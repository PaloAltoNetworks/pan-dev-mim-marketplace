# OpenXPKI Adaptable CA

The `OpenXPKI-AdaptableCA.ps1` Adaptable CA driver integrates the open-source [OpenXPKI](https://www.openxpki.org) certificate authority with Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform), letting Venafi request, retrieve, renew, and revoke certificates from OpenXPKI through its RPC (Remote Procedure Call) API.

## How it works

The driver maps Venafi's Adaptable CA calls to OpenXPKI RPC methods over an HTTP/HTTPS endpoint (configured in the script's `$base_url`, e.g. `https://<openxpki-host>/rpc/venafi`):

- **Enrollment** — `Submit-CsrAsNew` posts the Base64 PKCS#10 CSR to the `RequestCertificate` method and returns the issued certificate plus chain as PKCS#7, using the OpenXPKI `cert_identifier` as the transaction ID.
- **Renewal and replacement** — both resubmit through `Submit-CsrAsNew`.
- **Revocation** — `Revoke-Certificate` posts to `RevokeCertificateByIdentifier` with the identifier, reason code, and comment.
- **Connectivity test** — `Test-Settings` calls the OpenXPKI `healthcheck/ping` endpoint.

Authentication uses a PKCS#12 (`.pfx`) client certificate and password supplied through the Adaptable CA General parameters (`PfxData`/`PfxPass`).

## Prerequisites

- Certificate Manager, Self-Hosted (Trust Protection Platform)
- A running OpenXPKI instance with the RPC server enabled and workflows exposed for certificate requests (and for revocation by identifier). See <https://openxpki.readthedocs.io>.
- A PKCS#12 client certificate trusted by OpenXPKI, if the RPC endpoint requires client-certificate authentication

## Installation and configuration

1. Deploy `OpenXPKI-AdaptableCA.ps1` to the Adaptable CA scripts directory on the Venafi server (for example `C:\Program Files\Venafi\Scripts\AdaptableCA\`).
2. Edit the script's `$base_url` (and the `Test-Settings` health-check URL) to point at your OpenXPKI RPC endpoint. The shipped value points at a demo instance and must be changed.
3. Create an Adaptable CA template that references the script and supply the PKCS#12 client certificate and password.
4. Use the template's **Test** action (which invokes `Test-Settings`) to confirm connectivity before issuing certificates.

## Notes

The RPC method and parameter names (`RequestCertificate`, `RevokeCertificateByIdentifier`, `pkcs10`, `cert_identifier`) must match workflows exposed on the OpenXPKI side. Revocation support depends on the revocation RPC endpoint being available. See `DOCUMENTATION.md` for the full function set and details.
