# WinRM Certificate Deployment

Many Windows hosts run applications that read certificates from files or keystores rather than the Windows certificate store, and updating those by hand is slow and easy to forget. This set of Adaptable drivers lets Certificate Manager, Self-Hosted deploy certificates to remote Windows hosts over Windows Remote Management (WinRM) in the format each application expects, without installing agents on the target machines.

**Value Highlights**

- **Deploy without agents**: Push certificates to Windows hosts over WinRM.
- **Match the application format**: Install certificates as CRT and KEY files, PEM, PKCS#12 (PFX), Java KeyStore (JKS) or IBM CMS key database (KDB).
- **Renew automatically**: Certificates associated with an application are reprovisioned on renewal.
- **Update SSRS bindings**: Use the workflow driver to bind a renewed certificate to SQL Server Reporting Services.
- **Start from open scripts**: Each driver is a PowerShell script you can review and adapt.

**How it Works**

Each Adaptable Application driver connects to the target host over WinRM on issuance or renewal and writes the certificate, private key and chain to the paths or keystore configured on the application object. The SSRS Adaptable Workflow driver uses WinRM and the SSRS WMI provider to reserve URLs and create SSL bindings for the new certificate. See the Documentation tab for the included drivers and setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Windows hosts with WinRM enabled
- WinRM Adaptable Application and Workflow drivers

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
