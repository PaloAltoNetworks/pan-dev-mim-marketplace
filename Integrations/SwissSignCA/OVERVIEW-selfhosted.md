# SwissSign Adaptable CA Driver

Teams that use SwissSign certificates often request and renew them by hand, which makes policy hard to enforce and outages more likely. This Adaptable CA driver lets Certificate Manager, Self-Hosted request, retrieve and revoke SwissSign-issued certificates through your SwissSign Managed PKI account, so you can automate enrollment and provisioning of SwissSign certificates for secure machine-to-machine communication.

Any team that needs secure and efficient management of X.509 certificates issued by SwissSign can benefit, with streamlined machine identity management, crypto agility and reduced risk of outages caused by expired certificates.

**Value Highlights**

- **Enforce policy**: Apply organization-wide policies to certificates issued by SwissSign.
- **Automate the lifecycle**: Request, renew and revoke SwissSign certificates without manual steps.
- **Gain visibility**: See the demand, usage and workflow of SwissSign certificates in one place.
- **Use your SwissSign products**: Issue DV, OV and EV TLS certificates and S/MIME certificates available in your account.
- **Rely on partner support**: The driver is developed and supported by SwissSign AG.

**How it Works**

The driver is a PowerShell Adaptable CA script that calls the SwissSign RA API using a SwissSign service or account API key stored in a Username credential. Each CA template selects the issuing product with a profile string that names the SwissSign policy and client. You need licenses for both Certificate Manager, Self-Hosted and SwissSign Managed PKI. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- SwissSign Managed PKI
- SwissSign Adaptable CA driver (`SwissSign_Adaptable_Script.ps1`)

**About SwissSign AG**

SwissSign is a recognized trust service provider (TSP) and provider of digital certificates, electronic signature solutions and identity services. Learn more at [swisssign.com](https://www.swisssign.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
