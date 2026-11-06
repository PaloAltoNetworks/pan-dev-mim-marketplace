# Akamai Application Driver — Installation and Usage Guide (v4.2.6)

## Introduction

The Akamai Adaptable Application Driver is a Certificate Manager, Self-Hosted (CMSH) driver that communicates with the Akamai Certificate Provisioning System (CPS) API to provision and discover certificates.

> **Note:** This solution has many facets to it. It is highly recommended to read this entire guide before continuing.

### Onboard Discovery

Onboard Discovery allows the user to import all the production certificates from the Akamai CPS into CMSH.

- Imports all production certificates.
- Discovers dual-stack RSA/ECC certificates provisioned to the Akamai CPS.
- Names the application `{cert CN} {ECC|RSA}`.
- Saves the discovered enrollment ID of the certificates to the application configuration field **Akamai EnrollmentID** for use during renewals.
- Saves the enrollment configuration information to the **Enrollment Template JSON** field of the application configuration.

### Provisioning

Provisioning allows the user to add and renew certificates from the CMSH console directly into Akamai.

- Adds new certificates, saving the new enrollment ID to **Akamai EnrollmentID** for use during renewals.
- Renews existing certificates.
- Updates the **Enrollment Template JSON**.

### Workflows

When provisioning a certificate to Akamai, there are several stages where a review of the certificate is requested in order to approve deployment to the Akamai network. By default, this driver automatically acknowledges the request so the deployment can continue. If a separate approval is required in CMSH before the acknowledgement is sent, two adaptable workflow scripts are included to facilitate this at stages 803 and 804.

## Assumptions and Constraints

### Constraints

1. The system will only work on certificates that are in the Akamai CPS as enrollments.
2. Discovery will only be done on certificates that are in the Akamai Production networks.
3. CMSH cannot have two certificates attached to the same application, so dual-stack certificates in Akamai are represented by two different certificates and applications in CMSH — one ECC and one RSA. It's recommended to rename the certificate once imported to clearly differentiate between the two, e.g.:
   - `certname.domain.com` → `certname.domain.com RSA`
   - `certname.domain.com - 1` → `certname.domain.com ECC`
4. When creating new dual-stack certificates manually, the new enrollment ID must be copied to the **Akamai EnrollmentID** field on the second application once the first is provisioned, so the second can find the first enrollment and successfully complete provisioning to the dual-stack configuration.

### Assumptions

1. The customer must have a valid Akamai account and must be able to obtain an API token with CPS management rights.
2. The CMSH servers must be able to communicate with Akamai servers.
3. All certificates must be configured to use **Generate Key/CSR on Application**, as Akamai generates both the CSR and private key.

## Installation

The driver is delivered in a compressed ZIP file that contains all scripts and documentation.

1. Copy `AkamaiApplicationDriver.ps1` and the `AkamaiApplicationDriver` folder to `<CMSH installation folder>\Scripts\AdaptableApp` on all CMSH servers.
2. To use the optional adaptable workflow scripts, copy all files beginning with `AkamaiWorkflow` to `<CMSH installation folder>\Scripts\AdaptableWorkflow` on all CMSH servers.
3. Open an admin PowerShell prompt and run:

   ```powershell
   Get-ChildItem -Path '<CMSH installation folder>\Scripts' -Recurse | Unblock-File
   ```

## Overview of Application

The Akamai Adaptable Application Driver supports the Onboard Discovery feature of the application driver. The driver logs into the Akamai API system and queries the Akamai Production network for installed certificates. It processes the returned JSON from the Akamai API and creates applications and certificates that match those installed on the Akamai Production network. Created applications are added to the location specified by the onboard discovery job and are named using the certificate CN friendly name with either `RSA` or `ECC` appended, for example:

- `my.friendlycert.com RSA`
- `my.friendlycert.com ECC`

The driver also supports provisioning once onboard discovery has been completed. New certificates can be added from CMSH so long as an appropriate enrollment template is specified. Once created, certificates are added to Akamai CPS on renewal. Existing certificates can be renewed from CMSH as well.

