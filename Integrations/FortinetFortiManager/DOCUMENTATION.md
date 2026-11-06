# Fortinet FortiManager Adaptable Application — Installation and Usage Guide (v1.5)

## Introduction

The FortiManager Adaptable Application Driver is a Certificate Manager, Self-Hosted (CMSH) driver that enrolls and provisions a certificate for use by the FortiManager management interface — the web-based GUI administrators use to manage and maintain the FortiManager appliance/VM.

## Assumptions and Constraints

### Constraints

Development and testing has been performed against:
- Certificate Manager, Self-Hosted (CMSH) version 22.2 or higher
- PowerShell version 5.1
- FortiManager version 6.4 or 7.0

### Assumptions

1. You have the FortiManager FQDN or IP address.
2. You have a FortiManager `Super_User` account with the **JSON API Access** field set to `Read-Write`.
3. You have RDP access to all CMSH servers.

## Installation

1. Copy the `FortiManagerAdaptableApp.ps1` script to `<CMSH installation folder>\Scripts\AdaptableApp\` on all CMSH servers.

## Configuration Steps

### Policy Folder Creation

1. Log in to the CMSH GUI as a master administrator.
2. Click **Policy Tree** in the top navigation bar.
3. Identify a policy folder location where the FortiManager objects will be nested — you may use the default `Certificates`, `Credentials`, and `Installations` folders created by the Venafi Base Configuration Utility, but note that only one adaptable application script can be configured per policy folder.

### Certificates Policy Folder Configuration

1. Locate and click the policy folder where FortiManager certificates will be managed.
2. On **Settings → Certificate**, set:
   - **Management Type**: `Provisioning`
   - **Subject DN Section**: update the fields if not already inherited
   - **CA Template**: select the CA template to use for enrollment/renewal (optional — leave blank to let certificate owners choose)
3. Click **Save**.

### Credentials

#### FortiManager API Credential

1. Right-click the policy folder where credentials will be managed → **Add → Credential → Username Credential**.
2. Provide a name, then enter the username and password of the FortiManager account with `JSON API Access` configured.
3. Click **Save**.

#### Private Key Credential

A **Password Credential** is required to encrypt the private key installed alongside the certificate on the FortiManager device, and must be assigned to all FortiManager adaptable application objects.

1. Right-click the policy folder where credentials will be managed → **Add → Credential → Password Credential**.
2. Provide a name and the passphrase used to encrypt all private keys.
3. Click **Save**.

### Installations Policy Folder Configuration

1. Locate the policy folder where the FortiManager device will be managed.
2. On **Applications → Adaptable**, set:
   - **Port**: `443`
   - **PowerShell Script**: `FortiManagerAdaptableApp`
   - **Private Key Credential**: the password credential created above (optional — if left blank, each application object must set this field manually)
3. Click **Save**.

## Usage

### Onboard Discovery

Onboard Discovery performs a privileged (authenticated) scan to discover and import certificates that exist on the FortiManager device.

1. Log in to the CMSH GUI as a master administrator.
2. Click **Configuration → Jobs → + Create New Job**.
3. Select **Onboard Discovery** and click **Start**.
4. In Details: enter a job name, select `Adaptable` as the **Installation Type**, click **Next**.
5. In Targets: click **Create New Devices**, keep **Create New Device Only** selected, enter the FortiManager FQDN/IP as the Device Address, select the device folder, select the API username credential created earlier, click **Save**, then **Next**.
6. In Placement: choose **In this folder**, select the certificate policy folder where discovered certificates will be placed, click **Next**.
7. In Occurrence: select **Manually run**.

   > **Note:** Discovery should only be run once per FortiManager system to create the necessary objects in CMSH.

8. Click **Create & Run**. Once complete, review the discovered objects in the Policy Tree.

> **Note:** The certificate label cannot be `Fortinet_local` — this is FortiManager's reserved default certificate, and enrollment/provisioning will fail against it.

#### Renewal for Discovered Certificates

Onboard Discovery creates a certificate object from the `admin_server_cert` certificate returned by FortiManager, plus an adaptable object below the FortiManager device. The certificate's label is used as both the certificate object's name and the adaptable object's **Certificate Label** field.

> **Note:** If the certificate label is the same across multiple FortiManager devices, place the certificate objects under separate policy folders, or configure the policy folder to allow duplicate object names.

#### Asset Naming

By default, CMSH generates a unique asset name for the certificate to be provisioned, e.g. `contoso12.xyzcompany.com_24dec04_EC2B`. FortiManager's API limits certificate labels to 35 characters, so if the generated name exceeds that limit, the driver trims the Common Name portion, e.g. `contoso12.xyzcompany.c_24dec04_EC2B`.

#### Certificate Label

The adaptable application object's **Certificate Label** field is populated automatically during Onboard Discovery and may be changed afterward. If changed, renewing the certificate provisions a new certificate under the new label on the FortiManager device.
