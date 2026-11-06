# Zero Touch PKI Adaptable Driver

This is the Adaptable CA driver for CyberArk Zero Touch PKI (ZTPKI). It lets Certificate
Manager, Self-Hosted issue, renew, and import certificates from ZTPKI.

The driver files can also be obtained from the
[CyberArk Software Download Portal](https://community.cyberark.com/marketplace/s/#software).

## Files

| File | Purpose |
|---|---|
| `ztPKI_Driver.ps1` | Main Adaptable CA driver used for certificate issuance and renewal. |
| `ztPKI_Create_Custom_Fields.ps1` | Helper script that creates the custom fields the driver relies on. |
| `ztPKI_ImportOnly.ps1` | Import-only driver used by an Adaptable Certificate Import job (see below). |

## Installation

1. Download the files using the Download button.
2. Copy `ztPKI_Driver.ps1` (and `ztPKI_ImportOnly.ps1` if importing) to
   `<Venafi Home>\Scripts\Adaptable CA` on each engine.
3. Run `ztPKI_Create_Custom_Fields.ps1` to create the required custom fields.
4. Set up an API Key in the ZTPKI Console for the ztPKI account and record the policy IDs the
   account/API key can access.
5. Create the API Key credential within the Venafi Platform.

---

# ztPKI ImportOnly

## Overview

This script (`ztPKI_ImportOnly.ps1`) is for importing certificates from ZTPKI into the Venafi
Platform (TPP).

1. **Import Only** — the script will only perform imports. The main ztPKI driver should be used
   for certificate issuance.
2. **Filtering updates** — can filter by policy, and can include expired and include revoked if
   this is set on the Certificate import job.
3. **New Global Variable functions** — `LastProcessedID`, `IgnoreLastJobImport`, `StartAtOrder`,
   `Timeout`, `MaxLimit`, `CertLimit`. These target the methods used to import certificates
   (details in the Script Configuration Guide below).

## High Level Script Guide

Refer to `ztPKI_Import_Guide.docx` (included in the download) for more detailed implementation
steps.

1. Copy the script to `<Venafi Home>\Scripts\Adaptable CA`.
2. Set up an API Key within the ZTPKI Console for the ztPKI account.
3. Record the policy IDs that the account/API key has access to.
4. Create an API key credential within TPP.
5. Create and run an Adaptable Certificate Import Job with the API Key credential and Policy ID.

## Script Configuration Guide

The script will work with default settings. However, there are additional features that can be
leveraged. The following variables are defined at the beginning of the script.

**Note**: Editing these settings should only be done if the desired functionality is required.
It is assumed that any script editing is done by someone familiar with PowerShell scripts. Each
edit needs to be saved to every TPP server running the adaptable import job.

#### LastProcessedID functionality

The script by default leverages common `LastProcessedID` functionality to only process certs
since the last run. The 1.06 version of the script also leverages the `updated_since` filter on
the ZTPKI API with `LastProcessedID` information to only query certs that are newer or have had
updates (like revocation). See the `IgnoreLastJobImport` setting to change this behavior.

#### IgnoreLastJobImport

Can be set to `$true` to ignore the last job import and always process all certificates.

**Default:** `$false` (will always read in the last processed ID from TPP)

**Why this may be needed:** If the `LastProcessedID` was for some reason not set correctly, or if
you need to make sure it's not skipping past results, this tells the adaptable to pull in all
cert details. Can also be useful for certs that may now be revoked (if revocation checking is not
otherwise functional in TPP).

#### StartAtOrder

Can be set to start at a specific ID. Requires `IgnoreLastJobImport` to also be set to `$true`.

**Default:** not set

**Why this may be needed:** If there are a large number of certs to import and some certs were
not found, this may be useful to tell the script where to start.

#### Timeout

Can be set to stop before a certain number of seconds to prevent TPP from calling it a runaway.
If the number of seconds the script has run has surpassed the global timeout, the script will
return incomplete and pass a parameter to TPP to run again in an hour. If `IgnoreLastJobImport`
is set to `$false`, the job will start processing at the last order when it picks back up.

**Default:** 3500 (58 minutes)

**Why this may be needed:** This ensures TPP won't call it a runaway job or time it out if it
doesn't complete within an hour.

#### MaxLimit

Global variable to limit how many certs to pull results on. Note: this is an API requirement for
ztPKI but can be set very high. If set too low, the adaptable may never pull in the entire list
of results.

**Default:** 100000

**Why this may be needed:** The Limit setting is a ZTPKI requirement and can be changed if there
are other issues with cert results calls.

#### CertLimit

Global variable to limit how many detailed certificate result calls can be made. This can be
paired with timeout values and/or set to a specific number to throttle how many cert details are
requested per run, as well as preventing timeouts on large imports. When the cert limit is
reached, the script will return incomplete and pass a parameter to TPP to run again in an hour.
If `IgnoreLastProcessedID` is set to `$false`, the job will start processing at the last order
when it picks back up.

**Default:** 30000

**Why this may be needed:** The `CertLimit` setting ensures that the number of detailed cert
requests (which include the X.509 data) are set to appropriate limits if there are a number of
certs to import. It also makes calls to the ZTPKI REST API more efficient.

## Debug Logging

Using the script with debug logging now adds a lot more detail to the log file.
