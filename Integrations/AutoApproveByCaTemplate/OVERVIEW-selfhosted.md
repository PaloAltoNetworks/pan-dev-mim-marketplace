# Auto-Approve by CA Template

Approval workflows protect certificate issuance, but requiring a manual review for every request slows teams down even when the request uses a CA template that security has already vetted. Reviewers spend time on routine requests instead of the ones that need attention.

Auto-Approve by CA Template is a workflow script for Certificate Manager, Self-Hosted that approves requests automatically when they use a pre-approved CA template. Requests that use any other CA template still go through your normal approval process.

**Value Highlights**

- **Streamline issuance** by auto-approving requests that use pre-approved CA templates.
- **Preserve manual review** for CA templates outside the designated policy folder.
- **Control which templates qualify** by placing them in a single designated policy folder.
- **Configure per policy folder** with a standard Adaptable Workflow object.
- **Troubleshoot approval decisions** with optional debug logging.

**How it Works**

`CAAutoApproval.ps1` runs from an Adaptable Workflow object during enrollment and renewal. It checks whether the parent policy folder of the certificate's CA template matches the policy folder you designated for auto-approved CA templates. If it matches, the workflow stage is approved automatically. Otherwise, the workflow object uses its configured approvers. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted with the Certificate Management module
- `CAAutoApproval.ps1` and an Adaptable Workflow object

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
