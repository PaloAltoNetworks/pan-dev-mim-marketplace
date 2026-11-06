# Integration README

The purpose of this document is to provide information regarding the configuration of the `Barracuda Web Application Firewall` for integration with Venafi Trust Protection Platform (TPP).

The information provided in this document is considered proprietary and confidential.

#### **TERMS OF USE**

This integration guide, as well as the software and/or products described in it, are furnished under agreement with `Barracuda Networks` and may be used only in accordance with the terms of such agreement. Except as permitted by such agreement, no part of this publication may be reproduced, stored in a retrieval system, or transmitted, in any form or by any means, electronic, mechanical, recording, or otherwise, without prior written permission of Barracuda Networks.

## TABLE OF CONTENTS

- [About Us](#about-us)
- [Integration with Venafi](#integration-with-venafi)
- [Prerequisites](#prerequisites)
- [Installation and Configuration](#installation-and-configuration)
    - [Barracuda WAF Integration with Venafi TPP](#Barracuda-WAF-Integration-with-Venafi-TPP)
    - [Configuring the Barracuda WAF with Access Credentials to Perform the API Operation](#Configuring-the-Barracuda-WAF-with-Access-Credentials-to-Perform-the-API-Operation)
    - [Setting-up-Barracuda-WAF-Connections-Details-and-Credentials-on-Venafi-TPP](#Setting-up-Barracuda-WAF–connections-details-and-credentials-on-venafi-TPP)
    - [Provisioning New SSL/TLS Certificates](#provisioning-new-SSL/TLS-certificates)
- [Usage](#usage)
    - [Discovering SSL/TLS Certificates on Barracuda WAF](#Discovering-SSL/TLS-Certificates-on-Barracuda-WAF)
    - [Automatic Renewal of SSL/TLS Certificates](#Automatic-Renewal-of-SSL/TLS-Certificates)
- [Troubleshooting](#troubleshooting)
    - [Error Messages](#error-messages)
    - [Limitations](#Limitations)
- [Appendix A - Partner Contact Information](#appendix-a-partner-contact-information)

## About Us

Barracuda Networks is the worldwide leader in Security, Application Delivery and Data Protection Solutions.
Having secured thousands of production applications against more than 11 billion attacks since 2008, the Barracuda Web Application Firewall is the ideal solution for organizations looking to protect web applications from data breaches and defacement. With the Barracuda Web Application Firewall, administrators do not need to wait for clean code or even know how an application works to secure their applications. Organizations can ensure robust security with a Barracuda Web Application Firewall hardware or virtual appliance, deployed either on-premises or in the cloud.


## Integration with Venafi

Venafi’s Trust Protection Platform integrates with the Barracuda Web Application Firewall for the purposes of SSL/TLS Certificates lifecycle Management. The primary benefit of this is to centrally manage the lifecyle of SSL/TLS certificates of an organization.

## Prerequisites

Before following the steps in this integration guide, the following prerequisite items must be installed and configured:

- PowerShell 3.0 or Later
- Venafi Trust Protection Platform Version 21.1
- Barracuda Web Application Firewall (WAF) Firmware Version 10.1.1 and Later
- Create Barracuda Account Credentials
- Create a Policy folder for the Barracuda WAF Device(s) 
- Create a Policy folder for the discovered Barracuda Certificates

## Installation and Configuration

### Barracuda WAF Integration with Venafi TPP

To enable Trust Protection Platform integration, the following must be completed:

1. Configuring the Barracuda WAF with Access Credentials to perform the API Operation
2. Setting up the Barracuda WAF connections details and credentials on the Venafi TPP

### Configuring the Barracuda WAF with Access Credentials to Perform the API Operation

On the Barracuda Web Application Firewall web interface, create a custom administrator role and do the following configuration:

1. Go to the **ADVANCED > Admin Access Control** page, **Administrator Roles** section and click **Add Administrator Role**.
2. On the **Add Administrator Role** window:
   1. Specify a role name.
   2. Select the services that need certificate management under **Services**.
   3. Set **API Privilege** to **Yes** under **API Privilege**.
   4. In the **Web Interface Privileges** section, select the **BASIC** (Primary Tab) and **Certificates** (Secondary Tab) **Read** and **Write** checkboxes, and ensure that all other checkboxes are disabled/cleared. 
   5. Click **Create Role**.
3. On the **ADVANCED > Admin Access Control** page, use the **Administrator Accounts** or **External Authentication Services** section to add a local administrator or an LDAP/RADIUS authentication service. Associate the custom role created in **Step 2** with the local administrator or the authentication service that you create. For more information on creating users, refer to the **Create Users** section on the [Role-Based Administration (RBA)](https://campus.barracuda.com/doc/4259970/) article.

To view the screenshots on how to configure the Barracuda WAF with Access Credentials to Perform the API Operation, refer to the [Barracuda Web Application Firewall Integration with Venafi](https://campus.barracuda.com/doc/96766281/) article.

### Setting Up Barracuda WAF Connections Details and Credentials on Venafi TPP

Perform the following steps to setup the Barracuda WAF on Venafi TPP:

1. Log in to the Venafi Trust Protection Platform (TPP).
2. On the Venafi WebAdmin, open the **Policy** Tree and add a new Policy folder for the Barracuda devices.
3. On the newly added policy page:
   1. Select **Applications** and do the following configuration under **Adaptable**:
      1. Select the **Application Credential path** and provide the **Port** number under **Application Information**. 

      > Port number should be 8443 for the cloud instance, 443 for the Hardware. If there is any specific port number for the device, provide the port details.

      2. Under **Adaptable Settings**, select **Barracuda-Waf** as the adaptable driver from the **PowerShell Script** drop-down list.

      3. Specify values for other parameters as required and click **Save**.

   2. Select **Settings > Certificates** and do the following configuration:
      1. Set the **Management Type** as **Provisioning** and **Managed By** as **Aperture**.

      2. Specify values for other parameters as required and click **Save**.

4. Right-click on the policy you created and select **Add > Credential > Username Credential**.
5. On the **Add New : Username Credential** page:
   1. Add the credentials (**User Name** and **Password**) of the administrator that you created in **step 3** under **Configuring the Barracuda WAF with Access Credential to Perform the API Operation**.
   2. Specify values for other parameters as required and click **Save**.
6. Right-click on the policy you created and select **Add > Devices > Device**.
7. On the **Add New : Device** page, add the device details such as Device name, IP address, credential, etc., click **Save**.

### Provisioning New SSL/TLS Certificates

1. On the Venafi TPP WebAdmin, open the Policy tree.
2. Right click on the policy that you created and select **Add > Certificates > Server Certificate**.
3. On the **Add New : Server Certificate** page, specify the certificate details and click **Save**.
4. After the certificate is added successfully, click **Associations** on the certificate page.
5. Click **Add** and select the application(s) to which you want to associate the certificate.
6. Click **Push** to push the certificate to the selected applications.

## Usage

This section provides information on how to properly use the integration after the initial configuration is complete. 

### Discovering SSL/TLS Certificates on Barracuda WAF

1. On the Venafi Aperture page, use the menu option and select **Jobs**.
2. Click **Create New Job**.
3. On the **Create New Job** page, select **Onboard Discovery** and click **Start**.
4. On the **New Onboard Discovery Job** page, configure the following:

- Details:

  1. Specify the job details and select **Adaptable** as the **Installation Type**.
  2. Select the **Enable Debug Logging** checkbox.
  3. Click **Next**.

- Targets:

  1. Specify the device that needs be discovered/scanned or select the folder to discover/scan all devices located in the folder. If you want to add a new device or add a new device and new credentials, select **Create New Devices**.
  2. Click **Next**.

- Placement Rules: 

  1. Select the location where you want to save the discovered certificates.

- Occurrence: 

  1. Set the **Frequency** to **Manually**. 
  2. Click **Create Job**.

5. Select the job you created and click **Run Now**.
6. After the successful discovery, all applications available on the Barracuda WAF along with the associated certificate objects will be visible on the Venafi TPP.

### Automatic Renewal of SSL/TLS Certificates

1. By default, the auto-renewal window for created and discovered certificates is set to 30 days prior to expiration. 
2. Choose the CA template that can be used while performing the renewal of the certificate.
3. At the renewal time, Venafi TPP generates the new key and gets CSR signed from the specified CA.
4. After the certificate is renewed, it is installed on devices and then associated with the applications.

## Troubleshooting

### Error Messages

When troubleshooting error messages, providing the entire message displayed by Trust Protection Platform can speed the diagnosis and resolution.

|Response Error Code | Error Message | Description |
| ---                | ---           | ---         |
| 401 - Unauthorized  | Get-BarracudaWAFSession System.Net.WebException The remote server returned an error | Error is generated when the wrong user credential is configured. | 
| 404 - Not Found | The remote server returned an error. | Error is generated when the user does not have permission to perform the operation or the Object (application/certificate) is not available on the device. |
| 406 | "Duplicate certificate name is not allowed" | Error is generated when the same certificate is installed more than once. |
| 406 | "Certificate is bound to at least one of the Services" | Error is generated when there is an attempt to delete a certificate which is associated with another existing application. |

### Limitations

- Custom role with services access - With the "Custom" role, if new services are created, certificate related operations on the new services will fail as the account will not have the required permissions. When a new service is added, the role should be edited and the new service(s) should be selected for the role to function properly. 

    - Alternatively, the default "Admin" role can be used to get full privileges. 

- On Venafi TPP, the certificate lifecycle can be managed only for the RSA or ECDSA certificate(s) associated with the service(s).
- Only Created and Uploaded Server certificates associated with the service(s) are supported.
- Trusted (CA) Certificate(s) and Trusted Server Certificate(s) are NOT supported.
- Currently, SNI certificates associated with the services cannot be managed on Venafi TPP. 

## Appendix A - Barracuda Networks Contact Information

E-mail: wafsupport_team@barracuda.com