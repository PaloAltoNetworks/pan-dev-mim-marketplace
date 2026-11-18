# HID PKIaaS

HID PKIaaS is a cloud-based PKI-as-a-Service from HID Global that issues private and publicly trusted TLS certificates. Next-Gen Trust Security connects to HID PKIaaS as a certificate authority, so you can issue certificates from your HID PKIaaS policies and import the certificates you already have into one inventory.

**Value Highlights**

- **Use a cloud-based certificate authority**: issue certificates from HID PKIaaS without operating your own CA infrastructure.
- **Import existing certificates**: bring certificates issued under your HID PKIaaS policies into your inventory, including revoked or expired ones if you choose.
- **Keep the inventory current**: schedule recurring imports or run them on demand.
- **Enforce policy**: add the HID PKIaaS CA to request policies so certificates are requested under your rules.
- **Track domain validation**: see the domains registered with your HID PKIaaS account and their validation status.

**How it Works**

You add an HID PKIaaS CA under **Certificate Authorities** with your instance URL and an API key ID and key from an HID PKIaaS account. The Service Requestor role is recommended for that account. You then select the certificate policies to use, set import options, and add the CA to one or more request policies. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- HID PKIaaS
