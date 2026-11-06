# Entrust nShield HSMs

The integration is delivered as an in-product capability to Venafi Certificate Manager, Self-Hosted and Venafi Code Sign Manager. To enable it, you only need to perform prescribed configurations within TLS Protect and Venafi Code Sign Manager with the information related to your nShield HSM. 

  

Venafi platform provides you the control plane for managing, orchestrating, and automating the lifecycles of all machine identities across the organization. It provides an industry approval level of security for sensitive materials such as private keys, the protection is done through software. However, many organizations in certain industries are required to provide a level of security that can only be provided by hardware security modules due to many reasons regulatory requirements. This integration with Entrust nShield HSMs enables you to entrust the safeguarding of the most sensitive key materials for machine identities to HSMs while allows Certificate Manager to automate the processes involve machine identities and provide governance and visibility to them across your organization. 

  

This integration is supported since Certificate Manager, Self-Hosted v21.1. Specific requirements for an Entrust nShield HSM should be provided by Entrust. 

  

**Who will benefit**

Any organization with both Certificate Manager and Entrust nShield HSMs deployed should take advantage of this integration to connect the two systems to reduce overall cybersecurity risks the organization faces. Any organization with regulatory requirements on data security should consider putting in place these two systems and connect them with this integration.  

  

**Additional resources**

- Enable Certificate Manager to access AES keys on Entrust nShield:[https://docs.venafi.com/Docs/current/TopNav/Content/EncryptionKeys/t-encryptionKeys-nCipher-NetHSM-ConfigRequirements.php](https://docs.venafi.com/Docs/current/TopNav/Content/EncryptionKeys/t-encryptionKeys-nCipher-NetHSM-ConfigRequirements.php)
- Setting up Venafi Code Sign Manager to use HSM keys: [https://docs.venafi.com/Docs/current/TopNav/Content/_Outcomes/th-using-codesignprotect-with-hsm.php](https://docs.venafi.com/Docs/current/TopNav/Content/_Outcomes/th-using-codesignprotect-with-hsm.php)
- Recommendation for Key Management: part 2 – Best Practices for Key Management Organizations. NIST.SP.800-57pt2r1
- Integration guide: [https://www.entrust.com/resources/hsm/nshield-docs/venafi-trust-protection-platform-integration-guide](https://www.entrust.com/resources/hsm/nshield-docs/venafi-trust-protection-platform-integration-guide )

  

**Get it to work **

There are 3 high-level steps you need to take after proper deployments of both Venafi products and nShield HSM. You can find the details of the configuration in the documentation provided on this listing. 

- Install the Entrust nShield Client Software on each Certificate Manager server in the cluster
- Configure the Entrust nShield client
- Set up the PKCS11 HSM Driver in Certificate Manager

**Example usage**

- On Certificate Manager, you request that web server keys be generated in nShield HSM
- On Certificate Manager, it initiates a certificate request after the key generation
- On Certificate Manager, a user approves the request (this is optional). Certificate Manager works with configured CA to issue the certificate. Certificate Manager then automatically install the certificate the targeted application. The process is validated and logged and can be audited at any time by Certificate Manager
- Certificate Manager monitors the expiration date of a certificate and triggers the starting of the process when it’s about time to be renewed

  

**About Company**

Entrust has established secure connections across the planet and even into outer space, enabled reliable debit and credit card purchases with our card printing and issuance technologies, protected international travel with our border control solution, created secure experiences on the internet with our SSL technologies and safeguarded networks and devices with our suite of authentication products.

  

Entrust nShield HSMs is a family of general purpose hardware security modules. nShield HSMs provide a hardened, tamper-resistant environment for secure cryptographic processing, key generation and protection, encryption, key management, and more. nShield hardware security modules are available in a range of FIPS 140-2 & 140-3* certified form factors and support a variety of deployment scenarios.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
