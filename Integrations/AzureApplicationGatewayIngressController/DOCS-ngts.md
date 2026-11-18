## Prerequisites

- An AKS cluster with Azure Application Gateway and the Application Gateway Ingress Controller enabled. See [Enable the application gateway ingress controller add-on for an existing AKS cluster](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing).
- cert-manager installed in the cluster.
- There are no specific version requirements for cert-manager or AGIC.

## Configuration

After you create the ingress that tells AKS to use Application Gateway, configure the ingress resource to use AGIC in one of two ways.

Method 1, annotation:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <your-ingress-name>
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
```

Method 2, the `ingressClassName` spec attribute:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <your-ingress-name>
spec:
  ingressClassName: azure/application-gateway
```

The ingress secures traffic by referencing a Kubernetes [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that holds the TLS private key and certificate. cert-manager manages that Secret.

## Additional Resources

- [Azure Application Gateway](https://azure.microsoft.com/en-us/products/application-gateway/)
- [Azure Load Balancer overview](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview)
- [Configure an application gateway with TLS termination using the Azure portal](https://learn.microsoft.com/en-us/azure/application-gateway/create-ssl-portal)
- [Ingress controllers supported by Kubernetes and third parties](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
