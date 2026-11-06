# Pomerium Ingress Controller

This solution highlights the integration of *cert-manager*, the de-facto machine identity management component in Kubernetes clusters and Pomerium Ingress Controller, an ingress controller based on the context-aware proxy Pomerium. An ingress controller is the component within a Kubernetes cluster where SSL/TLS traffic is terminated.

This integration enables organizations running cloud native workloads and serving HTTPs traffic with Pomerium Ingress Controller the ability to automate and secure the lifecycle of TLS certificates using policies defined by security teams and ensure the extension of security policies to Kubernetes resources.

This integration is enabled through Kubernetes resource configuration.

**Release and support versions**

There are no specific version requirements on cert-manager and Pomerium Ingress Controller. As long as the version compatibility between Kubernetes and Pomerium Ingress Controller is set, this integration should function as expected.

**Applicability**

Pomerium Ingress Controller is provided by Pomerium. It often comes as part of the Pomerium Proxy which offers context-aware policies. It can be used in combination with an array of other Ingresses as explained in “Special notes and limitations”.

**Special notes and limitations**

There is a reference specification for ingress controllers which allows securing an Ingress implementation by specifying a [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that contains a TLS private key and certificate. cert-manager is aware and knows where and how to retrieve the Secret, therefore, able to operate on the TLS private key and certificate.

The configuration-only based integration with Kubernetes ingresses is not limited to ingress-nginx. cert-manager can integrate with all ingresses that implement the reference specification for ingress controller. This includes the three controllers supported and maintained by Kubernetes, ALB Ingress by AWS, GLBC by GCP, *ingress-nginx* and the following third-party ingresses:

- Kong Ingress Controller for Kubernetes
- AKS Application Gateway Ingress Controller
- Istio Ingress
- Traefik Kubernetes Ingress provider
- Citrix Ingress Controller
- Apache APISIX ingress controller
- Gloo
- NGINX Ingress Controller for Kubernetes
- Avi Kubernetes Operator
- HAProxy Ingress

This list is always growing and changing by Ingress providers. For the latest version, check out the third-party ingress controllers link in “Additional Resources”

**Additional resources **

- https://www.pomerium.com/docs/deploying/k8s/ingress
- Available third-party ingress controllers in addition to nginx ingress: [https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

**Get it to work **

Prerequisite: *cert-manager* and Pomerium Ingress Controller are running in a Kubernetes cluster.

The following configuration on the Ingress manifest will make *cert-manager* aware of Pomerium Ingress Controller and automate the operations of TLS certificates and keys on the ingress.

*apiVersion: networking.k8s.io/v1*

*kind: Ingress*

*metadata:*

*     name: #NAME_YOUR_INGRESS*

*spec:*

*     ingressClassName: pomerium*

**ABOUT Pomerium **

Pomerium is an identity-aware [proxy](https://www.pomerium.com/blog/proxy-vs-reverse-proxy/) that enables secure access to internal applications. Pomerium provides a standardized interface to add access control to applications regardless of whether the application itself has authorization or authentication baked-in. Pomerium gateways both internal and external requests, and can be used in situations where you'd typically reach for a VPN.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
