# Actalis SSL

Organizations that buy SSL certificates from Actalis need those certificates to follow the same renewal, approval and validation processes as the rest of their inventory. Requesting and renewing them in a separate portal adds manual work and risks missed renewals.

This Adaptable CA driver, developed and supported by Actalis S.p.A., lets you obtain and manage Actalis SSL certificates from Certificate Manager, Self-Hosted. You get automatic renewals, configurable workflows and installation validation from Certificate Manager, Self-Hosted, together with Actalis certificates that are trusted by all major operating systems, browsers and runtime environments.

**Value Highlights**

- **Request every certificate class** that your Actalis contract covers, including DV, OV, EV and QWAC.
- **Issue every certificate type**, including single-domain, multi-domain and wildcard, with RSA or ECC keys.
- **Speed up issuance** by reusing organizations and domains that Actalis has already validated.
- **Automate renewal and revocation** through standard Certificate Manager, Self-Hosted workflows.
- **Meet EU requirements** with a CA that complies with EU data protection law and the eIDAS regulation.

**How it Works**

The driver (`Actalis_Adaptable_Script.ps1`) is an Adaptable CA driver for Certificate Manager, Self-Hosted that calls the Actalis API to submit, renew, replace, retrieve and revoke certificates. It authenticates with a Certificate Credential that Actalis provides after you sign a contract. Custom fields on each request set the certificate class, validity and reference email. See the Documentation tab for setup.

**Applicability**

Any public or private organization can use this solution. Organizations that manage many certificates, operate globally, rely on many cloud applications, or are subject to strict compliance rules benefit most.

**Special Notes and Limitations**

- You need a contract with Actalis for SSL certificates. Your contract sets your initial credit, which you can top up at any time.
- Every domain in a certificate, or a parent domain, must pass Domain Control Validation (DCV) first. Actalis can assist, or you can complete DCV yourself in the Actalis Enterprise RA portal.
- OV, EV and QWAC certificates can only be requested for organizations that Actalis has verified as affiliated with your account.

**Additional Resources**

- [Contact Actalis](https://www.actalis.com/contact-us.aspx)
- [Actalis SSL certificates](https://www.actalis.com/ssl-certificates.aspx)
- [Actalis Certification Practice Statement](https://www.actalis.it/documenti-en/cps_for_ssl_server_and_code_signing_en.aspx)

**About Actalis**

[Actalis S.p.A.](https://www.actalis.com/), an accredited Certification Authority since 2002, provides eIDAS-compliant qualified trust services and trusted SSL certificates. It has been part of the Aruba Group, an Italian provider of data center, cloud and hosting services, since 2009.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
