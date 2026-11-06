# Actalis SSL

This solution is an Adaptable CA Driver that allows you to obtain and manage Actalis SSL Certificates from Venafi's Certificate Manager, Self-Hosted.

  

All classes (i.e. validation levels, such as DV, OV, EV, QWAC) and types of SSL certificates (single-domain, multi-domain, wildcard) are supported, depending on your contract with Actalis. Both RSA and ECC keys are allowed. Needless to say, Actalis' SSL certificates are trusted by all major operating systems, browsers, and run-time environments (such as Java, Python, Node.js, .NET/Mono, etc.).

  

**SOLUTION HIGHLIGHTS**

- **Adaptable CA Driver **developed and supported by **Actalis S.p.A.**
- **Support **of **all SSL certificate classes **(DV, OV, EV, QWAC)
- **Support **of **all SSL certificate types **(single-domain, multi-domain, wildcard)
- **Leverages **pre-validation (whitelisting) of organizations and domains

  

The Venafi + Actalis combined solution allows you to enjoy the benefits offered by both providers. Thanks to the possibility of managing your Actalis certificates through the TSL Protect platform, you can benefit from the remarkable functions offered by this platform, such as automatic renewals, configurable workflows, certificate installation validation, etc. At the same time, Actalis also ensures: convenient prices without any compromise on security and trust, efficient and professional support, flexibility, compliance with EU data protection laws and the eIDAS regulation, human customer service instead of chatbots, and more.

  

**WHO WILL BENEFIT**

Any type of organization, public or private, can benefit from this solution, although organizations that need to manage a large number of certificates could benefit the most. This includes organizations with a global presence, organizations that use many cloud-based applications, and organizations subject to strict compliance regulations.

  

**SPECIAL NOTES & LIMITATIONS**

In order to use this driver, you must first sign a contract with Actalis for SSL certificates. After which, Actalis will carry out the necessary checks and provide you with the "Certificate Credential" that is necessary to complete the driver's configuration in TLS Protect.

  

Next, you must pass Domain Control Validation (DCV) for all domains you wish to include in your SSL certificates, in compliance with browser policies and CAB Forum regulations. The Actalis team will assist you with the DCV process, or you may prefer to do it yourself through the Actalis Enterprise RA portal, to which you will be enabled upon request.

  

It should be noted that organization-validated certificates (such as OV, EV, QW) can only be requested for organizations that have been verified by Actalis as affiliated to the Customer. This constraint does not apply to domain-validated certificates (DV).

  

The number of Actalis certificates you will be able to obtain will depend on your contract with Actalis which determines your initial credit. When the initial credit is about to run out, or at any time, you can ask for a "top-up" from Actalis.

  

**ADDITIONAL RESOURCES**

- Contact Actalis: [https://www.actalis.com/contact-us.aspx](https://www.actalis.com/contact-us.aspx)
- Actalis SSL Certificates documentation: [https://www.actalis.com/ssl-certificates.aspx](https://www.actalis.com/ssl-certificates.aspx)
- Actalis Certification Practice Statement (CPS): [https://www.actalis.it/documenti-en/cps_for_ssl_server_and_code_signing_en.aspx](https://www.actalis.it/documenti-en/cps_for_ssl_server_and_code_signing_en.aspx)

  

**SET UP THE SOLUTION**

Follow these steps:

- Copy the Powershell script to a suitable folder on the TLS Protect server
- Copy your Certificate Credential (see Special notes and limitations) to the TLS Protect server
- From Certificate Manager, Self-Hosted:
- Create and configure the necessary Custom Fields (Configuration > Custom Fields)
- Create and configure a CA Template for Actalis (Configuration > CA Templates)
- Associate the Actalis CA Template to a Certificate Folder of your choice (Configuration > Folders)

  

At this point you can start requesting Actalis SSL certificates.

See also the detailed instructions in the provided support documentation.

  

**USAGE EXAMPLE**

From TLS Protect, you can obtain an Actalis SSL certificate as follows:

- From the Certificates Inventory, click on "Create a New Certificate"
- In the "Create New Certificate" dialog window, select the Actalis certificate folder (step 3.c above)
- Enter the request data according to your needs, such as the certificate class, domains, organization, etc.
- Submit the request and you will obtain your certificate in a matter of seconds, unless request errors occur.

  

Subsequent life-cycle management operations (e.g. renewal, revocation, etc.) are done in the usual way from TLS Protect.

  

**ABOUT ACTALIS**

Actalis S.p.A., established in 2002 and an accredited Certification Authority ever since, provides a wide range of eIDAS-compliant qualified trust services and is internationally recognized for issuing trusted SSL certificates of all kinds. One of the leading CAs in Europe and in the top 10 global CAs for SSL certificates (according to W3Techs), Actalis customers include Italian government agencies as well as global private companies in all sectors and of all sizes. Since 2009 has been part of the Aruba Group, the Italian leader in data center, cloud, web hosting, email, and domain name registration services. For more information go to [www.actalis.com](http://www.actalis.com).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
