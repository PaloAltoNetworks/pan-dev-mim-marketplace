# Delinea Credentials

Provisioning certificates to devices and applications requires privileged credentials for those systems, and copying them into another tool adds risk and maintenance. This integration lets Certificate Manager, Self-Hosted retrieve privileged credentials from Delinea Secret Server when it needs them, using the Adaptable Credential framework, so the credentials are not stored in Certificate Manager, Self-Hosted.

**Value Highlights**

- **Improve security posture**: credentials are stored only in Delinea Secret Server.
- **Prevent outages**: Certificate Manager, Self-Hosted always uses the most recent credential for provisioning operations.
- **Keep one source of truth**: Secret Server remains the place where credentials are stored, rotated and audited.
- **Require no Secret Server changes**: the integration works with your existing Delinea Secret Server deployment.

**How it Works**

An Adaptable Credential object in Certificate Manager, Self-Hosted uses a PowerShell script to authenticate to Delinea Secret Server and retrieve privileged credentials on demand. Provisioning operations that reference the Adaptable Credential receive the current secret from Secret Server instead of a stored copy.

**Solution Components**

- Certificate Manager, Self-Hosted
- Delinea Secret Server

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
