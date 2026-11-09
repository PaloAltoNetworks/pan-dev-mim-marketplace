import React, { createContext, useState, useEffect } from "react";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import integrationsData from "../data/integrations.json";
import { IntegrationMetadata } from "../types";
import { SHOW_LAST_UPDATED } from "../featureFlags";
import ListBuilderSidebar from "./ListBuilderSidebar";
import RecommendedIntegrations from "./RecommendedIntegrations";
import { PrimaryCTA } from "./PrimaryCTA";
import MarketplaceAnnouncements from "./MarketplaceAnnouncements";
import { listingTypeOf, LISTING_TYPE_NAMES, ToolBadge } from "./ListingType";
import { languageOnlyLabel } from "../utils/languageLabel";
import { integrationId } from "../utils/integrationId";

const integrations = integrationsData as IntegrationMetadata[];

export const ProductContext = createContext<string>("");

// Shared active-tab state so a sibling (PrimaryCTA's "docs" banner) can switch the
// IntegrationTabs selection without an ownership/ref hookup between the two components.
export interface TabContextValue {
    activeTab: string;
    setActiveTab: (value: string) => void;
}
export const TabContext = createContext<TabContextValue>({
    activeTab: "",
    setActiveTab: () => {},
});

// A product can only have one company behind its support contact, so supportUrl/supportEmail
// resolve as a single unit: a variant setting either one fully overrides root (both of root's
// fields are ignored), and supportUrl wins if a single level sets both. Mirrors
// resolveSupportContact() in generate-gallery.js — this is the fallback path used when a
// variant has no precomputed `_resolved` (e.g. a synthesized single-product variant).
function resolveSupportContact(
    variant: { supportUrl?: string; supportEmail?: string } | undefined,
    root: { supportUrl?: string; supportEmail?: string }
) {
    if (variant?.supportUrl) return { supportUrl: variant.supportUrl, supportEmail: undefined };
    if (variant?.supportEmail) return { supportUrl: undefined, supportEmail: variant.supportEmail };
    if (root?.supportUrl) return { supportUrl: root.supportUrl, supportEmail: undefined };
    if (root?.supportEmail) return { supportUrl: undefined, supportEmail: root.supportEmail };
    return { supportUrl: undefined, supportEmail: undefined };
}

// license/licenseUrl are root-level only, so they're read straight off metadata rather than
// resolved per variant. Each listing links to its own terms (Legal guidance, 2026-11-02): PS tools
// use the PANW Software Tool License Agreement, partners MIT or their own license, community
// listings the Marketplace TOU, all via licenseUrl. A bare "MIT" keeps pointing at the
// marketplace repo's LICENSE (MIT). Any other license without a licenseUrl gets no link, so it can
// never be shown as MIT by mistake.
const MARKETPLACE_LICENSE_URL = 'https://github.com/PaloAltoNetworks/pan-dev-mim-marketplace/blob/main/LICENSE';

function licenseHref(metadata: IntegrationMetadata): string | null {
    if (metadata.licenseUrl) return metadata.licenseUrl;
    return metadata.license?.trim().toUpperCase() === 'MIT' ? MARKETPLACE_LICENSE_URL : null;
}

const PAID_SUPPORT_TOOLTIP_ID = 'paid-support-tooltip';

// The Paid Support pill. When the listing gives a supportAcquisition.description, it shows as a
// tooltip on hover or keyboard focus instead of a paragraph under the Price row. A pill with a
// url is a link (focusable on its own); a plain pill gets tabIndex=0 so keyboard and touch users
// can still reach the tooltip.
function PaidSupportBadge({ acquisition }: { acquisition?: { url?: string; label?: string; description?: string } }) {
    const description = acquisition?.description;
    const describedBy = description ? PAID_SUPPORT_TOOLTIP_ID : undefined;
    const className = "detail-info-badge detail-info-badge--paid-support";
    const badge = acquisition?.url ? (
        <a
            href={acquisition.url}
            target="_blank"
            rel="noopener noreferrer"
            className={className}
            aria-describedby={describedBy}
        >
            {acquisition.label || 'Paid Support'}
        </a>
    ) : (
        <span className={className} tabIndex={description ? 0 : undefined} aria-describedby={describedBy}>
            Paid Support
        </span>
    );
    if (!description) return badge;
    return (
        <span className="detail-info-tooltip">
            {badge}
            <span role="tooltip" id={PAID_SUPPORT_TOOLTIP_ID} className="detail-info-tooltip__bubble">
                {description}
            </span>
        </span>
    );
}

