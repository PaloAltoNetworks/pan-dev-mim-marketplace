# Kubernetes Cluster Discovery

Certificates used by OpenShift and Kubernetes workloads are created and replaced quickly, and they often sit outside the view of the security team. The Kubernetes Cluster Discovery integration for Certificate Manager, Self-Hosted connects to OpenShift or standard Kubernetes clusters, discovers the certificates on their routes, and imports them into Certificate Manager, Self-Hosted. This removes blind spots in your certificate inventory and brings container certificates under enterprise policy.

**Value Highlights**

- **Connect simply**: Authenticate to OpenShift or Kubernetes clusters with a standard config YAML file.
- **Find active certificates**: Traverse all routes to identify active certificates and their metadata.
- **Organize automatically**: Import discovered certificates into a structured Kubernetes policy, cluster and namespace hierarchy.
- **Keep data current**: Create or update certificate objects from raw PEM data for full lifecycle visibility.
- **Reduce outage risk**: Bring short-lived Kubernetes certificates under enterprise security standards so expired or unmanaged certificates are caught.

**How it Works**

The integration authenticates to each cluster with a config YAML file and traverses its routes to extract the certificates in use. It then creates a hierarchy in Certificate Manager, Self-Hosted: a Kubernetes policy folder that groups all container assets, a cluster object for each discovered cluster, and a namespace object for each Kubernetes namespace. Certificate objects are created or updated under their namespace from the PEM data.

**Applicability**

This integration suits organizations that run OpenShift or Kubernetes workloads at scale and need to centralize certificate security in Certificate Manager, Self-Hosted.

**Solution Components**

- Certificate Manager, Self-Hosted
- OpenShift or Kubernetes clusters

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
