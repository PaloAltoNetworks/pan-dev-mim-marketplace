# Radware Alteon Load Balancer & ADC

Application teams running Radware Alteon load balancers and application delivery controllers depend on valid TLS certificates on every SSL-enabled virtual service. Replacing those certificates by hand is slow and error-prone, and a missed renewal takes the service down. Radware and Venafi built this integration so Certificate Manager, Self-Hosted can push and renew certificates on Alteon automatically.

**Value Highlights**

- **Prevent outages**: renew certificates on Alteon virtual services before they expire.
- **Remove manual steps**: the driver uploads the certificate, attaches it and the SSL policy to the service, and runs the Alteon apply and save for you.
- **Keep devices clean**: on renewal the old certificate is deleted after the new one is in place.
- **Enforce policy**: every certificate on Alteon is requested and tracked through Certificate Manager, Self-Hosted.

**How it Works**

The integration is an Adaptable Application driver (PowerShell script) that runs in Certificate Manager, Self-Hosted. For each Alteon application object you set the virtual server, service port and SSL policy. When a certificate is pushed or renewed, the driver connects to the Alteon, installs the certificate and binds it to the service. Two driver versions are provided: one for Alteon ADC OS 30.5.1.200 and above, and one for Alteon ADC OS 33.0.x. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted 22.1 and above
- Radware Alteon Load Balancer or ADC

**About Radware**

Radware builds application delivery and cyber security solutions for cloud, on-premises and software-defined data centers. Learn more at [radware.com](https://www.radware.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
