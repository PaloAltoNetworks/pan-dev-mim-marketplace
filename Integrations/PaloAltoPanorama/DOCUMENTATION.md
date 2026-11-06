# Palo Alto Panorama Adaptable Application — Installation and Usage Guide (v1.5.1)

## Introduction

The `PanoramaAdaptableApp` Adaptable Application provisions certificates to a Palo Alto Panorama Certificate Manager from Certificate Manager, Self-Hosted (CMSH). Depending on configuration, it can also bind the certificate to a Decryption Rule for SSL deep packet inspection.

The driver supports three levels of configuration change:
- **Staging** ("Commit to Panorama") — if the decryption policy fields are left blank, the certificate is only added to a template's certificate inventory.
- **Partial-Commit** ("Commit to Panorama") — only the changes submitted by the service account are committed to Panorama.
- **Commit-All** ("Commit and Push") — all pending changes are committed to Panorama and pushed to the specified device group.

## Assumptions and Constraints

### Constraints

- Panorama PanOS 10.2 or 11.2 (other versions may work but are unvalidated).
- Certificate Manager, Self-Hosted (CMSH) 23.3 or higher.

### Assumptions

- Templates, Device Groups, and Decryption Policies already exist in the Panorama configuration.
- You can generate a Panorama API key for an account with access to the Operational Requests, Configuration, Commit, and Import XML APIs, as well as the Decryption Rules REST API:

  ```powershell
  Invoke-WebRequest -Uri https://myPano/api?type=keygen -Method POST -Headers @{"Content-Type" = "application/x-www-form-urlencoded"} -Body "user=admin&password=mySuperP@ssw0rd"
  ```

  > **Important:** Generating a new API key invalidates all previous keys for that user. If the account's password contains special characters, URL-encode it or the request will fail.

  > **Important:** The private key passphrase used below is strictly limited to **30 characters or fewer**, containing only alphanumeric characters and `! $ * ^ ( ) - _`.

## Installation

The driver is delivered as a `.vupkg` package.

1. Copy the `.vupkg` file to `<CMSH installation folder>\Packages` on the CMSH server.
2. In the same folder, run `VenafiUpdater.exe` as an administrator.
3. Confirm the `PanoramaAdaptableApp` package is selected, then click **Install**.

   > **Note:** Installing the package stops and restarts the VED, VenafiLogServer, and w3svc services, temporarily disabling the CMSH UI.

4. To confirm installation, in `VenafiUpdater.exe` go to **View → Installed**, select the `PanoramaAdaptableApp` entry, and check its output.
5. Close `VenafiUpdater.exe` and repeat these steps on **all** CMSH servers.

## Configuration Steps

