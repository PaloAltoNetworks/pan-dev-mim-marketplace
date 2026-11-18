# Google Certificate Manager

Google Cloud load balancers and other Google services serve certificates stored in Google Certificate Manager. When those certificates are uploaded and renewed by hand, they expire unnoticed or drift from policy. Certificate Manager, SaaS connects to Google Certificate Manager as a cloud keystore, so you get central visibility of those certificates and can provision new and renewed certificates to them automatically.

**Value Highlights**

- **Automate provisioning**: Push new and renewed certificates to Google Certificate Manager for use with Google Cloud services.
- **Gain visibility**: Discover the certificates in your Google Certificate Manager projects and track them in one inventory.
- **Prevent outages**: Replace certificates before they expire and avoid serving non-compliant certificates.
- **Simplify operations**: Manage Google Cloud certificates with the same policies and workflows as the rest of your certificates.

**How it Works**

You configure a Google Cloud Platform cloud provider in Certificate Manager, SaaS, which connects to your project through a Google service account or Workload Identity Federation. You then add a Google cloud keystore for a project and region, discover the certificates it holds, and provision certificates to it. See the Documentation tab for setup.

**Applicability**

This integration suits organizations that run Google Cloud services at scale and need automated certificate management for them.

**Solution Components**

- Certificate Manager, SaaS
- Google Certificate Manager

**About Google Certificate Manager**

[Google Certificate Manager](https://docs.cloud.google.com/certificate-manager/docs) is a Google Cloud service for managing and deploying TLS certificates for your Google Cloud services.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
