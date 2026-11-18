# Microsoft Azure Key Vault

Applications and Azure services that load certificates from Azure Key Vault go down when those certificates expire, and certificates imported by hand into many key vaults are hard to track. Certificate Manager, SaaS connects to your key vaults to discover the certificates stored there and to provision new and renewed certificates into them, so Azure workloads always pick up valid, policy-compliant certificates.

**Value Highlights**

- **Gain visibility**: Discover the certificates stored across your Azure key vaults in one inventory.
- **Prevent outages**: Renew certificates and push them to Azure Key Vault before they expire.
- **Stay in compliance**: Provision only certificates issued under your organization's security policy.
- **Reduce key handling risk**: Deliver certificates, keys and chains to Key Vault without copying files by hand.

**How it Works**

Certificate Manager, SaaS signs in to Microsoft Entra ID as an app registration that has access to the key vault's certificates and secrets. It discovers the certificates in the key vault and imports new or renewed certificates. You can connect Azure Key Vault as a cloud keystore, or create a Microsoft Azure Private Key Vault machine that connects through a VSatellite. See the Documentation tab for requirements and setup.

**Solution Components**

- Certificate Manager, SaaS
- Microsoft Azure Key Vault and a Microsoft Entra app registration

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
