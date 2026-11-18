# Akeyless Vault Platform

Cloud environments and ephemeral workloads have multiplied the certificates, keys and credentials that machines use to authenticate to each other. When those secrets are spread across DevOps and cloud tools, security teams lose coverage, auditability and traceability.

The integration between Certificate Manager, SaaS and the Akeyless Vault Platform lets DevOps teams get certificates from Akeyless in their pipelines while every certificate stays under Certificate Manager, SaaS policy and visibility.

**Value Highlights**

- **Simplify certificate use in CI/CD pipelines** with Akeyless authentication.
- **Protect CA keys** with Akeyless Distributed Fragments Cryptography (DFC), which signs certificates with key fragments that are never combined.
- **Support audit and compliance** with granular identities, least privilege, detailed logs and analytics.
- **Deliver certificates anywhere** through Akeyless plugins, SDKs, CLI and REST APIs for pipelines, configuration management and orchestration tools.
- **Authenticate with existing identity providers** such as OIDC, SAML, AWS IAM, Azure AD and GCP.

**How it Works**

You create a Venafi dynamic secret on an Akeyless Gateway that connects to Certificate Manager, SaaS with an API key and a zone in the form `<Application>/<Issuing template>`. Either product can act as the issuer:

- **Certificate Manager, SaaS as issuer**: Certificate Manager, SaaS requests the certificate from one of its connected CAs under the zone's policy. The certificate is stored in both Certificate Manager, SaaS and Akeyless.
- **Akeyless as issuer**: a customer-created Akeyless DFC key signs the certificate. Akeyless stores it as a secret and exports it to Certificate Manager, SaaS for monitoring.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- Akeyless Vault Platform with an Akeyless Gateway

**About Akeyless**

[Akeyless](https://docs.akeyless.io/) provides a SaaS secrets management platform that secures credentials, certificates and keys across hybrid and multi-cloud environments.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
