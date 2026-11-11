#!/usr/bin/env python3
"""Gate a PR on the designated integration reviewer(s) approving.

For every ``Integrations/<Name>/`` directory the PR touches, look up the
required reviewer usernames in ``.github/owner-reviewers.yml`` and pass only if
each of them has a *current* ``APPROVED`` review on the PR. Internal staff and
external partners are treated identically: a username is a username, and the
reviewer needs no repo access — their review is API-readable on a public repo.

This is the mechanism that enforces the second review gate, which GitHub's
native required-review rules cannot do because those only count approvals from
users with write access (see .github/OWNER_APPROVAL_DESIGN.md).

Reviewer mapping entries come in two shapes (see ``.github/owner-reviewers.yml``
for the full schema doc):

- A bare list — applies to every product of that integration.
- A map keyed by the exact product string from ``Config/approved_products.json``
  — scopes reviewers to just that product. Which product(s) a given touched
  file affects is resolved per-file: ``OVERVIEW-<suffix>.md`` and
  ``ReleaseNotes/<ver>-<suffix>.md`` map by suffix; ``integration_metadata.json``
  is diffed structurally (see ``metadata_changed_products``); anything else
  (logo, unsuffixed docs) is treated as shared across every product.

A directory with no entry on the base branch normally fails the gate outright
(a human must decide who reviews it). The one exception: if the directory does
not exist at all on the base branch (a brand-new integration), the gate will
instead trust an entry the PR itself adds to ``.github/owner-reviewers.yml`` —
read from the PR's *head* commit via the Contents API, never executed. This
never applies to a directory that already exists on the base branch (even to
add a new product variant to it), which prevents a PR from redirecting review
away from its legitimate reviewer.

A required reviewer who is also the PR's author is treated as self-attested
and does not need a separate ``APPROVED`` review (GitHub blocks self-approval
outright, so requiring one would create an unresolvable deadlock for the very
common case of a solo-maintained integration). ``mim-final-approvers`` still
approves every PR unconditionally, so this doesn't remove any backstop.

Usage:  check_owner_approval.py <pr-number>

Env:    GH_TOKEN            token with pull-requests:read (github.token is fine)
        GITHUB_REPOSITORY   "owner/repo" (set automatically in Actions)
        GITHUB_STEP_SUMMARY optional; a markdown summary is appended if present
"""

import base64
import json
import os
import re
import sys
import urllib.error
import urllib.request

API = "https://api.github.com"
MAPPING_FILE = ".github/owner-reviewers.yml"

# Review states that do NOT change a user's effective approval state and should
# be ignored when computing the latest state per reviewer.
IGNORED_STATES = {"COMMENTED", "PENDING"}

# Mirrors the product -> file-suffix convention. The authoritative list is
# docs/config/marketplace-products.json in pan-dev-mim; scripts/validate-integration.js's
# DOC_SUFFIX_BY_PRODUCT is another copy. Keep this in sync with those if a
# product's suffix or the approved list ever changes.
PRODUCT_SUFFIX = {
    "Certificate Manager SaaS": "saas",
    "Certificate Manager Self-Hosted": "selfhosted",
    "Next-Gen Trust Security": "ngts",
    "Zero Touch PKI": "ztpki",
}
SUFFIX_PRODUCT = {v: k for k, v in PRODUCT_SUFFIX.items()}

GITHUB_USERNAME_RE = re.compile(r"^[A-Za-z0-9](?:[A-Za-z0-9]|-(?=[A-Za-z0-9])){0,38}$")

_OVERVIEW_RE = re.compile(r"^OVERVIEW-([a-z0-9]+)\.md$")
_RELEASE_NOTE_RE = re.compile(r"^ReleaseNotes/[\w]+-([a-z0-9]+)\.md$")

# Per-directory resolution outcomes, used both for gate messaging and by
# request_owner_reviewers.py to decide who/whether to notify.
NOTE_MAPPED = "mapped"
NOTE_SELF_DECLARED = "self_declared"
NOTE_NEW_UNMAPPED = "new_unmapped"
NOTE_EXISTING_UNMAPPED = "existing_unmapped"

# A PR carrying this label skips the per-integration reviewer gate entirely —
# no approval required, and (via request_owner_reviewers.py) no reviewer is
# requested or @-mentioned. Applying a label requires write access, which only
# mim-final-approvers holds, so an outside contributor can never self-grant
# this. Intended for a maintainer's own mechanical/bulk changes (schema
# migrations, repo-wide backfills) — not a substitute for routine per-
# integration review. See .github/OWNER_APPROVAL_DESIGN.md.
BYPASS_LABEL = "admin-bulk"


