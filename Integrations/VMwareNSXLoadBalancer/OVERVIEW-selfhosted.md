# VMware NSX Load Balancer (formerly Avi Vantage)

Enforcing HTTPS everywhere matters more than ever, but keeping certificates current across load balancers becomes difficult at scale. VMware NSX Advanced Load Balancer provides a software load balancer, web application firewall and service mesh for fast, scalable and secure application delivery. VMware and Certificate Manager, Self-Hosted work together so networking teams can get started quickly and fully automate the keys and certificates their applications use.

**Value Highlights**

- **Scale HTTPS**: Expand the use of HTTPS without difficult setup or maintenance.
- **Eliminate outages**: Keep keys and certificates continuously updated.
- **Reduce risk**: Avoid security incidents caused by improperly handled keys.
- **Distribute securely**: Deliver keys and certificates to the load balancer automatically and securely.
- **Automate issuance and renewal**: Renewals happen without manual steps.
- **Support TLS inspection**: Integrate with SSL/TLS inspection for visibility into encrypted traffic.

**How it Works**

The `Avi Vantage.ps1` Adaptable App Driver connects Certificate Manager, Self-Hosted to the NSX Advanced Load Balancer controller. When you create a certificate for the load balancer, Certificate Manager, Self-Hosted has the controller generate the CSR remotely, sends it to your configured CA, and pushes the signed certificate and any chain certificates back to the controller. The controller pushes updates to the Service Engines that use the certificate, and Certificate Manager, Self-Hosted learns the virtual service mapping and handles renewals automatically. See the Documentation tab for the workflow and the VMware user guide.

**Solution Components**

- Certificate Manager, Self-Hosted
- VMware NSX Advanced Load Balancer controller and Service Engines
- `Avi Vantage.ps1` Adaptable App Driver

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
