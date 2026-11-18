# AWS Private CA Service

Kubernetes workloads on AWS often need private certificates from the same AWS Private CA that the rest of the organization uses. cert-manager, the standard certificate controller for Kubernetes, does not include a built-in issuer for AWS Private CA.

aws-privateca-issuer is an open-source cert-manager external issuer, maintained by the cert-manager project, that sends certificate requests from the cluster to AWS Private CA for signing. When you connect the cluster to Next-Gen Trust Security, the certificates that cert-manager issues become visible alongside the rest of your inventory. Next-Gen Trust Security can also add AWS Private CA directly as a certificate authority through its AWS Private CA connector, currently a Preview feature.

**Value Highlights**

- **Issue private certificates from AWS Private CA** through standard cert-manager Certificate resources.
- **Keep one private PKI** for Kubernetes and non-Kubernetes workloads.
- **Renew automatically** before certificates expire, through cert-manager.
- **Gain visibility** of cluster certificates by connecting the cluster to Next-Gen Trust Security.
- **Install easily** with a Helm chart or, on Amazon EKS, as an EKS add-on.

**How it Works**

The issuer runs as a controller in your cluster and provides two resources, AWSPCAIssuer and the cluster-wide AWSPCAClusterIssuer, that point to an AWS Private CA by ARN. cert-manager routes Certificate requests for those issuers to the controller, which calls AWS Private CA to sign them. The issuer is free, but it requires an AWS Private CA subscription. See the Documentation tab for setup.

**Solution Components**

- Next-Gen Trust Security
- cert-manager in a Kubernetes cluster
- aws-privateca-issuer and an AWS Private CA

**Additional Resources**

- [aws-privateca-issuer project](https://github.com/cert-manager/aws-privateca-issuer)
- [cert-manager at CNCF](https://www.cncf.io/projects/cert-manager/)

**About AWS Private CA**

[AWS Private Certificate Authority](https://aws.amazon.com/private-ca/) is a highly available managed CA service that helps organizations secure applications and devices with private certificates. You can automate CA and certificate management with API calls, the AWS CLI or AWS CloudFormation.
