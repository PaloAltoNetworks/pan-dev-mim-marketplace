# Zero Touch PKI Adaptable Driver

CyberArk Zero Touch PKI (ZTPKI) is a cloud-delivered certificate authority that issues trusted machine identities on demand. This Adaptable CA driver connects Certificate Manager, Self-Hosted to ZTPKI so certificates can be requested, renewed, and imported without manual intervention.

**SOLUTION HIGHLIGHTS**

- Issue and renew certificates from CyberArk Zero Touch PKI directly within Certificate Manager
- Import existing ZTPKI certificates into the Venafi Platform inventory
- Maintain a complete, up-to-date machine identity inventory

**HOW IT WORKS**

The driver authenticates to the ZTPKI REST API and handles certificate issuance and renewal. A companion import-only script populates the Venafi Platform with existing ZTPKI certificates via an Adaptable Certificate Import job.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
