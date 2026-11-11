# Contributing to MIM Marketplace

Thank you for contributing! This guide walks you through submitting a new integration or updating an existing one.

## Why contribute

- **Visibility**: your integration is listed and searchable alongside integrations from leading vendors and technology partners.
- **Less to build**: the marketplace hosts your downloads, normalizes your logo, renders your docs, and handles per-product variants for you.
- **Community**: you join the authors building the machine identity security ecosystem.

You don't need to list an integration here to use it. Build for your own environment first, then share it if it's useful to others.

## Prerequisites

- Node.js 20+
- Git

## Quick start

```bash
# 1. Fork this repository on GitHub, then clone your fork
git clone https://github.com/<your-username>/pan-dev-mim-marketplace.git
cd pan-dev-mim-marketplace

# 2. Create a branch
git checkout -b add-my-integration

# 3. Copy the template
cp -r Integrations/.template Integrations/MyIntegration
# Windows (cmd.exe): xcopy /E /I Integrations\.template Integrations\MyIntegration
# Windows (PowerShell) and Git Bash/WSL can use the cp command above as-is.

# 4. Edit your files (see INTEGRATION_GUIDE.md for details)

# 5. Install dependencies and validate
npm ci
node scripts/validate-integration.js Integrations/MyIntegration

# 6. Commit and push
git add Integrations/MyIntegration
git commit -m "feat: add MyIntegration"
git push origin add-my-integration

# 7. Open a pull request against main
#    GitHub shows a "Compare & pull request" button on your fork after the push,
#    or start one at https://github.com/PaloAltoNetworks/pan-dev-mim-marketplace/compare
#    With the GitHub CLI:
gh pr create --repo PaloAltoNetworks/pan-dev-mim-marketplace --base main --fill
```

In the pull request, say what the integration does and which products it supports, and confirm you've worked through the [Testing checklist](#testing-checklist). For a new integration, include its `.github/owner-reviewers.yml` entry in the same PR (see [Reviewer approval required to merge](#reviewer-approval-required-to-merge)). External contributors also need to accept the [Contributor Terms](#contributor-terms). The [Review process](#review-process) section explains what happens next.

## Optional: AI-assisted listing generation

