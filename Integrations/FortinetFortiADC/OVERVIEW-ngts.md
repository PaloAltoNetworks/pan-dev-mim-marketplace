# Fortinet FortiADC

Fortinet FortiADC virtual servers present TLS certificates to clients through client SSL profiles and local certificate groups. Tracking which certificate each virtual server serves, and replacing it before it expires, is manual work on every appliance.

Next-Gen Trust Security finds the TLS certificates your virtual servers present and installs renewed certificates on the appliance, so every virtual server that uses a local certificate group serves the new certificate.

**Value Highlights**

- **Map certificates to virtual servers**: discovery records each certificate's virtual domain, local certificate group, client SSL profile, virtual server and port.
- **Renew without rebinding**: a renewed certificate is uploaded under a new name and the existing entry in the local certificate group points at it, without interrupting live traffic.
- **Keep chains with certificates**: the issuing chain is uploaded to an intermediate CA group created for each certificate.
- **Work with virtual domains**: discover every virtual domain from one machine, or create one machine per virtual domain for least privilege.
- **Use a scoped API key**: connect with a REST API administrator account whose access profile grants read-write System and read-only Server Load Balance access.

**How it Works**

A Fortinet FortiADC machine connects to the FortiADC REST API through a VSatellite with an API key, and requires FortiADC version 7.2 or later. Discovery reads each certificate from a TLS connection to the enabled virtual server that serves it.

Next-Gen Trust Security provisions to local certificate groups that already exist and doesn't create or change client SSL profiles or virtual servers. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Fortinet FortiADC 7.2 or later
