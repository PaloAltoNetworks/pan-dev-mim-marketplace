# Microsoft Intune

## Prerequisites

- A Zero Touch PKI account.
- Microsoft Intune, with permission to upload a trusted root CA certificate and create SCEP profiles.
- Permission to register applications in Microsoft Entra ID.
- A secure secret-sharing method, for example a one-time link, to send credentials to CyberArk onboarding.

## Configuration

1. **Register an Entra ID application**: Create the app, record the **Application (client) ID** and **Tenant ID**, add a client secret (track its expiry), and grant the `scep_challenge_provider` and `Application.Read.All` API permissions.
2. **Onboard with CyberArk**: Send the client ID, client secret (securely), tenant ID and an admin contact to `ztpki-onboarding@cyberark.com`. CyberArk provisions the certificate policies and an Intune Requestor service account, and returns the root CA certificate and SCEP server URL.
3. **Configure Intune**: Upload the Zero Touch PKI root CA with a trusted root profile (once per OS), then create SCEP profiles for users and devices that point at the Zero Touch PKI SCEP URL, `https://ztpki.<region>.venafi.com/<policy-guid>/pkiclient.exe`. Omit `/pkiclient.exe` for Windows profiles.

## Troubleshooting

Rotate the Entra client secret before it expires. Send a replacement to CyberArk Support at least 7 days ahead to avoid an enrollment outage.

See the [Microsoft Intune integration guide](https://docs.cyberark.com/mis-saas/ztpki/connectors/integrating-microsoft-intune/) for full details.
