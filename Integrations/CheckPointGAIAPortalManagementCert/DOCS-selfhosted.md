## Prerequisites

- Certificate Manager, Self-Hosted.
- A Check Point GAIA gateway and its management server, reachable from the Certificate Manager, Self-Hosted server.
- Administrative credentials authorized to manage the GAIA Portal certificate.

## Installation

1. Copy `CheckPoint-GAIA-Portal-AdaptableApp.ps1` into the Adaptable Application scripts directory on the Certificate Manager, Self-Hosted server.

## Configuration

1. Create a device for the GAIA gateway and configure its management credential.
2. Add an Adaptable Application under the device and select the Check Point GAIA driver.
3. Set the **Domain Name** and **Gateway Name** fields for the target gateway. Optionally enable **Ignore Warnings** to control how connection warnings are handled during provisioning.
4. Associate the certificate with the application so renewals provision the GAIA Portal certificate automatically.

## Support

For platform assistance, see the [Check Point Support Center](https://supportcenter.checkpoint.com/).
