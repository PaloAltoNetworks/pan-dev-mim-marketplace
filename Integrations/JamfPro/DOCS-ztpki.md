# Jamf Pro

## Prerequisites

- A Zero Touch PKI account, to download the root and issuing CA certificates.
- Jamf Pro administrator access on a cloud tenant with enrolled, managed devices.
- From CyberArk: a static SCEP challenge password, a SCEP-enabled Zero Touch PKI certificate policy, the device and user SCEP service URLs, and the SHA-1 fingerprint of the Zero Touch PKI SCEP RA certificate.

## Configuration

1. **Download CA certificates**: In Zero Touch PKI, download the root and issuing CA chain (**Certificate Authorities** > **Download PEM Chain**).
2. **Establish trust in Jamf Pro**: Create two configuration profiles with a Certificate payload, one for the root CA and one for the issuing CA, and scope them to your devices and users.
3. **Create a device SCEP profile**: Add a SCEP payload with the device SCEP URL, Subject `CN=$COMPUTERNAME`, SAN (DNS) `$COMPUTERNAME`, the static challenge, key size 2048 with **Digital Signature** and **Key Encipherment**, the RA certificate fingerprint, 3 retries with a 5 second delay, and **Redistribute Profile** at 10% or more of the certificate lifetime. The redistribution setting is required for renewal.
4. **Create a user SCEP profile**: Follow the same pattern with the user SCEP URL, Subject `CN=$USERNAME` (or `$UPN`) and SAN (RFC822) `$EMAIL` or `$UPN`.

## Usage

Enroll a test device and confirm that the certificate appears in the keychain with the SAN populated.

See the [Jamf Pro integration guide](https://docs.cyberark.com/mis-saas/ztpki/connectors/integrating-jamf-pro/) for full details.
