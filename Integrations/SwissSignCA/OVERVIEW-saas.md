# SwissSign CA Connector

Teams that use SwissSign certificates often request and renew them by hand, which makes policy hard to enforce and outages more likely. This CA connector lets Certificate Manager, SaaS issue, revoke and import certificates through your SwissSign Managed PKI (MPKI) account, so SwissSign certificates are managed alongside the rest of your machine identities.

**Value Highlights**

- **Issue from SwissSign**: Request SwissSign certificates through Certificate Manager, SaaS request policies.
- **Import existing certificates**: Bring certificates already issued from your SwissSign account into your inventory.
- **Revoke when needed**: Revoke SwissSign certificates from Certificate Manager, SaaS.
- **Enforce policy**: Apply your organization's request policies to SwissSign issuance.
- **Rotate keys without outages**: After you rotate the SwissSign service API key, the previous key keeps working for seven days while you update the connector.

**How it Works**

The connector is built on the CA Connector Framework and must be deployed to Certificate Manager, SaaS through the Dev Central API before it appears as a Certificate Authority Type. Each connector authenticates to the SwissSign RA API with an RA service account and service API key, and covers exactly one SwissSign Client. Create one connector for each Client in your account. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- SwissSign Managed PKI

**About SwissSign AG**

SwissSign is a recognized trust service provider (TSP) and provider of digital certificates, electronic signature solutions and identity services. Learn more at [swisssign.com](https://www.swisssign.com/).

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
