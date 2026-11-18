# Microsoft Intune

Devices managed by Microsoft Intune need user and device certificates, and running your own CA infrastructure to issue them adds cost and operational work. This integration connects Zero Touch PKI with Microsoft Intune to request, install and renew certificates on Intune-managed devices over SCEP, giving mobile and desktop fleets trusted identities without a customer-run CA.

**Value Highlights**

- **Skip the on-premises CA**: Issue Intune certificates from Zero Touch PKI.
- **Cover every platform**: Deliver user and device certificates on every Intune-supported platform.
- **Renew automatically**: Renewals happen as devices check in.
- **Validate requests**: Zero Touch PKI checks each SCEP challenge with Intune before it issues a certificate.

**How it Works**

Zero Touch PKI exposes a SCEP endpoint that authenticates to Intune through a Microsoft Entra ID application (app-to-app authentication). Intune trusted root and SCEP profiles point devices at that endpoint, and Zero Touch PKI issues the certificates under policies that CyberArk provisions during onboarding. See the Documentation tab for setup.

**Solution Components**

- Zero Touch PKI
- Microsoft Intune and Microsoft Entra ID
