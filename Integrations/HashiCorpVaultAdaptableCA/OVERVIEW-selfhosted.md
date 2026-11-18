# HashiCorp Vault Adaptable CA

Teams that use the HashiCorp Vault PKI secrets engine as a certificate authority still need visibility and policy over the certificates it issues. This Adaptable CA script lets Certificate Manager, Self-Hosted enroll and manage certificates issued by Vault, so you can keep Vault as a CA while lifecycle management, policy and visibility stay in Certificate Manager, Self-Hosted.

**Value Highlights**

- **Issue from Vault**: request certificates from a HashiCorp Vault PKI intermediate CA through Certificate Manager, Self-Hosted.
- **Centralize lifecycle management**: bring Vault-issued certificates under the same renewal and revocation processes as the rest of your PKI.
- **Import existing certificates**: pull certificates already issued by the Vault intermediate CA into your inventory.
- **Fit your Vault layout**: configure the Vault URL, root path, issuer path and issuer role for your environment.

**How it Works**

The PowerShell script implements the Adaptable CA interface and calls the Vault PKI API with a Vault token stored in a Certificate Manager, Self-Hosted credential. It signs CSRs against a configured issuer role, or lets Vault generate the key, and retrieves the root and issuing CA certificates to build the chain. See the Documentation tab for prerequisites and setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- HashiCorp Vault PKI secrets engine

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
