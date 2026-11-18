# Microsoft ADCS

Many organizations use Microsoft Active Directory Certificate Services (ADCS), the CA built into Windows Server, to issue internal certificates across a wide range of use cases. Without central management, security teams can't see every certificate ADCS issues, and missed renewals cause outages. This integration lets Certificate Manager, Self-Hosted request, enroll and renew certificates from your enterprise or standalone ADCS, and keeps every issued certificate under management.

**Value Highlights**

- **Gain full visibility**: track every internally issued ADCS certificate in Certificate Manager, Self-Hosted.
- **Prevent outages**: automate enrollment and renewal of ADCS certificates and keys.
- **Detect misuse**: enforce enterprise certificate policy on certificates issued by your internal CA.
- **Start quickly**: the Microsoft CA driver ships with Certificate Manager, Self-Hosted, so there's nothing to install.
- **Cover any deployment**: works with ADCS in the data center or in the cloud.

**How it Works**

The Microsoft CA driver is included in every release of Certificate Manager, Self-Hosted. You enable it by configuring a Microsoft CA Template object that points to your ADCS server. Certificate Manager, Self-Hosted then submits new and renewal requests to ADCS and manages the issued certificates. See the Documentation tab for step-by-step configuration.

**Applicability**

The driver supports Enterprise and Standalone CAs running on Windows Server 2003 through 2012, 2016, 2019 and 2022. For the full list of supported drivers, see [Supported integrations](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/r-drivers-SysReq-supportedIntegrations.php).

**Solution Components**

- Certificate Manager, Self-Hosted
- Microsoft Active Directory Certificate Services

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