## Configuration Steps

### Setup an API Integration

Create a new application integration.

1. In CMSH, select **API → Integrations**.
2. Click **Add → New** and provide these values:

   | Step | Name | Value |
   |------|------|-------|
   | 1 | Name | `AkamaiAutomation`. Another name can be used, but ensure the Application Driver configuration is updated. |
   | 1 | Description | `Akamai Automation` or any description you'd like to provide. |
   | 2 | Scope / Privilege | `configuration:manage` and `certificate:manage` |
   | 3 | User or team | Select an appropriate user/team to have access to Akamai Application objects, e.g. `AkamaiUser`. |

### Configure credentials for use with Akamai

Two credential objects configured in CMSH are used by the scripts to connect to Akamai. `AkamaiApplicationDriver.ps1` uses a Password Credential object. `AkamaiWorkflow803.ps1` and `AkamaiWorkflow804.ps1` use a Username Credential object. The password field of both credential objects is a JSON string of the credentials for Akamai authorization.

When the Akamai administrator creates the API Client, it will require access to API CPS with an Access Level of **READ-WRITE**.

1. Open a text editor and paste in this content:

   ```json
   {
     "default": {
       "client_secret": "your-client-secret",
       "host": "your-host-id.luna.akamaiapis.net",
       "access_token": "your-client-access-token",
       "client_token": "your-client-token-goes-here"
     }
   }
   ```

2. Change the values to match those given to you by your Akamai administrator for Akamai API system access.
3. Copy the modified JSON credential text — this is your password in the next steps.
4. In CMSH, go to the Policy Tree.
5. Right-click on the folder where your credentials are stored → **Add → Credential → Username Credential**:
   - Credential Name: `Akamai JSON`
   - User Name: `default`
   - Password/Confirm Password: the JSON credential text
6. Right-click on the folder where your credentials are stored → **Add → Credential → Password Credential**:
   - Credential Name: `EdgeRC JSON`
   - Password/Confirm Password: the JSON credential text
7. Add another Username Credential for the user/team assigned to the API integration (e.g. `AkamaiUser`), if not already created.

### Set up the Application Driver on the Policy tree

For Onboard Discovery to use the Akamai Adaptable Application Driver, the driver must be enabled on the Policy Tree folder where applications are stored.

1. Click on the Policy Tree folder where the Akamai applications will be stored, e.g. `\VED\Policy\Installations\Akamai`.
2. In the tabs at the top, select **Application**, then **Adaptable**.
3. Set the following values:

   | Name | Value | Description |
   |------|-------|--------------|
   | Application Credential | CMSH username credential | e.g. `AkamaiUser` |
   | PowerShell Script | `AkamaiApplicationDriver` | |
   | Proxy URL | Proxy URL | Proxy with optional port, must begin with `http://`. |
   | WebSDK URL | CMSH REST API Server URL | DNS name, e.g. `https://cmsh.company.com`. |
   | Enrollment Template JSON | blank for now | Populated later during discovery. |
   | API Integration Client ID | Client ID from earlier step | Leave blank if `AkamaiAutomation` was provided. |
   | Update using Enrollment Template JSON | `No` | `No` (default) uses the JSON from Akamai. Set to `Yes` to override this behavior and use the JSON configured in CMSH instead. |
   | Remove Root from Chain | `No` | `No` (default) sends the root certificate as part of the trust chain. Set to `Yes` to omit the root certificate from the trust chain. |
   | EdgeRC JSON | EdgeRC JSON credential | Created in the previous step. |

4. Click **Save**.

### Limit Policy Permissions

Ensure the user/team used with the API integration has the ability to access and update Applications created in the Akamai policy folder. If the user/team already has permissions, or a CMSH admin account was used, this step can be skipped.

1. Right-click on the Policy folder created in the last step and select **Permissions**.
2. Add the user/team associated with the API Integration and provide it View, Read, and Write permissions.
3. Click **Save**.

### Set up a device to represent the Akamai server

