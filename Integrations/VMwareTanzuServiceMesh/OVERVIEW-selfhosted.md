# VMware Tanzu Service Mesh

Complex, interconnected Kubernetes workloads need certificates that are trusted by the organization, not just by the mesh. VMware has integrated Certificate Manager, Self-Hosted as the machine identity control plane for [Tanzu Service Mesh](https://tanzu.vmware.com/service-mesh), so Tanzu users can connect their service mesh to a trusted certificate authority of their choice for mutual TLS (mTLS) between Kubernetes clusters.

Certificates generated for services then chain to your organizational CA, which increases observability and control and helps meet compliance requirements in regulated industries.

**Value Highlights**

- **Automate trusted identities**: Automate enterprise-trusted machine identities for Kubernetes workloads.
- **Cover ingress and mTLS**: Support both ingress and service-to-service mTLS use cases.
- **Choose your CA**: Use any certificate authority supported by Certificate Manager, Self-Hosted (more than 40).
- **Stay compliant**: Keep service certificates within your organizational CA trust chain.

**How it Works**

Tanzu Service Mesh requests the certificates for services in the mesh from Certificate Manager, Self-Hosted, which issues them from the CA you choose and applies your certificate policy. Services across clusters then use those certificates for mTLS and ingress.

**Solution Components**

- Certificate Manager, Self-Hosted
- VMware Tanzu Service Mesh
- Kubernetes clusters connected to the mesh

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
