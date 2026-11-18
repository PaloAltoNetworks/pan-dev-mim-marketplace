# cert-manager-operator for Red Hat OpenShift

Application teams on OpenShift need certificates for the containers and code they deploy, while security teams need visibility and governance over every machine identity in those clusters. The cert-manager Operator for Red Hat OpenShift, built on cert-manager, connects OpenShift clusters to Next-Gen Trust Security so both needs are met.

Application operations teams can fully automate certificate issuance, and the security team keeps visibility and governance of all machine identities in the clusters from Next-Gen Trust Security.

**Value Highlights**

- **Automate certificate issuance**: Let application teams get certificates on OpenShift without manual requests.
- **Keep central governance**: Maintain visibility and policy control of OpenShift certificates in Next-Gen Trust Security.
- **Install like any OpenShift app**: Add the operator from the OpenShift web console on OpenShift 4 and later.
- **Use tested versions**: Rely on cert-manager version compatibility that is tested and documented in the [cert-manager supported releases](https://cert-manager.io/docs/releases/).
- **Stay consistent across clouds**: Apply the same cert-manager approach on other certified Kubernetes distributions such as EKS, AKS and GKE.

**How it Works**

The operator installs and manages cert-manager on the OpenShift cluster. cert-manager adds certificates and issuers as Kubernetes resources and requests certificates from Next-Gen Trust Security according to its policies, then renews them before they expire. You can also deploy cert-manager on OpenShift with regular YAML manifests. See the Documentation tab for deployment options.

**Solution Components**

- Next-Gen Trust Security
- cert-manager Operator for Red Hat OpenShift
- Red Hat OpenShift Container Platform 4 or later

**About Red Hat**

Red Hat provides enterprise open source solutions, including Linux, cloud, container and Kubernetes technologies. [Red Hat OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift) is a hybrid cloud application platform powered by Kubernetes that delivers a consistent experience across public cloud, on-premises, hybrid cloud and edge.
