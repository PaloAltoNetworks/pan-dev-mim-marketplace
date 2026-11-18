# Microsoft IIS

Expired or misconfigured certificates on Microsoft Internet Information Services (IIS) servers cause outages for the websites and applications they host, and tracking those certificates by hand across many Windows servers does not scale. Certificate Manager, SaaS discovers the certificates on your IIS servers and provisions new and renewed certificates to them, so certificates stay valid and compliant with your policy without manual installs.

**Value Highlights**

- **Prevent outages**: Find certificates on IIS servers and replace them before they expire.
- **Automate provisioning**: Install certificates in the Windows certificate store and bind them to IIS web sites in one step.
- **Gain visibility**: See every certificate discovered on your IIS servers in the Certificate Manager, SaaS inventory.
- **Enforce policy**: Provision only certificates issued under your organization's policies.

**How it Works**

You create a Microsoft IIS machine in Certificate Manager, SaaS. A VSatellite connects to the Windows server through Windows Remote Management (WinRM) to discover certificates and to provision them. When you provision a certificate, Certificate Manager, SaaS installs it in the Windows certificate store and can bind it to an IIS web site. See the Documentation tab for requirements and setup.

**Solution Components**

- Certificate Manager, SaaS, with a VSatellite that can reach the server
- Microsoft IIS on Windows Server

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
