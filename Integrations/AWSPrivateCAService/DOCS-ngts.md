# AWS Private CA Service

## Prerequisites

- A Kubernetes cluster with [cert-manager](https://cert-manager.io/docs/installation/) installed.
- An AWS Private CA and an AWS identity with at least the `acm-pca:DescribeCertificateAuthority`, `acm-pca:GetCertificate` and `acm-pca:IssueCertificate` permissions on it.

## Installation

1. Add the Helm repository:

   ```bash
   helm repo add awspca https://cert-manager.github.io/aws-privateca-issuer
   ```

2. Install the issuer:

   ```bash
   helm install awspca/aws-privateca-issuer --generate-name
   ```

On Amazon EKS, you can instead install the `aws-privateca-connector-for-kubernetes` EKS add-on.

## Configuration

1. Give the issuer access to AWS with an access key secret referenced from the issuer, IAM Roles for Service Accounts, or an EC2 instance role. From v1.12.0, an issuer does not use the pod's own AWS credentials unless the chart sets `enableIssuerAmbientCredentials: true`.
2. Create an `AWSPCAIssuer` (namespaced) or `AWSPCAClusterIssuer` that references the ARN of your AWS Private CA.
3. Create cert-manager `Certificate` resources that reference the issuer.

By default, the issuer waits for a certificate request to be approved before AWS Private CA signs it. See the [aws-privateca-issuer project](https://github.com/cert-manager/aws-privateca-issuer) for examples and options.

## Usage

To view the certificates cert-manager issues, connect the cluster to Next-Gen Trust Security. See [Discover Certificates in Kubernetes Clusters](https://docs.paloaltonetworks.com/next-gen-trust-security/next-gen-trust-security/about-vaas/c-Cloud-discovery-service-sectionOverview/discover-certificates-in-kubernetes-clusters).
