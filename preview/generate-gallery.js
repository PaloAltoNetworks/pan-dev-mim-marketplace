// docs/generate-gallery.js
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");
const { v4: uuidv4 } = require("uuid");
const sharp = require('sharp');
const downloadsBaseDir = path.join(__dirname, "static/downloads");
// Name of a per-build download folder (uuidv4), the only entries the cleanup below may delete.
const UUID_DIR = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Per-variant download switch, owned by PDM admins (contributors never edit it, so it is
// not under Integrations/). Keyed by Integrations/ folder name, then by the variant's exact
// `product` string, or "*" for every variant. A disabled variant resolves to no
// downloadFiles: nothing is copied or published, no <DownloadButton> is emitted, a download
// primary CTA falls through to the next type, and the Release Notes tab shows
// DOWNLOADS_DISABLED_NOTICE where the buttons would be. Missing file = everything enabled.
const downloadsConfigPath = path.join(__dirname, "config/marketplace-downloads.json");
// Keep the link in step with the "downloads-moving-here" banner in
// config/marketplace-announcements.json, which shows on the same pages.
const CYBERARK_MARKETPLACE_URL =
    "https://community.cyberark.com/marketplace/s/#---CyberArk_Solution__c-Certificate%20Lifecycle%20Management";
const DOWNLOADS_DISABLED_NOTICE =
    `:::info\n\nDownloads are moving to this Marketplace soon. For now, download this integration from the [CyberArk Marketplace](${CYBERARK_MARKETPLACE_URL}).\n\n:::`;

function loadDownloadsConfig() {
    if (!fs.existsSync(downloadsConfigPath)) {
        return { default: true, enabled: {}, disabled: {} };
    }
    const raw = JSON.parse(fs.readFileSync(downloadsConfigPath, "utf8"));
    return {
        default: raw.default !== false,
        enabled: raw.enabled ?? {},
        disabled: raw.disabled ?? {},
    };
}

const downloadsConfig = loadDownloadsConfig();

// The listed-variant map that overrides `default`: `disabled` when downloads default on,
// `enabled` when they default off.
const downloadsOverrides = () =>
    downloadsConfig.default ? downloadsConfig.disabled : downloadsConfig.enabled;

function isDownloadEnabled(folder, product) {
    const listed = downloadsOverrides()[folder];
    const isListed = Array.isArray(listed) && (listed.includes("*") || listed.includes(product));
    return isListed ? !downloadsConfig.default : downloadsConfig.default;
}

// Warn on config entries that match nothing, so a typo can't silently leave downloads on.
function warnUnknownDownloadsConfigKeys(productsByFolder) {
    for (const [folder, products] of Object.entries(downloadsOverrides())) {
        const known = productsByFolder[folder];
        if (!known) {
            console.warn(`⚠️  marketplace-downloads.json: unknown integration folder "${folder}"`);
            continue;
        }
        for (const product of products) {
            if (product !== "*" && !known.has(product)) {
                console.warn(`⚠️  marketplace-downloads.json: "${folder}" has no product "${product}"`);
            }
        }
    }
}

// Marketplace announcement banners (config/marketplace-announcements.json) are read by the
// MarketplaceAnnouncements component in the browser, not generated here. This only checks the
// file at build time so an admin's typo shows up as a warning instead of a banner that silently
// never appears. Invalid entries are skipped by the component.
function warnInvalidAnnouncements() {
    const file = path.join(__dirname, "config/marketplace-announcements.json");
    if (!fs.existsSync(file)) return;
    const list = JSON.parse(fs.readFileSync(file, "utf8")).announcements ?? [];
    const seen = new Set();
    const warn = (i, msg) => console.warn(`⚠️  marketplace-announcements.json [${i}]: ${msg}`);
    list.forEach((a, i) => {
        if (!a.id) warn(i, 'missing "id"');
        else if (seen.has(a.id)) warn(i, `duplicate id "${a.id}"`);
        seen.add(a.id);
        if (!a.message) warn(i, 'missing "message"');
        if (a.severity && !["info", "warning", "critical"].includes(a.severity)) {
            warn(i, `unknown severity "${a.severity}", showing as "info"`);
        }
        for (const key of ["start", "end"]) {
            if (a[key] !== undefined && Number.isNaN(Date.parse(a[key]))) {
                warn(i, `"${key}" is not a valid date: "${a[key]}" (entry will not show)`);
            }
        }
        if (a.start && a.end && Date.parse(a.end) <= Date.parse(a.start)) {
            warn(i, '"end" is not after "start" (entry will not show)');
        }
        if (a.end && Date.parse(a.end) <= Date.now()) {
            warn(i, `"${a.id}" expired at ${a.end}; you can delete it`);
        }
        if (a.link && !a.link.href) warn(i, 'link has no "href"');
        if (a.placements !== undefined) {
            if (!Array.isArray(a.placements) || a.placements.length === 0) {
                warn(i, '"placements" must be a non-empty array (entry will not show)');
            } else {
                for (const pl of a.placements) {
                    if (!["gallery", "downloads-disabled"].includes(pl)) warn(i, `unknown placement "${pl}"`);
                }
            }
        }
    });
}
warnInvalidAnnouncements();

const integrationsDir = path.join(__dirname, "../Integrations");
const integrationDatesPath = path.join(integrationsDir, ".integration-dates.json");
const outputJsonPath = path.join(__dirname, "src/data/integrations.json");
const outputDocsDir = path.join(__dirname, "docs/marketplace");
const logoDestDir = path.join(__dirname, "static/img/integrations");

// Logo normalization constants
const PADDING = 8;            // Add 8px uniform padding
const LOGO_MAX_WIDTH = 160;   // Maximum logo width (176px total with padding)
const LOGO_MAX_HEIGHT = 92;   // Maximum logo height (108px total with padding)

// Known lowercase HTML tags that are valid in MDX — anything else starting with uppercase
// or containing spaces should be escaped.
const VALID_HTML_TAGS = new Set([
    'a','abbr','address','area','article','aside','audio','b','base','bdi','bdo',
    'blockquote','body','br','button','canvas','caption','cite','code','col','colgroup',
    'data','datalist','dd','del','details','dfn','dialog','div','dl','dt','em','embed',
    'fieldset','figcaption','figure','footer','form','h1','h2','h3','h4','h5','h6',
    'head','header','hr','html','i','iframe','img','input','ins','kbd','label','legend',
    'li','link','main','map','mark','menu','meta','meter','nav','noscript','object','ol',
    'optgroup','option','output','p','picture','pre','progress','q','rp','rt','ruby',
    's','samp','script','section','select','small','source','span','strong','style','sub',
    'summary','sup','table','tbody','td','template','textarea','tfoot','th','thead','time',
    'title','tr','track','u','ul','var','video','wbr',
]);

// Sanitize a single non-code-block line segment
function sanitizeSegment(text) {
    // Normalize non-breaking spaces (U+00A0) to regular spaces — common copy-paste artifact
    text = text.replace(/\u00a0/g, ' ');
    // Fix **text **continuation → **text** continuation (space before closing **)
    text = text.replace(/\*\*([^*\n]+?) \*\*/g, '**$1** ');
    // Fix *text *continuation → *text* continuation (space before closing *)
    text = text.replace(/(?<!\*)\*([^*\n]+?) \*(?!\*)/g, '*$1* ');
    // Markdown autolinks (<https://…>, <mailto:…>) read as JSX to MDX. The escaping rules
    // below would only rewrite the opening `<`, leaving `&lt;https://example.com>` — GFM then
    // auto-links the remainder with the stray `>` inside the href and Docusaurus fails to
    // parse the URL. Rewrite them as explicit markdown links before any escaping happens.
    text = text.replace(/<(https?:\/\/[^\s<>]+)>/g, '[$1]($1)');
    text = text.replace(/<mailto:([^\s<>]+)>/g, '[$1](mailto:$1)');

    return text
        // 1. Escape { and } so MDX doesn't try to parse them as JSX expressions
        .replace(/\{/g, '\\{')
        .replace(/\}/g, '\\}')
        // 2. Catch the exact </~ error
        .replace(/<\/~/g, '&lt;/~')
        // 3. Catch <~ and < ~ variations
        .replace(/<\s*~/g, '&lt;~')
        // 4. Escape <TagName where TagName starts with uppercase (fake JSX component)
        .replace(/<([A-Z][a-zA-Z0-9]*)/g, (match, tag) => `&lt;${tag}`)
        // 5. Escape <tag where tag is not a known HTML element
        .replace(/<([a-z][a-zA-Z0-9-]*)/g, (match, tag) => {
            if (VALID_HTML_TAGS.has(tag.toLowerCase())) return match;
            return `&lt;${tag}`;
        })
        // 6. Catch ANY remaining < not starting a valid HTML tag, comment, or closing tag
        .replace(/<(?=[^a-zA-Z\/\!\?])/g, '&lt;')
        // 7. Catch ANY </ not starting a valid HTML tag
        .replace(/<\/(?=[^a-zA-Z])/g, '&lt;/');
}

// Helper to prevent legacy markdown from breaking the Docusaurus React/JSX parser.
// Processes line-by-line, skipping fenced code blocks and inline code spans.
function sanitizeMDX(text) {
    if (!text) return '';
    const lines = text.split('\n');
    let inFencedCode = false;
    let fencePattern = null;

    return lines.map(line => {
        // Detect fenced code block open/close
        const fenceMatch = line.match(/^([ \t]*)(```+|~~~+)/);
        if (fenceMatch) {
            if (!inFencedCode) {
                inFencedCode = true;
                fencePattern = fenceMatch[2];
            } else if (line.trim().startsWith(fencePattern)) {
                inFencedCode = false;
                fencePattern = null;
            }
            return line; // Never sanitize fence lines themselves
        }
        if (inFencedCode) return line;

        // Split on inline code spans (`...`) and only sanitize non-code segments
        const parts = line.split(/(``?[^`]*``?)/);
        return parts.map((part, i) => (i % 2 === 1 ? part : sanitizeSegment(part))).join('');
    }).join('\n');
}

