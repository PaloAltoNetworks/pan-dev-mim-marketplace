# AWS Private CA w/ Key Usage & Extended Key Usage

Some certificates must carry specific key usage, extended key usage or certificate policy extensions to be accepted by the systems that rely on them. When AWS Private CA is your issuing CA, setting those extensions per request is not possible through a standard CA connection.

Secur Solutions' AWS Private CA Adaptable CA driver lets Certificate Manager, Self-Hosted issue certificates from AWS Private CA with the key usage, extended key usage and certificate policy values you choose for each certificate.

**Value Highlights**

- **Issue certificates with key usage** such as Digital Signature, Key Encipherment, Data Encipherment and Non-Repudiation.
- **Issue certificates with extended key usage** such as Server Authentication and Client Authentication.
- **Specify policy identifiers and qualifiers** in the certificate policies extension.
- **Control validity** per certificate with a validity period field.
- **Manage the full lifecycle** with issuance, retrieval and revocation through Certificate Manager, Self-Hosted.

**How it Works**

The driver (`Secur AWS CA script.ps1`) is an Adaptable CA driver for Certificate Manager, Self-Hosted. It reads custom fields on each certificate, builds the requested extensions, and calls AWS Private CA through the AWS CLI using the API passthrough end-entity template. You select the extension values in custom fields when you request the certificate. See the Documentation tab for setup.

**Applicability**

Organizations that use AWS Private CA and need key usage, extended key usage or certificate policy values in their certificates can use this driver.

**Solution Components**

- Certificate Manager, Self-Hosted
- AWS Private CA and the AWS CLI

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) is a Singapore-based provider of smart card issuance and digital identity solutions, and a long-standing Entrust distribution partner in Southeast Asia.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
