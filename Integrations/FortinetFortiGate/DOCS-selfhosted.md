# Fortinet FortiGate Adaptable Application — Installation and Usage Guide (v1.4.2)

## Introduction

The `FortiGateAdaptableApp.ps1` driver uses the Adaptable Application Framework to perform onboard discovery, enrollment, and provisioning of certificates through Certificate Manager, Self-Hosted (CMSH). Onboard discovery detects certificates used by SSL Inspection Profiles as well as the HTTPS certificate used by the management interface's web GUI, creating certificate objects and associating them with adaptable application objects in CMSH. Once discovered, CMSH can renew and provision certificates back to the FortiGate device.

## Assumptions and Constraints

### Constraints

- Developed and tested against CMSH 22.2 or higher, PowerShell 5.1, and FortiGate 6.4.14.
- Only SSL/SSH Inspection Profiles with the "Protecting SSL Server" option are supported.

### Assumptions

1. You have the FortiGate FQDN or IP address and the management interface's HTTPS port (default `443`).
2. You have a FortiGate API key whose access profile has:
   - For onboard discovery: `System:Configuration` (read), `VPN` (read), `Firewall:Other` (read)
   - For provisioning: `System:Configuration` (read/write), `VPN` (read/write), and — for SSL/SSH Inspection Profile certificate management — `Firewall:Other` (read/write)
   - `PKI Group` and `CORS Allow Origin` **disabled** on the API account

   See [Appendix: FortiGate API Permissions](#appendix-fortigate-api-permissions) for the full endpoint-level breakdown.
3. If using VDOMs, the API account's access profile is set to global scope:
   ```
   config global
      config system accprofile
         edit "<profile>"
            set scope global
   ```
4. RDP access to all CMSH servers.
5. The management interface's default self-signed HTTPS certificate has been replaced with a trusted certificate (private/public CA-signed, or a Fortinet factory certificate).

## Installation

1. Unzip the downloaded package.
2. Copy the `FortiGateAdaptableApp.ps1` script to `<CMSH installation folder>\Scripts\AdaptableApp\` on all CMSH servers.

## Configuration Steps

### Policy Folder Creation

1. Log in to the CMSH GUI as a master administrator.
2. Click **Policy Tree** in the top navigation bar.
3. Identify a policy folder location where the FortiGate objects will be nested — you may use the default `Certificates`, `Credentials`, and `Installations` folders created by the Venafi Base Configuration Utility, but note that only one adaptable application script can be configured per policy folder.

### Certificates Policy Folder Configuration

1. Locate and click the policy folder where FortiGate certificates will be managed.
2. On **Settings → Certificate**, set:
   - **Management Type**: `Provisioning`
   - **Subject DN Section**: update if not already inherited
   - **CA Template**: select the CA template to use for enrollment/renewal (optional — leave blank to let certificate owners choose)
3. Click **Save**.

### Credentials

#### FortiGate API (Username) Credential

1. Right-click the policy folder where credentials will be managed → **Add → Credential → Username Credential**.
2. Provide a name. In the Credential section, set the username to the API account created on the FortiGate device, and the password to the API token generated for that account.
3. Click **Save**.

#### Private Key Credential

FortiGate certificates are installed in PKCS12 format, so a **Password Credential** must be created and assigned to all FortiGate adaptable application objects to encrypt the private key.

1. Right-click the policy folder where credentials will be managed → **Add → Credential → Password Credential**.
2. Provide a name and the passphrase used to encrypt all private keys.
3. Click **Save**.

### Installations Policy Folder Configuration

1. Locate the policy folder where the FortiGate device will be managed.
2. On **Applications → Adaptable**, set:
   - **Port**: the management interface's HTTPS port (can also be set per application object)
   - **PowerShell Script**: `FortiGateAdaptableApp`
   - **Private Key Credential**: the password credential created above (optional — if left blank, each application object must set this field manually)
3. Click **Save**.

### Adaptable Application Object

Objects created by onboard discovery are one of:
- The management interface certificate, named with an `MGMT-` prefix followed by the FortiGate hostname (e.g. `MGMT-FortiGate01`).
- An SSL/SSH Inspection Profile certificate, prefixed by the VDOM name followed by the profile name (e.g. `VDOM1-MySslProfile1` — spaces in the profile name are replaced with underscores).

Most fields on these objects are set automatically by onboard discovery and shouldn't be changed unless you know what you're doing:

| Field | Description |
|-------|-------------|
| Port | The HTTPS port used to connect to the device's management interface. |
| Certificate Label | Set from onboard discovery; used as the certificate's name on the device. Changing it takes effect on the next provisioning run. Clearing it falls back to a Venafi-generated name — see Asset Naming below. |
| Virtual Domain | The VDOM associated with the SSL/SSH Inspection Profile. |
| SSL Inspection Profile | The profile containing the certificate used for deep inspection. |
| Certificate Range | Whether the certificate is accessible globally or scoped to a specific VDOM. |
| Configure SSL Inspection | Enables/disables provisioning of SSL/SSH Inspection Profiles. If `No`, the object is treated as the management certificate. |
| Enable Debug Logging | Writes additional logs to `<CMSH installation folder>\Venafi\Logs`. |

## Usage

### Onboard Discovery

1. Log in to the CMSH GUI as a master administrator.
2. Click **Configuration → Jobs → + Create New Job**.
3. Select **Onboard Discovery** and click **Start**.
4. In Details: enter a job name, select `Adaptable` as the **Installation Type**, click **Next**.
5. In Targets: click **Create New Devices**, keep **Create New Device Only** selected, enter the FortiGate FQDN/IP as the Device Address, select the device folder, select the API username credential created earlier, click **Save**, then **Next**.
6. In Placement: choose **In this folder** and select the certificate policy folder, click **Next**.

   > If a discovered certificate's name matches the device name and both live in the same policy folder, `" - 1"` is appended to the certificate object's name to keep names unique — this doesn't affect how CMSH manages the objects.

7. In Occurrence: select a discovery frequency and click **Create & Run**. CyberArk recommends scheduling discovery at least monthly to keep FortiGate's certificates properly tracked.
8. Once complete, review the discovered objects in the Policy Tree.

#### Renewal for Discovered Certificates

Onboard Discovery creates a certificate object from the certificate returned by the FortiGate device, plus an adaptable object below the FortiGate device, using the certificate's label as both the certificate object's name and the adaptable object's **Certificate Label** field.

> **Note:** If the certificate label is the same across multiple FortiGate devices, place the certificate objects under separate policy folders, or configure the policy folder to allow duplicate object names.

#### Asset Naming

By default, CMSH generates a unique asset name for the certificate to be provisioned, e.g. `contoso12.xyzcompany.com_24dec04_EC2B`. FortiGate's API limits certificate labels to 35 characters, so if the generated name exceeds that limit, the driver trims the Common Name portion, e.g. `contoso12.xyzcompany.c_24dec04_EC2B`.

## Appendix: FortiGate API Permissions

| Process | Resource | Type | Group | Filter | Permission |
|-----------|------------------------|-----------|-----------|-----------|-----------|
| Discovery | `/api/v2/cmdb/system/global` | cmdb | system | configuration | read |
| Discovery | `/api/v2/cmdb/system/vdom` | cmdb | system | configuration | read |
| Discovery | `/api/v2/monitor/system/available-certificates` | monitor | any | | read |
| Discovery | `/api/v2/cmdb/firewall/ssl-ssh-profile` | cmdb | firewall | other | read |
| Discovery | `/api/v2/monitor/system/certificate/download` | monitor | vpn | | read |
| Provision | `/api/v2/cmdb/system/vdom/{vdom}` | cmdb | system | | read |
| Provision | `/api/v2/cmdb/firewall/ssl-ssh-profile/{name}` | cmdb | firewall | other | read,write |
| Provision | `/api/v2/monitor/vpn-certificate/local/import` | monitor | vpn | | read,write |
| Provision | `/api/v2/monitor/system/certificate/download` | monitor | vpn | | read |
| Provision | `/api/v2/cmdb/system/global` | cmdb | system | configuration | read,write |
