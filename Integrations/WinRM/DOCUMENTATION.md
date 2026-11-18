# WinRM Certificate Deployment

## Included Drivers

| Driver | Type | Format |
| --- | --- | --- |
| `WinRM CRT-KEY.ps1` | Adaptable Application | Separate certificate (CRT) and private key (KEY) files |
| `WinRM PEM.ps1` | Adaptable Application | PEM files |
| `Aeyrix PFX WinRM Driver.ps1` | Adaptable Application | PKCS#12 (PFX) file |
| `WinRM JKS.ps1` | Adaptable Application | Java KeyStore (JKS) |
| `WinRM KDB.ps1` | Adaptable Application | IBM CMS key database (KDB) |
| `WinRM SSRS Workflow.ps1` | Adaptable Workflow | SQL Server Reporting Services (SSRS) SSL binding |

## Prerequisites

- Certificate Manager, Self-Hosted
- Target Windows hosts with WinRM enabled and reachable from the Certificate Manager, Self-Hosted server
- A credential with permission to connect over WinRM and write certificates to the target location on each host

## Installation

1. Copy the drivers for the formats you need into the Adaptable Application (or Adaptable Workflow) scripts directory on the Certificate Manager, Self-Hosted server.

## Configuration

1. Create a device for the target Windows host and configure its WinRM connection credential.
2. Add an Adaptable Application under the device and select the WinRM driver for the required format.
3. Set the format-specific fields:
    - **CRT-KEY** and **PEM**: **Private Key File**, **Certificate File**, **Certificate Chain File** and **Overwrite Existing Chain**.
    - **PFX**: **PKCS#12 File**, **Friendly Name**, **Certificate Chain File**, **Create** and **Reuse Friendly Name**.
    - **JKS**: **Keystore Path**, **Certificate Alias**, **Create keystore**, **reuse alias** and **Keystore Credential**.
    - **KDB**: **Key Store Path**, **Certificate Label**, **Create Keystore**, **Reuse Label** and **Key Store Credential**.
4. Associate the certificate with the application so renewals are provisioned automatically.
5. For SSRS, create an Adaptable Workflow object with `WinRM SSRS Workflow.ps1` and apply it to the certificate.

## Usage

On issuance or renewal, the selected driver connects to the target host over WinRM and installs the certificate in the chosen format. The SSRS workflow driver removes the existing SSRS URL reservations and SSL bindings and recreates them with the new certificate. Choose the driver whose format matches what the consuming application on the host expects.
