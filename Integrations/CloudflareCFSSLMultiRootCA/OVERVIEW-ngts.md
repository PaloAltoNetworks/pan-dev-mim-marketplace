# Cloudflare CFSSL Multirootca

This solution is an open-source implementation of the external issuer, an extension interface provided by the de-factor certificate provisioning and management component in Kubernetes, *cert-manager*. It enables a K8S cluster to employ Cloudflare’s Private CA *CFSSL* as the backend Certificate Authority (CA) to sign certificate requests using multiple signing keys. By using this external issuer [*cfssl-multirootca-issuer*](https://github.com/cert-manager/aws-privateca-issuer), you gain a specialized private CA  in addition to what’s already been provided by *cert-manager* when it comes to Certificate Authority.

**Applicability**

Any organization that runs workloads in a cloud native environment with Kubernetes or any flavor of K8S orchestrating clusters should have *cert-manager* deployed. It is the de-factor choice for certificates, aka machine identities, provisioning and management, accepted and current incubated within CNCF. This solution enables signing with multiple signing keys with Cloudflare’s private CA when the *cert-manager* deployed meets the version requirements detailed below in the “Special notes and limitations” section.

The supported flavors of K8S are as follows:

- AWS EKS
- AWS EKS Anywhere
- Azure AKS
- Azure Arc
- Google GKE
- Google Anthos

**Special notes and limitations**

From *cert-manager*’s point of view, despite external issuers such as *cfssl-multicaroot-issuer*

are not implemented in the main *cert-manager* repository, they are otherwise treated the same as any other built-in issuer.

**ADDITIONAL RESOURCES**

- *cert-manager* incubated in CNCF: [https://www.cncf.io/projects/cert-manager/](https://www.cncf.io/projects/cert-manager/)
- Venafi TLS Protect for Kubernetes, a management plane for all your cert-manager deployments: [https://venafi.com/tls-protect-for-kubernetes/](https://venafi.com/tls-protect-for-kubernetes/)
- Cloudflare’s PKI and TLS toolkit: [https://github.com/cloudflare/cfssl](https://github.com/cloudflare/cfssl)

**Get it to work **

*cfssl-multirootca-issuer* is release as a helm chart. The helm charts (cfssl-issuer and cfssl-issuer-cdrs) available at [https://helm-charts.wikimedia.org/stable](https://helm-charts.wikimedia.org/stable) (source: [cfssl-issuer](https://gerrit.wikimedia.org/r/plugins/gitiles/operations/deployment-charts/+/refs/heads/master/charts/cfssl-issuer/), [cfssl-issuer-cdrs](https://gerrit.wikimedia.org/r/plugins/gitiles/operations/deployment-charts/+/refs/heads/master/charts/cfssl-issuer-crds/)). The corresponding docker images can be found at: [https://docker-registry.wikimedia.org/cfssl-issuer/tags/](https://docker-registry.wikimedia.org/cfssl-issuer/tags/)

See the helm charts values.yaml for examples on how to create Issuer/ClusterIssuer objects.

**ABOUT Cloudflare**

Cloudflare is a global network designed to make everything you connect to the Internet secure, private, fast, and reliable. Secure your websites, APIs, and Internet applications. Protect corporate networks, employees, and devices. Write and deploy code that runs on the network edge.
