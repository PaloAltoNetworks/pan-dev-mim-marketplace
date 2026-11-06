# WISeKey CertifyID Managed PKI

This integration lets Venafi request, retrieve, renew, and revoke certificates from WISeKey CertifyID Managed PKI using the Venafi Adaptable CA framework. The included PowerShell driver (`WisekeyUra.ps1`) calls the CertifyID Universal Registration Authority (URA) REST API so that certificate lifecycle operations can be automated and governed centrally from Venafi while WISeKey acts as the issuing Certificate Authority.

## How it works

CertifyID Managed PKI is WISeKey's PKI-as-a-Service offering. It is delivered through the CertifyID Universal Registration Authority (URA), a multi-tenant, multi-CA certificate management solution that exposes a REST API for programmatic certificate management. This driver implements the Venafi Adaptable CA interface against that URA API.

Requests are authenticated to the URA using a client certificate (PKCS#12) supplied through the Venafi credential, together with an application identifier passed in the `X-App-ID` HTTP header (the driver `UserName`). All calls are made over TLS 1.2.

## Adaptable CA functions

The driver implements the standard Adaptable CA framework functions:

| Function | Behavior |
| --- | --- |
| `Test-Settings` | Validates connectivity and authentication against the URA `authentication` endpoint. |
| `Submit-CsrAsNew` | Submits a PKCS#10 CSR to the URA (`request/submit`) and returns the request id as the transaction id. |
| `Submit-CsrAsRenewal` | Renews an existing certificate (delegates to `Submit-CsrAsNew`). |
| `Submit-CsrAsReplacement` | Replaces an existing certificate (delegates to `Submit-CsrAsNew`). |
| `Approve-Request` | Approves a previously submitted request (`request/approve`). |
| `Retrieve-Certificate` | Retrieves the issued certificate by request id (`certificate/getbyrequest`) and returns it as PKCS#7. |
| `Revoke-Certificate` | Revokes an issued certificate (`certificate/revoke`) using a revocation reason code and optional comment. |
| `Get-ChainCertificates` | Not used (returns `NotUsed`). |
| `Prepare-ForRequest` | Not used (returns `NotUsed`). |

Supported revocation reason codes are: 1 (User Key Compromised), 2 (CA Key Compromised), 3 (User Changed Affiliation), 4 (Certificate Superseded), and 5 (Original Use No Longer Valid).

## Configuration

Before use, set the environment-specific values near the top of `WisekeyUra.ps1`:

| Setting | Description |
| --- | --- |
| `app_host` | Base URL of the CertifyID URA API (for example, the URA `.../ura/api/v1/` endpoint for your tenant). |
| `userId` | The CertifyID URA user id used when building the request. |
| `templateId` | The CertifyID certificate template id used to issue certificates. |

Authentication is provided through the Venafi CA template credential:

| Credential / field | Description |
| --- | --- |
| `UserName` | Application id sent in the `X-App-ID` request header. |
| Client certificate (PfxData / PfxPass) | PKCS#12 client certificate and password used for mutual-TLS authentication to the URA. |

An optional Adaptable CA custom field is supported:

| Custom field | Description |
| --- | --- |
| `Validity Period` | Requested certificate validity period. Defaults to `1` when not supplied. |

The CSR subject (CN, OU, O, L, ST, C) and DNS Subject Alternative Names are taken from the certificate request built by Venafi and mapped to the corresponding URA request fields.

## Notes

The endpoint values shipped in the script point at a WISeKey demo environment and must be updated to your production CertifyID URA host, user id, and template id before use. Contact WISeKey to obtain the application id, client certificate credential, and URA configuration for your account.
