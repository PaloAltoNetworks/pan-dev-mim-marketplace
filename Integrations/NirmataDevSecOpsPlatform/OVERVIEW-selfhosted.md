# Nirmata DevSecOps Platform

Developers deploying applications on Kubernetes need certificates on demand, but issuing them by hand slows teams down and leaves room for certificates that break policy or expire unnoticed. The Nirmata DevSecOps Platform (NDP) and Certificate Manager, Self-Hosted automate certificate management for Kubernetes clusters wherever they run, giving developers secure self-service while security teams keep control of policy.

**Value Highlights**

- **Enable secure self-service** for developers on any cluster.
- **Eliminate overhead** in managing machine identities.
- **Ensure compliance** with corporate certificate standards.
- **Prevent downtime** related to certificate expiration.
- **Deploy cert-manager as an add-on** to every cluster created from a cluster type.
- **Create cluster issuers** directly from NDP.

**How it Works**

NDP deploys cert-manager from its add-on catalog, either per cluster or automatically for every cluster created with a chosen cluster type. Deployed cert-manager instances can be upgraded together from their Git settings. From NDP you can then create cluster issuers, including the Venafi issuer, on any cluster that runs cert-manager. The Venafi issuer connects to Certificate Manager, Self-Hosted and requests certificates from a policy folder, so every certificate cert-manager issues follows your organization's policy.

**Solution Components**

- Certificate Manager, Self-Hosted
- Nirmata DevSecOps Platform
- cert-manager

**About Nirmata**

[Nirmata](https://nirmata.com/) is the creator of Kyverno, a CNCF project for Kubernetes policy management, and provides Nirmata Enterprise for Kyverno, an enterprise distribution with long-term support.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
