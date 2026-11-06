# OpenXPKI Adaptable CA

This document describes the `OpenXPKI-AdaptableCA.ps1` Adaptable CA driver, which
integrates the open-source [OpenXPKI](https://www.openxpki.org) certificate
authority with Venafi Certificate Manager, Self-Hosted (the product formerly
known as Venafi Trust Protection Platform). The driver lets Venafi request,
retrieve, and revoke certificates from an OpenXPKI CA through OpenXPKI's RPC
(Remote Procedure Call) API.

The driver implements the standard Adaptable CA PowerShell function set. The
following functions are supported:

- `Test-Settings` — implemented (connectivity/health check)
- `Submit-CsrAsNew` — implemented
- `Submit-CsrAsRenewal` — implemented (calls `Submit-CsrAsNew` internally)
- `Submit-CsrAsReplacement` — implemented (calls `Submit-CsrAsNew` internally)
- `Retrieve-Certificate` — implemented (calls `Submit-CsrAsNew` internally)
- `Revoke-Certificate` — implemented
- `Get-ChainCertificates` — not implemented (returns `NotUsed`)
- `Prepare-ForRequest` — not implemented (returns `NotUsed`)
- `Approve-Request` — not implemented (returns `NotUsed`)

## How it works

OpenXPKI exposes its certificate workflows over an HTTP/HTTPS RPC endpoint. The
driver communicates with that endpoint (configured in the script's `$base_url`
variable, e.g. `https://<openxpki-host>/rpc/venafi`) and maps Venafi's Adaptable
CA calls to OpenXPKI RPC methods:

- **Enrollment** — `Submit-CsrAsNew` posts the Base64 PKCS#10 CSR (wrapped in
  the `-----BEGIN/END CERTIFICATE REQUEST-----` markers, with stray line breaks
  stripped) to the `RequestCertificate` RPC method as the `pkcs10` parameter.
  On a `SUCCESS` state, the driver concatenates the issued certificate with its
  chain and returns it to Venafi as PKCS#7, along with the OpenXPKI
  `cert_identifier` used as the transaction ID (`TransId`).

- **Renewal and replacement** — both are handled by resubmitting through
  `Submit-CsrAsNew`.

- **Revocation** — `Revoke-Certificate` posts to the
  `RevokeCertificateByIdentifier` RPC method, passing the certificate identifier
  (`cert_identifier`), a reason code, and a comment. Venafi revocation reason
  codes are mapped as: 1 (Key Compromised), 3 (Affiliation Changed), 4
  (Superseded); all other codes map to UNSPECIFIED.

- **Connectivity test** — `Test-Settings` calls the OpenXPKI `healthcheck/ping`
  endpoint and reports success when the CA responds.

Authentication to the OpenXPKI RPC endpoint uses a PKCS#12 (`.pfx`) client
certificate and its password, supplied through the Adaptable CA "General"
parameters (`PfxData`/`PfxPass`). Username/password fields are not used by this
driver.

## Prerequisites

Before configuring this integration, the following must be in place:

- Venafi Certificate Manager, Self-Hosted (Trust Protection Platform).
- A running OpenXPKI instance with the RPC server enabled and a workflow exposed
  for certificate requests (and, for revocation, one exposed for revocation by
  identifier). See the OpenXPKI documentation:
  <https://openxpki.readthedocs.io>.
- A client certificate (PKCS#12) trusted by OpenXPKI for authenticating RPC
  calls, if the RPC endpoint requires client-certificate authentication.

## Installation and configuration

1. Deploy `OpenXPKI-AdaptableCA.ps1` to the Adaptable CA scripts directory on the
   Venafi server (for example
   `C:\Program Files\Venafi\Scripts\AdaptableCA\`).
2. Edit the script's `$base_url` (and the health-check URL used by
   `Test-Settings`) to point at your OpenXPKI RPC endpoint.
3. In the Venafi platform, create an Adaptable CA template that references the
   script and supply the PKCS#12 client certificate and password used to
   authenticate to OpenXPKI.
4. Use the template's "Test" action, which invokes `Test-Settings`, to confirm
   connectivity before issuing certificates.

## Notes

- The `$base_url` value shipped in the script points at a demonstration OpenXPKI
  instance and must be changed to your own environment.
- The RPC method and parameter names above (`RequestCertificate`,
  `RevokeCertificateByIdentifier`, `pkcs10`, `cert_identifier`) reflect what the
  driver sends; the corresponding workflows must be configured and exposed on the
  OpenXPKI side under matching RPC endpoint names.
- Revocation support depends on the revocation RPC endpoint being available in
  your OpenXPKI deployment.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
