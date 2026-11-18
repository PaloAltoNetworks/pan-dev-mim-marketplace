# IBM DataPower Gateway

IBM DataPower Gateway secures and integrates APIs, web services, mobile, B2B and cloud workloads, and each of those services depends on certificates stored on the gateway. When those certificates are tracked and replaced by hand, they expire and break the traffic the gateway protects. Certificate Manager, SaaS discovers the certificates in your DataPower application domains and provisions new and renewed certificates to them, so the gateway always presents valid, policy-compliant certificates.

**Value Highlights**

- **Gain visibility**: Discover the certificates in each DataPower application domain and track them in one inventory.
- **Automate provisioning**: Upload certificates and private keys to the domain filestore and update the crypto objects that use them.
- **Replace certificates in place**: Point an existing certificate object at the renewed certificate so the profiles that use it pick up the change.
- **Cover every use**: Provision certificates for HTTPS listeners, outbound TLS clients, signing credentials, trust anchors and the management interface.
- **Prevent outages**: Renew certificates before they expire.

**How it Works**

You create an IBM DataPower Gateway machine in Certificate Manager, SaaS. A VSatellite connects to the gateway's REST Management Interface to discover certificates and to provision them. When you provision a certificate, Certificate Manager, SaaS uploads the certificate and key files to the domain filestore, creates or updates the CryptoCertificate and CryptoKey objects, can associate the certificate with an SSL profile or identification credential, and saves the domain configuration. See the Documentation tab for requirements and setup.

**Solution Components**

- Certificate Manager, SaaS, with a VSatellite that can reach the gateway
- IBM DataPower Gateway with the REST Management Interface turned on

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
