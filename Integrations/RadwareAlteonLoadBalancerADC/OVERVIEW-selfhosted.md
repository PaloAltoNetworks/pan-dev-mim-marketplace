# Radware Alteon Load Balancer & ADC

Application teams running Radware Alteon load balancers and application delivery controllers depend on valid TLS certificates on every SSL-enabled virtual service. Replacing those certificates by hand is slow and error-prone, and a missed renewal takes the service down. Radware and Venafi built this integration so Certificate Manager, Self-Hosted can install and renew certificates on Alteon automatically.

**Value Highlights**

- **Prevent outages**: renew certificates on Alteon before they expire.
- **Onboard what exists**: Onboard Discovery creates one application for each virtual service that uses an SSL server certificate.
- **Renew in place**: the connector replaces the contents of the named Alteon certificate object, so every service that references it picks up the new certificate.
- **Manage the chain**: intermediate CA certificates are uploaded, grouped and attached to the server certificate, and unused connector-managed CA objects are removed.
- **Change only what's needed**: Apply and Save run only when something changed, and HA Sync runs on the master when synchronization is needed.
- **Enforce policy**: every certificate on Alteon is requested and tracked through Certificate Manager, Self-Hosted.

**How it Works**

The integration is an Adaptable Application connector (PowerShell script) that runs in Certificate Manager, Self-Hosted and calls the Alteon REST API. For each application you set the **Certificate Name in Alteon**, the ID of the server certificate object to install, renew or extract. When a certificate is pushed or renewed, the connector imports the certificate and private key under that name, attaches the intermediate CA group, and applies and saves the configuration. The connector does not bind certificates to virtual services. Virtual Server, Service Port and SSL Policy are informational fields filled by discovery, and a new certificate name must be bound to its service in Alteon. See the Radware integration guide in Resources for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Radware Alteon Load Balancer or ADC

**About Radware**

Radware builds application delivery and cyber security solutions for cloud, on-premises and software-defined data centers. Learn more at [radware.com](https://www.radware.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
