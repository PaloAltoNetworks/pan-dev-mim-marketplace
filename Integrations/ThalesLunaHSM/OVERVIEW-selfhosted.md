# Thales Luna HSM

With growing numbers of machines used by organizations to support digital transformation, protecting their identities against misuse and compromise is critical. Venafi orchestrates connections to machines needing certificates, while protecting cryptographic keys with Thales Luna hardware security modules (HSMs).

  

**SOLUTION HIGHLIGHTS**

- **Protect identities **of devices and applications securing critical data
- **Enable trust **in machines that are supporting critical business
- **Apply consistent security **policies to put you in complete control
- **Automated lifecycle **of keys and certificates
- **FIPS 140-2 and Common Criteria **EAL 4+ root of trust

  

**SOLUTION OVERVIEW**

Scaling the use of HTTPS has always required trade-offs between security and efficiency. Using machine identities to enable Encryption Everywhere strategies requires that more SSL/TLS keys and certificates be deployed in more locations. Managing this not only increases resource demands on an organization, it also exponentially increases the risk of exposing keys stored in software.

  

To help reduce the risk of a data breach, meet compliance requirements, and simplify machine identity management, Venafi and Thales have combined the benefits of automated key and certificate lifecycle management with Luna HSMs' on-premises or cloud-based hardware security module (HSM) key protection to the Venafi Platform. This out-of-the-box solution delivers full visibility, centralized control and full automation over HTTPS web application keys and certificates. All keys are generated, stored, and used for SSL/TLS within the safe confines of Thales Luna HSMs to reduce the risk of unauthorized data access and loss.

  

Thales Luna HSMs store, protect and manage sensitive cryptographic keys on-premises in FIPS 140-2 Level 3, tamper resistant hardware appliances, providing high-assurance key protection within an organization’s own IT infrastructure.

  

**HOW IT WORKS**

- Venafi Platform requests that web server keys be generated in the Luna HSM, using native commands in Microsoft, Apache, and Java that communicate with Thales libraries.
- Following key generation, a certificate request is initiated. All Venafi native policy, workflow and CA integrations are supported.
- Once the certificate is approved and received by the Venafi Platform, it is installed automatically at the application. The process is validated and logged and can be audited at any time.
- When a certificate is renewed, or a key rolled over, the full process is repeated and automated by the Venafi Platform according to the organization’s policy.

  

**INTEGRATION GUIDE**

- https://thalesdocs.com/gphsm/ccc/latest/resources/venafitrustprotectionplatform_lunahsm_integrationguide_revg/index.html

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
