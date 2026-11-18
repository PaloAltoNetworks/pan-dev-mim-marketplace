# HashiCorp Vault Credentials

Provisioning certificates to devices and applications requires credentials for those systems, and copying those secrets into another tool adds risk and maintenance. This integration lets Certificate Manager, Self-Hosted retrieve secrets from HashiCorp Vault when it needs them, using the Adaptable Credential framework, so the secrets stay in Vault and are not stored in Certificate Manager, Self-Hosted.

**Value Highlights**

- **Improve security posture**: secrets are stored only in HashiCorp Vault.
- **Prevent outages**: Certificate Manager, Self-Hosted always uses the most recent credential for provisioning operations.
- **Keep teams working from one source**: security and operations teams manage secrets in Vault while certificate automation uses them.
- **Require no Vault changes**: the integration works with your existing HashiCorp Vault deployment.

**How it Works**

An Adaptable Credential object in Certificate Manager, Self-Hosted uses a PowerShell script to retrieve credentials from the HashiCorp Vault Key-Value secrets engine at the time of use. Provisioning operations that reference the Adaptable Credential receive the current secret from Vault instead of a stored copy.

**Solution Components**

- Certificate Manager, Self-Hosted
- HashiCorp Vault

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
