# Barracuda Web Application Firewall

Barracuda Web Application Firewalls secure applications with HTTPS through TLS/SSL offloading and inspection, so every protected service depends on a valid certificate. As deployments grow, tracking those certificates in spreadsheets stops working and expired certificates cause downtime. Barracuda and Venafi built this integration so Certificate Manager, Self-Hosted can discover, provision and renew certificates on Barracuda WAF centrally and automatically.

**Value Highlights**

- **Improve scalability and efficiency**: automate the orchestration and management of certificates and keys.
- **Increase security**: discover the certificates on each Barracuda WAF and bring them under policy.
- **Prevent downtime**: renew certificates before they expire.
- **Create, renew and revoke certificates**: manage the full lifecycle from Certificate Manager, Self-Hosted.
- **Automate provisioning**: push new and renewed certificates to Barracuda WAF services without manual steps.

**How it Works**

The integration is an Adaptable Application driver (PowerShell script) that runs in Certificate Manager, Self-Hosted and uses the Barracuda WAF API with a custom administrator role. An Onboard Discovery job finds the applications on the WAF and their certificates. When a certificate is pushed or renewed, the driver installs it on the device and associates it with the selected services. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted 21.1 and above
- Barracuda Web Application Firewall, firmware 10.1.1 and above

**About Barracuda**

Barracuda Networks provides security, application delivery and data protection solutions. The Barracuda Web Application Firewall protects web applications from data breaches and defacement, as a hardware or virtual appliance, on-premises or in the cloud. Learn more at [barracuda.com](https://www.barracuda.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
