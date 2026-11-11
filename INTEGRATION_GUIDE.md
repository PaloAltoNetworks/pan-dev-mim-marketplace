# Integration Guide

This document is the reference for creating and maintaining integrations in the MIM Marketplace.

## Directory naming

Use PascalCase for directory names.

- **Integrations**: match the official name of the product the integration connects to, with spaces removed. Examples: `HashiCorpVault`, `AWSCertificateManager`, `FortinetFortiGate`
- **Tools & Utilities**: describe what the tool does, starting with a verb where it reads naturally. Examples: `WriteVenafiDebug`, `GetTppActiveHistoricalCertificate`, `AutoApproveByCaTemplate`

## integration_metadata.json schema

```json
{
  "name": "Human-readable integration name",
  "description": "One or two sentences. What does this integration do? What value does it deliver?",
  "support": "Supported | Community",
  "currentVersion": "1.0.0",
  "author": "Your Name or Company",
  "supportEmail": "support@yourdomain.com",
  "price": "Free",
  "categories": ["Certificate Management"],
  "products": ["Certificate Manager Self-Hosted"],
  "tags": ["TLS", "PKI", "Automation"],
  "useCases": ["Certificate Lifecycle Management"],
  "supportUrl": "https://github.com/example/my-integration/issues"
}
```

