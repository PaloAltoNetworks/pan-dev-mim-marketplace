# GlobalSign Atlas

Enterprises need trusted certificates at high volume, especially in DevOps environments, without losing control over policy or visibility into what has been issued. GlobalSign Atlas is a cloud-native certificate authority platform built for scale and automation.

This GlobalSign-supported Adaptable CA driver connects Certificate Manager, Self-Hosted to GlobalSign Atlas, so organizations can centralize certificate activity, enforce TLS policy and automate issuance, renewal and revocation of GlobalSign certificates.

**Value Highlights**

- **Automate the certificate lifecycle** to reduce manual effort and keep issuance within the defined scope.
- **Enforce enterprise policy** on every certificate requested from GlobalSign Atlas.
- **Meet high-volume demand** from DevOps environments with certificates from a trusted CA.
- **Centralize oversight** of certificate usage to prevent unexpected expirations.
- **Use the native GlobalSign Atlas API** for consistent issuance.
- **Configure approval workflows** to fit your authorization process.

**How it Works**

The driver is a PowerShell script for the Certificate Manager, Self-Hosted Adaptable CA framework. It authenticates to the GlobalSign Atlas API with an API key and secret plus a client certificate, then submits CSRs, retrieves issued certificates and their trust chain, and revokes certificates. Supported use cases include public TLS, private dedicated TLS from a GlobalSign-hosted private CA, machine and device authentication, and public S/MIME certificates. See the Documentation tab for setup, supported API operations and certificate fields.

**Solution Components**

- Certificate Manager, Self-Hosted
- GlobalSign Atlas
- GlobalSign Atlas Adaptable CA driver

**About GlobalSign**

[GlobalSign](https://www.globalsign.com/en) is a certificate authority and provider of identity and security solutions.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
