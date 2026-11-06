# Two-Gate PR Review for Marketplace Integrations

Every integration change requires two approvals before merge:

1. **`mim-final-approvers`** on every PR, regardless of which integration it touches.
2. **The integration's designated reviewer** — whoever owns that `Integrations/<Name>/` directory, internal staff or external partner, treated identically.

Everyone — internal contributors, partner developers, customers, community — contributes the same way: fork + pull request with **no access of any kind**. Nothing merges until both gates approve.

> **Why the design is shaped this way.** Two hard constraints drive everything:
>
> 1. **No one outside `mim-final-approvers` gets write access.** External partners are never org members, and internal contributors also fork/PR rather than holding write. GitHub only counts approvals toward native required-review rules when the reviewer has **write**, so *no* designated integration reviewer — internal or external — can be enforced natively.
> 2. **A GitHub `CODEOWNERS` file can only route to owners with write, and treats multiple owners on a line as alternatives (any one satisfies).** With no write-holding owners to list, CODEOWNERS has no job here.
>
> The result is a **single write-holding team** (`mim-final-approvers`) enforced natively via a branch ruleset, plus **one CI status check** (`owner-approval`) that enforces the per-integration reviewer — internal or external, uniformly — by reading their approving review through the API. This is the only mechanism that can gate on a no-write reviewer, and it lets internal and external contribution be genuinely identical.

## Current state

- The repo is public, so fork-based contribution works for anyone with a GitHub account.
- `mim-final-approvers` holds the only write access in this model. There is no CODEOWNERS file and no other write-holding team.
- Both `owner-approval` and `final-approval` are required status checks on the `marketplace-review` branch ruleset. Final-approver sign-off is enforced by the `final-approval` check (`.github/final-approvers.yml` + `.github/scripts/check_final_approval.py`), not by a native "require review from team" ruleset rule — see "Final-approver gate" below for why.
- The reviewer mapping (`.github/owner-reviewers.yml`) is sparsely populated — most existing integrations have no entry yet. That's fine for an integration whose next update is authored by its own maintainer (self-attestation, below) or is brand new (self-declaration, below); an update PR from someone other than the actual owner will fail the gate until a maintainer adds an entry.

## Final-approver gate

GitHub's native "require review from specific teams" ruleset rule blocks a PR's own author from satisfying it, with no override, even when the author is the sole member of the required team — which is the normal case for `mim-final-approvers` today. Rather than requiring a manual "bypass rules" checkbox on every self-authored PR, this gate uses the same technique as `owner-approval`: a required CI status check (`final-approval`, `.github/workflows/final-approval.yml`) that reads `.github/final-approvers.yml` and passes if every listed username either has a current `APPROVED` review, or is the PR's own author (self-attested — identical rule to the one below for per-integration reviewers, for the identical reason). Keep `.github/final-approvers.yml` in sync with the `mim-final-approvers` team's actual membership by hand; it's deliberately a flat file rather than a team-membership API call, since the default Actions token has no org/team read scope.

The `mim-final-approvers` team remains an "always" bypass actor on the ruleset as a safety valve (e.g. if this check has a bug), but routine merges shouldn't need it anymore.

## How the `owner-approval` gate works

Native branch protection cannot gate on a reviewer without write access. A GitHub Action can, because any reviewer's `APPROVED` review is recorded and readable via the API regardless of their access.

The `owner-approval` job (`.github/workflows/owner-approval.yml`, logic in `.github/scripts/check_owner_approval.py`):

- determines which `Integrations/<Name>/` directories the PR touches (from the diff),
- resolves the required reviewer(s) for those directories — from `.github/owner-reviewers.yml` on the base branch, or (see below) a self-declared entry for a brand-new directory,
- reads the PR's reviews (`GET /repos/{owner}/{repo}/pulls/{n}/reviews`),
- **passes only if every required reviewer has a current `APPROVED` review, or is the PR's own author** (self-attestation, below) — otherwise **fails**.

It triggers on `pull_request_target` (repo context and a token even for fork PRs) and `pull_request_review` (re-evaluates the moment a reviewer approves, so merge unblocks without a dummy commit), and holds only `contents: read` + `pull-requests: read` on the gate job — it must never check out or run untrusted PR code. The `request-reviewers` job (same workflow, `pull-requests: write` + `issues: write`) auto-requests/mentions the resolved reviewer(s) on `opened`/`reopened`/`synchronize`; it never blocks merge, it only notifies.

### Self-service reviewer declaration for new integrations

`.github/owner-reviewers.yml` can't have an entry for a directory that doesn't exist yet, so a first-time contributor's PR would otherwise always fail the gate with no way to self-serve. Instead: a directory that has no entry in the base-branch mapping, but also **does not exist at all on the base branch** (confirmed via `GET /repos/{repo}/contents/Integrations/<Name>?ref=<base_sha>` returning 404), is allowed to declare its own reviewer(s) by adding an entry to `.github/owner-reviewers.yml` in the same PR — read from the PR's head commit via the Contents API as data only, never executed.

This trust is deliberately narrow: it **never** applies to a directory that already exists on the base branch, even to add a new product variant to it — that always requires a maintainer to add the entry via a separate base-branch change. A same-PR edit to an existing directory's mapping has no effect on that PR's own gate evaluation (the gate only ever reads the base-branch mapping for existing directories), which is what prevents a PR from redirecting its own required reviewer.

