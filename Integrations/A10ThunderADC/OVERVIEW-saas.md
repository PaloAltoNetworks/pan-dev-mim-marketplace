# A10 Networks Thunder ADC

A10 Networks Thunder ADC load balances and terminates HTTPS traffic for business-critical applications. Every virtual server depends on a TLS certificate and key, and keeping those current across many devices and partitions by hand leads to expired certificates, outages and inconsistent key handling.

Certificate Manager, SaaS includes an A10 Thunder ADC machine type that automates this work. It discovers the certificates in the client SSL templates of your virtual servers and provisions renewed certificates to them, so certificates stay valid without manual updates on each device.

**Value Highlights**

- **Scale HTTPS** across Thunder ADC devices without manual certificate setup.
- **Eliminate outages** with continuous certificate renewal and provisioning.
- **Build a complete inventory** by discovering the certificates already used by your virtual servers.
- **Automate provisioning** of renewed certificates to client SSL templates.
- **Support partitioned devices** with one machine that can manage multiple partitions.

**How it Works**

You create an A10 Thunder ADC machine in Certificate Manager, SaaS. A VSatellite on your network connects to the device's aXAPI management interface, discovers certificates in client SSL templates, and provisions certificates to them. The machine type supports devices running ACOS 5.2.1 or later. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS with a VSatellite
- A10 Networks Thunder ADC (ACOS 5.2.1 or later)

**About A10 Networks**

[A10 Networks](https://www.a10networks.com/) provides secure application services and solutions, including high-performance application delivery controllers, that keep business-critical applications secure and available.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
