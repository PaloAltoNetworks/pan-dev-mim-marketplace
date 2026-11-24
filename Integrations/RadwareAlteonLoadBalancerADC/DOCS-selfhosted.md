# Radware Alteon Load Balancer & ADC

The full setup procedure is in the **Radware Alteon Integration Guide** (PDF) under Resources on this listing.

## Before you start

- The `Radware_Alteon_Connector_For_PaloAlto_1.1.ps1` connector, downloaded from this listing and copied to the `Scripts\AdaptableApp` folder on every Certificate Manager, Self-Hosted server that may run it.
- Windows PowerShell 5.1 and `curl.exe` 7.76 or later on each of those servers.
- HTTPS connectivity from each server to the Alteon management interface, and trust in the Alteon management certificate unless **Trust Insecure Alteon Device Management Certificate** is enabled.
- An Alteon account that can read certificate configuration, change configuration, apply changes and save configuration.
- Confirm the supported Certificate Manager, Self-Hosted and Alteon releases with Radware before deployment.

## Notes

- **Certificate Name in Alteon** is required. Enter the exact Alteon server certificate ID, not the Common Name or the application name.
- Apply and Save commit all pending configuration on the Alteon, including changes made outside the connector. Review pending changes before provisioning.
- With HA Auto-Sync enabled, configure only the primary device. With Auto-Sync disabled, configure every device in the cluster.

## Upgrading from the 1.0.0 scripts

Version 2.0.0 replaces the two OS-specific scripts with a single connector. It no longer binds the certificate or SSL policy to a virtual service. Set **Certificate Name in Alteon** on each existing application and select the new connector in the policy's **PowerShell Script** setting.
