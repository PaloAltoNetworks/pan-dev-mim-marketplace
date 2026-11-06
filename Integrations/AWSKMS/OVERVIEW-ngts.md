# AWS KMS

This solution is an open-source implementation of the external issuer, an extension interface provided by the de-factor certificate provisioning and management component in Kubernetes, cert-manager. It enables a K8s cluster to employ AWS KMS as the backend Certificate Authority (CA) that signs certificate requests originated from within the cluster and issues certificates. By using this external issuer _kms-issuer_, you gain one more option than what’s already been provided by cert-manager when it comes to Certificate Authority.  
This implementation is provided and currently maintained by Skyscanner as a helm chart that can be deployed in any Kubernetes cluster with a few common simple helm commands. 
**Applicability**
Any organization that runs workloads in a cloud native environment with Kubernetes or any flavor of K8s orchestrating clusters should have cert-manager deployed. It is the de-factor choice for certificates, aka machine identities, provisioning and management, accepted and current incubated within CNCF. This solution should work when the cert-manager deployed meets the version requirements detailed below in the “Special notes and limitations” section.   
The supported flavors of K8S are as follows:
- AWS EKS
- AWS EKS Anywhere
- Azure AKS
- Azure Arc
- Google GKE
- Google Anthos
**Special notes and limitations**
From cert-manager’s point of view, despite external issuers such as kms-issuer are not implemented in the main cert-manager repository, they are otherwise treated the same as any other built-in issuer. This solution is developed and tested against the open-source _cert-manager_ v0.11.0 or higher.
Approval check before AWS KMS signs a request is present by default. You can disable this check in certain version. Please refer to the open-source repo for details. 
**ADDITIONAL RESOURCES**
- _cert-manager_ incubated in CNCF: https://www.cncf.io/projects/cert-manager/
- Venafi TLS Protect for Kubernetes, a management plane for all your cert-manager deployments: https://venafi.com/tls-protect-for-kubernetes/
**GETTING STARTED**

_kms-issuer_ is release as a helm chart. The installation is a simple 3-step process with 3 command lines in a K8s environment:

```bash
helm repo add kms-issuer 'https://skyscanner.github.io/kms-issuer'
helm repo update
helm upgrade --install kms-issuer kms-issuer/kms-issuer --namespace kms-issuer-system --create-namespace
```

**ABOUT Skyscanner**
Skyscanner is a global travel search engine that helps users compare millions of flights, hotels, and car rental options to find the best deals. Founded in 2003, the company is headquartered in Edinburgh, Scotland, and has offices in various locations around the world. Skyscanner provides its services to over 100 million people each month and is available in over 30 languages. The company has partnerships with various airlines, hotel chains, and rental car companies, and its website and mobile app offer users a simple and convenient way to plan and book their travel itineraries.
**ABOUT AWS KMS**
AWS KMS (Key Management Service) is a fully managed service that enables users to create and control encryption keys for their data stored on AWS. With KMS, users can centrally manage their encryption keys, create and rotate keys, and define access policies for the keys. KMS is integrated with other AWS services such as S3, EBS, and RDS, making it easy to encrypt and decrypt data in these services. KMS uses hardware security modules (HSMs) to protect the security of the keys and is designed to meet various compliance standards, including HIPAA, PCI DSS, and SOC.
