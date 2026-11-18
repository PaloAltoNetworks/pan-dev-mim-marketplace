# Akamai Adaptable Application

Akamai manages certificates as part of the edge services it delivers, and those certificates need to be part of your risk analysis and renewal process. The Akamai Adaptable Application driver connects Certificate Manager, Self-Hosted to the Akamai Certificate Provisioning System (CPS) API, so you can discover the certificates on Akamai's production network and provision new and renewed certificates directly to Akamai.

**Value Highlights**

- **Streamline operations**: import all production certificates from Akamai CPS through onboard discovery.
- **Increase visibility**: include Akamai certificates in the same inventory as the rest of your machine identities.
- **Automate renewals**: add and renew certificates from Certificate Manager, Self-Hosted directly into Akamai CPS.
- **Support dual-stack deployments**: manage RSA and ECC certificates on the same Akamai enrollment.
- **Add approvals where you need them**: optional adaptable workflows require approval before certificate changes are acknowledged in Akamai.

**How it Works**

The PowerShell Adaptable Application driver authenticates to the Akamai CPS API with API client credentials stored in Certificate Manager, Self-Hosted. Onboard discovery creates an application and certificate for each certificate on the Akamai production network and saves its enrollment ID for later renewals. Akamai generates the key and CSR, and the driver delivers the issued certificate back to the enrollment. Optional workflow scripts handle approval stages and dual-stack RSA/ECC orchestration. See the Documentation tab for installation and configuration.

This driver is free to download. Support is provided under a paid support subscription, so please contact your account team for details.

**Solution Components**

- Certificate Manager, Self-Hosted
- Akamai Adaptable Application driver
- Akamai Certificate Provisioning System

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
