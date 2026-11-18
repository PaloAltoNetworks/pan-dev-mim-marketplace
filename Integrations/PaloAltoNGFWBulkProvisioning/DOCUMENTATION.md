# Palo Alto NGFW Bulk Provisioning

This Adaptable Bulk Provisioning driver provisions many certificates from a source policy folder to a target Palo Alto Networks NGFW.

## Prerequisites

- Certificate Manager, Self-Hosted
- A Palo Alto Networks NGFW reachable over HTTPS from every Certificate Manager, Self-Hosted engine server
- A username and password for the target NGFW with permission to import certificates, change configuration and commit

## Installation

1. Download `Palo Alto Networks NGFW.ps1` from this listing.
2. Place it in the `AdaptableBulk` scripts folder under the Certificate Manager, Self-Hosted installation folder on every engine server, typically `C:\Program Files\Venafi\Scripts\AdaptableBulk`.

## Configuration

1. Create a Username Credential with the username and password for the target NGFW device.
2. Create a Bulk Provisioning job that uses the driver, following [Creating a Bulk Provisioning job](https://docs.venafi.com/Docs/current/TopNav/Content/Provision/t-Provision-BulkProvisioning-Job-creating.php).
3. Set the driver's optional fields:
    - **Decryption Profile Name**: the decryption profile to assign to decryption policy rules that the driver creates.
    - **Update Decryption Policy Rules**: bind each installed certificate to an existing SSL inbound inspection rule with the same name as the certificate (truncated to 31 characters).
    - **Create Decryption Policy Rules**: when no matching rule exists, create one, with address objects for the certificate's DNS names (or common name).

## Troubleshooting

- The NGFW does not accept self-signed end-entity certificates or expired certificates. The job reports these as rejected certificates.
- Other import errors are reported as failed certificates.
