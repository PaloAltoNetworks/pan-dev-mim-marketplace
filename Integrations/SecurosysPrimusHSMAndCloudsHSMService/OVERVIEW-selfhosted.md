# Securosys Primus HSM and CloudsHSM Service

Private keys for machine identities are only as safe as the place they are generated and stored. Integrating Certificate Manager, Self-Hosted with Securosys Primus HSM (on-premises) or CloudsHSM (HSM as a service) lets you generate, store and use sensitive key material on FIPS 140-2 Level 3 and CC EAL4+ certified hardware security modules, helping you meet strict regulatory requirements.

CloudsHSM delivers the same HSM protection as a cloud service, so you avoid the evaluation, setup, operation, redundancy and maintenance work of running HSM infrastructure yourself. It scales with your needs, with redundant clusters available across regions up to a world-wide cluster.

**Value Highlights**

- **Protect keys in hardware**: Generate and store keys in highest-grade secure hardware, using a physical true random number generator.
- **Scale key storage**: Use the large built-in key store, or an unlimited key store on CloudsHSM.
- **Stay available**: Fast regional access, load balancing and automatic failover come from built-in geo-redundant HA clustering.
- **Prove key provenance**: Built-in key attestation and audit features help you demonstrate how keys were created and used.
- **Manage remotely**: The Decanus terminal provides cost-efficient remote management of HSM clusters and CloudsHSM partitions (2-of-n, 2FA) without compromising security.
- **Meet compliance requirements**: HSMs are developed and manufactured in Switzerland with a trusted supply chain and certified to FIPS 140-2 Level 3 and CC EAL4+ (EN 419221-5).

**How it Works**

The Securosys Primus PKCS#11 provider is installed on each Certificate Manager, Self-Hosted server in the cluster and connects to your closest HSM cluster members. Certificate Manager, Self-Hosted then uses the HSM through PKCS#11 for key generation and protection. See the Documentation tab for setup resources.

**Solution Components**

- Certificate Manager, Self-Hosted
- Securosys Primus HSM or CloudsHSM
- Securosys Primus PKCS#11 provider

**About Securosys**

Securosys SA, headquartered in Zurich, Switzerland, has built hardware security modules since 2014 and secures the Swiss financial market in collaboration with the Swiss National Bank. Learn more at [www.securosys.com](https://www.securosys.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
