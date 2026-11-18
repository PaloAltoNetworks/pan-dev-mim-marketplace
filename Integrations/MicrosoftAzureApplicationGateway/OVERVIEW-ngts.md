# Microsoft Azure Application Gateway

Microsoft Azure Application Gateway terminates TLS for web applications on its HTTPS listeners, and each listener depends on an SSL certificate that must be renewed before it expires. Tracking and replacing those certificates by hand across subscriptions and resource groups is slow and easy to miss.

With Next-Gen Trust Security, you can discover the SSL certificates bound to your Application Gateway listeners and provision renewed certificates to them from a central inventory, so expiring certificates are replaced before they cause an outage.

**Value Highlights**

- **Find listener certificates**: Discover the uploaded SSL certificates bound to HTTPS listeners across a subscription or a single resource group.
- **Renew in place**: Replace the contents of an existing SSL certificate by name, or add a new one, and bind it to the HTTPS listener you choose.
- **Connect without on-premises components**: The connector runs in the cloud and signs in to Azure as a Microsoft Entra ID service principal, so no VSatellite is needed.
- **Schedule changes**: Run discovery and provisioning daily, weekly, or monthly so renewals install during the window you choose.
- **Avoid conflicting updates**: Next-Gen Trust Security waits and retries when another change is already running on the gateway.

**How it Works**

You create a Microsoft Azure Application Gateway machine in Next-Gen Trust Security with the tenant ID, client ID, and client secret of a service principal, plus the ID of the Azure subscription. The service principal needs the Network Contributor role on the subscription or on the resource group that contains the gateways.

Discovery finds uploaded certificates that at least one HTTPS listener uses and skips certificates the gateway loads from Microsoft Azure Key Vault. Provisioning adds or replaces the named SSL certificate on the gateway and binds it to an existing HTTPS listener. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Microsoft Azure Application Gateway
- Microsoft Entra ID service principal with the Network Contributor role