def die(msg, code=1):
    print(msg, file=sys.stderr)
    sys.exit(code)


def _token():
    tok = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if not tok:
        die("GH_TOKEN / GITHUB_TOKEN not set")
    return tok


def api_get(path):
    """GET a paginated GitHub API endpoint, returning the concatenated list."""
    results = []
    url = f"{API}{path}"
    if "?" not in url:
        url += "?per_page=100"
    elif "per_page" not in url:
        url += "&per_page=100"

    while url:
        req = urllib.request.Request(url)
        req.add_header("Authorization", f"Bearer {_token()}")
        req.add_header("Accept", "application/vnd.github+json")
        req.add_header("X-GitHub-Api-Version", "2022-11-28")
        try:
            with urllib.request.urlopen(req) as resp:
                results.extend(json.load(resp))
                url = _next_link(resp.headers.get("Link"))
        except urllib.error.HTTPError as e:
            die(f"GitHub API error {e.code} for {url}: {e.read().decode(errors='replace')}")
    return results


def _next_link(link_header):
    if not link_header:
        return None
    for part in link_header.split(","):
        section = part.split(";")
        if len(section) < 2:
            continue
        url = section[0].strip().lstrip("<").rstrip(">")
        rel = section[1].strip()
        if rel == 'rel="next"':
            return url
    return None


def _get_raw(path):
    """GET a single resource. Returns (status_code, parsed_json_or_None).

    404 is returned to the caller rather than treated as an error, since
    "does this exist at this ref" is itself the signal several callers need.
    Any other non-2xx status still dies loudly.
    """
    req = urllib.request.Request(f"{API}{path}")
    req.add_header("Authorization", f"Bearer {_token()}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            return resp.status, (json.loads(raw) if raw else None)
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return 404, None
        die(f"GitHub API error {e.code} for {path}: {e.read().decode(errors='replace')}")


def dir_exists_at_ref(repo, path, ref):
    """True if `path` exists at `ref` — read-only Contents API check, never
    executes anything, safe under pull_request_target."""
    status, _ = _get_raw(f"/repos/{repo}/contents/{path}?ref={ref}")
    return status == 200


def fetch_file_at_ref(repo, path, ref):
    """Return the decoded text content of a file at `ref`, or None if the
    file doesn't exist there or its content can't be decoded. Read-only —
    the content is treated as data, never executed."""
    status, data = _get_raw(f"/repos/{repo}/contents/{path}?ref={ref}")
    if status != 200 or not isinstance(data, dict):
        return None
    content = data.get("content")
    if not content:
        return None
    try:
        return base64.b64decode(content).decode("utf-8")
    except (ValueError, UnicodeDecodeError):
        return None


def fetch_pr(repo, pr):
    status, data = _get_raw(f"/repos/{repo}/pulls/{pr}")
    if status != 200 or not isinstance(data, dict):
        die(f"Could not fetch PR #{pr} metadata (status {status})")
    return data


def load_mapping(path):
    """Load ``.github/owner-reviewers.yml`` from the local (base-branch)
    checkout.

    Prefers PyYAML; falls back to a tiny parser for the constrained shape this
    file uses, so the gate keeps working even if PyYAML is unavailable on the
    runner.
    """
    if not os.path.exists(path):
        die(
            f"Required mapping file '{path}' not found. "
            "It must exist before this gate can pass."
        )
    with open(path, encoding="utf-8") as fh:
        return _parse_mapping_text(fh.read())


def _parse_mapping_text(text):
    """Parse mapping YAML text into {dir: entry}, where entry is always
    normalized to {"*": [users]} (bare list/string) or
    {<product>: [users], ...} (per-product map). Shared by the local
    base-branch load and by reading a candidate mapping from a PR's head
    commit via the Contents API, so the two can never disagree on shape."""
    try:
        import yaml  # type: ignore

        data = yaml.safe_load(text) or {}
        return {k: _normalize_entry(v) for k, v in data.items()}
    except ImportError:
        return _parse_flat_yaml(text)


def _as_list(v):
    if v is None:
        return []
    if isinstance(v, str):
        return [v.strip()] if v.strip() else []
    return [str(x).strip() for x in v if str(x).strip()]


def _normalize_entry(v):
    if isinstance(v, dict):
        return {str(k).strip(): _as_list(val) for k, val in v.items()}
    return {"*": _as_list(v)}


def _parse_flat_yaml(text):
    """Fallback parser for the constrained shape this file uses: top-level
    ``key: [a, b]`` / ``key: a`` (bare list), or a top-level ``key:`` with no
    value followed by indented ``  <product>: [a, b]`` lines (per-product
    map). Not a general YAML parser — only handles this file's own shape."""
    mapping = {}
    current_key = None
    for raw in text.splitlines():
        line = raw.split("#", 1)[0].rstrip()
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip(" "))
        key, sep, val = line.strip().partition(":")
        if not sep:
            continue
        key = key.strip()
        val = val.strip()
        if indent == 0:
            current_key = key
            mapping[current_key] = {"*": _parse_list_or_scalar(val)} if val else {}
        elif current_key is not None and isinstance(mapping.get(current_key), dict):
            mapping[current_key][key] = _parse_list_or_scalar(val)
    # A top-level "key:" with no inline value and no indented children ends up
    # as {} — normalize it to {"*": []} to match the PyYAML path's handling of
    # a null value, so both parsers treat "declared nothing" identically.
    return {k: (v if v else {"*": []}) for k, v in mapping.items()}


