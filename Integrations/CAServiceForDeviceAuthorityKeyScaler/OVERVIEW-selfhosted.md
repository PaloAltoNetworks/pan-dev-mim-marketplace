# CA Service for Device Authority KeyScaler

IoT fleets need X.509 certificates on every device, and updating those credentials by hand at scale is costly and error prone. Weak device identities also expose private data to cloning, key theft, impersonation and spoofing.

Device Authority KeyScaler integrates with Certificate Manager, Self-Hosted to automate the X.509 certificate lifecycle for IoT devices, including secure delivery, renewal and revocation of credentials based on defined policies.

**Value Highlights**

- **Automate IoT certificate management**: Manage X.509 certificates for IoT machine identities without manual work.
- **Reduce cost and error**: Cut the labor of updating credentials at scale and minimize human error.
- **Stay compliant**: Issue and renew device certificates according to policies defined in Certificate Manager, Self-Hosted.
- **Automate password management**: Reduce password attacks and IT overhead.
- **Delegate IoT security tasks**: Hand password management, device identity checks and certificate policy enforcement to KeyScaler.

**How it Works**

KeyScaler uses Certificate Manager, Self-Hosted as the certificate authority service for its managed devices. KeyScaler handles device identity checks and secure delivery, and requests, renews and revokes device certificates through Certificate Manager, Self-Hosted using VCert (Java), so certificates follow your policies. Contact Device Authority for setup details.

**Solution Components**

- Certificate Manager, Self-Hosted
- Device Authority KeyScaler

**About Device Authority**

[Device Authority](https://deviceauthority.com/) provides KeyScaler, an identity and access management platform that automates security for IoT devices.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
