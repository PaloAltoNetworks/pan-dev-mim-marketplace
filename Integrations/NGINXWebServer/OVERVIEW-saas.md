# NGINX Web Server

This integration is delivered as an in-product capability to Certificate Manager, Self-Hosted. To enable it, you only need to perform prescribed configurations within Certificate Manager, Self-Hosted with information related to your NGINX Web Server. It supports the management of PEM files for NGINX web servers running on Linux or Windows by enabling you to provision the end-entity, chain, and private key to a single file (rather than two or three separate files).
This extension of the automation and policy-compliant machine identity management on to NGINX web servers that are hosting the critical services, applications, and content of your web infrastructure effectively rid the outages caused by expired or misconfigured certificates which are one of the major time-consuming, expensive, and even job-threatening challenges. 
It comes with all releases of Certificate Manager, Self-Hosted 18.3+.
**Applicability**
NGINX Web Server is the choice of web server for high-traffic websites and applications over the internet. NGINX offers enterprise customers a variety of deployment options, from on-premises installations to cloud-based solutions. It is a popular choice for enterprise customers looking for a reliable, fast, and scalable web server solution.
This integration works with both the open-source version of NGINX web server and the commercial version NGINX Plus in all types of deployments. 
**ADDITIONAL RESOURCES**
Securing Web Transactions: TLS Server Certificate Management. NIST Special Publication 1800-16: [https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-16.pdf](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1800-16.pdf)
**GETTING STARTED**
NGINX web server supports _.pem_ files which are concatenated certificate containers frequently used in storing certificates or a chain of certificates when multiple certificates that form a complete chain are being imported as a single file. Therefore, from Certificate Manager, Self-Hosted’s perspective, it is a PEM application object. The integration only requires a configuration of a PEM application object with specific information related to the NGINX web server deployment. 
You can find the details in the Venafi documentation titled “[Creating a PEM application object](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/r-PEM_AppObjSettings.php?)”.
**ABOUT Venafi**
Venafi is the cybersecurity market leader in machine identity management, securing the cryptographic keys and digital certificates on which every business and government depends to deliver safe machine-to-machine communication. Organizations use Venafi key and certificate security to protect communications, commerce, critical systems and data, and mobile and user access.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
