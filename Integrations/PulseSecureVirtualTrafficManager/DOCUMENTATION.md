# Pulse Secure Virtual Traffic Manager

This integration provides an Adaptable Application driver (`Pulse-Secure-vTM.ps1`) that automates TLS certificate provisioning and renewal on Pulse Secure (Ivanti) Virtual Traffic Manager from Certificate Manager, Self-Hosted.

## Prerequisites

- Certificate Manager, Self-Hosted
- Pulse Secure vTM with the REST API reachable on port 9070 from every engine that runs the driver
- A vTM username and password with permission to manage SSL server keys and virtual servers

## Installation

1. Download `Pulse-Secure-vTM.ps1` using the Download button.
2. Copy the script to the `<Venafi root directory>\Scripts\AdaptableApp\` folder on every Certificate Manager, Self-Hosted engine that will run the driver.
3. Create an Adaptable Application driver object and select `Pulse-Secure-vTM.ps1` as the PowerShell script.

## Configuration

1. Create a device for the vTM host and assign a username credential for the vTM REST API.
2. Create an Adaptable application object under the device. Name it exactly as the vTM virtual server the certificate should be bound to.
3. Set **vTM API Version** (required) to the REST API version your vTM exposes. It is used in the API path `/api/tm/<version>/`.

For general Adaptable Application configuration, see the [Adaptable Application PowerShell reference](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/c-drivers-AdaptableApp-PowerShell-reference.php).

## Logs

The driver writes `mdlog.txt` (information), `mderr.txt` (errors) and `mddebug.txt` (debug) in the same folder as the Adaptable framework debug log.
