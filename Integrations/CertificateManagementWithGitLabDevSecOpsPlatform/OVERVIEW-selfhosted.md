# Certificate Management with GitLab DevSecOps Platform

Build and deployment pipelines need TLS certificates, and requesting and installing them by hand slows delivery and creates risk. This integration brings certificate management into GitLab CI/CD pipelines, so DevOps teams request, retrieve and renew TLS certificates as automated pipeline steps that comply with policies enforced by Certificate Manager, Self-Hosted.

**Value Highlights**

- **Remove manual certificate work**: Eliminate the effort and risk of requesting and installing certificates in build and deployment pipelines.
- **Comply with policy automatically**: Issue certificates that follow the policies security teams define in Certificate Manager, Self-Hosted.
- **Automate certificate operations**: Define authentication, certificate requests, retrieval and renewal as jobs in your GitLab CI YAML.
- **Empower developers**: Let developers use trusted certificates without deep PKI expertise.
- **Shift security left**: Give security teams policy enforcement, visibility and an audit trail of certificate operations started from pipelines.

**How it Works**

Built on VCert, the integration adds operations to GitLab CI/CD that connect to Certificate Manager, Self-Hosted to request, download and renew certificates. Jobs run through a provided Docker image on Docker executors, or through the Python-based integration package installed on shell and SSH executors. Every request flows through Certificate Manager, Self-Hosted, which applies policy and records the operation.

**Solution Components**

- Certificate Manager, Self-Hosted
- GitLab CI/CD
- Qensus GitLab integration (Docker image or Python package)

**About Qensus**

[Qensus](https://qensus.com/) is a services provider focused on DevSecOps and machine identity management. It develops and maintains the open source integrations for GitLab that embed certificate lifecycle management into GitLab CI/CD.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
