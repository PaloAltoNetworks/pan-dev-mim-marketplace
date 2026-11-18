# EJBCA Enterprise

EJBCA Enterprise is a private certificate authority (CA) that you can run in your own data center or in the cloud. It is a popular choice for infrastructure teams because of its coverage of cryptographic mechanisms, certificate templates, and DevOps and IoT enrollment protocols.

This community-supported Adaptable CA driver connects Certificate Manager, Self-Hosted to an EJBCA Enterprise instance in your environment, so EJBCA certificates get the same visibility, governance and automation as the rest of your PKI.

**Value Highlights**

- **Gain full visibility**: See the demand, usage and workflow of certificate services.
- **Automate certificate provisioning**: Keep pace with dynamic IT services.
- **Enforce policies**: Reduce risk with automated workflow, configurable approval and authorization, and detailed logging.
- **Work with multiple CAs**: Manage EJBCA alongside your other certificate authorities.
- **Consolidate or migrate**: Bring older PKIs under one central control.
- **Support the full lifecycle**: Handle request, issuance and renewal through revocation.

**How it Works**

The `EJBCA_REST.ps1` driver runs in the Adaptable CA framework of Certificate Manager, Self-Hosted and calls the EJBCA REST API. It uses the version 1 API for issuance, renewal and revocation, and the version 2 API to import existing certificates. Custom fields on the policy folder select the EJBCA CA, certificate profile and end entity profile. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted with the Adaptable CA framework
- EJBCA Enterprise with the REST API enabled

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
