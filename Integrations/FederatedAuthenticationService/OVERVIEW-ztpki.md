# Federated Authentication Service (FAS)

Citrix Federated Authentication Service (FAS) integrates with Zero Touch PKI (ZTPKI) to automate the logon certificates that enable federated single sign-on to Citrix Virtual Apps and Desktops — removing the need to run and maintain an on-premises certificate authority for FAS.

## How it works

FAS support is delivered through the ZTPKI [Auto-Enrollment Connector](https://docs.cyberark.com/mis-saas/ztpki/connectors/aec-overview/) (AEC). The AEC runs as a Windows service that presents itself to Active Directory as a Microsoft Enterprise CA and forwards enrollment requests to ZTPKI. Citrix FAS then uses a Remote Host configuration pointed at the AEC to obtain the user logon (smart-card class) certificates it issues on behalf of federated users, so authentication certificates are sourced from ZTPKI rather than a local CA.

## Prerequisites

- A Zero Touch PKI account with an issuance policy suitable for smart-card logon / client-authentication certificates.
- A deployed ZTPKI Auto-Enrollment Connector (see the AEC overview for its Windows Server, Active Directory, and network prerequisites).
- Citrix Federated Authentication Service, with permission to configure its Certificate Authority / Remote Host settings.

## Setup

1. **Deploy and configure the AEC** so it fronts Active Directory for ZTPKI (install the connector, import the ZTPKI CA chain, and map the logon certificate template to a ZTPKI issuance policy).
2. **Point Citrix FAS at the AEC** — in the FAS configuration, add the AEC as the certificate authority using a Remote Host configuration.
3. **Validate** federated logon by signing in through Citrix with a FAS-issued certificate and confirming it was issued by ZTPKI.

See the [Auto-Enrollment Connector documentation](https://docs.cyberark.com/mis-saas/ztpki/connectors/aec-overview/) for connector setup; there is no separate FAS connector page — FAS is configured as an AEC use case.
