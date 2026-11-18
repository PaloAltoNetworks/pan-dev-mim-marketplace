# F5 BIG-IP

F5 BIG-IP Local Traffic Manager (LTM) terminates TLS for many of the applications an organization runs, so expired or misconfigured certificates on BIG-IP cause outages and security gaps. Next-Gen Trust Security automates the certificate lifecycle on BIG-IP, from discovering the certificates already in use to provisioning renewed certificates, without manual work by F5 administrators.

The F5 BIG-IP LTM machine type is built into Next-Gen Trust Security. There is nothing to download or install on the BIG-IP system.

**Value Highlights**

- **Discover existing certificates** in the SSL profiles on your BIG-IP systems for a complete inventory from the start.
- **Automate provisioning** of renewed certificates and keys to BIG-IP and bind them to SSL profiles.
- **Prevent outages** caused by expired certificates on load-balanced applications.
- **Reduce manual work** for F5 administrators, who no longer handle key and certificate updates by hand.
- **Scale encryption** across physical, virtual and cloud BIG-IP deployments under one policy.

**How it Works**

You create an F5 BIG-IP LTM machine in Next-Gen Trust Security with the BIG-IP management address and an administrative account. Next-Gen Trust Security connects to the BIG-IP iControl REST API through a VSatellite that can reach the management interface, discovers certificates in SSL profiles and provisions certificates to them. BIG-IP version 13 or later is required. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security with a VSatellite
- F5 BIG-IP LTM version 13 or later
