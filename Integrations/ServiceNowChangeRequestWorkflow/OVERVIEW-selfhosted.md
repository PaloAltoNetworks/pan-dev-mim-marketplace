# ServiceNow Change Request Workflow

Many organizations require an approved change request before anything is installed on production systems, and that includes certificates. This workflow driver pauses the deployment of a machine identity in Certificate Manager, Self-Hosted and creates a ServiceNow Change Request for approval, so certificate installs follow the same change process as every other production change.

**Value Highlights**

- **Enforce change control**: Certificate installation waits until the ServiceNow Change Request is approved and scheduled.
- **Follow the standard lifecycle**: The change request is tracked through the default Normal lifecycle (New, Assess, Authorize, Scheduled, Implement, Review).
- **Link to the right asset**: The target device is matched to a ServiceNow configuration item by name or FQDN.
- **Close the loop automatically**: After installation the change moves to Review and can be closed automatically.
- **Fit your process**: Control the description, assignment group, approval check interval and change model.

**How it Works**

When a certificate deployment reaches the workflow stage, the driver creates a change request and monitors it. Once the change is scheduled and the planned start date is reached, the driver moves the change to Implement and the Certificate Manager, Self-Hosted workflow continues to install the certificate. When installation completes, the change moves to Review and is optionally closed. The Caller is set to the account used to authenticate to ServiceNow.

You can control these change request values:

- **Change request description**: name/value pairs added to the description field.
- **Assignment Group**: a required group name or sys_id.
- **Approval check interval**: the time between change request status checks.
- **Change model**: an alternative to the default change model, if you use one.

**Solution Components**

- Certificate Manager, Self-Hosted
- ServiceNow Change Management

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
