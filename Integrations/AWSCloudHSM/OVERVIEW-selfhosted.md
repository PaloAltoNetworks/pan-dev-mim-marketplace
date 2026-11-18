# AWS CloudHSM

Certificate Manager, Self-Hosted protects private keys and other sensitive material in software by default. Many organizations, especially in regulated industries, must keep their most sensitive keys in a hardware security module (HSM) instead.

This built-in integration lets Certificate Manager, Self-Hosted store keys in AWS CloudHSM. Code signing keys and the encryption of the Certificate Manager, Self-Hosted database are protected by FIPS-validated HSMs, while Certificate Manager, Self-Hosted keeps automating, governing and reporting on the machine identities that use them. CloudHSM delivers this as an on-demand cloud service with no upfront hardware investment.

**Value Highlights**

- **Protect sensitive keys in hardware** with FIPS-validated HSMs that you control.
- **Meet regulatory and compliance requirements** that call for HSM-backed key storage.
- **Secure code signing** by keeping Code Sign Manager signing keys in CloudHSM.
- **Encrypt the Certificate Manager, Self-Hosted database** with keys held in the HSM.
- **Avoid upfront capital costs** by using a fully managed, on-demand HSM service.

**How it Works**

Certificate Manager, Self-Hosted connects to AWS CloudHSM through the CloudHSM PKCS#11 client installed on its servers. You configure the client with your HSM cluster ID for failover, then configure Certificate Manager, Self-Hosted to use the HSM for database encryption or Code Sign Manager keys. Connecting to an HSM requires Advanced Key Protect. The integration is supported from version 21.1. See the Documentation tab for setup.

**Applicability**

Organizations that must meet data security regulations, or that want hardware protection for code signing keys, should consider connecting Certificate Manager, Self-Hosted to AWS CloudHSM.

**Solution Components**

- Certificate Manager, Self-Hosted with Advanced Key Protect
- AWS CloudHSM cluster and the CloudHSM PKCS#11 client

**Additional Resources**

- [AWS CloudHSM third-party integrations](https://docs.aws.amazon.com/cloudhsm/latest/userguide/other-integrations.html)
- NIST SP 800-57 Part 2 Rev. 1, Recommendation for Key Management: Best Practices for Key Management Organizations

**About AWS CloudHSM**

[AWS CloudHSM](https://aws.amazon.com/cloudhsm/) is a fully managed HSM service that lets you generate and use your own encryption keys on AWS. It supports industry-standard APIs such as PKCS#11, JCE and Microsoft CNG, and automates hardware provisioning, patching, high availability and backups.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
