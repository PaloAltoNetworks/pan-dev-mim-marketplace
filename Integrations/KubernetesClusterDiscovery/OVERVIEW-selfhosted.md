# Kubernetes Cluster Discovery

The Kubernetes Cluster Discovery integration for Certificate Manager, Self-Hosted provides automated visibility and management of certificates across your containerized infrastructure. By connecting directly to OpenShift or standard Kubernetes clusters via a YAML configuration, it helps remove blind spots in your machine identity landscape.

This integration bridges the gap between dynamic DevOps environments and centralized security, ensuring every route and certificate is discovered, imported, and governed according to enterprise policy.

**SOLUTION COMPONENTS**

- Certificate Manager, Self-Hosted
- OpenShift / Kubernetes

**KEY TECHNICAL FEATURES**

- **Seamless OpenShift integration:** authenticates and connects to OpenShift/Kubernetes environments using a standard config YAML to begin deep-scan discovery.
- **Route-based certificate extraction:** automatically traverses all Kubernetes routes to identify active certificates and their associated metadata.
- **Automated hierarchical provisioning:** imports discovered data into Certificate Manager, Self-Hosted by automatically creating a structured hierarchy:
  - *Kubernetes Policy* — groups all container-related assets
  - *Cluster Object* — created dynamically based on the discovered cluster
  - *Namespace Object* — segregates certificates by their specific Kubernetes namespace
- **PEM data synchronization:** creates or updates certificate objects under their respective namespaces using raw PEM data for full lifecycle visibility.
- **Centralized compliance:** aligns ephemeral Kubernetes certificates with enterprise security standards, reducing the risk of outages from expired or unmanaged certificates.

**USE CASES**

For organizations running high-scale OpenShift or Kubernetes workloads who need to centralize machine identity security within Certificate Manager, Self-Hosted.
