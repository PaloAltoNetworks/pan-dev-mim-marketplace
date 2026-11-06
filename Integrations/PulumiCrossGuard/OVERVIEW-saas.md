# Pulumi CrossGuard

Pulumi simplifies deploying cert-manager on Kubernetes and includes the necessary Kubernetes CRDs needed to provision certificates as strongly-typed resources. CrossGuard Policy as Code can enforce issuer verification for additional security.

  

**SOLUTION HIGHLIGHTS**

- **Secure Kubernetes **with policy as code and cert-manager
- **Simplify **cert-manager deployments
- **Deploy a Pulumi stack **using the issuer of your choice (Venafi Platform, Venafi as a Service, Let's Encrypt)
- **Create policies **that verify the issuer type before deployment and block improperly configured deployments

  

**SOLUTION OVERVIEW**

CrossGuard is Pulumi’s new Policy as Code offering. CrossGuard empowers you to set guardrails to enforce compliance for resources so developers within an organization can provision their own infrastructure while sticking to best practices and security compliance. Using Policy as Code, you can write flexible business or security policies. When policies are executed as part of a Pulumi deployment, any violation will gate or block that update from proceeding.  

  

Pulumi has added cert-manager examples for CrossGuard to simplify the install of cert-manager on Kubernetes.
