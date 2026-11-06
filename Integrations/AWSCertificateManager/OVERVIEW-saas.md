# AWS Certificate Manager

Integrating Amazon Certificate Manager with Venafi streamlines the process of provisioning, tracking, and renewing TLS/SSL certificates. This strengthens your security posture by allowing you to maintain consistent, policy-driven control over your machine identities, which can help to safeguard the data flow within your cloud infrastructure.
**Applicability**
For organizations building or maintaining their applications on AWS, this solution offers effective security management by ensuring streamlined and automated TLS/SSL management. This is particularly beneficial for organizations with strict compliance requirements around their machine identities.
**Value Highlights**
- Automated lifecycle management of keys and certificates
- Robust visibility into certificate usage within AWS, enhancing your security posture
- Streamlined workflow that eliminates administrative burden
- Consistent enforcement of security policy across your cloud infrastructure
**Solution Components**
- Venafi TLS Protect Cloud or Certificate Manager, Self-Hosted
- Amazon Certificate Manager
**How it Works w/ TLS Protect Cloud (**[**Docs**](https://docs.venafi.cloud/vaas/integrations/Aws/aws-acm/)**)**
The integration is enabled within the AWS Management Console. After specifying Venafi as the Certificate Manager, Venafi policies are applied in the ACM, ensuring that all machine identities fulfill your security and policy requirements.
**How it Works w/ Certificate Manager, Self-Hosted (**[**Docs**](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/r-drivers-Amazon-AWS-AppObjectSettings.php?tocpath=TLS%20Protect%7CCertificate%20Authority%20and%20Hosting%20Platform%20Integration%20Guide%7CProtecting%20server%20platforms%20and%20keystores%7CAmazon%20Web%20Services%20\(AWS\)%E2%80%94Overview%7C_____3)**)**
Certificate Manager, Self-Hosted can submit Certificate Signing Requests (CSRs) and retrieve certificates from many Certificate Authorities (CAs) including AWS Certificate Manager. The integration simplifies certificate acquisition and administration, making it easy for certificate owners to request public or private certificates through AWS Certificate Manager while security teams get assurance that all certificates issued are compliant with enterprise security policy.
**ABOUT Amazon**
Amazon Web Services (AWS) is a leading cloud platform with a wide array of services. Amazon Certificate Manager (ACM) is a part of the AWS suite, allowing users to manage the lifecycle of their TLS/SSL certificates.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