function getVariantData(
    metadata: IntegrationMetadata,
    selectedProduct: string
) {
    const variant = metadata.productVariants?.find(
        v => v.product === selectedProduct
    );

    if (variant?._resolved) {
        return variant._resolved;
    }

    return {
        support: variant?.support ?? metadata.support ?? 'Unknown',
        currentVersion: variant?.currentVersion ?? metadata.currentVersion ?? '1.0.0',
        author: variant?.author ?? metadata.author ?? 'Unknown',
        ...resolveSupportContact(variant, metadata),
        description: variant?.description ?? metadata.description,
        price: variant?.price ?? metadata.price ?? 'Free',
        acquisition: variant?.acquisition ?? metadata.acquisition,
        supportPrice: variant?.supportPrice ?? metadata.supportPrice ?? 'Free',
        supportAcquisition: variant?.supportAcquisition ?? metadata.supportAcquisition,
        primaryCta: variant?.primaryCta ?? metadata.primaryCta ?? null,
        // Only the generator knows a variant's downloads are admin-disabled (it sets _resolved).
        downloadsDisabled: false,
        downloadUrls: undefined,
    };
}

const ALL_PRODUCTS = [
    "Certificate Manager Self-Hosted",
    "Certificate Manager SaaS",
    "Next-Gen Trust Security"
];

// The gallery lives at /marketplace, not at the landing page — `/` ignores these params.
function filterLink(type: string, value: string) {
    return `/marketplace?${type}=${encodeURIComponent(value)}`;
}

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

// Formatted straight off the ISO string's date part rather than through `new Date()`.
// A bare "YYYY-MM-DD" releaseDate parses as UTC midnight and would render a day early west
// of Greenwich — and the server and browser could disagree, tripping a hydration mismatch.
function formatUpdated(iso?: string): string | null {
    const parts = /^(\d{4})-(\d{2})-(\d{2})/.exec(iso ?? "");
    if (!parts) return null;
    const month = MONTHS[Number(parts[2]) - 1];
    return month ? `${month} ${Number(parts[3])}, ${parts[1]}` : null;
}

function DetailSection({ heading, children }: { heading: string; children: React.ReactNode }) {
    return (
        <div className="detail-sidebar-section">
            <h4 className="detail-sidebar-heading">{heading}</h4>
            {children}
        </div>
    );
}

