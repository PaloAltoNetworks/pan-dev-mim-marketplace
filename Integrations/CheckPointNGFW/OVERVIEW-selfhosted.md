# Check Point NGFW

Check Point and Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform) together automate the delivery and configuration of the machine identities used by organizations protected with Check Point Next-Generation Firewalls (NGFW). This removes manual certificate handling on the firewall and keeps its certificates governed centrally by Venafi.

## How it works

The `Check Point Adaptable App Driver.ps1` script implements the Venafi Adaptable Application framework and provisions certificates to a Check Point gateway scoped by a **Domain Name** (supplied as a policyable field on the application object). On issuance or renewal, Venafi pushes the new certificate to the firewall so it is put into use automatically.

## Prerequisites

- Certificate Manager, Self-Hosted (Trust Protection Platform)
- A Check Point NGFW / management server reachable from the Venafi server
- Administrative credentials authorized to manage certificates on the Check Point platform

## Installation and configuration

1. Copy `Check Point Adaptable App Driver.ps1` into the Adaptable Application scripts directory on the Venafi server.
2. Create a device for the Check Point gateway and configure its management credential.
3. Add an Adaptable Application under the device, select the Check Point driver, and set the **Domain Name** field for the target gateway.
4. Associate the certificate with the application so renewals provision automatically.

## Support

For platform assistance, see the [Check Point Support Center](https://supportcenter.checkpoint.com/).
