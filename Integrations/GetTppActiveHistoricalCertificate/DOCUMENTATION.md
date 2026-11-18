# Get-TppActiveHistoricalCertificate

This script can still be used, but the capability has been added to VenafiPS as `Search-TppHistory`, which can search on all attributes, not just active ones.

## Prerequisites

- VenafiPS PowerShell module, version 4.2.0 or later.
- PowerShell 7 or later.
- An account with access to the Certificate Manager, Self-Hosted WebSDK and the policy folders to search.

## Usage

1. Create a session with `New-VenafiSession`.
2. Run the script, optionally passing the starting policy path with `-Path` (default `\ved\policy`). The search is recursive.

```powershell
$certs = & .\Get-TppActiveHistoricalCertificate.ps1 -Path '\ved\policy\mycerts'
```

The script returns one object per certificate that has active historical versions, with these properties:

- `Path`: path to the current certificate.
- `ActiveHistory`: list of still-valid previous versions, each with `VaultId`, `Serial` and `ValidTo`.

The search covers the first 5,000 certificates found under the path. Run `Get-Help .\Get-TppActiveHistoricalCertificate.ps1 -Full` for full parameter help.
