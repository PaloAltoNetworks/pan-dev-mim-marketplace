/** Listing dates all trace back to the bulk marketplace import, not real contribution
 *  activity. Keep them out of the UI until the site is live in production and integrations
 *  start receiving genuine updates. The build pipeline still populates `lastUpdated`
 *  (sync-integrations.sh → .integration-dates.json → generate-gallery.js), so re-enabling
 *  is this one flag. */
export const SHOW_LAST_UPDATED = false;