### Self-attestation (a required reviewer who is also the PR author)

GitHub blocks literal self-approval, so a required reviewer who is also the PR's author could never produce an `APPROVED` review — for the very common case of a solo-maintained integration (contributor and reviewer are the same person), this would otherwise be a permanent deadlock. The gate treats that slot as self-attested and satisfied without a separate review. This applies uniformly to every mapping, not just self-declared ones. It costs nothing security-wise because `mim-final-approvers` still approves every PR unconditionally — this only removes a second approval that could never literally happen anyway.

### Per-product reviewer scoping

A directory's mapping entry may be a bare list (applies to every product) or a map keyed by the exact product string from `Config/approved_products.json` (scopes reviewers to just that product — see the schema comment in `.github/owner-reviewers.yml`). Resolution happens per touched file: `OVERVIEW-<suffix>.md` / `ReleaseNotes/<ver>-<suffix>.md` map by suffix; `integration_metadata.json` is diffed structurally between base and head (a change confined to one `productVariants[]` entry only requires that product's reviewer; a change to a shared/root field, including the `products` list itself, requires every product's reviewer); anything else (logo, unsuffixed docs) is treated as shared across every product. A product actually affected by the PR with no reviewer mapped fails the gate with an actionable message rather than being silently skipped.

### Admin bulk-change bypass

A PR carrying the `admin-bulk` label skips this gate entirely — `owner-approval` passes immediately with no reviewer resolution, and `request-reviewers` doesn't run at all, so no reviewer is requested or @-mentioned either (`BYPASS_LABEL` in `check_owner_approval.py`, shared by both scripts).

This exists for a maintainer's own mechanical/repo-spanning changes — a schema field added across every integration, a bulk backfill — where routing dozens or hundreds of individual per-integration reviews (and notifying every one of those owners) would be pure overhead for a change no owner needs to weigh in on. It is deliberately **not** a substitute for routine per-integration review: applying the label to a PR that meaningfully changes one integration's content defeats the whole point of the gate.

Applying a label requires write access, which only `mim-final-approvers` holds, so an outside contributor can never grant themselves this bypass — the `owner-approval` and `mim-final-approvers` gates together are still the only way to merge. The `owner-approval.yml` workflow re-runs on `labeled`/`unlabeled` so the check flips the moment the label is added or removed, rather than staying stuck on a stale run. Apply the label at PR-creation time (e.g. `gh pr create --label admin-bulk`) when possible — added retroactively, `request-reviewers` may already have fired on the earlier `opened` event, so reviewers can still end up requested/mentioned before the label lands.

## Contribution flow

No access of any kind is needed to contribute (public repo). This is identical for internal staff and external partners:

1. A contributor **forks** `pan-dev-mim-marketplace`.
2. They edit `Integrations/<TheirIntegration>/` on a branch in their fork — for a brand-new integration, including a self-declared reviewer entry in `.github/owner-reviewers.yml` (see CONTRIBUTING.md).
3. They open a **pull request** against `main`.
4. `request-reviewers` requests the resolved reviewer, the ruleset requires `mim-final-approvers`, and `owner-approval` tracks the reviewer's approval (or self-attestation).
5. Merge unlocks only after both gates pass and checks are green.

## Blast-radius note

`mim-final-approvers` has repo-wide write, so a member could in principle push changes spanning multiple integrations. The review gates block a bad *merge*, but a PR whose changed files span more than one `Integrations/<Name>/` directory isn't automatically rejected today — this is a possible future hardening step (a required status check failing any PR that crosses directories), not yet built.

## End-to-end test recipe

1. From a second account (or ask a teammate), fork and open a PR editing one integration's documentation.
2. Confirm `owner-approval` is **failing** (no reviewer approval yet) and `mim-final-approvers` is a required reviewer.
3. Have the mapped reviewer account submit an approving review: `owner-approval` flips to **passing**, but merge stays **blocked** on the `mim-final-approvers` gate.
4. Approve as `mim-final-approvers`: merge **unblocks**.
5. Open a second PR touching a *different* integration and confirm the correct reviewer is requested and required (proves per-directory routing works).
6. Open a PR creating a brand-new integration directory with a self-declared solo reviewer (yourself): confirm `owner-approval` passes on `mim-final-approvers` approval alone, with no second approval required.

## Caveats to remember

- **Only `mim-final-approvers` holds write** — it's the sole team, the only merge authority, and the native gate. Everyone else forks.
- **Reviewers need no repo access** on a public repo — internal or external, they fork/review with a plain GitHub account. Their `APPROVED` review is API-readable, and that is what the CI gate keys on.
- **No CODEOWNERS means no auto-requested reviewers** — this is handled by the `request-reviewers` job.
- **`pull_request_target` runs with repo secrets even for fork PRs** — never check out and execute untrusted PR code in that job; only read metadata/reviews via the API. The self-declaration mechanism above follows this same discipline: PR-head content is fetched and parsed as data, never executed.
- **The `owner-approval` CI check is the single load-bearing gate for all per-integration review.** Nothing else backstops it, so its correctness and the `pull_request_target` security discipline matter.
- **Write access is repo-wide, not per-directory.** See the blast-radius note above.
