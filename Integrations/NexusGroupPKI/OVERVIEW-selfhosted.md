# Nexus Group PKI

Public key infrastructure is a cost-effective and secure way to deliver authentication, digital signatures and encryption, and at its core is the certificate authority that issues and manages certificates. Many organizations run several PKIs that grew up separately, which makes certificate demand and usage hard to see and control.

The Nexus Group PKI integration connects Certificate Manager, Self-Hosted to Nexus Certificate Manager, so certificates issued by your Nexus CA are requested, renewed and revoked under central policy, alongside certificates from your other CAs.

**Value Highlights**

- **Consolidate or migrate** older PKIs into one central point of control.
- **Automate the full lifecycle** of Nexus certificates, from request and issuance to renewal and revocation.
- **Gain visibility** into the demand for and usage of certificate services.
- **Manage multiple CAs** from a single platform.
- **Use Nexus procedures** to apply the issuance workflow configured on the Nexus side.

**How it Works**

The integration is an Adaptable CA PowerShell driver (`Nexus.ps1`) for Certificate Manager, Self-Hosted. It calls the Nexus Certificate Manager web service (CMWS) and authenticates with a PKCS#12 client certificate. The driver submits CSRs for new, renewed and replacement certificates, retrieves issued certificates and handles revocation. An optional `NEXUS Token Procedure` custom field selects the Nexus procedure to use for enrollment.

**Solution Components**

- Certificate Manager, Self-Hosted
- Nexus Certificate Manager

**About Nexus**

[Nexus](https://nexus.ingroupe.com/) provides PKI and identity solutions for issuing and managing trusted digital identities for people and things.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
