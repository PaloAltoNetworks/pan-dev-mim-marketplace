## Prerequisites

- Certificate Manager, Self-Hosted.
- A Check Point NGFW and management server reachable from the Certificate Manager, Self-Hosted server.
- Administrative credentials authorized to manage certificates on the Check Point platform.

## Installation

1. Copy `Check Point Adaptable App Driver.ps1` into the Adaptable Application scripts directory on the Certificate Manager, Self-Hosted server.

## Configuration

1. Create a device for the Check Point gateway and configure its management credential.
2. Add an Adaptable Application under the device and select the Check Point driver.
3. Set the **Domain Name** field for the target gateway.
4. Associate the certificate with the application so renewals provision automatically.

## Support

For platform assistance, see the [Check Point Support Center](https://supportcenter.checkpoint.com/).
