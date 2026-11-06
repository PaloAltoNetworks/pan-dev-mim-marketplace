# Carillon CA

Carillon's CertServ PKI Suite integrates with Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform) through an Adaptable CA script, enabling certificate lifecycle operations — issuance, renewal, and revocation — for a defined set of certificate types in a Carillon-managed PKI (MPKI) from the Venafi interface.

## How it works

The `Carillon_CA.ps1` Adaptable CA driver signs requests to the MPKI's `extreq` API using a client certificate credential and submits PKCS#10 CSRs; Carillon issues the certificate and returns it to Venafi. Requestable certificate types must use the MPKI's delegated-automation retrieval workflow.

## Prerequisites

- Certificate Manager, Self-Hosted (Trust Protection Platform)
- An operational Carillon-managed PKI using CertServ PKI Suite (the MPKI)
- A client certificate and keypair in PKCS#12/PFX format, issued by the MPKI, for the driver to use
- The MPKI `extreq` API configured with the list of certificate types Venafi should manage

## Installation and configuration

1. Copy the driver to `C:\Program Files\Venafi\Scripts\AdaptableCA\Carillon_CA.ps1` on the Venafi server.
2. Configure a Certificate Credential in the Policy Tree, importing the PKCS#12/PFX file.
3. Select the certificate type(s) to manage: for a single type, set `HKLM\SOFTWARE\Carillon\extreq\certtype` in the registry; for multiple, create a Required, policy-controlled Single Select List custom field named `CarillonCertType` applied to Certificates.
4. Add an Adaptable CA template referencing the credential, the Carillon API URL as the Service Address, and the `Carillon_CA` script; click **Validate**. In Options, set the renewal window, enable Allow Reissuance, and attach `CarillonCertType`.
5. Optionally create a per-certificate-type policy (Management Type: Enrollment, Managed By: Aperture, the Adaptable CA template, and the `CarillonCertType` value), each policy-locked.

## Usage

Subscribers must first be sponsored in the CertServ GUI with all required registration attributes. Then request a credential using a delegated-automation workflow, add a Device/Server Certificate in Venafi with the subscriber name as the Common Name, and use **Renew Now** to issue. Use **Renew Now** again during the renewal window, and **Revoke** to permanently revoke (a new CertServ credential request is required before re-issuance). See `DOCUMENTATION.md` for full configuration and troubleshooting.
