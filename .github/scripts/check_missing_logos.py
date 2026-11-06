#!/usr/bin/env python3
"""Notify PR authors when an integration will fall back to the generic logo.

A missing logo is *not* a blocker (see scripts/validate-integration.js): a
listing without its own image falls back to the generic marketplace logo,
``assets/integration-fallback.svg``. This script makes that fallback visible so
the author can supply a real logo if they want one.

For every ``Integrations/<Name>/`` directory the PR touches, it inspects the
folder contents *at the PR head commit* (via the contents API — never by
executing PR code, so it is safe under ``pull_request_target``) and flags any
folder with no top-level image file. It then posts — and keeps updated — a
single sticky comment on the PR. If every touched integration has a logo, an
existing notice is edited to a resolved state instead of leaving stale text.

Usage:  check_missing_logos.py <pr-number>

Env:    GH_TOKEN            token with pull-requests:write, issues:write
        GITHUB_REPOSITORY   "owner/repo" (set automatically in Actions)
        GITHUB_SERVER_URL   e.g. https://github.com (set automatically)
"""

import json
import os
import sys
import urllib.error
import urllib.request

API = "https://api.github.com"
COMMENT_MARKER = "<!-- generic-logo-notice -->"
FALLBACK_ASSET = "assets/integration-fallback.svg"
LOGO_EXTENSIONS = (".png", ".svg", ".jpg", ".jpeg", ".webp")

# Reuse the mapping/PR helpers so the two scripts can never disagree on how PR
# files are parsed.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_owner_approval import api_get, touched_integration_dirs  # noqa: E402


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
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        die(f"GitHub API error {e.code} for {path}: {e.read().decode(errors='replace')}")


def head_sha(repo, pr):
    return api("GET", f"/repos/{repo}/pulls/{pr}")["head"]["sha"]


def folder_has_image(repo, folder, ref):
    """True if <folder> has a top-level image file at the given ref.

    Uses the contents API at the PR head SHA — reads data only, never executes
    PR code, so it is safe under pull_request_target.
    """
    path = f"/repos/{repo}/contents/{folder}?ref={ref}"
    req = urllib.request.Request(f"{API}{path}")
    req.add_header("Authorization", f"Bearer {_token()}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    try:
        with urllib.request.urlopen(req) as resp:
            entries = json.load(resp)
    except urllib.error.HTTPError as e:
        if e.code == 404:
            # Folder was deleted in this PR — nothing to flag.
            return True
        die(f"GitHub API error {e.code} for {path}: {e.read().decode(errors='replace')}")
    if not isinstance(entries, list):
        return True
    return any(
        entry.get("type") == "file"
        and entry.get("name", "").lower().endswith(LOGO_EXTENSIONS)
        for entry in entries
    )


def find_existing_comment(repo, pr):
    for c in api_get(f"/repos/{repo}/issues/{pr}/comments"):
        if COMMENT_MARKER in (c.get("body") or ""):
            return c["id"]
    return None


def upsert_comment(repo, pr, body):
    existing = find_existing_comment(repo, pr)
    if existing:
        api("PATCH", f"/repos/{repo}/issues/comments/{existing}", {"body": body})
        print(f"Updated existing logo notice (comment {existing}).")
    else:
        api("POST", f"/repos/{repo}/issues/{pr}/comments", {"body": body})
        print("Posted new logo notice.")


def build_body(repo, base_ref, missing):
    server = os.environ.get("GITHUB_SERVER_URL", "https://github.com").rstrip("/")
    logo_link = f"{server}/{repo}/blob/{base_ref}/{FALLBACK_ASSET}"
    lines = [
        COMMENT_MARKER,
        "### ⚠️ Generic logo will be used",
        "",
        "The following integration(s) in this PR have no logo image, so the "
        f"[generic fallback logo]({logo_link}) will be shown on the Marketplace listing:",
        "",
    ]
    lines += [f"- `{d}`" for d in missing]
    lines += [
        "",
        "This is **not** a blocker — it's fine to merge as-is. To use a custom "
        "logo instead, add a square image (`.png`, `.svg`, `.jpg`, `.jpeg`, or "
        "`.webp`, ideally ~400×400 and under 500 KB) to the integration folder "
        "and set `logoFile` in `integration_metadata.json`.",
    ]
    return "\n".join(lines)


def build_resolved_body():
    return "\n".join(
        [
            COMMENT_MARKER,
            "### ✅ Logos present",
            "",
            "All integrations in this PR now include a logo — the generic "
            "fallback is no longer needed.",
        ]
    )


def main():
    if len(sys.argv) != 2:
        die("Usage: check_missing_logos.py <pr-number>")
    pr = sys.argv[1]
    repo = os.environ.get("GITHUB_REPOSITORY")
    if not repo:
        die("GITHUB_REPOSITORY not set")

    dirs = touched_integration_dirs(repo, pr)
    if not dirs:
        print("No Integrations/<Name>/ directories changed — nothing to check.")
        return

    ref = head_sha(repo, pr)
    missing = [d for d in dirs if not folder_has_image(repo, d, ref)]

    if missing:
        print("Missing logos: " + ", ".join(missing))
        base_ref = os.environ.get("GITHUB_BASE_REF", "main")
        upsert_comment(repo, pr, build_body(repo, base_ref, missing))
    else:
        print("All touched integrations have a logo.")
        # Only edit if we previously posted a notice; don't create noise.
        if find_existing_comment(repo, pr):
            upsert_comment(repo, pr, build_resolved_body())


if __name__ == "__main__":
    main()
