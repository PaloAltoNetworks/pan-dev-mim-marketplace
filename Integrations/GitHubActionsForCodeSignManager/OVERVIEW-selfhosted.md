# GitHub Actions for Code Sign Manager

This integration brings Code Sign Manager into GitHub Actions workflows, letting teams sign build artifacts such as JAR files and Windows executables directly from their CI/CD pipelines while private signing keys stay secured in Certificate Manager, Self-Hosted.

  

**SOLUTION HIGHLIGHTS**

- **Protect signing keys **Private code signing keys never leave Certificate Manager, Self-Hosted and are never exposed on GitHub runners or developer workstations.
- **Sign inside the pipeline **A setup action configures the Code Sign Manager client so signing tools like jarsigner and signtool run directly within GitHub Actions jobs.
- **Enforce policy and audit **Central policy, role-based access, and a full audit trail capture who signed what, when, and with which key.

  

**SOLUTION OVERVIEW**

The integration provides a GitHub Action that downloads, caches, and configures the Code Sign Manager client on GitHub-hosted or self-hosted runners. Once configured, pipeline jobs invoke standard signing utilities such as jarsigner and signtool, which broker each signing request back to Certificate Manager, Self-Hosted to perform the operation using centrally managed keys and certificates. Developers sign code and other build outputs without needing deep PKI knowledge, while security teams retain control over key usage, approval workflows, and auditability across the software supply chain. For higher-security requirements, self-hosted runners are recommended over shared GitHub-hosted infrastructure.

**ABOUT CYBERARK**

Code Sign Manager, formerly Venafi CodeSign Protect, secures the code signing process by keeping private keys in a protected, centrally managed store and brokering every signing request through enforced policy. It provides visibility, access control, and complete audit records for signing operations across development and DevOps toolchains.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
