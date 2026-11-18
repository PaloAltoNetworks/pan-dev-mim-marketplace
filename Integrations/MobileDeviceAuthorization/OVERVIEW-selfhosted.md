# Mobile Device Authorization

From Wi-Fi and VPN to MDM and EMM management, certificates are used more and more to authenticate mobile devices and their users. When those certificates are issued from several CAs without consistent policy, security teams lose track of who holds which certificate and cannot cut off access quickly. Integrating MobileIron with Certificate Manager, Self-Hosted gives security and operations teams consistent certificate issuance policies, consolidated user-level visibility, and a kill switch for VPN, Wi-Fi and other mobile certificates.

**Value Highlights**

- **Gain visibility**: See all certificates down to the user level.
- **Get a running start**: Use your existing CAs and import from your directory.
- **Issue through SCEP**: Use a validated SCEP integration to issue multi-profile, policy-enforced certificates.
- **Stop unauthorized access**: Revoke all certificates for an individual across CAs with a single kill switch.
- **Stay in sync**: Import and synchronize users with directory services.

**How it Works**

MobileIron requests certificates for managed devices and users from Certificate Manager, Self-Hosted over SCEP. Certificate Manager, Self-Hosted applies your issuance policy, issues the certificates from your existing CAs, and links each certificate to its user through directory import, so you can see and revoke every certificate a person holds.

**Solution Components**

- Certificate Manager, Self-Hosted with its SCEP service
- MobileIron
- Your existing CAs and directory service

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
