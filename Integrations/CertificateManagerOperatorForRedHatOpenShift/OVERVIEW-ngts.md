# Certificate Manager Operator for Red Hat OpenShift

Platform teams that run OpenShift need a reliable way to install, upgrade and keep consistent the components that connect their clusters to Next-Gen Trust Security. Certificate Manager Operator for Red Hat OpenShift simplifies deployment of these enterprise components and their dependencies, using declarative manifests that define the desired state of each deployment.

**Value Highlights**

- **Deploy the right components**: Select and deploy the Kubernetes components each team needs as a deployment package.
- **Use tested versions**: Each release ships a default set of component versions that are tested together.
- **Pin versions**: Specify exact component versions for consistent deployments across environments.
- **Manage many clusters**: Roll out releases across multiple Kubernetes clusters and environments.
- **Upgrade smoothly**: Move components between versions without manual reinstallation.

**How it Works**

The operator reads *VenafiInstall* manifests that describe the components and versions you want, and installs and maintains them in the cluster. The components it manages include:

- **cert-manager**: An enterprise distribution of [cert-manager](https://cert-manager.io/) for application certificate management, with long-term support from the team that maintains the open source project and FIPS 140-2 compliance.
- **Enterprise Issuer**: A cert-manager issuer that lets your clusters request certificates from CAs managed in Next-Gen Trust Security, following centrally managed policies.
- **Distributed Issuer**: A lightweight certificate issuer for Kubernetes, OpenShift and other cloud-native environments, centrally governed by Next-Gen Trust Security.
- **Discovery Agent**: Connects your clusters to Next-Gen Trust Security and continuously gathers certificate, ingress and other machine identity data for display in Next-Gen Trust Security.

**Solution Components**

- Next-Gen Trust Security
- Certificate Manager Operator for Red Hat OpenShift
- Red Hat OpenShift
