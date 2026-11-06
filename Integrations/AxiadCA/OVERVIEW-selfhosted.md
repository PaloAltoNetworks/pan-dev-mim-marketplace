# Axiad CA

Axiad Cloud PKI integrates with Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform) through an Adaptable CA script, automating the issuance, renewal, and revocation of machine certificates issued by Axiad Cloud PKI.

## How it works

The integration ships two PowerShell drivers for the Adaptable CA framework: `ID_PKI_Adaptable_ScriptRA.ps1` for RA-based provisioning (preferred) and `ID_PKI_Adaptable_Script.ps1` for CA-based provisioning. Requests are authenticated to the Axiad ID_PKI service with a client certificate mapped to a service account that Axiad provisions for your instance.

## Prerequisites

- Certificate Manager, Self-Hosted (Trust Protection Platform)
- An Axiad Cloud PKI (ID_PKI) instance with a service account provisioned for Venafi, and the client certificate (PFX/PKCS#12) associated with that account

## Installation and configuration

1. Copy the appropriate driver into the Adaptable CA script folder on the Venafi server (`ID_PKI_Adaptable_ScriptRA.ps1` for RA-based provisioning, or `ID_PKI_Adaptable_Script.ps1` for CA-based).
2. Create a Certificate Credential in the Policy Tree and import the service-account PFX/PKCS#12 provided by the Axiad PKI administrator.
3. Add the required custom fields (case sensitive): `IssuerDN` and `CAPartition`, plus `RequesterEmail` when using the RA connector. Mark them Required and apply to Certificates.
4. Add an Adaptable CA template, select the credential, set the Service Address and Profile String (certificate template name) provided by Axiad, choose the driver script, and attach the custom fields. Click **Validate**, then save.

## Usage

When requesting a certificate from the Axiad CA template, supply the `CAPartition` and `IssuerDN` values provided by the PKI administrator (a CA may have multiple management partitions). With the preferred RA connector, also supply `RequesterEmail`, which is required for initial enrollment. See `DOCUMENTATION.md` for full step-by-step configuration.
