# GlobalSign Atlas Adaptable CA Driver

GlobalSign Atlas integrates with Certificate Manager, Self-Hosted for lifecycle management of GlobalSign certificates. The driver automates issuance, revocation and deployment of certificates for public and private CA use cases:

- Public trust TLS/SSL.
- Private dedicated TLS/SSL, issued from your dedicated private CA hierarchy hosted by GlobalSign.
- Machine and device authentication certificates, issued from your dedicated private CA hierarchy hosted by GlobalSign.
- Public trust S/MIME certificates for secure email.

Terms of use are governed by your agreement with GMO GlobalSign for Atlas services, together with your agreement for Certificate Manager, Self-Hosted.

## Prerequisites

- A [GlobalSign Atlas](https://www.globalsign.com/en/atlas) service, with an API key, API secret and client authentication certificate created in your Atlas account.
- Certificate Manager, Self-Hosted.

## Installation

1. Copy `GMO_GlobalSign_Atlas_Adaptable_Script_1_0_5.ps1` to the `Scripts\AdaptableCA` folder under the Certificate Manager, Self-Hosted installation folder on every server.
2. If needed, edit the configuration block at the top of the script:
   - `$global:api_base_url`: Atlas API base URL, used when the CA template does not set one. Default `https://emea.api.hvca.globalsign.com:8443/v2`.
   - `$global:signature_hash`: default signature hash, `SHA-256`.
   - `$global:proxy_url`: proxy URL, for example `http://proxy.corp.local:8080`. Leave empty for no proxy.
   - `$global:proxy_required`: set to `$true` to fail requests when no proxy URL is configured.

## Configuration

Create an Adaptable CA template that uses the driver, with the Atlas API key and secret as the credential and the client certificate (PKCS #12 file and password) for mutual TLS. Optional proxy credentials can be set as the auxiliary credential on the CA template. Otherwise the system's default credentials are used for the proxy.

## Supported API Operations

- `/login` POST: authenticates with `api_key` and `api_secret` from your Atlas account. The returned token is used for other requests and is valid for 10 minutes.
- `/certificates` POST: submits a request for a new certificate with the certificate fields below.
- `/certificates/{certificate}` GET: retrieves a certificate by serial number.
- `/certificates/{certificate}` PATCH: revokes a certificate by serial number.
- `/certificates/{certificate}/rekey` POST: submits a rekey request for an existing issued certificate with the rekey fields below.
- `/trustchain` GET: retrieves the chain of trust for certificates in your account, from the issuing CA to the root CA.

## Certificate Fields

New certificate requests use:

- CSR
- Validity not after (custom field, default now)
- Validity not before (custom field)
- Hash algorithm (custom field, default SHA-256)
- SAN domain
- Email
- URI
- Other names
- Common name
- OU (not allowed for public TLS)

Rekey requests use:

- CSR
- Hash algorithm (custom field, default SHA-256)

## Support

For help setting up a GlobalSign Atlas service, contact your GlobalSign account manager or `solutions@globalsign.com`. For general queries, contact `technology-alliance@globalsign.com`.
