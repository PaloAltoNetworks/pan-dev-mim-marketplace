# Fortanix DSM

Private keys behind X.509 certificates must be protected, and for many enterprises that means encrypting them or keeping them in a hardware security module before they are stored anywhere in the infrastructure. Managing that protection across a complex, multi-vendor environment is hard to do by hand. Certificate Manager, Self-Hosted and Fortanix Data Security Manager (DSM) combine certificate lifecycle automation with key protection in the cloud, on premises or as a hybrid deployment.

Certificate Manager, Self-Hosted acts as the automation and orchestration engine for the certificate lifecycle, and Fortanix DSM secures the private keys associated with those certificates.

**Value Highlights**

- **Protect private keys** with FIPS 140-2 certified HSMs, delivered on premises or as a cloud service.
- **Automate multi-vendor certificates** across many devices from Certificate Manager, Self-Hosted.
- **Gain visibility and control** across all certificates and keys.
- **Enforce policy** and support compliance across the network.
- **Control access** with comprehensive role-based access control in Fortanix DSM.
- **Rely on a resilient architecture** with a distributed design for high availability.

**How it Works**

Certificate Manager, Self-Hosted connects to Fortanix DSM as a PKCS#11 HSM. The integration supports two models: certificate management with private keys encrypted by Fortanix DSM and stored in Certificate Manager, Self-Hosted, or certificate management with private keys generated and kept in Fortanix DSM. Fortanix provides the integration documentation through [Fortanix Support](https://support.fortanix.com/).

**Solution Components**

- Certificate Manager, Self-Hosted
- Fortanix Data Security Manager (SaaS or on premises)

**About Fortanix**

[Fortanix](https://www.fortanix.com/) takes a data-first approach to security, helping businesses protect data on premises, in the cloud and everywhere in between. Enterprises in privacy-sensitive industries such as healthcare, financial services, government and retail use Fortanix for data security, privacy and compliance.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
