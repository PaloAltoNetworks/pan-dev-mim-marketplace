# SandboxAQ AQtive Guard (fka Cryptosense Analyzer Platform)

SandboxAQ and Venafi have a native integration that solves the problem of lost or missing machine identifies by providing full visibility on cryptography use across applications and filesystems, preventing certificate outages and downtime.

  

**SOLUTION HIGHLIGHTS**

- **Reduce the risk of outages **by ensuring that all in-use certificates are correctly tracked and managed
- **Provide on-demand visibility **on certificate use in applications for compliance and audits
- **Simplify operations **by avoiding human error including use of hard-coded certificates
- **Filters to add found certificates** to Venafi under certain conditions
- **Rules to fail **a build if unmanaged certificates are included
- **Register an issue in Jira **for an unmanaged certificate using our powerful GraphQL API
- **Alert on any scan **containing a certificate that will expire in <3 months without a replacement

  

**SOLUTION OVERVIEW**

Multiple challenges make it hard for security teams to retain end-to-end visibility on certificate use: self-issued LetsEncrypt or DigiCert certificates used during development and testing may move untracked into production; third-party code is used that includes untracked or hard-coded certificates; new certificates are placed in the wrong store; or the application is not restarted to trigger a store reload.

  

AQtive Guard is a complete cryptography management solution. Its unique technology provides full visibility on cryptography use enterprise-wide, including inside running applications. It traces an application's calls to its cryptographic libraries to discover what cryptography is really being used when the application runs, including which keys and certificates are used. It also scans filesystems and containers to discover where the certificates that are called by running applications are stored. This can be used both to find missing certificates and to understand how the application gets access to them.

  

AQtive Guard now integrates directly with Venafi Certificate Manager, Self-Hosted. Users are able to determine whether certificates in a Cryptosense Analyzer Platform scan are already protected by Venafi or not, and directly submit any missing certificates in order to give security teams the full picture of machine identities in use throughout their organization.

  

**HOW IT WORKS**

The process starts with an administrator obtaining a Venafi instance URL and access token from the Venafi platform and entering them into AQtive Guard's integrations tab. Then: 

- A AQtive Guard user traces an application or scans a file system and uploads the resulting trace to AQtive Guard. 
- They use AQtive Guard to generate a report.
- They click the "populate Venafi GUIDs" button in the certificates tab of the report to look up all certificates in the Venafi inventory.
- For all certificates already present in Venafi, they can then either click through to the relevant record, or view selected details within AQtive Guard.
- For any certificates not found in the Venafi inventory, they can examine the details and if they wish, upload them to Venafi with a single click.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
