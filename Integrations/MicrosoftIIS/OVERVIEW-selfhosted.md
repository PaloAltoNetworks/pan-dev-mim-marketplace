# Microsoft IIS

Expired or misconfigured certificates on Microsoft Internet Information Services (IIS) servers cause outages for the websites and applications they host. Certificate Manager, Self-Hosted automates certificate provisioning to IIS servers in line with your policy, so certificates are renewed and installed on time without manual work on each server.

**Value Highlights**

- **Prevent outages**: Renew and install certificates on IIS servers before they expire.
- **Automate provisioning**: Install certificates and private keys in the Windows CAPI store and bind them to IIS web sites.
- **Use stronger keys**: Provision certificates with RSA or elliptic curve cryptography (ECC) keys, generated centrally or on the server.
- **Keep integration simple**: Rely on native Windows remote management with minimal port requirements and no agent on the server.
- **Enforce policy**: Apply the certificate policy you define in Certificate Manager, Self-Hosted to every IIS server.

**How it Works**

Microsoft IIS uses certificates and private keys stored in the Windows CAPI store, so Certificate Manager, Self-Hosted manages IIS through its built-in CAPI driver. You create a CAPI application object for each IIS server. The driver connects over Windows Remote Management (WinRM) and PowerShell, installs the certificate and key in the CAPI store, and can bind them to an IIS web site. The capability ships with Certificate Manager, Self-Hosted 18.3 and later, with no separate download. See the Documentation tab for setup.

**Applicability**

The CAPI driver supports provisioning to IIS 7.0 and later.

**Solution Components**

- Certificate Manager, Self-Hosted
- Microsoft IIS on Windows Server

**Additional Resources**

- [NIST SP 1800-16, Securing Web Transactions: TLS Server Certificate Management](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-16.pdf)

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