/**
 * Strip YAML frontmatter from markdown content
 */
function stripFrontmatter(text) {
    if (!text) return '';
    // Match frontmatter: starts with ---, ends with ---, may span multiple lines
    const frontmatterPattern = /^---\s*\n[\s\S]*?\n---\s*\n/;
    return text.replace(frontmatterPattern, '').trimStart();
}

/**
 * Convert product name to file suffix for auto-detection
 */
function getProductSuffix(productName) {
    const mapping = {
        'Certificate Manager SaaS': 'saas',
        'Certificate Manager Self-Hosted': 'selfhosted',
        'Next-Gen Trust Security': 'ngts',
        'Zero Touch PKI': 'ztpki'
    };
    if (!mapping[productName]) {
        // Falling through here serves that variant the SaaS overview, silently. The marketplace
        // repo's approved_products.json is what actually prevents it; this is the tripwire.
        console.warn(`⚠️  Unrecognized product "${productName}" — falling back to the "saas" file suffix`);
    }
    return mapping[productName] || 'saas';
}

/**
 * Resolve the local documentation file for a variant, if one exists on disk.
 * Auto-detect order: DOCS-{suffix}.md > variant.documentationFile. No bare-DOCUMENTATION.md
 * fallback: that used to apply to any variant lacking the first two, which silently leaked
 * one product's doc content onto another product's tab for multi-product integrations
 * (e.g. a Self-Hosted-only Adaptable driver README showing up on the SaaS/NGTS tab too).
 * A single-product integration's root-level `documentationFile` still works — normalizeMetadata()
 * copies it onto the synthesized variant, so it resolves here as an explicit `variant.documentationFile`,
 * not through this function's own fallback.
 * Single source of truth shared by the Documentation tab (MDX generation) and
 * primaryCta inference (resolvePrimaryCta) — they must agree on whether a
 * Documentation tab exists, or a "docs" CTA could point at a tab that isn't there.
 */
function resolveVariantDocPath(intPath, suffix, variant) {
    const autoDocsPath = path.join(intPath, `DOCS-${suffix}.md`);
    const explicitDocsPath = variant.documentationFile ? path.join(intPath, variant.documentationFile) : null;

    if (fs.existsSync(autoDocsPath)) return autoDocsPath;
    if (explicitDocsPath && fs.existsSync(explicitDocsPath)) return explicitDocsPath;
    return null;
}

const RN_FILE_PATTERN = /^(\d+_\d+(?:_\d+)?)(?:-([a-z0-9]+))?\.md$/;
const CHANGELOG_FILE_PATTERN = /^CHANGELOG(?:-([a-z0-9]+))?\.md$/i;
// A version heading must be on its own line so the body starts cleanly on the next line — kept
// in sync with the (looser, detection-only) pattern in scripts/validate-integration.js.
const CHANGELOG_VERSION_HEADING = /^##[ \t]*Version[ \t]+(\d+\.\d+(?:\.\d+)?)[ \t]*\r?\n/gim;

// One-file-per-version format: <version_with_underscores>[-<suffix>].md, e.g. "1_1_0.md" (shared
// across all products) or "1_1_0-selfhosted.md" (that product only).
function releaseNotesEntriesFromFiles(releaseNotesDir, suffix) {
    return fs
        .readdirSync(releaseNotesDir)
        .map((file) => {
            const m = file.match(RN_FILE_PATTERN);
            if (!m) return null;
            return { file, version: m[1].replace(/_/g, '.'), fileSuffix: m[2] || null };
        })
        .filter(Boolean)
        // Shared notes (no suffix) always apply; suffixed notes only for the matching product.
        .filter((e) => !e.fileSuffix || e.fileSuffix === suffix)
        .map((e) => ({
            version: e.version,
            body: sanitizeMDX(fs.readFileSync(path.join(releaseNotesDir, e.file), 'utf8')),
        }));
}

// Combined-changelog format: CHANGELOG[-<suffix>].md with one "## Version X.Y.Z" section per
// entry. Same shared-vs-suffixed convention as the per-file format.
function releaseNotesEntriesFromChangelog(releaseNotesDir, suffix) {
    const files = fs.readdirSync(releaseNotesDir).filter((f) => {
        const m = f.match(CHANGELOG_FILE_PATTERN);
        if (!m) return false;
        const fileSuffix = m[1] || null;
        return !fileSuffix || fileSuffix === suffix;
    });

    const entries = [];
    for (const file of files) {
        const content = fs.readFileSync(path.join(releaseNotesDir, file), 'utf8');
        const headings = [...content.matchAll(CHANGELOG_VERSION_HEADING)];
        headings.forEach((m, i) => {
            const start = m.index + m[0].length;
            const end = i + 1 < headings.length ? headings[i + 1].index : content.length;
            entries.push({ version: m[1], body: sanitizeMDX(content.slice(start, end).trim()) });
        });
    }
    return entries;
}

function sortReleaseNotesNewestFirst(entries) {
    // Sort numerically, newest-first (fixes string-sort mis-ordering of e.g. 1.10.0 vs 1.2.0).
    const toParts = (v) => v.split('.').map(Number);
    return entries.slice().sort((a, b) => {
        const pa = toParts(a.version);
        const pb = toParts(b.version);
        for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
            const diff = (pb[i] || 0) - (pa[i] || 0);
            if (diff !== 0) return diff;
        }
        return 0;
    });
}

/**
 * Build the Release Notes tab content for an integration (its own tab, not Overview text).
 *
 * Supports both authoring formats — one file per version, or a single CHANGELOG[-<suffix>].md
 * with "## Version X.Y.Z" sections — auto-detected. Mixing both for the same product is a
 * validator error (scripts/validate-integration.js); if both somehow exist anyway, the combined
 * file wins here as a defensive default.
 *
 * When `downloadButtonsMarkup` is given, it's appended right after the newest entry only — GitHub
 * Releases style: every past note is shown, but only the current version's downloads are offered.
 *
 * Returns '' when no matching notes exist — callers use that to decide whether the tab exists.
 * No leading "## Release Notes" heading: the tab label already says that.
 */
