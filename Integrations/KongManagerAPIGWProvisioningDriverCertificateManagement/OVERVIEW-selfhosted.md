# Kong Manager API GW Provisioning Driver Certificate Management

Self-hosted Kong Gateway terminates TLS with certificates stored as Certificate entities and matched to hostnames through SNI entities. Updating certificates and SNI mappings by hand on every renewal leaves APIs exposed to expired or out-of-policy certificates. Secur Solutions' Kong API Gateway TLS Provisioning Driver brings self-hosted Kong Gateway under Certificate Manager, Self-Hosted, so the certificates your API gateways serve follow enterprise security policy and are renewed automatically.

**Value Highlights**

- **Automate the certificate lifecycle**: Provision new and renewed certificates to self-hosted Kong Gateway.
- **Manage SNI configuration**: Keep the SNI hostnames that point to each certificate in step with the certificate.
- **Enforce policy**: Serve only certificates issued under your Certificate Manager, Self-Hosted policy.
- **Prevent outages**: Replace certificates on Kong Gateway before they expire.

**How it Works**

The driver is built on the Adaptable Application framework of Certificate Manager, Self-Hosted. When a certificate is issued or renewed, the driver uses the Kong Admin API of your self-hosted Kong Gateway to create or update the Certificate entity and its SNI entities. Contact Secur Solutions Group for installation and setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Self-hosted [Kong Gateway](https://developer.konghq.com/gateway/entities/certificate/), managed with Kong Manager
- Secur Solutions Kong API Gateway TLS Provisioning Driver

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) builds certificate lifecycle integrations for CyberArk Certificate Manager and provides identity and security consultancy services.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
