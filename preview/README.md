# Marketplace preview

Preview how your integration will render on the public MIM Marketplace **before you open a PR** — locally, offline, in seconds.

This is a slim [Docusaurus](https://docusaurus.io/) site that runs the *real* marketplace rendering engine (the same components used on the live site), pointed at your local `Integrations/` content. What you see here is what reviewers and users will see.

## Quick start

Requires **Node 20 or 22 LTS** (Docusaurus does not support odd/newer Node lines like 21/23/26 — use `nvm use 20` if in doubt). On Windows, the standard `nvm` doesn't work — use [nvm-windows](https://github.com/coreybutler/nvm-windows) or [fnm](https://github.com/Schniz/fnm) instead; the `nvm use 20` command itself is the same.

```bash
cd preview
npm install          # one time
npm start            # regenerates from ../Integrations, then serves http://localhost:3000
```

Then open <http://localhost:3000> — it redirects to the marketplace grid. Find your integration in the grid, or go straight to `http://localhost:3000/marketplace/<YourIntegrationName>` (the name with all non-alphanumeric characters removed).

## How it works

- On `npm start`, `generate-gallery.js` reads every folder in the repo-root `Integrations/` directory (including your unmerged edits) and generates the grid data + one page per integration.
- Edit files under `Integrations/<YourIntegration>/` — `integration_metadata.json`, the `OVERVIEW-*.md` docs, logos, script files — then restart `npm start` to see the changes.
- API Endpoints and Developer Docs are **out of scope** for the preview; those navbar links point at the public site.

## ⚠️ Do not hand-edit the synced engine

These paths are **synced automatically from the private `pan-dev-mim` repo** and will be overwritten — never edit them here:

- `preview/src/**`
- `preview/src/css/custom.css`
- `preview/generate-gallery.js`

If the marketplace *renders* something wrong (a layout bug, a broken tab, etc.), that's an engine issue — file it against `pan-dev-mim`, not here. This repo owns the *content* (`Integrations/`) and the preview *scaffold* (`preview/package.json`, `preview/docusaurus.config.ts`, `preview/sidebars.ts`, `preview/tsconfig.json`, `preview/src/pages/index.tsx`), not the rendering logic.

## Troubleshooting

- **My integration isn't in the grid.** Confirm `Integrations/<name>/integration_metadata.json` exists and is valid JSON, then restart.
- **A link warns in the console.** The preview uses `onBrokenLinks: warn` on purpose so in-progress content still renders; fix the link before opening your PR.
- **Stale output.** `npm run clear` then `npm start`.
