# Check Point GAIA Portal Management

The Check Point GAIA web management portal relies on a TLS certificate, and an expired or untrusted certificate disrupts administrators and weakens trust in the management interface. This integration lets Certificate Manager, Self-Hosted provision and renew the GAIA Portal certificate, so the management interface stays trusted without manual updates.

**Value Highlights**

- **Automate portal certificates**: Provision and renew the GAIA Portal TLS certificate from Certificate Manager, Self-Hosted.
- **Prevent expirations**: Renew the certificate before it expires so administrators keep uninterrupted access.
- **Target the right gateway**: Scope each certificate to a specific domain and gateway.
- **Enforce policy**: Set the domain and gateway through policy for consistent configuration.

**How it Works**

The `CheckPoint-GAIA-Portal-AdaptableApp.ps1` Adaptable Application driver connects to the Check Point Management API, adds or updates the server certificate, assigns it to the portal of the target gateway and publishes the change. The **Domain Name** and **Gateway Name** fields on the application object, both policyable, select the target. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Check Point management server and GAIA gateway
- `CheckPoint-GAIA-Portal-AdaptableApp.ps1` Adaptable Application driver

**About Check Point**

[Check Point Software Technologies](https://www.checkpoint.com/) provides network, cloud and endpoint security solutions.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
