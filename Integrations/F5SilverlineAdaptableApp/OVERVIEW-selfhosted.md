# F5 Silverline

HTTPS encryption is more prevalent than ever but can be difficult to scale. Certificates used by F5 Silverline managed security services are often uploaded and renewed by hand, which risks outages when one expires. This F5-built Adaptable Application driver lets Certificate Manager, Self-Hosted provision and renew TLS certificates on F5 Silverline automatically, keeping application services protected without manual work.

**Value Highlights**

- **Automate the certificate lifecycle** by requesting, provisioning and renewing certificates on F5 Silverline from Certificate Manager, Self-Hosted.
- **Reduce outages** by replacing error-prone manual certificate handling with policy-driven automation.
- **Enforce consistent policy** on the certificates used by F5 Silverline services.
- **Cover the Silverline family**, including DDoS Protection, Web Application Firewall and Shape Defense.

**How it Works**

Certificate Manager, Self-Hosted connects to the F5 Silverline portal through an Adaptable Application driver, a PowerShell script installed on the platform's servers. The driver authenticates with a Silverline API token and uploads renewed certificates and keys under the certificate name you configure. Certificates must be issued by an intermediate CA, not directly by a root CA. See the Documentation tab for installation and configuration steps.

**Solution Components**

- Certificate Manager, Self-Hosted 20.3 or later
- F5 Silverline DDoS Protection, Web Application Firewall or Shape Defense
- F5 Silverline Adaptable Application driver

**About F5 Silverline**

F5 Silverline is a family of managed security services. Silverline DDoS Protection mitigates volumetric DDoS attacks at layers 3 to 7 before they reach your network. Silverline Web Application Firewall protects web apps and data while helping meet PCI DSS. Silverline Shape Defense detects bots, fake users and unauthorized transactions to prevent large-scale fraud.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
