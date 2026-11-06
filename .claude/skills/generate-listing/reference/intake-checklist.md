# Intake checklist — ask, don't guess

Fields below are required or closed-vocabulary, so a wrong guess is either a hard validator error
or a claim the human submitter has to stand behind. If `generate-listing`'s source material
doesn't clearly evidence one of these, ask the user rather than inferring it. This list only
covers fields worth stopping for — the full schema lives in `INTEGRATION_GUIDE.md`.

- **`products[]`** (required, closed vocabulary) — which of `Certificate Manager Self-Hosted`,
  `Certificate Manager SaaS`, `Next-Gen Trust Security`, `Zero Touch PKI` does this integration
  actually support? An incorrect value is a hard validator error and controls which
  `OVERVIEW-<suffix>.md` renders.
- **`categories[]`** (closed vocabulary, one axis: what kind of system it connects to) — see
  `Config/approved_categories.json` for the full list. Ask if nothing in the source material maps
  cleanly to one of the ~17 approved categories.
- **`price`** (required) — `Free` or `Paid`. If `Paid`, also need the `acquisition` object:
  `type` (`contact-sales` or `contact-partner`), `label`, `url`, optional `description`.
- **`support`** — `Community`, `Supported`, or `Partner`.
- **`supportEmail`** or **`supportUrl`** — only one is ever shown; ask which one applies if the
  source material doesn't make it obvious.
- **`author`** — the name or company to credit. Don't guess a legal entity name from a GitHub org.
- **`license`** (+ `licenseUrl`) — only needed if the integration ships `downloadFiles`. Partner
  downloads use `"MIT"` (no `licenseUrl`) or the partner's own license plus its URL; Palo Alto
  Networks and Professional Services downloads use the Software Tool License Agreement; community
  downloads use the Marketplace Terms of Use. See the License section in `INTEGRATION_GUIDE.md`
  for the exact values, and confirm the choice with the submitter.
- **GitHub username(s) for `.github/owner-reviewers.yml`** — required in the same PR for a
  brand-new integration (`CONTRIBUTING.md`'s "Reviewer approval required to merge"). Not needed
  for an update to an existing integration.
- **Contributor Terms acceptance** — not this skill's job to resolve, but flag it in the final
  report for an external (non-Palo-Alto-Networks) contributor: `CONTRIBUTOR_TERMS.md` must be
  accepted before the PR is reviewed.
