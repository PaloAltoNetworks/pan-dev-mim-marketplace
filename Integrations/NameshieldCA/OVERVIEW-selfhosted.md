# Nameshield CA

Organizations that buy public TLS certificates from Nameshield often manage them in a separate portal, which leaves gaps in inventory and makes renewals easy to miss. The Nameshield CA connector lets Certificate Manager, Self-Hosted order, renew and revoke Nameshield certificates and import your existing Nameshield portfolio, so public certificates follow the same policy and automation as the rest of your machine identities.

**Value Highlights**

- **Order certificates from policy**: Request new Nameshield certificates for a chosen organization and product directly from Certificate Manager, Self-Hosted.
- **Renew and replace without the portal**: Reissue or replace existing certificates, keeping the original product.
- **Import your portfolio**: Bring every certificate in your Nameshield account into inventory, optionally including revoked and expired certificates.
- **Revoke centrally**: Revoke any Nameshield certificate that Certificate Manager, Self-Hosted manages or has imported.
- **See errors where you work**: Messages returned by the Nameshield API are displayed in Certificate Manager, Self-Hosted.

**How it Works**

The connector is an Adaptable CA PowerShell driver (`NameShield.ps1`) that calls the Nameshield SSL API v2 using an API access token. A CA template in Certificate Manager, Self-Hosted supplies the token, the Nameshield product ID and the organization ID, plus optional scope and analytical account values. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Nameshield Certificate Area (Nameshield SSL API v2)

**About Nameshield**

[Nameshield](https://www.nameshield.com/en/) provides domain name management and digital certificate services.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
