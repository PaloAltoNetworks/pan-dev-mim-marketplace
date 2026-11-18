# Huawei Cloud Elastic Load Balancer (ELB) Connector

Huawei Cloud Elastic Load Balancer (ELB) terminates HTTPS and TLS traffic with server certificates that are uploaded to ELB and bound to listeners. Uploading and rebinding those certificates by hand on every renewal is slow and leads to expired certificates on public services. The Secur Solutions Connector for Huawei Cloud ELB connects Certificate Manager, SaaS to Huawei Cloud, so certificates for your load balancers are provisioned, uploaded and assigned automatically.

**Value Highlights**

- **Automate provisioning**: Deliver certificates issued under your Certificate Manager, SaaS policy to Huawei Cloud ELB.
- **Upload and assign in one step**: Upload each certificate to ELB and assign it to the load balancer listeners that use it.
- **Prevent outages**: Replace certificates on ELB listeners before they expire.
- **Reduce manual work**: Remove repeated console uploads and listener edits on every renewal.

**How it Works**

The connector runs with Certificate Manager, SaaS and uses the Huawei Cloud APIs to upload certificates to ELB and bind them to listeners. When a certificate is issued or renewed in Certificate Manager, SaaS, it is uploaded to Huawei Cloud as an ELB server certificate and assigned to the configured listener. Contact Secur Solutions Group for installation and setup.

**Solution Components**

- Certificate Manager, SaaS
- Huawei Cloud Elastic Load Balancer (ELB)
- Secur Solutions Connector for Huawei Cloud ELB

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) builds certificate lifecycle integrations for CyberArk Certificate Manager and provides identity and security consultancy services.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
