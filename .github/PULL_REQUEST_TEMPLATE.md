## Integration Submission Checklist

**Integration name**: <!-- e.g. MyProduct -->

### Type of change
- [ ] New integration
- [ ] Update to existing integration
- [ ] Remove integration
- [ ] Config/script update

### Pre-submission checklist

- [ ] `integration_metadata.json` is present and valid JSON
- [ ] All required fields are populated: `name`, `description`, `products`, `price`
- [ ] Logo file is present (`.png`, `.svg`, `.jpg`, or `.webp`)
- [ ] At least one `OVERVIEW-*.md` or `README.md` is present
- [ ] Ran `node scripts/validate-integration.js Integrations/<MyIntegration>` locally — passed
- [ ] No credentials, API keys, or secrets are included in any file

### For partner paid integrations (`price: "Paid (Contact Partner)"`)
- [ ] `partnerContactUrl` is set to a valid HTTPS URL
- [ ] No `downloads/` directory is included (partner integrations link out, not distribute)

### For new integrations
- [ ] Added an entry to `.github/owner-reviewers.yml` naming the GitHub username(s) who should review this integration going forward (listing yourself is fine) — see [Reviewer approval required to merge](../CONTRIBUTING.md#reviewer-approval-required-to-merge) in CONTRIBUTING.md

### Description of changes
<!-- What did you add, update, or fix? -->

### Testing
<!-- How did you verify this looks correct? e.g. ran local build, checked metadata, reviewed docs -->
