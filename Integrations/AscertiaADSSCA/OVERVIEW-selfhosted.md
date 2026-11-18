# Ascertia ADSS CA

Organizations that run Ascertia ADSS Server as their certification authority need its certificates to follow the same request, renewal and revocation processes as the rest of their PKI. Handling ADSS certificates separately creates gaps in inventory and policy.

Secur Solutions' Ascertia ADSS Adaptable CA driver connects Certificate Manager, Self-Hosted to the ADSS Certification Service, so you can issue, retrieve and revoke ADSS certificates from Certificate Manager, Self-Hosted.

**Value Highlights**

- **Issue certificates** from the Ascertia ADSS Certification Service.
- **Retrieve issued certificates** automatically into Certificate Manager, Self-Hosted.
- **Revoke certificates** through standard Certificate Manager, Self-Hosted workflows.
- **Select ADSS certification profiles** per policy folder or certificate with a custom field.
- **Bring ADSS certificates under central policy** and inventory.

**How it Works**

The driver (`Secur Ascertia CA script.ps1`) is an Adaptable CA driver for Certificate Manager, Self-Hosted. It works with the ADSS Secur Client, installed on each Certificate Manager, Self-Hosted server, to send requests to your ADSS server. Custom fields set the ADSS certification profile and certificate password for each request. See the Documentation tab for setup.

**Applicability**

Organizations that use the Ascertia ADSS Certification Service and want to issue its certificates from Certificate Manager, Self-Hosted can use this driver.

**Solution Components**

- Certificate Manager, Self-Hosted
- Ascertia ADSS Server with the Certification Service
- ADSS Secur Client from Secur Solutions

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) is a Singapore-based provider of smart card issuance and digital identity solutions, and a long-standing Entrust distribution partner in Southeast Asia.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
