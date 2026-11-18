# SAP Secure Login Server

## Prerequisites

- Certificate Manager, Self-Hosted 21.3 or later
- SAP Secure Login Server 3.0 SP02 PL10 or later (SAP Single Sign-On 3.0 or later)

## Configuration

The integration needs configuration only, with no additional software. The high-level steps are:

1. In Certificate Manager, Self-Hosted, create a user identity that is allowed to request certificates after HTTP authentication.
2. In Certificate Manager, Self-Hosted, create a password credential for the challenge password.
3. Configure the SAP interface in Certificate Manager, Self-Hosted.
4. Configure SAP Secure Login Server to use Certificate Manager, Self-Hosted as its remote CA.

## Additional Resources

- [A quick intro into SAP Single Sign-On 3.0](https://blogs.sap.com/2021/03/10/a-quick-intro-into-sap-single-sign-on-3.0/)
- [SAP Single Sign-On 3.0 SP01: Secure Login Server with Enterprise PKI](https://blogs.sap.com/2016/07/04/sap-single-sign-on-30-secure-login-server-with-enterprise-pki/)
- [SAP: Configuring Certificate Lifecycle Management](https://blogs.sap.com/2020/07/09/configuring-certificate-lifecycle-management/)
- [SAP Note 2375797](https://me.sap.com/notes/2375797) (requires SAP support access)
- [SAP Note 3086237](https://me.sap.com/notes/3086237), the release note that adds support for Certificate Manager, Self-Hosted (requires SAP support access)
