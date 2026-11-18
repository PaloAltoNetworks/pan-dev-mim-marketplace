# Oracle Cloud API Gateway

Oracle Cloud Infrastructure (OCI) API Gateway serves APIs on custom domains with certificates you upload. API Gateway certificates can't be changed after they're created, so each renewal means creating a new certificate, switching the gateway to it, and cleaning up the old one.

Certificate Manager, SaaS automates that cycle. It discovers the custom certificates your API gateways serve and provisions renewed certificates to them.

**Value Highlights**

- **Discover custom certificates**: Report each API Gateway certificate in a compartment, with one installation for each API gateway that serves it.
- **Renew safely**: Create a new certificate resource, switch the gateway to it, and wait for OCI to confirm the gateway is active before deleting anything.
- **Clean up replaced certificates**: Delete the previous certificate once no other API gateway in the compartment uses it.
- **Protect existing names**: Refuse a certificate that would drop a DNS name or IP address the gateway serves today.
- **Connect directly**: Sign each request with an OCI API signing key, with no VSatellite.

**How it Works**

Each machine covers one compartment in one region. It uses a dedicated OCI user, that user's API signing key, and an IAM policy for API gateways, API Gateway certificates, and work requests in the compartment. Certificate Manager, SaaS follows each change through an OCI work request.

API gateways that use Oracle's default certificate, and certificates managed by the OCI Certificates service, aren't discovered or replaced. Provisioned certificates must use an RSA key of 2048 to 4096 bits.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- Oracle Cloud Infrastructure API Gateway
- OCI user with an API signing key and an IAM policy

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
