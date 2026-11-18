# Microsoft IIS

Expired or misconfigured certificates on Microsoft Internet Information Services (IIS) servers cause outages for the websites and applications they host, and tracking those certificates by hand across many Windows servers does not scale. Next-Gen Trust Security discovers the certificates on your IIS servers and provisions new and renewed certificates to them, so certificates stay valid and compliant with your policy without manual installs.

**Value Highlights**

- **Prevent outages**: Find certificates on IIS servers and replace them before they expire.
- **Automate provisioning**: Install certificates in the Windows certificate store and bind them to IIS web sites in one step.
- **Gain visibility**: See every certificate discovered on your IIS servers in the Next-Gen Trust Security inventory.
- **Enforce policy**: Provision only certificates issued under your organization's policies.
- **Fit your Windows environment**: Connect with Kerberos or Basic authentication, over HTTP or HTTPS.

**How it Works**

You create a Microsoft IIS machine in Next-Gen Trust Security. A VSatellite connects to the Windows server through Windows Remote Management (WinRM) to discover certificates and to provision them. When you provision a certificate, Next-Gen Trust Security installs it in the Personal or Web Hosting store of the local computer, installs its issuing chain, and can create or update an HTTPS binding on an IIS web site. See the Documentation tab for requirements and setup.

**Applicability**

The Microsoft IIS machine supports IIS 10.0 or later with the WebAdministration PowerShell module.

**Solution Components**

- Next-Gen Trust Security, with a VSatellite that can reach the server
- Microsoft IIS on Windows Server
