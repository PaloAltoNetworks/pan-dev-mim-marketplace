# ACME Adaptable CA Driver — Installation and Usage Guide (v2.2)

## Introduction

The ACME Adaptable CA Driver enables Certificate Manager, Self-Hosted (CMSH) to connect to Certificate Authorities that use the ACMEv2 protocol, such as Let's Encrypt. Certificates can be requested, renewed, and revoked through CMSH as with any other CA.

## Assumptions and Constraints

- Requires the third-party [Posh-ACME](https://poshac.me) PowerShell module, version 4.5.0 or later.
- Requires OpenSSL installed with the `openssl` binary on the system `PATH` — any recent version is fine.
- Installation and configuration require an administrative PowerShell prompt; familiarity with PowerShell is strongly recommended.

## DNS Requirements

This driver only implements ACME domain validation via DNS, using Posh-ACME's DNS plugins — each plugin needs its own credentials to update records on your DNS server/provider. Unless you're certain your CA will never require domain validation, you need a dynamic DNS update mechanism in place; the driver detects a validation requirement with no configured update mechanism and raises a specific error.

Allowing the driver to create/modify the `_acme-challenge.<domain>` TXT record it needs may, depending on your DNS infrastructure, also allow modification of the base domain or zone. If that's a concern, the driver supports CNAME delegation: configure an optional `CNamePrefix`/`CNameSuffix` (see [Configuration](#configuration) below) so `_acme-challenge.<domain>` points to a different name in a zone your DNS administrators are willing to delegate — and ensure the corresponding CNAME records exist before using it.

## ACME Accounts and External Account Binding

The driver supports External Account Binding (EAB), which lets a CA associate an otherwise-pseudonymous ACME identity with an existing CA account — important for private CAs that need to issue from the correct hierarchy. To use EAB, the ACME account must be created manually (see [Registering an ACME Account](#registering-an-acme-account)). CyberArk recommends creating the account manually even without EAB, unless you're only running a single CMSH server — the driver hasn't been tested with independent ACME accounts per CMSH server, and that configuration isn't supported.

## Multiple CMSH Servers

Posh-ACME stores account and certificate state on disk alongside the driver's own CA configuration. The driver and its configuration files must be installed on every CMSH server whose web UI (vedadmin/Aperture) may be used, since the UI calls the driver whenever **Test Settings**/**Validate** is clicked.

To use the driver across multiple CMSH servers, the CA configuration directory must exist at the same path on each server, and these Posh-ACME account files (under `<config location>\Posh-ACME\<CA hostname>\`) must be present on each: `current-account.json`, `dir.json`, and `<account ID>\acct.json`.

Alternatively, restrict the driver to a single CMSH server via **Settings → Policy → Processing Engines** on the policy folder containing the CA object (you may need to restart the `Venafi Trust Protection Platform` service after changing this). Running on one instance simplifies troubleshooting, but that instance's failure blocks certificate requests until it's restored.

## Installation

1. Install Posh-ACME on every CMSH server that will run the web interface or process certificate requests (requires internet access):

   ```powershell
   Install-Module -Name Posh-ACME -Scope AllUsers
   ```

2. Install OpenSSL if not already present. The "light" installer at [slproweb.com](https://slproweb.com/products/Win32OpenSSL.html) is sufficient.
3. Copy `AcmeAdaptableCA.ps1` to `<CMSH installation folder>\Scripts\AdaptableCA\` on every CMSH server that will use the driver.

## Configuration

Each CA the driver connects to needs its own configuration directory holding driver state and a `ca.cfg` file. CyberArk recommends creating these under `C:\Program Files\Venafi\Utilities` (e.g. copy the `ACME-Sample-CA` directory to `ACME-LE-CA`). If multiple CMSH servers will share this CA, the directory must be on storage accessible to all of them.

`ca.cfg` is a JSON file with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `Proxy` | String, optional | Proxy address, if required. For an authenticated proxy, create a Username Credential and set it as the CA Template's **Secondary Credential**. |
| `ProxyBypass` | String array, optional | Regular expressions for addresses to bypass the proxy, e.g. `["dns.company.com", ".*\\.internal\\.com"]`. |
| `AutoCreateAccount` | Boolean, default `false` | Automatically registers an ACME account if one doesn't exist. Only set this to `true` when **not** using External Account Binding — EAB accounts must be created manually. |
| `Contact` | String, optional | Contact email address used when registering an account. |
| `SkipCertificateCheck` | Boolean, default `false` | Skips TLS certificate validation for the CA host. Only needed if the CA's own TLS certificate isn't publicly trusted. |
| `Plugin` | String, required | The Posh-ACME DNS plugin to use. Set to `Manual` if your CA never issues DNS challenges for your requests. |
| `PluginParams` | Hashtable, required if `Plugin` is set | Parameters for the chosen DNS plugin (see the [Posh-ACME plugin docs](https://poshac.me/docs/latest/Plugins/)). To avoid plaintext secrets in `ca.cfg`, you can use `pscredential`, `securestringpassword`, `username`, or `password` as a parameter value to pull that value from the CA Template's Username Credential instead. |
| `WaitTime` | Integer, required if `Plugin` is set | Seconds to wait after instructing the DNS plugin to create validation records, before asking the CA to validate. CyberArk suggests starting at 30. |
| `CNamePrefix` / `CNameSuffix` | String, optional | Prepended/appended to the domain name used for the `_acme-challenge` DNS record, enabling CNAME delegation (see [DNS Requirements](#dns-requirements)). |

## Registering an ACME Account

Unless `AutoCreateAccount` is `true`, register the account manually from an administrative PowerShell prompt on one CMSH instance:

```powershell
$env:POSHACME_HOME = "<CA Data Path>\Posh-ACME\"
mkdir $env:POSHACME_HOME
Import-Module Posh-ACME -Force
Set-PAServer <CA_URL>
New-PAAccount -AcceptTOS -Contact <Contact> -ExtAcctKID <Key ID> -ExtAcctHMACKey <HMAC key>
```

- `<CA Data Path>` — the CA configuration directory, e.g. `C:\Program Files\Venafi\Utilities\ACME-LE-CA`.
- `<CA URL>` — the CA's ACME directory URL, e.g. `https://acme-v02.api.letsencrypt.org/directory`.
- `<Key ID>` / `<HMAC key>` — your EAB credentials (omit `-ExtAcctKID`/`-ExtAcctHMACKey` if not using EAB; some CAs use different names for these, e.g. Telia calls the Key ID a "Customer ID").

Then copy the CA configuration directory (now containing `ca.cfg` and the `Posh-ACME` subdirectory) to every other CMSH instance that will use this CA.

## Create a Username Credential

The Adaptable CA interface requires a Username Credential even though ACME itself doesn't use one (the client's identity comes from the ACME account/EAB, not this credential) — unless you're pulling plugin secrets from it via `pscredential`/`username`/`password`/`securestringpassword` in `PluginParams`, create a dummy Username Credential with a username/password that aren't valid in your environment, and note in its description that it's a placeholder required by the driver.

## Creating the CA Template Object

1. In vedadmin, right-click an appropriate Policy Tree location → **Add → CA Template → Adaptable**.
2. Set:
   - **Username Credential** — the credential created above.
   - **Secondary Credential** — a Username Credential for proxy authentication, if `Proxy` is set in `ca.cfg`.
   - **Service Address** — the ACME CA's server URL, e.g. `https://acme-v02.api.letsencrypt.org/directory`.
   - **Profile String** — the CA configuration directory path, e.g. `C:\Program Files\Venafi\Utilities\ACME-LE-CA`.
   - **Allow Reissuance** — checked.
   - **Subject Alt Name Enabled** — checked.
   - **Enable Debug Logging** — as needed.
3. Click **Validate** before saving — this checks the page and `ca.cfg` settings, and creates the ACME account if `AutoCreateAccount` is `true`.
4. Once **Validate** succeeds, save the object. It's now available for selection on certificate objects.

### Troubleshooting a Failed Validate

If **Validate** fails with a message that isn't enough to diagnose the issue, a debug log is needed — but debug logging isn't available until after the object is saved. As a one-time workaround: set **Service Address** to `AllowMeToSave`, click **Validate** (it will succeed), check **Enable Debug Logging**, and click **Save**. Then set **Service Address** back to the correct value and click **Validate** again — a log will now be written to the `Logs` folder in the CMSH installation directory.
