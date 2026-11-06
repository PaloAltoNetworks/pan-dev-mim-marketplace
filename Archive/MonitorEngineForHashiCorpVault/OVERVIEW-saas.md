# Monitor Engine for HashiCorp Vault

This integration is delivered as a Hashicorp Vault plugin to enable InfoSec team visibility and policy enforcement over DevOps teams’ activities related to acquiring and consuming machine identities through Vault’s internal PKI capability. Vault is a common and popular tool for DevOps teams. In addition to managing secrets, Vault also provides the ability to fast issue internal certificates for development and testing. However, many of such operations and activities failed to be monitored and overseen by InfoSec team, creating a huge security risk for the organization and headache for the InfoSec team in the event of a security breach due to a machine identity compromise or service outage caused by a certificate expiration. This integration enables the Vault issued certificates to be automatically forwarded to [Venafi](https://www.venafi.com/platform/trust-protection-platform) Control Plane which offers the organization and InfoSec team a single pane of glass for enterprise-wide machine identities. This further enables risk assessment, incident response, and auditing to ensure strengthened security posture for the organization. The [secrets engine](https://www.vaultproject.io/docs/secrets/pki/index.html) component was sourced from the original [HashiCorp Vault secrets engine.](https://marketplace.venafi.com/xchange/620d2d6ed419fb06a5c5bd36/solution/620fd73bd419fb06a5c5bd5a) **Applicability** Any organization that has DevOps teams using Hashicorp Vault to issue certificates for development, testing and deployment should consider and encourage DevOps teams to adopt this plugin. A centralized and single pane of glass on all machine identities across the organization can significantly reduce the security risks associated with certificate outages and misuses. 

**ADDITIONAL RESOURCES**

 Github repo: [https://github.com/Venafi/vault-pki-monitor-venafi](https://github.com/Venafi/vault-pki-monitor-venafi) 

**GETTING STARTED**

 Venafi monitor engine for Vault is an open source software leveraging Vault’s plugin framework and runs on the Vault engine. You will need to download the appropriate release of this plugin and set it up following instructions provided by Hashicorp for plugin installation. The step-by-step configuration instructions are provided in github repo documentation. **Example usage** This [video](https://marketplace.venafi.com/xchange/620d2d6ed419fb06a5c5bd36/solution/620fd73bd419fb06a5c5bd5a) provides content for 3 integrations Venafi has with Hashicorp Vault and Terraform, you need to location the portion of content related to this integration. 

**ABOUT Venafi**

 Venafi is the cybersecurity market leader in machine identity management, securing the cryptographic keys and digital certificates on which every business and government depends to deliver safe machine-to-machine communication. Organizations use Venafi key and certificate security to protect communications, commerce, critical systems and data, and mobile and user access.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
