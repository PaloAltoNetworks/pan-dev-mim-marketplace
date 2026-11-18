# Barracuda Web Application Firewall

This guide describes how to configure the Barracuda Web Application Firewall (WAF) for integration with Certificate Manager, Self-Hosted.

## Prerequisites

- PowerShell 3.0 or later.
- Certificate Manager, Self-Hosted 21.1 or later.
- Barracuda Web Application Firewall firmware 10.1.1 or later.
- Barracuda account credentials for the API, as described in [Configure Barracuda WAF API Access](#configure-barracuda-waf-api-access).
- A policy folder for the Barracuda WAF devices.
- A policy folder for the discovered Barracuda certificates.

## Configuration

To enable the integration, configure API access on the Barracuda WAF, and then set up the Barracuda WAF connection details and credentials in Certificate Manager, Self-Hosted.

### Configure Barracuda WAF API Access

On the Barracuda Web Application Firewall web interface, create a custom administrator role:

1. Go to **ADVANCED** > **Admin Access Control**. In the **Administrator Roles** section, click **Add Administrator Role**.
2. In the **Add Administrator Role** window:
   1. Specify a role name.
   2. Under **Services**, select the services that need certificate management.
   3. Under **API Privilege**, set **API Privilege** to **Yes**.
   4. In the **Web Interface Privileges** section, select the **Read** and **Write** checkboxes for **BASIC** (primary tab) and **Certificates** (secondary tab), and make sure all other checkboxes are cleared.
   5. Click **Create Role**.
3. On the **ADVANCED** > **Admin Access Control** page, use the **Administrator Accounts** or **External Authentication Services** section to add a local administrator or an LDAP/RADIUS authentication service. Associate the custom role from step 2 with it. For more information on creating users, see the **Create Users** section of the Role-Based Administration (RBA) article on Barracuda Campus.

For screenshots of these steps, see [Barracuda Web Application Firewall Integration with Venafi](https://campus.barracuda.com/doc/96766281/) on Barracuda Campus.

### Set Up the Barracuda WAF in Certificate Manager, Self-Hosted

1. Log in to Certificate Manager, Self-Hosted.
2. In WebAdmin, open the **Policy** tree and add a new policy folder for the Barracuda devices.
3. On the new policy page:
   1. Select **Applications**, and under **Adaptable**:
      1. Select the **Application Credential** path, and enter the **Port** under **Application Information**. Use port 8443 for the cloud instance and 443 for hardware, unless the device uses a specific port.
      2. Under **Adaptable Settings**, select **Barracuda-Waf** in the **PowerShell Script** list.
      3. Specify values for the other parameters as required, and click **Save**.
   2. Select **Settings** > **Certificates**:
      1. Set **Management Type** to **Provisioning** and **Managed By** to **Aperture**.
      2. Specify values for the other parameters as required, and click **Save**.
4. Right-click the policy and select **Add** > **Credential** > **Username Credential**.
5. On the **Add New : Username Credential** page:
   1. Enter the **User Name** and **Password** of the administrator you created in [Configure Barracuda WAF API Access](#configure-barracuda-waf-api-access).
   2. Specify values for the other parameters as required, and click **Save**.
6. Right-click the policy and select **Add** > **Devices** > **Device**.
7. On the **Add New : Device** page, enter the device details, such as the device name, IP address and credential, and click **Save**.

### Provision New TLS Certificates

1. In WebAdmin, open the **Policy** tree.
2. Right-click the policy and select **Add** > **Certificates** > **Server Certificate**.
3. On the **Add New : Server Certificate** page, specify the certificate details and click **Save**.
4. On the certificate page, click **Associations**.
5. Click **Add** and select the applications to associate with the certificate.
6. Click **Push** to push the certificate to the selected applications.

## Usage

### Discover TLS Certificates on Barracuda WAF

1. In the Certificate Manager, Self-Hosted web console (Aperture), open the menu and select **Jobs**.
2. Click **Create New Job**.
3. On the **Create New Job** page, select **Onboard Discovery** and click **Start**.
4. On the **New Onboard Discovery Job** page, configure the following:
   - **Details**: specify the job details, select **Adaptable** as the **Installation Type**, select **Enable Debug Logging**, and click **Next**.
   - **Targets**: specify the device to scan, or select the folder to scan all devices in it. To add a new device, or a new device and credentials, select **Create New Devices**. Click **Next**.
   - **Placement Rules**: select the location to save the discovered certificates.
   - **Occurrence**: set **Frequency** to **Manually**, and click **Create Job**.
5. Select the job and click **Run Now**.

After discovery completes, all applications on the Barracuda WAF and their associated certificates appear in Certificate Manager, Self-Hosted.

### Automatic Renewal of TLS Certificates

1. By default, the renewal window for created and discovered certificates is 30 days before expiration.
2. Choose the CA template to use when renewing the certificate.
3. At renewal time, Certificate Manager, Self-Hosted generates a new key and gets the CSR signed by the specified CA.
4. After the certificate is renewed, it is installed on the devices and associated with the applications.

## Troubleshooting

### Error Messages

When troubleshooting, include the entire error message displayed by Certificate Manager, Self-Hosted to speed up diagnosis.

| Response Error Code | Error Message | Description |
| --- | --- | --- |
| 401 - Unauthorized | Get-BarracudaWAFSession System.Net.WebException The remote server returned an error | The configured user credential is wrong. |
| 404 - Not Found | The remote server returned an error. | The user doesn't have permission to perform the operation, or the object (application or certificate) isn't on the device. |
| 406 | "Duplicate certificate name is not allowed" | The same certificate was installed more than once. |
| 406 | "Certificate is bound to at least one of the Services" | An attempt was made to delete a certificate that is associated with another application. |

### Limitations

- With a custom role, certificate operations on newly created services fail because the account doesn't have permission for them. When you add a service, edit the role and select the new service. Alternatively, use the default **Admin** role for full privileges.
- Certificate lifecycle can be managed only for RSA or ECDSA certificates associated with services.
- Only created and uploaded server certificates associated with services are supported.
- Trusted (CA) certificates and trusted server certificates are not supported.
- SNI certificates associated with services can't be managed in Certificate Manager, Self-Hosted.

## Barracuda Networks Contact Information

Email: wafsupport_team@barracuda.com

## Terms of Use

This integration guide, as well as the software and/or products described in it, are furnished under agreement with Barracuda Networks and may be used only in accordance with the terms of such agreement. Except as permitted by such agreement, no part of this publication may be reproduced, stored in a retrieval system, or transmitted, in any form or by any means, electronic, mechanical, recording, or otherwise, without prior written permission of Barracuda Networks.
