import React from "react";

// Listing type ("Tools & Utilities" vs integrations), set per listing by the optional root-level
// `listingType` in integration_metadata.json. A missing or unknown value is an integration, so
// listings that predate the field need no change.

export type ListingType = "integration" | "tool";

export const LISTING_TYPES: ListingType[] = ["integration", "tool"];

/** Filter pill labels (plural). */
export const LISTING_TYPE_LABELS: Record<ListingType, string> = {
    integration: "Integrations",
    tool: "Tools & Utilities",
};

/** Info-row value on the detail page (singular). */
export const LISTING_TYPE_NAMES: Record<ListingType, string> = {
    integration: "Integration",
    tool: "Tools & Utilities",
};

export function listingTypeOf(listing: { listingType?: string } | null | undefined): ListingType {
    return listing?.listingType === "tool" ? "tool" : "integration";
}

export function ToolIcon({ size = 14 }: { size?: number }) {
    return (
        <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M22.7 19l-9.1-9.1c.9-2.3.4-5-1.5-6.9-2-2-5-2.4-7.4-1.3L9 6 6 9 1.6 4.7C.4 7.1.9 10.1 2.9 12.1c1.9 1.9 4.6 2.4 6.9 1.5l9.1 9.1c.4.4 1 .4 1.4 0l2.3-2.3c.5-.4.5-1.1.1-1.4z" />
        </svg>
    );
}

export function IntegrationIcon({ size = 14 }: { size?: number }) {
    return (
        <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M16 7V3h-2v4h-4V3H8v4H6v6l3.5 3.5V21h5v-4.5L18 13V7h-2z" />
        </svg>
    );
}

/** Orange pill shown on tool cards and next to a tool's detail-page title. */
export function ToolBadge({ variant = "card" }: { variant?: "card" | "detail" }) {
    return (
        <span className={`tool-badge${variant === "detail" ? " tool-badge--detail" : ""}`}>
            <ToolIcon size={12} /> Tools &amp; Utilities
        </span>
    );
}
