# F5 Distributed Cloud (XC)

Applications delivered through F5 Distributed Cloud (XC) depend on TLS certificates stored in the tenant's namespaces. When those certificates are tracked and renewed by hand, an expired certificate can take an application offline. Certificate Manager, SaaS automates the lifecycle of keys and certificates in F5 Distributed Cloud so they stay valid and compliant with your security policy.

The F5 Distributed Cloud machine type is built into Certificate Manager, SaaS and runs in the cloud. There is nothing to install.

**Value Highlights**

- **Automate key and certificate management** for applications delivered through F5 Distributed Cloud.
- **Minimize application downtime** by making sure certificates never expire unnoticed.
- **Discover existing certificates** in the namespaces of your XC tenant.
- **Bind certificates to HTTP load balancers** as part of provisioning.
- **Ensure compliance** by keeping every key and certificate aligned with your security policy.

**How it Works**

You create an F5 Distributed Cloud machine in Certificate Manager, SaaS with your tenant console URL and an XC API token. Certificate Manager, SaaS connects to the tenant over the F5 Distributed Cloud API, discovers certificate objects in your namespaces and provisions certificates to them, optionally binding them to HTTP load balancers. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, SaaS
- F5 Distributed Cloud tenant and API token

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
