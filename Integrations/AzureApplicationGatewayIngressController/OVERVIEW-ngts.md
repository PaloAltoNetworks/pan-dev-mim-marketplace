# Azure Application Gateway Ingress Controller

This *reference solution* highlights the integration of *cert-manager*, the de-facto machine identity management component in Kubernetes clusters and Azure Application Gateway Ingress Controller (AGIC), where SSL offloading takes place in an AKS cluster equipped with Azure Application Gateway.

This integration enables organizations running cloud native workloads and serving HTTPs traffic with *AGIC *the ability to automate and secure the lifecycle of TLS certificates using policies defined by security teams and ensure the extension of security policies to Kubernetes resources.

This integration is enabled through Kubernetes resource configuration.

**Release and support versions**

There are no specific version requirements on cert-manager and AGIC.

**Applicability**

Any organization running clusters in AKS and taking advantage of Azure Application Gateway as layer 7 load balancers to manage the HTTPs requests that client applications send to web apps that are hosted on a pool of web servers should consider deploying this integration to automate the management of machine identities consumed by Azure Application Gateway.

**Special notes and limitations**

There is a reference specification for ingress controllers which allows securing an Ingress implementation by specifying a [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that contains a TLS private key and certificate. *cert-manager* is aware and knows where and how to retrieve the Secret, therefore, able to operate on the TLS private key and certificate.

The configuration-only based integration with Kubernetes ingresses is not limited to AGIC. *cert-manager* can integrate with all ingresses that implement the reference specification for ingress controller. This includes the three controllers supported and maintained by Kubernetes, ALB Ingress by AWS, GLBC by GCP, ingress-nginx and the following third-party ingresses:

- Kong Ingress Controller for Kubernetes
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

- Azure Application Gateway: [https://azure.microsoft.com/en-us/products/application-gateway/](https://azure.microsoft.com/en-us/products/application-gateway/)
- Azure Load Balancer: [https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview)
- Manually Configure an Application Gateway with TLS termination using the Azure portal: [https://learn.microsoft.com/en-us/azure/application-gateway/create-ssl-portal](https://learn.microsoft.com/en-us/azure/application-gateway/create-ssl-portal)
- Tutorial: Enable application gateway ingress controller add-on for an existing AKS cluster with an existing application gateway: [https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing)
- Open source community: [https://kyuubang.github.io/cloud-native/2023/04/03/configure-ssl-with-agic.html](https://kyuubang.github.io/cloud-native/2023/04/03/configure-ssl-with-agic.html)
- Available third-party ingress controllers in addition to Azure Application Gateway Ingress Controller: [https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

**Get it to work **

There are two ways to configure the ingress controller via the ingress resource configuration *after the successful creation of the ingress which tells AKS to use Application Gateway as Ingress*.

Method 1: annotation

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

     name: #NAME_YOUR_INGRESS

     annotations:

           Kubernetes.io/ingress.class: “azure/application-gateway”

Method 2: spec attribute “*ingressClassName*”

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

     name: #NAME_YOUR_INGRESS

spec:

     ingressClassName: azure/application-gateway

**ABOUT Azure Application Gateway**

Azure Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications. Traditional load balancers operate at the transport layer (OSI layer 4 - TCP and UDP) and route traffic based on source IP address and port, to a destination IP address and port.
