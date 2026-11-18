# Microsoft ADCS

Many organizations use Microsoft Active Directory Certificate Services (AD CS) as their internal CA. Certificate Manager, SaaS connects to your AD CS server so you can issue new certificates and import existing ones from it, which gives security teams visibility and control over internally issued certificates alongside the rest of the inventory.

**Value Highlights**

- **Gain visibility**: import certificates already issued by AD CS into Certificate Manager, SaaS.
- **Issue under policy**: request new certificates from AD CS through Certificate Manager, SaaS.
- **Simplify deployment**: VSatellite connects directly to AD CS, with no separate worker machine to run.
- **Strengthen authentication**: use Kerberos for mutual authentication and stronger encryption, with automatic fallback to NTLM when Kerberos isn't available.
- **Stay available**: the integration supports VSatellite high availability.

**How it Works**

A VSatellite on a Linux server in your network connects to the AD CS service with an account that has Read, Issue and Manage Certificates, and Request Certificates permissions. You choose the authentication method: Automatic (Kerberos when the environment supports it, otherwise NTLM), NTLM only, or Kerberos only. Once connected, you can import existing certificates and issue new ones through AD CS.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- VSatellite
- Microsoft Active Directory Certificate Services

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
