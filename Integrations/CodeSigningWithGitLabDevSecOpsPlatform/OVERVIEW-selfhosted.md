# Code Signing with GitLab DevSecOps Platform

Signing build artifacts in CI/CD often means copying private keys onto build servers, where they are hard to protect and audit. This integration brings CodeSign Protect into GitLab CI/CD pipelines, so teams sign artifacts such as JAR files and Windows executables from their pipelines while private signing keys stay secured in Certificate Manager, Self-Hosted.

**Value Highlights**

- **Protect signing keys**: Keep private code signing keys in Certificate Manager, Self-Hosted, never on build servers or developer workstations.
- **Sign inside the pipeline**: Run signing tools such as jarsigner and signtool directly in GitLab jobs with purpose-built container images.
- **Enforce policy and audit**: Apply central policy and role-based access, and record who signed what, when and with which key.
- **Help developers move fast**: Let developers sign code without deep PKI knowledge.

**How it Works**

The integration is delivered as container images that GitLab CI/CD Docker executors pull to run signing commands as pipeline jobs. Each job points at the artifacts to sign and calls the CodeSign Protect signing utilities, which connect to Certificate Manager, Self-Hosted to sign with centrally managed keys and certificates. Security teams keep control of key usage, approval workflows and audit records across the software supply chain.

**Solution Components**

- Certificate Manager, Self-Hosted with CodeSign Protect
- GitLab CI/CD with Docker executors
- Qensus signing container images

**About Qensus**

[Qensus](https://qensus.com/) is a services provider focused on DevSecOps and machine identity management, and develops open source integrations for GitLab CI/CD.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
