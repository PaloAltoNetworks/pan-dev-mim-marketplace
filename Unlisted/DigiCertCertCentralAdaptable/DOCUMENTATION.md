# venafi-cc-integration v1.6.7

This file (DigiCert_Adaptable_Script.ps1) has the basic functions supported by adaptable CA template:

- Test-Settings
- Submit-CsrAsNew
- Submit-CsrAsRenewal
- Submit-CsrAsReplacement
- Retrieve-Certificate
- Revoke-Certificate
- Get-ChainCertificates (Not implemented)
- Prepare-ForRequest (Not implemented)
- Approve-Request (Not implemented)

User can add DigiCert_Adaptable_Script.ps1 script in their Adaptable CA template, to call CC APIs through the script. Before using this template, user must configure following custom fields in TPP. Please note that these custom field names should be configured with exact name and value.

## Custom Fields

1. Product
2. ICA
3. Division
4. Locale
5. Server Platform
6. Organization
7. Order validity years
8. Order validity days
9. Order validity custom expiration date
10. Cert validity years
11. Cert validity days
12. Cert validity custom expiration date
13. Code Signing Provisioning Method
14. Server licenses
15. Profile option

The values which can be configured as part of custom field should as follows:

| Field name | Value | Example | Reference link |
| ----------- | ----------- | ----------- | ----------- |
| Product | `products.name`(`products.name_id`) | Secure Site EV SSL (ssl_ev_securesite) | Use CC API to get the product list https://www.digicert.com/services/v2/product |
| ICA | `intermediates.subject_common_name`(`intermediates.id`) | DigiCert SHA2 Secure Server CA (BFF28BD4075C8D9A) | Use CC API to get the ICA list https://www.digicert.com/services/v2/certificate/intermediates |
| Division | `containers.name`(`containers.id`) | Test Container (12345) | Use CC API to get the divisions https://www.digicert.com/services/v2/container |
| Locale | `language`(`code`) | English (en) | https://dev.digicert.com/glossary/#locale-codes |
| Server Platform | `platform`(`id`) | Apache (2) | https://dev.digicert.com/glossary/#server-platforms |
| Organization | `organizations.name`(`organizations.id`) | Test Organization (12345) | Use CC API to get the organizations https://www.digicert.com/services/v2/organization |
| Order validity years | `1-6`| 1 | Number of years the order is valid. (Range: 1-6) |
| Order validity days | `Positive Integer`| 1000 | Number of days the order is valid.(Overrides order_validity.years. Max: 2190) |
| Order validity custom expiration date | `Format: dd MMM YYYY`| 10 MAY 2021 | Overrides order_validity.days and order_validity.years.(Format: dd MMM YYYY) |
| Cert validity years | `1`| 1 | Number of years the certificate is valid after it is issued(Allowed value: 1)  |
| Cert validity days | `Positive Integer`| 300 | Overrides cert_validity.years.(Max: 397) |
| Cert validity custom expiration date | `Format: dd MMM YYYY`| 10 MAR 2021 | Validation Template : Custom Validation Regular Expression : ^[A-Za-z0-9\s]*$ |
| Code Signing Provisioning Method | `provisioning method`(`provisioning_method_name`) | Email(email) | https://dev.digicert.com/glossary/#Provisioning%20methods |
| Server licenses | `Positive Integer`| 5 | The number of server licenses you need for the certificate. |
| Profile option | `Profile option`(`Profile option name`) | intel_vpro_eku(intel_vpro_eku) | https://dev.digicert.com/glossary/#certificate-profile-options

Please note the following:

- The custom field value passed in small brackets will be parsed by the script, and will be used appropriately in API calls.
- The custom field value passed in small brackets should not have any leading or trailing spaces.
- The parameters passed in custom fields through script, will override $global parameters in the script.
- These parameters which are passed as custom fields, need to be configured only in TPP and not in Cert Central account.
- Regular CertCentral account-level custom fields should be configured the same in TPP and will work as expected.
- Additional properties such as additional emails, proxy, etc can be configured in script files, where parameters are defined between "START global configuration" and "END global configuration".
- The list of supported minimum versions of PowerShell and .NET are documented in the Glossary.
