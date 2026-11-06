# Jamf Pro

This integration connects Zero Touch PKI (ZTPKI) with Jamf Pro to deliver certificates to Apple devices using SCEP — automating trusted machine identities for macOS, iOS, and iPadOS fleets managed through Jamf.

## How it works

ZTPKI provides a standard SCEP endpoint authenticated by a static challenge password. Jamf Pro configuration profiles distribute the trust chain and issue device and user certificates via SCEP payloads, with automatic renewal driven by the profile's redistribution settings.

## Prerequisites

- A Zero Touch PKI account (to download the root and issuing CA certificates).
- Jamf Pro administrator access on a cloud tenant with enrolled, managed devices.
- From CyberArk: a static SCEP challenge password, a SCEP-enabled ZTPKI certificate policy, the device and user SCEP service URLs, and the SHA-1 fingerprint of the ZTPKI SCEP RA certificate.

## Setup

1. **Download CA certificates** — in ZTPKI, download the root and issuing CA chain (Certificate Authorities → Download PEM Chain).
2. **Establish trust in Jamf Pro** — create two Certificate-payload configuration profiles (root CA and issuing CA) and scope them to your devices/users.
3. **Create a Device SCEP profile** — SCEP payload with the device SCEP URL, Subject `CN=$COMPUTERNAME`, SAN (DNS) `$COMPUTERNAME`, the static challenge, key size 2048 with Digital Signature + Key Encipherment, the RA certificate fingerprint, retries 3 / 5s, and Redistribute Profile at ≥10% of lifetime (required for renewal).
4. **Create a User SCEP profile** — same pattern with the user SCEP URL, Subject `CN=$USERNAME` (or `$UPN`) and SAN (RFC822) `$EMAIL`/`$UPN`.
5. **Verify** by enrolling a test device and confirming the certificate appears in the keychain with the SAN populated.

See the [Jamf Pro integration guide](https://docs.cyberark.com/mis-saas/ztpki/connectors/integrating-jamf-pro/) for full details.
