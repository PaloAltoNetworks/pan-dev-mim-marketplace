# IBM API Connect

IBM API Connect gateways, backend mutual TLS (mTLS) connections and consumer applications all depend on certificates kept in a provider organization. An expired gateway or mTLS certificate breaks the APIs that rely on it.

Certificate Manager, SaaS discovers and provisions the certificates that an IBM API Connect provider organization uses, so gateway and mTLS certificates are renewed on time.

**Value Highlights**

- **Discover across the provider organization**: find gateway SNI hostname certificates, backend mTLS certificates, keystore-only certificates and consumer application certificates.
- **Renew gateway certificates in place**: update the keystore that a gateway's TLS server profile uses, with no gateway change.
- **Set up backend mTLS**: point a TLS client profile at a keystore so outbound connections present the certificate.
- **Replace consumer application certificates**: update the public certificate registered on a consumer application without sending a private key.
- **Run on SaaS or self-managed**: supports IBM API Connect SaaS and self-managed IBM API Connect version 10.0.x or later.

**How it Works**

An IBM API Connect machine connects to the management (platform) endpoint through a VSatellite. It authenticates with API Manager toolkit credentials plus a platform REST API key (SaaS) or a provider organization user (self-managed).

Each machine connects to one provider organization.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- IBM API Connect SaaS or self-managed 10.0.x or later

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
