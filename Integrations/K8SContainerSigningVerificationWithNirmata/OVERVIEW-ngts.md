# K8S Container Signing Verification with Nirmata

Verifying container image signatures before deployment protects Kubernetes clusters from tampered or untrusted images. Today, SecOps engineers often create verification policies by hand and paste their signing certificates into them, which is cumbersome, error-prone and unmanageable at scale. This Development Fund project from Nirmata automates that workflow with Nirmata Policy Manager and CodeSign Protect, for teams using Next-Gen Trust Security.

**Value Highlights**

- **Secure the supply chain**: Deploy only verified and attested images to your clusters.
- **Automate policy creation**: Remove manual steps to add signing certificates to verification policies.
- **Enforce at admission**: Verify signed images during Kubernetes admission control.
- **Keep checking**: Detect unverified images with in-cluster background scans.

**How it Works**

CodeSign Protect signs container images with cosign (using PKCS#11 certificates or public and private key pairs) or with Podman and Skopeo (using GPG keys). Nirmata Policy Manager uses Kyverno policies to verify those signatures when images are admitted to the cluster and during background scans. The integration lets SecOps engineers define the policies that make sure only verified images run. See the [Nirmata documentation](https://docs.nirmata.io) for setup.

**Solution Components**

- Next-Gen Trust Security with CodeSign Protect
- Nirmata Policy Manager (Nirmata Enterprise for Kyverno)
- Kubernetes clusters

**About Nirmata**

[Nirmata](https://nirmata.com/) is the creator of Kyverno, a CNCF project for Kubernetes policy enforcement and management. Nirmata Enterprise for Kyverno is an enterprise-grade distribution of Kyverno with long-term support for production users.
