# MIM Marketplace — Integration Repository

This is the single repository for all integrations listed on the [MIM Marketplace](https://mim.pan.dev/marketplace).

## What lives here

- **Free integrations** — open-source and community-supported
- **Paid integrations (Contact Partner)** — commercial products listed with a partner CTA
- **Paid integrations (Contact Sales)** — products available through the internal sales team

## Contributing a new integration

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide. If you use Claude Code, see
[Optional: AI-assisted listing generation](CONTRIBUTING.md#optional-ai-assisted-listing-generation)
for a way to draft the files below from your existing codebase.

Quick start:

```bash
# Fork this repository on GitHub, then clone your fork
git clone https://github.com/<your-username>/pan-dev-mim-marketplace.git
cd pan-dev-mim-marketplace

# Create a branch
git checkout -b add-my-integration

# Copy the template
cp -r Integrations/.template Integrations/MyIntegration
# Windows (cmd.exe): xcopy /E /I Integrations\.template Integrations\MyIntegration
# Windows (PowerShell) and Git Bash/WSL can use the cp command above as-is.

# Edit your integration files
# Then validate locally
npm ci
node scripts/validate-integration.js Integrations/MyIntegration

# Commit and push
git add Integrations/MyIntegration
git commit -m "feat: add MyIntegration"
git push origin add-my-integration
```

Open a pull request when ready.

## Repository structure

```
Integrations/
├── .template/                  # Template for new integrations
├── MyIntegration/
│   ├── integration_metadata.json   # Required: display name, tags, products, price
│   ├── OVERVIEW-selfhosted.md      # Required: documentation page
│   ├── logo.png                    # Recommended: integration logo (falls back to a generic logo if absent)
│   ├── ReleaseNotes/                # Required: one release note per version
│   └── scripts/                    # Optional: PowerShell or other scripts
Config/
├── approved_categories.json        # Allowed category values
├── approved_tags.json              # Allowed tag values
├── approved_products.json          # Allowed product values
└── approved_usecases.json          # Allowed use-case values
scripts/
└── validate-integration.js         # Local validation tool
```

## Integration metadata schema

See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for the full schema reference.

## Where integrations go

All integrations live in this repository. The `price` field and optional `acquisition` object control how each integration appears on the marketplace:

| Type | Price | CTA on site |
|------|-------|-------------|
| Free | `"Free"` | Download or documentation link |
| Paid (Contact Partner) | `"Paid"` + `acquisition.type: "contact-partner"` | Partner contact button |
| Paid (Contact Sales) | `"Paid"` + `acquisition.type: "contact-sales"` | Sales contact button |

## License

See [LICENSE](LICENSE).

