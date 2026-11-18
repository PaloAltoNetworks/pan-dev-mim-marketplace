# Barracuda ADC

Barracuda ADC appliances terminate TLS for the services they load balance, and each service needs a valid certificate. A missed renewal takes the application behind that service offline for its users.

Certificate Manager, SaaS discovers the certificates that the appliance's services use and provisions new and renewed certificates to those services, so expiring certificates are replaced on schedule.

**Value Highlights**

- **Discover certificates in use**: discovery reads each service's TLS configuration, including the CA certificates used to validate connecting clients.
- **Assign certificates where they're needed**: provision as a service's default certificate, as the certificate for an SNI domain, or as a client validation certificate.
- **Serve RSA and ECDSA side by side**: the appliance keeps RSA and ECDSA certificates in separate slots, and Certificate Manager, SaaS turns on ECDSA for a service when it provisions an ECDSA certificate.
- **Limit administrative access**: the appliance account needs read and write access to services and certificates, not full administrator rights.
- **Use stored credentials**: connect with an appliance account entered directly or held in a credential manager integration.

**How it Works**

A Barracuda ADC machine connects to the appliance's management interface through a VSatellite. Certificate Manager, SaaS uploads each certificate to the appliance's certificate store and assigns it to the service you choose. Services and their TLS configuration must already exist.

The appliance API can't replace or delete certificates, so each renewal adds a new certificate and earlier ones stay until you remove them in the appliance's web interface.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- Barracuda ADC appliance

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
