import React, { useState, useMemo, useEffect } from "react";
import Layout from "@theme/Layout";
import { useLocation } from "@docusaurus/router";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import integrationsData from "../data/integrations.json";
import { IntegrationMetadata } from "../types";
import { SHOW_LAST_UPDATED } from "../featureFlags";
import Link from "@docusaurus/Link";
import ExportButton from "../components/ExportButton";
import ListBuilderSidebar from "../components/ListBuilderSidebar";
import { useListBuilder } from "../contexts/ListBuilderContext";
import FilterDropdown from "../components/FilterDropdown";
import MarketplaceAnnouncements from "../components/MarketplaceAnnouncements";
import { languageOnlyLabel } from "../utils/languageLabel";
import { integrationId } from "../utils/integrationId";
import { byProductPriority, matchProductParam, PRODUCT_NAMES, productParamValue } from "../utils/productParam";
import { LISTING_TYPES, LISTING_TYPE_LABELS, listingTypeOf, ToolIcon, IntegrationIcon, ToolBadge } from "../components/ListingType";

function SupportedIcon() {
    return (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>
        </svg>
    );
}

function CommunityIcon() {
    return (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
        </svg>
    );
}

function SupportBadge({ support }: { support?: string }) {
    if (support !== "Supported" && support !== "Community") return null;
    const supported = support === "Supported";
    return (
        <div className={`card-badge card-badge--${supported ? "certified" : "community"}`}>
            <span className="card-badge-icon">
                {supported ? <SupportedIcon /> : <CommunityIcon />}
            </span>
            <span className="card-badge-label">{supported ? "Supported" : "Community"}</span>
        </div>
    );
}

const SUPPORT_LEVEL_TOOLTIP_ID = "support-level-tooltip";

// The "i" next to the SUPPORT LEVEL heading. Opens on hover or keyboard focus. The button gives
// keyboard and touch users something to focus; it has no click action of its own.
function SupportLevelInfo() {
    return (
        <span className="filter-info-tooltip">
            <button
                type="button"
                className="filter-info-tooltip__icon"
                aria-label="What support levels mean"
                aria-describedby={SUPPORT_LEVEL_TOOLTIP_ID}
            >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    <path d="M12 2a10 10 0 100 20 10 10 0 000-20zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z" />
                </svg>
            </button>
            <span role="tooltip" id={SUPPORT_LEVEL_TOOLTIP_ID} className="filter-info-tooltip__bubble">
                <strong>Supported:</strong> support is offered by Palo Alto Networks or the partner.
                Each listing shows which.
                <br />
                <strong>Community:</strong> best-effort support from the community.
            </span>
        </span>
    );
}

// The stored `support` values, in filter order, shown as-is. "Supported" was labelled "Certified"
// until 2026-11-11, and "Partner" was dropped as a value the same day.
const SUPPORT_LEVELS = ["Supported", "Community"];

// A card's product pills: the first two by priority, the rest folded into a "+N" pill.
function ProductPills({ products }: { products: string[] }) {
    const sorted = byProductPriority(products);
    return (
        <div className="card-pills">
            {sorted.slice(0, 2).map((p) => (
                <span key={p} className="card-pill">{p}</span>
            ))}
            {sorted.length > 2 && (
                <span className="card-pill card-pill--more" title={sorted.slice(2).join(", ")}>
                    +{sorted.length - 2}
                </span>
            )}
        </div>
    );
}

const ALL_SORT_OPTIONS = [
    { value: "name-asc", label: "Name (A–Z)" },
    { value: "name-desc", label: "Name (Z–A)" },
    { value: "updated-desc", label: "Last update (newest)" },
    { value: "updated-asc", label: "Last update (oldest)" },
] as const;

type SortOption = (typeof ALL_SORT_OPTIONS)[number]["value"];

// Sorting by a date the listings don't display would only surface the bulk-import ordering.
// The date sorts come back with the rest of the feature — see SHOW_LAST_UPDATED. A stale
// "updated-*" in localStorage is rejected by the saved-preferences effect below, which validates
// against this filtered list.
const SORT_OPTIONS: readonly { value: SortOption; label: string }[] = SHOW_LAST_UPDATED
    ? ALL_SORT_OPTIONS
    : ALL_SORT_OPTIONS.filter((o) => !o.value.startsWith("updated"));

function toggleItem(
    setter: React.Dispatch<React.SetStateAction<string[]>>,
    value: string,
) {
    setter((prev) =>
        prev.includes(value) ? prev.filter((x) => x !== value) : [...prev, value],
    );
}