function buildReleaseNotes(releaseNotesDir, suffix, downloadButtonsMarkup = '') {
    if (!fs.existsSync(releaseNotesDir)) return '';

    const changelogEntries = releaseNotesEntriesFromChangelog(releaseNotesDir, suffix);
    const entries = changelogEntries.length > 0
        ? changelogEntries
        : releaseNotesEntriesFromFiles(releaseNotesDir, suffix);

    if (entries.length === 0) return '';

    const sorted = sortReleaseNotesNewestFirst(entries);

    let block = '';
    sorted.forEach((e, i) => {
        block += `### Version ${e.version}\n`;
        block += e.body + "\n\n";
        if (i === 0 && downloadButtonsMarkup) {
            block += downloadButtonsMarkup + "\n\n";
        }
    });
    return block;
}

/**
 * Normalize a logo using Sharp: trim → resize → sharpen → pad
 */
async function normalizeLogo(inputPath, outputPath) {
    try {
        await sharp(inputPath)
            .trim({ threshold: 10 })  // More aggressive trim with threshold
            .resize(LOGO_MAX_WIDTH, LOGO_MAX_HEIGHT, {
                fit: 'inside',  // Fit within box, maintaining aspect ratio
                kernel: 'lanczos3',  // High-quality downsampling kernel
                withoutEnlargement: false,
                background: { r: 0, g: 0, b: 0, alpha: 0 }
            })
            .sharpen({
                sigma: 0.5,  // Subtle sharpening to compensate for downsampling
                m1: 0.5,
                m2: 0.5
            })
            .extend({
                top: PADDING,
                bottom: PADDING,
                left: PADDING,
                right: PADDING,
                background: { r: 0, g: 0, b: 0, alpha: 0 }
            })
            .png({
                quality: 100,  // Maximum PNG quality
                compressionLevel: 9,  // Best compression
                palette: false  // Use full color, not indexed palette
            })
            .toFile(outputPath);
        return true;
    } catch (err) {
        console.error(`❌ Error normalizing ${path.basename(inputPath)}:`, err.message);
        return false;
    }
}

/**
 * Normalize metadata for backward compatibility with old schema
 */
function normalizeMetadata(metadata) {
    // Accept both the current product vocabulary and the pre-rename platform one, indefinitely.
    // The marketplace repo owns these files and renames on its own schedule, so an old-shaped
    // manifest can reappear at any point in the sync cycle — from an in-flight contributor PR,
    // a fork, or a revert. Everything downstream of this point is product-native.
    //
    // NOTE: resources.videos[].platform is a *different* field ("youtube"/"vimeo"). This is a
    // key-aware rename of three specific paths, never a blanket substitution.
    if (metadata.products === undefined && metadata.platforms !== undefined) {
        metadata.products = metadata.platforms;
    }
    if (metadata.productVariants === undefined && metadata.platformVariants !== undefined) {
        metadata.productVariants = metadata.platformVariants;
    }
    if (metadata.productVariants) {
        metadata.productVariants = metadata.productVariants.map((variant) => {
            if (variant.product !== undefined) return variant;
            const { platform, ...rest } = variant;
            return { ...rest, product: platform };
        });
    }
    delete metadata.platforms;
    delete metadata.platformVariants;

    // Normalize acquisition from legacy fields if not already present
    if (!metadata.acquisition) {
        if (metadata.price === 'Paid (Contact Partner)' && metadata.partnerContactUrl) {
            metadata.acquisition = {
                type: 'contact-partner',
                url: metadata.partnerContactUrl
            };
        } else if (metadata.price && metadata.price.startsWith('Paid') && metadata.price !== 'Free') {
            metadata.acquisition = { type: 'contact-sales' };
        }
    }

    // If no productVariants, create synthetic one (backward compatibility)
    if (!metadata.productVariants || metadata.productVariants.length === 0) {
        const product = metadata.products?.[0] ?? 'Certificate Manager Self-Hosted';
        metadata.productVariants = [{
            product: product,
            support: metadata.support,
            currentVersion: metadata.currentVersion,
            author: metadata.author,
            supportUrl: metadata.supportUrl,
            supportEmail: metadata.supportEmail,
            externalDocsUrl: metadata.externalDocsUrl,
            externalDocsLabel: metadata.externalDocsLabel,
            // Now that resolveVariantDocPath() no longer falls back to a bare DOCUMENTATION.md
            // for any variant lacking documentationFile, a single-product integration's
            // root-level documentationFile must be copied onto its synthesized variant here —
            // otherwise it would silently lose documentation it always had.
            documentationFile: metadata.documentationFile,
            price: metadata.price,
            supportPrice: metadata.supportPrice,
            supportAcquisition: metadata.supportAcquisition
        }];
    }

    return metadata;
}

/**
 * Per-integration commit dates recorded by .gitlab/scripts/sync-integrations.sh from the
 * marketplace repo's history. Absent on a fresh checkout that has never run a sync — the
 * local git fallback in resolveLastUpdated() covers that case for development.
 */
function loadIntegrationDates() {
    try {
        return JSON.parse(fs.readFileSync(integrationDatesPath, "utf8"));
    } catch {
        console.warn("⚠️  No Integrations/.integration-dates.json — falling back to local git history for listing dates");
        return {};
    }
}

/**
 * Date shown as "last update" on the marketplace card, and the key the catalog sorts on.
 * An explicit `releaseDate` in integration_metadata.json always wins; otherwise fall back to
 * the synced snapshot, then to this repo's own git history (only meaningful locally — CI
 * shallow-clones, and every folder shares the bulk-import commit anyway).
 */
function resolveLastUpdated(metadata, folder, datesSnapshot) {
    const declared = metadata.releaseDate;
    if (declared) return declared;

    if (datesSnapshot[folder]) return datesSnapshot[folder];

    try {
        const stamp = execFileSync(
            "git",
            ["log", "-1", "--format=%cI", "--", `Integrations/${folder}`],
            { cwd: path.join(__dirname, ".."), encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] },
        ).trim();
        return stamp || undefined;
    } catch {
        return undefined;
    }
}

// Default button labels per CTA type. `link` has no default — a bare "Learn More"
// is applied as a last resort in resolvePrimaryCta().
const DEFAULT_CTA_LABELS = {
    download: 'Download',
    docs: 'View Documentation Tab',
    'contact-sales': 'Contact Your Account Team',
    'contact-partner': 'Contact Partner',
};

// Paid types carry the "Paid Integration" badge; download/docs/link do not.
const PAID_CTA_TYPES = new Set(['contact-sales', 'contact-partner']);

/**
 * Compute the unified primary CTA for a variant. Resolution order:
 *   1. explicit `primaryCta` (variant → root)
 *   2. legacy `acquisition` (paid) — folded into the same model
 *   3. `download` if resolved downloadFiles is non-empty (url filled in later, once the
 *      files are copied and their download URLs are known)
 *   4. `docs` if a Documentation tab resolves for this variant (local doc file,
 *      documentationLinks entry, or legacy externalDocsUrl) — no `url` is attached:
 *      the "docs" CTA switches to the in-page Documentation tab, it never opens a link.
 *   5. none
 * `resolved` is the partially-built _resolved object (downloadFiles, documentationLinks,
 * externalDocsUrl, acquisition already populated). `hasLocalDoc` reflects whether
 * resolveVariantDocPath() found a DOCS-{suffix}.md/documentationFile/DOCUMENTATION.md
 * on disk — the same signal the MDX generator uses to decide whether to emit the
 * Documentation tab at all, so the two stay in lockstep. Returns null when nothing applies.
 */
