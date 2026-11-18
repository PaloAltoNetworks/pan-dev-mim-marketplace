# Pomerium Ingress Controller

The ingress controller is where TLS traffic to a Kubernetes cluster is terminated, so every hostname it serves needs a valid certificate. Pomerium Ingress Controller is an ingress controller built on Pomerium, a context-aware access proxy. Combined with cert-manager and Certificate Manager, SaaS, teams serving HTTPS through Pomerium can automate the lifecycle of their TLS certificates using policies defined by the security team, extending those policies to Kubernetes resources.

**Value Highlights**

- **Automate ingress certificates**: cert-manager issues and renews the TLS certificate for each Pomerium Ingress.
- **Apply security team policy**: Certificates are requested from Certificate Manager, SaaS, so they follow your organization's policy.
- **Configure, do not code**: The integration is enabled entirely through Kubernetes resource configuration.
- **Combine TLS with access control**: Pomerium adds identity-aware access policy on top of the TLS endpoint.
- **Avoid version lock-in**: There are no specific version requirements beyond Kubernetes and Pomerium Ingress Controller compatibility.

**How it Works**

Pomerium Ingress Controller follows the Kubernetes Ingress specification, which secures an Ingress with a [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that holds the TLS certificate and private key. cert-manager watches Ingress resources annotated with an issuer, requests the certificate through an issuer connected to Certificate Manager, SaaS, and writes it to the Secret that Pomerium uses. See the Documentation tab for the Ingress configuration.

**Solution Components**

- Certificate Manager, SaaS
- cert-manager
- Pomerium Ingress Controller

**About Pomerium**

[Pomerium](https://www.pomerium.com/) is an identity-aware proxy that enables secure access to internal applications. It adds access control to applications whether or not they have authentication or authorization built in, and can be used where you would typically reach for a VPN.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
