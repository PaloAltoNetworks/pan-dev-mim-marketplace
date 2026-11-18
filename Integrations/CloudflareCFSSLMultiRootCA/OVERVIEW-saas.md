# Cloudflare CFSSL Multirootca

Kubernetes teams sometimes need a private CA that can sign certificates with more than one signing key, beyond the issuers built into cert-manager. This open source cert-manager external issuer, cfssl-issuer, lets a Kubernetes cluster use Cloudflare's CFSSL multirootca as the backend certificate authority, signing certificate requests with multiple signing keys.

**Value Highlights**

- **Sign with multiple keys**: Use CFSSL multirootca to sign certificate requests with multiple signing keys.
- **Add a private CA to cert-manager**: Extend cert-manager with a specialized private CA alongside its built-in issuers.
- **Work like a built-in issuer**: cert-manager treats this external issuer the same as any built-in issuer.
- **Run on any certified Kubernetes**: Deploy on AWS EKS and EKS Anywhere, Azure AKS and Arc, and Google GKE and Anthos.
- **Keep central visibility**: Manage the resulting certificates alongside the rest of your inventory in Certificate Manager, SaaS.

**How it Works**

cfssl-issuer implements the cert-manager external issuer interface. You create Issuer or ClusterIssuer objects that point to your CFSSL multirootca service, and cert-manager sends certificate requests to it for signing. The issuer is released as Helm charts with matching container images. See the Documentation tab for the charts and examples.

**Solution Components**

- Certificate Manager, SaaS
- cert-manager with cfssl-issuer
- Cloudflare [CFSSL](https://github.com/cloudflare/cfssl) multirootca

**About Cloudflare**

[Cloudflare](https://www.cloudflare.com/) runs a global network that makes websites, APIs, applications and corporate networks secure, private, fast and reliable.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
