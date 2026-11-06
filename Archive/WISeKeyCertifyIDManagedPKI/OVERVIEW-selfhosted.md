# WISeKey CertifyID Managed PKI

This integration uses the Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform) Adaptable CA framework to request, retrieve, renew, and revoke certificates from WISeKey CertifyID Managed PKI. The `WisekeyUra.ps1` driver calls the CertifyID Universal Registration Authority (URA) REST API so certificate lifecycle operations are automated and governed centrally from Venafi while WISeKey acts as the issuing CA.

## How it works

CertifyID Managed PKI is WISeKey's PKI-as-a-Service offering, delivered through the multi-tenant, multi-CA CertifyID URA, which exposes a REST API. The driver implements the Adaptable CA interface against that API. Requests are authenticated with a client certificate (PKCS#12) supplied through the Venafi credential plus an application identifier passed in the `X-App-ID` header (the driver `UserName`); all calls use TLS 1.2.

Supported Adaptable CA functions include `Test-Settings`, `Submit-CsrAsNew`, `Submit-CsrAsRenewal`, `Submit-CsrAsReplacement`, `Approve-Request`, `Retrieve-Certificate`, and `Revoke-Certificate`. Revocation reason codes 1–5 are supported.

## Prerequisites

- Certificate Manager, Self-Hosted (Trust Protection Platform)
- A WISeKey CertifyID Managed PKI account with URA access
- An application id, a PKCS#12 client certificate credential, and the URA configuration (host, user id, template id) for your tenant — obtained from WISeKey

## Installation and configuration

1. Deploy `WisekeyUra.ps1` to the Adaptable CA scripts directory on the Venafi server.
2. Set the environment-specific values near the top of the script: `app_host` (URA API base URL, e.g. `.../ura/api/v1/`), `userId`, and `templateId`. The shipped values point at a WISeKey demo environment and must be updated.
3. Configure the Adaptable CA template credential: set `UserName` to your application id and import the PKCS#12 client certificate/password (`PfxData`/`PfxPass`) for mutual-TLS to the URA.
4. Optionally add the `Validity Period` custom field (defaults to `1` when not supplied).

## Usage

The CSR subject (CN, OU, O, L, ST, C) and DNS SANs are taken from the certificate request built by Venafi and mapped to the URA request fields. Use the template's **Test** action to validate connectivity and authentication before issuing. See `DOCUMENTATION.md` for the full function and configuration reference.
