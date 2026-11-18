# GitHub Actions for Code Sign Manager

This integration brings Code Sign Manager into GitHub Actions workflows. Teams can sign build artifacts such as JAR files and Windows executables directly from their CI/CD pipelines, while private signing keys stay secured in Certificate Manager, Self-Hosted.

Code Sign Manager keeps private keys in a protected, centrally managed store and brokers every signing request through enforced policy. Developers sign code without deep PKI knowledge, and security teams keep control over key usage, approval workflows and auditability across the software supply chain.

**Value Highlights**

- **Protect signing keys**: private code signing keys never leave Certificate Manager, Self-Hosted and are never exposed on GitHub runners or developer workstations.
- **Sign inside the pipeline**: a setup action configures the Code Sign Manager client so tools like jarsigner and signtool run directly in GitHub Actions jobs.
- **Enforce policy and audit**: central policy, role-based access and a full audit trail record who signed what, when and with which key.
- **Keep developers moving**: standard signing utilities work as usual, with no keys to handle.

**How it Works**

A GitHub Action downloads, caches and configures the Code Sign Manager client on GitHub-hosted or self-hosted runners. Pipeline jobs then call standard signing utilities such as jarsigner and signtool, which send each signing request to Certificate Manager, Self-Hosted to be performed with centrally managed keys and certificates. For higher-security requirements, self-hosted runners are recommended over shared GitHub-hosted infrastructure.

**Solution Components**

- Certificate Manager, Self-Hosted with Code Sign Manager
- Code Sign Manager client
- GitHub Actions on GitHub-hosted or self-hosted runners

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
