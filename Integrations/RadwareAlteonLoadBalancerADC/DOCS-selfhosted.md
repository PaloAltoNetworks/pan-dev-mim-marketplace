# Radware Alteon Load Balancer & ADC

## Prerequisites

- Certificate Manager, Self-Hosted 22.1 or later.
- The driver script that matches your Alteon version, downloaded from this listing: `Radware Alteon ADC OS 30.5.1.200 and above.ps1` or `Radware Alteon ADC OS 33.0.x.ps1`.
- The IP address of the Alteon, and the user name and password of an Alteon account. Contact Radware support if needed.
- In auto-sync mode, configure only the master device in Certificate Manager, Self-Hosted.

## Installation

1. Download the driver script for your Alteon version from this listing.
2. Copy it to the `Scripts\AdaptableApp` folder under the Certificate Manager, Self-Hosted installation folder on each server, so it appears in the **PowerShell Script** list.

## Configuration

1. In Certificate Manager, Self-Hosted, create a new policy named **Alteon** (or any relevant name).
2. Click the new policy, open the **Application** tab, go to **Adaptable Settings** > **PowerShell Script**, select the driver script, and click **Save**.
3. Right-click the policy and select **Add** > **Devices** > **Device**. Under **General**, enter a **Device Name**. Under **Host Information**, enter the Alteon IP address in **Hostname/Address**. Click **Save**.
4. Right-click the device and select **Add** > **Credential** > **Username Credential**. Under **General**, enter a **Credential Name**. Under **Settings**, set **Expires** if needed. Under **Credential**, enter **User Name**, **Password** and **Confirm Password**. Click **Save**.
5. Open the device again and select the new credential in **Device Credentials**.
6. Right-click the device and select **Add** > **Application** > **Adaptable**. Under **General**, enter an **Application Name**. Under **Certificate**, select the certificate to manage.
7. Under **Adaptable Settings**, fill in these fields:
   - **Virtual Server**: the name of the virtual server whose certificate you want to push or replace.
   - **Service Port**: the port that the SSL service listens on.
   - **SSL Policy**: the SSL policy for that service.
8. Click **Save**.

## Covered Scenarios

- **Push certificate**: Certificate Manager, Self-Hosted uploads the certificate to the Alteon and attaches the certificate and SSL policy to the service.
- **Renew certificate**: Certificate Manager, Self-Hosted replaces the certificate on the Alteon, attaches the new certificate and SSL policy to the service, and then deletes the old certificate.

The driver runs the Alteon apply and save after each change.

## Logs

The driver can write two log files:

- **Debug log**: written when **Enable Debug Logging** is selected on the application.
- **Error log**: written when an error occurs, even if debug logging is off.

## Disclaimer

This script is for use at your own choice. The script is provided as is without any warranty of any kind and Radware disclaims any and all liability regarding any use of the script.
