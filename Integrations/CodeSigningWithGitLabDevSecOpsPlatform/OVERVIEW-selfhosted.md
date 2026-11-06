# Code Signing with GitLab DevSecOps Platform

This integration brings Venafi CodeSign Protect into GitLab CI/CD pipelines, letting teams sign build artifacts such as JAR files and Windows executables directly from their pipelines while private signing keys stay secured in Certificate Manager, Self-Hosted.

  

**SOLUTION HIGHLIGHTS**

- **Protect signing keys **Private code signing keys never leave Certificate Manager, Self-Hosted and are never exposed on build servers or developer workstations.
- **Sign inside the pipeline **Purpose-built container images run signing tools like jarsigner and signtool directly within GitLab jobs.
- **Enforce policy and audit **Central policy, role-based access, and a full audit trail capture who signed what, when, and with which key.

  

**SOLUTION OVERVIEW**

The integration is delivered as ready-to-use container images that GitLab CI/CD Docker executors pull to run Venafi signing commands as pipeline jobs. Each job points at the artifacts to sign and calls Venafi’s signing utilities, which connect back to Certificate Manager, Self-Hosted to perform the operation using centrally managed keys and certificates. Developers sign code and other build outputs without needing deep PKI knowledge, while security teams retain control over key usage, approval workflows, and auditability across the software supply chain.

**ABOUT VENAFI**

Venafi CodeSign Protect secures the code signing process by keeping private keys in a protected, centrally managed store and brokering every signing request through enforced policy. It provides visibility, access control, and complete audit records for signing operations across development and DevOps toolchains.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