Onboard Discovery jobs require a device object to execute discovery. A device is configured here with the Akamai Contract ID in the Hostname/Address field, as the Akamai host is supplied by the Akamai authorization credential. An example Akamai Contract ID is `K-0N7RAK7`.

1. In the Policy Tree folder configured in the previous step (e.g. `\VED\Policy\Installations\Akamai`), create a device.
2. Name the device something appropriate with "Akamai" in it.
3. For the hostname, put in the Akamai Contract ID supplied by your Akamai administrator.
4. Save the changes.

### Increase the Adaptable App Script Execution Timeout

1. Contact Venafi support and set up a conference session with a support engineer to increase the Script Execution Timeout of an adaptable application. They will need to be on the call for the next step.
2. Select the Policy Tree folder that contains the device created in the previous step. Navigate to the **Support** tab and click **Enable Edit**.
3. Give the support person the Request. They will reply with a response that enables the attribute edit function.
4. Select the **Policy Attributes** tab and click **Add**.
5. For Class, select **Adaptable App**; Attribute is **Script Execution Timeout**; Value is `3600`; check **Lock this value**.
6. Click **OK** to save the changes.

### Create an Onboard Discovery Job

1. In the CMSH menu, select **Configuration → Jobs**.
2. Click **+ Create New Job**.
3. Select **Onboard Discovery**, then click **Start**.
4. Fill out the form. Pay careful attention to the **Installation Type** field — it must say **Adaptable**.
5. To log details of what was discovered for troubleshooting purposes, check **Enable Debug Logging**.
6. Click **Next**.
7. Either select the specific Akamai Device under **Devices to Scan**, or select the Policy Tree folder under **Scan all Devices located in this folder (and its subfolders)** (e.g. `\Policy\Installations\Akamai`), then click **Next**.
8. Choose where to place newly discovered certificates:
   - **With this device** puts them in the folder with the Akamai Device.
   - **In this folder** puts them in a folder you select.
