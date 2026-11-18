# Pulumi CrossGuard

Developers who provision their own Kubernetes infrastructure can easily deploy cert-manager with the wrong issuer, which results in certificates that do not meet security policy. Pulumi simplifies deploying cert-manager on Kubernetes and provides the cert-manager CRDs as strongly typed resources. CrossGuard, Pulumi's Policy as Code offering, can then verify the issuer before a deployment goes ahead, so certificates come from an approved source such as Next-Gen Trust Security.

**Value Highlights**

- **Secure Kubernetes** with Policy as Code and cert-manager.
- **Simplify cert-manager deployments** with Pulumi examples and strongly typed certificate resources.
- **Choose your issuer**: Deploy a Pulumi stack using the issuer you need, including the Venafi issuer for Next-Gen Trust Security.
- **Block misconfigured deployments**: Policies verify the issuer type before deployment and stop updates that violate them.
- **Enable self-service with guardrails**: Developers provision their own infrastructure while staying within business and security policy.

**How it Works**

Pulumi deploys cert-manager to your cluster and defines issuers and certificates as code. CrossGuard policies run as part of each Pulumi deployment and check that certificate resources use an approved issuer. Any violation gates or blocks the update. When the Venafi issuer is used, cert-manager requests certificates from Next-Gen Trust Security, so they follow your organization's policy. See [Pulumi Policy as Code](https://www.pulumi.com/docs/discovery-governance/concepts/policy-as-code/) for details.

**Solution Components**

- Next-Gen Trust Security
- Pulumi with CrossGuard Policy as Code
- cert-manager on Kubernetes

**About Pulumi**

[Pulumi](https://www.pulumi.com/) provides an Infrastructure as Code platform that helps engineering teams work together and ship faster.
