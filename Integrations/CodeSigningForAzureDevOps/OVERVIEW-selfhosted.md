# Code Signing for Azure DevOps

More teams now build in the cloud with Azure DevOps, but they lack an easy way to sign code consistently and with the approval and visibility of security teams. Sidechain's Microsoft Azure Pipelines agent for CodeSign Protect is a turnkey solution that brings code signing from Certificate Manager, Self-Hosted into Azure DevOps build processes without extra burden on developers.

**Value Highlights**

- **Remove custom integration work**: Avoid building and maintaining your own signing integrations in build pipelines.
- **Sign as a pipeline task**: Invoke code signing as an automated, one-step task in your Azure DevOps pipeline.
- **Start with a ready agent**: Use a build agent preconfigured with current CodeSign Protect clients and signing tools (jarsigner and SignTool).
- **Extend existing investments**: Bring Certificate Manager, Self-Hosted code signing to cloud-based builds.
- **Speed up delivery**: Modernize and accelerate your software development lifecycle.

**How it Works**

The Azure Pipelines agent runs signing as a task in the pipeline. The task calls CodeSign Protect in Certificate Manager, Self-Hosted, which applies signing policy and approvals while the private keys stay protected. The agent works with both Azure DevOps Services and on-premises Azure DevOps Server. Contact Sidechain for setup details.

**Solution Components**

- Certificate Manager, Self-Hosted with CodeSign Protect
- Azure DevOps Services or Azure DevOps Server
- Sidechain Azure Pipelines agent

**About Sidechain**

[Sidechain](https://sidechainsecurity.com/) is a data security firm focused on digital transformation. It built this agent through the Machine Identity Management Development Fund.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
