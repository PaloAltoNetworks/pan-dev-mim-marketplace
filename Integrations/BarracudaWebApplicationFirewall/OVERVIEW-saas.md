# Barracuda Web Application Firewall

Barracuda Web Application Firewalls terminate HTTPS for the applications they protect, so each service needs a valid certificate. Certificate Manager, SaaS discovers the certificates stored on the appliance and provisions renewed certificates to its services, which removes manual uploads and the outages that follow a missed renewal.

**Value Highlights**

- **Prevent downtime**: provision renewed certificates to Barracuda WAF services before the old ones expire.
- **Gain visibility**: discover signed, self-signed, trusted CA and trusted server certificates on the appliance, filtered by vsite if you want.
- **Remove manual steps**: activate a certificate as a service's default certificate or as the certificate for an SNI domain.
- **Use least privilege**: connect with an appliance account that has read and write access to certificates and services, without full administrator rights.
- **Renew on your schedule**: run discovery and provisioning on a daily, weekly or monthly schedule.

**How it Works**

Certificate Manager, SaaS connects to the Barracuda WAF management interface through a VSatellite. Discovery reads the certificates on the appliance and the services that use them. Provisioning uploads an RSA or ECDSA server certificate, activates it on the service or SNI domain you choose, and turns on SSL and SNI for the service if needed. Other certificate assignments on the service stay unchanged.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- VSatellite
- Barracuda Web Application Firewall

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
