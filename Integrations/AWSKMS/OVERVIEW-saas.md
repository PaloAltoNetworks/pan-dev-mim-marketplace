# AWS KMS

Teams running Kubernetes on AWS often want a private CA for in-cluster certificates whose signing key never leaves AWS-managed hardware. cert-manager, the standard certificate controller for Kubernetes, does not include a built-in issuer for AWS Key Management Service (KMS).

kms-issuer is an open-source cert-manager external issuer, maintained by Skyscanner, that uses an asymmetric AWS KMS key to sign certificate requests from inside the cluster. When you connect the cluster to Certificate Manager, SaaS, the certificates that cert-manager issues become visible alongside the rest of your inventory.

**Value Highlights**

- **Keep the CA signing key in AWS KMS** so it is never exported to the cluster.
- **Issue certificates natively in Kubernetes** through standard cert-manager Certificate resources.
- **Provision KMS keys from Kubernetes** with the issuer's KMSKey custom resource.
- **Gain visibility** of cluster certificates by connecting the cluster to Certificate Manager, SaaS.
- **Use open-source tooling** distributed as a Helm chart.

**How it Works**

kms-issuer runs as a controller in your cluster. You create a KMSIssuer that references a KMS key with SIGN_VERIFY usage, and the controller generates a root certificate signed by that key. cert-manager then routes Certificate requests for that issuer to the controller, which signs them with KMS. Connecting the cluster to Certificate Manager, SaaS lets you view and monitor the resulting certificates. See the Documentation tab for installation.

**Solution Components**

- Certificate Manager, SaaS
- cert-manager v1.17 or later in a Kubernetes cluster
- kms-issuer and an asymmetric AWS KMS key

**About Skyscanner**

[Skyscanner](https://www.skyscanner.net/) is a global travel search company. It maintains kms-issuer as an [open-source project](https://github.com/Skyscanner/kms-issuer).

**About AWS KMS**

[AWS Key Management Service](https://aws.amazon.com/kms/) is a managed service for creating and controlling cryptographic keys. It uses hardware security modules to protect keys and integrates with other AWS services.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
