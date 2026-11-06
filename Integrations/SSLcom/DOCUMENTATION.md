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

User can add SSL.com_Adaptable_Script.ps1 script in their Adaptable CA template, to call SSL.com API through the script. 
Please note that these custom field names should be configured with exact name and value.

Custom Fields:
--------------
1. email
2. phone
3. first_name
4. last_name
5. reason
6. product
7. period
8. postal_code

The values which can be configured as part of custom field should as follows:	

| Field name | Function | Description | Example |
| --- | --- | --- | --- |
| email | Create new order | Contact information: Admin email | jbob@domain.com |
| phone | Create new order | Contact information: Admin phone number | 111-111-1111	|
| first_name | Create new order | Contact information: Admin first name | Joe |					
| last_name | Create new order | Contact information: Admin last name |	Bob	|
| product | Create new order | The product code of the certificate being purchased | 104 |
| period | Create new order | The number of days the certificate is valid for | 90 |
| postal_code | Create new order | Postal Code | 77098 |
| reason | Revoke certificate |	The reason for this revocation | mistake |