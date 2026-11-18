# Cisco ASA

Cisco Adaptive Security Appliance (ASA) firewalls present identity certificates to remote-access VPN users and to administrators on their management interfaces. When one of those certificates expires or is replaced by hand, VPN users get disconnected and administrators lose trusted access. Next-Gen Trust Security finds the certificates on each firewall and installs renewed certificates for you, so remote access keeps working without manual trustpoint changes.

**Value Highlights**

- **Prevent VPN outages**: renew and install certificates before they expire, on the schedule you choose.
- **Gain visibility**: discover the certificates on each firewall, including trust pool CA certificates if you want to track their expiry.
- **Remove manual CLI work**: Next-Gen Trust Security imports the certificate, key and chain into a trustpoint and binds it for you.
- **Bind to the right service**: provision to an interface, the management interface, a VPN load-balancing address, an SNI domain, a global fallback or the IKEv2 remote-access VPN.
- **Keep firewalls clean**: replaced trustpoints that Next-Gen Trust Security created are removed after the new certificate is bound.
- **Cover multi-context firewalls**: manage each security context as its own machine.

**How it Works**

Next-Gen Trust Security connects to the firewall's HTTPS management interface through a VSatellite, using a local Cisco ASA account with privilege level 15. It doesn't need the ASA REST API agent. Discovery reads the certificates on the firewall, and provisioning installs a certificate into a trustpoint, binds it, saves the configuration so it survives a reboot, and removes the trustpoint it replaces. Both can run on a schedule. See the Documentation tab for setup.

The Cisco ASA machine type is currently available in Next-Gen Trust Security as a Preview feature.

**Solution Components**

- Next-Gen Trust Security
- VSatellite
- Cisco ASA firewall
