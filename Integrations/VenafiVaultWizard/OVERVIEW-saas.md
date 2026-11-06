# Venafi-Vault Wizard

The Venafi-Vault Wizard (VVW) is an open-source command-line tool that simplifies and automates the integration between Venafi and HashiCorp Vault, handling the installation, configuration, and verification of the Venafi Vault plugins so certificates issued through Vault stay compliant with Venafi’s machine identity policies.

  

**SOLUTION HIGHLIGHTS**

- **Automate the integration **install and configure the Venafi PKI secrets engine and PKI monitor plugins for HashiCorp Vault from a single tool
- **Reduce errors **replace lengthy manual setup steps with a repeatable, declarative configuration
- **Verify the setup **confirm that Vault and Venafi are correctly connected and issuing certificates as expected
- **Free and open source **community-maintained and available on GitHub

  

**SOLUTION OVERVIEW**

The Venafi-Vault Wizard reads a declarative HCL configuration file that describes your Vault and Venafi environment, then connects to Vault to install and configure the Venafi plugins (such as the Venafi PKI secrets engine and PKI monitor). It downloads and registers the plugin binaries, enables and configures the secrets engines, sets up the roles and Venafi zones, and runs verification checks against Venafi Certificate Manager, SaaS. This turns a multi-step manual process into an automated, repeatable workflow and reduces the chance of misconfiguration.

**ABOUT VENAFI-VAULT WIZARD**

The Venafi-Vault Wizard is an open-source project created by Open Credo. It works with the Venafi Vault plugins to bring Venafi’s policy enforcement and certificate visibility to HashiCorp Vault deployments, and is distributed as a community-supported tool on GitHub.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
