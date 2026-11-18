# Google Cloud Load Balancing

Google Cloud load balancers terminate TLS with classic SSL certificates attached to their target proxies, and replacing those certificates by hand across projects and regions is easy to get wrong. Next-Gen Trust Security discovers the certificates on your load balancers and provisions renewed certificates to them, so cloud operations teams avoid certificate-related outages.

**Value Highlights**

- **Eliminate outages**: provision renewed certificates to load balancers before the old ones expire.
- **Gain visibility**: discover the classic SSL certificates attached to global target HTTPS proxies, global target SSL proxies and regional target HTTPS proxies in a project.
- **Automate replacement**: Next-Gen Trust Security creates the new certificate, swaps it into the proxy's certificate list and deletes the certificate it replaced.
- **Leave other certificates alone**: the proxy's other certificates stay attached.
- **Authenticate your way**: use a service account JSON key, the VSatellite VM's service account, or an OAuth2 access token.

**How it Works**

Next-Gen Trust Security connects to the Google Cloud APIs through a VSatellite, using a service account with the Compute Engine permissions the machine needs. One machine covers the load balancers in one Google Cloud project. Provisioning creates a classic SSL certificate resource, global or regional, and attaches it to the target proxy you name. Google Cloud Certificate Manager certificates and certificate maps aren't supported. See the Documentation tab for setup.

**Solution Components**

- Next-Gen Trust Security
- VSatellite
- Google Cloud Load Balancing
