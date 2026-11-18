# F5 BIG-IP

F5 BIG-IP Local Traffic Manager (LTM) terminates TLS for many of the applications an organization runs, so expired or misconfigured certificates on BIG-IP cause outages and security gaps. Certificate Manager, Self-Hosted automates the complete key and certificate lifecycle on BIG-IP, from first setup to validating that each key and certificate update completed, without manual work by F5 administrators.

The F5 LTM Advanced driver is distributed with Certificate Manager, Self-Hosted. There is nothing to download.

**Value Highlights**

- **Scale encryption** reliably across physical, virtual and cloud BIG-IP environments.
- **Automate installation** of keys and certificates to BIG-IP and their association with SSL profiles.
- **Validate every update** so failed or partial installations are caught.
- **Prevent outages** caused by expired certificates on load-balanced applications.
- **Discover existing certificates** on BIG-IP for a complete machine identity inventory from the start.
- **Distribute keys for inspection** so security tools can see into SSL/TLS traffic.

**How it Works**

You create F5 LTM Advanced device and application objects in Certificate Manager, Self-Hosted that point at the BIG-IP management interface. The driver connects to BIG-IP, installs keys, certificates and chains, updates the SSL profiles that use them, and reports the result back to the platform. See the Documentation tab for configuration steps.

**Solution Components**

- Certificate Manager, Self-Hosted
- F5 BIG-IP LTM

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
