# Palo Alto Networks NGFW

Palo Alto Networks Next-Generation Firewalls (NGFW) rely on trusted certificates to protect the integrity and confidentiality of their own management and service connections. When a firewall's device certificate expires or is replaced by hand, administrators lose time and connections can fail. Certificate Manager, Self-Hosted automates the device certificates on your NGFWs, so renewals happen on schedule and follow policy across physical appliances and VM-Series firewalls.

**Value Highlights**

- **Automate renewals** of device certificates on physical appliances and VM-Series firewalls.
- **Distribute trust**: Provision CA certificates to the firewall's trust store.
- **Prevent misuse** of firewall machine identities with central policy and control.
- **Reduce outages** caused by expired device certificates.

**How it Works**

The Palo Alto Networks application driver is built into Certificate Manager, Self-Hosted. You create a device and a Palo Alto Networks application object for each firewall, and Certificate Manager, Self-Hosted installs and renews the firewall's device certificate. To install server certificates and private keys on the firewall for SSL decryption, use a bulk provisioning job instead (see the Palo Alto NGFW Bulk Provisioning listing). See the Documentation tab for the configuration guide.

**Solution Components**

- Certificate Manager, Self-Hosted
- Palo Alto Networks Next-Generation Firewall (hardware appliance or VM-Series)

**About Palo Alto Networks**

[Palo Alto Networks](https://www.paloaltonetworks.com/) is a cybersecurity company whose next-generation firewalls are built to enable applications safely and prevent threats. The integration is also listed in the [Palo Alto Networks technology partner catalog](https://technologypartners.paloaltonetworks.com/English/integration/NGFW-Venafi-Trust-Protection-Platform).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
