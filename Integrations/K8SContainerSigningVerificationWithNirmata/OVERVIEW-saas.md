# K8S Container Signing Verification with Nirmata

This Development Fund project from Nirmata will improve supply chain security by enabling image verification for your Kubernetes clusters using Nirmata Policy Manager and CodeSign Protect.

**SOLUTION OVERVIEW**

Today, SecOps engineers have to manually create policies and include their certificates in the policies to enable image verification. This is not only cumbersome and error prone but also unmanageable at scale. This Development Fund sponsored solution addresses this problem by automating the entire workflow. CodeSign Protect supports signing container images using cosign (via PKCS11 certificates, and public/private key-pairs), and Podman/Skopeo (using GPG keys). Nirmata supports verification of signed container images during Kubernetes admission controls and in-cluster background scans via policies. This integration allows SecOps engineers to define policies that can be used to ensure that only verified and attested images are deployed to their clusters.

**ABOUT Nirmata**

Nirmata is the creator of Kyverno, now a CNCF incubating project with over 1 billion downloads. Kyverno has become the de facto solution for Kubernetes policy enforcement and management. Nirmata provides Nirmata Enterprise for Kyverno. It is an enterprise-grade distribution of Kyverno with long-term support, designed to save time and costs for production users.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
