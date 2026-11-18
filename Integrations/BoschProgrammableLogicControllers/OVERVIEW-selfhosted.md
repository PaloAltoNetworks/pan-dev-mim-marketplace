# Bosch Programmable Logic Controllers

Industry 4.0 and IoT connect more machinery and devices to the network, which grows the machine identity attack surface. As smart machines become self-organizing, they need trustworthy identities to authenticate with each other.

This solution embeds machine identity management into Bosch programmable logic controllers (PLCs) using Certificate Manager, Self-Hosted. It equips machine networks with secure identities based on industrial standards, giving organizations full control of PLC identities and simpler identity and access controls.

**Value Highlights**

- **Enforce consistent policy**: Apply the same certificate policies to every PLC machine identity.
- **Automate provisioning**: Provision machine identities to PLCs without manual steps.
- **Gain full visibility**: Build a complete inventory of PLC machine identities.
- **Customize the integration**: Adapt the open source project, built on VCert, to your environment.

**How it Works**

The application uses VCert, the open source Venafi client library, to request certificates from Certificate Manager, Self-Hosted and provision them to Bosch PLCs. Certificate Manager, Self-Hosted enforces policy and keeps an inventory of the PLC identities it issues. Contact accessec for setup details.

**Solution Components**

- Certificate Manager, Self-Hosted
- Bosch programmable logic controllers
- VCert (Python)

**About accessec**

[accessec](https://accessec.com/) is an IT security consultancy for CSOs, CISOs and CTOs, including some of the largest automotive and OT brands. accessec built this application through the Machine Identity Management Development Fund.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
