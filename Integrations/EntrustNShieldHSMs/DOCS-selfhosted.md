# Entrust nShield HSMs

## Prerequisites

- Certificate Manager, Self-Hosted 21.1 or later (and Venafi Code Sign Manager, if you use it for code signing).
- A deployed Entrust nShield HSM. Specific HSM requirements are provided by Entrust.

## Installation

1. Install the Entrust nShield client software on each Certificate Manager, Self-Hosted server in the cluster.
2. Configure the Entrust nShield client.

## Configuration

1. Set up the PKCS#11 HSM connector in Certificate Manager, Self-Hosted. See [Creating an HSM connector](https://docs.venafi.com/Docs/current/TopNav/Content/Configuration/PlatformConfig/t-connector-HSM-create.php).
2. To use HSM keys for code signing, see [Setting up Code Sign Manager to use HSM keys](https://docs.venafi.com/Docs/current/TopNav/Content/_Outcomes/th-using-codesignprotect-with-hsm.php).

Entrust publishes a detailed [integration guide](https://www.entrust.com/resources/hsm/nshield-docs/venafi-trust-protection-platform-integration-guide). For key management practices, see NIST SP 800-57 Part 2 Rev. 1, Recommendation for Key Management: Best Practices for Key Management Organizations.

## Usage

1. In Certificate Manager, Self-Hosted, request that web server keys be generated in the nShield HSM.
2. Certificate Manager, Self-Hosted starts a certificate request after the key is generated.
3. Optionally, a user approves the request. Certificate Manager, Self-Hosted works with the configured CA to issue the certificate and installs it on the target application. Each step is validated and logged for audit.
4. Certificate Manager, Self-Hosted monitors the certificate's expiry date and starts renewal when it is due.
