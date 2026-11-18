# Venafi-Vault Wizard

Connecting HashiCorp Vault to Next-Gen Trust Security by hand takes many manual steps, and a small misconfiguration can leave Vault issuing certificates outside your policy. The Venafi-Vault Wizard (VVW) is an open-source command-line tool that automates the installation, configuration and verification of the Venafi plugins for Vault, so certificates issued through Vault stay compliant with your Next-Gen Trust Security policies.

**Value Highlights**

- **Automate the integration**: Install and configure the Venafi PKI secrets engine and PKI monitor plugins for Vault from a single tool.
- **Reduce errors**: Replace lengthy manual setup with a repeatable, declarative configuration.
- **Verify the setup**: Confirm that Vault and Next-Gen Trust Security are connected and issuing certificates as expected.
- **Use it freely**: The tool is free, open source and community-maintained on [GitHub](https://github.com/opencredo/venafi-vault-wizard).

**How it Works**

The wizard reads a declarative HCL configuration file that describes your Vault and Next-Gen Trust Security environment. It connects to Vault, downloads and registers the plugin binaries, enables and configures the secrets engines, sets up the roles and the zone used for issuance, and runs verification checks against Next-Gen Trust Security.

**Solution Components**

- Next-Gen Trust Security
- HashiCorp Vault
- Venafi PKI secrets engine and PKI monitor plugins
- Venafi-Vault Wizard CLI

**About Open Credo**

Open Credo created the Venafi-Vault Wizard and distributes it as a community-supported tool. Learn more at [opencredo.com](https://opencredo.com/).
