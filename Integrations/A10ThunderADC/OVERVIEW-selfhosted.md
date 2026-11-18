# A10 Networks Thunder ADC

A10 Networks Thunder ADC load balances and terminates HTTPS traffic for business-critical applications. Every virtual server depends on a TLS certificate and key, and keeping those current across many devices and partitions by hand leads to expired certificates, outages and inconsistent key handling.

The A10 Thunder integration for Certificate Manager, Self-Hosted automates that work. Certificate Manager, Self-Hosted discovers the certificates bound to your Thunder ADC virtual servers, renews them according to your policy, and pushes the new certificate and key to the device without manual steps.

**Value Highlights**

- **Scale HTTPS** across Thunder ADC devices without manual certificate setup.
- **Eliminate outages** with continuous, policy-driven certificate and key renewal.
- **Build a complete inventory** by discovering the certificates already in use on your virtual servers.
- **Automate provisioning** of renewed certificates to client SSL templates.
- **Support partitioned devices** by targeting a specific Thunder ADC partition per application.

**How it Works**

The integration is an Adaptable Application driver (`A10-Thunder.ps1`) for Certificate Manager, Self-Hosted. The driver connects to the Thunder ADC management interface, uploads the certificate and private key, and binds them to the client SSL template of the virtual server and port you specify. It can also discover certificates already configured on the device. The integration supports ACOS 5.2.1 and later. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- A10 Networks Thunder ADC (ACOS 5.2.1 or later)

**About A10 Networks**

[A10 Networks](https://www.a10networks.com/) provides secure application services and solutions, including high-performance application delivery controllers, that keep business-critical applications secure and available.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
