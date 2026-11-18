# cert-manager

Kubernetes workloads need TLS certificates that are issued fast and renewed often, and requesting and installing them by hand does not keep up. cert-manager builds natively on the Kubernetes API and is the de facto open source solution for issuing and renewing certificates in Kubernetes and OpenShift clusters.

Connected to Certificate Manager, SaaS, cert-manager lets DevOps teams get certificates automatically while security teams keep control of policy and visibility across clusters.

**Value Highlights**

- **Remove manual certificate work**: Eliminate the effort and risk of requesting and installing certificates by hand.
- **Comply with policy automatically**: Issue certificates that follow the policies security teams define in Certificate Manager, SaaS.
- **Automate the lifecycle**: Request, retrieve and renew certificates without human intervention.
- **Work in native tools**: Start key and certificate operations directly from Kubernetes or OpenShift.
- **See what is in your clusters**: Give security teams visibility into certificates in fast-changing Kubernetes environments, which network scanners cannot provide.

**How it Works**

cert-manager uses its Venafi issuer to connect to Certificate Manager, SaaS with an API key. When a `Certificate` resource is created or nears expiry, cert-manager sends the request to Certificate Manager, SaaS, which applies the policy for the configured issuing template and returns the issued certificate. cert-manager stores it in a Kubernetes Secret for workloads to use. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- cert-manager
- Kubernetes or OpenShift clusters

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
