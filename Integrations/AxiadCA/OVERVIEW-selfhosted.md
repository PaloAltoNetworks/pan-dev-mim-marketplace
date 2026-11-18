# Axiad CA

Organizations that use Axiad Cloud PKI for machine certificates need those certificates issued, renewed and revoked on time, under the same policy as the rest of their PKI. Doing this by hand outside your certificate management platform causes missed renewals and gaps in visibility.

The Axiad integration for Certificate Manager, Self-Hosted automates the issuance, renewal and revocation of machine certificates issued by Axiad Cloud PKI.

**Value Highlights**

- **Automate issuance, renewal and revocation** of Axiad Cloud PKI certificates.
- **Choose RA-based or CA-based provisioning** with two included drivers.
- **Authenticate securely** with a client certificate mapped to an Axiad service account.
- **Target the right CA partition** and issuer for each request with custom fields.
- **Bring Axiad certificates under central policy** and inventory.

**How it Works**

The integration provides two Adaptable CA drivers: `ID_PKI_Adaptable_ScriptRA.ps1` for RA-based provisioning, which is preferred, and `ID_PKI_Adaptable_Script.ps1` for CA-based provisioning. Certificate Manager, Self-Hosted authenticates to the Axiad ID_PKI service with a client certificate that Axiad maps to a service account for your instance. Each request supplies the issuer DN and CA partition, plus a requester email for RA-based enrollment. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Axiad Cloud PKI (ID_PKI) with a provisioned service account

**About Axiad**

[Axiad](https://www.axiad.com/) provides a platform for passwordless authentication and PKI that secures people, machines and digital interactions. Axiad Cloud offers PKI and authentication services for public sector organizations and enterprises.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
