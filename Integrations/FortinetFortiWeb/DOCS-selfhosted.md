# Fortinet FortiWeb Adaptable Application Driver — Installation and Usage Guide (v2.3.0)

## Introduction

The FortiWeb driver is an Adaptable Application Driver that gives Certificate Manager, Self-Hosted (CMSH) the ability to discover certificates on, and provision certificates to, a FortiWeb appliance — virtual or physical.

- **Discovery** finds Local certificates already installed on the FortiWeb appliance and imports them (without private keys) into CMSH, giving administrators visibility and a path to bring them under full CMSH management.
- **Provisioning** generates new private keys and certificates, uploads them to the FortiWeb appliance as Local certificates, and — where enabled — updates Server Policies and SNI Certificate rules to point to the new certificate version. The certificate chain is uploaded and assigned to a specified certificate group.

## Assumptions and Constraints

### Assumptions

This guide assumes familiarity with general CMSH concepts, the Vedadmin and Aperture web UIs, and CMSH's provisioning and discovery principles.

### Constraints

- Qualified against CMSH 25.1 running on Windows 2019.
- No additional software is required on the CMSH servers beyond CMSH itself.
- Administrator privileges are required to install on a CMSH server.

## Installation

1. Unzip the downloaded package.
2. Copy `FortiWeb.ps1` to the `AdaptableApp` folder under the CMSH installation folder (typically `C:\Program Files\Venafi\Scripts\AdaptableApp`).

## Configuration Steps

### Configure the CMSH Policy

1. In the Policy Tree, select a parent policy folder that will hold the device and application objects.
2. Select the **Applications** tab, then the **Adaptable** tab.
3. Set **PowerShell Script** to `FortiWeb`.
4. Set **Update Server and SNI Policies**:
   - **Yes** — the driver looks for Server and SNI certificate policies referencing either the certificate name on its own, or the certificate name followed by a recognized suffix (see [Manual Provisioning](#manual) below), and updates any matching policy to reference the newly-installed certificate.
   - **No** — use this if the driver is only being used for discovery.
   - Optionally lock the policy.
5. Click **Save**.

### Create the Device Credential and Device Object

1. Create a new Username Credential with access to inspect and modify configuration objects on the FortiWeb appliance.
2. Create a Device object for each FortiWeb appliance, in the policy folder configured above:
   - **Device Name** — a name for the appliance.
   - **Hostname/Address** — the appliance's hostname or IP address.
   - **Device Credential** — the Username Credential created above.
3. Click **Save**.

## Provisioning

To provision a certificate to a configured FortiWeb appliance, an Application object must be created inside the Device object and associated with a Certificate object. Application objects can be created manually or from Discovery jobs.

### Discovery

Refer to the CMSH documentation for creating and managing Onboard Discovery jobs.

The driver uses the following algorithm to decide which certificates on the FortiWeb appliance are "related" to each other, both when importing certificates and when searching Server/SNI policies to update — this lets CMSH retain historical certificate versions on the appliance without re-importing them:

1. Each local certificate's name is examined for a suffix of the form `-YYYYMMDDTHHMMSSMMMMZ` (see [Manual Provisioning](#manual)).
2. If present, the suffix is removed and the remainder is treated as the certificate's "base name"; if absent, the full name is the base name.
3. When multiple certificates share a base name, the suffixes are compared to find the most recent one — a certificate with no suffix is treated as older than any suffixed certificate with the same base name.
4. Only the most recent certificate for each base name is imported into CMSH; older certificates with that base name are ignored. Certificates with no suffix at all are imported as-is.

### Manual Provisioning

1. Right-click the Device object → **Add → Application → Adaptable**.
2. Deselect **Processing Disabled**.
3. **Associated Certificate** — optionally select an existing Certificate object to associate with this Application object.
4. **Application Name** — a name to identify the object.
5. **FortiWeb Certificate Name** — the base name FortiWeb will use for the certificate. When provisioning, CMSH appends a `-YYYYMMDDTHHMMSSMMMMZ` suffix (UTC issue date/time) to this base name, which lets CMSH track multiple certificate versions tied to the same certificate object and retain older versions on the appliance.
6. **ADOM** — if the certificate should be stored under a non-default ADOM, enter its name.
7. **CA Group** — maps the CA (root) certificate to the corresponding FortiWeb certificate group; the group is created if it doesn't already exist, and the certificate is added if not already a member.
8. **Intermediate CA Group** — the same mapping, for the intermediate certificate.
9. Click **Save**.

## Troubleshooting

Enabling **Debug Logging** on an individual Application object causes the driver to write a debug log to the `Logs` directory under the CMSH installation directory, detailing the driver's discovery/provisioning activity (certificate enumeration, suffix comparison, and server/SNI policy updates).
