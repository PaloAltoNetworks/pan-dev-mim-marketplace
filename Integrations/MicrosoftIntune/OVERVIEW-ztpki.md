# Microsoft Intune

This integration connects Zero Touch PKI (ZTPKI) with Microsoft Intune to automatically request, install, and renew certificates on Intune-managed devices using SCEP — giving mobile and desktop fleets trusted machine identities without a customer-run CA.

## How it works

ZTPKI exposes a SCEP endpoint that authenticates to Intune through a Microsoft Entra ID application (app-to-app authentication). Once configured, Intune SCEP profiles deliver user and device certificates on every Intune-supported platform, and renewals flow automatically as devices check in.

## Prerequisites

- A Zero Touch PKI account.
- Microsoft Intune, with permission to upload a trusted root CA certificate and create SCEP profiles.
- Permission to register applications in Microsoft Entra ID.
- A secure secret-sharing method (for example a one-time link) to transmit credentials to CyberArk onboarding.

## Setup

1. **Register an Entra ID application** — create the app, record the Application (client) ID and Tenant ID, add a client secret (track its expiry), and grant the `scep_challenge_provider` and `Application.Read.All` API permissions.
2. **Onboard with CyberArk** — send the client ID, client secret (securely), tenant ID, and admin contact to `ztpki-onboarding@cyberark.com`. CyberArk provisions the certificate policies, an Intune Requestor service account, and returns the root CA certificate and SCEP server URL.
3. **Configure Intune** — upload the ZTPKI root CA via a trusted-root profile (once per OS), then create SCEP profiles for users and devices that point at the ZTPKI SCEP URL (`https://ztpki.<region>.venafi.com/<policy-guid>/pkiclient.exe`; omit `/pkiclient.exe` for Windows profiles).

> Rotate the Entra client secret before it expires — send a replacement to CyberArk Support at least 7 days ahead to avoid an enrollment outage.

See the [Microsoft Intune integration guide](https://docs.cyberark.com/mis-saas/ztpki/connectors/integrating-microsoft-intune/) for full details.
