# Code Signing with Jenkins Continuous Integration

This open source Jenkins plugin lets Venafi customers embed CodeSign Protect signing and verification directly into their Jenkins CI/CD pipelines, so build artifacts are signed with keys that remain secured and governed by Venafi’s Certificate Manager, Self-Hosted.

  

**SOLUTION HIGHLIGHTS**

- **Secure **signing keys stay protected in Venafi CodeSign Protect (optionally backed by an HSM), separate from the build infrastructure
- **Automate **signing and verification as native build steps in both Freestyle and Pipeline projects
- **Support **for common signing tools including Jarsigner for Java artifacts and Signtool for Windows binaries

  

**SOLUTION OVERVIEW**

The plugin adds Venafi Code Signing build steps and pipeline functions (such as `venafiCodeSignWithJarSigner` and `venafiCodeSignWithSignTool`) that invoke the CodeSign Protect client tools installed on the Jenkins nodes. Administrators register one or more Certificate Manager, Self-Hosted environments under Manage Jenkins, and jobs then sign and verify artifacts against those environments during the build and release process. Because private keys never leave CodeSign Protect, security teams retain policy control, access enforcement, and visibility into key usage while developers keep an automated, hands-off signing workflow.

**ABOUT QENSUS**

Qensus is a Venafi partner that develops and supports integrations connecting Venafi machine identity and code signing capabilities with DevOps tooling such as Jenkins. This plugin is distributed as free, open source software through the Jenkins plugin ecosystem.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
