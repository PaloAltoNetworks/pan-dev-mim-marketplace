# Entrust CA Gateway

Entrust CA Gateway puts a single API in front of one or more back-end Entrust certificate authorities. Certificate Manager, SaaS connects to the gateway through a connector built on the Venafi CA Connector Framework, so you can issue, revoke and import certificates from every authority and profile the gateway fronts with one connection.

**Value Highlights**

- **Cover many CAs with one connector**: every authority and profile behind the gateway is offered as a product, so you don't add a connector per CA.
- **Issue under your policies**: map gateway profiles to request policies so certificates are requested under your rules.
- **Respect gateway approvals**: when a profile has an approval workflow, Certificate Manager, SaaS waits for approval at the gateway and records the certificate once issued.
- **Import existing certificates**: bring certificates from the gateway into your inventory on demand or on a schedule, with optional expired and revoked certificates.
- **Authenticate without shared secrets**: the connector uses mutual TLS with a client certificate, so there is no API token or password to manage.

**How it Works**

This is a custom CA connector. After the Entrust CA Gateway connector is deployed to your tenant, you add it under **Certificate Authorities**, choose a VSatellite that can reach the gateway, and upload the API user's client certificate and private key. The gateway does not need to be reachable from the internet. You then select the authority and profile pairs to offer for issuance and configure import. Renewal is handled as a new issuance, and revocation depends on what the back-end authority supports. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, SaaS
- VSatellite
- Entrust CA Gateway

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
