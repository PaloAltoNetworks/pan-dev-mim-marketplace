# Get-TppActiveHistoricalCertificate

When a certificate is renewed, earlier versions often remain valid until they expire. Those still-active historical certificates can be in use somewhere, and they matter during key compromise response, revocation planning and audits.

`Get-TppActiveHistoricalCertificate` is a community PowerShell script that finds historical certificates in Certificate Manager, Self-Hosted that are still within their validity period.

This script can still be used, but the same capability is now part of the VenafiPS module as `Search-TppHistory`, which can search on all attributes, not only active ones.

**Value Highlights**

- **Find active historical certificates** across a policy folder and its subfolders.
- **Support revocation and incident response** by listing previous versions that are still valid.
- **Build on VenafiPS**, the widely used PowerShell module for Certificate Manager, Self-Hosted.
- **Search quickly** with parallel processing of certificate history.

**How it Works**

The script uses an existing VenafiPS session to search certificates under a starting policy path (by default `\ved\policy`), retrieves each certificate's previous versions through the WebSDK API, and returns the path of each certificate with its still-valid previous versions (vault ID, serial number and expiry date). See the Documentation tab for prerequisites and usage.

**Solution Components**

- Certificate Manager, Self-Hosted
- VenafiPS PowerShell module

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
