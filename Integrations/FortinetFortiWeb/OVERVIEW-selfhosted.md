# Fortinet FortiWeb

For a web application firewall (WAF) to provide maximum protection, it must inspect HTTPS traffic as well as HTTP, which means terminating TLS with the keys and certificates of the applications it protects. If those certificates are missing, expired or out of date on the WAF, inspection stops or applications go down.

The Fortinet FortiWeb Adaptable Application Driver lets Certificate Manager, Self-Hosted discover and provision the TLS certificates on FortiWeb, the WAF that protects web applications and APIs from known and unknown exploits.

**Value Highlights**

- **Get started fast** with your existing FortiWeb key and certificate inventory.
- **Maximize WAF coverage** with full discovery of Local certificates on the appliance.
- **Maintain protection** with automated renewal and distribution of keys and certificates.
- **Keep policies current** by updating Server Policies and SNI Certificate rules to the new certificate version.
- **Map the chain** by uploading CA and intermediate certificates to a specified certificate group.

**How it Works**

The driver is a PowerShell script for the Certificate Manager, Self-Hosted Adaptable framework that uses the FortiWeb REST API on physical or virtual appliances. Discovery imports Local certificates already on FortiWeb (without private keys) so they can be brought under management. Provisioning generates new keys and certificates, uploads them as Local certificates, and where enabled updates the Server Policies and SNI rules that reference them. See the Documentation tab for installation and configuration.

**Applicability**

Qualified against Certificate Manager, Self-Hosted 25.1 on Windows Server 2019.

**Solution Components**

- Certificate Manager, Self-Hosted
- Fortinet FortiWeb (physical or virtual appliance)
- FortiWeb Adaptable Application Driver

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
