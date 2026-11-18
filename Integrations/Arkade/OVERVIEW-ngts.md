# arkade

arkade is a portable Kubernetes marketplace that works on any cloud or local Kubernetes cluster. Teams use it to find and install common Kubernetes apps and DevOps CLIs with a single command instead of searching for charts and manifests.

arkade installs cert-manager in one step. With cert-manager configured to use Next-Gen Trust Security as its issuer, clusters get certificates that follow your organization's policy.

**Value Highlights**

- **Install cert-manager in one command** with no searching for the correct charts or CRDs.
- **Create, renew and manage** certificates on Kubernetes through cert-manager.
- **Reduce operational work** by automating certificate management on local and cloud clusters.
- **Keep certificates under policy** by issuing them through Next-Gen Trust Security.
- **Secure apps such as OpenFaaS** and ingress controllers with TLS.

**How it Works**

You run `arkade install cert-manager` to deploy cert-manager to your cluster. You then create a cert-manager issuer that connects to Next-Gen Trust Security, and cert-manager requests and renews certificates for your Certificate and Ingress resources through it.

**Special Notes and Limitations**

arkade previously included dedicated apps for installing Venafi issuers. Those apps were removed from arkade in 2022, so issuer configuration is now a separate cert-manager step.

**Solution Components**

- Next-Gen Trust Security
- arkade and cert-manager in a Kubernetes cluster

**About arkade**

[arkade](https://github.com/alexellis/arkade) is an open-source project created by Alex Ellis and maintained by OpenFaaS Ltd.
