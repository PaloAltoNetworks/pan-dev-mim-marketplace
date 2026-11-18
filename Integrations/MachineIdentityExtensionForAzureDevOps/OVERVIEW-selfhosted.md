# Machine Identity Extension for Azure DevOps

Slow, ad-hoc certificate processes push developers to get certificates for development, testing and deployment through shadow channels, which leaves the security team blind to those certificates. The Machine Identity Extension for Azure DevOps lets DevOps teams generate keys and enroll certificates from Certificate Manager, Self-Hosted inside their pipelines, so they get policy-compliant certificates quickly without needing to know how the security team runs certificate management.

**Value Highlights**

- **Remove blind spots**: Certificates requested from pipelines are visible to the security team in Certificate Manager, Self-Hosted.
- **Comply by default**: Every certificate follows the enterprise security policy set in Certificate Manager, Self-Hosted.
- **Keep developers moving**: Generate keys and enroll certificates with a pipeline task instead of a manual request.
- **Fit any Azure DevOps deployment**: Works with Azure DevOps Services and Azure DevOps Server.

**How it Works**

The extension is open-source software distributed through the Visual Studio Marketplace, and you install it in your Azure DevOps organization or server. It adds a pipeline task that uses the VCert CLI to generate keys and request certificates. The task authenticates to Certificate Manager, Self-Hosted with an access token, which you can provide inline or obtain in an earlier pipeline step with the extension's **Get Token** action. See the Documentation tab for usage.

**Solution Components**

- Certificate Manager, Self-Hosted
- Azure DevOps Services or Azure DevOps Server
- [Machine Identity Extension](https://marketplace.visualstudio.com/items?itemName=GregBrownstein.MachineIdentityExtension) ([source on GitHub](https://github.com/gdbarron/MachineIdentityExtension))

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
