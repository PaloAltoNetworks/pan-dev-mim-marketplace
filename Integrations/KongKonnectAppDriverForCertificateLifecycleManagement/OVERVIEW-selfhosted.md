# Kong Konnect App Driver for Certificate Lifecycle Management

Kong Konnect is Kong's cloud-hosted control plane for managing Kong API gateways. The gateways terminate TLS with certificates stored as Certificate entities in Konnect, and updating those certificates by hand on every renewal leaves APIs exposed to expired or out-of-policy certificates. Secur Solutions' Kong Konnect Adaptable App Driver brings Kong Konnect under Certificate Manager, Self-Hosted, so the certificates your API gateways serve follow enterprise security policy and are renewed automatically.

**Value Highlights**

- **Centralize TLS management**: Manage the certificates used by Kong Konnect gateways from Certificate Manager, Self-Hosted.
- **Automate renewal**: Push renewed certificates to Kong Konnect before the current ones expire.
- **Enforce policy**: Serve only certificates issued under your Certificate Manager, Self-Hosted policy.
- **Reduce manual work**: Remove per-renewal certificate uploads in the Konnect console or API.

**How it Works**

The driver is built on the Adaptable Application framework of Certificate Manager, Self-Hosted. When a certificate is issued or renewed, the driver uses the Kong Konnect API to create or update the Certificate entity in the target control plane, so the gateways it manages pick up the new certificate. Contact Secur Solutions Group for installation and setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- [Kong Konnect](https://konghq.com/products/kong-konnect)
- Secur Solutions Kong Konnect Adaptable App Driver

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) builds certificate lifecycle integrations for CyberArk Certificate Manager and provides identity and security consultancy services.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
