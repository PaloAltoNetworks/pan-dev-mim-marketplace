# Azure Application Gateway Ingress Controller

Teams running workloads on Azure Kubernetes Service (AKS) often use Azure Application Gateway as a layer 7 load balancer for HTTPS traffic, with TLS terminated at the gateway. Managing those TLS certificates by hand is slow and risks outages and policy drift.

This reference solution pairs cert-manager, the standard certificate management component for Kubernetes, with the Azure Application Gateway Ingress Controller (AGIC). cert-manager automates the TLS certificates used by AGIC, so certificates follow the policies security teams define in Next-Gen Trust Security and those policies extend to Kubernetes resources.

**Value Highlights**

- **Automate TLS certificates**: Issue and renew the certificates used for SSL offloading on Azure Application Gateway without manual steps.
- **Enforce security policy**: Keep certificates for cloud-native workloads aligned with policies defined in Next-Gen Trust Security.
- **Avoid outages**: Renew certificates before they expire so HTTPS services stay available.
- **Configure, don't code**: Enable the integration through standard Kubernetes resource configuration.
- **Reuse the same pattern**: Apply the same approach to any ingress controller that follows the Kubernetes ingress specification.

**How it Works**

The Kubernetes ingress specification secures an ingress by referencing a [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that holds the TLS private key and certificate. cert-manager knows where that Secret is and how to manage it, so it can request, store and renew the certificate that AGIC serves. You point the ingress at AGIC with an annotation or the `ingressClassName` field. There are no specific version requirements for cert-manager or AGIC. See the Documentation tab for configuration examples.

**Applicability**

Any organization running AKS clusters behind Azure Application Gateway should consider this integration. The same configuration-only approach works with other ingress controllers that implement the specification, including ingress-nginx, Kong, Istio, Traefik, Citrix, Apache APISIX, Gloo, NGINX Ingress Controller, Avi Kubernetes Operator, HAProxy and Pomerium.

**Solution Components**

- Next-Gen Trust Security
- cert-manager
- [Azure Application Gateway](https://azure.microsoft.com/en-us/products/application-gateway/) and Application Gateway Ingress Controller on AKS
