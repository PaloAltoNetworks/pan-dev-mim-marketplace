# WinRM Certificate Deployment

A set of Adaptable Application drivers that deploy certificates to remote Windows hosts over Windows Remote Management (WinRM) from Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform). Each driver provisions certificates in a different on-host format, so you can automate installation without local agents on the target machines.

## Included drivers

| Driver | Format |
| --- | --- |
| `WinRM CRT-KEY.ps1` | Separate certificate (CRT) and private key (KEY) files |
| `WinRM PEM.ps1` | PEM bundle |
| `WinRM PFX.ps1` (`Aeyrix PFX WinRM Driver.ps1`) | PKCS#12 / PFX keystore |
| `WinRM JKS.ps1` | Java KeyStore (JKS) |
| `WinRM KDB.ps1` | IBM CMS key database (KDB) |
| `WinRM SSRS Workflow.ps1` | SQL Server Reporting Services (SSRS) binding workflow |

## Prerequisites

- Certificate Manager, Self-Hosted (Trust Protection Platform)
- Target Windows hosts with WinRM enabled and reachable from the Venafi server
- A credential with permission to connect over WinRM and write certificates to the target location on each host

## Installation and configuration

1. Copy the driver(s) for the format(s) you need into the Adaptable Application scripts directory on the Venafi server.
2. Create a device for the target Windows host and configure its WinRM connection credential.
3. Add an Adaptable Application under the device, select the appropriate WinRM driver for the required output format, and set the destination path and any format-specific options (for example, keystore password for PFX/JKS/KDB).
4. Associate the certificate with the application so renewals provision automatically.

## Usage

On issuance or renewal, the selected driver connects to the target host over WinRM and installs the certificate in the chosen format. Use the SSRS workflow driver to bind a certificate to SQL Server Reporting Services. Choose the driver whose format matches what the consuming application on the host expects.
