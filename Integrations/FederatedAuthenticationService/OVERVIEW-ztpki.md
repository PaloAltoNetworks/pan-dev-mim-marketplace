# Federated Authentication Service (FAS)

Citrix Federated Authentication Service (FAS) issues logon certificates on behalf of users so they can sign in to Citrix Virtual Apps and Desktops with federated single sign-on. FAS normally needs an on-premises certificate authority to issue those certificates, which is one more system to run, secure and maintain. With Zero Touch PKI, FAS can get its logon certificates from a hosted CA instead.

**Value Highlights**

- **Remove the on-premises CA** that FAS would otherwise depend on.
- **Automate logon certificates** for federated single sign-on to Citrix Virtual Apps and Desktops.
- **Use your existing FAS design**, because Zero Touch PKI appears to Active Directory as a Microsoft Enterprise CA.
- **Apply issuance policy centrally** by mapping the logon certificate template to a Zero Touch PKI policy.

**How it Works**

FAS support is delivered through the Zero Touch PKI [Auto-Enrollment Connector](https://docs.cyberark.com/mis-saas/ztpki/connectors/aec-overview/) (AEC). The AEC runs as a Windows service that presents itself to Active Directory as a Microsoft Enterprise CA and forwards enrollment requests to Zero Touch PKI. Citrix FAS uses a Remote Host configuration pointed at the AEC to obtain the smart-card class logon certificates it issues for federated users. See the Documentation tab for setup steps.

**Solution Components**

- Zero Touch PKI
- Zero Touch PKI Auto-Enrollment Connector
- Citrix Federated Authentication Service
