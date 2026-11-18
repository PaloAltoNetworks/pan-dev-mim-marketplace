## Installation

There are two ways to make cert-manager part of an OpenShift deployment:

- **cert-manager Operator for Red Hat OpenShift**: The operator is not installed in OpenShift Container Platform by default. Install it from the OpenShift web console like any other application. This applies to OpenShift 4 and later.
- **YAML manifests**: Deploy cert-manager on OpenShift clusters with the regular cert-manager YAML manifests.

## Compatibility

cert-manager version compatibility is tested and documented in the [cert-manager supported releases](https://cert-manager.io/docs/releases/).

cert-manager works with all certified Kubernetes distributions, including AWS EKS and EKS Anywhere, Azure AKS and Arc, and Google GKE and Anthos, regardless of how the platform is delivered or sourced.
