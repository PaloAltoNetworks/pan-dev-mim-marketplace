# Apache HTTP Server

Apache HTTP Server hosts critical services, applications and content across enterprise web infrastructure, in data centers and in public, private and hybrid clouds. Expired or misconfigured certificates on those servers cause outages that are time-consuming and expensive to fix.

Next-Gen Trust Security manages the certificates on Apache web servers through its Common KeyStore machine type. It discovers the certificate files on each server and provisions renewed certificates and keys before the old ones expire.

**Value Highlights**

- **Prevent outages** caused by expired or misconfigured certificates on Apache servers.
- **Discover existing certificates** in PEM files on Linux and Windows hosts.
- **Provision renewed certificates** and keys directly to the files Apache uses.
- **Restart the service automatically** after provisioning on systemd hosts.
- **Enforce policy** on every certificate deployed to your web infrastructure.

**How it Works**

You create a Common KeyStore machine for each Apache host in Next-Gen Trust Security. A VSatellite connects to the host over SSH or Windows Remote Management (WinRM) and reads and writes the PEM files that Apache uses. After provisioning, Next-Gen Trust Security can restart the Apache service so the new certificate takes effect. See the Documentation tab for setup.

**Applicability**

The integration works for Apache HTTP Server deployments on any infrastructure, whether in the cloud or in the data center.

**Solution Components**

- Next-Gen Trust Security with a VSatellite
- Apache HTTP Server on Linux or Windows

**Additional Resources**

- [NIST SP 1800-16, Securing Web Transactions: TLS Server Certificate Management](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-16.pdf)
