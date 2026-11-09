export interface Video {
    title: string;
    description?: string;
    url: string; // YouTube/Vimeo URL or direct video URL
    thumbnailUrl?: string; // Optional custom thumbnail
    platform?: string; // e.g., "youtube", "vimeo", "custom"
}

export interface SolutionGuide {
    title: string;
    description?: string;
    url: string; // URL to PDF, whitepaper, or document
    type: 'pdf' | 'whitepaper' | 'doc' | 'other';
    fileSize?: string; // e.g., "2.5 MB"
    date?: string; // Publication date
}

export interface ExternalLink {
    title: string;
    description?: string;
    url: string;
    category?: string; // e.g., "Documentation", "Training", "Community"
}

export interface DocumentationLink {
    title: string;
    description?: string;
    url: string;
}

// Discriminated union for other resources
export type OtherResource =
    | (SolutionGuide & { resourceType: 'file' })
    | (ExternalLink & { resourceType: 'link' });

export interface ResourceCollection {
    videos?: Video[];

    // NEW: Unified other resources
    otherResources?: OtherResource[];

    // DEPRECATED: Use otherResources instead
    /** @deprecated Use otherResources array instead */
    solutionGuides?: SolutionGuide[];
    /** @deprecated Use otherResources array instead */
    externalLinks?: ExternalLink[];
}

/** @deprecated Superseded by {@link PrimaryCTA}. The paid-only acquisition model is now
 *  folded into the unified primaryCta at build time. */
export interface AcquisitionInfo {
    type: string;
    label?: string;
    url?: string;
    description?: string;
}

export type PrimaryCTAType =
    | 'download'
    | 'docs'
    | 'link'
    | 'contact-sales'
    | 'contact-partner';

/** Unified per-variant primary call-to-action. Replaces the paid-only AcquisitionInfo.
 *  Paid types (`contact-*`) render the "Paid Integration" badge; download/docs/link do not.
 *  `type: "link"` requires a `url`. */
export interface PrimaryCTA {
    type: PrimaryCTAType;
    label?: string;
    url?: string;
    description?: string;
}

export interface ProductVariant {
    product: string;
    overviewFile: string;
    documentationFile?: string;

    // NEW: Multiple documentation links
    documentationLinks?: DocumentationLink[];

    // NEW: Unified per-variant primary CTA
    primaryCta?: PrimaryCTA;

    // NEW: Variant-scopable download files. An explicit [] suppresses this variant's download.
    downloadFiles?: string[];

    // Variant-specific metadata (moved from root)
    support?: string;
    currentVersion?: string;
    author?: string;
    supportUrl?: string;
    supportEmail?: string;
    price?: string;
    /** @deprecated Use primaryCta instead */
    acquisition?: AcquisitionInfo;

    // Free product, paid support — independent of price/acquisition above, and never folded
    // into primaryCta (it's a second, independent CTA slot: "how to buy support", not "how to
    // buy the product").
    supportPrice?: string;
    supportAcquisition?: AcquisitionInfo;

    // DEPRECATED: Use documentationLinks instead
    /** @deprecated Use documentationLinks array instead */
    externalDocsUrl?: string;
    /** @deprecated Use documentationLinks array instead */
    externalDocsLabel?: string;

    description?: string;
    resources?: ResourceCollection;

    // Build-time resolved fields
    _resolved?: {
        support: string;
        currentVersion: string;
        author: string;
        supportUrl?: string;
        supportEmail?: string;
        externalDocsUrl?: string;
        externalDocsLabel?: string;
        documentationLinks?: DocumentationLink[];
        description: string;
        price: string;
        /** @deprecated Use primaryCta instead */
        acquisition?: AcquisitionInfo;
        supportPrice?: string;
        supportAcquisition?: AcquisitionInfo;
        primaryCta?: PrimaryCTA | null;
        downloadFiles?: string[];
        /** True when this variant ships downloadFiles but marketplace-downloads.json turns them off. */
        downloadsDisabled?: boolean;
        /** Scratch only: per-build UUID download URLs. Stripped from integrations.json. */
        downloadUrls?: { name: string; url: string }[];
    };
}

export interface IntegrationMetadata {
    name: string;
    description: string;
    /** ISO 639-1 code of the content's only language, when not English (see utils/languageLabel). */
    language?: string;
    /** Page id / slug, written by generate-gallery.js (see utils/integrationId). */
    routeId?: string;
    categories: string[];
    products: string[];
    tags: string[];
    useCases: string[];
    keywords: string[];
    logoFile?: string;
    logoFileDark?: string;
    logoUrl?: string | null;
    logoUrlDark?: string | null;

    // Global resources (new)
    resources?: ResourceCollection;

    /** Optional ISO date (YYYY-MM-DD) authored in integration_metadata.json. Overrides the
     *  git-derived date when resolving `lastUpdated`. */
    releaseDate?: string;

    // Root-level fields, shared across every product variant unless a variant overrides them.
    support?: string;
    supportUrl?: string;
    currentVersion?: string;
    author?: string;
    supportEmail?: string;
    /** @deprecated Superseded by `documentationLinks` — kept for older integrations, not needed for new ones */
    externalDocsUrl?: string;
    /** @deprecated Superseded by `documentationLinks` — kept for older integrations, not needed for new ones */
    externalDocsLabel?: string;
    price?: string;
    /** @deprecated Use primaryCta instead */
    acquisition?: AcquisitionInfo;
    supportPrice?: string;
    supportAcquisition?: AcquisitionInfo;
    /** Root-level only (no per-variant override). Display name, e.g. "MIT" or
     *  "Software Tool License Agreement". See licenseHref() in IntegrationDetail.tsx. */
    license?: string;
    /** Root-level only. Absolute https URL of the license terms. Required for any license other
     *  than "MIT"; without it the License row shows plain text with no link. */
    licenseUrl?: string;
    /** Root-level only. "tool" marks a Tools & Utilities listing; missing means "integration". */
    listingType?: 'integration' | 'tool';

    // NEW: Unified primary CTA (also valid at top level for backward-compat resolution)
    primaryCta?: PrimaryCTA;

    // Build-time generated
    /** ISO timestamp: explicit `releaseDate`, else the integration folder's last commit date
     *  in the marketplace repo. Drives the catalog's "Last update" sort. */
    lastUpdated?: string;
    documentationFile?: string;
    downloadFiles?: string[];
    downloadUrls?: {name: string; url: string}[];
    productVariants?: ProductVariant[];
    supported_by?: string;
    /** Distinct developer(s) across all product variants, resolved variant → root.
     *  Populated whenever `productVariants` exist; `author` is the comma-joined string form
     *  for flat (non-array) consumers. Use this for per-developer filtering/counting. */
    authors?: string[];
}
