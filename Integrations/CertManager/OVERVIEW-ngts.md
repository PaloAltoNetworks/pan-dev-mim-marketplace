# cert-manager

Kubernetes workloads need TLS certificates that are issued fast and renewed often, and requesting and installing them by hand does not keep up. cert-manager builds natively on the Kubernetes API and is the de facto open source solution for issuing and renewing certificates in Kubernetes and OpenShift clusters.

Connected to Next-Gen Trust Security, cert-manager lets DevOps teams get certificates automatically while security teams keep control of policy and visibility across clusters.

**Value Highlights**

- **Remove manual certificate work**: Eliminate the effort and risk of requesting and installing certificates by hand.
- **Comply with policy automatically**: Issue certificates that follow the policies security teams define in Next-Gen Trust Security.
- **Automate the lifecycle**: Request, retrieve and renew certificates without human intervention.
- **Work in native tools**: Start key and certificate operations directly from Kubernetes or OpenShift.
- **See what is in your clusters**: Give security teams visibility into certificates in fast-changing Kubernetes environments, which network scanners cannot provide.

**How it Works**

cert-manager adds certificates and issuers as resource types in your clusters, and can request certificates from CAs configured in Next-Gen Trust Security. When a `Certificate` resource is created or nears expiry, cert-manager requests a certificate that follows your centrally managed policy and stores it in a Kubernetes Secret for workloads to use. Next-Gen Trust Security also shows installed cert-manager components, their health and version, on the Kubernetes Clusters page. See the Documentation tab for setup.

**Solution Components**

- Next-Gen Trust Security
- cert-manager
- Kubernetes or OpenShift clusters
