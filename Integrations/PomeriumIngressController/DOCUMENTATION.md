# Pomerium Ingress Controller with cert-manager

## Prerequisites

- cert-manager and Pomerium Ingress Controller running in a Kubernetes cluster
- A cert-manager Issuer or ClusterIssuer configured to request certificates from your Venafi tenant (see [Venafi issuer configuration](https://cert-manager.io/docs/configuration/venafi/))

There are no specific version requirements on cert-manager or Pomerium Ingress Controller. As long as Kubernetes and Pomerium Ingress Controller versions are compatible, the integration works.

## Configuration

Add a cert-manager issuer annotation and a `tls` section to the Ingress, and set the Ingress class to `pomerium`. cert-manager then requests the certificate and stores it in the named Secret, which Pomerium uses to terminate TLS.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <your-ingress>
  annotations:
    cert-manager.io/cluster-issuer: <your-venafi-cluster-issuer>
spec:
  ingressClassName: pomerium
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <your-service>
                port:
                  name: http
  tls:
    - hosts:
        - app.example.com
      secretName: app-example-com-tls
```

## Covered Scenarios

cert-manager can secure any ingress controller that implements the Kubernetes Ingress specification, not only Pomerium. For the current list of controllers, see [Ingress controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) in the Kubernetes documentation.

## Additional Resources

- [Pomerium Ingress Controller documentation](https://www.pomerium.com/docs/deploy/k8s/ingress)
- [Securing Ingress resources with cert-manager](https://cert-manager.io/docs/usage/ingress/)
