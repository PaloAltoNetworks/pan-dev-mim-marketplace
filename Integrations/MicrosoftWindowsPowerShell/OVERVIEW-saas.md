# Microsoft Windows (PowerShell)

Many Windows services need a certificate in the Windows certificate store plus a binding step before they use it. Doing this by hand on each server makes renewals slow and inconsistent.

With the Microsoft Windows (PowerShell) machine type, Certificate Manager, SaaS installs certificates on Windows servers and can then run a PowerShell function you provide, for example to bind the certificate to a Windows service. Renewed certificates reach the server and the service without manual steps.

**Value Highlights**

- **Install into the right store**: Provision certificates to the Personal, Web Hosting, or Remote Desktop store under the local computer account, along with the issuing chain.
- **Bind with your own logic**: Run a `bind-certificate` function from a signed script on the server, which receives the store name and the certificate thumbprint.
- **Connect over WinRM**: Reach servers through Windows Remote Management from a VSatellite, with Kerberos or Basic authentication and optional HTTPS.
- **Control key export**: Choose whether the private key can be exported after installation. By default it can't.
- **Schedule renewals**: Provision queued certificates, such as renewals, on a daily, weekly, or monthly schedule.

**How it Works**

A VSatellite in your network connects to the Windows server over WinRM with an account in the local Administrators group. When you provision a certificate, Certificate Manager, SaaS installs it in the store you choose and sets its friendly name.

If you enable the PowerShell function, Certificate Manager, SaaS checks that the script exists and that the execution policy is AllSigned, runs the function, and reports its error text if it fails. You write and maintain the script. This machine type supports provisioning only, not discovery.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS with a VSatellite
- Microsoft Windows server with WinRM enabled
- A signed PowerShell script on the server (optional)

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
