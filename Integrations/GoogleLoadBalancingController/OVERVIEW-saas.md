# Google Load Balancing Controller

Teams that serve HTTPS traffic from Google Kubernetes Engine (GKE) through Google Cloud Load Balancing need the TLS certificates on their Ingress resources to stay valid and to follow the security team's policy. This reference solution combines cert-manager, the standard certificate controller for Kubernetes, with the GKE Ingress controller (GLBC), so certificates for load-balanced workloads are issued and renewed automatically under policies defined in Certificate Manager, SaaS.

**Value Highlights**

- **Automate renewal**: cert-manager renews Ingress certificates before they expire, so load balancers never serve an expired certificate.
- **Extend policy to Kubernetes**: Certificates are issued under the policies your security team defines in Certificate Manager, SaaS.
- **Configure, don't code**: The integration uses standard Kubernetes resource configuration, with no custom software.
- **Reuse the pattern**: The same approach works with any Ingress controller that follows the Kubernetes Ingress TLS specification.

**How it Works**

The GKE Ingress controller configures a Google Cloud Application Load Balancer from an Ingress resource and terminates TLS with the certificate and key stored in the Kubernetes Secret named by the Ingress. cert-manager, configured with an issuer that enrolls from Certificate Manager, SaaS, requests the certificate, writes it to that Secret, and renews it on schedule. See the Documentation tab for the Ingress configuration.

**Applicability**

This solution suits any organization that runs GKE clusters and uses Google Cloud Load Balancing as a layer 7 load balancer for HTTPS applications. GLBC is part of the Kubernetes project. There are no specific version requirements for cert-manager or GLBC, but GLBC versions map to Kubernetes versions (see [ingress-gce on GitHub](https://github.com/kubernetes/ingress-gce)).

**Solution Components**

- Certificate Manager, SaaS
- cert-manager
- GKE with the GKE Ingress controller and Google Cloud Load Balancing

**Additional Resources**

- [Configure Ingress for external load balancing](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/load-balance-ingress)
- [Kubernetes Ingress controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

**About Google Cloud Load Balancing**

Cloud Load Balancing is a fully distributed, software-defined managed service built on the same frontend-serving infrastructure that powers Google. Traffic enters through global load-balancing locations and stays on Google's private network backbone for most of its journey.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
