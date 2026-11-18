# Radware Alteon Load Balancer & ADC

Radware Alteon load balancers and application delivery controllers terminate TLS for the applications behind them, so each SSL-enabled virtual service needs a valid certificate. Next-Gen Trust Security discovers the certificates assigned to Alteon virtual services and provisions renewed certificates to them, so certificate changes stop being a manual, outage-prone task.

**Value Highlights**

- **Prevent outages**: provision renewed certificates to Alteon virtual services before the old ones expire.
- **Gain visibility**: discover the server certificate and intermediate chain on each virtual service.
- **Remove manual steps**: Next-Gen Trust Security imports the certificate and chain, creates or updates the SSL policy, and assigns both to the virtual service.
- **Apply changes safely**: the Alteon configuration is applied and saved after each change.
- **Renew on your schedule**: run discovery and provisioning on a daily, weekly or monthly schedule.

**How it Works**

Next-Gen Trust Security connects to the Alteon REST API through a VSatellite, using an Alteon administrator account. Discovery reads the server certificate assigned to each virtual service. Provisioning imports the certificate, its private key and its chain, groups the intermediates into a certificate group, creates or updates the SSL policy you name, and sets it on an existing virtual service. It never creates virtual servers or virtual services. See the Documentation tab for setup.

**Solution Components**

- Next-Gen Trust Security
- VSatellite
- Radware Alteon ADC
