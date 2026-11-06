# ServiceNow Change Request Workflow

This workflow driver is used to pause the deployment of a machine identity and create a ServiceNow Change Request for approval.

**SOLUTION OVERVIEW**

This solution will monitor the change request through the default Normal change request lifecycle, New->Assess->Authorize->Scheduled. Once scheduled and the planned start date reached, the state will be changed to Implement and the Certificate Manager, Self-Hosted workflow will continue to install the certificate. Once the installation is complete, the state will be moved to Review and optionally automatically closed.

With this script you will have the ability to control the following change request values:

- Change request description - name/value pairs to be added to the description field
- Assignment Group - this mandatory value can either be a group name or sysid
- Approval check interval - the time inbetween change request status checks
- Change model - if using a non-default change model, you can select which to use

The Caller will be set as the account used for authenticating against ServiceNow. The device which the certificate will be installed on will be used for the configuration item lookup; either name or FQDN will be matched.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
