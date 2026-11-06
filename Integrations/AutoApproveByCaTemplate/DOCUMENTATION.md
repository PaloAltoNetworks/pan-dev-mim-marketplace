# CA Auto-Approval Workflow
The CAAutoApproval.ps1 PowerShell script is used by an Adaptable Workflow object in TPP. The script evaluates the location of an X509 certificate object's CA template to determine if the residing parent policy folder DN matches the designated CA templates policy folder DN. If the parent policy folder and designated policy folder match, the workflow stage will be auto-approved during enrollment/renewal of a certificate request. If the CA template resides in any other policy folder, the workflow object will utilize the configured approval value.

## Prerequisites
* A policy folder has been created in TPP where CA templates have been designated for auto-approval.

## Installing the PowerShell Script
1. Place the CAAutoApproval.ps1 script in the following directory on **ALL** platform engine where the **Certificate Management** module is enabled.

    `<TPP Install Path>\Venafi\Scripts\AdaptableWorkflow`

## Workflow Object Configuration
1. Log into **WebAdmin** as a Master Admin.
1. In the **Policy Tree**, locate the policy folder where the workflow object will be created.
1. Right-click and select **Add->Workflow->Adaptable Workflow**.
1. Supply the following workflow object configurations:
  
    |Field|Requirement|Value|Description
    |-|-|-|-|
    PowerShell Script | Mandatory | CAAutoApproval | Select the name of the PowerShell script from the dropdown field
    Enable Debug Logging | Optional | Checked/Unchecked | If enabled, writes debug-level logs to `<TPP Install Path>\Venafi\Logs`
    Certificate Template Macro ($ParentDN[$Policy[$selfdn$, 'Certificate Authority']$]$) | Mandatory | $ParentDN[$Policy[$selfdn$, 'Certificate Authority']$]$ | A macro which identifies the certificate object parent DN of the "Certificate Authority" attribute
    Policy Folder DN for Auto-Approved CA Templates | Mandatory | A policy folder DN ( e.g. - \VED\Policy\Administration\CAs\PreApproved ) | The policy folder DN containing CA templates that do not require review/approval during workflow stages
    If Stage is | Mandatory | 0 | Can be set to stage 0 or 500
    Request Approval From | Mandatory | Approver assigned to object | Approvers of a X509 Certificate object
    Approval Reason Code | Mandatory | Stage 0 | Can be set to stage 0 or 500

1. Click Save.

## Assign the Workflow Object to a Policy Folder
To enforce the workflow process created above, the workflow object must be assigned to a policy folder where certificates will reside.

1. Log into **WebAdmin** as a Master Admin.
1. In the **Policy tree** locate and select policy folder where workflows are enforced. ( e.g. - \Policy\Certificates )
1. In the main window, locate the **Settings** tab and **Workflow** sub-tab.
1. Click the "..." symbol of the **Applied Workflows** field and add the workflow object created previously.
1. Click Save.