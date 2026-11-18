# Entrust CA Gateway

Enterprise PKIs are often made up of many individual CAs, which creates administrative overhead. Entrust CA Gateway gives Entrust customers a single API endpoint for requesting certificates from their Entrust certificate authorities. Certificate Manager, Self-Hosted uses that endpoint to request, approve, issue and manage Entrust certificates under your existing policies.

**Value Highlights**

- **Automate the full certificate lifecycle**: request, issue, renew and revoke Entrust certificates without manual steps.
- **Gain full visibility**: track the demand, usage and workflow of certificate services in one place.
- **Enforce policies and reduce risk**: apply automated workflows, approvals and detailed logging to every request.
- **Achieve compliance**: keep a record of workflow approvals, authorization and authentication.
- **Use one connection for many CAs**: reach multiple Entrust CAs through the CA-agnostic CA Gateway REST API.

**How it Works**

Certificate Manager, Self-Hosted includes an Entrust CA Gateway driver. You configure a CA template that connects to your CA Gateway, and Certificate Manager, Self-Hosted then requests server, device, user and code signing certificates issued by the Entrust Security Manager CAs behind it. Approval workflows and policy are applied in Certificate Manager, Self-Hosted before requests reach the gateway. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, Self-Hosted
- Entrust CA Gateway

**About Entrust**

Entrust provides a portfolio of identity, encryption and PKI solutions, including certificate-based technology that helps organizations establish trusted signatures, encryption and identity for people, systems and devices.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
