# Kemp LoadMaster

Kemp LoadMaster virtual services terminate TLS for the applications behind them. Uploading and assigning renewed certificates by hand on each LoadMaster is slow, and a missed renewal causes an outage.

Next-Gen Trust Security discovers the certificates on a Kemp LoadMaster and provisions certificates to its virtual services, so renewals reach the load balancer without manual uploads.

**Value Highlights**

- **See which services use each certificate**: discovery reads every certificate on the LoadMaster and records the virtual services that use it.
- **Focus on what's in use**: optionally skip expired certificates and certificates that no virtual service uses.
- **Install the full chain**: the certificate, private key and issuing chain are installed together and added to an existing virtual service.
- **Avoid name collisions**: a different certificate with an existing name gets a unique name based on its expiration date and serial number.
- **Use stored credentials**: connect with a LoadMaster account entered directly or held in a credential manager integration.

**How it Works**

The Kemp Virtual LoadMaster machine type connects through a VSatellite to the LoadMaster JSON API (/accessv2), which must be turned on. Next-Gen Trust Security finds the target virtual service by its IP address, port and protocol, and doesn't create virtual services.

See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Kemp LoadMaster with API access turned on
