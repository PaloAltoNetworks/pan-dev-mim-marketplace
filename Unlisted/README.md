# Unlisted Integrations

This directory holds integrations that are **not listed yet**. Unlike `Archive/`, they are
still supported or in progress; they are only held back from the Marketplace for now.

Like `Archive/`, anything here sits outside `Integrations/`, so it is not synced to
`pan-dev-mim`, not rendered in the gallery and not validated by CI.

## How to unlist an integration

```
git mv Integrations/<Name> Unlisted/<Name>
```

Then add a redirect for its page to `Integrations/.route-aliases.json`, so the old URL doesn't stay live:

```json
{ "from": "/marketplace/<RouteId>", "to": "/marketplace", "reason": "unlisted — remove this entry when the listing returns" }
```

`<RouteId>` is the listing's `name` with every character that isn't a letter or digit removed.

## How to list it

```
git mv Unlisted/<Name> Integrations/<Name>
```

Remove its entry from `Integrations/.route-aliases.json`.

Commit and merge to `main`; the next sync adds it to the site.

## Currently unlisted

- `AcmetekCertificateServices`: held back until the partner's support details are confirmed.
- `IDnomicAdaptableCA` (Eviden IDnomic PKI): held back pending partner confirmation. Its
  supportUrl already points at https://eviden.com/en/contact.
- `NousNCert`: held back until the partner's site and support details are confirmed.
- `OracleOperaAdaptableApp`: held back for now. When it returns, also remove its `/marketplace/OracleOperaAdaptableApp` entry from `Integrations/.route-aliases.json`.

## Unlisted variants

A variant can be held back without unlisting the whole integration: remove it from
`products` and `productVariants`, and record the removed entry here so it can be put back.

- `EJBCAEnterprise`, Certificate Manager Self-Hosted: held back because it has no script or
  README to download (the EJBCA Enterprise w/ Custom Serial Number listing is a separate
  integration from an external developer). `OVERVIEW-selfhosted.md` stays in the folder.
  Restore by adding "Certificate Manager Self-Hosted" back to `products` and this entry to
  `productVariants` once a proper download and docs exist:

  ```json
  {
    "product": "Certificate Manager Self-Hosted",
    "documentationLinks": [
      {
        "title": "Certificate Manager SaaS Documentation",
        "url": "https://docs.venafi.cloud/vaas/certificates/ca/custom-ca/r-ejbca-example/"
      }
    ]
  }
  ```
