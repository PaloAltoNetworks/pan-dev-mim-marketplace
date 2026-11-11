## Listing Submission Checklist

**Listing name**: <!-- e.g. MyProduct -->

### Type of change
- [ ] New integration
- [ ] New tool or utility (`"listingType": "tool"`)
- [ ] Update to existing listing
- [ ] Remove listing
- [ ] Config/script update

### Pre-submission checklist

- [ ] `integration_metadata.json` is present and valid JSON
- [ ] All required fields are populated: `name`, `description`, `products`, `price`
- [ ] Logo file is present (`.png`, `.svg`, `.jpg`, or `.webp`), or the generic fallback logo is intended
- [ ] An `OVERVIEW-<suffix>.md` is present for each product
- [ ] Ran `node scripts/validate-integration.js Integrations/<MyListing>` locally — no errors
- [ ] Worked through the [Testing checklist](../CONTRIBUTING.md#testing-checklist) in a local preview
- [ ] No credentials, API keys, or secrets are included in any file

### For updates to an existing listing
- [ ] `currentVersion` is bumped and a matching `ReleaseNotes/<version>.md` is added — see [Updating an existing integration](../CONTRIBUTING.md#updating-an-existing-integration)

### For partner paid listings (`price: "Paid"` with `acquisition.type: "contact-partner"`)
- [ ] `acquisition.url` is set to a valid HTTPS URL

### For new listings
- [ ] Added an entry to `.github/owner-reviewers.yml` naming the GitHub username(s) who should review this listing going forward (listing yourself is fine) — see [Reviewer approval required to merge](../CONTRIBUTING.md#reviewer-approval-required-to-merge) in CONTRIBUTING.md

### For external contributors
- [ ] I have accepted the [Contributor Terms](../CONTRIBUTOR_TERMS.md)

### Description of changes
<!-- What did you add, update, or fix? What does the listing do, and which products does it support? -->

### Testing
<!-- How did you verify this looks correct? e.g. ran local preview, checked metadata, reviewed docs -->
