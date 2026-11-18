# OpenXPKI Adaptable CA

Organizations that run the open-source OpenXPKI certificate authority often manage its certificates separately from the rest of their PKI, which makes it hard to apply consistent policy and renew on time. The OpenXPKI Adaptable CA driver connects Certificate Manager, Self-Hosted to [OpenXPKI](https://www.openxpki.org), so you can request, retrieve, renew and revoke OpenXPKI certificates under the same policy and automation as certificates from your other CAs.

**Value Highlights**

- **Issue from policy**: Enroll certificates from OpenXPKI directly through Certificate Manager, Self-Hosted.
- **Automate renewal and replacement**: Renewals and replacements are resubmitted to OpenXPKI without manual steps.
- **Revoke centrally**: Revoke OpenXPKI certificates with a reason code and comment from one place.
- **Authenticate with a client certificate**: Connect to the OpenXPKI RPC endpoint using a PKCS#12 client certificate.
- **Test before you issue**: Confirm connectivity to OpenXPKI with the CA template's test action.

**How it Works**

The driver (`OpenXPKI-AdaptableCA.ps1`) maps Adaptable CA calls to OpenXPKI RPC methods over an HTTPS endpoint. Enrollment sends the CSR to the `RequestCertificate` method and returns the issued certificate and chain, using the OpenXPKI certificate identifier as the transaction ID. Revocation calls `RevokeCertificateByIdentifier`, and the connectivity test calls the OpenXPKI health check. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- OpenXPKI with the RPC server enabled

**About OpenXPKI**

[OpenXPKI](https://www.openxpki.org) is an open-source, enterprise-grade PKI and certificate management software project.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
