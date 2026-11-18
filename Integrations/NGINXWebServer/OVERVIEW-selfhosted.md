# NGINX Web Server

Expired or misconfigured certificates on NGINX web servers take down the websites and applications they serve. Certificate Manager, Self-Hosted automates certificate provisioning to NGINX in line with your policy, so certificates are renewed and installed on time without manual work on each server.

**Value Highlights**

- **Prevent outages**: Renew and install certificates on NGINX servers before they expire.
- **Provision in the format NGINX expects**: Write the end-entity certificate, chain and private key to PEM files, including a single combined file instead of two or three separate files.
- **Cover any NGINX deployment**: Works with open-source NGINX and NGINX Plus on Linux or Windows.
- **Enforce policy**: Apply the certificate policy you define in Certificate Manager, Self-Hosted to every NGINX server.

**How it Works**

NGINX reads certificates and keys from PEM files, so Certificate Manager, Self-Hosted manages NGINX through its built-in PEM driver. You create a PEM application object for each NGINX server with the file paths your NGINX configuration uses, and Certificate Manager, Self-Hosted provisions renewed certificates to those files. The capability ships with Certificate Manager, Self-Hosted 18.3 and later, with no separate download. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- NGINX or NGINX Plus on Linux or Windows

**Additional Resources**

- [NIST SP 1800-16, Securing Web Transactions: TLS Server Certificate Management](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-16.pdf)

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
