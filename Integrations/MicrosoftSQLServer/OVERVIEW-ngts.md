# Microsoft SQL Server

Microsoft SQL Server uses a network certificate to encrypt client connections with TLS. Replacing that certificate means installing it on the server, assigning it to each instance, and restarting the service, which is easy to postpone until the certificate expires.

Next-Gen Trust Security automates this for Windows servers that run SQL Server. It installs the certificate in the server's Personal store and can set it as the network certificate of one or all SQL Server instances.

**Value Highlights**

- **Install with the chain**: Place the certificate in the Personal store and its issuing chain in the intermediate and trusted root stores.
- **Assign to instances**: Set the certificate as the network certificate of a named instance or of every instance found on the server.
- **Restart when you choose**: Restart the affected SQL Server services so the new certificate takes effect, or skip the restart and do it later.
- **Connect over WinRM**: Reach servers through Windows Remote Management from a VSatellite, with Kerberos or Basic authentication and optional HTTPS.
- **Schedule renewals**: Provision queued certificates, such as renewals, on a daily, weekly, or monthly schedule.

**How it Works**

A VSatellite connects to the Windows server over WinRM with an account in the local Administrators group. Next-Gen Trust Security installs the certificate and, if you enable the SQL Server option, uses the dbatools PowerShell module on the server to set the network certificate of the instances you choose.

SQL Server starts using the new certificate only after the instance restarts. This machine type supports provisioning only, not discovery. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security with a VSatellite
- Microsoft SQL Server on a Windows server with WinRM enabled
- dbatools PowerShell module on the server
