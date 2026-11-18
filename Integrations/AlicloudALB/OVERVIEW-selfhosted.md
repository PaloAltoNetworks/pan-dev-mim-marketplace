# Alicloud ALB

Organizations that run applications on Alibaba Cloud terminate HTTPS on the Alibaba Cloud Application Load Balancer (ALB). Uploading and assigning certificates to each ALB by hand is slow, and a missed renewal causes an outage.

Secur Solutions' integration for Certificate Manager, Self-Hosted automates the certificate lifecycle for AliCloud ALB. Certificate Manager, Self-Hosted issues and renews certificates under your policy, then provisions them to the load balancer without manual steps.

**Value Highlights**

- **Automate provisioning** of TLS certificates to AliCloud ALB.
- **Upload and assign certificates** to the load balancer as part of each renewal.
- **Prevent outages** by replacing certificates before they expire.
- **Enforce policy** on the certificates that protect your Alibaba Cloud applications.
- **Manage Alibaba Cloud certificates** alongside the rest of your inventory in Certificate Manager, Self-Hosted.

**How it Works**

The integration is an Adaptable Application driver for Certificate Manager, Self-Hosted. When a certificate is issued or renewed, the driver uploads the certificate and private key to Alibaba Cloud and assigns it to the ALB you configure on the application object. Contact Secur Solutions for setup documentation.

**Solution Components**

- Certificate Manager, Self-Hosted with an Adaptable Application driver from Secur Solutions
- Alibaba Cloud Application Load Balancer

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) is a Singapore-based identity and digital security company that builds integrations for CyberArk certificate management products. Contact Secur Solutions for pricing, downloads and support.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
