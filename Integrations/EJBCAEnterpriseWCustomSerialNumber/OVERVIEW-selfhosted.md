# EJBCA Enterprise w/ Custom Serial Number

Some legacy applications only accept certificates whose serial numbers follow a specific format, which can block a move to a new certificate authority. Secur Solutions' EJBCA Enterprise Adaptable CA driver lets Certificate Manager, Self-Hosted issue EJBCA Enterprise certificates with a randomized serial number that starts with a configurable prefix.

**Value Highlights**

- **Issue legacy-compatible serial numbers**: Generate randomized serial numbers with a customized prefix.
- **Configure the prefix per policy**: Set the prefix value in Certificate Manager, Self-Hosted.
- **Switch back when you need to**: Return to the default EJBCA workflow by configuration.
- **Migrate off older CAs**: Replace CAs that legacy applications depended on without changing those applications.
- **Keep central control**: Manage EJBCA certificates with the policy and automation of Certificate Manager, Self-Hosted.

**How it Works**

The driver runs in the Adaptable CA framework of Certificate Manager, Self-Hosted and calls the EJBCA REST API to issue, renew and revoke certificates. Two extra custom fields on the policy folder turn the legacy serial number on or off and set its prefix. See the Documentation tab for setup.

**Applicability**

Organizations migrating from other CAs that have legacy applications requiring a specific serial number format can use this driver. It suits customers with on-premises CAs, especially in highly regulated, air-gapped environments.

**Solution Components**

- Certificate Manager, Self-Hosted with the Adaptable CA framework
- EJBCA Enterprise with the REST API enabled

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com) focuses on smart card issuance and digital identity in Southeast Asia, covering financial and government card issuance with major system integrator partners.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
