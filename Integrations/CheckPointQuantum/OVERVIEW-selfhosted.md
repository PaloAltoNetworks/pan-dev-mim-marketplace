# Check Point Quantum

Attackers use encryption to hide malicious activity from security controls such as NGFW and intrusion prevention systems. To inspect encrypted traffic, Check Point Quantum gateways need current keys and certificates, and keeping them current by hand leaves gaps.

Check Point and Certificate Manager, Self-Hosted together automate the delivery and configuration of the keys and certificates used by Check Point Next-Generation Firewalls (NGFW). Firewalls always have current machine identities to inspect traffic, so they can tell which encrypted channels to trust and detect attacks hiding in the others.

**Value Highlights**

- **Get started fast**: Use your inventory of existing keys and certificates from the start.
- **Maximize inspection**: Discover keys and certificates so gateways can inspect more traffic.
- **Maintain inspection levels**: Automate the key and certificate lifecycle and distribution.
- **Distribute replacement keys automatically**: Send new keys to gateways as soon as they are generated.
- **Improve inspection performance**: Remove delays caused by manual key distribution.

**How it Works**

Certificate Manager, Self-Hosted automates the TLS certificates used in Check Point inbound HTTPS inspection policies. Certificates are defined as synced objects in Check Point and kept in sync with Certificate Manager, Self-Hosted:

- Bulk provisioning jobs deliver new certificates that match your policy to Check Point gateways on a schedule or on demand.
- Expiring certificates are renewed at the CA, provisioned to the gateways and applied in the HTTPS inspection policy.
- Inspection policies always use the latest certificates, so there are no gaps in TLS visibility.

**Solution Components**

- Certificate Manager, Self-Hosted
- Check Point Quantum gateways (NGFW) with HTTPS inspection

**About Check Point**

[Check Point Software Technologies](https://www.checkpoint.com/) provides network, cloud and endpoint security solutions.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
