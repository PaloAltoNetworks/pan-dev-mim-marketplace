# Secrets Engine for HashiCorp Vault

DevOps teams that use HashiCorp Vault to issue certificates for development, testing and deployment often rely on Vault's built-in PKI, which leaves InfoSec without visibility or policy control and cannot provide publicly trusted certificates. The Venafi PKI secrets engine for Vault lets those teams acquire certificates from Next-Gen Trust Security without changing how they work in Vault, while security keeps visibility and enforces enterprise policy.

**Value Highlights**

- **Keep the Vault workflow**: The plugin provides the same interface as Vault's built-in PKI secrets engine.
- **Get publicly trusted certificates**: Reach the public and private CAs connected to Next-Gen Trust Security, beyond Vault's internal PKI.
- **Enforce enterprise policy**: Every certificate follows the policy defined in Next-Gen Trust Security.
- **Give InfoSec visibility**: Certificates issued through Vault appear in the Next-Gen Trust Security inventory.
- **Skip manual steps**: Services obtain certificates without manual key generation, CSR submission or signing workflows.
- **Avoid unnecessary reissues**: Optional settings return an existing valid certificate instead of requesting a new one.

**How it Works**

The secrets engine is open-source software built on Vault's plugin framework. You register the plugin with Vault, create a Venafi secret that holds the connection details, and create roles that reference it. For Next-Gen Trust Security, the secret holds service account credentials (OAuth2 client credentials and TSG ID) and the issuing template alias as the zone. Certificates can be issued, signed, read and revoked. Applications then use the familiar `issue` and `sign` paths to get certificates. See the Documentation tab for setup.

**Applicability**

Organizations whose DevOps teams use HashiCorp Vault to issue certificates should consider this plugin.

**Solution Components**

- Next-Gen Trust Security
- HashiCorp Vault with the [Venafi PKI secrets engine](https://github.com/Venafi/vault-pki-backend-venafi) plugin

**About HashiCorp**

HashiCorp provides infrastructure and security automation software, including [Vault](https://developer.hashicorp.com/vault) for secrets management.
