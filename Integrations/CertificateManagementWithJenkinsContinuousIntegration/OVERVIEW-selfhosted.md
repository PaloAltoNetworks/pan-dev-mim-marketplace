# Certificate Management with Jenkins Continuous Integration

Security teams must know what to trust at all times, and in fast-moving DevOps environments that means policy enforcement has to be automated inside the tools developers already use. This open source Jenkins plugin, built by Qensus in collaboration with CloudBees, lets Jenkins pipelines request certificates from Certificate Manager, Self-Hosted in a standard way, so certificates in CI/CD follow your policies.

**Value Highlights**

- **Give security teams visibility**: See and control the certificates that protect applications built in Jenkins.
- **Serve application teams automatically**: Let application and operations teams get certificates inside the tools they use every day.
- **Automate issuance in pipelines**: Request certificates and private keys as build steps or pipeline functions.
- **Shift security left**: Apply certificate policy in pre-production, before applications reach production.
- **Stay crypto-agile**: Use the certificate authorities connected to Certificate Manager, Self-Hosted without changing pipelines.

**How it Works**

The plugin uses the VCert library to connect Jenkins to Certificate Manager, Self-Hosted. You configure the connection once in the Jenkins system settings, then use the request certificate operation in freestyle projects or pipelines. Each request names a zone, and the certificate, chain and private key are written to files in PEM format for later build steps. See the plugin documentation on the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Jenkins
- [Venafi Machine Identity Management plugin for Jenkins](https://plugins.jenkins.io/venafi-vcert/)

**About Qensus**

[Qensus](https://qensus.com/) is a services provider focused on DevSecOps and machine identity management, and develops open source integrations that bring certificate management into CI/CD tools.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
