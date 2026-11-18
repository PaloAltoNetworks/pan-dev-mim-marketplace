# SandboxAQ AQtive Guard (fka Cryptosense Analyzer Platform)

Security teams struggle to keep end-to-end visibility of certificate use. Self-issued certificates from development and testing move untracked into production, third-party code includes hard-coded certificates, new certificates land in the wrong store, or applications are not restarted to reload their store. AQtive Guard integrates natively with Certificate Manager, Self-Hosted to find these lost or missing machine identities across applications and file systems, so they can be managed before they cause an outage.

**Value Highlights**

- **Reduce the risk of outages** by making sure every in-use certificate is tracked and managed.
- **Provide on-demand visibility** of certificate use in applications for compliance and audits.
- **Simplify operations** by catching human error, including hard-coded certificates.
- **Add found certificates automatically**: Use filters to add discovered certificates to Certificate Manager, Self-Hosted under conditions you set.
- **Gate builds and raise issues**: Fail a build that includes unmanaged certificates, or open a Jira issue for one through the AQtive Guard GraphQL API.
- **Alert on expiring certificates**: Flag any scan containing a certificate that expires within three months without a replacement.

**How it Works**

AQtive Guard traces an application's calls to its cryptographic libraries to see which keys and certificates are actually used at runtime, and scans file systems and containers to find where those certificates are stored. With a Certificate Manager, Self-Hosted URL and access token configured, AQtive Guard looks up each certificate in a report against your inventory. You can open certificates that are already managed, and submit missing ones to Certificate Manager, Self-Hosted with a single click. See the Documentation tab for setup and usage.

**Solution Components**

- Certificate Manager, Self-Hosted
- SandboxAQ AQtive Guard

**About SandboxAQ**

[SandboxAQ](https://www.sandboxaq.com/) builds AI and quantum technology solutions, including [AQtive Guard](https://www.aqtiveguard.com/) for cryptography management.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
