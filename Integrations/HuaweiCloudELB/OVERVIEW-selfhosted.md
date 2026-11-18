# Huawei Cloud Elastic Load Balancer (ELB) Adaptable App Driver

Huawei Cloud Elastic Load Balancer (ELB) terminates HTTPS and TLS traffic with server certificates that are uploaded to ELB and bound to listeners. Uploading and rebinding those certificates by hand on every renewal is slow and leads to expired certificates on public services. The Secur Solutions Adaptable App Driver for Huawei Cloud ELB connects Certificate Manager, Self-Hosted to Huawei Cloud, so certificates for your load balancers are provisioned, uploaded and assigned automatically.

**Value Highlights**

- **Automate provisioning**: Deliver certificates issued under your Certificate Manager, Self-Hosted policy to Huawei Cloud ELB.
- **Upload and assign in one step**: Upload each certificate to ELB and assign it to the load balancer listeners that use it.
- **Prevent outages**: Replace certificates on ELB listeners before they expire.
- **Reduce manual work**: Remove repeated console uploads and listener edits on every renewal.

**How it Works**

The driver is built on the Adaptable Application framework of Certificate Manager, Self-Hosted and uses the Huawei Cloud APIs to upload certificates to ELB and bind them to listeners. When a certificate is issued or renewed in Certificate Manager, Self-Hosted, it is uploaded to Huawei Cloud as an ELB server certificate and assigned to the configured listener. Contact Secur Solutions Group for installation and setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Huawei Cloud Elastic Load Balancer (ELB)
- Secur Solutions Adaptable App Driver for Huawei Cloud ELB

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) builds certificate lifecycle integrations for CyberArk Certificate Manager and provides identity and security consultancy services.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
