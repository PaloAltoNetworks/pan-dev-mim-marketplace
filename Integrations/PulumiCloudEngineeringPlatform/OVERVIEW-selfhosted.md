# Pulumi Cloud Engineering Platform

Cloud engineering teams need to ship quickly while keeping the services behind modern applications secure. As architectures span multiple clouds, SaaS services and Kubernetes, TLS certificates become hard to track, and expired ones break trust between components. Pulumi is an Infrastructure as Code (IaC) platform, and the Venafi provider for Pulumi lets teams create and consume certificates from Certificate Manager, Self-Hosted alongside the cloud resources they already define in code.

**Value Highlights**

- **Define certificates as code**: Request certificates from Certificate Manager, Self-Hosted in the same Pulumi programs that build your infrastructure.
- **Replace expired certificates on demand**: Every deployment or infrastructure update can renew certificates and establish trust correctly.
- **Use your favorite languages**: Work in the programming languages, source control systems and IDEs your team already uses.
- **Test and enforce policy**: Apply unit tests, integration tests and policy enforcement to infrastructure that includes certificates.
- **Deploy anywhere**: Combine certificates with resources in AWS, Azure, Google Cloud and many SaaS platforms.

**How it Works**

The Venafi provider is a Pulumi package, built by Pulumi through the Machine Identity Management Development Fund and based on the Venafi Terraform provider. It provides resources for certificates, policy and SSH certificates. The provider connects to your Certificate Manager, Self-Hosted URL with an access token or PKCS#12 client certificate and requests certificates from the policy folder set as the zone. See the [Venafi provider documentation](https://www.pulumi.com/registry/packages/venafi/) for configuration.

**Solution Components**

- Certificate Manager, Self-Hosted
- Pulumi with the Venafi provider package

**About Pulumi**

[Pulumi](https://www.pulumi.com/) provides an Infrastructure as Code platform that helps engineering teams work together and ship faster.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