### Field reference

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | Yes | string | Display name shown on the marketplace |
| `description` | Yes | string | Short description (1–2 sentences) |
| `support` | No | string | `Supported` or `Community`. Sets the listing's support level. See [Support level](#support-level) |
| `currentVersion` | No | string | Semver version string |
| `releaseDate` | No | string | ISO date (`YYYY-MM-DD`). Overrides the date the marketplace otherwise derives from this folder's last commit — set it only when the two should differ |
| `author` | No | string | Author or company name |
| `supportEmail` | No | string | Support email. Only one of `supportUrl`/`supportEmail` is ever shown — set the one that applies; if both are set at the same level, `supportUrl` wins |
| `price` | Yes | string | `Free` or `Paid` |
| `categories` | Yes | string[] | Exactly one value from `Config/approved_categories.json`. See [Categories, tags, and keywords](#categories-tags-and-keywords) |
| `listingType` | No | string | `"tool"` for a script or utility that supports the products without connecting them to another system. Omit for an integration. See [Listing type](#listing-type). Root-level only |
| `products` | Yes | string[] | Venafi product(s) this integration supports. Must be from `Config/approved_products.json` |
| `tags` | No | string[] | Should be from `Config/approved_tags.json`. Other values pass validation with a warning. See [Categories, tags, and keywords](#categories-tags-and-keywords) |
| `useCases` | No | string[] | Use case labels |
| `supportUrl` | No | string | Link to issue tracker or support portal |
| `keywords` | No | string[] | Extra search terms not shown as facets (unlike `tags`/`useCases`), useful for search-only synonyms |
| `logoFile` | No | string | Filename of the logo image in this folder (e.g. `logo.png`). Falls back to a generic marketplace logo if omitted |
| `logoFileDark` | No | string | Filename of a dark-mode logo variant. Falls back to `logoFile` if omitted |
| `documentationFile` | No | string | Filename of a longer-form Documentation-tab markdown file. A `DOCS-<suffix>.md` file is picked up without it, but a plain `DOCUMENTATION.md` is only used when this field names it |
| `documentationLinks` | No | object[] | List of `{title, description?, url}` external doc links shown on the Documentation tab |
| `resources` | No | object | Optional videos and other resources (PDFs, external links) shown on the listing. See [Resources](#resources) below |
| `license` | No | string | Name of the license covering any `downloadFiles` in this folder, shown as the "License" row in the listing's Info sidebar, e.g. `"MIT"` or `"Software Tool License Agreement"`. See [License](#license). Root-level only |
| `licenseUrl` | Conditional | string | Absolute `https` URL of the license terms; the License row links here. Required for any `license` other than `"MIT"`, which links to the repo's root `LICENSE` file when `licenseUrl` is unset. Root-level only |
| `acquisition` | Conditional | object | **Required** when `price` is `"Paid"`. See [Paid Integrations](#paid-integrations) below |
| `supportPrice` | No | string | `Free` or `Paid`. Defaults to `Free`. Independent of `price` — a free product can still have paid support. See [Paid support](#paid-support) below |
| `supportAcquisition` | Conditional | object | **Required** when `supportPrice` is `"Paid"`. Same shape as `acquisition`. See [Paid support](#paid-support) below |
| `productVariants` | No | object[] | Per-product overrides. See [Product variants](#product-variants) |
| `language` | No | string | ISO 639-1 code (e.g. `"ja"`) for an integration whose content is only in a non-English language. Omit for English. Shows a "`<Language>` Language Only" badge on the gallery card and detail page title — a short-term measure, not full localization. If `name` is non-ASCII, the directory name is still used for the page URL, so it must stay ASCII |

### Categories, tags, and keywords

These three fields look similar but do different jobs:

- **`categories`** answers "what kind of system does this connect to?" Set exactly one value from the closed list below. It drives the Categories filter on the marketplace and is the highest-weighted signal in "Recommended Integrations", so a wrong value hurts discovery more than a missing one. `validate-integration.js` errors on a missing, multiple, or unrecognized category.
- **`tags`** are secondary facets: a technology, protocol, or delivery model that cuts across categories (`Cloud`, `Kubernetes`, `Adaptable Framework`, `Open Source`). Every distinct tag becomes a row in the Tags filter, so only use one that more than one listing could plausibly carry. A tag that isn't in `Config/approved_tags.json` doesn't fail validation, but the validator prints a `[WARN]` line for it and the marketplace shows it as a new Tags filter option. Use an approved tag where one fits. To propose a new one, add it to `Config/approved_tags.json` in the same PR and say why in the PR description.
- **`keywords`** are free-text search terms: vendor names, product names, model numbers, and anything too specific to be a facet (`ONTAP`, `PKCS#11`, `nShield`). They're searchable but never shown as a filter. When in doubt between a tag and a keyword, use a keyword.

| Category | Use it for |
|----------|------------|
| `API Gateway & WAF` | API gateways, web application firewalls |
| `CI/CD & DevOps` | Pipelines, config management, IaC tooling |
| `Certificate Authority` | Public and private CAs, PKI services |
| `Data Platform & Storage` | Databases, warehouses, storage, streaming |
| `Discovery & Asset Management` | Scanners, inventory, attack-surface tools |
| `Endpoint & Device Management` | MDM, endpoint agents, printers, workstations |
| `Firewall & Network Security` | Firewalls, NGFW, TLS inspection, network gear |
| `HSM & Key Management` | HSMs, KMS, key stores |
| `ITSM & Workflow` | Ticketing, SOAR, notifications, RPA |
| `Installation & Operations` | Installing, upgrading, troubleshooting and operating the products themselves |
| `Identity & Access Management` | Directories, SSO, MFA, authentication |
| `IoT & OT` | IoT platforms, PLCs, industrial systems |
| `Kubernetes & Containers` | Clusters, ingress controllers, admission control |
| `Load Balancer & ADC` | Load balancers, ADCs, CDN and edge delivery |
| `SIEM & Observability` | SIEM, logging, analytics, monitoring |
| `Secrets Management` | Vaults, secret stores, credential providers |
| `Web Server` | Apache, IIS, NGINX, Oracle HTTP Server |

If your integration seems to fit two categories, choose the system it actually talks to. A Kubernetes ingress controller is `Kubernetes & Containers`, not `Load Balancer & ADC`. A code-signing integration is categorized by where it runs (CI/CD, HSM, IoT), with `Code Signing` as its use case.

**`useCases`** describes the machine-identity workflow the integration takes part in, not the kind of system it connects to. The approved values are `Certificate Lifecycle Management`, `Code Signing`, and `SSH Key Management`. Discovery tooling is found through the `Discovery & Asset Management` category and the `Discovery` tag, not a use case. A use case that isn't in `Config/approved_usecases.json` doesn't fail validation, but the validator prints a `[WARN]` line for it and the marketplace shows it as a new Use Cases filter option. To propose a new one, add it to `Config/approved_usecases.json` in the same PR and say why in the PR description.

The approved lists live in `Config/approved_categories.json`, `Config/approved_tags.json`, and `Config/approved_usecases.json`. To add a value, open a PR against the relevant file; a CODEOWNER must approve. A new category should be able to hold at least about four listings; otherwise it belongs as a tag.

### Listing type

The marketplace lists two kinds of entries. An **integration** connects a Palo Alto Networks machine identity product to another system, such as a CA, load balancer, or ITSM tool. A **tool** is a script or utility that helps you run the products themselves, such as a prerequisites checker, a reporting script, or a debug helper. Tools are often built by Palo Alto Networks Professional Services or product teams.

Set `"listingType": "tool"` at the root level for a tool. Leave it out for an integration. The only accepted values are in `Config/approved_listing_types.json`.

```json
"listingType": "tool"
```

On the marketplace, tools carry a "Tools & Utilities" badge and have their own Type filter. A tool still needs exactly one category that describes what it works with, for example `Installation & Operations` for a prerequisites checker or `Discovery & Asset Management` for an inventory export script. Everything else about a tool listing, including downloads, release notes, and [License](#license), works the same as for an integration.

### Support level

`support` sets the listing's support level, which the marketplace shows on the card badge and as the Support Level filter.

| Value | Meaning |
| --- | --- |
| `Supported` | Support is offered by Palo Alto Networks or by the partner. The listing shows which, through its author and its `supportUrl` or `supportEmail`. |
| `Community` | Support is best-effort, from the community. Not maintained by Palo Alto Networks. |

The validator rejects any other value.

### Paid integrations

Set `price: "Paid"` and add an `acquisition` object:

```json
{
  "name": "My Commercial Product",
  "price": "Paid",
  "acquisition": {
    "type": "contact-partner",
    "label": "Contact Partner",
    "url": "https://example.com/contact-sales",
    "description": "Reach out to the partner team for licensing."
  },
  ...
}
```

#### `acquisition` object reference

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `type` | Yes | string | `"contact-sales"` or `"contact-partner"` |
| `label` | Yes | string | CTA button text shown on the marketplace |
| `url` | Yes | string | Link target for the CTA button |
| `description` | No | string | Additional context shown near the CTA |

#### Acquisition types

- **`contact-partner`** — The CTA links to a partner's own contact or sales page. Use this when a third-party partner owns the commercial relationship.
- **`contact-sales`** — The CTA reads "Contact Your Account Team". Use this for paid integrations that require purchase through a Palo Alto Networks account team.

Example with `contact-sales`:

```json
{
  "name": "Enterprise Certificate Connector",
  "price": "Paid",
  "acquisition": {
    "type": "contact-sales",
    "label": "Contact Your Account Team",
    "url": "https://marketplace.example.com/contact",
    "description": "Available for enterprise customers with an active subscription."
  },
  ...
}
```

The marketplace renders the `label` as a button linking to `url`. The optional `description` appears as helper text near the CTA.

### Paid support

Some integrations are free but the vendor charges for support. Set `supportPrice: "Paid"` and add
a `supportAcquisition` object — same shape as `acquisition`, but scoped to "how to buy support"
rather than "how to buy the product":

```json
{
  "name": "My Free Product",
  "price": "Free",
  "supportPrice": "Paid",
  "supportAcquisition": {
    "type": "contact-partner",
    "label": "Contact Partner for Support",
    "url": "https://example.com/support-plans",
    "description": "The product is free; paid support plans are available directly from the vendor."
  },
  ...
}
```

`supportPrice`/`supportAcquisition` are independent of `price`/`acquisition` and can be set
regardless of whether the product itself is free or paid, and independently overridden per
`productVariants[]` entry (e.g. paid support on Self-Hosted, included support on SaaS).

## Products

`products` is a closed vocabulary defined by `Config/approved_products.json`.
`validate-integration.js` errors on anything else, so these are the only accepted values:

- `"Certificate Manager Self-Hosted"` — Certificate Manager (on-prem/TPP)
- `"Certificate Manager SaaS"` — Certificate Manager (cloud)
- `"Next-Gen Trust Security"` — Next-Gen Trust Security
- `"Zero Touch PKI"` — Zero Touch PKI

To propose a new product, open a PR against `Config/approved_products.json`; a CODEOWNER
must approve it, and it also requires a matching change in the site repo: add the product to
pan-dev-mim's `docs/config/marketplace-products.json`, which sets its name, its `?product=`
suffix, and its display order.

### Product variants

An integration supporting more than one product can override per-product content with
`productVariants[]`. Each entry names its `product` — which must also appear in the root
`products` array — and typically points at that product's `overviewFile`:

```json
"productVariants": [
  { "product": "Certificate Manager SaaS", "overviewFile": "OVERVIEW-saas.md" },
  { "product": "Next-Gen Trust Security", "overviewFile": "OVERVIEW-ngts.md" }
]
```

The order of `productVariants[]` doesn't set the default variant. A listing opens on the highest-priority product it supports, in this order: Next-Gen Trust Security, Certificate Manager Self-Hosted, Certificate Manager SaaS, Zero Touch PKI. The PRODUCT dropdown and the gallery card's product pills use the same order.

A variant may also override `description`, `currentVersion`, `support`, `author`, `supportUrl`,
`supportEmail`, `price`, `supportPrice`, `supportAcquisition`, `documentationFile`, `documentationLinks`,
`resources`, `downloadFiles`, and `primaryCta`. Anything it does not set falls back to the top level — except `documentationLinks`,
which is variant-only and never inherited (a shared link would otherwise show under every
product tab), and `resources`, which is additive (see [Field resolution](#field-resolution)).

`supportUrl`/`supportEmail` fall back as a single unit, not field-by-field: a variant that sets
*either* one fully overrides the root's support contact (both of the root's fields are ignored
for that variant). A product can only have one company behind it, so set whichever of
`supportUrl`/`supportEmail` applies to that variant's support owner — never both.

#### Field resolution

For each product tab, the site resolves a field in this order:

1. The value on that product's `productVariants[]` entry.
2. The root-level value, shared by every product.
3. A site default, when neither is set.

| Field | Site default when unset |
|-------|-------------------------|
| `support` | `Unknown` |
| `author` | `Unknown` |
| `currentVersion` | `1.0.0` (the validator also warns when it's missing) |
| `price` | `Free` |
| `supportPrice` | `Free` |

Exceptions to the simple chain:

- `supportUrl` and `supportEmail` resolve as one unit, as described above.
- `documentationLinks` is read only from a `productVariants[]` entry. It has no root fallback, and a root-level value is not shown.
- `resources` is merged rather than overridden: root-level resources appear under every product tab, followed by that variant's own.
- `downloadFiles` set to `[]` on a variant stops the fallback, so that variant has no download.
- `license` and `licenseUrl` are root-level only. Values on a variant are ignored, and the validator warns.

The overview and Documentation-tab files resolve by filename first:

- **Overview**: `OVERVIEW-<suffix>.md`, then the variant's `overviewFile`, then `README.md`. If none exists, the tab shows "No overview documentation provided for this product."
- **Documentation**: `DOCS-<suffix>.md`, then the variant's `documentationFile`. For a listing without `productVariants`, the root `documentationFile` counts as the variant's. A `DOCUMENTATION.md` is used only when a `documentationFile` names it.

In this example, the SaaS tab shows version `2.0.0` and the Self-Hosted tab inherits `1.0.0` and `Supported` from the root:

```json
{
  "products": ["Certificate Manager SaaS", "Certificate Manager Self-Hosted"],
  "support": "Supported",
  "currentVersion": "1.0.0",
  "productVariants": [
    { "product": "Certificate Manager SaaS", "currentVersion": "2.0.0" },
    { "product": "Certificate Manager Self-Hosted" }
  ]
}
```

Put values that apply to every product at the root and only the differences on each variant. [`Integrations/.template/integration_metadata.json`](Integrations/.template/integration_metadata.json) is a complete multi-product example.

#### Documentation (`documentationFile` and `documentationLinks`)

A variant's Documentation tab can point at a local markdown file, a list of external links, or
both:

```json
{
  "product": "Certificate Manager SaaS",
  "documentationFile": "DOCS-saas.md",
  "documentationLinks": [
    { "title": "Add as a CA", "description": "Optional helper text", "url": "https://docs.example.com/saas/add-ca" }
  ]
}
```

`documentationFile` is also auto-detected: a `DOCS-<suffix>.md` file in the folder is picked up
automatically even if you don't set the field. A plain `DOCUMENTATION.md` is not; name it in
`documentationFile` on each variant it documents. `documentationLinks` is the
way to list external doc links.

#### Downloads (`downloadFiles`) per variant

`downloadFiles` lists downloadable assets (scripts, installers, connectors, etc. — e.g. an
Adaptable driver `.ps1`) shipped in the folder. For a single-product integration with no
`productVariants`, declare it at the top level. Once `productVariants` exists, declare it on
each variant that has one instead — a root-level `downloadFiles` alongside `productVariants` is
an error, since it would otherwise silently bleed onto every variant. To offer a download on one
variant but **not** another, set an explicit empty array on the variant that should have none:

```json
"productVariants": [
  { "product": "Certificate Manager Self-Hosted", "overviewFile": "OVERVIEW-selfhosted.md", "downloadFiles": ["MyDriver.ps1"] },
  { "product": "Certificate Manager SaaS", "overviewFile": "OVERVIEW-saas.md", "downloadFiles": [] }
]
```

Every filename listed must exist in the folder (the validator errors otherwise); `[]` is valid.

Any integration with a non-empty `downloadFiles` should also set the root-level `license` field.
The validator warns if it's missing. See [License](#license) for which license applies.

### License

Each listing shows its applicable license terms in a "License" row in the Info sidebar, driven by
the root-level `license` (display name) and `licenseUrl` (link) fields:

| Who developed the downloads | `license` | `licenseUrl` |
|---|---|---|
| Partner | `"MIT"`, or the partner's own license name | Omit for MIT (links to this repo's [`LICENSE`](LICENSE)); otherwise the partner license URL |
| Palo Alto Networks, including Professional Services | `"Software Tool License Agreement"` | `https://www.paloaltonetworks.com/content/dam/pan/en_US/assets/pdf/legal/software-tool-license-agreement.pdf` |
| Community | `"Marketplace Terms of Use"` | `https://www.paloaltonetworks.com/content/dam/pan/en_US/assets/pdf/legal/panw-marketplace-terms-of-use-for-cortex-and-mim.pdf` |

```json
"license": "Software Tool License Agreement",
"licenseUrl": "https://www.paloaltonetworks.com/content/dam/pan/en_US/assets/pdf/legal/software-tool-license-agreement.pdf"
```

Both fields are root-level only; a single license covers all of an integration's downloads. The
validator errors when `licenseUrl` isn't an `https` URL, when `licenseUrl` is set without `license`,
and when a `license` other than `"MIT"` has no `licenseUrl`.

Marketplace admins can temporarily disable downloads for a specific variant. A disabled variant shows a notice to contact the account team instead of its download buttons.

#### Primary call-to-action (`primaryCta`)

Every variant always renders one **primary call-to-action**, shown inline next to the PRODUCT
selector. You normally don't set it — it is inferred: **Download** when the variant resolves to
a non-empty `downloadFiles`, otherwise **View Documentation Tab** when a Documentation tab resolves
for that variant (a local `documentationFile`/`DOCS-<suffix>.md`/`DOCUMENTATION.md`, or a
`documentationLinks` entry). Paid integrations (`acquisition`)
render their contact CTA. Variants with none of the above show a plain "No additional resources
available" note rather than an empty gap. Override any of this with `primaryCta`:

```json
"primaryCta": { "type": "download|docs|link|contact-sales|contact-partner", "label": "Get the driver", "url": "https://…" }
```

- `type` is required and must be one of the values above. `type: "link"` requires a `url`.
- `label` overrides the default button text (download → "Download", docs → "View Documentation
  Tab", contact-sales → "Contact Your Account Team", contact-partner → "Contact Partner").
- `type: "docs"` never opens `url` — clicking it switches the page to the in-page
  "Documentation" tab instead of duplicating a link that's already shown there. Any `url` you set
  on a `docs` CTA is ignored. It only ever appears when this variant actually has a Documentation
  tab to switch to.
- For `download` the `url` is derived automatically; supply `url` only for `link` (a custom
  external target) or `contact-partner`/`contact-sales`.

## Resources

The optional top-level `resources` object lists videos and other resources (PDFs, whitepapers,
external links) shown on the listing. It can also be set per-variant (see [Product
variants](#product-variants)), in which case it's shown in addition to the top-level `resources`
for that product only.

```json
"resources": {
  "videos": [
    { "title": "Integration Overview", "description": "Optional", "url": "https://www.youtube.com/watch?v=...", "platform": "youtube" }
  ],
  "otherResources": [
    { "title": "Partner Brief", "description": "Optional", "url": "MyIntegration-PartnerBrief.pdf", "type": "pdf", "resourceType": "file" },
    { "title": "Community Forum", "description": "Optional", "url": "https://community.example.com", "category": "Community", "resourceType": "link" }
  ]
}
```

- `videos[]` — `title` and `url` required; `description` and `platform` (`"youtube"`, `"vimeo"`,
  or `"custom"`) optional. `url` can be a YouTube/Vimeo link or a direct video URL.
- `otherResources[]` — a discriminated union on `resourceType`:
  - `resourceType: "file"` — a local file (PDF, doc) shipped in the integration folder, or an
    external URL. Fields: `title`, `url`, `type` (`"pdf"`, `"whitepaper"`, `"doc"`, or `"other"`),
    optional `description`, `fileSize`, `date`.
  - `resourceType: "link"` — an external link. Fields: `title`, `url`, optional `description` and
    `category` (e.g. `"Documentation"`, `"Training"`, `"Community"`).

Typical uses for each type:

- **Videos**: demos, setup tutorials, and overview walkthroughs.
- **Files**: solution guides, partner briefs, and deployment or best-practice PDFs. Put a local file in the integration folder and set `url` to its filename; the site copies it and rewrites the link.
- **Links**: product websites, support portals, and community forums.

Older listings may use `resources.solutionGuides[]` and `resources.externalLinks[]`. The site still renders them, as `otherResources` entries with `resourceType` `"file"` and `"link"` respectively, but they're deprecated. Use `otherResources` for new work.

## Logos

- Preferred format: PNG or SVG
- Minimum width: 200px
- Maximum file size: 500KB (optimize with tools like [Squoosh](https://squoosh.app/) if larger)
- Name it `logo.png`, `logo.svg`, or use the product name (e.g., `MyProduct.png`)
- Set `logoFile` to the filename. The site only uses the file `logoFile` names; without it the listing shows the generic marketplace logo, even if a logo image is in the folder.
- Use a transparent background, and check that the logo is still readable at small sizes.

The site normalizes every logo so the gallery looks consistent. It trims the empty border, scales the image to fit within 160x92px while keeping its aspect ratio, applies light sharpening, adds 8px of transparent padding on every side, and outputs a PNG. You don't need to pre-size your logo, but tight cropping and a transparent background give the best result.

**Dark mode (optional).** If your logo is hard to read on a dark background, add a dark-mode variant (e.g. `logo-dark.png`) and set `logoFileDark` to its filename. It's normalized the same way and shown when the visitor uses the dark theme. The filename alone does nothing; without `logoFileDark` the light logo is used in both themes.

## Documentation files

| File name pattern | Purpose |
|-------------------|---------|
| `OVERVIEW-selfhosted.md` | Overview for self-hosted (on-prem) users |
| `OVERVIEW-saas.md` | Overview for SaaS users |
| `OVERVIEW-ngts.md` | Overview for Next-Gen Trust Security users |
| `OVERVIEW-ztpki.md` | Overview for Zero Touch PKI users |
| `README.md` | Fallback if no OVERVIEW-*.md files exist |
| `DOCS-<suffix>.md` | Documentation-tab content for one product (same suffixes as `OVERVIEW-<suffix>.md`) |
| `DOCUMENTATION.md` | Documentation-tab content, used only when a `documentationFile` names it |

See [Field resolution](#field-resolution) for how the site picks a file for each product tab. The site drops the first line of each overview and documentation file when it's a heading, because the listing already shows the integration name as the page title.

At least one documentation file is required. It should include:
- What the integration does
- Prerequisites
- Installation steps
- Configuration
- Example usage

For suggested structure and writing guidance, see [Writing your overview](CONTRIBUTING.md#writing-your-overview) and [Writing your documentation](CONTRIBUTING.md#writing-your-documentation) in `CONTRIBUTING.md`.

## Versioning

The `currentVersion` field is a [semantic version](https://semver.org/) string
(`MAJOR.MINOR.PATCH`, e.g. `"1.2.0"`) that identifies the current release of your integration.

Bump it whenever you make a functional change:

| Change | Bump | Example |
|--------|------|---------|
| Breaking change (incompatible config, removed feature) | **MAJOR** | `1.4.0` → `2.0.0` |
| New feature, backward compatible | **MINOR** | `1.4.0` → `1.5.0` |
| Bug fix or minor correction | **PATCH** | `1.4.0` → `1.4.1` |

For multi-product integrations, `currentVersion` can live at the top level or in a specific
`productVariants[]` entry (variant → top level resolution). If a change affects only one product,
bump only that variant's `currentVersion` — leave the other variants untouched.

**Any functional update to an existing integration must bump `currentVersion` and add a matching
[release note](#release-notes). A brand-new integration must also ship a release note for its
initial version** — see [Writing your first release note](CONTRIBUTING.md#writing-your-first-release-note)
in `CONTRIBUTING.md` for guidance on what to cover. `validate-integration.js` errors if any
declared version — initial or updated — has no matching release note.

## Release Notes

Release notes tell users what changed between versions. They live in a `ReleaseNotes/` directory
inside your integration, in one of two formats — pick whichever fits how you maintain your
integration:

- **One file per version** (the default, shown below): `ReleaseNotes/<version>.md`.
- **A single running changelog**: `ReleaseNotes/CHANGELOG.md`, with a `## Version X.Y.Z` heading
  per entry — see [Combined changelog format](#combined-changelog-format) below. Don't mix both
  formats for the same product; `validate-integration.js` errors if it finds both.

### One file per version

```text
Integrations/MyIntegration/
├── integration_metadata.json
├── README.md
├── logo.png
└── ReleaseNotes/
    ├── 1_0_0.md
    ├── 1_1_0.md
    └── 1_2_0.md
```

### File naming

- **Format:** `<version_with_underscores>.md` — dots become underscores.
- **Example:** `1_2_0.md` is displayed as **"Version 1.2.0"**.
- Files are sorted automatically, newest first.

### Content format

The `### Version X.Y.Z` heading is generated automatically from the filename — **do not repeat
the version number inside the file**. Write only the changes, grouped under these `####`
subheadings (include only the ones that apply):

```markdown
#### Added
- New support for Certificate Manager SaaS.

#### Changed
- Updated the default connection timeout to 30s.

#### Fixed
- Corrected certificate chain ordering on renewal.

#### Breaking Changes
- Renamed the `apiKey` config field to `apiToken`.
```

Do not add `<~PLATFORM>` wrappers or your own version/product headings.

### Product-specific release notes

By default a release-note file is **shared** — it shows for every product the integration
supports. If a change affects only one product, add a product suffix to the file name so the note
appears only under that product (the same `saas` / `selfhosted` / `ngts` suffixes used for
`OVERVIEW-<suffix>.md`):

```text
ReleaseNotes/
├── 1_0_0.md              # shared — shown for all products
├── 1_1_0-selfhosted.md   # shown only for Certificate Manager Self-Hosted
└── 1_2_0-saas.md         # shown only for Certificate Manager SaaS
```

| Suffix | Product |
|--------|----------|
| `saas` | Certificate Manager SaaS |
| `selfhosted` | Certificate Manager Self-Hosted |
| `ngts` | Next-Gen Trust Security |

For each product, its shared notes and its own product-specific notes are **merged and shown
newest-first**. So in the example above, the Self-Hosted tab shows Versions 1.1.0 and 1.0.0, while
the SaaS tab shows Versions 1.2.0 and 1.0.0.

### Combined changelog format

Instead of one file per version, you can maintain a single running file with a `## Version
X.Y.Z` heading per entry:

```text
ReleaseNotes/
└── CHANGELOG.md
```

```markdown
## Version 1.2.0

#### Added
- New support for Certificate Manager SaaS.

## Version 1.1.0

#### Fixed
- Corrected certificate chain ordering on renewal.

## Version 1.0.0

Initial release.
```

Entries are sorted newest-first by version regardless of their order in the file. The same
product-suffix convention applies: `CHANGELOG-selfhosted.md` / `CHANGELOG-saas.md` for a
product-specific track, alongside a shared `CHANGELOG.md`. Pick one format per
integration/product — `validate-integration.js` errors if it finds both a `CHANGELOG[-<suffix>].md`
and individual per-version files for the same product.

## Optional assets

- `scripts/` — PowerShell or other automation scripts
- `docs/` — Additional documentation assets (PDFs, etc.)
- `screenshots/` — Screenshots for the marketplace listing

## Validation

Before submitting a PR, always run:

```bash
npm ci
node scripts/validate-integration.js Integrations/MyIntegration
```

The validator prints `[ERROR]` and `[WARN]` lines. Fix every error before opening a pull request, because reviewers won't approve a PR with validation errors. Warnings don't block approval. They flag something a reviewer will look at, such as a tag that isn't on the approved list, so fix them where you can or explain them in the PR description.