function supportOf(integration: IntegrationMetadata): string | undefined {
    return integration.support;
}

export default function MarketplaceGallery() {
    const location = useLocation();
    const { siteConfig: { baseUrl } } = useDocusaurusContext();
    const { setIntegrationsData, loadListFromUrl, currentList, integrations: listIntegrations } = useListBuilder();

    function paramList(key: string): string[] {
        const val = new URLSearchParams(location.search).get(key);
        return val ? [decodeURIComponent(val)] : [];
    }

    // `?product=` takes a full name or the short suffix (ngts, saas, selfhosted, ztpki), any case,
    // the same as the listing detail page. Both resolve to the canonical name the filter matches
    // on. An unrecognised value is kept as-is, so it still shows as an active filter.
    function productsFromUrl(): string[] {
        return paramList("product").map((v) => matchProductParam(v, PRODUCT_NAMES) ?? v);
    }

    // Every piece of state below that depends on the URL or localStorage starts at its default
    // and is filled in by an effect. The static HTML was built with no query string and no
    // storage, so React's first client render has to match that or hydration fails (React
    // error #418) and the whole page is thrown away and re-rendered.
    const [filtersOpen, setFiltersOpen] = useState(false);
    const [selectedProducts, setSelectedProducts] = useState<string[]>([]);
    const [selectedTags, setSelectedTags] = useState<string[]>([]);
    const [selectedUseCases, setSelectedUseCases] = useState<string[]>([]);
    const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
    const [selectedAuthors, setSelectedAuthors] = useState<string[]>([]);
    const [selectedSupport, setSelectedSupport] = useState<string[]>([]);
    const [selectedType, setSelectedType] = useState<string[]>([]);
    const [draggingCard, setDraggingCard] = useState<string | null>(null);

    // Filters come from the query string: on mount, and again whenever it changes. Filter links
    // across the site point at /marketplace?category=…, ?tag=…, and so on, and when one is
    // followed from a page that is already /marketplace (a category pill on a card, for
    // instance) the component does not remount. Nothing writes to the URL programmatically, so
    // this only fires on real navigation.
    useEffect(() => {
        setSelectedProducts(productsFromUrl());
        setSelectedTags(paramList("tag"));
        setSelectedUseCases(paramList("useCase"));
        setSelectedCategories(paramList("category"));
        setSelectedAuthors(paramList("author"));
        setSelectedSupport(paramList("support"));
        setSelectedType(paramList("type"));
    }, [location.search]);

    // Collapsed by default; only an explicit toggle is saved. The -v2 key ignores the old value,
    // which was written on every page load and pinned every past visitor to "expanded".
    const [listBuilderCollapsed, setListBuilderCollapsed] = useState<boolean>(true);
    const [sortBy, setSortBy] = useState<SortOption>('name-asc');

    // Saved preferences are applied after hydration (see the note above the filter state).
    // Declared before the ?list= effect below so a shared list link still wins and opens the list.
    useEffect(() => {
        try {
            if (localStorage.getItem('list-builder-collapsed-v2') === 'false') setListBuilderCollapsed(false);
            const stored = localStorage.getItem('marketplace-sort') as SortOption | null;
            if (stored && SORT_OPTIONS.some((o) => o.value === stored)) setSortBy(stored);
        } catch {
            // Storage blocked: keep the defaults.
        }
    }, []);

    const handleSortChange = (value: SortOption) => {
        setSortBy(value);
        if (typeof window !== 'undefined') {
            localStorage.setItem('marketplace-sort', value);
        }
    };

    const integrations: IntegrationMetadata[] =
        integrationsData as IntegrationMetadata[];

    useEffect(() => {
        setIntegrationsData(integrations);
    }, [integrations, setIntegrationsData]);

    useEffect(() => {
        const params = new URLSearchParams(location.search);
        const listParam = params.get('list');
        if (listParam) {
            loadListFromUrl(listParam);
            // A shared list link should show the list, without saving that as the visitor's choice.
            setListBuilderCollapsed(false);
        }
    }, [location.search, loadListFromUrl]);

    const toggleListBuilder = () => {
        const next = !listBuilderCollapsed;
        setListBuilderCollapsed(next);
        try {
            localStorage.setItem('list-builder-collapsed-v2', String(next));
        } catch {
            // Storage blocked: the choice lasts for this page view only.
        }
    };

    const allCategories = useMemo(() => {
        const categories = new Set<string>();
        integrations.forEach((i) => i.categories?.forEach((c) => categories.add(c)));
        return Array.from(categories).sort();
    }, [integrations]);

    const allTags = useMemo(() => {
        const tags = new Set<string>();
        integrations.forEach((i) => i.tags?.forEach((t) => tags.add(t)));
        return Array.from(tags).sort();
    }, [integrations]);

    const allUseCases = useMemo(() => {
        const useCases = new Set<string>();
        integrations.forEach((i) => i.useCases?.forEach((u) => useCases.add(u)));
        return Array.from(useCases).sort();
    }, [integrations]);

    const productCounts = useMemo(() => {
        const counts: Record<string, number> = {};
        integrations.forEach((i) =>
            i.products?.forEach((p) => { counts[p] = (counts[p] || 0) + 1; })
        );
        return counts;
    }, [integrations]);

    const categoryCounts = useMemo(() => {
        const counts: Record<string, number> = {};
        integrations.forEach((i) =>
            i.categories?.forEach((c) => { counts[c] = (counts[c] || 0) + 1; })
        );
        return counts;
    }, [integrations]);

    const tagCounts = useMemo(() => {
        const counts: Record<string, number> = {};
        integrations.forEach((i) =>
            i.tags?.forEach((t) => { counts[t] = (counts[t] || 0) + 1; })
        );
        return counts;
    }, [integrations]);

    const useCaseCounts = useMemo(() => {
        const counts: Record<string, number> = {};
        integrations.forEach((i) =>
            i.useCases?.forEach((u) => { counts[u] = (counts[u] || 0) + 1; })
        );
        return counts;
    }, [integrations]);

    // Ordered by the taxonomy, not alphabetically, so the pills read Supported → Community.
    const allSupportLevels = useMemo(() => {
        const present = new Set<string>();
        integrations.forEach((i) => {
            const support = supportOf(i);
            if (support) present.add(support);
        });
        return SUPPORT_LEVELS.filter((s) => present.has(s));
    }, [integrations]);

    const supportCounts = useMemo(() => {
        const counts: Record<string, number> = {};
        integrations.forEach((i) => {
            const support = supportOf(i);
            if (support) counts[support] = (counts[support] || 0) + 1;
        });
        return counts;
    }, [integrations]);

    const developersOf = (i: IntegrationMetadata): string[] =>
        i.authors ?? (i.author ? [i.author] : []);

    const allDevelopers = useMemo(() => {
        const devs = new Set<string>();
        integrations.forEach((i) => developersOf(i).forEach((a) => devs.add(a)));
        return Array.from(devs).sort((a, b) => {
            if (a === "Venafi") return -1;
            if (b === "Venafi") return 1;
            return a.localeCompare(b);
        });
    }, [integrations]);

    const developerCounts = useMemo(() => {
        const counts: Record<string, number> = {};
        integrations.forEach((i) => developersOf(i).forEach((a) => { counts[a] = (counts[a] || 0) + 1; }));
        return counts;
    }, [integrations]);

    const filteredIntegrations = useMemo(() => {
        return integrations.filter((i) => {
            const matchesProduct =
                selectedProducts.length === 0 ||
                selectedProducts.some((p) => i.products?.includes(p));
            const matchesTag =
                selectedTags.length === 0 ||
                selectedTags.some((t) => i.tags?.includes(t));
            const matchesUseCase =
                selectedUseCases.length === 0 ||
                selectedUseCases.some((u) => i.useCases?.includes(u));
            const matchesCategory =
                selectedCategories.length === 0 ||
                selectedCategories.some((c) => i.categories?.includes(c));
            const matchesAuthor =
                selectedAuthors.length === 0 ||
                developersOf(i).some((a) => selectedAuthors.includes(a));
            const matchesSupport =
                selectedSupport.length === 0 ||
                selectedSupport.includes(supportOf(i));
            const matchesType = selectedType.length === 0 || selectedType.includes(listingTypeOf(i));
            return matchesProduct && matchesTag && matchesUseCase && matchesCategory && matchesAuthor && matchesSupport && matchesType;
        });
    }, [integrations, selectedProducts, selectedTags, selectedUseCases, selectedCategories, selectedAuthors, selectedSupport, selectedType]);

    const typeCounts = useMemo(() => {
        const counts: Record<string, number> = { integration: 0, tool: 0 };
        integrations.forEach((i) => { counts[listingTypeOf(i)] += 1; });
        return counts;
    }, [integrations]);

    // With exactly one product filter on, the card link carries it so the click lands on that
    // variant. A listing that claims the product without a matching variant falls back to its
    // default on the detail page.
    const cardProductQuery = selectedProducts.length === 1
        ? `?product=${encodeURIComponent(productParamValue(selectedProducts[0]))}`
        : "";

    // Undated listings always sink to the bottom, whichever direction the date sort runs —
    // "oldest first" shouldn't be a showcase for entries that simply have no date yet.
    const sortedIntegrations = useMemo(() => {
        const copy = [...filteredIntegrations];
        if (sortBy === "name-asc") return copy.sort((a, b) => a.name.localeCompare(b.name));
        if (sortBy === "name-desc") return copy.sort((a, b) => b.name.localeCompare(a.name));

        const direction = sortBy === "updated-desc" ? -1 : 1;
        return copy.sort((a, b) => {
            if (!a.lastUpdated && !b.lastUpdated) return a.name.localeCompare(b.name);
            if (!a.lastUpdated) return 1;
            if (!b.lastUpdated) return -1;
            const delta = a.lastUpdated.localeCompare(b.lastUpdated) * direction;
            return delta !== 0 ? delta : a.name.localeCompare(b.name);
        });
    }, [filteredIntegrations, sortBy]);

    const hasActiveFilters =
        selectedProducts.length > 0 ||
        selectedTags.length > 0 ||
        selectedUseCases.length > 0 ||
        selectedCategories.length > 0 ||
        selectedAuthors.length > 0 ||
        selectedSupport.length > 0 ||
        selectedType.length > 0;

    function clearAllFilters() {
        setSelectedProducts([]);
        setSelectedTags([]);
        setSelectedUseCases([]);
        setSelectedCategories([]);
        setSelectedAuthors([]);
        setSelectedSupport([]);
        setSelectedType([]);
    }

    const handleDragStart = (e: React.DragEvent, integration: IntegrationMetadata) => {
        e.dataTransfer.setData('application/json', JSON.stringify(integration));
        e.dataTransfer.effectAllowed = 'copy';
        setDraggingCard(integration.name);
    };

    const handleDragEnd = () => {
        setDraggingCard(null);
    };

    return (
        <Layout
            title="MIM Marketplace"
            description="Discover MIM Integrations"
        >
            {/* Mirrors the condition ListBuilderSidebar renders under, so card
                drag affordances only show when there is a list to drop onto. */}
            <div className={`marketplace-container${currentList && !listBuilderCollapsed ? ' list-builder-open' : ''}`}>
                {/* Left Sidebar: Filters */}
                <aside className="marketplace-sidebar">
                    <button
                        className="mobile-filters-toggle"
                        onClick={() => setFiltersOpen((o) => !o)}
                        aria-expanded={filtersOpen}
                    >
                        ☰ {filtersOpen ? "Hide Filters" : "Show Filters"}
                    </button>
                    <div className={`marketplace-sidebar-inner${filtersOpen ? " open" : ""}`}>
                        {/* Product Filter */}
                        <FilterDropdown
                            title="Product"
                            items={PRODUCT_NAMES}
                            selected={selectedProducts}
                            onToggle={(v) => toggleItem(setSelectedProducts, v)}
                            counts={productCounts}
                        />

                        {/* Support Level filter — pill toggles rather than checkboxes, since
                            there are only ever two or three values */}
                        {allSupportLevels.length > 0 && (
                            <div className="filter-dropdown filter-dropdown--static">
                                <div className="filter-dropdown-header filter-dropdown-header--static">
                                    <span className="filter-section-label">Support Level</span>
                                    <SupportLevelInfo />
                                </div>
                                <div className="filter-pill-group">
                                    {allSupportLevels.map((level) => (
                                        <button
                                            key={level}
                                            className={`filter-pill-toggle${selectedSupport.includes(level) ? " active" : ""}`}
                                            onClick={() => toggleItem(setSelectedSupport, level)}
                                            aria-pressed={selectedSupport.includes(level)}
                                        >
                                            <span className="filter-pill-toggle-icon">
                                                {level === "Community" ? <CommunityIcon /> : <SupportedIcon />}
                                            </span>
                                            {level}
                                            <span className="filter-count"> ({supportCounts[level]})</span>
                                        </button>
                                    ))}
                                </div>
                            </div>
                        )}

                        {/* Type filter — Integrations vs Tools & Utilities (listingType) */}
                        <div className="filter-dropdown filter-dropdown--static">
                            <div className="filter-dropdown-header filter-dropdown-header--static">
                                <span className="filter-section-label">Type</span>
                            </div>
                            <div className="filter-pill-group">
                                {LISTING_TYPES.map((t) => (
                                    <button
                                        key={t}
                                        className={`filter-pill-toggle${selectedType.includes(t) ? " active" : ""}`}
                                        onClick={() => toggleItem(setSelectedType, t)}
                                        aria-pressed={selectedType.includes(t)}
                                    >
                                        <span className="filter-pill-toggle-icon">
                                            {t === "tool" ? <ToolIcon /> : <IntegrationIcon />}
                                        </span>
                                        {LISTING_TYPE_LABELS[t]}
                                        <span className="filter-count"> ({typeCounts[t]})</span>
                                    </button>
                                ))}
                            </div>
                        </div>

                        {/* Category Filter */}
                        {allCategories.length > 0 && (
                            <FilterDropdown
                                title="Category"
                                items={allCategories}
                                selected={selectedCategories}
                                onToggle={(v) => toggleItem(setSelectedCategories, v)}
                                counts={categoryCounts}
                                defaultOpen={false}
                            />
                        )}

                        {/* Tags Filter */}
                        {allTags.length > 0 && (
                            <FilterDropdown
                                title="Tags"
                                items={allTags}
                                selected={selectedTags}
                                onToggle={(v) => toggleItem(setSelectedTags, v)}
                                counts={tagCounts}
                                defaultOpen={false}
                            />
                        )}

                        {/* Use Cases Filter */}
                        {allUseCases.length > 0 && (
                            <FilterDropdown
                                title="Use Cases"
                                items={allUseCases}
                                selected={selectedUseCases}
                                onToggle={(v) => toggleItem(setSelectedUseCases, v)}
                                counts={useCaseCounts}
                                defaultOpen={false}
                            />
                        )}

                        {/* Developer Filter */}
                        {allDevelopers.length > 0 && (
                            <FilterDropdown
                                title="Developer"
                                items={allDevelopers}
                                selected={selectedAuthors}
                                onToggle={(v) => toggleItem(setSelectedAuthors, v)}
                                counts={developerCounts}
                                defaultOpen={false}
                            />
                        )}
                    </div>
                </aside>

                {/* Right Content: Card Grid */}
                <main className="marketplace-main">
                    <MarketplaceAnnouncements />
                    <div className="marketplace-header margin-bottom--md">
                        <div className="marketplace-header-top">
                            <p>
                                Displaying{" "}
                                <strong>{filteredIntegrations.length}</strong> of{" "}
                                <strong>{integrations.length}</strong> listings
                            </p>

                            <div className="marketplace-header-actions">
                                {/* Sort */}
                                <label className="sort-control">
                                    <span className="sort-control-label">Sort by</span>
                                    <select
                                        className="sort-select"
                                        value={sortBy}
                                        onChange={(e) => handleSortChange(e.target.value as SortOption)}
                                    >
                                        {SORT_OPTIONS.map((option) => (
                                            <option key={option.value} value={option.value}>
                                                {option.label}
                                            </option>
                                        ))}
                                    </select>
                                </label>

                                {/* Export Button */}
                                <ExportButton
                                    integrations={sortedIntegrations}
                                    totalCount={integrations.length}
                                />

                                {/* List Builder Toggle Button (when collapsed) */}
                                {listBuilderCollapsed && (
                                    <button
                                        className="list-builder-toggle-btn"
                                        onClick={toggleListBuilder}
                                        title="Build a shareable list of integrations"
                                        aria-label="Build a shareable list of integrations"
                                    >
                                        <span className="list-builder-toggle-btn-icon">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                                                <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" stroke="currentColor" strokeWidth="2" fill="none" />
                                                <path d="M9 12h6m-6 4h6" stroke="currentColor" strokeWidth="2" />
                                            </svg>
                                        </span>
                                        <span className="list-builder-toggle-btn-text">My List</span>
                                        {listIntegrations.length > 0 && (
                                            <span className="list-builder-toggle-btn-badge">
                                                {listIntegrations.length}
                                            </span>
                                        )}
                                    </button>
                                )}
                            </div>
                        </div>

                        {/* Active filter pills */}
                        {hasActiveFilters && (
                            <div className="active-filters">
                                {selectedType.map((t) => (
                                    <span key={t} className="filter-pill">
                                        {LISTING_TYPE_LABELS[t as keyof typeof LISTING_TYPE_LABELS] ?? t}
                                        <button onClick={() => toggleItem(setSelectedType, t)}>×</button>
                                    </span>
                                ))}
                                {selectedSupport.map((s) => (
                                    <span key={s} className="filter-pill">
                                        {s}
                                        <button onClick={() => toggleItem(setSelectedSupport, s)}>×</button>
                                    </span>
                                ))}
                                {selectedProducts.map((p) => (
                                    <span key={p} className="filter-pill">
                                        {p}
                                        <button
                                            onClick={() =>
                                                toggleItem(setSelectedProducts, p)
                                            }
                                        >
                                            ×
                                        </button>
                                    </span>
                                ))}
                                {selectedTags.map((t) => (
                                    <span key={t} className="filter-pill">
                                        {t}
                                        <button
                                            onClick={() =>
                                                toggleItem(setSelectedTags, t)
                                            }
                                        >
                                            ×
                                        </button>
                                    </span>
                                ))}
                                {selectedUseCases.map((u) => (
                                    <span key={u} className="filter-pill">
                                        {u}
                                        <button onClick={() => toggleItem(setSelectedUseCases, u)}>×</button>
                                    </span>
                                ))}
                                {selectedCategories.map((c) => (
                                    <span key={c} className="filter-pill">
                                        {c}
                                        <button onClick={() => toggleItem(setSelectedCategories, c)}>×</button>
                                    </span>
                                ))}
                                {selectedAuthors.map((a) => (
                                    <span key={a} className="filter-pill">
                                        {a}
                                        <button onClick={() => toggleItem(setSelectedAuthors, a)}>×</button>
                                    </span>
                                ))}
                                <button
                                    className="clear-filters-link"
                                    onClick={clearAllFilters}
                                >
                                    Clear all
                                </button>
                            </div>
                        )}
                    </div>

                    <div className="integration-grid">
                        {sortedIntegrations.map((int, index) => (
                            <Link
                                key={index}
                                to={`/marketplace/${integrationId(int)}${cardProductQuery}`}
                                className={`integration-card${draggingCard === int.name ? ' dragging' : ''}`}
                                draggable={true}
                                onDragStart={(e) => handleDragStart(e, int)}
                                onDragEnd={handleDragEnd}
                            >
                                <div className="card-head">
                                    {int.logoUrl && (
                                        <div className="card-logo-thumb">
                                            <img
                                                src={`${baseUrl}${int.logoUrl.replace(/^\//, '')}`}
                                                alt=""
                                                className={int.logoUrlDark ? "logo-light" : undefined}
                                            />
                                            {int.logoUrlDark && (
                                                <img
                                                    src={`${baseUrl}${int.logoUrlDark.replace(/^\//, '')}`}
                                                    alt=""
                                                    className="logo-dark"
                                                />
                                            )}
                                        </div>
                                    )}
                                    <div className="card-title-stack">
                                        <h3 className="card-title">{int.name}</h3>
                                        <p className="card-meta">By: {int.author}</p>
                                        {listingTypeOf(int) === "tool" && <ToolBadge />}
                                        {languageOnlyLabel(int.language) && (
                                            <span className="language-only-badge">{languageOnlyLabel(int.language)}</span>
                                        )}
                                    </div>
                                    <SupportBadge support={supportOf(int)} />
                                </div>
                                <p className="card-desc">{int.description}</p>
                                {/* The stack — not the description — takes the leftover
                                    vertical space, so the pills pin to the card's bottom
                                    without stretching (and un-clamping) .card-desc. */}
                                <div className="card-pill-stack">
                                    {int.products?.length > 0 && <ProductPills products={int.products} />}
                                    {int.categories?.length > 0 && (
                                        <div className="card-pills">
                                            <span className="card-pill card-pill--category">
                                                {int.categories[0]}
                                            </span>
                                            {int.categories.length > 1 && (
                                                <span
                                                    className="card-pill card-pill--more"
                                                    title={int.categories.slice(1).join(", ")}
                                                >
                                                    +{int.categories.length - 1}
                                                </span>
                                            )}
                                        </div>
                                    )}
                                </div>
                            </Link>
                        ))}
                    </div>
                </main>

                {/* Right Sidebar: List Builder */}
                <ListBuilderSidebar
                    isCollapsed={listBuilderCollapsed}
                    onToggleCollapsed={toggleListBuilder}
                />
            </div>
        </Layout>
    );
}
