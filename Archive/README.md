# Archived Integrations

This directory holds integrations that are **no longer supported**. They are retained here
so their full history stays in the repository, but they are intentionally kept **outside**
`Integrations/` so that they are:

- **not synced** to the downstream `pan-dev-mim` docs repo,
- **not rendered** in the integration gallery (`docs/generate-gallery.js` only scans `Integrations/`),
- **not validated** by CI (`scripts/validate-integration.js` only scans `Integrations/`).

## Why moving out of `Integrations/` is enough

The marketplace → `pan-dev-mim` sync is a full-mirror rsync that only ever reads this repo's
`Integrations/` directory (`pan-dev-mim/.gitlab/scripts/sync-integrations.sh`), run with
`--delete-after`. So anything moved out of `Integrations/` is removed from the downstream
copy automatically on the next sync, and nothing in `Archive/` is ever copied over.

## How to archive an integration

```
git mv Integrations/<Name> Archive/<Name>
```

Commit and merge to `main`. The next `sync_from_marketplace` pipeline run removes the folder
from `pan-dev-mim/Integrations/` automatically. Git history is preserved — inspect it with:

```
git log --follow Archive/<Name>/integration_metadata.json
```

## How to restore an integration

```
git mv Archive/<Name> Integrations/<Name>
```

On the next sync it reappears downstream and in the gallery.
