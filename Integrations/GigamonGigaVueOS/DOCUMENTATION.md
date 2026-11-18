# Gigamon GigaVue (OS)

## Prerequisites

- Certificate Manager, Self-Hosted with the Adaptable framework.
- The Posh-SSH PowerShell module on every Certificate Manager, Self-Hosted server that runs the driver.
- SSH access to the GigaVUE-OS appliance with an account that can manage certificates and the web server configuration.

## Installation

1. Install Posh-SSH from an administrator PowerShell prompt with `Install-Module -Name Posh-SSH`. Alternatively, download the release zip from [Posh-SSH on GitHub](https://github.com/darkoperator/Posh-SSH/releases), unblock it, unzip it to `C:\Program Files\WindowsPowerShell\Modules` and rename the folder to `Posh-SSH`.
2. Copy `GigamonGigaVUE-HC-CLI.ps1` to the `Scripts\AdaptableApp` folder under the Certificate Manager, Self-Hosted installation folder on every server.

## Configuration

1. Create a username credential for the GigaVUE-OS SSH account.
2. Create a device for the Gigamon appliance with its host address and SSH port, and assign the credential.
3. Add an **Adaptable** application to the device and select the `GigamonGigaVUE-HC-CLI` PowerShell script. The driver uses no custom fields.
4. Associate the application with the certificate for the web management interface and push the certificate.

Certificate names on GigaVUE-OS are limited to 40 characters, and the driver shortens longer asset names.

## Logs

The driver writes a debug log to `Logs\Gigamon-debug.log` under the Certificate Manager, Self-Hosted base path. For help with the driver, contact Gigamon technical support.
