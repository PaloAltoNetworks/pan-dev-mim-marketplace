# AWS Certificate Manager

AWS Certificate Manager (ACM) makes it easy to obtain public and private certificates for AWS workloads, but certificates requested directly in ACM sit outside the inventory and policy your security team applies everywhere else. That makes it hard to prove that every certificate meets enterprise standards.

Certificate Manager, Self-Hosted integrates with ACM as a certificate authority. Certificate owners request public or private certificates from ACM through Certificate Manager, Self-Hosted, and security teams get assurance that every certificate is tracked and compliant with enterprise policy.

**Value Highlights**

- **Request public and private certificates** from ACM through the same process used for your other CAs.
- **Manage certificates across regions** with a single driver.
- **Enforce consistent policy** for certificates issued in your AWS accounts.
- **Gain visibility** into ACM-issued certificates alongside the rest of your inventory.
- **Reduce administrative burden** by automating certificate requests and retrieval.

**How it Works**

Certificate Manager, Self-Hosted includes an AWS Certificate Manager CA template driver. You create a CA template that connects to your AWS account, and certificate objects that use it submit requests to ACM and retrieve the issued certificates. For a public certificate you supply only the Common Name and DNS Subject Alternative Names, because ACM generates and stores the key. Private certificates require an AWS Private CA in each region where you issue them. See the Documentation tab for setup.

**Applicability**

This integration suits organizations that build or run applications on AWS and need consistent, auditable control over the certificates those applications use.

**Solution Components**

- Certificate Manager, Self-Hosted
- AWS Certificate Manager, with AWS Private CA for private certificates

**About Amazon Web Services**

[Amazon Web Services](https://aws.amazon.com/certificate-manager/) is a cloud platform with a wide range of services. AWS Certificate Manager is the AWS service for provisioning, managing and deploying TLS certificates for use with AWS services.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
