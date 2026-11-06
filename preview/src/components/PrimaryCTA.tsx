import React, { useContext } from "react";
import type { PrimaryCTA as PrimaryCTAInfo } from "../types";
import { TabContext } from "./IntegrationDetail";

const DEFAULT_LABELS: Record<string, string> = {
    download: "Download",
    docs: "View Documentation Tab",
    "contact-sales": "Contact Your Account Team",
    "contact-partner": "Contact Partner",
};

// Only paid types carry the "Paid Integration" badge and show a description.
const PAID_TYPES = new Set(["contact-sales", "contact-partner"]);

const ExternalIcon = () => (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6M15 3h6v6M10 14L21 3" />
    </svg>
);

export function PrimaryCTA({ cta }: { cta: PrimaryCTAInfo | null | undefined }) {
    // `link` is meaningless without a target — the generator already warns and drops these,
    // but guard here too since the component is public.
    const isLinkWithoutUrl = cta?.type === "link" && !cta.url;

    const { setActiveTab } = useContext(TabContext);

    if (!cta || !cta.type || isLinkWithoutUrl) {
        // Every integration shows this row — when there's genuinely nothing to offer, say so
        // rather than leaving an empty gap next to the PRODUCT selector.
        return (
            <div className="primary-cta primary-cta--none">
                <span className="primary-cta__none">No additional resources available</span>
            </div>
        );
    }

    const isPaid = PAID_TYPES.has(cta.type);
    const label = cta.label || DEFAULT_LABELS[cta.type] || "Learn More";

    // In-page navigation, not outbound links. generate-gallery.js only emits these CTA types
    // when the target tab exists: downloads attach to the newest Release Notes entry.
    const tabTarget =
        cta.type === "docs" ? "documentation" : cta.type === "download" ? "release-notes" : null;

    let button: React.ReactNode;
    if (tabTarget) {
        button = (
            <button
                type="button"
                className={`primary-cta__button${cta.type === "docs" ? " primary-cta__button--docs" : ""}`}
                onClick={() => setActiveTab(tabTarget)}
            >
                {label}
            </button>
        );
    } else if (!cta.url) {
        // No target (e.g. contact-sales without a url) — render as a static label.
        button = (
            <span className="primary-cta__button primary-cta__button--text">{label}</span>
        );
    } else {
        // link / contact-* with a url open externally.
        button = (
            <a
                href={cta.url}
                target="_blank"
                rel="noopener noreferrer"
                className="primary-cta__button"
            >
                {label}
                <ExternalIcon />
            </a>
        );
    }

    return (
        <div className="primary-cta">
            <div className="primary-cta__row">
                {isPaid && <span className="primary-cta__badge">Paid Integration</span>}
                {button}
            </div>
            {isPaid && cta.description && (
                <p className="primary-cta__description">{cta.description}</p>
            )}
        </div>
    );
}
