# NetScaler Console Service (formerly Citrix ADM)

Creating or renewing an SSL certificate on a NetScaler ADC has traditionally meant a network admin creating a CSR, handing it to the PKI team, waiting for a certificate authority, then installing the certificate and binding it to the application's virtual servers. That process spans several teams and gives little visibility into expiring or noncompliant certificates.

NetScaler Console Service integrates with Certificate Manager, Self-Hosted so application owners can monitor, create, renew and bind SSL certificates for their applications from the NetScaler Console application dashboard, without involving network admins. Certificates are requested through Certificate Manager, Self-Hosted, so they follow your organization's policy.

**Value Highlights**

- **Prevent outages**: Automate certificate renewal so expired certificates do not take applications down.
- **Remove bottlenecks**: Let application owners handle their own certificates through role-based dashboards.
- **Manage the full lifecycle**: Create, install, renew and revoke certificates directly from NetScaler Console.
- **Find and fix SSL issues**: Review SSL issues and application scores and apply suggested remediation.
- **Bind certificates automatically**: Secure applications by binding issued certificates to NetScaler virtual servers.

**How it Works**

The integration is delivered with NetScaler Console Service, so there is nothing to install. You add your Certificate Manager, Self-Hosted server as a third-party CA in NetScaler Console, optionally enabling auto-renew, and point it at a policy folder. NetScaler Console then requests certificates through that policy folder and installs them across your NetScaler ADC instances. See the Documentation tab for the configuration guide.

**Solution Components**

- Certificate Manager, Self-Hosted
- NetScaler Console Service
- NetScaler ADC instances

**About NetScaler Console**

[NetScaler Console](https://www.netscaler.com/) provides a centralized dashboard for managing SSL across multiple NetScaler ADC instances, including creating, installing, monitoring and automatically renewing certificates.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
