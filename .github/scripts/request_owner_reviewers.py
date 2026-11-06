#!/usr/bin/env python3
"""Auto-request the mapped integration reviewer(s) on a PR.

Replaces what CODEOWNERS used to do (there is no CODEOWNERS in this model —
see .github/OWNER_APPROVAL_DESIGN.md). For each ``Integrations/<Name>/``
directory the PR touches, resolve the required reviewer(s) exactly as
``check_owner_approval.py`` does (same shared ``resolve_required_reviewers``,
so the two scripts can never disagree on who's required) and formally request
their review.

The GitHub API only lets you *formally* request review from repo collaborators.
Designated reviewers here typically have no repo access, so a formal request
returns 422. In that case we fall back to an ``@mention`` comment so the
reviewer is still notified. A directory that resolves to a new-but-undeclared
or existing-but-unmapped reviewer gets its own notice in the same comment,
since otherwise nobody would ever be told a mapping is missing. The comment is
upserted (edited in place on later pushes) rather than posted once, so it
stays accurate as the PR's declarations/mappings change.

Usage:  request_owner_reviewers.py <pr-number>

Env:    GH_TOKEN            token with pull-requests:write, issues:write
        GITHUB_REPOSITORY   "owner/repo"
"""

import json
import os
import sys
import urllib.error
import urllib.request

API = "https://api.github.com"
MAPPING_FILE = ".github/owner-reviewers.yml"
COMMENT_MARKER = "<!-- owner-reviewers-request -->"

# Reuse the resolver/mapping/PR helpers so this script can never disagree with
# the gate about who's required or why.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_owner_approval import (  # noqa: E402
    BYPASS_LABEL,
    NOTE_EXISTING_UNMAPPED,
    NOTE_NEW_UNMAPPED,
    fetch_pr,
    has_bypass_label,
    load_mapping,
    resolve_required_reviewers,
    touched_integration_dirs,
)


def die(msg, code=1):
    print(msg, file=sys.stderr)
    sys.exit(code)


def _token():
    tok = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if not tok:
        die("GH_TOKEN / GITHUB_TOKEN not set")
    return tok


def api(method, path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(f"{API}{path}", data=data, method=method)
    req.add_header("Authorization", f"Bearer {_token()}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    if data is not None:
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req) as resp:
        raw = resp.read()
        return json.loads(raw) if raw else {}


def api_get_list(path):
    if "?" not in path:
        path += "?per_page=100"
    return api("GET", path)


def find_existing_comment(repo, pr):
    for c in api_get_list(f"/repos/{repo}/issues/{pr}/comments"):
        if COMMENT_MARKER in (c.get("body") or ""):
            return c["id"]
    return None


def upsert_comment(repo, pr, body):
    existing = find_existing_comment(repo, pr)
    if existing:
        api("PATCH", f"/repos/{repo}/issues/comments/{existing}", {"body": body})
        print(f"Updated existing reviewer-request notice (comment {existing}).")
    else:
        api("POST", f"/repos/{repo}/issues/{pr}/comments", {"body": body})
        print("Posted new reviewer-request notice.")


def main():
    if len(sys.argv) != 2:
        die("Usage: request_owner_reviewers.py <pr-number>")
    pr = sys.argv[1]
    repo = os.environ.get("GITHUB_REPOSITORY")
    if not repo:
        die("GITHUB_REPOSITORY not set")

    # Checked before any resolution work, same as check_owner_approval.py: a PR
    # labeled for an admin bulk change gets no reviewer requests or @-mentions
    # at all, not just a skipped approval requirement.
    pr_data = fetch_pr(repo, pr)
    if has_bypass_label(pr_data):
        print(f'PR carries the "{BYPASS_LABEL}" label — no reviewers requested or notified.')
        return

    dirs = touched_integration_dirs(repo, pr)
    if not dirs:
        print("No integration directories touched — nothing to request.")
        return

    base_mapping = load_mapping(MAPPING_FILE)
    author = (pr_data.get("user") or {}).get("login")
    resolved = resolve_required_reviewers(repo, pr, dirs, base_mapping, pr_data)

    # Don't request review from the PR author (GitHub rejects it anyway, and
    # check_owner_approval.py treats an author-as-reviewer slot as self-attested).
    wanted = set()
    unresolved = []  # (dirpath, note) for NEW_UNMAPPED / EXISTING_UNMAPPED
    for d in dirs:
        info = resolved[d]
        if info["note"] in (NOTE_NEW_UNMAPPED, NOTE_EXISTING_UNMAPPED):
            unresolved.append((d, info["note"]))
            continue
        for reviewer in info["required"]:
            if reviewer != author:
                wanted.add(reviewer)

    reviewers = sorted(wanted)
    formally_requested = []
    needs_mention = []

    if reviewers:
        # Try a formal request first; on 422 (non-collaborator) fall back per-user.
        try:
            api(
                "POST",
                f"/repos/{repo}/pulls/{pr}/requested_reviewers",
                {"reviewers": reviewers},
            )
            formally_requested = reviewers
        except urllib.error.HTTPError as e:
            if e.code != 422:
                die(f"Failed to request reviewers: {e.code} {e.read().decode(errors='replace')}")
            for r in reviewers:
                try:
                    api(
                        "POST",
                        f"/repos/{repo}/pulls/{pr}/requested_reviewers",
                        {"reviewers": [r]},
                    )
                    formally_requested.append(r)
                except urllib.error.HTTPError as e2:
                    if e2.code == 422:
                        needs_mention.append(r)
                    else:
                        die(f"Failed to request {r}: {e2.code}")

    if formally_requested:
        print(f"Formally requested review from: {', '.join(formally_requested)}")

    blocks = []
    if needs_mention:
        mentions = " ".join(f"@{r}" for r in needs_mention)
        blocks.append(
            f"👋 This PR changes {', '.join('`' + d + '`' for d in dirs)}.\n\n"
            f"Requesting review from the designated integration reviewer(s): {mentions}\n\n"
            "Your approving review is required before this can merge. You don't need "
            "any repository access — just open the **Files changed** tab and submit a review."
        )
        print(f"Posted/updated @mention request for non-collaborator reviewer(s): {', '.join(needs_mention)}")

    for d, note in unresolved:
        if note == NOTE_NEW_UNMAPPED:
            blocks.append(
                f"⚠️ `{d}` is a new integration with no reviewer declared yet. Add a line like "
                f"`{d}: [your-github-username]` to `{MAPPING_FILE}` in this PR (see CONTRIBUTING.md) "
                "so the reviewer gate knows who to request."
            )
        else:
            blocks.append(
                f"⚠️ `{d}` has no reviewer mapping in `{MAPPING_FILE}` yet. "
                "A maintainer needs to add one before this can merge."
            )

    if not blocks:
        print("Nothing to notify — every touched directory already has its reviewer(s) requested or self-attested.")
        return

    body = COMMENT_MARKER + "\n\n" + "\n\n---\n\n".join(blocks)
    upsert_comment(repo, pr, body)


if __name__ == "__main__":
    main()
