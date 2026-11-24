#### Added
- Support for PAN-OS 12.2.

#### Fixed
- Fixed chain certificates not being trusted during the TLS handshake: importing a chain certificate did not mark it as a CA certificate, so Panorama omitted it when building the handshake chain and clients rejected the leaf certificate as untrusted. The CA flag is now set explicitly on both newly uploaded and pre-existing chain certificates.
- Fixed Commit and Push reaching zero firewalls when the configured Device Group has child groups: a push to a parent Device Group only reached firewalls directly assigned to that exact group, not firewalls assigned to groups nested underneath it (the common real-world layout). The full descendant tree is now resolved and pushed to.
- Fixed the CA-flag fix above not applying correctly to templates or certificate names containing a space or other special character, due to the certificate path being URL-encoded twice.
