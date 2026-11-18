## Prerequisites

- WebSDK access through an OAuth token with `configuration:manage` and `certificate:manage` scope (recommended), or a legacy Username credential for a master admin or a user with manage rights on all certificates found by Onboard Discovery.
- A Notification Rule targeting this Adaptable Log for the Onboard Discovery events.

## Configuration

Define the Adaptable Log fields as follows:

- **Service Address**: static URI of the Certificate Manager, Self-Hosted WebSDK, or `https://$WebSdkFQDN$/Vedsdk`.
- **Credential**: optional *Username* credential object with the username and password used to obtain an API key from WebSDK (legacy authentication method). The API user should be a master admin or have manage rights on all certificates found by Onboard Discovery.
- **Secondary Credential**: a *Password* credential object holding a valid OAuth token for WebSDK (recommended authentication method). The token scope should be `configuration:manage` and `certificate:manage`.
- **PowerShell Script**: this script.
- **Associated Applications**: `$Config[$Event.Text2$,"Consumers", ",\"]$`
- **Certificate Object GUID**: `$GUID[$Event.Text2$]$`
- **Created By**: `$Config[$Event.Text2$,Created By]$`
- **Application Types in scope**: optional comma-separated filter of application object class names that must match before the Management Type of the associated certificate is updated.
- **Management Type to set**: one of Provisioning, Enrollment, Monitoring or Unassigned.

## Installation

1. Create a new Adaptable Log object with the script.
2. Set the parameters in the UI as required.
3. Create a new Notification Rule that targets this Adaptable Log, with a rule of *Event ID* matches *Onboard Discovery - New Certificate*.
4. To include discovered certificates that are already managed by Certificate Manager, Self-Hosted, add an *or* rule for *Event ID* matches *Onboard Discovery - Managed Certificate*.

## Internal Logic

- If the optional application class filter is set, the application class names associated with the certificate are compared with the filter. If nothing matches, the certificate is out of scope, no change is made and success is reported to the engine.
- If the filter is not set, the script always attempts to update the **Management Type** of the certificate.
- The script checks the currently inherited or effective setting for the certificate. If it already matches the desired state, no change is made.
- When the **Management Type** is changed, the script verifies the new inherited or effective setting on the certificate object.
- If the effective **Management Type** after the change matches the desired state, *Success* is reported. Otherwise *Failure* is reported to the engine.
- A failure caused by a locked policy value is prefixed with **-103:**, for example `-103: Failure! <more info>`. Other Notification Rules can act on this error code.

## Logs

- Logging is always enabled, in the `TPP_HOME\Logs` folder.
- Debug logging can be enabled with the *Enable Debug Logging* option in the Adaptable Log object's settings.
