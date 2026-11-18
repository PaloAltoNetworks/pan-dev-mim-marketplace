# AWS Certificate Manager

AWS services such as Elastic Load Balancing, CloudFront and API Gateway use certificates stored in AWS Certificate Manager (ACM). When teams import or request those certificates by hand, the security team loses track of what is deployed in AWS and whether it follows enterprise policy.

Next-Gen Trust Security connects to your AWS account and provisions certificates it manages into ACM, so AWS services use certificates that are issued, tracked and renewed under your policy.

**Value Highlights**

- **Automate provisioning** of Next-Gen Trust Security certificates and private keys to ACM.
- **Gain visibility** into the certificates used by your AWS workloads.
- **Enforce consistent policy** across your cloud infrastructure.
- **Remove manual work** of exporting and importing certificates into AWS.
- **Use only enabled regions** so certificates land where your workloads run.

**How it Works**

You add AWS as a cloud provider in Next-Gen Trust Security and grant access through an IAM role that trusts Next-Gen Trust Security with an external ID. You then add an AWS cloud keystore for the regions you use. An active VSatellite provisions certificates that Next-Gen Trust Security generated or imported with their private keys into ACM, where your AWS services can use them. See the Documentation tab for setup.

**Applicability**

This integration suits organizations that build or run applications on AWS and need consistent, auditable control over the certificates those applications use.

**Solution Components**

- Next-Gen Trust Security with a VSatellite
- AWS Certificate Manager and an IAM role for Next-Gen Trust Security

**About Amazon Web Services**

[Amazon Web Services](https://aws.amazon.com/certificate-manager/) is a cloud platform with a wide range of services. AWS Certificate Manager is the AWS service for provisioning, managing and deploying TLS certificates for use with AWS services.