If you use [Claude Code](https://claude.com/claude-code), this repo ships a `/generate-listing`
skill (`.claude/skills/generate-listing/`) that can draft `integration_metadata.json`,
`OVERVIEW-*.md`, and your initial release note from your existing codebase, a repo link, or just
your docs — for you to review and edit before opening a PR. It's entirely optional; the manual
steps above work the same with or without it, and it never commits or opens a PR on its own.

## Contributor Terms

External contributors (partners and third parties) must accept the [Contributor
Terms](CONTRIBUTOR_TERMS.md) before their first contribution is reviewed. Palo Alto
Networks employees contributing as part of their job don't need to accept them separately.

Acceptance records the contributor's entity name and authorized signatory. For
contributors who work for an employer, it also records an employer counter-signature.
Acceptance covers your later contributions too, until you end it in writing.

Signing instructions coming soon.

### Before you submit

The Contributor Terms govern; this list is a reminder.

- No copyleft or reciprocal dependencies (GPL, LGPL, AGPL, SSPL, Creative Commons) — [Section 4](CONTRIBUTOR_TERMS.md#4-representations-warranties-and-covenants)
- List third-party and open-source components with their licenses in an SBOM or NOTICE file — [Section 4](CONTRIBUTOR_TERMS.md#4-representations-warranties-and-covenants)
- Review and clear any AI-generated code yourself — [Section 4](CONTRIBUTOR_TERMS.md#4-representations-warranties-and-covenants)
- Submitting your logo and product names lets Palo Alto Networks use them on the listing — [Section 3](CONTRIBUTOR_TERMS.md#3-trademark--branding-license)

## Reviewer approval required to merge

Every PR needs two approvals before it can merge: one from the marketplace maintainers (always required, regardless of which integration you touch), and one from the designated reviewer for the specific integration you're changing — tracked in [`.github/owner-reviewers.yml`](.github/owner-reviewers.yml) and enforced automatically by the `owner-approval` check. Neither gate requires repo write access; a designated reviewer just opens the **Files changed** tab on your PR and submits a review.

**If you're submitting a brand-new integration**, add an entry for it to `.github/owner-reviewers.yml` in the same PR that creates the integration, naming the GitHub username(s) who should review changes to it going forward — most often just yourself:

```yaml
Integrations/MyIntegration: [your-github-username]
```

This only works for a genuinely new directory (one that doesn't exist on `main` yet) — the gate reads this declaration straight out of your PR. If you list only yourself, that's fine: GitHub can't let you approve your own PR, so the check treats you being both the author and the declared reviewer as sufficient on its own, and the maintainer approval above still applies as normal. If your integration has multiple product variants (Self-Hosted, SaaS, NGTS) with different owners, you can scope reviewers per product instead of listing one for the whole integration — see the schema comment at the top of `.github/owner-reviewers.yml` for that format.

**If you're updating an existing integration**, you don't need to do anything here — the check already knows who to ask. If that check fails with "no reviewer mapping," a maintainer needs to add one; that's not something you can self-service for an integration you didn't create.

## File requirements

Every integration directory must contain:

| File | Required | Notes |
|------|----------|-------|
| `integration_metadata.json` | Yes | See the [schema reference](INTEGRATION_GUIDE.md#integration_metadatajson-schema) in INTEGRATION_GUIDE.md |
| `OVERVIEW-*.md` or `README.md` | Yes | Documentation shown on the marketplace page |
| Logo image (`.png`, `.svg`, `.jpg`, etc.) | No | Recommended: PNG, min 200px wide — falls back to a generic logo if absent |
| Downloadable file(s) (`downloadFiles`) | Optional | e.g. an Adaptable driver `.ps1`; can be scoped per product variant |
| `ReleaseNotes/<version>.md` (or `ReleaseNotes/CHANGELOG.md`) | Yes | Required for a brand-new integration's initial version, and for every subsequent update — see [Writing your first release note](#writing-your-first-release-note) and [Updating an existing integration](#updating-an-existing-integration) |

Each product variant always renders one **primary call-to-action**, inline next to the PRODUCT
selector. By default it's **Download** when the variant ships a downloadable file
(`downloadFiles`) and **View Documentation Tab** when it has documentation — clicking it switches
to the in-page Documentation tab rather than opening a duplicate link. Override it per variant
with `primaryCta` (`{ "type": "download|docs|link|contact-sales|contact-partner", "label": "…", "url": "…" }`).
To ship a download on one variant but not another, set `"downloadFiles": []` on the variant that
should have none. See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for details.

## Metadata requirements

- `name`, `description`, `products`, and `price` are required fields
- Scripts and utilities that support the products, rather than connecting them to another system, set `"listingType": "tool"`. See [Listing type](INTEGRATION_GUIDE.md#listing-type)
- `support` sets the support level: `"Supported"` means Palo Alto Networks or the partner offers support, and the listing shows which. `"Community"` means support is best-effort, from the community, and the listing is not maintained by Palo Alto Networks. See [Support level](INTEGRATION_GUIDE.md#support-level)
- `price` must be `"Free"` or `"Paid"`
- Paid integrations must include an `acquisition` object with `type`, `label`, and `url`
  - `type` is either `"contact-sales"` or `"contact-partner"`
  - See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for the full `acquisition` schema
- A free integration whose *support* is paid separately (e.g. the product is free, but the
  vendor charges for a support plan) sets `supportPrice: "Paid"` plus a `supportAcquisition`
  object — same shape as `acquisition`, independent of `price`, and overridable per
  `productVariants[]` entry. See [Paid support](INTEGRATION_GUIDE.md#paid-support) in the
  Integration Guide.
- If your integration's content is only available in a non-English language, set `language` to
  its ISO 639-1 code (e.g. `"ja"` for Japanese) — this shows a "Language Only" badge. Keep `name`
  non-ASCII if needed, but keep the directory name ASCII. See [the schema reference](INTEGRATION_GUIDE.md#field-reference).
- Marketplace admins can temporarily disable downloads for a variant. If you see a "Downloads temporarily unavailable" notice instead of your download button, that's why.

## Writing your overview

The overview (`OVERVIEW-<suffix>.md`, or `README.md` as a fallback) is the first thing a customer reads on your listing. It should make clear what value the integration provides and why someone would use it. Save setup steps for the Documentation tab.

Focus on customer outcomes rather than feature lists. Answer what problem the integration solves, what customers can achieve with it, and what they gain. For example, write "Eliminate outages with automated certificate renewal" rather than "Supports certificate renewal."

A structure that works well:

1. **Opening narrative** (one or two paragraphs): the problem or opportunity, framed from the customer's point of view.
2. **Solution highlights** (four to six bullets): the most important part. Start each bullet with an action verb (Eliminate, Streamline, Automate, Accelerate, Scale) and keep it to one or two lines. Lead with the benefit, not the implementation: "Gain visibility into certificate inventory across your infrastructure" works; "Uses REST API for communication" and "Compatible with version 2.0+" don't.
3. **Optional sections**, as they apply:
   - **Applicability**: the use cases or customer segments the integration fits.
   - **Solution components**: the products involved (e.g. Certificate Manager Self-Hosted and the target system).
   - **How it works**: a short explanation, linking to the Documentation tab or external docs for detail.
   - **About the vendor**: a sentence or two about the company or technology, with a link.

```markdown
Organizations rely on load balancers to decrypt and inspect HTTPS traffic. As TLS use grows, managing certificates across network infrastructure gets harder. This integration automates certificate lifecycle management so security teams keep control and operations teams avoid outages.

**SOLUTION HIGHLIGHTS**

- **Eliminate outages** with automated certificate renewal
- **Streamline workflows** by removing manual certificate provisioning
- **Enforce policy** on every certificate deployed to the load balancer
- **Gain visibility** into certificate inventory across your infrastructure

**About Example Networks**

Example Networks builds application delivery and security products. Learn more at [example.com](https://example.com).
```

The same customer-value focus applies to the `description` field, which appears on the gallery card. "Automate certificate lifecycle management for F5 BIG-IP load balancers using the REST API" tells a reader what they get; "Integration for F5" doesn't.

## Writing your documentation

Setup and configuration instructions go on the Documentation tab, in a `DOCS-<suffix>.md` file per product or a file named by `documentationFile` (see [Field resolution](INTEGRATION_GUIDE.md#field-resolution)). You can link to external documentation instead with `documentationLinks`, or do both. Suggested headings:

- **Prerequisites**: versions, accounts, permissions, and network access needed.
- **Installation**: numbered steps.
- **Configuration**: each setting, what it does, and its default.
- **Testing**: how to confirm the integration works.
- **Troubleshooting**: common issues and how to resolve them.

If your integration supports more than one product, make each product's documentation reflect how that product works. For example, Next-Gen Trust Security authenticates with OAuth 2.0 client credentials (a service account's client ID and secret) rather than the API key Certificate Manager SaaS uses, and the Application and Team concepts in Certificate Manager SaaS don't apply to Next-Gen Trust Security. Leave steps that don't apply out of that product's file.

### Markdown that breaks rendering

The site renders overviews, documentation, and release notes through MDX. It escapes curly braces, angle brackets, and unknown tags outside code automatically, but some valid-looking HTML still breaks the page:

- HTML comments. Delete them.
- Unclosed tags such as `<br>` or `<img src="...">`. Self-close them (`<br />`) or use markdown instead.
- String `style` attributes such as `style="color: red"`. Remove them.

Wrap code, placeholders, and tag names in backticks or fenced code blocks so they render as you wrote them. Previewing your integration locally (see [Preview locally](#preview-locally)) is the quickest way to catch these.

## Writing your first release note

A brand-new integration needs a release note for its initial version too, not just later updates — add `ReleaseNotes/1_0_0.md` (or `ReleaseNotes/CHANGELOG.md` with a `## Version 1.0.0` section; see [Release Notes](INTEGRATION_GUIDE.md#release-notes) for both formats) in the same PR that adds the integration. `validate-integration.js` errors if it's missing.

There's no mandated format — adapt it to your integration. As a starting point, consider covering:

- **Platform Availability** — the deployment mode this build supports (e.g. SaaS vs. Self-Hosted, or Agent vs. Agentless).
- **Target Device / CA Version Compatibility** — the exact OS, firmware, or API versions of the target device (e.g. ACOS v4.x/v5.x) or CA (e.g. DigiCert REST API v2) validated for this release.
- **Supported Lifecycle Operations** — the specific automated actions available (Discovery, CSR Generation, Provisioning, Renewal, Revocation, Binding).
- **Connection Protocols & Auth** — how it talks to the target machine or CA (REST API, SSH/SCP, WinRM, EST, ACME).
- **Initial Scope Boundaries & Limitations** — call out supported key types/algorithms explicitly (e.g. "RSA up to 4096-bit supported; ECDSA planned for a future release") to prevent misconfiguration.

Two worked examples:

**Target machine integration** (load balancers, web servers, firewalls, etc.):

```markdown
#### Availability
- Initial release for Certificate Manager Self-Hosted.

#### Compatibility
- Validated on target software version(s) ACOS 4.1.4 – 5.2.1.

#### Supported Lifecycle Actions
- Discovery: automated scanning and inventory of active SSL/TLS certificates via aXAPI v3.
- Provisioning & Renewal: automated deployment of new certificates and private keys to Virtual Servers (VIPs) and SNI profiles.
- Binding: zero-downtime certificate re-binding upon renewal.

#### Connection Protocol
- REST API over HTTPS (port 443).

#### Limitations
- Supports RSA keys (2048-bit and 4096-bit). ECDSA certificate provisioning is not supported in this version.
```

**CA / issuer integration** (public CAs, internal PKI, etc.):

```markdown
#### Availability
- Initial release for Certificate Manager SaaS and Self-Hosted.

#### Supported Operations
- Certificate enrollment, automated renewal, and revocation requests.
- Support for single-domain, SAN (multi-domain), and wildcard certificate profiles.
- Automated sync of CA-issued certificate inventory.

#### Authentication
- API key / HMAC authentication.

#### Key & Signature Compatibility
- RSA (2048/4096-bit) and ECDSA (P-256/P-384).
```

A few rules of thumb that make notes more useful to admins scanning quickly:

- Use standard PKI terminology (Provisioning, Renewal, Revocation, Discovery) and keep bullets action-oriented.
- Explicitly state missing features as limitations. If the target machine supports both SSL binding and IPsec certificate deployment but this version only handles SSL binding, say so — don't let the gap surface as a support ticket instead.
- Update the release note when platform targets expand. Adding SaaS alongside an existing Self-Hosted release, for example, should state the new deployment mode and link to the relevant setup documentation.

## Updating an existing integration

When you change an integration that already exists, you **must** tell users what changed:

1. **Bump `currentVersion`** in `integration_metadata.json` using [semantic versioning](https://semver.org/) — MAJOR for breaking changes, MINOR for new features, PATCH for fixes.
2. **Add a release note** at `ReleaseNotes/<version>.md` (dots become underscores, e.g. version `1.2.0` → `ReleaseNotes/1_2_0.md`) describing the change.

If the change affects **only one product** of a multi-product integration, bump only that product variant's `currentVersion` and name the release note with a product suffix — e.g. `ReleaseNotes/1_2_0-selfhosted.md` — so it shows only for that product.

See [Versioning](INTEGRATION_GUIDE.md#versioning) and [Release Notes](INTEGRATION_GUIDE.md#release-notes) in the Integration Guide for the version rules and release-note format.

## Validation

Run validation locally before opening a PR:

```bash
node scripts/validate-integration.js                        # Validate all
node scripts/validate-integration.js Integrations/MyTool   # Validate one
```

The validator prints `[ERROR]` and `[WARN]` lines. Fix every error before opening a pull request, because reviewers won't approve a PR with validation errors. Warnings don't block approval. They flag something a reviewer will look at, such as a tag that isn't on the approved list, so fix them where you can or explain them in the PR description.

## Preview locally

The `preview/` folder runs the same rendering engine as the live marketplace against your local `Integrations/` folder, including uncommitted edits. It needs Node 20 or 22 LTS:

```bash
cd preview
npm install   # one time
npm start     # http://localhost:3000/marketplace
```

Restart `npm start` after editing your integration's files. See [preview/README.md](preview/README.md) for details. Run `npm run validate` here as well, because the preview doesn't check the schema.

## Testing checklist

Before you open a PR, run the validator and check your integration in a local preview:

- [ ] `node scripts/validate-integration.js Integrations/MyIntegration` reports no errors
- [ ] The integration appears in the marketplace gallery with the right category and tags
- [ ] The logo displays correctly in the light theme, and in the dark theme if you set `logoFileDark`
- [ ] The Overview tab renders without errors for every product
- [ ] The Documentation tab shows the right content for every product
- [ ] The product selector switches correctly (multi-product integrations)
- [ ] Downloads, resources, and release notes appear where expected
- [ ] All links work and no images are broken

## Review process

1. Automated CI validates your integration (schema, logo, markdown); external contributors must have accepted the [Contributor Terms](#contributor-terms) before their PR is reviewed
2. The `owner-approval` check auto-requests review from your integration's designated reviewer (see [Reviewer approval required to merge](#reviewer-approval-required-to-merge)); a marketplace maintainer separately reviews and approves every PR
3. After merge, your integration appears on the live marketplace

Reviewers commonly check:

- **Metadata**: the category and tags fit (see [Categories, tags, and keywords](INTEGRATION_GUIDE.md#categories-tags-and-keywords)), the description is clear, and versions follow semantic versioning.
- **Logo**: good quality, transparent background, readable at small sizes.
- **Documentation**: the overview focuses on customer value, prerequisites are complete, configuration steps are clear, and troubleshooting is covered.
- **Rendering**: every tab renders, links work, and there are no MDX errors.

Address feedback by pushing more commits to the same branch; the PR updates automatically.

## After your integration is merged

- **Support your users.** Users may reach you through your `supportUrl` or `supportEmail`, or through GitHub issues. Aim to respond within one or two business days, and update your documentation when the same question keeps coming up.
- **Ship updates.** Fix bugs and keep up with product API changes. Follow [Updating an existing integration](#updating-an-existing-integration) for each change.
- **Retire it cleanly.** If you can no longer support the integration, open an issue or PR saying so, and point users to an alternative if one exists. Unsupported integrations are moved to `Archive/`, which removes them from the marketplace while keeping their history; see [Archive/README.md](Archive/README.md).

## Code of conduct

Be respectful. We follow the [Contributor Covenant](https://www.contributor-covenant.org/).

## Questions?

Open an issue.
