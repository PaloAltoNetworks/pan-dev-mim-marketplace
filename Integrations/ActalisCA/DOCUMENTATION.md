# Actalis SSL

## Prerequisites

- A contract with Actalis for SSL certificates, and the Certificate Credential that Actalis provides.
- Domain Control Validation completed for every domain you want in your certificates.
- When you request a certificate:
  - The organization (O) attribute of the subject DN must match an organization that Actalis has registered and validated. See the CPS for validated information reuse periods.
  - The common name (CN) is optional. If you set it, also add it to the SAN list.
  - The SAN list must contain at least one entry.
  - Every domain in the certificate, or a parent domain, must have been validated by Actalis. See the CPS for domain validation reuse periods.
  - SSL EV and SSL QWAC certificates may have additional requirements.

## Installation

1. Copy `Actalis_Adaptable_Script.ps1` to the Adaptable CA scripts folder on each Certificate Manager, Self-Hosted server.
2. Copy your Certificate Credential to the Certificate Manager, Self-Hosted server.
3. If you connect through a proxy, set `$global:proxy_url`, `$global:proxy_user` and `$global:proxy_password` at the beginning of the script.

## Configuration

1. In Certificate Manager, Self-Hosted, go to **Configuration > Custom Fields** and create these custom fields with these exact names:
   - `Actalis_Certificate_Class`
   - `Actalis_Validity_In_Months`
   - `Actalis_Reference_Email`
2. Go to **Configuration > CA Templates** and create an Adaptable CA template that uses `Actalis_Adaptable_Script.ps1`.
3. Go to **Configuration > Folders** and assign the Actalis CA template to the certificate folder of your choice.

See the [configuration guide](configuration-guide.pdf) for full details.

## Usage

1. In the certificate inventory, click **Create a New Certificate**.
2. Select the folder that uses the Actalis CA template.
3. Enter the request data, such as the certificate class, domains and organization.
4. Submit the request. The certificate is normally issued within seconds.

Renewal, revocation and other lifecycle operations work as for any other CA.

## Covered Scenarios

The driver implements these Adaptable CA functions:

- Test-Settings
- Submit-CsrAsNew
- Submit-CsrAsRenewal
- Submit-CsrAsReplacement
- Retrieve-Certificate
- Revoke-Certificate

Get-ChainCertificates, Prepare-ForRequest and Approve-Request are not implemented.
