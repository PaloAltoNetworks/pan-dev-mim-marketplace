# Palo Alto Networks Prisma Access

Prisma Access relies on certificates for GlobalProtect portals and gateways and for the IPsec tunnels of Remote Networks and Service Connections. Renewing them by hand in Strata Cloud Manager means importing each certificate, updating the objects that use it, and pushing the configuration.

Next-Gen Trust Security connects to your Prisma Access tenant through the Strata Cloud Manager configuration API to discover these certificates and provision renewed ones.

**Value Highlights**

- **See where certificates are used**: Discover one installation for each TLS service profile or IKE gateway that uses a certificate, and flag certificates that nothing uses.
- **Rebind and push**: Import the renewed certificate as a new object, point the TLS service profile or IKE gateway at it, and push the configuration.
- **Clean up superseded objects**: Delete the old certificate object after a renewal when Next-Gen Trust Security created it and nothing references it.
- **Scope discovery**: Limit discovery to one Strata Cloud Manager folder and the folders below it.
- **Schedule changes**: Run discovery and provisioning daily, weekly, or monthly.

**How it Works**

A VSatellite connects to the Strata Cloud Manager API with a service account's client ID and client secret and the tenant's Tenant Service Group ID. A push publishes every pending change in the affected folders, so coordinate with the tenant's other Strata Cloud Manager administrators before you provision.

Explicit Proxy certificates aren't supported, and IKE gateways that use a pre-shared key are skipped. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security with a VSatellite
- Palo Alto Networks Prisma Access tenant managed in Strata Cloud Manager
- Strata Cloud Manager service account
