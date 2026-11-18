# Export from Certificate Manager, SaaS into Self-Hosted

Organizations that run both Certificate Manager, SaaS and Certificate Manager, Self-Hosted can end up with certificate inventory split across the two. This community command-line utility, `vcloud2tpp`, exports certificates from a Certificate Manager, SaaS account inventory and imports them into a policy folder in Certificate Manager, Self-Hosted, so the Self-Hosted inventory includes certificates first found in SaaS.

It was created for Self-Hosted customers looking for a TrustNet-like inventory feed. The source is provided as a buildable Go project.

**Value Highlights**

- **Consolidate inventory** by bringing certificates from Certificate Manager, SaaS into Certificate Manager, Self-Hosted.
- **Use a standard API** through the WebSDK `POST discovery/import` method, the same endpoint the Scanafi discovery utility uses.
- **Choose the destination** by targeting any policy folder you specify.
- **Run incremental syncs** with a configurable batch size and a "last N days" filter.
- **Troubleshoot imports** with optional debug output showing the import JSON and any skipped certificates.

**How it Works**

The utility searches the Certificate Manager, SaaS certificate inventory using an API key, downloads each certificate, and posts the batch to the Certificate Manager, Self-Hosted WebSDK discovery import endpoint using an access token with the `certificate:discover` scope. See the Documentation tab for build steps, parameters and an example.

**Solution Components**

- Certificate Manager, Self-Hosted (destination)
- Certificate Manager, SaaS account (source)
- `vcloud2tpp` command-line utility built from the included source

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
