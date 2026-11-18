# CSC Global CA

Organizations that buy public certificates from CSC often order, validate and renew them by hand, outside the policies they enforce for the rest of their certificates. The CSC Global Adaptable CA Driver by Secur Solutions Group connects Certificate Manager, Self-Hosted to CSC TrustedSecure certificate services, so CSC certificates are requested, renewed and tracked like any other certificate.

**Value Highlights**

- **Automate CSC certificate orders**: Request and renew CSC TrustedSecure certificates directly from Certificate Manager, Self-Hosted.
- **Cover CSC certificate types**: Order Premium, Wildcard, UCC and EV certificates, with domain control validation by CNAME or email.
- **Enforce policy**: Set certificate type, validation method and other CSC values per certificate or through policy.
- **Import your existing inventory**: Bring active CSC certificates into Certificate Manager, Self-Hosted with the included import script.
- **Keep credentials current**: The driver refreshes its own API tokens, so integrations keep working without manual credential updates.

**How it Works**

The Adaptable CA Driver runs on each Certificate Manager, Self-Hosted engine and calls the CSC API to submit orders, track validation and retrieve issued certificates. Account-wide CSC values are set in a properties file, and per-certificate values such as certificate type come from custom fields. A separate CA import script pulls active certificates from your CSC Global account. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- CSC Global TrustedSecure certificate services and the CSC API
- CSC Global Adaptable CA Driver and import script by Secur Solutions Group

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) is an identity technology and consultancy firm that builds integrations for CyberArk machine identity products. Contact Secur Solutions Group for licensing.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
