# Google Cloud CA Service

Google Cloud Certificate Authority Service (CAS) provides private CAs hosted in Google Cloud. Certificate Manager, SaaS connects to Google Cloud CAS as a certificate authority, so you can request, renew, revoke and import certificates from your Google Cloud CA pools and manage them alongside every other certificate in your inventory.

Request policies decide which teams can request certificates from which Google Cloud CAS products, so cloud-issued certificates follow the same rules as the rest of your PKI.

**Value Highlights**

- **Issue from Google Cloud private CAs**: request and renew certificates from a Google Cloud CAS CA pool through Certificate Manager, SaaS.
- **Revoke from one place**: revoke Google Cloud CAS certificates without switching consoles.
- **Import existing certificates**: bring certificates already issued by the CA pool into your inventory, with optional scheduled import.
- **Enforce policy**: map Google Cloud CAS products to request policies so only approved certificates are issued.
- **Reduce PKI overhead**: use Google Cloud-hosted CAs instead of running your own CA servers.

**How it Works**

You add a Google CA Service connector under **Certificate Authorities** and give it your GCP project, region, CA pool name and a service account key in JSON format with permissions to manage certificates in the pool. After a connection test, you choose which products to offer for issuance and which to import from, including revoked, expired or pool CA certificates if you want them. The CA is then available to request policies. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, SaaS
- Google Cloud Certificate Authority Service

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
