# F5 Distributed Cloud (XC)

Applications delivered through F5 Distributed Cloud (XC), including those protected by Distributed Cloud Web Application and API Protection (WAAP), depend on TLS certificates stored in the tenant's namespaces. When those certificates are tracked and renewed by hand, an expired certificate can take an application offline. This F5-built driver lets Certificate Manager, Self-Hosted automate the lifecycle of keys and certificates in F5 Distributed Cloud so they stay valid and compliant with your security policy.

**Value Highlights**

- **Automate key and certificate management** for applications delivered through F5 Distributed Cloud.
- **Minimize application downtime** by making sure certificates never expire unnoticed.
- **Increase visibility and control** over certificates across all XC applications.
- **Create load balancers automatically**, optionally, with an FQDN matching the certificate CN.
- **Ensure compliance** by keeping every key and certificate aligned with your security policy.

**How it Works**

Certificate Manager, Self-Hosted connects to F5 Distributed Cloud through an Adaptable Application driver, a PowerShell script installed on the platform's servers. The driver authenticates with an XC API token, pushes certificates and keys into an application namespace, and can validate the result against the load balancer FQDN. See the Documentation tab for installation and configuration steps.

**Solution Components**

- Certificate Manager, Self-Hosted
- F5 Distributed Cloud tenant
- F5 Distributed Cloud Adaptable Application driver

**About F5**

F5 helps organizations scale cloud, data center and software-defined networking deployments to deliver applications on premises, in the cloud or at the edge. Learn more at [f5.com](https://www.f5.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
