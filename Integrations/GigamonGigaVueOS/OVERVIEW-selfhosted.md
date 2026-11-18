# Gigamon GigaVue (OS)

The GigaVUE-OS web management interface on Gigamon appliances uses a TLS certificate to secure administrator access. That certificate is usually self-signed, or needs manual work every time it expires, which leads to browser warnings, weaker security and outages of the admin UI.

This Gigamon integration lets Certificate Manager, Self-Hosted manage the lifecycle of the GigaVUE-OS web management interface certificate, so administrators no longer have to track or replace it by hand. A separate Gigamon integration, Gigamon TLS Decryption, handles the certificates used in Gigamon policies for TLS inspection.

**Value Highlights**

- **Protect admin access** with trusted certificates that keep management traffic confidential and intact.
- **Eliminate self-signed certificates** and the browser warnings they cause.
- **Prevent outages** caused by expired certificates.
- **Automate renewal and deployment** of the web management interface certificate.
- **Remove manual provisioning** to streamline operations.

**How it Works**

A PowerShell driver for the Certificate Manager, Self-Hosted Adaptable framework connects to the GigaVUE-OS command line over SSH. When a certificate is issued or renewed, the driver installs the certificate, chain and private key on the appliance, activates it for the web management interface, can read the installed certificate back for validation, and can remove older certificates. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Gigamon appliances running GigaVUE-OS
- Gigamon GigaVUE-OS Adaptable driver

**About Gigamon**

[Gigamon](https://www.gigamon.com) provides deep observability across hybrid and multi-cloud networks.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
