# Check Point GAIA Portal Management

Automate the certificate used by the Check Point GAIA web management portal with Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform). The integration provisions and renews the GAIA Portal's TLS certificate so the management interface stays trusted without manual updates.

## How it works

The `CheckPoint-GAIA-Portal-AdaptableApp.ps1` script implements the Venafi Adaptable Application framework and installs the certificate on a specific Check Point gateway, targeted by a **Domain Name** and **Gateway Name** (both policyable fields on the application object). An optional **Ignore Warnings** flag controls how connection warnings are handled during provisioning.

## Prerequisites

- Certificate Manager, Self-Hosted (Trust Protection Platform)
- A Check Point GAIA gateway reachable from the Venafi server
- Administrative credentials authorized to manage the GAIA Portal certificate

## Installation and configuration

1. Copy `CheckPoint-GAIA-Portal-AdaptableApp.ps1` into the Adaptable Application scripts directory on the Venafi server.
2. Create a device for the GAIA gateway and configure its management credential.
3. Add an Adaptable Application under the device, select the Check Point GAIA driver, and set the **Domain Name** and **Gateway Name** fields for the target gateway (optionally enable **Ignore Warnings**).
4. Associate the certificate with the application so renewals provision the GAIA Portal certificate automatically.

## Support

For platform assistance, see the [Check Point Support Center](https://supportcenter.checkpoint.com/).
