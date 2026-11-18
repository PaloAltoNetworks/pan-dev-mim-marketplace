# Thales Luna HSM

As organizations add machines to support digital transformation, protecting machine identities against misuse and compromise becomes critical, and keys stored in software are a growing risk. Certificate Manager, Self-Hosted orchestrates connections to the machines that need certificates, while Thales Luna hardware security modules (HSMs) protect the cryptographic keys.

Together they combine automated key and certificate lifecycle management with Luna HSM key protection, giving you visibility, centralized control and automation over HTTPS web application keys and certificates. Luna HSMs store, protect and manage keys on-premises in FIPS 140-2 Level 3 tamper-resistant appliances, so all keys are generated, stored and used for TLS within your own infrastructure.

**Value Highlights**

- **Protect identities**: Secure the identities of devices and applications that protect critical data.
- **Enable trust in machines**: Establish trust in the machines that support critical business services.
- **Apply consistent policy**: Keep complete control with consistent security policies.
- **Automate the lifecycle**: Automate the lifecycle of keys and certificates.
- **Anchor trust in hardware**: Use a FIPS 140-2 Level 3 and Common Criteria EAL 4+ root of trust.

**How it Works**

- Certificate Manager, Self-Hosted requests that web server keys be generated in the Luna HSM, using native commands in Microsoft, Apache and Java that communicate with Thales libraries.
- After key generation, a certificate request is initiated. All Certificate Manager, Self-Hosted native policy, workflow and CA integrations are supported.
- Once the certificate is approved and received, Certificate Manager, Self-Hosted installs it automatically at the application. The process is validated and logged and can be audited at any time.
- When a certificate is renewed or a key rolled over, Certificate Manager, Self-Hosted repeats and automates the full process according to your policy.

See the Documentation tab for the integration guide.

**Solution Components**

- Certificate Manager, Self-Hosted
- Thales Luna HSM

**About Thales**

Thales provides data security, encryption and key management solutions, including Luna hardware security modules. Learn more at [cpl.thalesgroup.com](https://cpl.thalesgroup.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
