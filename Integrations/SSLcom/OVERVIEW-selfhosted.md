# SSL.com

Managing a high volume of publicly trusted certificates across an organization is hard to do by hand, and missed renewals cause outages. The SSL.com Adaptable CA driver connects Certificate Manager, Self-Hosted to SSL.com, so you can request, renew, replace and revoke SSL.com certificates centrally, under the same policy and automation as the rest of your machine identities.

**Value Highlights**

- **Lower operational costs** with automated certificate provisioning.
- **Gain visibility** into the demand for, usage of and workflow around certificate services.
- **Strengthen compliance** with automated notifications, renewals and centralized authorization.
- **Automate the full lifecycle**, including request, issuance, renewal, replacement and revocation.
- **Cover many certificate types**: SSL/TLS, client, S/MIME and code signing certificates.

**How it Works**

The driver (`SSL.com_Adaptable_Script.ps1`) runs in an Adaptable CA template in Certificate Manager, Self-Hosted and calls the SSL.com web services API. Custom fields on the template supply the order details SSL.com needs, such as the product code, validity period and admin contact. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- An SSL.com account

**About SSL.com**

SSL.com is a publicly trusted certificate authority that provides SSL/TLS, code signing, client authentication and S/MIME certificates.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