def _parse_list_or_scalar(val):
    if val.startswith("[") and val.endswith("]"):
        items = [x.strip().strip("'\"") for x in val[1:-1].split(",")]
        return [x for x in items if x]
    return [val.strip("'\"")] if val else []


def touched_integration_dirs(repo, pr):
    dirs = set()
    for f in api_get(f"/repos/{repo}/pulls/{pr}/files"):
        parts = f["filename"].split("/")
        if len(parts) >= 2 and parts[0] == "Integrations":
            dirs.add(f"Integrations/{parts[1]}")
    return sorted(dirs)


def touched_files_by_dir(repo, pr):
    """Return {dirpath: [file paths relative to the directory]} for touched
    Integrations/<Name>/ files. Only called when a directory's mapping entry
    is per-product — bare-list directories never need per-file resolution."""
    by_dir = {}
    for f in api_get(f"/repos/{repo}/pulls/{pr}/files"):
        parts = f["filename"].split("/")
        if len(parts) >= 2 and parts[0] == "Integrations":
            d = f"Integrations/{parts[1]}"
            by_dir.setdefault(d, []).append("/".join(parts[2:]))
    return by_dir


def is_valid_github_username(name):
    return bool(GITHUB_USERNAME_RE.match(name))


def _valid_declaration(entry):
    all_names = [name for names in entry.values() for name in names]
    return bool(all_names) and all(is_valid_github_username(n) for n in all_names)


def _suffix_from_filename(rel_path):
    m = _OVERVIEW_RE.match(rel_path) or _RELEASE_NOTE_RE.match(rel_path)
    return m.group(1) if m else None


def _all_products(meta_json):
    variants = meta_json.get("productVariants")
    if variants:
        return {v.get("product") for v in variants if v.get("product")}
    return set(meta_json.get("products") or [])


def metadata_changed_products(base_json, head_json):
    """Return the set of product strings whose content changed between the
    base and head versions of integration_metadata.json.

    A change to any key other than `productVariants` (including the root
    `products` list, `defaults`, `name`, etc.) is treated as a shared/root
    change affecting every product currently on the integration (at head) —
    not silently scoped away. Otherwise, only the productVariants entries
    actually added/removed/changed are affected, matched by `product` so
    reordering or insertion doesn't misattribute a change to the wrong one.
    Comparing parsed JSON (not raw text) means pure whitespace/key-order
    diffs resolve to "no change".
    """
    base_root = {k: v for k, v in base_json.items() if k != "productVariants"}
    head_root = {k: v for k, v in head_json.items() if k != "productVariants"}
    if base_root != head_root:
        return _all_products(head_json)

    base_variants = {v.get("product"): v for v in base_json.get("productVariants", []) if v.get("product")}
    head_variants = {v.get("product"): v for v in head_json.get("productVariants", []) if v.get("product")}
    return {
        product
        for product in set(base_variants) | set(head_variants)
        if base_variants.get(product) != head_variants.get(product)
    }


