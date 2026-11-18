# Imperva WAF

Imperva Cloud Web Application Firewall (WAF) protects websites against attacks that deny service and steal data. Sites behind Imperva can serve custom certificates, and when those certificates are uploaded and renewed by hand, they expire and break the sites they protect. Certificate Manager, SaaS discovers the certificates served by the sites in your Imperva account and provisions custom certificates to them, so protected sites always serve valid, policy-compliant certificates.

**Value Highlights**

- **Gain visibility**: Discover all the sites in your Imperva account and the certificates they serve.
- **Automate provisioning**: Upload the certificate, its issuing chain and its private key as a site's custom certificate.
- **Prevent outages**: Monitor the certificates on each site for expiration and replace them in time.
- **Keep policy**: Serve only certificates issued under your organization's policy.

**How it Works**

You create an Imperva WAF machine in Certificate Manager, SaaS with an Imperva API ID and API key. Certificate Manager, SaaS lists the sites in the account and retrieves the certificate each site serves. To provision, you choose an existing site by its Site ID, and Certificate Manager, SaaS uploads the certificate as that site's custom certificate. See the Documentation tab for requirements and setup.

**Solution Components**

- Certificate Manager, SaaS
- Imperva Cloud WAF

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
