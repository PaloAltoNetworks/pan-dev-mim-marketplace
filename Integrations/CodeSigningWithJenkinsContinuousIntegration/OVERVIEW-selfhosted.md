# Code Signing with Jenkins Continuous Integration

Build pipelines need to sign artifacts, but copying private signing keys onto build servers puts them at risk. This open source Jenkins plugin embeds CodeSign Protect signing and verification directly into Jenkins CI/CD pipelines, so build artifacts are signed with keys that stay secured and governed by Certificate Manager, Self-Hosted.

**Value Highlights**

- **Secure signing keys**: Keys stay protected in CodeSign Protect (optionally backed by an HSM), separate from the build infrastructure.
- **Automate signing and verification**: Run them as native build steps in both Freestyle and Pipeline projects.
- **Use common signing tools**: Sign Java artifacts with Jarsigner and Windows binaries with Signtool.
- **Keep security in control**: Security teams retain policy control, access enforcement and visibility into key usage.
- **Keep developers moving**: Developers get an automated, hands-off signing workflow.

**How it Works**

The plugin adds Code Signing build steps and pipeline functions (such as `venafiCodeSignWithJarSigner` and `venafiCodeSignWithSignTool`) that invoke the CodeSign Protect client tools installed on the Jenkins nodes. Administrators register one or more Certificate Manager, Self-Hosted environments under **Manage Jenkins**, and jobs then sign and verify artifacts against those environments during the build and release process. Private keys never leave CodeSign Protect.

**Solution Components**

- Certificate Manager, Self-Hosted with CodeSign Protect
- Jenkins, with the CodeSign Protect client tools installed on the build nodes

**About Qensus**

[Qensus](https://qensus.com) develops and supports integrations that connect machine identity and code signing capabilities with DevOps tooling such as Jenkins. This plugin is distributed as free, open source software through the Jenkins plugin ecosystem.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
