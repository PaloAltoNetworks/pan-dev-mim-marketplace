# Crypto4A QxEdge HSM Certificate Manager

Machine identities are only as trustworthy as the keys behind them, and organizations need to prepare their cryptography for a post-quantum world. Crypto4A's quantum-ready QxEdge hardware security module (HSM) adds hardware-backed security to Certificate Manager, Self-Hosted by providing secure generation and storage of the keys used for machine identities.

The native integration with QxEdge was built with sponsorship from the Machine Identity Management Development Fund.

**Value Highlights**

- **Use NIST-validated post-quantum cryptography**: Crypto4A's LMS implementation is [validated by NIST](https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/validation-search?searchMode=validation&productType=-1&algorithm=173%2C174%2C175&ipp=25).
- **Scale with central management**: Deployments scale from the cloud to the edge without scaling the resources needed to manage them.
- **Ensure consistent security**: Protect all cryptographic assets with an HSM.
- **Simplify operations**: Develop, deploy and manage security applications on a unified platform.
- **Reduce latency**: Run HSM and CA functions on Crypto4A's all-in-one appliance.
- **Protect the platform itself**: QxEdge supports both master encryption key storage and central key generation.

**How it Works**

Certificate Manager, Self-Hosted uses QxEdge over PKCS#11 for secure key generation when it creates machine identities, and to protect the master encryption key that secures the Certificate Manager, Self-Hosted database.

**Applicability**

Crypto4A is the first HSM vendor that NIST has certified for LMS algorithm support, with LMS being the first PQC algorithm included in the NIST [Cryptographic Algorithm Validation Program (CAVP)](https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/details?validation=36814). The NSA recommends both LMS and XMSS for code and firmware signing in [CNSA 2.0](https://media.defense.gov/2022/Sep/07/2003071834/-1/-1/0/CSA_CNSA_2.0_ALGORITHMS_.PDF) (PDF). Crypto4A's QASM Crypto Module also supports XMSS.

**Solution Components**

- Certificate Manager, Self-Hosted
- Crypto4A QxEdge HSM

**About Crypto4A**

[Crypto4A Technologies](https://crypto4a.com) builds quantum-ready cybersecurity solutions, including HSMs that deliver high-entropy key generation, secure key storage and a post-quantum ready PKI.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
