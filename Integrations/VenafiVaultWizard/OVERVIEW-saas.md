# Venafi-Vault Wizard

Connecting HashiCorp Vault to Certificate Manager, SaaS by hand takes many manual steps, and a small misconfiguration can leave Vault issuing certificates outside your policy. The Venafi-Vault Wizard (VVW) is an open-source command-line tool that automates the installation, configuration and verification of the Venafi plugins for Vault, so certificates issued through Vault stay compliant with your Certificate Manager, SaaS policies.

**Value Highlights**

- **Automate the integration**: Install and configure the Venafi PKI secrets engine and PKI monitor plugins for Vault from a single tool.
- **Reduce errors**: Replace lengthy manual setup with a repeatable, declarative configuration.
- **Verify the setup**: Confirm that Vault and Certificate Manager, SaaS are connected and issuing certificates as expected.
- **Use it freely**: The tool is free, open source and community-maintained on [GitHub](https://github.com/opencredo/venafi-vault-wizard).

**How it Works**

The wizard reads a declarative HCL configuration file that describes your Vault and Certificate Manager, SaaS environment. It connects to Vault, downloads and registers the plugin binaries, enables and configures the secrets engines, sets up the roles and the zone used for issuance, and runs verification checks against Certificate Manager, SaaS.

**Solution Components**

- Certificate Manager, SaaS
- HashiCorp Vault
- Venafi PKI secrets engine and PKI monitor plugins
- Venafi-Vault Wizard CLI

**About Open Credo**

Open Credo created the Venafi-Vault Wizard and distributes it as a community-supported tool. Learn more at [opencredo.com](https://opencredo.com/).

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
