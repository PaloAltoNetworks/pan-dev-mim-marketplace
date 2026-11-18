# DigiCert CertCentral

DigiCert CertCentral issues and manages publicly trusted certificates. Certificate Manager, Self-Hosted includes a native DigiCert CertCentral CA driver, so teams can enroll and renew DigiCert certificates under central policy without custom scripting.

**Value Highlights**

- **Use a native CA driver**: DigiCert CertCentral is a built-in CA template type in Certificate Manager, Self-Hosted.
- **Automate enrollment and renewal**: Certificate Manager, Self-Hosted initiates and auto-enrolls new and renewing certificate and key generation requests.
- **Cover TLS and email**: The driver supports DigiCert TLS/SSL and Secure Email (S/MIME) certificate products through the same CA template and workflow.
- **Enforce policy**: Apply your policy folder rules and workflow to every DigiCert certificate.
- **Get support from one vendor**: The driver is built and supported by Venafi.

**How it Works**

An administrator creates a DigiCert CA template object in Certificate Manager, Self-Hosted with the CertCentral account credentials and certificate product settings. Policy folders reference the CA template, and Certificate Manager, Self-Hosted submits requests to CertCentral and retrieves the issued certificates for provisioning. See the Documentation tab for the integration guide.

**Solution Components**

- Certificate Manager, Self-Hosted
- DigiCert CertCentral account

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
