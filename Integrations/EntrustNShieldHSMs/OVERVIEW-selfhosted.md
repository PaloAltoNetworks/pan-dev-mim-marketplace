# Entrust nShield HSMs

Certificate Manager, Self-Hosted protects private keys and other sensitive material in software by default. Organizations in regulated industries often need a hardware security module to hold those keys instead. This integration lets Certificate Manager, Self-Hosted and Venafi Code Sign Manager keep their most sensitive key material in Entrust nShield HSMs while still automating the machine identity lifecycle and providing governance and visibility across the organization.

The integration is built into Certificate Manager, Self-Hosted and Venafi Code Sign Manager, so there is nothing to download. You enable it by configuring the products with the details of your nShield HSM. It is supported from Certificate Manager, Self-Hosted 21.1, and Entrust provides the specific nShield requirements.

**Value Highlights**

- **Meet regulatory requirements** by keeping private keys in FIPS-certified hardware.
- **Generate keys in the HSM** for web servers and code signing.
- **Keep automation** of certificate requests, approvals, installation and renewal while keys stay in hardware.
- **Audit every step**, because each operation is validated and logged by Certificate Manager, Self-Hosted.
- **Protect code signing keys** used by Venafi Code Sign Manager.

**How it Works**

The Entrust nShield client software is installed on each Certificate Manager, Self-Hosted server, and the platform's PKCS#11 HSM connector is pointed at the nShield HSM. Keys requested through the platform are then generated and stored in the HSM, and the platform drives certificate issuance, installation and renewal around them. See the Documentation tab for setup steps.

**Applicability**

Any organization running both Certificate Manager, Self-Hosted and Entrust nShield HSMs can connect them to reduce risk. Organizations with regulatory requirements on data security should consider deploying both and connecting them with this integration.

**Solution Components**

- Certificate Manager, Self-Hosted and Venafi Code Sign Manager
- Entrust nShield HSM and nShield client software

**About Entrust**

[Entrust](https://www.entrust.com) nShield HSMs are a family of general-purpose hardware security modules that provide a hardened, tamper-resistant environment for cryptographic processing, key generation and protection, encryption and key management. They are available in a range of FIPS 140-2 and FIPS 140-3 certified form factors.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
