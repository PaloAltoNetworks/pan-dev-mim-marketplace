# Tencent Cloud Load Balancer Adaptable App Driver

As organizations scale cloud-native infrastructure on Tencent Cloud, updating certificates on load balancer listeners by hand becomes slow and error-prone, and a missed renewal can take an application offline. Secur Solutions' Tencent Cloud Load Balancer Adaptable App Driver automates this work between Certificate Manager, Self-Hosted and Tencent Cloud Load Balancer (CLB).

**Value Highlights**

- **Automate provisioning**: Push certificates from Certificate Manager, Self-Hosted to Tencent Cloud Load Balancer.
- **Bind certificates to listeners**: Attach provisioned certificates to the CLB listeners that serve your applications.
- **Renew without downtime**: Replace expiring certificates on listeners without interrupting traffic.
- **Remove manual overhead**: Stop uploading and rebinding certificates in the Tencent Cloud console.

**How it Works**

The driver is an Adaptable App Driver for Certificate Manager, Self-Hosted. Each Tencent Cloud Load Balancer target is configured as an application object, and when a certificate is issued or renewed, the driver uploads it to Tencent Cloud and binds it to the configured CLB listeners. The driver is a paid offering from Secur Solutions Group. Contact the partner for access and setup guidance.

**Solution Components**

- Certificate Manager, Self-Hosted
- Tencent Cloud Load Balancer (CLB)
- Secur Solutions Tencent Cloud Load Balancer Adaptable App Driver

**About Secur Solutions Group**

Secur Solutions Group is a Singapore-based identity solutions provider that builds integrations for CyberArk Certificate Manager. Learn more at [secursolutionsgroup.com](https://secursolutionsgroup.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
