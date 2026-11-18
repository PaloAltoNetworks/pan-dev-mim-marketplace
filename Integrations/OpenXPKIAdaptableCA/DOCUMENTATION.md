# OpenXPKI Adaptable CA

This guide covers the `OpenXPKI-AdaptableCA.ps1` Adaptable CA driver, which lets Certificate Manager, Self-Hosted request, retrieve and revoke certificates from an [OpenXPKI](https://www.openxpki.org) CA through its RPC (Remote Procedure Call) API.

## Prerequisites

- Certificate Manager, Self-Hosted
- A running OpenXPKI instance with the RPC server enabled and a workflow exposed for certificate requests (and, for revocation, one exposed for revocation by identifier). See the [OpenXPKI documentation](https://openxpki.readthedocs.io).
- A PKCS#12 client certificate trusted by OpenXPKI for authenticating RPC calls, if the RPC endpoint requires client-certificate authentication

## Installation

1. Copy `OpenXPKI-AdaptableCA.ps1` to the Adaptable CA scripts directory on each Certificate Manager, Self-Hosted server (for example `C:\Program Files\Venafi\Scripts\AdaptableCA\`).
2. Edit the script's `$base_url` (and the health-check URL used by `Test-Settings`) to point at your OpenXPKI RPC endpoint, for example `https://<openxpki-host>/rpc/venafi`. The shipped value points at a demonstration OpenXPKI instance and must be changed.

## Configuration

1. In Certificate Manager, Self-Hosted, create an Adaptable CA template that references the script.
2. Supply the PKCS#12 client certificate and its password used to authenticate to OpenXPKI (`PfxData`/`PfxPass`). Username and password fields are not used by this driver.
3. Use the template's **Test** action, which invokes `Test-Settings`, to confirm connectivity before issuing certificates.

## Covered Scenarios

The driver implements the standard Adaptable CA PowerShell function set:

- `Test-Settings`: implemented (calls the OpenXPKI `healthcheck/ping` endpoint)
- `Submit-CsrAsNew`: implemented
- `Submit-CsrAsRenewal`: implemented (calls `Submit-CsrAsNew` internally)
- `Submit-CsrAsReplacement`: implemented (calls `Submit-CsrAsNew` internally)
- `Retrieve-Certificate`: implemented (calls `Submit-CsrAsNew` internally)
- `Revoke-Certificate`: implemented
- `Get-ChainCertificates`: not implemented (returns `NotUsed`)
- `Prepare-ForRequest`: not implemented (returns `NotUsed`)
- `Approve-Request`: not implemented (returns `NotUsed`)

**Enrollment.** `Submit-CsrAsNew` posts the Base64 PKCS#10 CSR (wrapped in the `-----BEGIN/END CERTIFICATE REQUEST-----` markers, with stray line breaks stripped) to the `RequestCertificate` RPC method as the `pkcs10` parameter. On a `SUCCESS` state, the driver concatenates the issued certificate with its chain and returns it as PKCS#7, along with the OpenXPKI `cert_identifier` used as the transaction ID (`TransId`).

**Renewal and replacement.** Both are handled by resubmitting through `Submit-CsrAsNew`.

**Revocation.** `Revoke-Certificate` posts to the `RevokeCertificateByIdentifier` RPC method, passing the certificate identifier (`cert_identifier`), a reason code and a comment. Revocation reason codes are mapped as 1 (Key Compromised), 3 (Affiliation Changed) and 4 (Superseded). All other codes map to UNSPECIFIED.

## Troubleshooting

- The RPC method and parameter names (`RequestCertificate`, `RevokeCertificateByIdentifier`, `pkcs10`, `cert_identifier`) reflect what the driver sends. The corresponding workflows must be configured and exposed on the OpenXPKI side under matching RPC endpoint names.
- Revocation depends on the revocation RPC endpoint being available in your OpenXPKI deployment.
