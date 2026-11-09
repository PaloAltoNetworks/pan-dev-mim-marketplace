import React, { useEffect, useState } from "react";
import Link from "@docusaurus/Link";
import config from "../../../config/marketplace-announcements.json";
import styles from "./styles.module.css";

// Admin-owned announcement banners for the /marketplace gallery and, per entry, the integration
// detail pages whose downloads are turned off in config/marketplace-downloads.json. Edited in
// config/marketplace-announcements.json (see MARKETPLACE_FLAG.md → "Marketplace announcements").
// The start/end window is evaluated in the browser, so a scheduled banner appears and expires
// without a rebuild. Turning one off early, or adding one, is a commit.

type Severity = "info" | "warning" | "critical";

// Where a banner shows. "gallery" is the /marketplace page; "downloads-disabled" is any
// integration detail page whose selected product has downloadFiles that are admin-disabled.
export type Placement = "gallery" | "downloads-disabled";

interface Announcement {
    id: string;
    title?: string;
    message: string;
    severity?: Severity;
    link?: { label: string; href: string };
    start?: string;
    end?: string;
    enabled?: boolean;
    dismissible?: boolean;
    /** Defaults to ["gallery"] so existing entries keep their old behavior. */
    placements?: Placement[];
}

const SEVERITIES: Severity[] = ["info", "warning", "critical"];
const STORAGE_PREFIX = "mim-announcement-dismissed:";

const parseTime = (value?: string): number | null => {
    if (value === undefined) return null;
    const t = Date.parse(value);
    return Number.isNaN(t) ? NaN : t;
};

export function isActive(a: Announcement, now: number): boolean {
    if (!a.id || !a.message || a.enabled === false) return false;
    const start = parseTime(a.start);
    const end = parseTime(a.end);
    // An unparseable date hides the banner rather than showing it forever.
    if (Number.isNaN(start) || Number.isNaN(end)) return false;
    if (start !== null && now < start) return false;
    if (end !== null && now >= end) return false;
    return true;
}

function readDismissed(id: string): boolean {
    try {
        return window.localStorage.getItem(STORAGE_PREFIX + id) !== null;
    } catch {
        return false;
    }
}

function writeDismissed(id: string): void {
    try {
        window.localStorage.setItem(STORAGE_PREFIX + id, new Date().toISOString());
    } catch {
        // Storage blocked: the banner closes for this page view only.
    }
}

// When the link label appears in the message, the first occurrence becomes the link, so it can
// sit mid-sentence. Otherwise the link is appended after the message.
function MessageWithLink({ message, link }: Pick<Announcement, "message" | "link">) {
    if (!link?.href) return <>{message}</>;
    const label = link.label || "Learn more";
    const anchor = (
        <Link to={link.href} className={styles.link}>
            {label}
        </Link>
    );
    const at = message.indexOf(label);
    if (at === -1) return <>{message} {anchor}</>;
    return (
        <>
            {message.slice(0, at)}
            {anchor}
            {message.slice(at + label.length)}
        </>
    );
}

const placementsOf = (a: Announcement): Placement[] =>
    a.placements === undefined ? ["gallery"] : Array.isArray(a.placements) ? a.placements : [];

export default function MarketplaceAnnouncements({
    placement = "gallery",
}: {
    placement?: Placement;
}): React.JSX.Element | null {
    // Client-only: the static HTML is built once, so "now" and localStorage must be read after
    // hydration. Rendering nothing on the server also avoids flashing a dismissed banner.
    const [visible, setVisible] = useState<Announcement[]>([]);

    useEffect(() => {
        const now = Date.now();
        const all = (config.announcements ?? []) as Announcement[];
        setVisible(
            all.filter(
                (a) =>
                    placementsOf(a).includes(placement) &&
                    isActive(a, now) &&
                    !(a.dismissible !== false && readDismissed(a.id)),
            ),
        );
    }, [placement]);

    if (visible.length === 0) return null;

    const dismiss = (id: string) => {
        writeDismissed(id);
        setVisible((v) => v.filter((a) => a.id !== id));
    };

    return (
        <div className={styles.stack} role="region" aria-label="Announcements">
            {visible.map((a) => {
                const severity = SEVERITIES.includes(a.severity as Severity) ? a.severity : "info";
                return (
                    <div key={a.id} className={`${styles.banner} ${styles[severity!]}`}>
                        <p className={styles.message}>
                            {a.title && <strong className={styles.title}>{a.title}</strong>}
                            {a.title && " "}
                            <MessageWithLink message={a.message} link={a.link} />
                        </p>
                        {a.dismissible !== false && (
                            <button
                                type="button"
                                className={styles.close}
                                onClick={() => dismiss(a.id)}
                                aria-label="Dismiss announcement"
                            >
                                ×
                            </button>
                        )}
                    </div>
                );
            })}
        </div>
    );
}
