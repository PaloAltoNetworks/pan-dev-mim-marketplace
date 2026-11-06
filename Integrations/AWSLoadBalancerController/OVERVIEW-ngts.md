# AWS Load Balancer Controller

This *reference solution* highlights the integration of *cert-manager*, the de-facto machine identity management component in Kubernetes clusters and AWS Load Balancer Controller, where SSL offloading takes place in an AWS EKS cluster equipped with Elastic Application Load Balancers.

This integration enables organizations running cloud native workloads and serving encrypted HTTPs traffic with *Elastic Application Load Balancers *the ability to automate and secure the lifecycle of TLS certificates using policies defined by security teams and ensure the extension of security policies to Kubernetes resources.

This integration is enabled through Kubernetes resource configuration.

**Release and support versions**

AWS Load Balancer Controller is part of Kubernetes community. There are no specific version requirements on cert-manager and AWS Load Balancer Controller.

**Applicability**

Any organization running clusters in AWS EKS and taking advantage of Elastic Application Load Balancers as layer 7 load balancers to manage the HTTPs requests that client applications send to web apps that are hosted on a pool of web servers should consider deploying this integration to automate the management of machine identities consumed by Elastic Load Balancers.

**Special notes and limitations**

There is a reference specification for ingress controllers which allows securing an Ingress implementation by specifying a [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that contains a TLS private key and certificate. *cert-manager* is aware and knows where and how to retrieve the Secret, therefore, able to operate on the TLS private key and certificate.

The configuration-only based integration with Kubernetes ingresses is not limited to AGIC. *cert-manager* can integrate with all ingresses that implement the reference specification for ingress controller. This includes the three controllers supported and maintained by Kubernetes, GLBC by GCP, ingress-nginx and the following third-party ingresses:

- Kong Ingress Controller for Kubernetes
- Azure Application Gateway Ingress Controller
- Istio Ingress
- Traefik Kubernetes Ingress provider
- Citrix Ingress Controller
- Apache APISIX ingress controller
- Gloo
- NGINX Ingress Controller for Kubernetes
- Avi Kubernetes Operator
- HAProxy Ingress
- Pomerium Ingress Controller

This list is always growing and changing by Ingress providers, for the latest version, check out the third-party ingress controllers link in “Additional resources”.

**Additional resources **

- Elastic Application Load Balancer: [https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- Installing the AWS Load Balancer Controller add-on: [https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
- AWS Load Balancer Controller: [https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/)
- Available third-party ingress controllers in addition to AWS Load Balancer Controller: [https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

**Get it to work **

First, install AWS Load Balancer Controller using helm command provided here: [https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/main/helm/aws-load-balancer-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/main/helm/aws-load-balancer-controller)

There are two ways to configure the ingress controller via the ingress resource configuration *after the successful creation of the ingress which tells EKS to use Elastic Application Load Balancer as the Ingress*.

Method 1: annotation

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

     name: #NAME_YOUR_INGRESS

     annotations:

Method 2: spec attribute “*ingressClassName*”

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

     name: #NAME_YOUR_INGRESS

spec:

     ingressClassName: eks/aws-load-balancer-controller

**ABOUT AWS Elastic Load Balancer**

Kubernetes Ingress is an API object that manages external access to the services in a cluster, typically HTTP. [Ingress](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#ingress-v1-networking-k8s-io) exposes HTTP and HTTPS routes from outside the cluster to [services](https://kubernetes.io/docs/concepts/services-networking/service/) within the cluster. Traffic routing is controlled by rules defined on the Ingress resource. It may provide load balancing, SSL termination and name-based virtual hosting. You must have an [Ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers) to satisfy an Ingress. Unlike other types of controllers which run as part of the kube-controller-manager binary, Ingress controllers are not started automatically with a cluster. Use this page to choose the ingress controller implementation that best fits your cluster.
