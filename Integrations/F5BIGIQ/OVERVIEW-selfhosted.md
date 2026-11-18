# F5 BIG-IQ

F5 BIG-IP devices are among the largest consumers of keys and certificates in an enterprise network. Requesting, distributing and renewing them by hand is slow and error-prone, even with BIG-IQ as the central management layer, and mistakes lead to outages and security gaps. This integration, built into F5 BIG-IQ, connects BIG-IQ to Certificate Manager, Self-Hosted so certificates for managed BIG-IP devices are issued and renewed under Certificate Manager, Self-Hosted policy.

The integration ships with F5 BIG-IQ. There is nothing to install.

**Value Highlights**

- **Prevent outages** by automating renewal and deployment of keys and certificates on managed BIG-IP devices.
- **Add Certificate Manager, Self-Hosted as a third-party CA provider** in BIG-IQ.
- **Create CSRs in BIG-IQ** and get them signed through Certificate Manager, Self-Hosted.
- **Import certificates and keys**, including private SSL certificates, from Certificate Manager, Self-Hosted.
- **Monitor synchronization** with BIG-IQ sync scheduler alerts.
- **Give security teams visibility** and policy control over certificates on every BIG-IP device.

**How it Works**

In BIG-IQ, you register Certificate Manager, Self-Hosted as a third-party CA provider. BIG-IQ then submits certificate requests to Certificate Manager, Self-Hosted, imports the issued certificates and keys, keeps them synchronized on a schedule, and deploys them to managed BIG-IP devices. See the Documentation tab for setup steps. F5 article [K17379: Managing BIG-IP SSL certificates and keys](https://my.f5.com/manage/s/article/K17379) describes the manual process this integration replaces.

**Applicability**

Any organization running BIG-IP devices in the cloud or in a private data center and managing them with BIG-IQ can use this integration. Without BIG-IQ, the F5 BIG-IP listing on this marketplace achieves the same outcome directly on BIG-IP.

**Solution Components**

- Certificate Manager, Self-Hosted
- F5 BIG-IQ Centralized Management
- Managed F5 BIG-IP devices

**About F5**

F5 is a multi-cloud application services and security company that helps organizations secure and optimize apps and APIs on premises, in the cloud or at the edge. Learn more at [f5.com](https://www.f5.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
