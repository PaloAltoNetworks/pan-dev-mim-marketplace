# Apache HTTP Server

Apache HTTP Server hosts critical services, applications and content across enterprise web infrastructure, in data centers and in public, private and hybrid clouds. Expired or misconfigured certificates on those servers cause outages that are time-consuming and expensive to fix.

Certificate Manager, Self-Hosted extends policy-compliant, automated certificate management to Apache web servers. It provisions renewed certificates and keys to each server so that certificates are replaced before they expire.

**Value Highlights**

- **Prevent outages** caused by expired or misconfigured certificates on Apache servers.
- **Manage PEM files** for Apache web servers on Linux or Windows.
- **Simplify file handling** by provisioning the certificate, chain and private key to a single file instead of two or three.
- **Use ECC keys** generated centrally or remotely, including remote generation with a SafeNet Luna SA HSM.
- **Enforce policy** on every certificate deployed to your web infrastructure.

**How it Works**

The Apache application driver is included with Certificate Manager, Self-Hosted 18.3 and later, so there is nothing to install. You create an Apache application object for each server, and Certificate Manager, Self-Hosted connects to the server to provision the certificate, chain and private key in PEM format. See the Documentation tab for configuration.

**Applicability**

The integration works for Apache HTTP Server deployments on any infrastructure, whether in the cloud or in the data center.

**Solution Components**

- Certificate Manager, Self-Hosted
- Apache HTTP Server on Linux or Windows

**Additional Resources**

- [NIST SP 1800-16, Securing Web Transactions: TLS Server Certificate Management](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-16.pdf)

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
