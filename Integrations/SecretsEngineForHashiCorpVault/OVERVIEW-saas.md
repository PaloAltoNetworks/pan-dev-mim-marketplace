# Secrets Engine for HashiCorp Vault

This integration is delivered as a HashiCorp Vault plugin, allowing DevOps teams to acquire and consume machine identities from the Certificate Manager alongside Vault’s built-in PKI, without changing their existing workflow within Vault. 

  

Certificate Manager extends beyond Vault’s internal PKI by integrating with over 40 public CAs, enabling DevOps teams to obtain publicly trusted certificates while ensuring visibility and policy control for the InfoSec team.

  

Using Certificate Manager ensures compliance with enterprise policies and industry-standard trust protection. This integration is designed for high performance, providing the same interface as Vault’s built-in PKI secrets engine. Services can obtain certificates without the need for manual private key generation, CSR submission, or the typical certificate verification and signing process. 

  

**Applicability**

Organizations with DevOps teams using HashiCorp Vault to issue certificates for development, testing, and deployment should consider adopting this plugin.

  

**Additional Resources**

Github repo: [https://github.com/Venafi/vault-pki-backend-venafi](https://github.com/Venafi/vault-pki-backend-venafi)

  

**Get it to work **

The Venafi secrets engine for Vault is open-source software that leverages Vault’s plugin framework. To use it, download the appropriate release of the plugin and follow HashiCorp's installation instructions for plugins.

Step-by-step configuration details are available in the documentation linked to the listing.

  

**Example usage**

A video is available that covers three integrations Venafi offers with HashiCorp Vault and Terraform. The section related to this integration can be found within the video.

  

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
