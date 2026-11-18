# SwissSign CA Connector

Teams that use SwissSign certificates often request and renew them by hand, which makes policy hard to enforce and outages more likely. This CA connector lets Next-Gen Trust Security issue, revoke and import certificates through your SwissSign Managed PKI (MPKI) account, so SwissSign certificates are managed alongside the rest of your machine identities.

**Value Highlights**

- **Issue from SwissSign**: Request SwissSign certificates through Next-Gen Trust Security request policies.
- **Import existing certificates**: Bring certificates already issued from your SwissSign account into your inventory.
- **Revoke when needed**: Revoke SwissSign certificates from Next-Gen Trust Security.
- **Enforce policy**: Apply your organization's request policies to SwissSign issuance.
- **Rotate keys without outages**: After you rotate the SwissSign service API key, the previous key keeps working for seven days while you update the connector.

**How it Works**

The connector is built on the CA Connector Framework and must be deployed to Next-Gen Trust Security through the Dev Central API before it appears as a Certificate Authority Type. Each connector authenticates to the SwissSign RA API with an RA service account and service API key, and covers exactly one SwissSign Client. Create one connector for each Client in your account. See the Documentation tab for setup.

**Solution Components**

- Next-Gen Trust Security
- SwissSign Managed PKI

**About SwissSign AG**

SwissSign is a recognized trust service provider (TSP) and provider of digital certificates, electronic signature solutions and identity services. Learn more at [swisssign.com](https://www.swisssign.com/).
