# Auto-Enrollment Connector

The Auto-Enrollment Connector (AEC) extends Zero Touch PKI (ZTPKI) into Microsoft Active Directory, so Windows users, computers, and domain controllers receive and renew certificates automatically — with no on-endpoint agents and no on-premises certificate authority to maintain.

## How it works

The AEC runs as a Windows service and presents itself to Active Directory as a Microsoft Enterprise CA. It answers Windows auto-enrollment requests over the Microsoft Client Certificate Enrollment Protocol (MS-WCCE, via DCOM) and forwards them to ZTPKI for issuance. AD certificate templates (for example User, Workstation Authentication, Domain Controller) are mapped to ZTPKI issuance policies, so existing Group Policy auto-enrollment drives certificate lifecycle from the cloud. It also underpins the [Citrix Federated Authentication Service](#) integration by issuing the logon certificates FAS relies on.

## Prerequisites

- A Zero Touch PKI account with a Service Requestor (Hawk ID + key) and one or more issuance policies (Policy IDs), plus the root and issuing CA certificates (DER).
- A dedicated, domain-joined Windows Server (2022/2025, Desktop Experience) with .NET Framework 4.7.2+. Do **not** co-install with AD CS or any other MS-WCCE product, and do not install on a production domain controller.
- Local Administrator and Domain Administrator rights for installation and AD configuration.
- Network: inbound DCOM (TCP 135 + the dynamic RPC range) from enrolling clients; outbound HTTPS 443 to your regional ZTPKI endpoint (for example `ztpki.venafi.com`, `ztpki.eu.venafi.com`, `ztpki.au.venafi.com`).

## Setup

1. **Prepare Active Directory** — create/configure the certificate templates, import the ZTPKI root and issuing CA certificates via Group Policy, enable the auto-enrollment GPO, and configure DCOM permissions.
2. **Install the AEC** on the prepared Windows server.
3. **Configure the AEC** — set logging (and an optional local proxy), add your ZTPKI CAs, and map each AD template to a ZTPKI issuance Policy ID.
4. **Test** auto-enrollment from a client and confirm certificates are issued and renewed.

See the [Auto-Enrollment Connector documentation](https://docs.cyberark.com/mis-saas/ztpki/connectors/aec-overview/) for full installation, upgrade, and troubleshooting guidance.
