#!/usr/bin/env node
/**
 * validate-integration.js
 *
 * Validates integration directories in the MIM Marketplace.
 * Run against a specific directory or all Integrations/ directories.
 *
 * Usage:
 *   node scripts/validate-integration.js                        # Validate all
 *   node scripts/validate-integration.js Integrations/MyTool   # Validate one
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const INTEGRATIONS_DIR = path.join(ROOT, 'Integrations');
const CONFIG_DIR = path.join(ROOT, 'Config');

// Load approved lists
function loadApproved(file) {
  const p = path.join(CONFIG_DIR, file);
  if (!fs.existsSync(p)) return null;
  try {
    const data = JSON.parse(fs.readFileSync(p, 'utf8'));
    // Handle both array format and object-with-array format.
    if (Array.isArray(data)) return new Set(data);
    // Prefer an explicit "approved_list"; otherwise use the first array-valued key.
    const container =
      data.approved_list !== undefined
        ? data.approved_list
        : data[Object.keys(data).find((k) => Array.isArray(data[k]) || (data[k] && typeof data[k] === 'object'))];
    if (Array.isArray(container)) return new Set(container);
    if (container && typeof container === 'object') {
      // Nested groups of arrays (e.g. {common:[...], cloud:[...]}) rather than a flat list.
      return new Set(Object.values(container).flat());
    }
    return new Set();
  } catch {
    return null;
  }
}

const approvedCategories = loadApproved('approved_categories.json');
const approvedTags = loadApproved('approved_tags.json');
const approvedUseCases = loadApproved('approved_usecases.json');
const approvedProducts = loadApproved('approved_products.json');
const approvedListingTypes = loadApproved('approved_listing_types.json');

const REQUIRED_FIELDS = ['name', 'description', 'products', 'price'];
const VALID_PRICES = ['Free', 'Paid', 'Paid (Contact Partner)', 'Paid (Contact Sales)'];
// Support level, shown as the card badge and the gallery's Support Level filter.
const VALID_SUPPORT = ['Supported', 'Community'];
const VALID_SUPPORT_PRICES = ['Free', 'Paid'];
const LOGO_EXTENSIONS = ['.png', '.svg', '.jpg', '.jpeg', '.webp'];
const OVERVIEW_PATTERNS = [/^OVERVIEW.*\.md$/i, /^README\.md$/i];
// Semver (MAJOR.MINOR.PATCH), also accepting the legacy MAJOR.MINOR form (e.g. "1.0").
const VERSION_PATTERN = /^\d+\.\d+(\.\d+)?$/;
// Release-note filenames: <version_with_underscores>[-<product_suffix>].md
// e.g. 1_0_0.md (shared) or 1_1_0-selfhosted.md (product-specific).
const RELEASE_NOTE_PATTERN = /^\d+_\d+(_\d+)?(-[a-z0-9]+)?\.md$/;
// Alternative release-notes format: one running file with "## Version X.Y.Z" sections inside,
// instead of one file per version. Same optional product-suffix convention as above.
const CHANGELOG_PATTERN = /^CHANGELOG(-[a-z0-9]+)?\.md$/i;
const CHANGELOG_VERSION_HEADING = /^##\s*Version\s+(\d+\.\d+(?:\.\d+)?)/gim;
// Optional releaseDate: an ISO calendar date, optionally with a time component.
const RELEASE_DATE_PATTERN = /^\d{4}-\d{2}-\d{2}([T ].*)?$/;

let errors = [];
let warnings = [];
let totalChecked = 0;

function error(dir, msg) {
  errors.push(`[ERROR] ${path.basename(dir)}: ${msg}`);
}

function warn(dir, msg) {
  warnings.push(`[WARN]  ${path.basename(dir)}: ${msg}`);
}

// Accept the pre-rename vocabulary. `platforms` was renamed to `products`, and
// `platformVariants[].platform` to `productVariants[].product`. The site generator
// (pan-dev-mim docs/generate-gallery.js, normalizeMetadata) accepts both indefinitely for the
// same reason: an in-flight PR, a fork, or a revert can reintroduce the old shape at any time.
// Warn rather than error so a contributor branch opened before the rename still validates.
//
// NOTE: resources.videos[].platform is a different field ("youtube"/"vimeo") and is untouched.
function acceptLegacyVocabulary(dir, meta) {
  if (meta.products === undefined && meta.platforms !== undefined) {
    meta.products = meta.platforms;
    warn(dir, '"platforms" has been renamed to "products" — please rename the field (still accepted)');
  }
  if (meta.productVariants === undefined && meta.platformVariants !== undefined) {
    meta.productVariants = meta.platformVariants;
    warn(dir, '"platformVariants" has been renamed to "productVariants" — please rename the field');
  }
  if (Array.isArray(meta.productVariants)) {
    meta.productVariants = meta.productVariants.map((v) =>
      v && v.product === undefined && v.platform !== undefined ? { ...v, product: v.platform } : v);
  }
  return meta;
}

// Resolve a field from the top level. The `defaults` block this used to also check has been
// retired — docs/generate-gallery.js (the site generator) no longer reads it, and every
// integration now keeps shared values like price/support at the top level instead.
function resolveField(meta, field) {
  const v = meta[field];
  return v !== undefined && v !== null && v !== '' ? v : undefined;
}

// `defaults` is a retired schema tier (see resolveField above) — warn rather than error, since
// a stray `defaults` block is harmless (just silently unread), and an in-flight PR opened before
// the retirement shouldn't suddenly fail validation.
// The site generator resolves each field as productVariants entry, then root, then its own
// default, and never reads a `defaults` object, so anything in one is silently dropped.
function rejectDefaultsBlock(dir, meta) {
  if (meta.defaults === undefined) return;
  const keys = meta.defaults && typeof meta.defaults === 'object' ? Object.keys(meta.defaults) : [];
  const moved = keys.length ? ` (${keys.join(', ')})` : '';
  error(dir, `"defaults" is not supported and the site ignores it — move its fields${moved} to the root level (shared by all products) or into a productVariants entry`);
}

// Validates a supportPrice/supportAcquisition pair — the "who pays for support" analog of
// price/acquisition, kept orthogonal to it (a free product can still have paid support). No
// legacy field predates this, so there's no "starts with Free" shorthand or deprecated-string
// fallback like partnerContactUrl to replicate.
function validateSupportPricing(dir, label, supportPrice, supportAcquisition) {
  if (supportPrice !== undefined && !VALID_SUPPORT_PRICES.includes(supportPrice)) {
    error(dir, `${label}supportPrice "${supportPrice}" is invalid — accepted values: ${VALID_SUPPORT_PRICES.join(', ')}`);
  }

  if (supportPrice === 'Paid') {
    if (!supportAcquisition) {
      warn(dir, `${label}supportPrice is "Paid" but no "supportAcquisition" object is set — add one to specify how users obtain paid support`);
    } else {
      if (!supportAcquisition.type) {
        error(dir, `${label}supportAcquisition.type is required (e.g. "contact-sales", "contact-partner")`);
      }
      if (supportAcquisition.type === 'contact-partner' && !supportAcquisition.url) {
        error(dir, `${label}supportAcquisition.type is "contact-partner" but supportAcquisition.url is missing`);
      }
      if (supportAcquisition.url) {
        try {
          new URL(supportAcquisition.url);
        } catch {
          error(dir, `${label}supportAcquisition.url is not a valid URL: "${supportAcquisition.url}"`);
        }
      }
    }
  }
}

function validateMetadata(dir, meta) {
  // Required fields (top-level only — see resolveField above)
  for (const field of REQUIRED_FIELDS) {
    const value = resolveField(meta, field);
    if (!value && value !== 0) {
      error(dir, `Missing required field: "${field}"`);
    }
  }

  const price = resolveField(meta, 'price');

  // price validation
  if (price && !VALID_PRICES.includes(price) && !price.startsWith('Free')) {
    error(dir, `Invalid price "${price}" — accepted values: ${VALID_PRICES.join(', ')}`);
  }

  // support: optional, but an unknown value matches no Support Level filter option.
  const supportLevels = [['', meta.support]];
  if (Array.isArray(meta.productVariants)) {
    for (const v of meta.productVariants) supportLevels.push([`productVariants["${v.product}"].`, v.support]);
  }
  for (const [label, value] of supportLevels) {
    if (value !== undefined && !VALID_SUPPORT.includes(value)) {
      error(dir, `Invalid ${label}support "${value}" — accepted values: ${VALID_SUPPORT.join(', ')}`);
    }
  }

  // Optional releaseDate. Left unset, the marketplace dates the listing from this folder's
  // last commit, which is right for most integrations — so this is a warning, not an error.
  const releaseDate = resolveField(meta, 'releaseDate');
  if (releaseDate && !RELEASE_DATE_PATTERN.test(String(releaseDate))) {
    warn(dir, `"releaseDate" ("${releaseDate}") is not an ISO date — expected "YYYY-MM-DD"`);
  }

  // Paid integrations: validate acquisition object
  const acquisition = resolveField(meta, 'acquisition');
  const partnerContactUrl = resolveField(meta, 'partnerContactUrl');
  if (price && price.startsWith('Paid')) {
    if (!acquisition && !partnerContactUrl) {
      warn(dir, `Paid integration is missing an "acquisition" object — add one to specify how users obtain this integration`);
    }

    if (acquisition) {
      if (!acquisition.type) {
        error(dir, `acquisition.type is required (e.g. "contact-sales", "contact-partner")`);
      }
      if (acquisition.type === 'contact-partner' && !acquisition.url) {
        error(dir, `acquisition.type is "contact-partner" but acquisition.url is missing`);
      }
      if (acquisition.url) {
        try {
          new URL(acquisition.url);
        } catch {
          error(dir, `acquisition.url is not a valid URL: "${acquisition.url}"`);
        }
      }
    }

    // Legacy: partnerContactUrl still accepted for backward compatibility
    if (price === 'Paid (Contact Partner)' && !acquisition) {
      if (!partnerContactUrl) {
        error(dir, `price is "Paid (Contact Partner)" but neither acquisition nor partnerContactUrl is provided`);
      } else {
        try {
          new URL(partnerContactUrl);
        } catch {
          error(dir, `partnerContactUrl is not a valid URL: "${partnerContactUrl}"`);
        }
        warn(dir, `"partnerContactUrl" is deprecated — replace with acquisition: { type: "contact-partner", url: "${partnerContactUrl}" }`);
      }
    }
  }

  // Free product, paid support: validate independently of price/acquisition above.
  validateSupportPricing(dir, '', resolveField(meta, 'supportPrice'), resolveField(meta, 'supportAcquisition'));

  // Products are a closed vocabulary, like categories. The value is matched verbatim by the
  // marketplace's Product filter and it selects the OVERVIEW-<suffix>.md file for the variant,
  // so a typo silently drops the listing out of the filter and serves the wrong overview.
  if (meta.products && !Array.isArray(meta.products)) {
    error(dir, `"products" must be an array`);
  }
  const products = Array.isArray(meta.products) ? meta.products : [];
  if (approvedProducts) {
    for (const product of products) {
      if (!approvedProducts.has(product)) {
        error(dir, `Product "${product}" is not in approved_products.json`);
      }
    }
  }

  // Each variant must name an approved product, and one already declared at the root.
  if (Array.isArray(meta.productVariants)) {
    for (const variant of meta.productVariants) {
      if (!variant || !variant.product) {
        error(dir, 'productVariants[] entry is missing "product"');
        continue;
      }
      if (approvedProducts && !approvedProducts.has(variant.product)) {
        error(dir, `productVariants product "${variant.product}" is not in approved_products.json`);
      }
      if (products.length && !products.includes(variant.product)) {
        error(dir, `productVariants product "${variant.product}" is not listed in the root "products" array`);
      }

      validateSupportPricing(dir, `productVariants["${variant.product}"].`, variant.supportPrice, variant.supportAcquisition);
    }
  }

  // tags approved list check
  if (meta.tags && Array.isArray(meta.tags) && approvedTags) {
    for (const tag of meta.tags) {
      if (!approvedTags.has(tag)) {
        warn(dir, `Tag "${tag}" is not in approved_tags.json`);
      }
    }
  }

  // Categories are a closed vocabulary: exactly one, drawn from approved_categories.json.
  // These are errors, not warnings — the category drives the marketplace filter and is
  // weighted highest by the "Recommended Integrations" scorer, so a bad value is not cosmetic.
  const cats = meta.categories || (meta.category ? [meta.category] : []);
  if (cats.length === 0) {
    error(dir, 'Missing required field: "categories" (exactly one approved category)');
  } else if (cats.length > 1) {
    error(dir, `Expected exactly one category, found ${cats.length}: ${cats.join(', ')}. Use tags for secondary facets.`);
  }
  if (approvedCategories) {
    for (const cat of cats) {
      if (!approvedCategories.has(cat)) {
        error(dir, `Category "${cat}" is not in approved_categories.json`);
      }
    }
  }

  // listingType: what kind of listing this is. Absent means "integration". Root-level only,
  // because the type describes the whole listing, not one product's variant of it.
  if (meta.listingType !== undefined) {
    if (typeof meta.listingType !== 'string') {
      error(dir, '"listingType" must be a string, e.g. "tool"');
    } else if (approvedListingTypes && !approvedListingTypes.has(meta.listingType)) {
      error(dir, `listingType "${meta.listingType}" is not in approved_listing_types.json (accepted: ${[...approvedListingTypes].join(', ')})`);
    }
  }
  if (Array.isArray(meta.productVariants)) {
    meta.productVariants.forEach((v, i) => {
      if (v && v.listingType !== undefined) {
        warn(dir, `productVariants[${i}] sets "listingType", which is root-level only and ignored per variant`);
      }
    });
  }

  // useCases stay a warning so contributors can propose new ones.
  if (Array.isArray(meta.useCases) && approvedUseCases) {
    for (const uc of meta.useCases) {
      if (!approvedUseCases.has(uc)) {
        warn(dir, `Use case "${uc}" is not in approved_usecases.json`);
      }
    }
  }

  // URL fields should be valid URLs
  for (const urlField of ['externalDocsUrl', 'supportUrl', 'partnerContactUrl']) {
    if (meta[urlField]) {
      try {
        new URL(meta[urlField]);
      } catch {
        error(dir, `${urlField} is not a valid URL: "${meta[urlField]}"`);
      }
    }
  }

  // A product can only have one company behind its support contact — supportUrl and
  // supportEmail are mutually exclusive per level (root or a single productVariants[] entry).
  // Only supportUrl is ever displayed when both are set, so the other is silently unused.
  if (meta.supportUrl && meta.supportEmail) {
    warn(dir, `Both "supportUrl" and "supportEmail" are set at the top level — only "supportUrl" will be displayed. Remove the one that doesn't apply.`);
  }
  if (Array.isArray(meta.productVariants)) {
    for (const variant of meta.productVariants) {
      if (variant && variant.supportUrl && variant.supportEmail) {
        warn(dir, `Both "supportUrl" and "supportEmail" are set on productVariants["${variant.product}"] — only "supportUrl" will be displayed. Remove the one that doesn't apply.`);
      }
    }
  }
}

// Release notes are required for every integration, including a brand-new one's initial
// version — not just updates. Two authoring formats are accepted, auto-detected: one file per
// version (ReleaseNotes/<version>[-<suffix>].md), or a single running changelog
// (ReleaseNotes/CHANGELOG[-<suffix>].md) with "## Version X.Y.Z" sections inside. Mixing both
// formats for the same suffix is rejected — see the mixed-format check below.
function validateVersioning(dir, meta) {
  // A version may be declared at the top level or per product variant.
  const versions = new Set();
  const topVersion = resolveField(meta, 'currentVersion');
  if (topVersion) versions.add(topVersion);
  if (Array.isArray(meta.productVariants)) {
    for (const v of meta.productVariants) {
      if (v && v.currentVersion) versions.add(v.currentVersion);
    }
  }

  if (versions.size === 0) {
    warn(dir, `Missing "currentVersion" — add a semantic version (e.g. "1.0.0")`);
  }
  for (const version of versions) {
    if (typeof version !== 'string' || !VERSION_PATTERN.test(version)) {
      warn(dir, `"currentVersion" ("${version}") is not a valid semantic version (expected e.g. "1.2.0")`);
    }
  }

  const releaseNotesDir = path.join(dir, 'ReleaseNotes');
  const allFiles = fs.existsSync(releaseNotesDir)
    ? fs.readdirSync(releaseNotesDir).filter((f) => f.toLowerCase().endsWith('.md'))
    : [];

  const rnFiles = allFiles.filter((f) => RELEASE_NOTE_PATTERN.test(f));
  const changelogFiles = allFiles.filter((f) => CHANGELOG_PATTERN.test(f));

  for (const f of allFiles) {
    if (!RELEASE_NOTE_PATTERN.test(f) && !CHANGELOG_PATTERN.test(f)) {
      warn(dir, `Release note "${f}" does not match "<version_with_underscores>[-<suffix>].md" or "CHANGELOG[-<suffix>].md"`);
    }
  }

  // Mixing both formats for the same suffix is ambiguous (which one is authoritative?) — pick
  // one per integration/product. A shared file (no suffix) is its own bucket, keyed by null.
  const rnSuffixes = new Set(rnFiles.map((f) => (f.match(RELEASE_NOTE_PATTERN)[2] || '').replace(/^-/, '') || null));
  const changelogSuffixes = new Set(changelogFiles.map((f) => (f.match(CHANGELOG_PATTERN)[1] || '').replace(/^-/, '') || null));
  for (const suffix of rnSuffixes) {
    if (changelogSuffixes.has(suffix)) {
      error(dir, `Both a CHANGELOG${suffix ? `-${suffix}` : ''}.md and individual release-note files exist for ${suffix ? `"${suffix}"` : 'the shared (unsuffixed)'} notes — pick one format`);
    }
  }

  // A release note is required for every declared version — either a matching per-version
  // file (shared or product-specific), or a "## Version X.Y.Z" section in any CHANGELOG file.
  for (const version of versions) {
    if (!VERSION_PATTERN.test(version)) continue;
    const base = version.replace(/\./g, '_');
    const hasFile = rnFiles.some((f) => f === `${base}.md` || f.startsWith(`${base}-`));
    const hasChangelogEntry = changelogFiles.some((f) => {
      const content = fs.readFileSync(path.join(releaseNotesDir, f), 'utf8');
      CHANGELOG_VERSION_HEADING.lastIndex = 0;
      let m;
      while ((m = CHANGELOG_VERSION_HEADING.exec(content))) {
        if (m[1] === version) return true;
      }
      return false;
    });
    if (!hasFile && !hasChangelogEntry) {
      error(dir, `No release note for version ${version} — add ReleaseNotes/${base}.md, a product-specific ${base}-<suffix>.md, or a "## Version ${version}" section in ReleaseNotes/CHANGELOG.md`);
    }
  }
}

function validateDirectory(dir) {
  const name = path.basename(dir);
  totalChecked++;

  // Skip template directory
  if (name === '.template') return;

  // integration_metadata.json must exist
  const metaPath = path.join(dir, 'integration_metadata.json');
  if (!fs.existsSync(metaPath)) {
    error(dir, 'integration_metadata.json is missing');
    return;
  }

  // Parse metadata
  let meta;
  try {
    meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
  } catch (e) {
    error(dir, `integration_metadata.json is not valid JSON: ${e.message}`);
    return;
  }

  acceptLegacyVocabulary(dir, meta);
  rejectDefaultsBlock(dir, meta);
  validateMetadata(dir, meta);
  validateVersioning(dir, meta);

  // Logo file must exist
  const files = fs.readdirSync(dir);
  const hasLogo = files.some(f => {
    const ext = path.extname(f).toLowerCase();
    return LOGO_EXTENSIONS.includes(ext) && (
      f.toLowerCase().includes('logo') ||
      f.toLowerCase().includes(name.toLowerCase()) ||
      files.length <= 5 // if few files, any image counts as logo
    );
  });

  // More lenient: any image file counts. A missing logo is not a blocker —
  // listings without their own logo fall back to the generic marketplace logo.
  const hasAnyImage = files.some(f => LOGO_EXTENSIONS.includes(path.extname(f).toLowerCase()));
  if (!hasAnyImage) {
    warn(dir, 'No logo image file found (expected .png, .svg, .jpg, .jpeg, or .webp) — the generic fallback logo (assets/integration-fallback.svg) will be used');
  }

  // At least one overview/readme doc
  const hasOverview = files.some(f => OVERVIEW_PATTERNS.some(p => p.test(f)));
  if (!hasOverview) {
    warn(dir, 'No OVERVIEW-*.md or README.md found — consider adding integration documentation');
  }

  // Every declared overviewFile / documentationFile must actually resolve on disk.
  // These are errors, not warnings: the marketplace generator masks a bad overviewFile by
  // auto-detecting OVERVIEW-<suffix>.md first, so a dangling pointer renders fine today and
  // silently becomes a blank page the moment the suffixed file is renamed or removed.
  const checkFileRef = (label, value) => {
    if (value && !fs.existsSync(path.join(dir, value))) {
      error(dir, `${label} points at "${value}", which does not exist in this folder`);
    }
  };
  checkFileRef('documentationFile', meta.documentationFile);
  if (Array.isArray(meta.productVariants)) {
    for (const v of meta.productVariants) {
      const product = v.product || 'unknown product';
      checkFileRef(`productVariants["${product}"].overviewFile`, v.overviewFile);
      checkFileRef(`productVariants["${product}"].documentationFile`, v.documentationFile);
    }
  }

  // A bare DOCUMENTATION.md in the folder is a single physical file — the site no longer
  // auto-applies it to every productVariant that lacks its own documentationFile/DOCS-<suffix>.md
  // (that used to silently leak one product's doc content onto another, e.g. a Self-Hosted-only
  // Adaptable driver README showing up on the SaaS/NGTS tab). For a genuinely multi-product
  // integration, warn so authors notice and explicitly opt each variant in (or accept it has no
  // embedded doc) instead of assuming DOCUMENTATION.md still applies everywhere.
  const DOC_SUFFIX_BY_PRODUCT = {
    'Certificate Manager Self-Hosted': 'selfhosted',
    'Certificate Manager SaaS': 'saas',
    'Next-Gen Trust Security': 'ngts',
    'Zero Touch PKI': 'ztpki',
  };
  if (Array.isArray(meta.productVariants) && meta.productVariants.length > 1
    && fs.existsSync(path.join(dir, 'DOCUMENTATION.md'))) {
    for (const v of meta.productVariants) {
      const suffix = DOC_SUFFIX_BY_PRODUCT[v.product];
      const hasSuffixedFile = suffix && fs.existsSync(path.join(dir, `DOCS-${suffix}.md`));
      if (!v.documentationFile && !hasSuffixedFile) {
        warn(dir, `productVariants["${v.product}"] has no documentationFile and no DOCS-${suffix || '<suffix>'}.md — a generic DOCUMENTATION.md exists in this folder, but it's no longer auto-applied across products; set documentationFile explicitly if it documents "${v.product}", or ignore if this product genuinely has no embedded doc`);
      }
    }
  }

  // downloadFiles (downloadable published assets) may be declared at the top level or per
  // productVariant (variant → top level resolution; an explicit [] on a variant suppresses its
  // download). Every listed file must resolve on disk — a dangling download renders a broken
  // button — so a missing entry is an error. An empty array is valid.
  const checkDownloadFiles = (label, list) => {
    if (list === undefined) return;
    if (!Array.isArray(list)) {
      error(dir, `${label} must be an array of filenames`);
      return;
    }
    for (const f of list) {
      if (typeof f !== 'string' || !fs.existsSync(path.join(dir, f))) {
        error(dir, `${label} lists "${f}", which does not exist in this folder`);
      }
    }
  };
  checkDownloadFiles('downloadFiles', meta.downloadFiles);
  if (Array.isArray(meta.productVariants)) {
    for (const v of meta.productVariants) {
      const product = v.product || 'unknown product';
      checkDownloadFiles(`productVariants["${product}"].downloadFiles`, v.downloadFiles);
    }
  }

  // Root-level downloadFiles is a legacy fallback the site generator resolves for
  // single-product integrations only. For a multi-product integration it silently bleeds
  // into every productVariant that doesn't declare its own downloadFiles (or `[]` to
  // suppress it) — e.g. a Self-Hosted-only PowerShell Adaptable driver script showing a
  // "Downloads" button on the SaaS/NGTS listing pages too. Once productVariants exists,
  // force authors to be explicit: declare downloadFiles on each variant that has one
  // (duplicating a genuinely shared list across variants if needed), and `[]` to opt a
  // variant out.
  if (Array.isArray(meta.productVariants) && meta.productVariants.length > 0 && meta.downloadFiles !== undefined) {
    error(dir, 'root-level "downloadFiles" is not allowed alongside "productVariants" — scope it to the specific productVariants entry (or entries) that use it');
  }

  // license: any integration that ships a downloadFiles asset should say what license covers
  // it. Root-level only (one license covers the whole repo's distributed assets).
  const hasAnyDownloadFiles =
    (Array.isArray(meta.downloadFiles) && meta.downloadFiles.length > 0) ||
    (Array.isArray(meta.productVariants) &&
      meta.productVariants.some(v => Array.isArray(v.downloadFiles) && v.downloadFiles.length > 0));
  if (hasAnyDownloadFiles && !meta.license) {
    warn(dir, 'has downloadFiles but no root-level "license" field — set e.g. "license": "MIT" so the listing can show what covers the download');
  }

  // licenseUrl: where the listing's License row links. Without it the site links "MIT" to this
  // repo's root LICENSE and shows any other license as unlinked text, so every non-MIT license
  // must name its own terms URL.
  if (meta.licenseUrl !== undefined) {
    if (typeof meta.licenseUrl !== 'string' || !meta.licenseUrl) {
      error(dir, '"licenseUrl" must be a non-empty string');
    } else {
      let parsed = null;
      try { parsed = new URL(meta.licenseUrl); } catch { /* reported below */ }
      if (!parsed) {
        error(dir, `licenseUrl is not a valid URL: "${meta.licenseUrl}"`);
      } else if (parsed.protocol !== 'https:') {
        error(dir, `licenseUrl must use https: "${meta.licenseUrl}"`);
      }
    }
    if (!meta.license) {
      error(dir, '"licenseUrl" is set but "license" is not — set "license" to the name shown on the listing');
    }
  }
  if (meta.license !== undefined && typeof meta.license !== 'string') {
    error(dir, '"license" must be a string, e.g. "MIT"');
  } else if (meta.license && meta.license !== 'MIT' && !meta.licenseUrl) {
    error(dir, `license "${meta.license}" needs a root-level "licenseUrl" pointing at its terms — only "MIT" falls back to the repo's LICENSE file`);
  }
  if (Array.isArray(meta.productVariants)) {
    meta.productVariants.forEach((v, i) => {
      if (v && (v.license !== undefined || v.licenseUrl !== undefined)) {
        warn(dir, `productVariants[${i}] sets "license"/"licenseUrl", which are root-level only and ignored per variant`);
      }
    });
  }

  // primaryCta: the per-variant call-to-action (also accepted at the top level).
  // The site auto-defaults it (Download when downloadFiles exist, else View Docs when doc links
  // exist), so authors only set this to override. Validated as an error because a malformed CTA
  // renders a broken or blank button.
  const CTA_TYPES = new Set(['download', 'docs', 'link', 'contact-sales', 'contact-partner']);
  const checkPrimaryCta = (label, cta) => {
    if (cta === undefined) return;
    if (typeof cta !== 'object' || cta === null || Array.isArray(cta)) {
      error(dir, `${label} must be an object`);
      return;
    }
    if (!cta.type || !CTA_TYPES.has(cta.type)) {
      error(dir, `${label}.type must be one of: ${[...CTA_TYPES].join(', ')}`);
    }
    for (const strField of ['label', 'description']) {
      if (cta[strField] !== undefined && typeof cta[strField] !== 'string') {
        error(dir, `${label}.${strField} must be a string`);
      }
    }
    if (cta.url !== undefined) {
      if (typeof cta.url !== 'string') {
        error(dir, `${label}.url must be a string`);
      } else {
        try { new URL(cta.url); } catch { error(dir, `${label}.url is not a valid URL: "${cta.url}"`); }
      }
    }
    if (cta.type === 'link' && !cta.url) {
      error(dir, `${label} of type "link" requires a "url"`);
    }
  };
  checkPrimaryCta('primaryCta', meta.primaryCta);
  if (Array.isArray(meta.productVariants)) {
    for (const v of meta.productVariants) {
      const product = v.product || 'unknown product';
      checkPrimaryCta(`productVariants["${product}"].primaryCta`, v.primaryCta);
    }
  }

  // No internal/sensitive files
  const forbidden = ['.env', 'credentials.json', 'secrets.json', 'private.key'];
  for (const f of files) {
    if (forbidden.includes(f.toLowerCase())) {
      error(dir, `Forbidden file found: ${f} — do not commit credentials or secrets`);
    }
  }
}

function run(targetDir) {
  const dirs = targetDir
    ? [path.resolve(targetDir)]
    : fs.readdirSync(INTEGRATIONS_DIR)
        .filter(d => !d.startsWith('.'))
        .map(d => path.join(INTEGRATIONS_DIR, d))
        .filter(d => fs.statSync(d).isDirectory());

  for (const dir of dirs) {
    validateDirectory(dir);
  }

  console.log(`\nValidated ${totalChecked} integration(s)`);

  if (warnings.length > 0) {
    console.log('\nWarnings:');
    warnings.forEach(w => console.log(w));
  }

  if (errors.length > 0) {
    console.log('\nErrors:');
    errors.forEach(e => console.log(e));
    console.log(`\n${errors.length} error(s) found. Fix them before merging.\n`);
    process.exit(1);
  } else {
    console.log('\nAll validations passed.\n');
  }
}

const target = process.argv[2] || null;
run(target);
