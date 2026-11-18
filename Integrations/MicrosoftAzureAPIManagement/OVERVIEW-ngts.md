# Microsoft Azure API Management

Microsoft Azure API Management custom domains for the gateway, developer portal and management endpoints each need a valid certificate. When a custom-domain certificate expires, API clients and portal users can no longer connect.

Next-Gen Trust Security discovers the certificates on the custom domains of an API Management service and provisions certificates to them, leaving the service's other custom domains unchanged.

**Value Highlights**

- **Cover every endpoint**: provision to Gateway, Developer Portal, Management, Source Control (SCM) and Configuration API custom domains.
- **Skip the VSatellite**: the connector runs in the cloud and signs in to Azure as a Microsoft Entra ID service principal.
- **Include Key Vault certificates**: discovery also finds certificates the service loads from Microsoft Azure Key Vault.
- **Add custom domains as needed**: if the service has no custom domain for a hostname and domain type, Next-Gen Trust Security adds one.
- **Use a built-in role**: the API Management Service Contributor role grants the read and write access that discovery and provisioning need.

**How it Works**

An Azure API Management machine authenticates with a service principal client secret and targets one API Management service by subscription, resource group and service name. Discovery connects to each custom-domain hostname on port 443 to read its certificate, and doesn't include Azure managed (free) certificates.

Provisioning uploads the certificate as a custom certificate. If a custom domain loaded its certificate from Key Vault, that domain's Key Vault reference is replaced. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Microsoft Azure API Management
- A Microsoft Entra ID service principal
