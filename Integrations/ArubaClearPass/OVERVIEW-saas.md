# Aruba ClearPass

Aruba ClearPass Policy Manager uses certificates for RADIUS/EAP authentication, its HTTPS interfaces, RadSec and its database. An expired or untracked certificate on ClearPass can cause failed network logins across the sites it serves.

Certificate Manager, SaaS discovers the certificates on a ClearPass Policy Manager node and provisions certificates to it over the ClearPass REST API, so certificate renewals on ClearPass are tracked and automated.

**Value Highlights**

- **See every ClearPass certificate**: discovery covers the service certificate store, the server certificate slots (HTTPS, RADIUS, RadSec, Database) and the ClearPass certificate store.
- **Provision service certificates**: install certificates for RADIUS/EAP and API use in the ClearPass service certificate store.
- **Renew discovered server certificates**: replace the certificate in a server certificate slot that discovery found.
- **Use a scoped API client**: connect with a ClearPass API client whose operator profile grants only the certificate access you need.
- **Start with discovery only**: create a machine that only discovers certificates if you aren't ready to provision.

**How it Works**

Certificate Manager, SaaS connects to the ClearPass REST API through a VSatellite using the client credentials of a ClearPass API client. For provisioning, it stages each certificate in an Amazon S3 bucket that you own, and ClearPass downloads and installs it from there, so ClearPass needs network access to Amazon S3.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- Aruba ClearPass Policy Manager
- An Amazon S3 bucket for staging certificates (provisioning only)

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
