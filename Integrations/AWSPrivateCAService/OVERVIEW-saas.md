# AWS Private CA Service

This solution is an open-source implementation of the external issuer, an extension interface provided by the de-factor certificate provisioning and management component in Kubernetes, cert-manager. It enables a K8S cluster to employ AWS Private CA as the backend Certificate Authority (CA) that signs certificate requests originated from within the cluster and issues certificates. By using this external issuer [_aws-privateca-issuer_](https://github.com/cert-manager/aws-privateca-issuer), you gain one more option than what’s already been provided by cert-manager when it comes to Certificate Authority.  
This implementation is provided and currently maintained by cert-manager as a helm chart that can be deployed in any Kubernetes cluster with a few common simple helm commands. 
**Applicability**
Any organization that runs workloads in a cloud native environment with Kubernetes or any flavor of K8S orchestrating clusters should have cert-manager deployed. It is the de-factor choice for certificates, aka machine identities, provisioning and management, accepted and current incubated within CNCF. This solution should work when the cert-manager deployed meets the version requirements detailed below in the “Special notes and limitations” section.   
The supported flavors of K8S are as follows:
- AWS EKS
- AWS EKS Anywhere
- Azure AKS
- Azure Arc
- Google GKE
- Google Anthos
**Special notes and limitations**
From cert-manager’s point of view, despite external issuers such as _aws-privateca-issuer_
are not implemented in the main cert-manager repository, they are otherwise treated the same as any other built-in issuer. This solution is developed and tested against the open-source cert-manager v1.4 or higher.
Approval check before AWS Private CA signs a request is present by default. You can disable this check in certain version. Please refer to the open-source repo for details. 
While this external issuer is free, it requires proper subscription to AWS Private CA service to function as expected.
**ADDITIONAL RESOURCES**
- _cert-manager_ incubated in CNCF: https://www.cncf.io/projects/cert-manager/
- Venafi TLS Protect for Kubernetes, a management plane for all your cert-manager deployments: https://venafi.com/tls-protect-for-kubernetes/
**GETTING STARTED**
_aws-privateca-issuer_ is release as a helm chart. The installation is a simple 2 step process in a K8S environment.
**helm repo add awspca https://cert-manager.github.io/aws-privateca-issuer**
**helm install awspca/aws-privateca-issuer --generate-name**
The AWS private CA is a cloud service provided by AWS, therefore requires proper configuration per AWS so that it can be accessed and used. 
**ABOUT AWS Private CA**
AWS Private Certificate Authority (AWS Private CA) is a highly available, versatile CA that helps organizations secure their applications and devices using private certificates. It builds on a solid security foundation to protect data, identify resources, and help meet your regulatory and compliance needs. Organizations can expect avoiding outages and improving uptime by automating CA and certificate management using API calls, AWS CLI commands, or AWS CloudFormation templates.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
