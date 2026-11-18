# Palo Alto Panorama

Palo Alto Networks Panorama manages the certificates that firewalls use for SSL deep packet inspection, and updating those certificates by hand across templates, device groups and decryption rules is slow and error-prone. The Panorama Adaptable Application for Certificate Manager, Self-Hosted provisions certificates to Panorama and binds them to decryption rules automatically, with the level of commit control your change process needs.

**Value Highlights**

- **Streamline certificate operations**: provision certificates to Panorama templates without manual imports.
- **Automate decryption policy updates**: bind certificates to a Decryption Rule in the device group you choose.
- **Control change rollout**: stage the certificate only, commit just the service account's changes, or commit and push to a device group.
- **Prevent stale certificates**: expired certificates are unbound from the policy and can be removed from Panorama automatically.
- **Enforce policy**: request and track every Panorama certificate through Certificate Manager, Self-Hosted.

**How it Works**

The integration is an Adaptable Application driver delivered as a `.vupkg` package that you install on each Certificate Manager, Self-Hosted server. It uses a Panorama API key to import the certificate and its chain into the template you name, optionally binds it to a Decryption Rule, and commits the change to Panorama or pushes it to the device group. It works with Panorama PAN-OS 10.2 and 11.2 and Certificate Manager, Self-Hosted 23.3 or later. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Palo Alto Networks Panorama

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
