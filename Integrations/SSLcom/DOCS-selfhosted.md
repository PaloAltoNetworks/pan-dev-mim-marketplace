# SSL.com Adaptable CA Driver

The `SSL.com_Adaptable_Script.ps1` driver lets an Adaptable CA template in Certificate Manager, Self-Hosted call the SSL.com web services API.

## Prerequisites

- Certificate Manager, Self-Hosted
- An SSL.com account (username and password) with access to the API

## Installation

1. Download `SSL.com_Adaptable_Script.ps1` from this listing.
2. Copy it to the Adaptable CA scripts folder on every Certificate Manager, Self-Hosted server (for example `C:\Program Files\Venafi\Scripts\AdaptableCA\`).

## Configuration

1. Create an Adaptable CA template and select `SSL.com_Adaptable_Script.ps1`.
2. Assign a credential with your SSL.com username and password.
3. Add the following custom fields to the template. Field names must match exactly.

| Field name | Function | Description | Example |
| --- | --- | --- | --- |
| email | Create new order | Contact information: admin email | jbob@domain.com |
| phone | Create new order | Contact information: admin phone number | 111-111-1111 |
| first_name | Create new order | Contact information: admin first name | Joe |
| last_name | Create new order | Contact information: admin last name | Bob |
| product | Create new order | The product code of the certificate being purchased | 104 |
| period | Create new order | The number of days the certificate is valid for | 90 |
| postal_code | Create new order | Postal code | 77098 |
| reason | Revoke certificate | The reason for the revocation | mistake |

## Covered Scenarios

The driver implements these Adaptable CA functions:

- `Test-Settings`
- `Submit-CsrAsNew`
- `Submit-CsrAsRenewal`
- `Submit-CsrAsReplacement`
- `Retrieve-Certificate`
- `Revoke-Certificate`

`Get-ChainCertificates`, `Prepare-ForRequest` and `Approve-Request` are not implemented.
