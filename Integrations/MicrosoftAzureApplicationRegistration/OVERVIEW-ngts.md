# Microsoft Azure Application Registration

Applications registered in Microsoft Entra ID often authenticate with certificates uploaded as credentials. When one of those certificates expires, the application can no longer sign in, and these certificates are easy to lose track of because they sit inside individual app registrations.

Next-Gen Trust Security discovers the certificates uploaded to every app registration in your tenant and adds them to your certificate inventory, so you can see what is expiring and act before sign-ins fail.

**Value Highlights**

- **Cover the whole tenant**: One machine discovers certificate credentials across every app registration in the Microsoft Entra tenant.
- **Identify each credential**: Discovered certificates are labeled with the app registration's Application (client) ID and display name and the certificate's key ID.
- **Use read-only access**: The connector needs only the Microsoft Graph Application.Read.All application permission and makes no changes in Azure.
- **Run where it fits**: Choose the machine type that runs the connector in the cloud, or the one that runs it on a VSatellite in your network.
- **Keep the inventory current**: Schedule discovery daily, weekly, or monthly, and optionally exclude expired certificates.

**How it Works**

You create a Microsoft Azure Application Registration machine with your Microsoft Entra tenant ID and the client ID and client secret of an app registration that has the Application.Read.All permission with admin consent. Discovery reads the certificates uploaded as credentials to each app registration through Microsoft Graph. It doesn't discover client secrets.

This machine type discovers certificates only and doesn't provision them. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Microsoft Entra ID app registrations
- Microsoft Graph API
