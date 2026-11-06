# Certificate Management with GitLab DevSecOps Platform

This integration brings Venafi machine identity management directly into GitLab CI/CD pipelines, letting DevOps teams request, retrieve and renew TLS certificates as automated pipeline steps that stay compliant with policies enforced by Certificate Manager.

  

**SOLUTION HIGHLIGHTS**

- **Eliminate hassle and inherent risks **associated with manually requesting and installing certificates in build and deployment pipelines
- **Stay secure **and automatically comply with certificate policies defined by information security teams and enforced by Venafi
- **Automate certificate operations **for Venafi authentication, certificate requests, retrieval and renewal, defined as jobs in your GitLab CI YAML
- **Empower developers **to consume trusted machine identities without needing deep PKI or certificate management expertise

  

**SOLUTION OVERVIEW**

Built on Venafi’s vCert tooling, the integration adds operations to GitLab CI/CD that connect to Certificate Manager to request, download and renew certificates. Jobs can run through a provided Docker image on Docker executors, or via the Python-based integration package installed on shell and SSH executors. Because every request flows through Venafi, security teams gain centralized policy enforcement, visibility and a full audit trail of certificate operations initiated from the pipeline, shifting certificate security left into the software delivery process.

**ABOUT QENSUS**

Qensus is a specialist services provider focused on DevSecOps and machine identity management. It develops and maintains the open source Venafi integrations for GitLab, helping organizations secure their software delivery pipelines by embedding certificate lifecycle management into GitLab CI/CD.

  

  

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
