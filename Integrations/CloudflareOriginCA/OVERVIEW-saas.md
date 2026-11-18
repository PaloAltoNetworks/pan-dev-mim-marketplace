# Cloudflare Origin CA

Sites proxied through Cloudflare need certificates on their origin servers so traffic between Cloudflare and the origin is encrypted. When those origins run on Kubernetes, issuing and renewing origin certificates by hand does not keep up. Origin CA Issuer is a cert-manager controller for Cloudflare Origin CA, so Kubernetes workloads get Cloudflare origin certificates automatically.

**Value Highlights**

- **Automate origin certificates**: Request and renew Cloudflare Origin CA certificates from cert-manager.
- **Encrypt traffic to the origin**: Protect the connection between Cloudflare and your Kubernetes services.
- **Scope access tightly**: Authenticate with Cloudflare API tokens limited to specific accounts or zones.
- **Use standard cert-manager workflows**: Request certificates through the same resources teams already use.
- **Keep central visibility**: Manage the resulting certificates alongside the rest of your inventory in Certificate Manager, SaaS.

**How it Works**

Origin CA Issuer runs in the cluster and processes the certificate requests that cert-manager creates for an `OriginIssuer` resource. It calls Cloudflare Origin CA with an API token that has the Zone / SSL and Certificates / Edit permission, and returns the signed certificate to cert-manager. See the Documentation tab for installation.

**Solution Components**

- Certificate Manager, SaaS
- cert-manager with Origin CA Issuer
- [Cloudflare Origin CA](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/)

**About Cloudflare**

[Cloudflare](https://www.cloudflare.com/) runs a global network that makes websites, APIs, applications and corporate networks secure, private, fast and reliable.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
