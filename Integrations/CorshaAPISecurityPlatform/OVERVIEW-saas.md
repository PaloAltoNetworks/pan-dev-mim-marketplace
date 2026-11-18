# Corsha API Security Platform

Machine identities used in API authentication are typically long-lived and easy to steal and reuse. Corsha addresses this by adding a second layer of machine identity that is dynamic and unique to each machine, which enables zero-trust access for API services.

Corsha's integration with cert-manager, developed under the Machine Identity Management Development Fund, brings certificates governed by Certificate Manager, SaaS into Corsha's native Kubernetes-based infrastructure.

**Value Highlights**

- **Maintain mutual TLS**: Keep mTLS between internal resources within Corsha's Distributed Ledger Network (DLN).
- **Secure ingress**: Protect all ingress resources into the cluster with trusted certificates.
- **Provision client identities**: Issue new Hyperledger Fabric client identities.
- **Improve rotation and revocation**: Rotate and revoke certificates without manual effort.
- **Keep policy central**: Certificates issued in the cluster follow the policy defined in Certificate Manager, SaaS.

**How it Works**

Corsha runs cert-manager inside its Kubernetes infrastructure. cert-manager's Venafi issuer requests certificates from Certificate Manager, SaaS using an application and issuing template, stores them as Kubernetes secrets and renews them before they expire.

**Solution Components**

- Certificate Manager, SaaS
- cert-manager
- Corsha API Security Platform

**About Corsha**

[Corsha](https://corsha.com) provides an API security platform that uses dynamic machine identities to enable zero-trust access for API services.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
