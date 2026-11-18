# Oracle Wallet Provisioning Driver

Oracle databases and middleware read their TLS certificates and private keys from Oracle Wallets. Updating those wallets by hand at every renewal is slow and error-prone, and a missed update can break encrypted connections. The Secur Solutions Oracle Wallet Provisioning Driver automates the secure provisioning of SSL/TLS certificates and private keys from Certificate Manager, Self-Hosted directly into your Oracle Wallets.

**Value Highlights**

- **Automate wallet updates**: Deliver certificates and private keys issued by Certificate Manager, Self-Hosted into Oracle Wallets without manual import steps.
- **Prevent outages**: Keep wallets current when certificates are renewed, so Oracle services do not run on expired certificates.
- **Reduce handling of private keys**: Move keys into wallets through an automated process rather than by copying files between administrators.
- **Apply policy consistently**: Certificates provisioned to Oracle Wallets are issued and tracked under your Certificate Manager, Self-Hosted policy.

**How it Works**

The driver is an Adaptable framework driver for Certificate Manager, Self-Hosted. When a certificate is issued or renewed, Certificate Manager, Self-Hosted runs the driver to place the certificate and private key in the configured Oracle Wallet. Contact Secur Solutions Group for access to the Provisioning Driver and its setup guide.

**Solution Components**

- Certificate Manager, Self-Hosted
- Oracle Wallet on the target Oracle systems

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) is a Singapore-based identity and digital certificate lifecycle partner of Entrust, HID Global and CyberArk.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
