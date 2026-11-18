# Thycotic Adaptable Credentials

Keeping copies of service account passwords in several systems makes rotation harder and widens exposure. This driver lets you create an Adaptable Credential object in Certificate Manager, Self-Hosted that references `username`/`password` or `password` credentials stored in Thycotic (Delinea) Secret Server. The credential is retrieved from Secret Server on demand instead of being stored in Certificate Manager, Self-Hosted, so secrets stay centralized in the vault.

**Value Highlights**

- **Centralize secrets**: Keep credentials in Secret Server instead of duplicating them in Certificate Manager, Self-Hosted.
- **Pick up rotations automatically**: Passwords rotated in the vault are used without re-entering them.
- **Reuse everywhere**: Reference the credential from CA templates, application drivers and discovery jobs that consume a credential.
- **Configure simply**: Each credential object needs only the Secret Identifier of the secret to retrieve.

**How it Works**

The `ThycoticAdaptableCredential.ps1` script implements the Adaptable Credential framework. When a consuming object needs the credential, the script authenticates to Secret Server with an OAuth token request, looks up the secret by its **Secret Identifier** (a required, policyable field on the credential object) and returns the stored credential. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Thycotic (Delinea) Secret Server
- `ThycoticAdaptableCredential.ps1` Adaptable Credential driver

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
