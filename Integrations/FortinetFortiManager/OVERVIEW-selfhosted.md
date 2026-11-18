# Fortinet FortiManager

FortiManager is the central console network administrators use to manage the FortiManager appliance and their suite of Fortinet devices. Its web-based management interface is protected by a TLS certificate, and an expired or untrusted certificate disrupts administrator access and weakens security.

The Fortinet FortiManager Adaptable Application lets Certificate Manager, Self-Hosted automate enrollment and provisioning of the TLS certificate used by the FortiManager management interface, so it stays compliant with corporate policy and is renewed before it expires.

**Value Highlights**

- **Streamline** certificate lifecycle operations for your FortiManager systems.
- **Enhance visibility** and compliance with corporate certificate policy.
- **Automate** certificate requests and distribution to improve efficiency.
- **Reduce threats and errors** through a uniform deployment process.

**How it Works**

The FortiManager Adaptable Application is a PowerShell driver for the Certificate Manager, Self-Hosted Adaptable framework that connects to the FortiManager JSON API. An Onboard Discovery job runs an authenticated scan to import the management interface certificate and create the matching certificate and Adaptable Application objects. Certificate Manager, Self-Hosted then renews the certificate and provisions it to FortiManager under the configured certificate label. See the Documentation tab for installation and configuration.

**Applicability**

Tested with Certificate Manager, Self-Hosted 22.2 or higher, PowerShell 5.1, and FortiManager 6.4 or 7.0.

**Solution Components**

- Certificate Manager, Self-Hosted
- Fortinet FortiManager
- FortiManager Adaptable Application

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
