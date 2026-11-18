# HID PKIaaS

HID PKIaaS is a cloud-based PKI-as-a-Service that issues private and publicly trusted TLS certificates without you running your own CA infrastructure. This Adaptable CA driver connects Certificate Manager, Self-Hosted to HID PKIaaS, so certificates issued by HID's cloud CA are requested, renewed and revoked under your existing policies and workflows.

**Value Highlights**

- **Use a cloud-based certificate authority**: issue certificates from HID's multi-tenant PKI-as-a-Service instead of operating CA servers.
- **Automate the certificate lifecycle**: request, issue, renew, replace and revoke HID PKIaaS certificates from Certificate Manager, Self-Hosted.
- **Enforce consistent policy**: tie each CA template to an HID PKIaaS policy so only authorized certificates are issued.
- **Tailor certificates**: set validity periods and custom extensions through custom fields.
- **Reduce the risk of outages**: remove manual renewal steps that lead to expired or unmanaged certificates.

**How it Works**

The PowerShell Adaptable CA driver calls the HID PKIaaS REST API, authenticating with Hawk using your HID PKIaaS API ID and key. Each Adaptable CA template points at an HID PKIaaS policy, and Certificate Manager, Self-Hosted calls the driver to submit CSRs, retrieve issued certificates and revoke them. A companion script creates optional custom fields for validity periods and Microsoft application policy and certificate template extensions. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, Self-Hosted
- HID PKIaaS Adaptable CA driver
- HID PKIaaS

**About HID Global**

HID Global's PKIaaS is a geographically dispersed, multi-tenant PKI-as-a-Service that provides dedicated issuing CA services for private and publicly trusted TLS certificates and can host private intermediate CAs. Private keys are protected in dedicated hardware security modules, and the service offers REST API access along with standards such as SCEP and ACME.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
