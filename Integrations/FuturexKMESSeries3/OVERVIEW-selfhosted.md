# Futurex KMES Series 3

Hardware security modules (HSMs) are one of the strongest ways to protect the certificate issuance process. Certificate Manager, Self-Hosted integrates with the Futurex KMES Series 3 so that certificates are issued by a CA whose keys live in a FIPS 140-2 Level 3 validated HSM, guarding against key compromise, fraud and insider attacks.

The KMES Series 3 also lets administrators manage multiple certificate issuance policies from a single device and integrates with the Futurex Hardened Enterprise Security Platform as part of an organization's core cryptographic infrastructure.

**Value Highlights**

- **Protect CA keys** with FIPS 140-2 Level 3 physical security against key compromise, fraud and insider attacks.
- **Reduce management overhead** by managing multiple certificate issuance policies from a single device.
- **Control issuance** with granular policies for certificate attributes and issuance structure.
- **Define certificate types** with custom X.509 extension profiles.
- **Enforce approvals** with KMES signing approval groups and optional separation of request and approval roles.

**How it Works**

A PowerShell driver for the Certificate Manager, Self-Hosted Adaptable CA framework connects to the KMES Series 3 Host API over mutually authenticated TLS. Certificate requests from a Certificate Manager, Self-Hosted policy are uploaded to a KMES issuance policy, approved according to its signing workflow, and the signed certificate is returned. A companion script adds optional custom fields for the approval group and X.509 extension profile. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Futurex KMES Series 3 (application version 6.3.1.3 or later, Registration Authority license)

**About Futurex**

[Futurex](https://www.futurex.com) provides hardened, enterprise-class data security solutions, including HSMs and key management servers.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
