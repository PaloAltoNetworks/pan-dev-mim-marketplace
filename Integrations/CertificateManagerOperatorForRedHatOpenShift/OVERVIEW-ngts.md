# Certificate Manager Operator for Red Hat OpenShift

Certificate Manager Operator for Red Hat OpenShift simplifies deployment of [Venafi](https://venafi.com/)'s enterprise components and dependencies.

The enterprise components include:

- **cert-manager**: An enterprise distribution of [cert-manager](https://cert-manager.io/) designed for application certificate management within your clusters.
- **Venafi Enhanced Issuer**: Enables seamless certificate enrollment for your clusters directly from Next-Gen Trust Security.
- **Venafi Firefly**: A high-performance, lightweight issuer for certificates, centrally managed by Next-Gen Trust Security.
- **Venafi Kubernetes Agent**: Provides real-time visibility into certificates and Kubernetes resources directly within Next-Gen Trust Security.

  

**Automate Venafi deployments with confidence**

The Certificate Manager Operator simplifies Venafi installation, maintenance, and upgrades. Leveraging *VenafiInstall* manifests, it precisely defines your desired deployment state. This operator streamlines the process by providing:

- Deployment Packages: Platform operators can effortlessly select and deploy the necessary Venafi components tailored to the needs of their teams.
- Version Compatibility: Each release comes with a set of "default" component versions which are tested together, improving compatibility for users.
- Version Pinning: Specify precise versions of the Venafi Kubernetes components to ensure consistent deployments across diverse environments.
- Distributed Releases: Effortlessly manage releases across multiple Kubernetes clusters, facilitating complex multi-environment deployments.
- Upgrades: Seamlessly upgrade Venafi components, ensuring a smooth transition between versions.

  

**Enterprise Version of cert-manager**

An enhanced version of cert-manager designed for application certificate management within your clusters.

Key features:

- Long Term Support (LTS): Enterprise-grade offering built and supported by the expert team that maintains the cert-manager open source project.
- Highest grade compliance: Enhances security and provides FIPS 140-2 compliance for Kubernetes machine identity management.

###   

**Enhanced integration with Next-Gen Trust Security**

Enables seamless certificate enrollment for your clusters directly from the [Next-Gen Trust Security](https://venafi.com/control-plane/). [Venafi Enhanced Issuer](https://docs.venafi.cloud/vaas/k8s-components/c-vei-overview/)is a cert-manager issuer that can be either cluster-wide or per namespace.

  

###   

**Workload identity issuance for modern environments**

Lightweight and ephemeral, [Venafi Firefly](https://venafi.com/firefly/) goes beyond conventional PKI systems, bridging the gap between platform efficiency and security compliance.

  

By working in tandem with the [Next-Gen Trust Security,](https://venafi.com/control-plane/) [Venafi Firefly](https://venafi.com/firefly/) combines centralized governance with decentralized identity issuance, empowering your team to securely validate and authenticate every workload identity, in every environment.

  

**Real-time visibility into certs and Kubernetes resources**

Gain real-time visibility into certificates and Kubernetes resources directly within the [Next-Gen Trust Security](https://venafi.com/control-plane/). The [Venafi Kubernetes Agent](https://docs.venafi.cloud/vaas/k8s-components/c-tlspk-agent-overview/) gathers data for machine identities and other Kubernetes resources, such as ingresses, from Kubernetes clusters connected to Next-Gen Trust Security.

  
