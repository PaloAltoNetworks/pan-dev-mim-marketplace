# Crypto4A Secure PKI

Organizations preparing for post-quantum threats need a PKI whose root of trust they can rely on. Crypto4A's QxEdge platform provides a secure, quantum-ready PKI with a root of trust supplied by its built-in HSM, and this integration connects it to Certificate Manager, Self-Hosted as a certificate authority.

With certificates from Crypto4A requested and managed through Certificate Manager, Self-Hosted, security teams get visibility, policy enforcement and automation across the certificate lifecycle. The integration was built with sponsorship from the Machine Identity Management Development Fund.

**Value Highlights**

- **Gain full visibility**: See the demand, usage and workflow of certificates issued by Crypto4A.
- **Enforce certificate policy**: Reduce risk with automated workflows and detailed logging.
- **Inject workflow approvals**: Add approvals to the issuance, renewal and revocation processes where it makes sense for your business.
- **Automate provisioning**: Deliver certificates issued by Crypto4A to the systems that use them.
- **Anchor trust in hardware**: The CA's root of trust is protected by the QxEdge HSM.

**How it Works**

The downloadable Adaptable CA driver (`Crypto4A_Adaptable_CA.ps1`) connects Certificate Manager, Self-Hosted to the Crypto4A Secure PKI REST API. Through it, Certificate Manager, Self-Hosted submits CSRs for new, renewed and replacement certificates, retrieves issued certificates and their chains, and revokes certificates.

**Solution Components**

- Certificate Manager, Self-Hosted with the Adaptable CA framework
- Crypto4A QxEdge Secure PKI

**About Crypto4A**

[Crypto4A Technologies](https://crypto4a.com) builds quantum-ready cybersecurity solutions, including HSMs that deliver high-entropy key generation, secure key storage and a post-quantum ready PKI.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
