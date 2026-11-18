// Where a Community-supported variant's "Community" link points when the listing sets no
// issuesUrl: a new issue on the marketplace repo, using its community-support issue form
// (.github/ISSUE_TEMPLATE/community-support.yml in pan-dev-mim-marketplace). The form applies the
// "community" label; the integration/product/page fields below are pre-filled by matching the
// form's input ids, so the issue is attributed to the listing and variant it came from. Keep the
// template name and field ids in step with that file.

export const MARKETPLACE_REPO_URL = "https://github.com/PaloAltoNetworks/pan-dev-mim-marketplace";
const COMMUNITY_ISSUE_TEMPLATE = "community-support.yml";

export function communityIssueUrl(opts: {
    name: string;
    folder?: string;
    product: string;
    pageUrl: string;
}): string {
    const params: [string, string][] = [
        ["template", COMMUNITY_ISSUE_TEMPLATE],
        ["title", `[Community] ${opts.name} (${opts.product})`],
        ["integration", opts.folder ?? opts.name],
        ["product", opts.product],
        ["page", opts.pageUrl],
    ];
    const query = params.map(([k, v]) => `${k}=${encodeURIComponent(v)}`).join("&");
    return `${MARKETPLACE_REPO_URL}/issues/new?${query}`;
}
