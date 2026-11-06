# cert-manager-operator for Red Hat OpenShift

This solution features cert-manager Operator for Red Hat OpenShift, an OpenShift cluster certificate operator implemented based on *cert-manager, *the de-facto machine identity management component in Kubernetes clusters. This enables organizations to plug into the Certificate Manager for their OpenShift clusters certificates management, therefore, effectively take advantage of all the familiar machine identity management capabilities the Control Plane offers. For example, Application ops teams who manage the containers and code that are deployed on OpenShift can now fully automate the certificate issuance process while the organization’s security team still maintains all visibility and governance of all machine identities in the OpenShift clusters through a single pane of glass - the Certificate Manager.

**Release and support versions**

Version compatibility is thoroughly tested and documented here: [https://cert-manager.io/docs/installation/supported-releases/](https://cert-manager.io/docs/installation/supported-releases/)

**Applicability**

Organizations running any workloads that are managed by OpenShift should always use cert-manager for certificates managements.

Many organizations use a multi-cloud strategy, therefore employ a set of different distributions of certified Kubernetes distributions including some of the following:

- AWS EKS and EKS Anywhere
- Azure AKS and Arc
- GCP GKE and Anthos

All these certified distributions support the same set of APIs and they work with the same container standards as well as are compatible with the operations with *cert-manager* for managing certificates within clusters.

*cert-manager* works with all these certified Kubernetes distributions regardless how the container orchestration platform is delivered and where it is sourced.

**Get it to work **

There are two ways to make *cert-manager* part of OpenShift deployments:

- Use the *cert-manager* Operator for Red Hat OpenShift, just like any application on OpenShift. You can install the cert-manager Operator for Red Hat OpenShift by using the web console since cert-manager operator is not installed in OpenShift Container Platform by default. This is applicable to OpenShift 4 and above.
- *cert-manager* can be deployed on OpenShift clusters by using regular YAML manifests.

**ABOUT Red Hat and OpenShift**

Red Hat is the world’s leading provider of enterprise open source solutions—including Linux, cloud, container, and Kubernetes. Red Hat delivers hardened solutions that make it easier for enterprises to work across platforms and environments, from the core datacenter to the network edge.

Red Hat OpenShift, the industry's leading hybrid cloud application platform powered by Kubernetes, brings together tested and trusted services to reduce the friction of developing, modernizing, deploying, running, and managing applications. OpenShift delivers a consistent experience across public cloud, on-premise, hybrid cloud, or edge architecture.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