export default function IntegrationDetail({
    id,
    children,
}: {
    id: string;
    children: React.ReactNode;
}) {
    const metadata = integrations.find(
        (i) => integrationId(i) === id,
    );

    const firstProduct = metadata?.productVariants?.[0]?.product ?? ALL_PRODUCTS[0];
    const [selectedProduct, setSelectedProduct] = useState(firstProduct);
    const { siteConfig: { baseUrl } } = useDocusaurusContext();

    // Cleared on every product switch so the freshly-mounted IntegrationTabs falls back to
    // its own default tab rather than carrying over the previous variant's selection.
    const [activeTab, setActiveTab] = useState("");
    const handleProductChange = (product: string) => {
        setSelectedProduct(product);
        setActiveTab("");
    };

    // Collapsed by default. Only an explicit toggle is saved, so a visitor who never opened the
    // list keeps getting the default. The key has a -v2 suffix because the old key was written on
    // every page load, which pinned every past visitor to "expanded".
    const [listBuilderCollapsed, setListBuilderCollapsed] = useState(() => {
        if (typeof window !== 'undefined') {
            const stored = localStorage.getItem('list-builder-collapsed-detail-v2');
            return stored === null ? true : stored === 'true';
        }
        return true;
    });

    const toggleListBuilder = () => {
        const next = !listBuilderCollapsed;
        setListBuilderCollapsed(next);
        try {
            localStorage.setItem('list-builder-collapsed-detail-v2', String(next));
        } catch {
            // Storage blocked: the choice lasts for this page view only.
        }
    };

    const variantData = metadata ? getVariantData(metadata, selectedProduct) : null;
    const authorName = variantData?.author;
    const authorCount = metadata && authorName
        ? integrations.filter(i => {
            const iAuthor = i.productVariants?.[0]?.author ?? i.author;
            return iAuthor === authorName;
        }).length
        : 0;

    const supportedProducts = metadata?.productVariants?.map(v => v.product) || [ALL_PRODUCTS[0]];
    const isProductSupported = supportedProducts.includes(selectedProduct);

    // Offer only the products this integration actually supports. Listing all of ALL_PRODUCTS
    // let users pick a product and land on the "Product Not Supported" card — which many
    // listings hit, because `platforms` in the metadata frequently claims a platform that has
    // no corresponding variant. Ordered by ALL_PRODUCTS so the dropdown reads the same way on
    // every listing, with any unrecognised product appended rather than silently dropped.
    const selectableProducts = [
        ...ALL_PRODUCTS.filter(p => supportedProducts.includes(p)),
        ...supportedProducts.filter(p => !ALL_PRODUCTS.includes(p)),
    ];

    return (
        <div className="integration-detail-wrapper">
            <div className="integration-detail-header">
                {metadata && (
                    <h1 className="integration-detail-title">
                        {metadata.name}
                        {listingTypeOf(metadata) === "tool" && <ToolBadge variant="detail" />}
                        {languageOnlyLabel(metadata.language) && (
                            <span className="language-only-badge language-only-badge--detail">
                                {languageOnlyLabel(metadata.language)}
                            </span>
                        )}
                    </h1>
                )}
                {listBuilderCollapsed && (
                    <button
                        className="list-builder-toggle-btn list-builder-toggle-btn--detail"
                        onClick={toggleListBuilder}
                        title="Show list"
                        aria-label="Show list"
                    >
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                            <path d="M9 12h6m-6 4h6" />
                        </svg>
                        <span className="list-builder-toggle-badge">List</span>
                    </button>
                )}
            </div>
            <div className="integration-detail-layout">
            <ProductContext.Provider value={selectedProduct}>
            <TabContext.Provider value={{ activeTab, setActiveTab }}>
                <div className="integration-detail-content">
                    {/* Keyed by product so switching to a variant with downloads off re-reads the config. */}
                    {variantData?.downloadsDisabled && (
                        <MarketplaceAnnouncements key={selectedProduct} placement="downloads-disabled" />
                    )}
                    <div className="product-cta-row">
                        <div className="product-selector">
                            <span className="product-selector-label">PRODUCT</span>
                            <select
                                className="product-selector-dropdown"
                                value={selectedProduct}
                                onChange={(e) => handleProductChange(e.target.value)}
                            >
                                {selectableProducts.map((product) => (
                                    <option key={product} value={product}>
                                        {product}
                                    </option>
                                ))}
                            </select>
                        </div>

                        <PrimaryCTA cta={variantData?.primaryCta ?? null} />
                    </div>

                    {isProductSupported ? (
                        children
                    ) : (
                        <div className="integration-content-card">
                            <div className="product-unsupported">
                                <div className="product-unsupported-icon">⚠️</div>
                                <h3>Product Not Supported</h3>
                                <p>This integration doesn't support <strong>{selectedProduct}</strong> yet.</p>
                            </div>
                        </div>
                    )}

                    {/* Recommended Integrations Section - TODO: Enable when algorithm is refined */}
                    {/* {isProductSupported && metadata && (
                        <RecommendedIntegrations currentIntegrationId={id} />
                    )} */}
                </div>
            </TabContext.Provider>
            </ProductContext.Provider>

            {metadata && (
                <aside className="integration-detail-sidebar">
                    {metadata.logoUrl && (
                        <div className="detail-sidebar-logo">
                            <img src={`${baseUrl}${metadata.logoUrl.replace(/^\//, '')}`} alt={`${metadata.name} logo`} className={metadata.logoUrlDark ? "logo-light" : undefined} />
                            {metadata.logoUrlDark && (
                                <img src={`${baseUrl}${metadata.logoUrlDark.replace(/^\//, '')}`} alt={`${metadata.name} logo`} className="logo-dark" />
                            )}
                        </div>
                    )}

                    <DetailSection heading="Developer">
                        {authorCount > 1 ? (
                            <Link to={filterLink("author", variantData.author)} className="detail-filter-link">
                                {variantData.author}
                            </Link>
                        ) : (
                            <span className="detail-plain-value">{variantData.author}</span>
                        )}
                    </DetailSection>

                    {metadata.products?.length > 0 && (
                        <DetailSection heading="Products">
                            <div className="detail-item-list">
                                {metadata.products.map((p) => (
                                    <Link key={p} to={filterLink("product", p)} className="detail-filter-link">
                                        {p}
                                    </Link>
                                ))}
                            </div>
                        </DetailSection>
                    )}

                    {metadata.categories?.length > 0 && (
                        <DetailSection heading="Categories">
                            <div className="detail-item-list">
                                {metadata.categories.map((c) => (
                                    <Link key={c} to={filterLink("category", c)} className="detail-filter-link">
                                        {c}
                                    </Link>
                                ))}
                            </div>
                        </DetailSection>
                    )}

                    <DetailSection heading="Info">
                        <div className="detail-info-rows">
                            <div className="detail-info-row">
                                <span className="detail-info-label">Type</span>
                                <span className="detail-info-value">{LISTING_TYPE_NAMES[listingTypeOf(metadata)]}</span>
                            </div>
                            <div className="detail-info-row">
                                <span className="detail-info-label">Support</span>
                                <span className="detail-info-value">
                                    {variantData.supportUrl ? (
                                        <a
                                            href={variantData.supportUrl}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            className="detail-info-link"
                                        >
                                            {variantData.author}
                                        </a>
                                    ) : variantData.supportEmail ? (
                                        <a
                                            href={`mailto:${variantData.supportEmail}`}
                                            className="detail-info-link"
                                        >
                                            {variantData.author}
                                        </a>
                                    ) : (
                                        <span>—</span>
                                    )}
                                </span>
                            </div>
                            <div className="detail-info-row">
                                <span className="detail-info-label">Version</span>
                                <span className="detail-info-value">{variantData.currentVersion}</span>
                            </div>
                            {SHOW_LAST_UPDATED && formatUpdated(metadata.lastUpdated) && (
                                <div className="detail-info-row">
                                    <span className="detail-info-label">Last updated</span>
                                    <span className="detail-info-value">
                                        {formatUpdated(metadata.lastUpdated)}
                                    </span>
                                </div>
                            )}
                            <div className="detail-info-row">
                                <span className="detail-info-label">Price</span>
                                <span className="detail-info-value">
                                    {variantData.price}
                                    {variantData.supportPrice === 'Paid' && (
                                        <PaidSupportBadge acquisition={variantData.supportAcquisition} />
                                    )}
                                </span>
                            </div>
                            {metadata.license && (
                                <div className="detail-info-row">
                                    <span className="detail-info-label">License</span>
                                    <span className="detail-info-value">
                                        {licenseHref(metadata) ? (
                                            <a
                                                href={licenseHref(metadata)!}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="detail-info-link"
                                            >
                                                {metadata.license}
                                            </a>
                                        ) : (
                                            metadata.license
                                        )}
                                    </span>
                                </div>
                            )}
                        </div>
                    </DetailSection>

                    {metadata.useCases?.length > 0 && (
                        <DetailSection heading="Use Cases">
                            <div className="detail-item-list">
                                {metadata.useCases.map((u) => (
                                    <Link key={u} to={filterLink("useCase", u)} className="detail-filter-link">
                                        {u}
                                    </Link>
                                ))}
                            </div>
                        </DetailSection>
                    )}

                    {metadata.tags?.length > 0 && (
                        <DetailSection heading="Tags">
                            <div className="detail-item-list">
                                {metadata.tags.map((t) => (
                                    <Link key={t} to={filterLink("tag", t)} className="detail-filter-link">
                                        {t}
                                    </Link>
                                ))}
                            </div>
                        </DetailSection>
                    )}

                    <DetailSection heading="Disclaimer">
                        <p className="detail-disclaimer-text">
                            By downloading or using Marketplace content, you agree to the applicable{' '}
                            <Link href="https://www.paloaltonetworks.com/content/dam/pan/en_US/assets/pdf/legal/panw-marketplace-terms-of-use-for-cortex-and-mim.pdf">Terms of Use</Link> and End User License Agreement.
                            Third-party content is provided by its publisher, and Palo Alto Networks does not warrant, endorse, support, or assume responsibility for content not expressly identified as owned by Palo Alto Networks.
                        </p>
                    </DetailSection>

                </aside>
            )}

            <ListBuilderSidebar
                isCollapsed={listBuilderCollapsed}
                onToggleCollapsed={toggleListBuilder}
                currentIntegration={metadata}
            />
            </div>
        </div>
    );
}
