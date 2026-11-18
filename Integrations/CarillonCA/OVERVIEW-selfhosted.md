# Carillon CA

Organizations that run a Carillon-managed PKI often handle certificate issuance, renewal and revocation in a separate console from the rest of their certificate inventory. The Carillon Adaptable CA script connects Certificate Manager, Self-Hosted to Carillon's CertServ PKI Suite, so a defined set of MPKI certificate types can be managed from the same interface as every other certificate.

**Value Highlights**

- **Manage the full lifecycle**: Issue, renew and revoke Carillon MPKI certificates from Certificate Manager, Self-Hosted.
- **Control which certificate types are used**: Limit requests to the certificate types configured for automation in the MPKI.
- **Enforce policy**: Lock the CA template and certificate type per policy so requests follow your rules.
- **Renew on schedule**: Renew certificates during the renewal window to avoid expirations.
- **Sign requests securely**: Authenticate every request to the MPKI with a client certificate issued by the MPKI.

**How it Works**

The `Carillon_CA.ps1` Adaptable CA script signs requests to the MPKI `extreq` API with a client certificate credential and submits PKCS#10 CSRs. Carillon issues the certificate and returns it to Certificate Manager, Self-Hosted. Subscribers must be sponsored in CertServ first, and requestable certificate types must use the MPKI's delegated-automation retrieval workflow. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Carillon CertServ PKI Suite (Carillon-managed PKI)
- `Carillon_CA.ps1` Adaptable CA script

**About Carillon**

Since 2000, [Carillon Information Security](https://www.carillon.ca/) has provided identity management solutions, from consulting services to validation software and managed identity services, that help companies take control of their digital credentials.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
