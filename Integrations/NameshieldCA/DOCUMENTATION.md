# Nameshield CA Connector

This guide covers configuring the Nameshield CA connector (`NameShield.ps1`) for Certificate Manager, Self-Hosted. The connector manages the lifecycle of public certificates issued through the Nameshield Certificate Area.

## Prerequisites

- Certificate Manager, Self-Hosted
- A Nameshield Certificate Area account

## Installation

1. Download `NameShield.ps1` from this listing.
2. Copy it to the Adaptable CA scripts folder on every Certificate Manager, Self-Hosted server (for example `C:\Program Files\Venafi\Scripts\AdaptableCA\`).

## Configuration

Collect the following from Nameshield before you configure the connector:

1. An API access token.
2. Your organization ID.
3. The product ID.
4. Optional billing information (scope ID and analytical account).

For any question about these values, contact the Nameshield Certificates team.

The connector uses these settings:

```powershell
# Address of the Nameshield API
$global:ServiceAddress = "https://api.nameshield.net/ssl/v2";

# Nameshield Access Token
$global:UserPass = "YOUR TOKEN";

# Product identification
$global:ProfileString = "PRODUCT ID";

# Organization identification
$global:CustomFields:organization = "ORGANISATION ID";

# Nameshield scope identification (optional)
$global:CustomFields:scopeNms = "SCOPE ID";

# Analytical Account (optional)
$global:CustomFields:analyticalAccount = "ANALYTICAL ACCOUNT";
```

## Usage

### Retrieve all certificates in your portfolio

This operation retrieves every certificate in your Nameshield portfolio. It does not filter by organization, so you receive all of your certificates.

### Order a new certificate

Orders a certificate attached to the specified organization and product.

### Renew or replace an existing certificate

During a reissue or replacement the organization can be changed. The original product is kept.

### Revoke a certificate

Any certificate managed or retrieved by Certificate Manager, Self-Hosted can be revoked. Organization and product are not required for revocation.

## Troubleshooting

If an error occurs, the connector returns an error message that is displayed in Certificate Manager, Self-Hosted. Copy the message and contact the Nameshield Certificates team at certificates@nameshield.net.
