# Certificate Manager Operator for Red Hat OpenShift

Platform teams that run OpenShift need a reliable way to install, upgrade and keep consistent the components that connect their clusters to Certificate Manager, SaaS. Certificate Manager Operator for Red Hat OpenShift simplifies deployment of these enterprise components and their dependencies, using declarative manifests that define the desired state of each deployment.

**Value Highlights**

- **Deploy the right components**: Select and deploy the Kubernetes components each team needs as a deployment package.
- **Use tested versions**: Each release ships a default set of component versions that are tested together.
- **Pin versions**: Specify exact component versions for consistent deployments across environments.
- **Manage many clusters**: Roll out releases across multiple Kubernetes clusters and environments.
- **Upgrade smoothly**: Move components between versions without manual reinstallation.

**How it Works**

The operator reads *VenafiInstall* manifests that describe the components and versions you want, and installs and maintains them in the cluster. The components it manages are:

- **cert-manager**: An enterprise distribution of [cert-manager](https://cert-manager.io/) for application certificate management, with long-term support from the team that maintains the open source project and FIPS 140-2 compliance.
- **Venafi Enhanced Issuer**: A cert-manager issuer, cluster-wide or per namespace, that enrolls certificates for your clusters directly from Certificate Manager, SaaS.
- **Firefly**: A lightweight, high-performance issuer for workload certificates, centrally governed by Certificate Manager, SaaS while issuing locally.
- **Venafi Kubernetes Agent**: Gathers data on certificates and other Kubernetes resources, such as ingresses, for real-time visibility in Certificate Manager, SaaS.

**Solution Components**

- Certificate Manager, SaaS
- Certificate Manager Operator for Red Hat OpenShift
- Red Hat OpenShift

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
