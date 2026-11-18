# Google Cloud CA Service

Google Cloud Certificate Authority Service (CAS) lets you replace some or all of your existing PKI infrastructure with private CAs hosted in Google Cloud. Certificate Manager, Self-Hosted connects to Google Cloud CAS as a certificate authority, so certificates issued from your Google Cloud CA pools follow the same policies, workflows and automation as the rest of your machine identities.

There are no additional CA servers to deploy. Once the connection is configured, teams request certificates from Certificate Manager, Self-Hosted and receive them from Google Cloud CAS.

**Value Highlights**

- **Automate the full certificate lifecycle**: request, issue, renew and revoke Google Cloud CAS certificates without manual steps.
- **Gain full visibility**: track the demand, usage and workflow of certificate services in one inventory.
- **Reduce administrative burden and costs**: replace some or all of your on-premises PKI with Google Cloud-hosted private CAs.
- **Extend PKI to cloud workloads**: meet the certificate needs of cloud-based applications from the same policy framework.
- **Keep your roots where you want them**: keep root certificates in a local CA while issuing from Google Cloud CAS.

**How it Works**

Google Cloud CAS support is an in-product capability of Certificate Manager, Self-Hosted. You set up Google Cloud CAS to issue certificates and create a service account and key for its API. In Certificate Manager, Self-Hosted you store that key in a credential object, then create CA templates with the policies you need for each certificate use case. Certificates requested against those templates are issued by Google Cloud CAS and can then be provisioned to end systems through the wider integration ecosystem. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, Self-Hosted
- Google Cloud Certificate Authority Service

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
