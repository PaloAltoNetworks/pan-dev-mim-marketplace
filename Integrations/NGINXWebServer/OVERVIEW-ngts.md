# NGINX Web Server

Expired or misconfigured certificates on NGINX web servers take down the websites and applications they serve. Next-Gen Trust Security manages certificates for NGINX through its Common KeyStore machine, which discovers and provisions the PEM certificate and key files that NGINX reads, so you can renew certificates on time without editing files by hand on each server.

**Value Highlights**

- **Prevent outages**: Find the certificates NGINX uses and replace them before they expire.
- **Automate provisioning**: Write the certificate, chain and private key to the PEM files your NGINX configuration points to.
- **Restart on change**: Optionally restart the NGINX service after a certificate is provisioned so the new certificate takes effect.
- **Gain visibility**: See certificates discovered on your NGINX hosts in the Next-Gen Trust Security inventory.
- **Cover any NGINX deployment**: Works with open-source NGINX and NGINX Plus on Linux or Windows hosts.

**How it Works**

Next-Gen Trust Security has no NGINX-specific machine type. You create a Common KeyStore (PEM, JKS, PKCS#12) machine for each NGINX host. A VSatellite connects to the host over SSH or Windows Remote Management (WinRM), discovers certificates in the keystore files, and provisions certificates to the PEM file paths that NGINX uses. See the Documentation tab for requirements and setup.

**Solution Components**

- Next-Gen Trust Security, with a VSatellite that can reach the host
- NGINX or NGINX Plus on Linux or Windows