function resolvePrimaryCta(variant, resolved, root, hasLocalDoc, downloadsEnabled = true) {
    const applyLabel = (cta) => {
        if (!cta.label) cta.label = DEFAULT_CTA_LABELS[cta.type] || 'Learn More';
        return cta;
    };

    // 1. Explicit primaryCta wins.
    const explicit = variant.primaryCta ?? root?.primaryCta;
    if (explicit && explicit.type) {
        if (explicit.type === 'link' && !explicit.url) {
            console.warn(`⚠️  primaryCta type "link" requires a url — ignoring for product "${variant.product}"`);
        } else if (explicit.type === 'download' && !downloadsEnabled) {
            // Downloads are admin-disabled — fall through rather than point at a tab with no buttons.
        } else {
            return applyLabel({ ...explicit });
        }
    }

    // 2. Legacy paid acquisition → unified CTA.
    if (resolved.acquisition && resolved.acquisition.type) {
        const acq = resolved.acquisition;
        return applyLabel({
            type: acq.type,
            ...(acq.label ? { label: acq.label } : {}),
            ...(acq.url ? { url: acq.url } : {}),
            ...(acq.description ? { description: acq.description } : {}),
        });
    }

    // 3. Download — url is stitched in after downloadFiles are copied (see copy step).
    if (resolved.downloadFiles && resolved.downloadFiles.length > 0) {
        return applyLabel({ type: 'download' });
    }

    // 4. Docs — a local doc file, a documentationLinks entry, or a legacy externalDocsUrl.
    const hasDocSignal = hasLocalDoc || resolved.documentationLinks?.length > 0 || !!resolved.externalDocsUrl;
    if (hasDocSignal) {
        return applyLabel({ type: 'docs' });
    }

    return null;
}

/**
 * Resolve variant fields with fallback chain
 */
// A product can only have one company behind its support contact, so supportUrl/supportEmail
// resolve as a single unit: a variant setting either one fully overrides root (both of root's
// fields are ignored), and supportUrl wins if a single level sets both.
function resolveSupportContact(variant, root) {
    if (variant?.supportUrl) return { supportUrl: variant.supportUrl, supportEmail: undefined };
    if (variant?.supportEmail) return { supportUrl: undefined, supportEmail: variant.supportEmail };
    if (root?.supportUrl) return { supportUrl: root.supportUrl, supportEmail: undefined };
    if (root?.supportEmail) return { supportUrl: undefined, supportEmail: root.supportEmail };
    return { supportUrl: undefined, supportEmail: undefined };
}

function resolveVariantFields(variant, root, hasLocalDoc, downloadsEnabled = true) {
    const resolved = {
        support: variant.support ?? root?.support ?? 'Unknown',
        currentVersion: variant.currentVersion ?? root?.currentVersion ?? '1.0.0',
        author: variant.author ?? root?.author ?? 'Unknown',
        ...resolveSupportContact(variant, root),
        externalDocsUrl: variant.externalDocsUrl ?? root?.externalDocsUrl,
        externalDocsLabel: variant.externalDocsLabel ?? root?.externalDocsLabel ?? 'Documentation',
        description: variant.description ?? root?.description,
        price: variant.price ?? root?.price ?? 'Free',
        acquisition: variant.acquisition ?? root?.acquisition,
        // Paid-support pair: same variant->root resolution as price/acquisition, but never
        // folded into primaryCta — it's a second, independent CTA slot rendered directly by
        // IntegrationDetail's Info section, not by <PrimaryCTA>.
        supportPrice: variant.supportPrice ?? root?.supportPrice ?? 'Free',
        supportAcquisition: variant.supportAcquisition ?? root?.supportAcquisition,
        // Documentation links are per-product by nature — a shared link would render the same
        // URL under three different products — so these are read from the variant only and
        // deliberately do not fall back to the root. The legacy externalDocsUrl above *does*
        // resolve through the full chain; callers convert it.
        documentationLinks: variant.documentationLinks ?? [],
        // downloadFiles is variant-scopable: an explicit [] on a variant suppresses its
        // download (nullish-coalescing preserves [], only null/undefined falls through).
        downloadFiles: variant.downloadFiles ?? root?.downloadFiles ?? [],
    };

    // Admin-disabled downloads: keep the list aside (for the missing-file check and the
    // Release Notes notice) and resolve as if the variant had none.
    if (!downloadsEnabled && resolved.downloadFiles.length > 0) {
        resolved.suppressedDownloadFiles = resolved.downloadFiles;
        resolved.downloadFiles = [];
        // Shipped to the client (unlike the file list) so the detail page can show banners
        // placed on "downloads-disabled" (see MarketplaceAnnouncements).
        resolved.downloadsDisabled = true;
    }

    resolved.primaryCta = resolvePrimaryCta(variant, resolved, root, hasLocalDoc, downloadsEnabled);

    return resolved;
}

