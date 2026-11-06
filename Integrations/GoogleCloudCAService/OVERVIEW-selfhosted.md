# Google Cloud CA Service

With its cloud-based PKI solution, Google Cloud enables you to replace some or all of their existing PKI infrastructure with Google Cloud-hosted private CAs. The relative simplicity of a Cloud solution combined with the power of [Certificate Manager](https://venafi.com/control-plane/) makes system outage prevention easier and simpler.
**TECHNOLOGY COMPONENTS**
Certificate Manager, Self-Hosted, Google Cloud CA Service
**VALUE HIGHLIGHTS**
- **Automate the full certificate lifecycle** from issuance to revocation
- **Gain full visibility** into the demand, usage and workflow of certificate services
- **Reduce administrative burden and costs** by replacing some or all of your existing PKI infrastructure with Google Cloud-hosted private CAs
- **Supports full lifecycle** from request, issuance and renewal to revocation
- **Easily extends PKI to cloud services** to meet certificate needs of cloud-based workloads
When you use Google Cloud CA Service with Certificate Manager, Self-Hosted, you can simplify your enterprise PKI strategy. There's no need to deploy additional servers; once configuration is complete, simply request a new certificate.
As a PKI operator, you'll have a much simpler way to revoke trust by steering away the cumbersome process of extracting certificates from certificate authorities (CAs) in your network. To ensure higher lever of security, you can keep your root certificates in a local CA.
A key benefit of using Google Cloud CAS with the Certificate Manager is the out-of-the-box automation with the entire Venafi Ecosystem where integrations with hundreds of technologies that provide, consume, or orchestrate machine identities are provided. These solutions help your organization use tools you are familiar with, such as application developers being able to request certificates through cert-manager, while ensuring those certificates come from trusted providers like Google Cloud CAS and adhere to your organization’s security policies. It also enables those machine identities to be automatically installed and configured on end systems without any human intervention. 
**Make it Work**
This solution is an in-product capability within Certificate Manager, Self-Hosted. It only takes a few configuration steps. 
1. Set up Google Cloud CAS to issue certificates, create a service account to authenticate and use the Google Cloud CAS API, and create a key to authenticate to the API.
2. In the Certificate Manager, Self-Hosted, create an object to store the key, then create CA templates with different policies for different use cases for certificates issued by Google Cloud CAS.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
