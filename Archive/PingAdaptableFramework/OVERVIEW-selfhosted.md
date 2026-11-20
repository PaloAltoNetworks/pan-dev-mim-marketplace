# Ping Adaptable Framework

PingFederate uses SSL certificates for its own endpoints and signing certificates for federation connections. Renewing them by hand in the Ping administrator console is easy to forget, and an expired signing certificate can break single sign-on for every connected application. The Ping Adaptable Framework driver lets Certificate Manager, Self-Hosted manage SSL and signing certificates in PingFederate, so renewals follow policy and are delivered to Ping automatically.

**Value Highlights**

- **Discover what is in use**: Inventory the certificates PingFederate already uses with an onboard discovery job.
- **Automate renewals**: Any renewal started from Certificate Manager, Self-Hosted provisions the new certificate into PingFederate.
- **Keep keys in Ping**: Keys are generated inside PingFederate's default keystore and never leave it. Certificate Manager, Self-Hosted handles the signing.
- **Cover both certificate types**: Manage SSL certificates and signing certificates through separate policy scopes.
- **Control certificate lifetime**: Set the validity period for certificates managed under each policy.

**How it Works**

The `ping_adaptable_driver.ps1` script is an Adaptable Application driver for Certificate Manager, Self-Hosted. It calls the PingFederate administrative API to create the key and certificate request in Ping, sends the request for signing, and returns the signed certificate to Ping. Because private keys stay in Ping, an externally generated key and certificate cannot be imported through this integration. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- PingFederate

**About IDMWORKS**

[IDMWORKS](https://www.idmworks.com/) is an identity and access management consulting and services firm, and the author of this driver.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
