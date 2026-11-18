# Cisco ISE

Cisco Identity Services Engine (ISE) uses system certificates for its admin portal, EAP authentication, RADIUS DTLS, guest portals, pxGrid and SAML. When one of those certificates expires, administrators can lose management access and users can fail network authentication.

Certificate Manager, SaaS discovers the system certificates on every node of an ISE deployment and provisions renewed certificates to them, so renewals no longer depend on manual work in each node's admin portal.

**Value Highlights**

- **Cover the whole deployment from one machine**: Certificate Manager, SaaS reads the node list from the Primary Policy Administration Node and discovers certificates on every node.
- **Assign certificates to ISE services**: install a certificate and assign it to Admin, EAP Authentication, RADIUS DTLS, Portal, pxGrid, SAML or ISE Messaging Service.
- **Keep trust chains complete**: the certificate's issuing chain is imported into the deployment's trusted certificate store before the certificate is installed.
- **Renew during a window you choose**: scheduled provisioning pushes renewed certificates at the times you set.
- **Use stored credentials**: connect with an ISE administrator account entered directly or held in a credential manager integration.

**How it Works**

A Cisco ISE machine connects through a VSatellite to the Cisco ISE Open API (port 9070 by default) on the Primary Policy Administration Node, using an administrator account in the ERS Admin group or with the Super Admin role. Provisioning connects to each node directly, so the Open API must be turned on for every node.

Assigning the Admin usage restarts the application server on the node, and Certificate Manager, SaaS confirms the usage change after the node comes back.

See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- Cisco Identity Services Engine (ISE)
- A VSatellite that can reach every ISE node

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