1. [Create an API Integration](https://docs.venafi.com/Docs/current/TopNav/Content/API-ApplicationIntegration/t-APIAppIntegrations-creating.php) importing these settings:

   ```json
   {
      "id": "venafips-panoramaadaptableapp",
      "name": "VenafiPS PanoramaAdaptableApp",
      "vendor": "",
      "description": "API integration to enable communication by Adaptable Application scripts with Panorama",
      "scope": "configuration:manage"
   }
   ```

   > **Note:** The driver uses a hard-coded Client ID of `venafips-panoramaadaptableapp`. If you create the API Integration through the wizard rather than importing this JSON, the `id` must still match exactly.

2. On the new API Integration's **User or Team Access** tab, select the account that will be used to generate OAuth tokens, then **Save**.
3. [Create a Username Credential](https://docs.venafi.com/Docs/current/TopNav/Content/Credentials/t-Credentials-Username-Password-creating.php) containing the API Integration account from step 2.
4. Create a second Username Credential for the Panorama API key:
   - **Username** — the account that created the Panorama API key (used during partial commits).
   - **Password** — the Panorama API key itself.
5. [Create a Password Credential](https://docs.venafi.com/Docs/current/TopNav/Content/Credentials/t-Credentials-Username-Password-creating.php) to use as the Private Key Credential. This passphrase encrypts the private key PEM, and is subject to the same 30-character / `A-Z a-z 0-9 ! $ * ^ ( ) - _` restriction noted above.
6. Identify (or create) a policy folder for the Panorama device — settings configured on this folder are inherited by every object nested beneath it.
7. If using a non-Master Admin account for the CMSH API Integration, grant it `View`, `Read`, and `Write` permissions on that policy folder (you can omit `Revoke`, which `Write` enables automatically) — the account needs to update the Panorama Job ID attributes described below.
8. [Configure the Adaptable Application](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/t-drivers-AdaptableApp-settingUp.php) fields:
   - **Application Credential** — the Username Credential for the Panorama device (step 4). May also be set as the device object's **Device Credential** instead.
   - **Secondary Credential** — the Username Credential for the CMSH API Integration (step 3).
   - **PowerShell Script** — `PanoramaAdaptableApp`.
   - **Private Key Credential** — the Password Credential from step 5.
   - **CMSH Host Address** (required) — the FQDN/IP of a CMSH server with the WebSDK module enabled.
   - **Template** (required) — the Panorama template (under the **PANORAMA** tab) where the certificate is imported; case-sensitive.
   - **Device Group** (optional) — the Panorama device group (under the **PANORAMA** tab) containing the decryption policies. Certificates cannot be stored on the built-in `Shared` group.
   - **Decryption Policy** (optional) — the Decryption Rule to bind the certificate to, configured under the Device Group's **POLICIES** tab. Optionally append the rule type with a colon, e.g. `MyDecryptPolicy:PRE` — valid types are `PRE`/`POST`; defaults to `PRE` if omitted.
   - **Panorama Version** (required) — the PanOS major.minor version in use, e.g. `10.2` or `11.1`.
   - **Remove Expired Certs** — `Yes` deletes expired certificates from Panorama entirely; `No` only unbinds them from the policy and leaves them for manual cleanup.
   - **Commit and Push** — `No` only commits to Panorama; `Yes` also pushes to the Device Group (which becomes mandatory when this is `Yes`).
9. [Create a Device object](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/t-drivers-DeviceObjects-creating.php) with the Panorama FQDN/IP in **Host/Address**.

   > **Important:** Panorama must have a valid, trusted device certificate, or the connection from CMSH will fail.

10. [Create an Adaptable Application](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/cco-drivers-AdaptableApp-Overview.php) object under the device (fields may already be populated via inherited policy settings), and associate it with the desired certificate.
11. On the certificate object, set **Management Type** to `Provisioning`.

## Use Cases

### Provision to Template Only (Staging)

Leaving the **Decryption Policy** field blank provisions the certificate to the template's inventory only, without binding it to any decryption rule.

### Provision and Assign to a Decryption Policy

Binding a certificate to a decryption rule requires **both** `Device Group` and `Decryption Policy` to be set.
- If `Decryption Policy` is set without `Device Group`, the script fails and terminates.
- Palo Alto limits a single Decryption Policy to 12 bound certificates; the script errors and terminates if that limit is reached.

### Re-Provisioning the Same Certificate (Idempotent)

Re-running provisioning for a certificate already installed and bound to a Decryption Policy is safe — the script checks whether the certificate is already a member before adding it, and leaves it in place without creating a duplicate or raising an error. The same deduplication applies to the underlying certificate/chain objects on Panorama (see [Certificate Chain Import](#certificate-chain-import-root--intermediate--leaf) below).

### Automatic Expired Certificate Cleanup

On every provisioning run, the script reviews all certificates bound to the target Decryption Policy and identifies expired ones from the expiration date encoded in the certificate name (see [Certificate Naming Convention](#certificate-naming-convention)).
- An expired certificate is always unbound from the policy.
- Whether it's also deleted from Panorama's certificate inventory depends on **Remove Expired Certs** (`No` by default — left for manual cleanup).
- Certificates whose name doesn't match the `[CommonName]_[ExpDate]_[SerialNumber]` convention (or whose date can't be parsed) are assumed to be manually managed and are never touched.

### Partial Commit vs. Commit and Push

- **Commit and Push = No** — changes are committed to Panorama using the API account.
- **Commit and Push = Yes** — changes are committed, then a Commit-All is performed, automatically pushing to the configured Device Group. `Device Group` is mandatory in this mode; omitting it terminates the script immediately.

## FAQ

**Which CMSH server do I use for "CMSH Host Address"?**
Any CMSH server, unless your deployment splits modules across servers — in that case, use one with the WebSDK module installed and enabled.

**The provisioning process failed with "The PowerShell script timed out. The configured timeout is 180 seconds." — what do I do?**
Contact Venafi/CyberArk support to increase the Adaptable Application's *Script Execution Timeout*. They'll walk through enabling attribute editing on the device's policy folder (**Support** tab → **Enable Edit**) and setting the `Adaptable App` class's `Script Execution Timeout` attribute (e.g. to `3600`, with **Lock this value** checked).

**What does "Enable Debug Logging" do?**
Writes detailed driver activity and Panorama communication to a log file under `<CMSH installation folder>\Logs`. Enable it only while troubleshooting — the log can consume significant disk space.

## What to Expect in Panorama (Auditing & Naming)

- **Audit comments:** every policy change is tagged with an audit comment of the form `CyberArkAutomation_<timestamp>`, so Panorama administrators can filter commit logs for CMSH-driven changes.

### Certificate Naming Convention

The uploaded leaf certificate is renamed to `[CommonName]_[ExpDate]_[SerialNumber]` (Common Name truncated to 17 characters) to avoid naming collisions and to let the expired-certificate cleanup logic track expiration directly from the name. Don't manually alter this naming on CMSH-managed certificates.

### Certificate Chain Import (Root → Intermediate → Leaf)

When a certificate includes a chain, each CA certificate is uploaded to Panorama as its own object rather than bundled with the leaf, so the hierarchy displays correctly in Panorama's Certificate Store.
- **Import order** is always Root → Intermediate → leaf (with its private key), determined automatically from each certificate's Issuer/Subject relationship — independent of the order certificates were supplied in.
- **CA naming:** Root/Intermediate CA certificates are named `CA-<hash>`, a stable identifier derived from the certificate's own fingerprint rather than any one leaf certificate — so multiple leaf certificates sharing the same issuing chain all resolve to the same CA object.
- **Reuse, not duplication:** before uploading a Root/Intermediate CA certificate, the script checks whether an identical object already exists in the target template and reuses it if so. Seeing "already exists; skipping" in the debug log is expected, normal behavior.

### VUPKG Package Upgrades

If this solution was installed using a `.vupkg` package, be aware that upgrading Certificate Manager, Self-Hosted (CMSH) will require the `.vupkg` package to be reinstalled after the upgrade completes. Package installations are not automatically carried forward or migrated as part of a CMSH upgrade.

A `.vupkg` package may be version-specific to the CMSH release it was built against. Contact support prior to upgrading CMSH to re-certify the package version and confirm compatibility with the target CMSH release.