def _products_affected_by_file(repo, d, rel_path, base_sha, head_sha):
    if rel_path == "integration_metadata.json":
        base_text = fetch_file_at_ref(repo, f"{d}/integration_metadata.json", base_sha)
        head_text = fetch_file_at_ref(repo, f"{d}/integration_metadata.json", head_sha)
        base_json = json.loads(base_text) if base_text else {}
        head_json = json.loads(head_text) if head_text else {}
        return metadata_changed_products(base_json, head_json)

    suffix = _suffix_from_filename(rel_path)
    if suffix and suffix in SUFFIX_PRODUCT:
        return {SUFFIX_PRODUCT[suffix]}

    # No recognizable per-product suffix (logo, generic OVERVIEW.md/README.md,
    # unsuffixed release note, etc.) — shared across every product at head.
    head_text = fetch_file_at_ref(repo, f"{d}/integration_metadata.json", head_sha)
    head_json = json.loads(head_text) if head_text else {}
    return _all_products(head_json)


def _resolve_entry_for_dir(repo, pr, d, entry, pr_data):
    """Resolve (required_reviewers, unmapped_products) for one directory
    given its already-known mapping entry, scoped to the files this PR
    touches. Bare-list entries (the common case) never need the extra API
    calls below — every product resolves to the same list anyway."""
    if set(entry) <= {"*"}:
        return set(entry.get("*", [])), set()

    files = touched_files_by_dir(repo, pr).get(d, [])
    base_sha, head_sha = pr_data["base"]["sha"], pr_data["head"]["sha"]

    affected = set()
    for rel_path in files:
        affected |= _products_affected_by_file(repo, d, rel_path, base_sha, head_sha)

    required, unmapped = set(), set()
    for product in affected:
        reviewers = entry.get(product) or entry.get("*")
        if reviewers:
            required |= set(reviewers)
        else:
            unmapped.add(product)
    return required, unmapped


def resolve_required_reviewers(repo, pr, dirs, base_mapping, pr_data):
    """Resolve the required reviewer set for each touched integration
    directory. Returns {dirpath: {"required": set[str],
    "unmapped_products": set[str], "note": str}}.

    A directory's mapping entry from the base branch is trusted as-is. A
    directory absent from the base mapping falls back to a self-declared
    entry in the PR's own head commit ONLY if the directory does not exist at
    all on the base branch — an existing, merely-unmapped directory always
    requires a maintainer to add the entry separately.
    """
    results = {}
    head_declared = None  # lazily fetched only if a genuinely-new dir needs it

    for d in dirs:
        if d in base_mapping:
            required, unmapped = _resolve_entry_for_dir(repo, pr, d, base_mapping[d], pr_data)
            results[d] = {"required": required, "unmapped_products": unmapped, "note": NOTE_MAPPED}
            continue

        base_sha = pr_data["base"]["sha"]
        if dir_exists_at_ref(repo, d, base_sha):
            results[d] = {"required": set(), "unmapped_products": set(), "note": NOTE_EXISTING_UNMAPPED}
            continue

        if head_declared is None:
            head_sha = pr_data["head"]["sha"]
            text = fetch_file_at_ref(repo, MAPPING_FILE, head_sha)
            head_declared = _parse_mapping_text(text) if text else {}

        candidate = head_declared.get(d)
        if not candidate or not _valid_declaration(candidate):
            results[d] = {"required": set(), "unmapped_products": set(), "note": NOTE_NEW_UNMAPPED}
            continue

        required, unmapped = _resolve_entry_for_dir(repo, pr, d, candidate, pr_data)
        results[d] = {"required": required, "unmapped_products": unmapped, "note": NOTE_SELF_DECLARED}

    return results


def current_approvers(repo, pr):
    """Return the set of logins whose latest meaningful review is APPROVED."""
    latest = {}  # login -> state
    for review in api_get(f"/repos/{repo}/pulls/{pr}/reviews"):
        state = (review.get("state") or "").upper()
        if state in IGNORED_STATES:
            continue
        login = (review.get("user") or {}).get("login")
        if login:
            latest[login] = state  # reviews come back in chronological order
    return {login for login, state in latest.items() if state == "APPROVED"}


