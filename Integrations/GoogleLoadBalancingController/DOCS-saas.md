# Google Load Balancing Controller

## Prerequisites

- A GKE cluster that uses the GKE Ingress controller (GLBC) with Google Cloud Load Balancing.
- cert-manager installed in the cluster.
- A cert-manager CyberArk (formerly Venafi) issuer configured to enroll certificates from Certificate Manager, SaaS. See the [cert-manager issuer documentation](https://cert-manager.io/docs/configuration/venafi/).

## Configuration

1. Create the Ingress so that GKE uses Google Cloud Load Balancing. The `kubernetes.io/ingress.class: gce` annotation deploys an external Application Load Balancer and is also the default when no class is set. Use `gce-internal` for an internal Application Load Balancer. GKE Ingress does not support `spec.ingressClassName`.
2. Reference a TLS Secret in the Ingress and annotate the Ingress with the cert-manager issuer, so cert-manager requests the certificate and stores it in that Secret.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    kubernetes.io/ingress.class: "gce"
    cert-manager.io/issuer: "my-issuer"
spec:
  tls:
    - hosts:
        - app.example.com
      secretName: app-example-com-tls
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

For a ClusterIssuer, use the `cert-manager.io/cluster-issuer` annotation instead. See [Securing Ingress resources](https://cert-manager.io/docs/usage/ingress/) in the cert-manager documentation.

## Covered Scenarios

cert-manager works with any Ingress controller that implements the Kubernetes Ingress TLS specification, not only GLBC. This includes ingress-nginx, AWS Load Balancer Controller, Kong, Azure Application Gateway, Istio, Traefik, Citrix, Apache APISIX, Gloo, NGINX Ingress Controller, Avi Kubernetes Operator, HAProxy and Pomerium Ingress. See [Ingress controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) for the current list.
