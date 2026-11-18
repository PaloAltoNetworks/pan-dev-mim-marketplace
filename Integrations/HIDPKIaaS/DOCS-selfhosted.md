# HID PKIaaS Adaptable CA Driver

`HID_PKIaaS_Adaptable_CA_Driver.ps1` is a PowerShell Adaptable CA driver that connects Certificate Manager, Self-Hosted to HID PKI-as-a-Service (PKIaaS) for issuance, renewal, replacement and revocation of certificates.

## Prerequisites

- **Certificate Manager, Self-Hosted**: installed and configured in your environment.
- **HID PKIaaS account**: API credentials (API ID and key) for the HID PKIaaS API. The driver authenticates with Hawk.
- **PowerShell**: the ability to run PowerShell scripts on the Certificate Manager, Self-Hosted servers where the driver is deployed.

## Installation

1. Download `HID_PKIaaS_Adaptable_CA_Driver.ps1` (and, if you need custom fields, `HID_PKIaaS_Create_Custom_Fields.ps1`) from this listing.
2. Copy the driver script to the Adaptable CA driver directory of your Certificate Manager, Self-Hosted installation.
3. Make sure the PowerShell execution policy allows the script to run:

   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope Process
   ```

## Configuration

1. In Certificate Manager, Self-Hosted, add a new Adaptable CA template and select the HID PKIaaS Adaptable CA driver.
2. Provide these parameters:
   - **ServiceAddress**: the base URL of the HID PKIaaS API.
   - **UserName**: your HID PKIaaS API ID.
   - **UserPass**: your HID PKIaaS API key.
   - **ProfileString**: the policy ID configured in HID PKIaaS.
3. (Optional) Create custom fields to set certificate validity periods and custom extensions. `HID_PKIaaS_Create_Custom_Fields.ps1` creates them; contact your HID account representative first for the list of fields your account needs. The driver reads these fields:
   - `HydrantID ACM: Validity Days`
   - `HydrantID ACM: Validity Months`
   - `HydrantID ACM: Validity Years`
   - `AEP: Application Policies`
   - `AEP: Certificate Template`

## Usage

Certificate Manager, Self-Hosted calls these driver functions during certificate operations:

- **Test-Settings**: validates connectivity and authentication with HID PKIaaS.
- **Submit-CsrAsNew**: submits a new certificate signing request (CSR) for issuance.
- **Submit-CsrAsRenewal**: submits a CSR to renew an existing certificate.
- **Submit-CsrAsReplacement**: submits a CSR to replace an existing certificate.
- **Retrieve-Certificate**: retrieves the issued certificate once HID PKIaaS has processed it.
- **Revoke-Certificate**: revokes an existing certificate.

## Troubleshooting

- **Debug logging**: the driver includes debug logging, which you can enable and direct to a file by modifying the script.
- **Error messages**: use the `Format-Error` function output for detail on failed API calls.

## Security Notes

- Store the API credentials (`UserName` and `UserPass`) securely.
- Modification of the script is permitted only to update configuration details. Sharing or other modification requires consent from Venafi.

## License and Support

This driver is licensed by HydrantID in addition to Venafi and is provided for integrating with HID PKIaaS services.

- **CyberArk support**: [CyberArk Community](https://community.cyberark.com/s/)
- **HID PKIaaS support**: your HID account representative, or acmsupport@hidglobal.com
