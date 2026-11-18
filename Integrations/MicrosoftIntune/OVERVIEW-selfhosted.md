# Microsoft Intune

Mobile and desktop devices managed by Microsoft Intune need certificates for secure access, and issuing, renewing and revoking them by hand creates overhead, errors and outages. Integrating Certificate Manager, Self-Hosted with Microsoft Intune automates certificate enrollment for Intune-managed devices through SCEP, so device certificates are always current and comply with corporate policy.

**Value Highlights**

- **Automate certificate management**: Issue, renew and revoke device certificates without manual work.
- **Enforce policy**: Validate every request against Intune and your certificate policy before a certificate is issued.
- **Prevent outages**: Avoid disruptions caused by expired or invalid device certificates.
- **Use your CA**: Issue Intune device certificates from the certificate authority you configure.

**How it Works**

An Intune administrator creates a SCEP certificate profile and deploys it to a group of devices. Each device requests a certificate from the Network Device Enrollment (SCEP) Web Service of Certificate Manager, Self-Hosted. Certificate Manager, Self-Hosted validates the request with Intune, requests the certificate from the configured CA, reports the result to Intune, and returns the certificate to the device. See the Documentation tab for setup.

**Applicability**

This integration suits organizations with many mobile and IoT devices managed through Microsoft Intune.

**Solution Components**

- Certificate Manager, Self-Hosted with its SCEP service
- Microsoft Intune and Microsoft Entra ID

**About Microsoft Intune**

Microsoft Intune is a cloud-based endpoint management service for mobile device management (MDM) and mobile application management (MAM). It helps organizations manage devices and apps and keep corporate data secure.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
