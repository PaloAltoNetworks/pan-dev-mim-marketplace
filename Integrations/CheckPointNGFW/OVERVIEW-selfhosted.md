# Check Point NGFW

Organizations protected by Check Point Next-Generation Firewalls (NGFW) depend on certificates on the firewall, and handling them by hand is slow and risks expired or out-of-policy certificates. Check Point and Certificate Manager, Self-Hosted together automate the delivery and configuration of these certificates, so they are governed centrally and put into use without manual steps.

**Value Highlights**

- **Automate certificate delivery**: Push new and renewed certificates to Check Point gateways automatically.
- **Remove manual handling**: Stop importing and configuring firewall certificates by hand.
- **Govern centrally**: Keep firewall certificates under the policies you define in Certificate Manager, Self-Hosted.
- **Avoid expirations**: Renew certificates before they expire so firewall services keep working.

**How it Works**

The `Check Point Adaptable App Driver.ps1` Adaptable Application driver connects to the Check Point Management API, adds or updates the server certificate and publishes the change. The target domain is set with the **Domain Name** field, which is policyable, on the application object. When a certificate is issued or renewed, Certificate Manager, Self-Hosted runs the driver so the new certificate is put into use. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Check Point NGFW and management server
- `Check Point Adaptable App Driver.ps1` Adaptable Application driver

**About Check Point**

[Check Point Software Technologies](https://www.checkpoint.com/) provides network, cloud and endpoint security solutions.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