9. Set the frequency and click **Create Job**.
10. The Akamai Onboard Discovery job now appears in the jobs list.
11. When ready, click **Run Now** next to the job.
12. Once the job has completed, the discovered applications appear under the device created earlier, and the certificates are placed in the certificate folder.

    > **Note:** See the Constraints section above for information about renaming imported dual-stack certificates.
    >
    > **Note:** If an ECC certificate is imported, the CA Template setting for that certificate must be set to an ECC-enabled template for certificate renewal to work properly. See [New Enrollments](#new-enrollments) below.

13. Each discovered application will have an Enrollment Template in JSON format.
14. For new enrollments to be created, this template needs to be copied to the Policy Tree folder's **Enrollment Template JSON** field.
15. Updates to the Enrollment Template JSON can be made, but with several constraints:
    - Akamai will not change many items after a new enrollment — e.g. `enableMultiStackedCertificates` cannot be altered and is automatically changed to `true` after the first enrollment.
    - Mostly, the items that can be changed are expected ones such as the `org`, `adminContact`, and `techContact` sections.
    - The script favors the enrollment template as it exists on Akamai, so if an item already exists there, it cannot be overwritten unless **Update using Enrollment Template JSON** is set to `Yes`.
    - Even so, Akamai itself will not let some items be changed and will send an error message that contains the problem item.
    - The Onboard Discovery script attempts to avoid these issues by removing some items on import from the template. This is also used by the `Generate-CSR` function of the driver to normalize the enrollment being sent to Akamai.
    - **Note:** For SNI support, ensure `networkConfiguration.sniOnly` is set to `true` in the enrollment template.

For more information on Onboard Discovery jobs, see the CMSH documentation site.

## Additional Settings

The following Policy settings configure CMSH to have the driver perform CSR generation in Akamai.

1. Select the Akamai Certificates Policy Tree folder and select the **Certificate** tab (e.g. `\Policy\Certificates\Akamai Certs`).
2. Ensure **Management Type** is set to `Provisioning` and **Generate Key/CSR on Application** is set to `Yes`. Lock both values.

## Optional Workflows

Workflows enable the installation to be paused for approval during the enrollment cycle.

- If Akamai generates a warning message about a certificate enrollment that requires acknowledgement, this is handled by `AkamaiWorkflow803` when it runs the `Update-Binding` function at Stage 803.
- If Akamai has `changeManagement` set to `true` in the Enrollment Template JSON, it deploys the certificate first to the staging network and prompts for an acknowledgement to deploy it to the production network. This is handled automatically by `AkamaiWorkflow804` when it runs the `Activate-Certificate` function at Stage 804.
- If utilizing dual-stack certificates, `AkamaiWorkflowDualStack` is required to handle the orchestration of enrolling and provisioning two certificates at the same time to the endpoint.

All of the above workflows can be configured in CMSH so that approval is required before the associated functions run. The two adaptable workflows put any messages received from Akamai into the Status field of the adaptable application and send an email to the approver(s).

> **Note:** If no warning message is received from Akamai, both adaptable workflow scripts automatically approve the installation, enabling deployment to both staging and production with no further approval required. It's optional to always approve the workflows in CMSH — it's recommended to only do this with the Akamai Approve Production Deployment workflow.

### Increase the Adaptable Workflow Script Execution Timeout

This increases the Adaptable Workflow timeout, which is different from the Adaptable Application timeout above.

1. Create a new Policy Folder for these workflows, e.g. `Akamai Workflows`, so the script execution timeout can be increased.
2. Contact support and set up a conference session with a support engineer to increase the Script Execution Timeout of an adaptable workflow (if not already done for the app above).
3. Select the `Akamai Workflows` Policy Tree folder that will contain the workflows created below.
4. Navigate to the **Support** tab and click **Enable Edit**.
5. Give the support person the Authorization Request. They will reply with the Authorization Response that enables the attribute edit function.
6. On the **Policy Attributes** tab, click **Add**.
7. For Class, select **Adaptable Workflow**; Attribute is **Script Execution Timeout**; Value is `3600`; check **Lock this value**.
8. Click **OK** to save the changes.

### Approval for CSR Creation Workflow

Since Akamai generates the CSR and creates a change in the platform, a new reason code should be created for approval before this happens (if one doesn't already exist), allowing change control to be applied before a CSR is generated in Akamai.

1. Create a new reason code named `Approval for CSR Creation (Stage 400)` with a description such as:

   > A request has been made to create a certificate signing request for a certificate with a DN of `$Config[$Config[$SelfDN$,"Owner Object"]$,"Certificate"]$`. Approval is required for this process to proceed.

2. Right-click on the Policy Tree folder that will contain the workflow object → **Add → Workflow → Standard Workflow**.
3. Name the new workflow `Approval Required for CSR Creation`.
4. Set the stage to `400`.
5. Set the application to `Adaptable App`.
6. Set **Request Approval From** to `Approver assigned to object` (the Approver(s) on the policy where the device resides).
7. Set **Approval Reason Code** to `Approval for CSR Creation (Stage 400)`.
8. Once created, apply the workflow to the folder where the Akamai device resides: click the Policy Tree folder (e.g. `\VED\Policy\Installations\Akamai`) and select the **Workflow** tab.
9. Click in the **Applied Workflows** box, browse to the workflow, select it, and click **Select**.
10. Click **Save** on the policy folder to make the workflow effective.

CMSH will now stop before the `Generate-CSR` function is run (Stage 400) and send an email to the approver(s) with a link to the workflow approval portal. The workflow can be approved for immediate execution or scheduled.

### Akamai Enrollment Warnings Approval Workflow

Used when approval is needed for any warnings about the certificate sent by Akamai. The approval is required before the `Update-Binding` function runs, at stage 803.

1. Create a new reason code `Akamai Enrollment Warnings Approval (Stage 803)` with a description such as:

   > There were warning messages generated from an Akamai Enrollment for the certificate associated with the application `$CN[$Config[$SelfDN$,Owner Object]$]$`. Please log into CMSH and verify the warning status messages for this application and approve this request. The status is `$Config[$SelfDN$,"Status"]$`. The CMSH Application full DN is: `$Config[$SelfDN$,"Owner Object"]$`.

2. Right-click on the Policy Tree folder that will contain the workflow object → **Add → Workflow → Adaptable Workflow**.
3. Name the new workflow `Akamai Acknowledge Enrollment Warnings`.
4. Set the PowerShell Script to `AkamaiWorkflow803`.
5. Set the Credential field to the `Akamai JSON` credential created earlier.
6. To log details of the workflow for troubleshooting purposes, check **Enable Debug Logging**.
7. If a proxy server is in use, add it with its port to **Proxy URL**; otherwise leave blank.
8. Set the **Akamai EnrollmentID Macro** to `$Config[$SelfDN$,"Text Field 5"]$`.
9. If approval is always needed post-verification for the installed certificate, set **Always Approve (Optional)** to `yes`.
10. Set **If Stage is:** to `803`.
11. Set **Request Approval From** to `Approver assigned to object`.
12. Set **Approval Reason Code** to `Akamai Enrollment Warnings Approval (Stage 803)`.
13. Click **Save**.
14. Apply the workflow to the folder where the Akamai device resides, as in the previous section, and click **Save**.

CMSH will stop before the `Update-Binding` function is run (Stage 803) and send an email to the approver(s) with a link to the workflow approval portal.

### Akamai Approve Change Request for Production Workflow

Used when approval is needed to move a certificate from staging to production in Akamai. The approval is required before the `Activate-Certificate` function runs, at stage 804.

1. Create a new reason code `Akamai Approve Change Request for Production (Stage 804)` with a description such as:

   > There is an Akamai certificate ready for deployment to production associated with the application `$Config[$SelfDN$,"Owner Object"]$`. Please log into CMSH and verify status messages for this application and approve this change request.

2. Right-click on the Policy Tree folder that will contain the workflow object → **Add → Workflow → Adaptable Workflow**.
3. Name the new workflow `Akamai Approve Production Deployment`.
4. Set the PowerShell Script to `AkamaiWorkflow804`.
5. Set the Credential field to the `Akamai JSON` credential created earlier.
6. To log details of the workflow for troubleshooting purposes, check **Enable Debug Logging**.
7. If a proxy server is in use, add it with its port to **Proxy URL**; otherwise leave blank.
8. Set the **Akamai EnrollmentID Macro** to `$Config[$SelfDN$,"Text Field 5"]$`.
9. If approval is always needed to move the installed certificate to production, set **Always Approve (Optional)** to `yes`.
10. Set **If Stage is:** to `804`.
11. Set **Request Approval From** to `Approver assigned to object`.
12. Set **Approval Reason Code** to `Akamai Approve Change Request for Production (Stage 804)`.
13. Click **Save**.
14. Apply the workflow to the folder where the Akamai device resides, as in the previous sections, and click **Save**.

CMSH will now stop before the `Activate-Certificate` function is run (Stage 804) and send an email to the approver(s) with a link to the workflow approval portal.

### Adaptable Workflow for Dual-Stack Certificates

1. Update the existing API Integration to include scope `certificate:approve`.
2. Create a new reason code `Akamai DualStack (Stage 800)`.

   > **DO NOT APPROVE!** This workflow ticket is used for automated deployment of Akamai DualStack certificates and will be automatically approved at the appropriate time.

3. Right-click on the Policy Tree folder that will contain the workflow object → **Add → Workflow → Adaptable Workflow**.
4. Name the new workflow `Akamai DualStack` (or similar).
5. Set PowerShell Script to `AkamaiWorkflowDualStack`.
6. Set Credential to the `Akamai JSON` credential created earlier.
7. To log details of the workflow for troubleshooting purposes, check **Enable Debug Logging**.
8. If a proxy server is in use, add it with its port to **Proxy URL**; otherwise leave blank.
9. Set **Akamai EnrollmentID Macro** to `$Config[$SelfDN$,"Text Field 5"]$`.
10. Set **If Stage is:** to `800`.
11. Set **Request Approval From** to `Approver assigned to object`.
12. Set **Approval Reason Code** to `Akamai DualStack`.
13. Set **OAuth Application Id** to the name of your API Integration.
14. Set **OAuth Token Credential** to the Username Credential with access to the API Integration.
15. Set **OAuth Scope** to `configuration:manage; certificate:approve,manage`.
16. Click **Save**.
17. Click on the Policy Tree folder where the Akamai applications are stored and select the **Workflow** tab.
18. Click in the **Applied Workflows** box, browse to the workflow, select it, and click **Select**.
19. Click **Save** on the policy folder to make the workflow effective.

## Usage

General usage is now like any other provisionable application. Renewals of discovered certificates will automatically request a new CSR from Akamai, sign it, then deliver the completed certificate back as an enrollment.

> **Note:** The use of "Always test on Staging before deployment" in the Akamai UI is **not** supported. To accomplish the goal of pausing before Production deployment, see [Optional Workflows](#optional-workflows).

### New Enrollments

A new enrollment can be created in Aperture by creating a new certificate in Aperture.

1. Click **Create a New Certificate** in Aperture. The folder should be a certificate folder in the main Akamai policy. The nickname should match the certificate's Common Name with either `RSA` or `ECC` appended to indicate the CA template type used, e.g. `mycert.company.com ECC`.
2. The next page needs the Common Name and any other relevant CSR information. Under **Key and CSR Generation Options**, select **Connect to target system and create key & CSR remotely**.
3. The next page needs any SAN information and whether automatic renewal will be available. It's important to select either the ECC or RSA Certificate Authority template here to match the type of certificate being created. Make sure **Start processing on creation** is not selected.
4. Click **Create Certificate**.
5. On the next page, click **Yes, Add Installation** to begin the application creation.
6. Search for the existing Akamai device used during discovery and select **Adaptable Installation Driver** for the installation type.
7. Most of the driver information will already be filled out based on the earlier discovery work. Scroll down to the PowerShell Script section and check that the information looks correct and that the **Enrollment Template JSON** is filled in. The **Akamai EnrollmentID** is automatically filled in for new certificate enrollments once Akamai has generated it. When a second certificate is created in a dual-stack configuration, the Akamai EnrollmentID must be copied and pasted into this field for Akamai to recognize it.
8. Click **Install** to begin enrollment creation.

## Uninstall

1. Remove the adaptable application settings from any Policy Tree item set to use this adaptable driver.
2. Remove `AkamaiApplicationDriver.ps1` from `Venafi\Scripts\AdaptableApp`, and `AkamaiWorkflow803.ps1` and `AkamaiWorkflow804.ps1` from `Venafi\Scripts\AdaptableWorkflow` on all CMSH servers.
3. Remove the directory `Venafi\Scripts\AdaptableApp\AkamaiApplicationDriver` on all CMSH servers.
4. Remove the optional Workflows from the Policy Tree folder that contains the workflow objects.

## Appendix

### Code Signing

This solution uses code signing for PowerShell scripts and requires additional configuration on the Certificate Manager, Self-Hosted server.

Code signing is a vital security measure that ensures both the integrity and authenticity of software — it confirms code has not been altered or tampered with, and provides assurance that the code comes from a trusted source.

During usage of this solution you may encounter the following error, which requires the configuration below:

> PowerShell script "xxxxxx.ps1" is not trusted, because the Root ("CN=DigiCert Assured ID Root CA, OU=www.digicert.com, O=DigiCert Inc, C=US") of the code signing certificate is not found in the Roots tree or it is not marked as trusted for Adaptable script signing.

1. Download the DigiCert Root CA used for code signing by CyberArk.
2. Import the certificate.
3. Expand **Trusted Root Certification Authorities** and select **DigiCert Assured ID Root CA 20xx**.
4. Select the **Trust** tab.
5. Set the trust values accordingly and click **Save**.

   > **Note:** If running Certificate Manager v25.1, you must be on patch v25.1.5 or later.
