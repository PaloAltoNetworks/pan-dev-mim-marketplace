# DigiCert ONE

DigiCert ONE is DigiCert's unified certificate management platform, with centralized management of both public and private certificate authorities (CAs). Connecting DigiCert ONE to Certificate Manager, SaaS lets teams issue, renew, revoke and manage certificates from their DigiCert ONE CAs under central policy.

**Value Highlights**

- **Use public and private CAs**: Issue certificates from DigiCert ONE public and private CA profiles.
- **Automate the lifecycle**: Handle issuance, renewal and revocation from Certificate Manager, SaaS.
- **Map products to policy**: Choose which DigiCert ONE certificate products are available to each request policy.
- **Pick up new products**: Select product options added to your DigiCert ONE account later without re-creating the CA connection.
- **Get support from one vendor**: The connector is built and supported by Venafi.

**How it Works**

An administrator adds a DigiCert ONE certificate authority connector in Certificate Manager, SaaS, selects a VSatellite, and enters the DigiCert ONE base URL and API token. Only certificate profiles configured for REST API enrollment are available, and the Business Unit ID is taken from the selected profile. Organizations still on DigiCert CertCentral should use the DigiCert CertCentral listing instead. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS with at least one active VSatellite
- DigiCert ONE account with API access

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
