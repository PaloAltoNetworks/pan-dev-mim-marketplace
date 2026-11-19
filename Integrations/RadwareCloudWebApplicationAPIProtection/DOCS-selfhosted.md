# Radware Cloud Web Application API Protection

The full setup procedure is in the **Radware Cloud WAAP Integration Guide** (PDF) under Resources on this listing.

## Before you start

- Certificate Manager, Self-Hosted 22.1 or later.
- The `Radware_Cloud_Consolidated_Portal_Connector_For_Palo_Alto_Networks_1.1.ps1` connector, downloaded from this listing and copied to the `Scripts\AdaptableApp` folder on each Certificate Manager, Self-Hosted server.
- A Cloud WAAP API key with the **Application Basic User**, **Application Admin** and **Infrastructure Certificate Admin** roles. Store it as the password of a **Password Credential**.
- The tenant's **Application Protection ID**, entered as the device's **Hostname/Address**.
- A **Concurrent Connection Limit** of 1 on the device.
- A unique Common Name (CN) for each certificate in the Cloud WAAP tenant that Certificate Manager, Self-Hosted manages.

## Upgrading from CWAF.ps1

Version 1.1.0 authenticates with an API key instead of an API user. Replace the credential on existing policies with a Password Credential that holds the API key, and select the new connector in the policy's **PowerShell Script** setting.
