# Nokia NetGuard Certificate Manager

Kubernetes workloads need certificates from a trusted CA, and cert-manager is the standard way to request and renew them inside a cluster. ncm-issuer is an open-source external issuer for cert-manager that lets a Kubernetes cluster use Nokia NetGuard Certificate Manager (NCM) as its certificate authority, so applications get CA-signed certificates that stay valid and up to date. Next-Gen Trust Security provides a management plane for cert-manager deployments, giving security teams visibility into the certificates issued across clusters.

**Value Highlights**

- **Use your NCM PKI in Kubernetes**: Sign certificate requests from inside the cluster with Nokia NetGuard Certificate Manager.
- **Automate renewal**: cert-manager renews and re-enrolls certificates before they expire.
- **Treat NCM like a built-in issuer**: cert-manager handles ncm-issuer the same way as its native issuers.
- **Run on major Kubernetes platforms**: Supported on AWS EKS, AWS EKS Anywhere, Azure AKS, Azure Arc, Google GKE and Google Anthos.
- **Deploy with Helm**: ncm-issuer ships as a Helm chart maintained by Nokia.

**How it Works**

ncm-issuer is a Kubernetes controller that adds Issuer and ClusterIssuer resources for NCM. When cert-manager creates a certificate request that references one of these issuers, ncm-issuer forwards it to the NCM REST API and returns the signed certificate. See the Documentation tab for installation.

**Applicability**

ncm-issuer is developed and tested against open-source cert-manager v1.0.0 or later and supports NCM v21 and later.

**Solution Components**

- Next-Gen Trust Security
- cert-manager with [ncm-issuer](https://github.com/nokia-steward/ncm-issuer)
- Nokia NetGuard Certificate Manager

**About Nokia**

The [Nokia](https://www.nokia.com/) NetGuard Certificate Manager combines software with highly available, secure hardware to issue and manage digital certificates from a trusted CA. Its primary use is in 4G and 5G mobile networks, where base stations and small cells deployed in unsecured areas need a secure connection to the backbone network.
