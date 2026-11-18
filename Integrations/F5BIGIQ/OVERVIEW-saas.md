# F5 BIG-IQ

F5 BIG-IP devices are among the largest consumers of keys and certificates in an enterprise network. Requesting, distributing and renewing them by hand is slow and error-prone, even with BIG-IQ as the central management layer, and mistakes lead to outages and security gaps. This integration, built into F5 BIG-IQ, connects BIG-IQ to Certificate Manager, SaaS so certificates for managed BIG-IP devices are issued and renewed under Certificate Manager, SaaS policy.

Support for Certificate Manager, SaaS is available in F5 BIG-IQ 8.4.2 and later. There is nothing to install.

**Value Highlights**

- **Prevent outages** by automating renewal and deployment of keys and certificates on managed BIG-IP devices.
- **Request certificates from BIG-IQ** using Certificate Manager, SaaS as an external certificate authority provider.
- **Use Certificate Manager, SaaS templates** so BIG-IQ requests follow the policy your security team defines.
- **Import and synchronize** certificates from Certificate Manager, SaaS into BIG-IQ.
- **Give security teams visibility** and policy control over certificates on every BIG-IP device.

**How it Works**

In BIG-IQ, you add Certificate Manager, SaaS as a third-party CA provider using an API key, select the application and issuing template to use, and then create certificate requests from BIG-IQ. BIG-IQ communicates with Certificate Manager, SaaS over REST APIs to submit CSRs, retrieve issued certificates and synchronize certificates and keys, then deploys them to managed BIG-IP devices. See the Documentation tab for setup steps.

**Applicability**

Any organization running BIG-IP devices in the cloud or in a private data center and managing them with BIG-IQ can use this integration. Without BIG-IQ, the F5 BIG-IP listing on this marketplace achieves the same outcome directly on BIG-IP.

**Solution Components**

- Certificate Manager, SaaS
- F5 BIG-IQ Centralized Management 8.4.2 or later
- Managed F5 BIG-IP devices

**About F5**

F5 is a multi-cloud application services and security company that helps organizations secure and optimize apps and APIs on premises, in the cloud or at the edge. Learn more at [f5.com](https://www.f5.com/).

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
