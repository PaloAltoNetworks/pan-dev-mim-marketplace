# Microsoft Azure Key Vault

Applications and Azure services that load certificates from Azure Key Vault go down when those certificates expire, and certificates imported by hand are hard to keep compliant. Certificate Manager, Self-Hosted stores certificates, keys and chains in Azure Key Vault as part of its automated certificate lifecycle, so Azure workloads get valid certificates that follow your policy.

**Value Highlights**

- **Stay in compliance**: Make sure certificate issuance follows your security policy.
- **Reduce key handling risk**: Avoid incidents caused by keys copied and imported by hand.
- **Eliminate outages**: Keep keys and certificates in Key Vault updated continuously.
- **Automate distribution**: Deliver keys and certificates to Key Vault securely and without manual steps.
- **Gain visibility**: See the certificates in use in your Azure key vaults.

**How it Works**

Certificate Manager, Self-Hosted includes a built-in Azure Key Vault driver. You configure access to your Azure tenant and create an application object for each key vault, and Certificate Manager, Self-Hosted provisions certificates, keys and chains to that key vault as they are issued and renewed. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Microsoft Azure Key Vault

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
