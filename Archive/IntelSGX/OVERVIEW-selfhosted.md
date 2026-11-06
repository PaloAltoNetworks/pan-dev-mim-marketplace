# Intel SGX

This solution is an open-source implementation of the external issuer, an extension interface provided by the de-factor certificate provisioning and management component in Kubernetes, *cert-manager*. It enables a K8S cluster to employ an Intel developed certificate signing service based on Intel SGX technology as the backend Certificate Authority (CA). This private CA leverages Intel® SGX to store and use the signing key inside the Intel® SGX enclaves. By using this external issuer **[trusted-certificate-issuer](https://github.com/cert-manager/aws-privateca-issuer), you can be sure that your signing keys of all machine identities used within your K8s clusters are as safe as they could be. 

  

This implementation is provided and currently maintained by *cert-manager* as a helm chart that can be deployed in any Kubernetes cluster with a few common simple helm commands. 

  

**Applicability**

Any organization that runs workloads in a cloud native environment with Kubernetes or any flavor of K8S orchestrating clusters should have *cert-manager* deployed. It is the de-factor choice for certificates, aka machine identities, provisioning and management, accepted and current incubated within CNCF. This solution provides elevated security for internally issued machine identities should for organizations that demand higher level of security. 

  

It works when the *cert-manager* deployed meets the version requirements detailed below in the “Special notes and limitations” section.   

  

The supported flavors of K8S are as follows:

- AWS EKS
- AWS EKS Anywhere
- Azure AKS
- Azure Arc
- Google GKE
- Google Anthos

  

**Special notes and limitations**

From *cert-manager*’s point of view, despite external issuers such as Intel’s *trusted-certificate-issuer*

are not implemented in the main *cert-manager* repository, they are otherwise treated the same as any other built-in issuer. This solution is developed and tested against the open-source *cert-manager* v1.4 or higher.

  

**Additional resources**

- *cert-manager* incubated in CNCF: [https://www.cncf.io/projects/cert-manager/](https://www.cncf.io/projects/cert-manager/)
- Venafi Certificate Manager for Kubernetes, a management plane for all your *cert-manager* deployments: [https://venafi.com/tls-protect-for-kubernetes/](https://venafi.com/tls-protect-for-kubernetes/)
- Intel® Software Guard Extensions: [https://www.intel.com/content/www/us/en/architecture-and-technology/software-guard-extensions.html](https://www.intel.com/content/www/us/en/architecture-and-technology/software-guard-extensions.html)

  

**Get it to work **

*trusted-certificate-issuer* is release as a helm chart. The installation is a simple 3 step process in a K8S environment.

helm repo add intel https://intel.github.io/helm-charts
