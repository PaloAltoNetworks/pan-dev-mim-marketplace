# Microsoft IIS

This integration is delivered as an in-product capability to Certificate Manager, Self-Hosted. To enable it, you only need to perform prescribed configurations within Certificate Manager, Self-Hosted with information related to your Microsoft IIS servers. 
Microsoft IIS servers leverages the CAPI, a Microsoft technology for storing certificates and private keys in a Windows environment.  This integration supports the provisioning of certificates that use elliptic curve cryptography (ECC) keys using central or remote generation. Following provisioning, certificates and keys are extracted and, if using remote generation, download certificates and keys in all supported certificate store formats.
This extension of the automation and policy-compliant machine identity management on to Microsoft IIS web servers that are hosting the critical services, applications, and content of your web infrastructure effectively rid the outages caused by expired or misconfigured certificates which are one of the major time-consuming, expensive, and even job-threatening challenges. 
It comes with all releases of Certificate Manager, Self-Hosted 18.3+. It is also part of the Next-Gen Trust Security offering.
**Applicability**
When it comes to Web Servers, Microsoft IIS a natural choice for enterprises that are heavily invested in the Microsoft technology stack due to its deep integration with the Windows operating system and other Microsoft technologies, such as .NET Framework and ASP.NET. 
Microsoft IIS can be deployed in a variety of ways depending on your specific needs and requirements including on-premises, in public and private cloud environments such as Microsoft Azure, AWS, and GPC, be deployed as a containerized application using Docker or Kubernetes, in hybrid environments. 
This integration works with Microsoft IIS 7.0 and later for Certificate Manager, Self-Hosted. 
**ADDITIONAL RESOURCES**
Securing Web Transactions: TLS Server Certificate Management. NIST Special Publication 1800-16: [https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-16.pdf](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-16.pdf)
**GETTING STARTED**
Microsoft IIS consumes certificates and private keys that are stored in a Windows CAPI store. Therefore, from Certificate Manager, Self-Hosted’s perspective, IIS is a CAPI application object. The integration only requires a configuration of a CAPI application object with specific information related to the Microsoft IIS web server deployment. 
For Certificate Manager, Self-Hosted, you can find the details in the Venafi documentation titled “[Creating a CAPI application object”.](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/r-CAPI-AppObjSettings-tpp.php)
For Next-Gen Trust Security, you should follow the configuration instructions here:  [https://docs.venafi.cloud/vaas/machines/create-a-new-machine/#\_\_tabbed\_1\_2](https://docs.venafi.cloud/vaas/machines/create-a-new-machine/#__tabbed_1_2)
**ABOUT Venafi**
Venafi is the cybersecurity market leader in machine identity management, securing the cryptographic keys and digital certificates on which every business and government depends to deliver safe machine-to-machine communication. Organizations use Venafi key and certificate security to protect communications, commerce, critical systems and data, and mobile and user access.
