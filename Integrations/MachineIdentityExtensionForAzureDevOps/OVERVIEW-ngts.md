# Machine Identity Extension for Azure DevOps

Slow, ad-hoc certificate processes push developers to get certificates for development, testing and deployment through shadow channels, which leaves the security team blind to those certificates. The Machine Identity Extension for Azure DevOps lets DevOps teams generate keys and enroll certificates from Next-Gen Trust Security inside their pipelines, so they get policy-compliant certificates quickly without needing to know how the security team runs certificate management.

**Value Highlights**

- **Remove blind spots**: Certificates requested from pipelines are visible to the security team in Next-Gen Trust Security.
- **Comply by default**: Every certificate follows the enterprise security policy set in Next-Gen Trust Security.
- **Keep developers moving**: Generate keys and enroll certificates with a pipeline task instead of a manual request.
- **Fit any Azure DevOps deployment**: Works with Azure DevOps Services and Azure DevOps Server.

**How it Works**

The extension is open-source software distributed through the Visual Studio Marketplace, and you install it in your Azure DevOps organization or server. It adds a pipeline task that uses the VCert CLI to generate keys and request certificates. The task authenticates to Next-Gen Trust Security with the credentials your security team provides. See the Documentation tab for usage.

**Solution Components**

- Next-Gen Trust Security
- Azure DevOps Services or Azure DevOps Server
- [Machine Identity Extension](https://marketplace.visualstudio.com/items?itemName=GregBrownstein.MachineIdentityExtension) ([source on GitHub](https://github.com/gdbarron/MachineIdentityExtension))
