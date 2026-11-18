# HashiCorp Vault Credentials

Provisioning certificates to machines requires credentials for those machines. Certificate Manager, SaaS can use HashiCorp Vault as a privileged access manager, so the credentials it uses for provisioning stay in Vault and Certificate Manager, SaaS holds only a reference to them.

When a credential changes in Vault, Certificate Manager, SaaS uses the updated value the next time it provisions a certificate, with no change needed on the Certificate Manager, SaaS side.

**Value Highlights**

- **Keep secrets in Vault**: Certificate Manager, SaaS stores credential references, not copies of the secrets.
- **Pick up rotations automatically**: updates to a credential in Vault are used on the next provisioning operation.
- **Use your existing authentication method**: connect with a certificate, username and password, or token.
- **Support KV v1 and KV v2**: reference secrets by path and key name in either Key-Value secrets engine version.
- **Test before you rely on it**: check access for both the Vault connection and each credential from the console.

**How it Works**

A VSatellite in your data center connects to your HashiCorp Vault server, which must be version 1.16 or later. You add a HashiCorp Vault connection under **Credential Managers**, then create HashiCorp credentials that point to a secret path and key name. You assign those credentials to machines, and Certificate Manager, SaaS retrieves the secret through the VSatellite when it provisions a certificate. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, SaaS
- VSatellite
- HashiCorp Vault

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
