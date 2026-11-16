import React from "react";

// Support-level icons and badge, shared by the gallery cards and the gallery's Support Level filter.

export function SupportedIcon({ size = 18 }: { size?: number }) {
    return (
        <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>
        </svg>
    );
}

export function CommunityIcon({ size = 18 }: { size?: number }) {
    return (
        <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
        </svg>
    );
}

// A gallery card's support chip: an icon with the label revealed on hover.
export function SupportBadge({ support }: { support?: string }) {
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
