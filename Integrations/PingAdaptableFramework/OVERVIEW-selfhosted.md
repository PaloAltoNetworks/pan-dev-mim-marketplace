# Ping Adaptable Framework

The Ping Adaptable Framework driver manages SSL and signing certificates in PingFederate from Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform) using the Adaptable Application framework. Certificates and keys are generated within Ping using its default keystore; Venafi handles the signing, so all key material stays local to Ping.

## How it works

The `ping_adaptable_driver.ps1` script creates keys and certificates inside PingFederate and sends the requests to Venafi for signing. Because Venafi does not manage the private keys, an externally generated key/certificate cannot be imported into the Ping/Venafi configuration. Typically the process begins with Onboard Discovery to inventory certificates already in use in Ping; afterward, any renewal initiated through Venafi automatically provisions the new certificate into Ping.

## Prerequisites

- A supported Certificate Manager, Self-Hosted (Trust Protection Platform) instance
- A PingFederate platform with an administrative/API user for Venafi to enumerate and manage certificate objects
- The signing CA's root certificate imported into Ping (unless the CA is already trusted in the platform's Java keystore), so Ping trusts the signing CA

## Installation and configuration

1. Deploy `ping_adaptable_driver.ps1` to the Adaptable Application scripts directory on the Venafi server.
2. Create a policy and attach the adaptable configuration/script. Set the **Scope** to either `ssl` or `signing`, and set the SSL Validity Days (the lifetime of certificates managed by the policy).
3. Create the Ping device under the policy, specifying the Hostname/Address as `https://<host>:<port>`.
4. Configure credentials with the PingFederate API user's username and password.
5. Configure and run a Discovery job to import existing Ping certificates (references only — private keys are not pulled).
6. Add the certificate and an adaptable application under the device to link the certificate to the Ping application by scope.

## Usage

After a certificate is provisioned, log in to the PingFederate administrator console to activate it for SSL or attach it to a policy/connection. See `DOCUMENTATION.md` for annotated configuration screenshots.
