# Thales Data Protection on Demand

Using machine identities everywhere means deploying more TLS keys and certificates in more locations, which increases both the workload and the risk of exposing keys stored in software. Certificate Manager, Self-Hosted orchestrates connections to the machines that need certificates, while Thales Luna Cloud HSM, delivered through Data Protection on Demand, protects the cryptographic keys in hardware. As an on-demand service, Luna Cloud HSM deploys within minutes with no upfront capital investment and no specialized hardware or skills.

Together they combine automated key and certificate lifecycle management with cloud-based HSM key protection, giving you visibility, centralized control and automation over HTTPS web application keys and certificates. All keys are generated, stored and used for TLS within Thales Luna HSMs, reducing the risk of unauthorized access and loss.

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

**Solution Components**

- Certificate Manager, Self-Hosted
- Thales Data Protection on Demand (Luna Cloud HSM service)

**About Thales**

Thales provides data security, encryption and key management solutions, including Luna hardware security modules. Learn more at [cpl.thalesgroup.com](https://cpl.thalesgroup.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
