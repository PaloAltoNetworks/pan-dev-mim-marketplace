# Akeyless Vault Platform

This integration between Next-Gen Trust Security and Akeyless Vault helps organizations improve management coverage, auditability, and traceability of their machine identities.

  

**SOLUTION HIGHLIGHTS**

- Connect to the DevOps stack and simplify machine identity usage in the CI/CD pipeline using Akeyless authentication
- Protect machine identities with Akeyless’ FIPS Certified DFC Technology, which signs certificates using CA key fragments that are never combined
- Ensure audit and compliance through granular machine identities, least privileges, detailed logs, and analytics
- Use plugins, SDKs, CLI, or REST APIs to push certificates into CI/CD pipelines, configuration management, and orchestration tools
- Simplify certificate issuance authentication with external Identity Providers like OIDC, SAML, AWS IAM, Azure AD, GCP, and more

  

**SOLUTION OVERVIEW**

The shift to cloud environments and ephemeral workloads has introduced new challenges, particularly around how machines authenticate and interact with each other. With the increasing volume of certificates, credentials, and keys—also known as secrets—across IT, DevOps, and cloud environments, managing and securing these secrets becomes a critical concern. Secrets such as SSH keys for server authentication or certificates for database access are at risk of being compromised by malicious actors due to their growing number and dispersion within the organization.

  

The integration of Next-Gen Trust Security into the Akeyless Vault Platform ensures the security architecture of the hybrid environment becomes much more viable, manageable, and even possible, where it would previously have required a lot of manual work to automate certificate issuance and protect machine identities.

  

**HOW IT WORKS**

Akeyless integrates with Next-Gen Trust Security to provide the automation of certificate issuance. It can be used for Next-Gen Trust Security to ensure policy compliance and consistency with industry standards.

  

Either Akeyless or Venafi can act as the certificate issuer.

- Next-Gen Trust Security Issuer: The certificate is signed by any of the 40+ CAs that integrate with Next-Gen Trust Security. The certificate is saved in Next-Gen Trust Security and in Akeyless Vault. 
- Akeyless Issuer: The certificate is signed by a CA key from Akeyless created by the customer. In addition, the issued certificate is saved in Akeyless Vault as a secret and exported to Next-Gen Trust Security for monitoring.
