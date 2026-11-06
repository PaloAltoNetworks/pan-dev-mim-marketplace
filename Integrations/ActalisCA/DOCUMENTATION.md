This file has the basic functions supported by adaptable CA template: 
- Test-Settings
- Submit-CsrAsNew
- Submit-CsrAsRenewal
- Submit-CsrAsReplacement
- Retrieve-Certificate
- Revoke-Certificate
- Get-ChainCertificates (Not implemented)
- Prepare-ForRequest (Not implemented)
- Approve-Request (Not implemented)

User can add Actalis_Adaptable_Script.ps1 script in their Adaptable CA template, to call Actalis API through the script. 
Please note that these custom field names should be configured with exact name and value.
​
## Custom Fields:
1. Actalis_Certificate_Class
2. Actalis_Validity_In_Months
3. Actalis_Reference_Email

Additional properties can be configured such as proxy server. These parameters are defined at the beginning of the script file and their values should be modified accordingly when needed.
Please see the [configuration guide](configuration-guide.pdf) file for more details on how to configure Venafi TLS Protect Datacenter.
​
## Prerequisites when creating a new certificate:
- The organization name attribute (O) of the subject DN must match an existing organization previuosly registered and validated by Actalis (see the CPS for the validated information reuse periods).
- The common name attribute (CN) of the subject DN is optional; when specified, it must also be added to the SAN list.
- The SAN list must always have at least 1 element.
- Every domain to be included in the certificate, or a parent domain of the same, must have been previously validated by Actalis (see the CPS for the domain validation reuse periods).
- There may be additional requirements for SSL EV and SSL QWAC certificates.
