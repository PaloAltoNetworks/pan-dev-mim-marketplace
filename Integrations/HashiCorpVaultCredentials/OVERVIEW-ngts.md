# HashiCorp Vault Credentials

Provisioning certificates to machines requires credentials for those machines. Next-Gen Trust Security can use HashiCorp Vault as a privileged access manager, so the credentials it uses for provisioning stay in Vault and Next-Gen Trust Security holds only a reference to them.

When a credential changes in Vault, Next-Gen Trust Security uses the updated value the next time it provisions a certificate, with no change needed on the Next-Gen Trust Security side.

**Value Highlights**

- **Keep secrets in Vault**: Next-Gen Trust Security stores credential references, not copies of the secrets.
- **Pick up rotations automatically**: updates to a credential in Vault are used on the next provisioning operation.
- **Use your existing authentication method**: connect with a certificate, username and password, token, or AppRole.
- **Support KV v1 and KV v2**: reference secrets by path and key name in either Key-Value secrets engine version.
- **Share connectors across workspaces**: optionally let other workspaces use the Vault connection without changing its owner.

**How it Works**

A VSatellite in your data center connects to your HashiCorp Vault server, which must be version 1.16 or later. You add a HashiCorp Vault connection under **Credential Managers**, then create HashiCorp credentials that point to a secret path and key name. You assign those credentials to machines, and Next-Gen Trust Security retrieves the secret through the VSatellite when it provisions a certificate. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- VSatellite
- HashiCorp Vault
