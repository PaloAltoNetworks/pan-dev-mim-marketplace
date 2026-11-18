# Octopus Deploy Step Templates

Applications, services and workloads need certificates to communicate securely, but provisioning them by hand across many deployment targets is slow and error-prone and does not fit automated release pipelines. The Octopus Deploy step templates let your deployment processes request and provision certificates from Certificate Manager, Self-Hosted, so certificates are issued under policy and delivered as part of each deployment.

**Value Highlights**

- **Automate provisioning**: Request the certificates your deployments need directly from Octopus Deploy step templates, without manual processes or extra tools.
- **Enforce policy compliance**: Certificates are issued through Certificate Manager, Self-Hosted, so they meet your organization's security requirements.
- **Keep certificates visible**: Every certificate a deployment uses is tracked in Certificate Manager, Self-Hosted.
- **Reduce outage risk**: Automated issuance and policy enforcement cut the chance of certificate-related outages.
- **Reuse certificates in Octopus**: Import issued certificates into the Octopus certificate store for later steps.

**How it Works**

The integration is a set of community step templates from the Octopus Deploy library that you add to your deployment processes in Octopus Cloud or a self-hosted Octopus Server. The steps authenticate to Certificate Manager, Self-Hosted with an OAuth token and call its REST API. Available step templates:

- [Generate OAuth Token](https://library.octopus.com/step-templates/7e6f7f03-260a-4b52-9377-66f1c69b77d8/actiontemplate-venafi-tpp-generate-oauth-token)
- [Revoke OAuth Token](https://library.octopus.com/step-templates/d3e20a46-8119-4f4f-9d6f-52c30bcc6c59/actiontemplate-venafi-tpp-revoke-oauth-token)
- [Create and Provision Certificate](https://library.octopus.com/step-templates/dd4dfa66-e632-4c6a-bae6-156a7a105023/actiontemplate-venafi-tpp-create-and-provision-certificate)
- [Export Certificate](https://library.octopus.com/step-templates/2417aab5-6d84-4e0d-bc86-b2255bd4028a/actiontemplate-venafi-tpp-export-certificate)
- [Import Certificate into Octopus](https://library.octopus.com/step-templates/e10820c2-ae6d-4030-8a8a-b73ed60a81fc/actiontemplate-venafi-tpp-import-certificate-into-octopus)
- [Find Certificate Details](https://library.octopus.com/step-templates/91ea41ae-5b12-4854-8994-90c06ba4b7f1/actiontemplate-venafi-tpp-find-certificate-details)
- [Retrieve Certificate Details](https://library.octopus.com/step-templates/b893cae4-e280-4686-a60b-38da876528ec/actiontemplate-venafi-tpp-retrieve-certificate-details)

**Solution Components**

- Certificate Manager, Self-Hosted
- Octopus Cloud or a self-hosted Octopus Server

**About Octopus Deploy**

[Octopus Deploy](https://octopus.com/) is a deployment automation and release management platform.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
