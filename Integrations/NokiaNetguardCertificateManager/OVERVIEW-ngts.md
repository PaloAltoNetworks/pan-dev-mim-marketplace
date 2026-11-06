# Nokia Netguard Certificate Manager

This solution is an open-source implementation of the external issuer, an extension interface provided by the de-factor certificate provisioning and management component in Kubernetes, cert-manager. It enables a K8S cluster to employ Nokia Netguard Certificate Manager as the backend Certificate Authority (CA) that signs certificate requests originated from within the cluster and issues certificates. By using this external issuer [*ncm-issuer*](https://github.com/cert-manager/aws-privateca-issuer), you gain one more option than what’s already been provided by cert-manager when it comes to Certificate Authority. This implementation is provided and currently maintained by Nokia as a helm chart that can be deployed in any Kubernetes cluster with a few common simple helm commands. **Applicability** Any organization that runs workloads in a cloud native environment with Kubernetes or any flavor of K8S orchestrating clusters should have cert-manager deployed. It is the de-factor choice for certificates, aka machine identities, provisioning and management, accepted and current incubated within CNCF. This solution should work when the cert-manager deployed meets the version requirements detailed below in the “Special notes and limitations” section. The supported flavors of K8S are as follows: · AWS EKS · AWS EKS Anywhere · Azure AKS · Azure Arc · Google GKE · Google Anthos **Special notes and limitations** From cert-manager’s point of view, despite external issuers such as *ncm-issuer* are not implemented in the main cert-manager repository, they are otherwise treated the same as any other built-in issuer. This solution is developed and tested against the open-source cert-manager v1.0.0 or higher. It supports NCM v21 and higher. 

**ADDITIONAL RESOURCES**

 · cert-manager incubated in CNCF: https://www.cncf.io/projects/cert-manager/ · Venafi TLS Protect for Kubernetes, a management plane for all your cert-manager deployments: https://venafi.com/tls-protect-for-kubernetes/ 

**GETTING STARTED**

 *ncm-issuer* is release as a helm chart. The installation is one simple step process in a K8S environment. **$ helm install -n ncm-issuer ncm-issuer ./helm/.** The NetGuard Certificate Manager is a cloud service provided by Nokia, therefore requires proper authentication via REST API per Nokia so that it can be accessed and used. 

**ABOUT Nokia**

 **NCM** The Nokia NetGuard Certificate Manager (NCM) consists of software and highly available and secure hardware. Based on a trusted certificate authority (CA), the NCM issues and manages digital certificates in a standardized and secure way. Its primary use is for 4G and 5G mobile networks where base stations and small cells are deployed in an unsecured area, and where a secured connection to the backbone network is required.
