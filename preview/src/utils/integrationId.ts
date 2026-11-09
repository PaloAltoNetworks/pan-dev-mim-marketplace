import type { IntegrationMetadata } from "../types";

// generate-gallery.js writes the page id (the /marketplace/<id> slug) into integrations.json as
// `routeId`. Read it from there rather than re-deriving it from `name`: a name with no ASCII
// letters or digits (e.g. Japanese) gets its folder name as the id instead.
export function integrationId(integration: Pick<IntegrationMetadata, "name" | "routeId">): string {
    return integration.routeId ?? integration.name.replace(/[^a-zA-Z0-9]/g, "");
}
