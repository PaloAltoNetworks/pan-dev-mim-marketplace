# CA Auto-Approval Workflow

`CAAutoApproval.ps1` is used by an Adaptable Workflow object in Certificate Manager, Self-Hosted. It checks whether the parent policy folder of a certificate's CA template matches the designated policy folder for auto-approved CA templates. If it matches, the workflow stage is approved automatically during enrollment or renewal. If the CA template is in any other policy folder, the workflow object uses its configured approval settings.

## Prerequisites

- A policy folder that contains the CA templates designated for auto-approval.

## Installation

1. Copy `CAAutoApproval.ps1` to `<install path>\Venafi\Scripts\AdaptableWorkflow` on **every** server where the **Certificate Management** module is enabled.

## Configuration

1. Sign in to **WebAdmin** as a master administrator.
2. In the **Policy Tree**, select the policy folder where you want to create the workflow object.
3. Right-click it and select **Add > Workflow > Adaptable Workflow**.
4. Set these fields:

| Field | Requirement | Value | Description |
|-|-|-|-|
| PowerShell Script | Mandatory | `CAAutoApproval` | The script name, selected from the list. |
| Enable Debug Logging | Optional | Checked or unchecked | Writes debug logs to `<install path>\Venafi\Logs`. |
| Certificate Template Macro | Mandatory | `$ParentDN[$Policy[$selfdn$, 'Certificate Authority']$]$` | Resolves the parent DN of the certificate's CA template. |
| Policy Folder DN for Auto-Approved CA Templates | Mandatory | A policy folder DN, for example `\VED\Policy\Administration\CAs\PreApproved` | The folder that holds CA templates that do not need review. |
| If Stage is | Mandatory | `0` | Stage 0 or 500. |
| Request Approval From | Mandatory | The approver assigned to the object | Approvers of the certificate object. |
| Approval Reason Code | Mandatory | Stage 0 | Stage 0 or 500. |

5. Click **Save**.

## Usage

Assign the workflow object to the policy folder that contains the certificates you want it to apply to:

1. Sign in to **WebAdmin** as a master administrator.
2. In the **Policy Tree**, select the policy folder where workflows are enforced, for example `\Policy\Certificates`.
3. Open the **Settings** tab and the **Workflow** sub-tab.
4. Click **...** next to **Applied Workflows** and add the workflow object.
5. Click **Save**.

## Logs

With **Enable Debug Logging** checked, the script writes debug logs to `<install path>\Venafi\Logs`.
