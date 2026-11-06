# NGINX Ingress Controller

This solution highlights the integration of *cert-manager*, the de-facto machine identity management component in Kubernetes clusters and Kubernetes maintained and supported *ingress-nginx*, an open-source Ingress controller for Kubernetes using [NGINX](https://www.nginx.org/) as a reverse proxy and load balancer. It is also the component where SSL/TLS traffic is terminated.

This integration enables organizations running cloud native workloads and serving HTTPs traffic with *ingress-nginx* the ability to automate and secure the lifecycle of TLS certificates using policies defined by security teams and ensure the extension of security policies to Kubernetes resources.

This integration is enabled through Kubernetes resource configuration.

**Release and support versions**

There are no specific version requirements on cert-manager and ingress-nginx. As long as the version compatibility between Kubernetes and ingress-nginx is set, this integration should function as expected. Check out the “Additional Resources” section for Kubernetes and *ingress-nginx* version compatibility.

**Applicability**

*Ingress-nginx* is maintained and supported by K8s community. It is widely adopted therefore in organizations building and running applications in any cloud native environments. Any organization uses ingress-nginx as one of the ingresses in any cloud environment can and should use this integration to automate the management of machine identities in any size of Kubernetes clusters.

**Special notes and limitations**

There is a reference specification for ingress controllers which allows securing an Ingress implementation by specifying a [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that contains a TLS private key and certificate. cert-manager is aware and knows where and how to retrieve the Secret, therefore, able to operate on the TLS private key and certificate.

The configuration-only based integration with Kubernetes ingresses is not limited to ingress-nginx. cert-manager can integrate with all ingresses that implement the reference specification for ingress controller. This includes the three controllers supported and maintained by Kubernetes, ALB Ingress by AWS, GLBC by GCP, ingress-nginx and the following third-party ingresses:

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
- Pomerium Ingress Controller

This list is always growing and changing by Ingress providers, for the latest version, check out the third-party ingress controllers link in “Additional Resources”

**Additional resources **

- ingress-nginx: [https://github.com/kubernetes/ingress-nginx/blob/main/README.md#readme](https://github.com/kubernetes/ingress-nginx/blob/main/README.md#readme)
- Available third-party ingress controllers in addition to nginx ingress: [https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

**Get it to work **

There are two ways to configure the ingress controller via the ingress resource configuration.

Method 1: annotation

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

     name: #NAME_YOUR_INGRESS

     annotations:

           Kubernetes.io/ingress.class: “nginx”



Method 2: spec attribute “*ingressClassName*”

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

     name: #NAME_YOUR_INGRESS

spec:

     ingressClassName: nginx

**ABOUT Kubernetes Ingress Controller**

Kubernetes Ingress is an API object that manages external access to the services in a cluster, typically HTTP. [Ingress](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#ingress-v1-networking-k8s-io) exposes HTTP and HTTPS routes from outside the cluster to [services](https://kubernetes.io/docs/concepts/services-networking/service/) within the cluster. Traffic routing is controlled by rules defined on the Ingress resource. It may provide load balancing, SSL termination and name-based virtual hosting. You must have an [Ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers) to satisfy an Ingress. Unlike other types of controllers which run as part of the kube-controller-manager binary, Ingress controllers are not started automatically with a cluster. Use this page to choose the ingress controller implementation that best fits your cluster.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
