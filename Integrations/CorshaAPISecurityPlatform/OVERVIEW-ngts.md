# Corsha API Security Platform

Machine identities used in API authentication are typically long-lived and easy to steal and reuse. Corsha solves this problem by providing a second layer of machine identity that is dynamic and unique to each machine, which enables zero-trust access for API services.

**SOLUTION OVERVIEW**

Machine identities used in API authentication are typically long-lived and easy to steal and reuse. Corsha solves this problem by providing a second layer of machine identity that is dynamic and unique to each machine, which enables zero-trust access for API services.

As part of the Machine Identity Management Development Fund, Corsha will integrate cert-manager into its native Kubernetes-based infrastructure.

There are numerous use cases within Corsha’s Distributed Network Ledger (DLN) infrastructure for issuing certificates with cert-manager including:

- Maintaining mutualTLS between internal resources within the DLN
- Securing all ingress resources into the cluster
- Provisioning new Hyperledger Fabric client identities
- Improved certificate rotation and revocation.
