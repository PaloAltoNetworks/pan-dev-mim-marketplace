# mTLS for Kubernetes workloads with Otterize & Venafi

Securing traffic between Kubernetes workloads with mutual TLS (mTLS) means every workload needs a certificate that is issued, rotated and trusted, plus access policies that say which workloads may talk to each other. Otterize combined with Certificate Manager, SaaS automates both. Developers declare which services a workload calls, and Otterize generates the access policies and the mTLS certificates, with certificates issued through cert-manager from Certificate Manager, SaaS.

**Value Highlights**

- **Automate the certificate lifecycle**: Issue and rotate certificates and keys for Kubernetes workloads without manual steps.
- **Control access by intent**: Use intent-based access control (IBAC) so only declared clients can reach a workload.
- **Reduce administrative overhead**: Replace hand-written policies and certificate requests with declarative intents.
- **Keep certificates in policy**: Issue workload certificates under the policies defined in Certificate Manager, SaaS.

**How it Works**

You declare and apply client intents for workloads running in Kubernetes clusters. Otterize turns those intents into access policies, such as network policies, Kafka ACLs and AWS IAM policies, and generates and deploys mTLS certificates between each workload and its clients, using cert-manager as the certificate provider. cert-manager requests those certificates from Certificate Manager, SaaS. See the Documentation tab for setup.

**Applicability**

This integration suits enterprises that want fully automated workload certificate management and verification while enforcing intent-based access control policies.

**Solution Components**

- Certificate Manager, SaaS
- [cert-manager](https://cert-manager.io/)
- Otterize

**About Otterize**

[Otterize](https://docs.otterize.com) is a workload identity and access management platform that automates access control for cloud-native environments with a declarative, zero-trust approach.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
