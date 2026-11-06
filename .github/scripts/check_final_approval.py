#!/usr/bin/env python3
"""Gate a PR on final-approver sign-off.

This replaces the native "Require review from specific teams" branch-ruleset
rule for the `mim-final-approvers` gate. That native rule has no way to treat
a PR's own author as satisfying it, even when they're the sole member of the
team — GitHub blocks literal self-approval unconditionally, so a solo final
approver could never merge their own PR without a manual bypass. This check
applies the same self-attestation rule as check_owner_approval.py: a required
approver who is also the PR's author counts as self-attested.

Reads the required usernames from .github/final-approvers.yml (kept in sync
with the `mim-final-approvers` GitHub team's membership) rather than querying
team membership via the API, since the default Actions token has no org/team
read scope.

Usage:  check_final_approval.py <pr-number>

Env:    GH_TOKEN            token with pull-requests:read (github.token is fine)
        GITHUB_REPOSITORY   "owner/repo" (set automatically in Actions)
        GITHUB_STEP_SUMMARY optional; a markdown summary is appended if present
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_owner_approval import current_approvers, die, fetch_pr, summarize  # noqa: E402

FINAL_APPROVERS_FILE = ".github/final-approvers.yml"


def load_final_approvers(path):
    """Load a flat list of usernames, one per line (plain or "- name" YAML
    list item). Not a general YAML parser — this file is only ever a flat
    list, so no need to pull in PyYAML for it."""
    if not os.path.exists(path):
        die(f"Required file '{path}' not found.")
    approvers = []
    with open(path, encoding="utf-8") as fh:
        for raw in fh:
            line = raw.split("#", 1)[0].strip()
            if not line:
                continue
            name = line.lstrip("-").strip().strip("'\"")
            if name:
                approvers.append(name)
    if not approvers:
        die(f"'{path}' has no final approvers listed.")
    return approvers


def main():
    if len(sys.argv) != 2:
        die("Usage: check_final_approval.py <pr-number>")
    pr = sys.argv[1]
    repo = os.environ.get("GITHUB_REPOSITORY")
    if not repo:
        die("GITHUB_REPOSITORY not set")

    required = load_final_approvers(FINAL_APPROVERS_FILE)
    pr_data = fetch_pr(repo, pr)
    author = (pr_data.get("user") or {}).get("login")
    approvers = current_approvers(repo, pr)

    print(f"Required final approver(s): {', '.join(required)}")
    print(f"Current approvers:          {', '.join(sorted(approvers)) or '(none)'}")

    # A required approver who is also the PR author is self-attested — GitHub
    # blocks literal self-approval, so this is the only way a solo final
    # approver can ever merge their own PR without a standing bypass.
    missing = [r for r in required if r not in approvers and r != author]

    summary = ["## Final approver gate", ""]
    if missing:
        line = f"- ❌ awaiting approval from: {', '.join('@' + m for m in missing)}"
        print(f"FAIL: awaiting approval from {', '.join(missing)}")
    else:
        approved = [r for r in required if r in approvers]
        self_attested = [r for r in required if r == author]
        bits = []
        if approved:
            bits.append(f"approved by {', '.join('@' + r for r in approved)}")
        if self_attested:
            bits.append(f"{', '.join('@' + r for r in self_attested)} self-attested (PR author)")
        line = "- ✅ " + "; ".join(bits)
        print(f"OK: {'; '.join(bits)}")
    summary.append(line)
    summarize(summary)

    if missing:
        die("\nFinal-approver sign-off missing — gate not satisfied.")
    print("\nFinal-approver sign-off satisfied.")


if __name__ == "__main__":
    main()