def summarize(lines):
    path = os.environ.get("GITHUB_STEP_SUMMARY")
    if not path:
        return
    with open(path, "a", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")


def has_bypass_label(pr_data):
    return any((label.get("name") or "") == BYPASS_LABEL for label in pr_data.get("labels") or [])


def main():
    if len(sys.argv) != 2:
        die("Usage: check_owner_approval.py <pr-number>")
    pr = sys.argv[1]
    repo = os.environ.get("GITHUB_REPOSITORY")
    if not repo:
        die("GITHUB_REPOSITORY not set")

    # Fetched first and checked before any mapping/reviewer work: a PR labeled
    # for an admin bulk change skips this gate entirely, no matter how many
    # integrations it touches.
    pr_data = fetch_pr(repo, pr)
    if has_bypass_label(pr_data):
        msg = f'PR carries the "{BYPASS_LABEL}" label — per-integration reviewer gate bypassed.'
        print(msg)
        summarize(["## Integration reviewer gate", "", f"- ⏭️ {msg}"])
        return

    base_mapping = load_mapping(MAPPING_FILE)
    dirs = touched_integration_dirs(repo, pr)

    summary = ["## Integration reviewer gate", ""]

    if not dirs:
        msg = "No `Integrations/<Name>/` directories changed — reviewer gate not applicable."
        print(msg)
        summary += [msg]
        summarize(summary)
        return
    pr_author = (pr_data.get("user") or {}).get("login")
    resolved = resolve_required_reviewers(repo, pr, dirs, base_mapping, pr_data)
    approvers = current_approvers(repo, pr)

    print(f"Touched integrations: {', '.join(dirs)}")
    print(f"Current approvers:    {', '.join(sorted(approvers)) or '(none)'}")

    failed = False
    for d in dirs:
        info = resolved[d]
        note, required, unmapped = info["note"], info["required"], info["unmapped_products"]

        if note == NOTE_EXISTING_UNMAPPED:
            failed = True
            line = (
                f"- ❌ `{d}` — no reviewer mapping in `{MAPPING_FILE}`. Add an entry before this "
                "can merge (self-declared entries in this PR aren't trusted for integrations "
                "that already exist)."
            )
            print(f"FAIL: {d} has no reviewer mapping in {MAPPING_FILE}")
            summary.append(line)
            continue

        if note == NOTE_NEW_UNMAPPED:
            failed = True
            line = (
                f"- ❌ `{d}` — new integration with no reviewer declared. Add a line like "
                f"`{d}: [your-github-username]` to `{MAPPING_FILE}` in this PR (see CONTRIBUTING.md)."
            )
            print(f"FAIL: {d} is a new integration with no valid self-declared reviewer")
            summary.append(line)
            continue

        if unmapped:
            failed = True
            line = (
                f"- ❌ `{d}` — no reviewer mapped for product(s): {', '.join(sorted(unmapped))}. "
                f"Add entries to `{MAPPING_FILE}`."
            )
            print(f"FAIL: {d} has unmapped product(s): {', '.join(sorted(unmapped))}")
            summary.append(line)
            continue

        if not required:
            failed = True
            line = f"- ❌ `{d}` — reviewer mapping resolves to no one. Add usernames to `{MAPPING_FILE}`."
            print(f"FAIL: {d} resolved to zero required reviewers")
            summary.append(line)
            continue

        if note == NOTE_SELF_DECLARED:
            summary.append(
                f"- ℹ️ `{d}` — new integration; reviewer(s) self-declared in this PR: "
                f"{', '.join('@' + r for r in sorted(required))}."
            )

        # A required reviewer who is also the PR author is self-attested —
        # GitHub blocks literal self-approval, so this is the only way a
        # solo-maintained integration's own required review can ever pass.
        missing = sorted(r for r in required if r not in approvers and r != pr_author)
        if missing:
            failed = True
            line = f"- ❌ `{d}` — awaiting approval from: {', '.join('@' + m for m in missing)}"
            print(f"FAIL: {d} awaiting approval from {', '.join(missing)}")
        else:
            approved = sorted(r for r in required if r in approvers)
            self_attested = sorted(r for r in required if r == pr_author)
            bits = []
            if approved:
                bits.append(f"approved by {', '.join('@' + r for r in approved)}")
            if self_attested:
                bits.append(f"{', '.join('@' + r for r in self_attested)} self-attested (PR author)")
            line = f"- ✅ `{d}` — " + "; ".join(bits)
            print(f"OK:   {d} satisfied ({'; '.join(bits)})")
        summary.append(line)

    summarize(summary)

    if failed:
        die("\nRequired integration-reviewer approval(s) missing — gate not satisfied.")
    print("\nAll required integration reviewers have approved.")


if __name__ == "__main__":
    main()
