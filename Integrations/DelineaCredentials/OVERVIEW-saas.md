# Delinea Credentials

Provisioning certificates to machines requires credentials for those machines. Certificate Manager, SaaS can read those credentials from Delinea Secret Server through its REST API, so they stay in Secret Server and Certificate Manager, SaaS holds only a reference to each secret. This integration is currently available in Preview.

Certificate Manager, SaaS reads the secret each time it uses the credential, so a password you rotate in Secret Server takes effect on the next provisioning operation with no change on the Certificate Manager, SaaS side.

**Value Highlights**

- **Keep credentials in Secret Server**: Certificate Manager, SaaS stores references to secrets, not copies.
- **Pick up rotations automatically**: rotated passwords are used the next time a credential is read.
- **Support self-hosted and cloud Secret Server**: connect to Delinea Secret Server or Secret Server Cloud.
- **Use least-privilege access**: connect with an application account that needs only view permissions on the folders that hold your secrets.
- **Keep Secret Server private**: VSatellites in your network reach Secret Server over HTTPS.

**How it Works**

You create an application account in Secret Server, then add a Delinea connection under **Credential Managers** with the Secret Server URL and that account, tested through one or more VSatellites. You create Delinea credentials that reference a secret by its numeric ID and assign them to machines. Secrets that require check-out, approval or DoubleLock are not supported. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, SaaS
- VSatellite
- Delinea Secret Server

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
