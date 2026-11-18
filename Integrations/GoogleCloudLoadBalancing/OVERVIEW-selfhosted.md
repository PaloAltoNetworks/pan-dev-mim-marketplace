# Google Cloud Load Balancing

Google Cloud Load Balancing is a fully distributed, software-defined managed service, so cloud operations teams don't run physical load balancers, but they still have to keep the TLS certificates on their HTTPS load balancers current. Certificate Manager, Self-Hosted automates provisioning of those certificates to Google Cloud, which reduces or eliminates certificate-related outages.

**Value Highlights**

- **Scale the use of HTTPS**: deploy certificates to load balancers without difficult setup and maintenance.
- **Maintain infrastructure agility**: manage Google Cloud certificates with the same policy as the rest of your environment.
- **Eliminate outages**: keep keys and certificates updated continuously.
- **Secure distribution**: install keys and certificates through the Google Cloud API instead of by hand.
- **Automate issuance and renewal**: request, renew and install certificates from one place.

**How it Works**

Certificate Manager, Self-Hosted includes a Google Cloud Load Balancer driver, so there is nothing extra to install. The driver authenticates with a Google service account key stored in a Google Credential, and installs certificates on the global and regional HTTPS proxies used by external and internal HTTPS load balancers. Certificates must use RSA-2048 or ECDSA P-256. See the Documentation tab for the integration guide.

**Solution Components**

- Certificate Manager, Self-Hosted
- Google Cloud Load Balancing

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