async function generateGalleryData() {
    const gallery = [];
    const productsByFolder = {}; // for warnUnknownDownloadsConfigKeys
    const integrationDates = loadIntegrationDates();

    if (!fs.existsSync(path.dirname(outputJsonPath))) {
        fs.mkdirSync(path.dirname(outputJsonPath), { recursive: true });
    }
    if (!fs.existsSync(outputDocsDir)) {
        fs.mkdirSync(outputDocsDir, { recursive: true });
    }

    // Remove only this generator's per-build UUID folders. Other build steps also write here
    // (copy-openapi-specs.js -> static/downloads/openapi/), and a full wipe deleted their output.
    fs.mkdirSync(downloadsBaseDir, { recursive: true });
    for (const entry of fs.readdirSync(downloadsBaseDir)) {
        if (UUID_DIR.test(entry)) {
            fs.rmSync(path.join(downloadsBaseDir, entry), { recursive: true, force: true });
        }
    }

    const folders = fs.readdirSync(integrationsDir).filter((file) => {
        return !file.startsWith('.') && fs.statSync(path.join(integrationsDir, file)).isDirectory();
    });

    for (const folder of folders) {
        const intPath = path.join(integrationsDir, folder);
        const metadataPath = path.join(intPath, "integration_metadata.json");
        const readmePath = path.join(intPath, "README.md");
        const releaseNotesDir = path.join(intPath, "ReleaseNotes");

        if (fs.existsSync(metadataPath)) {
            const rawData = fs.readFileSync(metadataPath);
            let metadata = JSON.parse(rawData);

            // Normalize metadata for backward compatibility
            metadata = normalizeMetadata(metadata);
            productsByFolder[folder] = new Set((metadata.productVariants ?? []).map((v) => v.product));

            metadata.lastUpdated = resolveLastUpdated(metadata, folder, integrationDates);

            // A name with no ASCII letters or digits (e.g. Japanese) would strip to "", so fall
            // back to the folder name. Existing ids are unchanged.
            const routeId = metadata.name.replace(/[^a-zA-Z0-9]/g, "") || folder.replace(/[^a-zA-Z0-9]/g, "");

            // Process main logo
            if (metadata.logoFile) {
                const logoSrcPath = path.join(intPath, metadata.logoFile);
                if (fs.existsSync(logoSrcPath)) {
                    if (!fs.existsSync(logoDestDir)) {
                        fs.mkdirSync(logoDestDir, { recursive: true });
                    }
                    const logoExt = path.extname(metadata.logoFile);
                    const outputPath = path.join(logoDestDir, `${routeId}${logoExt}`);

                    // Normalize logo with Sharp instead of copying
                    const success = await normalizeLogo(logoSrcPath, outputPath);
                    metadata.logoUrl = success ? `/img/integrations/${routeId}${logoExt}` : '/img/integration-fallback.svg';
                } else {
                    metadata.logoUrl = '/img/integration-fallback.svg';
                }
            } else {
                metadata.logoUrl = '/img/integration-fallback.svg';
            }

            // Process dark mode logo
            if (metadata.logoFileDark) {
                const darkSrcPath = path.join(intPath, metadata.logoFileDark);
                if (fs.existsSync(darkSrcPath)) {
                    if (!fs.existsSync(logoDestDir)) {
                        fs.mkdirSync(logoDestDir, { recursive: true });
                    }
                    const darkExt = path.extname(metadata.logoFileDark);
                    const outputPath = path.join(logoDestDir, `${routeId}-dark${darkExt}`);

                    // Normalize dark logo with Sharp instead of copying
                    const success = await normalizeLogo(darkSrcPath, outputPath);
                    metadata.logoUrlDark = success ? `/img/integrations/${routeId}-dark${darkExt}` : metadata.logoUrl;
                } else {
                    metadata.logoUrlDark = metadata.logoUrl;
                }
            } else {
                // If no dark logo specified, reuse light logo (or fallback if no light logo either)
                metadata.logoUrlDark = metadata.logoUrl;
            }

            // --- Process resource files: copy local files to static/resources/<routeId>/ ---
            const resourcesDestDir = path.join(__dirname, 'static', 'resources', routeId);

            if (metadata.productVariants) {
                metadata.productVariants.forEach(variant => {
                    if (variant.resources) {
                        // Helper function to process URLs (convert local paths to static URLs)
                        const processResourceUrl = (url) => {
                            if (!url || url.startsWith('http://') || url.startsWith('https://')) {
                                return url; // External URL, no processing needed
                            }

                            // Local file path - copy to static directory
                            const srcPath = path.join(intPath, url);
                            if (fs.existsSync(srcPath)) {
                                // Create resources directory if it doesn't exist
                                if (!fs.existsSync(resourcesDestDir)) {
                                    fs.mkdirSync(resourcesDestDir, { recursive: true });
                                }

                                // Copy file with original filename
                                const filename = path.basename(url);
                                const destPath = path.join(resourcesDestDir, filename);
                                fs.copyFileSync(srcPath, destPath);

                                // Return static URL (human-readable, stable between builds)
                                return `/resources/${routeId}/${encodeURIComponent(filename)}`;
                            }

                            console.warn(`⚠️  Resource file not found: ${url} in ${folder}`);
                            return url; // Return original if file not found
                        };

                        // Process video thumbnails
                        if (variant.resources.videos) {
                            variant.resources.videos = variant.resources.videos.map(video => ({
                                ...video,
                                thumbnailUrl: video.thumbnailUrl ? processResourceUrl(video.thumbnailUrl) : video.thumbnailUrl
                            }));
                        }

                        // Process solution guide URLs
                        if (variant.resources.solutionGuides) {
                            variant.resources.solutionGuides = variant.resources.solutionGuides.map(guide => ({
                                ...guide,
                                url: processResourceUrl(guide.url)
                            }));
                        }

                        // Other resources may also be local files (e.g. a partner-brief PDF
                        // sitting next to the manifest), so they need the same rewrite.
                        if (variant.resources.otherResources) {
                            variant.resources.otherResources = variant.resources.otherResources.map(res => ({
                                ...res,
                                url: processResourceUrl(res.url)
                            }));
                        }

                        // External links are always external, no processing needed
                    }

                    // Local doc file, if any — computed once here and reused verbatim below
                    // when building the Documentation tab, so the tab and the "docs" CTA
                    // never disagree about whether documentation exists for this variant.
                    const suffix = getProductSuffix(variant.product);
                    variant._docPath = resolveVariantDocPath(intPath, suffix, variant);

                    // Resolve variant fields with fallback chain
                    variant._resolved = resolveVariantFields(
                        variant, metadata, !!variant._docPath, isDownloadEnabled(folder, variant.product)
                    );

                    // Release Notes tab content — computed once here (reusing `suffix`) and
                    // reused verbatim both for the needsTabs/import check and the tab emission
                    // below, so the two never disagree about whether this variant has notes.
                    variant._resolved.releaseNotesBlock = buildReleaseNotes(releaseNotesDir, suffix);
                });

                // Top-level `author` is a flat legacy field consumed by the grid card, CSV
                // export, and search filters — none of which are variant-aware. Backfill it
                // (and a distinct `authors` list, for products developed by different vendors
                // per variant, e.g. a partner builds Self-Hosted but Venafi builds SaaS/NGTS)
                // from the same fallback chain the per-variant sidebar already uses, so those
                // flat consumers stop showing "Unknown"/blank or a single wrong developer.
                const authorSet = new Set();
                metadata.productVariants.forEach((variant) => {
                    const a = variant._resolved?.author;
                    if (a && a !== 'Unknown') authorSet.add(a);
                });
                if (authorSet.size > 0) {
                    metadata.authors = Array.from(authorSet);
                    metadata.author = metadata.authors.join(', ');
                }
            }

            // Process GLOBAL resources (same logic as variant resources)
            if (metadata.resources) {
                const resourcesDestDir = path.join(__dirname, 'static', 'resources', routeId);

                const processResourceUrl = (url) => {
                    if (!url || url.startsWith('http://') || url.startsWith('https://')) {
                        return url; // External URL, no processing needed
                    }

                    // Local file path - copy to static directory
                    const srcPath = path.join(intPath, url);
                    if (fs.existsSync(srcPath)) {
                        // Create resources directory if it doesn't exist
                        if (!fs.existsSync(resourcesDestDir)) {
                            fs.mkdirSync(resourcesDestDir, { recursive: true });
                        }

                        // Copy file with original filename
                        const filename = path.basename(url);
                        const destPath = path.join(resourcesDestDir, filename);
                        fs.copyFileSync(srcPath, destPath);

                        // Return static URL (human-readable, stable between builds)
                        return `/resources/${routeId}/${encodeURIComponent(filename)}`;
                    }

                    console.warn(`⚠️  Global resource file not found: ${url} in ${folder}`);
                    return url; // Return original if file not found
                };

                // Process global video thumbnails
                if (metadata.resources.videos) {
                    metadata.resources.videos = metadata.resources.videos.map(video => ({
                        ...video,
                        thumbnailUrl: video.thumbnailUrl ? processResourceUrl(video.thumbnailUrl) : video.thumbnailUrl
                    }));
                }

                // Process global solution guides
                if (metadata.resources.solutionGuides) {
                    metadata.resources.solutionGuides = metadata.resources.solutionGuides.map(guide => ({
                        ...guide,
                        url: processResourceUrl(guide.url)
                    }));
                }

                // Other resources may also be local files (e.g. a partner-brief PDF sitting
                // next to the manifest), so they need the same rewrite.
                if (metadata.resources.otherResources) {
                    metadata.resources.otherResources = metadata.resources.otherResources.map(res => ({
                        ...res,
                        url: processResourceUrl(res.url)
                    }));
                }

                // External links are always external, no processing needed
            }

            // --- downloadFiles: copy published assets to static/downloads/<UUID>/ for security ---
            // downloadFiles is now variant-scopable. Copy the *union* of the top-level list and
            // every variant's resolved downloadFiles into one per-integration UUID dir, then hand
            // each variant only its own download URLs. A file shared across variants is copied
            // once and reused via the filename→url map.
            // The top-level list is not added directly: every variant already resolves through
            // it, and adding it would publish files for variants whose downloads are disabled.
            const downloadFileUnion = new Set();
            if (metadata.productVariants) {
                metadata.productVariants.forEach((variant) => {
                    (variant._resolved?.downloadFiles ?? []).forEach((f) => downloadFileUnion.add(f));
                    // Disabled downloads are not copied, but still flag missing files so the
                    // contributor finds out before an admin re-enables them.
                    (variant._resolved?.suppressedDownloadFiles ?? []).forEach((f) => {
                        if (!fs.existsSync(path.join(intPath, f))) {
                            console.warn(`⚠️  download file not found: ${f} in ${folder}`);
                        }
                    });
                });
            }

            const downloadUrlMap = {}; // filename -> { name, url }
            if (downloadFileUnion.size > 0) {
                const downloadUuid = uuidv4();
                const downloadsDestDir = path.join(downloadsBaseDir, downloadUuid);
                fs.mkdirSync(downloadsDestDir, { recursive: true });
                for (const filename of downloadFileUnion) {
                    const src = path.join(intPath, filename);
                    if (fs.existsSync(src)) {
                        fs.copyFileSync(src, path.join(downloadsDestDir, filename));
                        downloadUrlMap[filename] = {
                            name: filename,
                            url: `/downloads/${downloadUuid}/${encodeURIComponent(filename)}`,
                        };
                    } else {
                        console.warn(`⚠️  download file not found: ${filename} in ${folder}`);
                    }
                }
            }

            // Give each variant its own downloadUrls, and point a download CTA at the first one.
            if (metadata.productVariants) {
                metadata.productVariants.forEach((variant) => {
                    const files = variant._resolved?.downloadFiles ?? [];
                    const urls = files.map((f) => downloadUrlMap[f]).filter(Boolean);
                    variant._resolved.downloadUrls = urls;
                    const cta = variant._resolved.primaryCta;
                    if (cta && cta.type === 'download' && !cta.url && urls.length > 0) {
                        cta.url = urls[0].url;
                    }
                });
            }

            // --- documentationFile: read secondary markdown for Documentation tab ---
            let documentationContent = null;
            if (metadata.documentationFile) {
                const docPath = path.join(intPath, metadata.documentationFile);
                if (fs.existsSync(docPath)) {
                    let rawDoc = fs.readFileSync(docPath, "utf8")
                        .replace(/^#[^\n]*\n?/, "").trimStart();

                    // Rewrite relative asset paths (images + documents): copy to static and update URLs
                    const docAssetsDestDir = path.join(logoDestDir, routeId + "-docs");
                    const DOC_EXTS = new Set(['.pdf', '.zip', '.docx', '.doc', '.txt', '.csv']);

                    // Images: ![alt](path)
                    rawDoc = rawDoc.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, (match, alt, imgPath) => {
                        if (imgPath.startsWith("http") || imgPath.startsWith("/") || imgPath.startsWith("data:")) {
                            return match;
                        }
                        const cleanPath = imgPath.replace(/^\.\//, "");
                        const srcPath = path.join(intPath, cleanPath);
                        if (fs.existsSync(srcPath)) {
                            const flatName = cleanPath.replace(/[/\\]/g, "-");
                            fs.mkdirSync(docAssetsDestDir, { recursive: true });
                            fs.copyFileSync(srcPath, path.join(docAssetsDestDir, flatName));
                            return `![${alt}](/img/integrations/${routeId}-docs/${flatName})`;
                        }
                        return alt ? `*[image: ${alt}]*` : "";
                    });

                    // Document links: [text](file.pdf) etc.
                    rawDoc = rawDoc.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (match, text, linkPath) => {
                        if (linkPath.startsWith("http") || linkPath.startsWith("/") || linkPath.startsWith("#")) {
                            return match;
                        }
                        const ext = path.extname(linkPath).toLowerCase();
                        if (!DOC_EXTS.has(ext)) return match; // let markdown/html links pass through
                        const cleanPath = linkPath.replace(/^\.\//, "");
                        const srcPath = path.join(intPath, cleanPath);
                        if (fs.existsSync(srcPath)) {
                            const flatName = cleanPath.replace(/[/\\]/g, "-");
                            fs.mkdirSync(docAssetsDestDir, { recursive: true });
                            fs.copyFileSync(srcPath, path.join(docAssetsDestDir, flatName));
                            return `[${text}](/img/integrations/${routeId}-docs/${flatName})`;
                        }
                        // File not found — render as plain text
                        return text;
                    });

                    documentationContent = sanitizeMDX(rawDoc);
                }
            }

            metadata.routeId = routeId;
            gallery.push(metadata);

            // --- productVariants: per-product content switching ---
            const hasProductVariants =
                metadata.productVariants && metadata.productVariants.length > 0;

            // Downloads are now per-variant: any variant with resolved downloadUrls needs the
            // DownloadButton import, and only that variant gets download buttons in its
            // Release Notes tab.
            const anyVariantHasDownloads = metadata.productVariants?.some(
                (v) => (v._resolved?.downloadUrls?.length ?? 0) > 0
            ) || false;

            // Release Notes are also per-variant: any variant with a non-empty resolved
            // releaseNotesBlock needs the tabs imports, and only that variant emits the tab.
            const anyVariantHasReleaseNotes = metadata.productVariants?.some(
                (v) => !!v._resolved?.releaseNotesBlock
            ) || false;

            // Determine imports needed
            let needsTabs = false;
            let needsExternalDocs = false;

            if (hasProductVariants) {
                needsTabs = metadata.productVariants.some((v) => {
                    // Read through _resolved/_docPath for the same reason needsExternalDocs does
                    // below: an externalDocsUrl declared only at the root still produces a
                    // Documentation tab at emit time, so the raw variant fields
                    // under-report and the IntegrationTabs/IntegrationTabItem imports get
                    // omitted — an MDX build failure ("Expected component IntegrationTabItem to
                    // be defined"), not a silent one. v._docPath (not the raw documentationFile
                    // field) is what the emission loop actually uses — it also resolves a bare
                    // DOCUMENTATION.md on disk even when documentationFile isn't set, which is
                    // always true for the variant normalizeMetadata() synthesizes for legacy
                    // single-product metadata with no explicit productVariants.
                    const hasDocumentation = !!v._docPath
                        || v._resolved?.externalDocsUrl
                        || (v._resolved?.documentationLinks?.length > 0);
                    const hasResources = v.resources && (
                        v.resources.videos?.length > 0 ||
                        v.resources.otherResources?.length > 0 ||
                        v.resources.solutionGuides?.length > 0 ||
                        v.resources.externalLinks?.length > 0
                    );
                    const hasVariantDownloads = (v._resolved?.downloadUrls?.length ?? 0) > 0;
                    const hasReleaseNotes = !!v._resolved?.releaseNotesBlock;
                    return hasDocumentation || hasResources || hasVariantDownloads || hasReleaseNotes;
                });
                // Check if any variant needs DocumentationTab component
                needsExternalDocs = metadata.productVariants.some((v) => {
                    // Read through _resolved so a URL declared only at the root still counts —
                    // otherwise the DocumentationTab import is omitted and the link is dropped.
                    const hasDocLinks = (v._resolved?.documentationLinks?.length > 0) || v._resolved?.externalDocsUrl;
                    return hasDocLinks || v.documentationFile;
                });
            } else {
                needsTabs = !!documentationContent || !!metadata.externalDocsUrl || anyVariantHasDownloads || anyVariantHasReleaseNotes;
                needsExternalDocs = !!documentationContent || !!metadata.externalDocsUrl;
            }

            let imports = `import IntegrationDetail from '@site/src/components/IntegrationDetail';`;
            if (hasProductVariants) {
                imports += `\nimport ProductVariant from '@site/src/components/ProductVariant';`;
            }
            if (needsTabs) {
                imports += `\nimport IntegrationTabs from '@site/src/components/IntegrationTabs';`;
                imports += `\nimport IntegrationTabItem from '@site/src/components/IntegrationTabItem';`;
            }
            if (anyVariantHasDownloads) {
                imports += `\nimport DownloadButton from '@site/src/components/DownloadButton';`;
            }
            if (needsExternalDocs) {
                imports += `\nimport DocumentationTab from '@site/src/components/DocumentationTab';`;
            }
            // Check for resources and add ResourcesTab import (global OR variant)
            const hasGlobalResources = metadata.resources && (
                metadata.resources.videos?.length > 0 ||
                metadata.resources.solutionGuides?.length > 0 ||
                metadata.resources.externalLinks?.length > 0 ||
                metadata.resources.otherResources?.length > 0
            );
            const hasVariantResources = metadata.productVariants?.some(v =>
                v.resources && (
                    v.resources.videos?.length > 0 ||
                    v.resources.solutionGuides?.length > 0 ||
                    v.resources.externalLinks?.length > 0 ||
                    v.resources.otherResources?.length > 0
                )
            );
            if (hasGlobalResources || hasVariantResources) {
                imports += `\nimport ResourcesTab from '@site/src/components/ResourcesTab';`;
            }

            // Downloads no longer get their own tab — they're attached to the newest entry of
            // the Release Notes tab (see buildReleaseNotes's downloadButtonsMarkup param), GitHub
            // Releases style. This just builds the button markup, per-variant, from each
            // variant's own resolved downloadUrls.
            const buildDownloadButtonsMarkup = (downloadUrls) => {
                if (!downloadUrls || downloadUrls.length === 0) return "";
                return downloadUrls.map((s) =>
                    `<DownloadButton filename="${s.name}" url="${s.url}" />`
                ).join("\n\n");
            };

            let pageContent = `---
id: ${routeId}
title: ${metadata.name}
sidebar_label: ${metadata.name}
slug: /marketplace/${routeId}
displayed_sidebar: null
pagination_prev: null
pagination_next: null
hide_table_of_contents: true
hide_title: true
---

${imports}

<IntegrationDetail id="${routeId}">

`;

            if (hasProductVariants) {
                // Generate one <ProductVariant> block per variant
                metadata.productVariants.forEach((variant) => {
                    pageContent += `<ProductVariant product="${variant.product}">\n\n`;

                    // Overview content for this variant — strip leading h1 (title shown by component)
                    let variantOverview = "";

                    // Auto-detect overview file: OVERVIEW-{suffix}.md > variant.overviewFile > README.md
                    const suffix = getProductSuffix(variant.product);
                    const autoOverviewPath = path.join(intPath, `OVERVIEW-${suffix}.md`);
                    const explicitOverviewPath = variant.overviewFile ? path.join(intPath, variant.overviewFile) : null;
                    const fallbackReadmePath = path.join(intPath, 'README.md');

                    let variantReadmePath = null;
                    if (fs.existsSync(autoOverviewPath)) {
                        variantReadmePath = autoOverviewPath;
                    } else if (explicitOverviewPath && fs.existsSync(explicitOverviewPath)) {
                        variantReadmePath = explicitOverviewPath;
                    } else if (fs.existsSync(fallbackReadmePath)) {
                        variantReadmePath = fallbackReadmePath;
                    }

                    if (variantReadmePath) {
                        const rawVariantReadme = fs.readFileSync(variantReadmePath, "utf8")
                            .replace(/^#[^\n]*\n?/, "").trimStart();
                        variantOverview += sanitizeMDX(rawVariantReadme) + "\n\n";
                    } else {
                        variantOverview += `*No overview documentation provided for this product.*\n\n`;
                    }

                    // Release notes now render in their own tab (see hasReleaseNotes below),
                    // not appended to the Overview text — reuse the value already resolved
                    // above so the needsTabs check and this emission never disagree.
                    const releaseNotesBlock = variant._resolved?.releaseNotesBlock || '';
                    const hasReleaseNotes = !!releaseNotesBlock;

                    // Variant-specific documentation tab
                    let variantDoc = null;

                    // Reuse the path resolved earlier (alongside _resolved.primaryCta) rather
                    // than re-running the DOCS-{suffix}.md/documentationFile/DOCUMENTATION.md
                    // auto-detect here — a second, independent detection could drift out of
                    // sync with what primaryCta inference decided.
                    const variantDocPath = variant._docPath;

                    if (variantDocPath) {
                        let rawDoc = fs.readFileSync(variantDocPath, "utf8");
                        // Strip frontmatter first
                        rawDoc = stripFrontmatter(rawDoc);
                        // Then strip leading h1 heading
                        rawDoc = rawDoc.replace(/^#[^\n]*\n?/, "").trimStart();
                        const docAssetsDestDir = path.join(logoDestDir, routeId + "-docs");
                        const DOC_EXTS = new Set(['.pdf', '.zip', '.docx', '.doc', '.txt', '.csv']);
                        rawDoc = rawDoc.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, (match, alt, imgPath) => {
                            if (imgPath.startsWith("http") || imgPath.startsWith("/") || imgPath.startsWith("data:")) return match;
                            const cleanPath = imgPath.replace(/^\.\//, "");
                            const srcPath = path.join(intPath, cleanPath);
                            if (fs.existsSync(srcPath)) {
                                const flatName = cleanPath.replace(/[/\\]/g, "-");
                                fs.mkdirSync(docAssetsDestDir, { recursive: true });
                                fs.copyFileSync(srcPath, path.join(docAssetsDestDir, flatName));
                                return `![${alt}](/img/integrations/${routeId}-docs/${flatName})`;
                            }
                            return alt ? `*[image: ${alt}]*` : "";
                        });
                        rawDoc = rawDoc.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (match, text, linkPath) => {
                            if (linkPath.startsWith("http") || linkPath.startsWith("/") || linkPath.startsWith("#")) return match;
                            const ext = path.extname(linkPath).toLowerCase();
                            if (!DOC_EXTS.has(ext)) return match;
                            const cleanPath = linkPath.replace(/^\.\//, "");
                            const srcPath = path.join(intPath, cleanPath);
                            if (fs.existsSync(srcPath)) {
                                const flatName = cleanPath.replace(/[/\\]/g, "-");
                                fs.mkdirSync(docAssetsDestDir, { recursive: true });
                                fs.copyFileSync(srcPath, path.join(docAssetsDestDir, flatName));
                                return `[${text}](/img/integrations/${routeId}-docs/${flatName})`;
                            }
                            return text;
                        });
                        variantDoc = sanitizeMDX(rawDoc);
                    }

                    // Process documentation links
                    let documentationLinks = variant._resolved?.documentationLinks ?? variant.documentationLinks ?? [];

                    // Backward compatibility: convert legacy externalDocsUrl to documentationLinks.
                    // Resolve through _resolved, not the raw variant — a manifest that declares
                    // externalDocsUrl only at the root alongside explicit productVariants would
                    // otherwise lose its only documentation link entirely.
                    if (!documentationLinks || documentationLinks.length === 0) {
                        const legacyUrl = variant._resolved?.externalDocsUrl ?? variant.externalDocsUrl;
                        const legacyLabel = variant._resolved?.externalDocsLabel ?? variant.externalDocsLabel ?? 'Documentation';

                        if (legacyUrl) {
                            documentationLinks = [{
                                title: legacyLabel,
                                url: legacyUrl
                            }];

                            console.warn(`[${metadata.name}] Product "${variant.product}" uses deprecated externalDocsUrl. Migrate to documentationLinks array.`);
                        }
                    }

                    // Check if this variant has documentation (embedded or external)
                    const hasDocumentation = variantDoc || (documentationLinks && documentationLinks.length > 0);

                    // Check for global resources
                    const hasGlobalResources = metadata.resources &&
                        (metadata.resources.videos?.length > 0 ||
                         metadata.resources.solutionGuides?.length > 0 ||
                         metadata.resources.externalLinks?.length > 0);

                    // Check if this variant has resources
                    const hasVariantResources = variant.resources &&
                        (variant.resources.videos?.length > 0 ||
                         variant.resources.solutionGuides?.length > 0 ||
                         variant.resources.externalLinks?.length > 0);

                    const hasAnyResources = hasGlobalResources || hasVariantResources;

                    // Downloads attach to the newest Release Notes entry (see buildReleaseNotes)
                    // rather than getting their own tab. Recompute the block here — a cheap
                    // directory read — now that downloadUrls are resolved; the releaseNotesBlock/
                    // hasReleaseNotes above (no download markup) exist only for the has-notes
                    // check and stay untouched.
                    const downloadButtonsMarkup = variant._resolved?.suppressedDownloadFiles
                        ? DOWNLOADS_DISABLED_NOTICE
                        : buildDownloadButtonsMarkup(variant._resolved?.downloadUrls);
                    let releaseNotesTabContent = buildReleaseNotes(releaseNotesDir, suffix, downloadButtonsMarkup);
                    if (!releaseNotesTabContent && downloadButtonsMarkup) {
                        // Defensive fallback: every integration is expected to have a release
                        // note (validate-integration.js errors otherwise), but never silently
                        // drop a download if one is somehow still missing.
                        releaseNotesTabContent = `### Version ${variant._resolved?.currentVersion ?? '1.0.0'}\n\n${downloadButtonsMarkup}\n\n`;
                    }
                    const hasReleaseNotesTab = !!releaseNotesTabContent;

                    if (hasDocumentation || hasAnyResources || hasReleaseNotesTab) {
                        pageContent += `<IntegrationTabs>\n<IntegrationTabItem value="overview" label="Overview" default>\n\n`;
                        pageContent += variantOverview;
                        pageContent += `\n</IntegrationTabItem>\n`;

                        // Documentation tab
                        if (hasDocumentation) {
                            pageContent += `<IntegrationTabItem value="documentation" label="Documentation">\n\n`;

                            // Render embedded documentation as markdown (if it exists)
                            if (variantDoc) {
                                pageContent += variantDoc + '\n\n';

                                // If there are also external links, add a separator and render them
                                if (documentationLinks && documentationLinks.length > 0) {
                                    pageContent += `---\n\n## External Documentation\n\n`;
                                    pageContent += `<DocumentationTab documentationLinks={${JSON.stringify(documentationLinks)}} />\n\n`;
                                }
                            } else if (documentationLinks && documentationLinks.length > 0) {
                                // Only external documentation links
                                pageContent += `<DocumentationTab documentationLinks={${JSON.stringify(documentationLinks)}} />\n\n`;
                            }

                            pageContent += `</IntegrationTabItem>\n`;
                        }
                        // Add Resources tab if global or variant resources exist
                        if (hasAnyResources) {
                            // Merge global + variant resources with backward compatibility
                            const videos = [
                                ...(metadata.resources?.videos ?? []),
                                ...(variant.resources?.videos ?? [])
                            ];

                            // Consolidate otherResources (new structure) with legacy solutionGuides/externalLinks
                            const otherResources = [
                                // New structure
                                ...(metadata.resources?.otherResources ?? []),
                                ...(variant.resources?.otherResources ?? []),
                                // Legacy structure (auto-convert)
                                ...(metadata.resources?.solutionGuides?.map(g => ({ ...g, resourceType: 'file' })) ?? []),
                                ...(variant.resources?.solutionGuides?.map(g => ({ ...g, resourceType: 'file' })) ?? []),
                                ...(metadata.resources?.externalLinks?.map(l => ({ ...l, resourceType: 'link' })) ?? []),
                                ...(variant.resources?.externalLinks?.map(l => ({ ...l, resourceType: 'link' })) ?? [])
                            ];

                            const mergedResources = { videos, otherResources };

                            // Deprecation warnings
                            if (metadata.resources?.solutionGuides || variant.resources?.solutionGuides) {
                                console.warn(`[${metadata.name}] Uses deprecated solutionGuides. Migrate to otherResources array.`);
                            }
                            if (metadata.resources?.externalLinks || variant.resources?.externalLinks) {
                                console.warn(`[${metadata.name}] Uses deprecated externalLinks. Migrate to otherResources array.`);
                            }

                            pageContent += `<IntegrationTabItem value="resources" label="Resources">\n\n`;
                            pageContent += `<ResourcesTab resources={${JSON.stringify(mergedResources)}} />\n\n`;
                            pageContent += `</IntegrationTabItem>\n\n`;
                        }
                        // Release Notes tab — now the only place downloads render too (see
                        // releaseNotesTabContent above), so there's no separate Downloads tab
                        // to order around any more.
                        if (hasReleaseNotesTab) {
                            pageContent += `<IntegrationTabItem value="release-notes" label="Release Notes">\n\n`;
                            pageContent += releaseNotesTabContent + '\n\n';
                            pageContent += `</IntegrationTabItem>\n\n`;
                        }
                        pageContent += `</IntegrationTabs>\n\n`;
                    } else {
                        pageContent += `<div className="integration-content-card">\n\n`;
                        pageContent += variantOverview;
                        pageContent += `\n</div>\n\n`;
                    }

                    pageContent += `</ProductVariant>\n\n`;
                });
            } else {
                // Unreachable: normalizeMetadata() always synthesizes at least one
                // productVariant, so hasProductVariants is never false. The old single-product
                // path that lived here emitted <ExternalDocsButton>, which the import block
                // above never imports — it would have been an MDX build failure the moment
                // anyone removed that fallback. Fail loudly instead of emitting a broken page.
                throw new Error(
                    `[${metadata.name}] No productVariants after normalizeMetadata(). ` +
                    `This invariant is relied on by the MDX generator — see normalizeMetadata().`
                );
            }

            pageContent += "\n</IntegrationDetail>\n";

            fs.writeFileSync(
                path.join(outputDocsDir, `${routeId}.mdx`),
                pageContent,
            );
            console.log(`✅ Generated sanitized page for: ${metadata.name}`);
        }
    }

    warnUnknownDownloadsConfigKeys(productsByFolder);

    // downloadUrls holds per-build UUID download paths, used only while emitting MDX
    // (<DownloadButton>). No component reads the list directly, so strip it from both the
    // top level and each variant's _resolved to keep it out of the shipped bundle. The
    // _resolved.primaryCta (which a download CTA embeds one such URL into) is kept — the
    // detail page renders it — so its churn is accepted in exchange for the unified CTA.
    const cleanGallery = gallery.map(({ downloadUrls, ...rest }) => {
        if (Array.isArray(rest.productVariants)) {
            rest.productVariants = rest.productVariants.map((v) => {
                if (v && v._resolved) {
                    const { downloadUrls: _drop, suppressedDownloadFiles: _dropSuppressed, ...resolvedRest } = v._resolved;
                    return { ...v, _resolved: resolvedRest };
                }
                return v;
            });
        }
        return rest;
    });
    fs.writeFileSync(outputJsonPath, JSON.stringify(cleanGallery, null, 2));

    pruneStalePages(cleanGallery);
    writeRouteRedirects(cleanGallery);
    console.log(`\n🚀 Successfully generated all data and markdown files!`);
}

/**
 * Delete MDX for integrations that no longer exist.
 *
 * This generator only ever writes; it never cleaned its output directory. That was harmless
 * while Integrations/ only grew, but the moment a folder is removed upstream — merged into
 * another listing, or archived — its page survives here and stays live on the site. A merged-away
 * listing would keep its own page, which defeats the merge and collides with the redirect that
 * is supposed to replace it. CI builds from a clean checkout and never saw this; local and
 * incremental builds do.
 */
function pruneStalePages(cleanGallery) {
    // Refuse to prune against an empty gallery: an unmounted or half-synced Integrations/ would
    // otherwise delete every marketplace page and look like a successful build.
    if (cleanGallery.length === 0) {
        console.warn('⚠️  Gallery is empty — skipping stale-page pruning rather than deleting every page');
        return;
    }

    const live = new Set(cleanGallery.map(i => `${i.routeId}.mdx`));
    const stale = fs.readdirSync(outputDocsDir).filter(f => f.endsWith('.mdx') && !live.has(f));
    for (const f of stale) fs.unlinkSync(path.join(outputDocsDir, f));
    if (stale.length) console.log(`🧹 Removed ${stale.length} stale marketplace page(s)`);
}

/**
 * Emit src/data/route-redirects.json for @docusaurus/plugin-client-redirects.
 *
 * Merging two listings into one retires a marketplace URL. The alias list is authored in the
 * marketplace repo as Integrations/.route-aliases.json, so it rides the same rsync as the merge
 * that caused it — the redirect can never be forgotten in a separate repo.
 *
 * Targets are validated against the routeIds actually generated this run: a typo'd survivor
 * would otherwise ship a redirect to a 404, which is worse than the original dead URL.
 */
function writeRouteRedirects(cleanGallery) {
    const outPath = path.join(__dirname, 'src/data/route-redirects.json');
    const aliasPath = path.join(integrationsDir, '.route-aliases.json');

    if (!fs.existsSync(aliasPath)) {
        fs.writeFileSync(outPath, '[]\n');
        return;
    }

    const known = new Set(cleanGallery.map(i => `/marketplace/${i.routeId}`));

    // The alias file arrives from the marketplace repo via rsync, so malformed content is an
    // upstream problem, not a reason to fail this build — ship without redirects and say so.
    let aliases;
    try {
        aliases = JSON.parse(fs.readFileSync(aliasPath, 'utf8'));
        if (!Array.isArray(aliases)) throw new Error('expected an array');
    } catch (err) {
        console.warn(`⚠️  Could not read Integrations/.route-aliases.json (${err.message}) — no redirects emitted`);
        fs.writeFileSync(outPath, '[]\n');
        return;
    }

    const valid = [];

    for (const { from, to } of aliases) {
        // '/marketplace' (the catalog index) is a legitimate target for archived listings.
        if (to !== '/marketplace' && !known.has(to)) {
            console.warn(`⚠️  Redirect target does not exist, dropping: ${from} -> ${to}`);
            continue;
        }
        if (known.has(from)) {
            console.warn(`⚠️  Redirect source is a live listing, dropping: ${from}`);
            continue;
        }
        valid.push({ from, to });
    }

    fs.writeFileSync(outPath, JSON.stringify(valid, null, 2) + '\n');
    console.log(`🔀 Wrote ${valid.length} route redirect(s) (${aliases.length - valid.length} dropped)`);
}

generateGalleryData().catch(err => {
    console.error('Fatal error generating gallery:', err);
    process.exit(1);
});
