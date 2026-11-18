# Radware Cloud Web Application API Protection

Radware Cloud Web Application and API Protection (Cloud WAAP, shown as Radware Cloud WAF in Next-Gen Trust Security) serves TLS for the applications it protects, so each application needs a current certificate. Next-Gen Trust Security discovers the certificates in your Radware account and installs renewed certificates on the applications that use them, without manual uploads in the Radware Cloud Portal.

**Value Highlights**

- **Prevent outages**: assign renewed certificates to protected applications before the old ones expire.
- **Gain visibility**: discover every certificate in the Radware account and the applications that use it.
- **Deploy with confidence**: Next-Gen Trust Security confirms the application serves the new certificate, and rolls back to the previous certificate if the assignment fails.
- **Skip extra infrastructure**: connect directly to the Radware Cloud Services API with an API key, with no VSatellite.
- **Clean up safely**: optionally report or delete expired, unused certificates that cover the application's domain.

**How it Works**

Next-Gen Trust Security connects to the Radware Cloud Services API with an API key and your account's Application Protection ID. Discovery reports each certificate with the applications that use it. Provisioning uploads the certificate, chain and private key to your Radware account, assigns it to an existing application, and waits until the application serves it. Discovery and provisioning can run on a schedule. See the Documentation tab for setup.

**Solution Components**

- Next-Gen Trust Security
- Radware Cloud WAAP
