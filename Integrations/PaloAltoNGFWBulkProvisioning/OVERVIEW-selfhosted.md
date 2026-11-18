# Palo Alto NGFW Bulk Provisioning

Firewalls that perform SSL inbound inspection need a copy of the certificate and private key for every server they protect, which can mean hundreds of certificates on a single Palo Alto Networks next-generation firewall (NGFW). Installing them one at a time is slow and easy to get wrong. This Adaptable Bulk Provisioning driver lets Certificate Manager, Self-Hosted provision many certificates from a source policy folder to a target NGFW in a single job.

**Value Highlights**

- **Provision in bulk**: Push every certificate in a source policy folder to a target Palo Alto Networks NGFW in one operation.
- **Keep inspection working**: Optionally bind each installed certificate to its SSL inbound inspection decryption policy rule, updating existing rules or creating new ones.
- **Commit safely**: The driver locks the firewall configuration while it works, then unlocks and commits the changes.
- **Report clearly**: Certificates the firewall cannot accept, such as expired or self-signed end-entity certificates, are reported as rejected rather than failed.

**How it Works**

The driver (`Palo Alto Networks NGFW.ps1`) runs as a standard Bulk Provisioning job using the Adaptable framework. It authenticates to the NGFW XML API with a username credential, imports each certificate and private key as a key pair and, if enabled, updates or creates the matching decryption policy rule using the decryption profile you name. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Palo Alto Networks NGFW

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
