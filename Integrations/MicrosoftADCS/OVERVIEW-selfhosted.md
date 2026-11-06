# Microsoft ADCS

This integration is delivered as a Certificate Authority (CA) driver distributed with Certificate Manager, Self-Hosted. It enables Certificate Manager, Self-Hosted to initiate and auto-enroll new or to-be-renewed certificate and key generation requests from your internal enterprise or standalone Microsoft Active Directory Certificate Services (ADCS). All the resulted ADCS issued certificates are under the management of Certificate Manager. This provides your info security team the full visibility of all internally issued machine identities, prevents outages through the automation of certificate lifecycle management, detect misuses by enforcing enterprise machine identity policies.  
This integration comes with all releases of Certificate Manager, Self-Hosted It is also part of the TLS Protect Cloud offering. 
**Applicability**
Internally issued certificates using internal Certificate Authorities are used in a wide range of enterprise use cases. Many organizations use Microsoft ADCS, a built-in component of any Windows Server offering which has become a foundation of most established enterprise IT infrastructure, as the internal CA.  
This integration works for all deployments of MS ADCS in any type of infrastructures, being it cloud or in the datacenter. 
**Limitations and special notes**
It supports Enterprise or Standalone CA running on Windows Server 2003-2012, 2016, 2019, and 2022.
**ADDITIONAL RESOURCES**
A full list of Certificate Manager, Self-Hosted supported drivers: [https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/r-drivers-SysReq-supportedIntegrations.php](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/r-drivers-SysReq-supportedIntegrations.php)
**Get it to work (solution in action)**
The Microsoft CA driver is distributed with Certificate Manager, Self-Hosted. There’s no installation required. All you need to do is follow the documentation which provides the step-by-step configuration instructions to get it working. 
This capability comes as part of the TLS Protect Cloud offering. The SaaS product offers clear and self-explanatory instructions for a successful configuration to enable the capability to connect your MS Active Directory Certificates Service in your infrastructure. 
**Example usage**
The enabling of this integration is through a configuration of a “CA Template Object”. A detailed example of “Configuring the Microsoft template object” within Certificate Manager, Self-Hosted is provided in the documentation. 
**ABOUT Venafi**
Venafi is the cybersecurity market leader in machine identity management, securing the cryptographic keys and digital certificates on which every business and government depends to deliver safe machine-to-machine communication. Organizations use Venafi key and certificate security to protect communications, commerce, critical systems and data, and mobile and user access.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
