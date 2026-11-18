# F5 BIG-IQ

F5 BIG-IP devices are among the largest consumers of keys and certificates in an enterprise network. Requesting, distributing and renewing them by hand is slow and error-prone, even with BIG-IQ as the central management layer, and mistakes lead to outages and security gaps. This integration, built into F5 BIG-IQ, connects BIG-IQ to Next-Gen Trust Security so certificates for managed BIG-IP devices are issued and renewed under Next-Gen Trust Security policy.

Support for Next-Gen Trust Security is available in F5 BIG-IQ 8.4.2 and later. There is nothing to install.

**Value Highlights**

- **Prevent outages** by automating renewal and deployment of keys and certificates on managed BIG-IP devices.
- **Request certificates from BIG-IQ** using Next-Gen Trust Security as an external certificate authority provider.
- **Use Next-Gen Trust Security templates** so BIG-IQ requests follow the policy your security team defines.
- **Import and synchronize** certificates from Next-Gen Trust Security into BIG-IQ.
- **Give security teams visibility** and policy control over certificates on every BIG-IP device.

**How it Works**

In BIG-IQ, you add Next-Gen Trust Security as a third-party CA provider using an API key, select the application and issuing template to use, and then create certificate requests from BIG-IQ. BIG-IQ communicates with Next-Gen Trust Security over REST APIs to submit CSRs, retrieve issued certificates and synchronize certificates and keys, then deploys them to managed BIG-IP devices. See the Documentation tab for setup steps.

**Applicability**

Any organization running BIG-IP devices in the cloud or in a private data center and managing them with BIG-IQ can use this integration. Without BIG-IQ, the F5 BIG-IP listing on this marketplace achieves the same outcome directly on BIG-IP.

**Solution Components**

- Next-Gen Trust Security
- F5 BIG-IQ Centralized Management 8.4.2 or later
- Managed F5 BIG-IP devices

**About F5**

F5 is a multi-cloud application services and security company that helps organizations secure and optimize apps and APIs on premises, in the cloud or at the edge. Learn more at [f5.com](https://www.f5.com/).
