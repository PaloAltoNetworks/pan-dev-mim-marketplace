# SAP Secure Login Server

SAP landscapes rely on many certificates, and SAP Secure Login Server (SLS), part of SAP Single Sign-On (SSO), issues certificates to SAP users and systems. When those certificates are managed outside central policy, renewals are missed and outages follow. This integration lets Certificate Manager, Self-Hosted act as a remote CA for SAP Secure Login Server, so certificates for your SAP systems are issued under policy and renewed automatically.

**Value Highlights**

- **Prevent outages**: Auto-renewal keeps certificates used by SAP systems from expiring unnoticed.
- **Govern by policy**: Certificates requested through SLS follow the policy defined in Certificate Manager, Self-Hosted.
- **Install nothing extra**: The capability is built into both products, so the integration needs configuration only.
- **Improve productivity**: Reduce manual certificate work for your SAP and certificate management teams.

**How it Works**

SAP Secure Login Server supports Certificate Manager, Self-Hosted as one of its remote CAs. You create a user identity and a challenge password credential in Certificate Manager, Self-Hosted, configure its SAP interface, and then point SLS at it. SLS then requests certificates from Certificate Manager, Self-Hosted over HTTP with authentication. See the Documentation tab for the setup steps.

**Applicability**

Remote CA support is available with SAP SSO 3.0 and later. Certificate Manager, Self-Hosted 21.3 and later supports Secure Login Server 3.0 SP02 PL10 and later (the patch that enables Certificate Manager, Self-Hosted as a remote CA).

**Solution Components**

- Certificate Manager, Self-Hosted
- SAP Secure Login Server (SAP Single Sign-On 3.0 or later)

**About SAP**

SAP is an enterprise application software company whose products include SAP S/4HANA and SAP Single Sign-On.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
