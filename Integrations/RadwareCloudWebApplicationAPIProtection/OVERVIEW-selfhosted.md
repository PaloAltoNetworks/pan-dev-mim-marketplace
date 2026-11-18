# Radware Cloud Web Application API Protection

Radware Cloud Web Application and API Protection (Cloud WAAP) protects web applications and APIs in a fully managed cloud service, and every protected application needs a valid TLS certificate. In large environments, uploading and rebinding those certificates by hand slows application teams down and raises the risk of mishandled keys. Radware and Venafi built this integration so Certificate Manager, Self-Hosted can upload and renew Cloud WAAP certificates automatically.

**Value Highlights**

- **Scale HTTPS**: provision certificates automatically and remove manual bottlenecks for application teams.
- **Reduce risk**: keep private keys out of manual handling during certificate distribution.
- **Prevent outages**: renew certificates and reassign every application that used the old certificate.
- **Cover new applications**: rebind applications that use a placeholder certificate when a matching certificate is issued.
- **Keep the tenant clean**: SNI certificate groups are updated and the old certificate is deleted after renewal.

**How it Works**

The integration is an Adaptable Application driver (PowerShell script) that runs in Certificate Manager, Self-Hosted and calls the Cloud WAAP API with an API user. When a certificate is pushed or renewed, the driver uploads it to the Cloud WAAP tenant, reassigns the applications that used the old certificate, rebinds applications under the placeholder certificate whose main domain matches the new certificate's CN or SANs, updates SNI certificate groups, and deletes the old certificate. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted 22.1 and above
- Radware Cloud WAAP

**About Radware**

Radware builds application delivery and cyber security solutions for cloud, on-premises and software-defined data centers. Learn more about Cloud WAAP at [radware.com](https://www.radware.com/products/cloud-waf-service/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
