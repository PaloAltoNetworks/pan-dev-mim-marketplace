// Integrations default to English. An integration whose content is only available in another
// language sets `language` (an ISO 639-1 code, e.g. "ja") in integration_metadata.json, and the
// gallery card and detail page show a "<Language> Language Only" badge. Placeholder until the
// Marketplace is localized.
export function languageOnlyLabel(language?: string): string | null {
    if (!language || language.toLowerCase() === "en") return null;
    let name: string | undefined;
    try {
        name = new Intl.DisplayNames(["en"], { type: "language" }).of(language);
    } catch {
        // Invalid code — fall back to showing it verbatim rather than dropping the badge.
    }
    return `${name ?? language} Language Only`;
}
