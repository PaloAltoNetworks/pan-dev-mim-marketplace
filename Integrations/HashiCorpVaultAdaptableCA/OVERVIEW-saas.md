# HashiCorp Vault Adaptable CA

Teams that run the HashiCorp Vault PKI secrets engine as a certificate authority need the certificates it issues to follow the same policy and visibility as the rest of their PKI. Certificate Manager, SaaS connects to Vault through a HashiCorp Vault CA connector built on the Venafi CA Connector Framework, so you can issue, renew, revoke and import Vault certificates from one place.

**Value Highlights**

- **Reuse your Vault role constraints**: each PKI role in the mount appears as a product, so requests follow the limits already set on your Vault roles.
- **Cover the full lifecycle**: issue, renew and revoke certificates from a single PKI secrets engine mount.
- **Import existing certificates**: bring certificates stored in the PKI mount into your inventory, on demand or on a schedule.
- **Work with any Vault edition**: connect to Vault Community Edition, Vault Enterprise or HCP Vault, including Enterprise namespaces.
- **Limit credential exposure**: authenticate with AppRole (recommended) or a scoped token, and keep Vault private behind a VSatellite.

**How it Works**

This is a custom CA connector. After the HashiCorp Vault CA connector is deployed to your tenant, you add it under **Certificate Authorities**, choose a VSatellite that can reach Vault over HTTPS, and enter the Vault URL, PKI mount path and credentials bound to a Vault policy for the connector. You then pick the roles to offer to request policies and configure import. See the Documentation tab for the required Vault policy and setup steps.

**Solution Components**

- Certificate Manager, SaaS
- VSatellite
- HashiCorp Vault PKI secrets engine

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
