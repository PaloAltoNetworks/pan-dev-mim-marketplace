# SAP Secure Login Server

This integration is an exclusive capability delivered as in-product features by both Venafi Certificate Manager, Self-Hosted and SAP Secure Login Server (SLS), part of SAP Single Sign-On (SSO). It enables Venafi to act as a remote CA to provision and manage certificates to SAP systems. Certificate Manager of which Certificate Manager, Self-Hosted is a module provides auto-renewal, policy governance and a suite of capabilities to ensure zero outages resulted from machine identities managed by Venafi and improved productivity of certificate management team in your organization. This integration does not require any additional software download or installation. Proper configuration following instructions provided is all you need. 

  

Remote CA support is available with SAP SSO 3.0 and higher. Certificate Manager, Self-Hosted 21.3 support the integration with Secure Login Server 3.0 SP02 PL10 (this patch has the fix that enables the support for Venafi as the Remote CA) and above. 

  

**Who can benefit**

Any organizations with SAP systems should consider this integration and Certificate Manager to automate all machine identities used by SAP systems to enable efficiency and productivity and prevent any outages caused by expired certificates. 

  

**Additional resources**

- A quick intro into SAP Single Sign On 3.0: [https://blogs.sap.com/2021/03/10/a-quick-intro-into-sap-single-sign-on-3.0/](https://blogs.sap.com/2021/03/10/a-quick-intro-into-sap-single-sign-on-3.0/)
- SAP Single Sign-On 3.0 SP01 – Secure Login Server with Enterprise PKI: [https://blogs.sap.com/2016/07/04/sap-single-sign-on-30-secure-login-server-with-enterprise-pki/](https://blogs.sap.com/2016/07/04/sap-single-sign-on-30-secure-login-server-with-enterprise-pki/)
- SAP: Configure Certificate Lifecycle Management: [https://blogs.sap.com/2020/07/09/configuring-certificate-lifecycle-management/](https://blogs.sap.com/2020/07/09/configuring-certificate-lifecycle-management/)
- SAP internal support (requires access to SAP knowledge base): [https://launchpad.support.sap.com/#/notes/2375797](https://launchpad.support.sap.com/#/notes/2375797)
- SAP released note with support for Venafi : [https://launchpad.support.sap.com/#/notes/3086237](https://urldefense.com/v3/__https:/launchpad.support.sap.com/*/notes/3086237__;Iw!!NgSi4SaN6ydtRVQ-!ihygJp7Uqd49oAcgxMKu0RDPt6GA7uqh6WJkxOwouJ0gFEpeUA8NqFkogcSh4rMS$)

  

**Get it to work **

You can find the detailed instructions in provided support documentation. This integration only requires proper configuration between the two solutions. The high-level steps are:

- Create a new user identity in Certificate Manager, Self-Hosted. This user identity will be allowed to request certificates after HTTP authentication. 
- Create password credential for Challenge Password in Certificate Manager, Self-Hosted. 
- Configure SAP Interface in Certificate Manager, Self-Hosted. 
- Configure SAP Secure Login Server (SLS). 

  

Note: Venafi Client Protect is part of Venafi Certificate Manager (Certificate Manager) which has been renamed to Certificate Manager, Self-Hosted. 

  

**About SAP**

As the market leader in enterprise application software, we’re helping companies of all sizes and in all industries run better by redefining ERP and creating networks of intelligent enterprises that provide transparency, resiliency, and sustainability across supply chains. Our end-to-end suite of applications and services enables our customers to operate profitably, adapt continuously, and make a difference worldwide.

  

With the introduction of its original SAP R/2 and SAP R/3 software, SAP established the global standard for [enterprise resource planning (ERP) software.](https://www.sap.com/products/erp/what-is-erp.html) Now, [SAP S/4HANA](https://www.sap.com/products/erp/s4hana.html) takes ERP to the next level by using the power of in-memory computing to process vast amounts of data, and to support advanced technologies such as artificial intelligence (AI) and machine learning.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
