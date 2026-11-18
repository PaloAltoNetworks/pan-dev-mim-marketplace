# Array Networks APV

Array Networks APV Series application delivery controllers keep applications and servers available, fast and secure. Every SSL virtual host needs a current certificate and key, and managing them by hand across appliances makes HTTPS hard to scale and leads to outages.

The Array Networks APV integration for Certificate Manager, Self-Hosted automates keys and certificates for load balancing teams. Certificate Manager, Self-Hosted discovers the certificates on your APV appliances, renews them under your policy, and installs and activates them on the right SSL virtual host.

**Value Highlights**

- **Scale HTTPS** without difficult setup or maintenance.
- **Eliminate outages** with continuous key and certificate updates.
- **Reduce the risk** of security incidents from improperly handled keys.
- **Automate issuance, renewal and distribution** of certificates for Array appliances.
- **Build a complete inventory** by discovering certificates already on your SSL virtual hosts.
- **Support SSL/TLS inspection** by keeping the certificates it depends on current.

**How it Works**

The integration is an Adaptable Application driver (`ArrayNetworks_ADC_Driver.ps1`) for Certificate Manager, Self-Hosted. It uses the APV RESTful API to import the certificate and private key to the SSL virtual host you specify, and can activate the certificate and enable the virtual host after installation. The driver uses TLS 1.2, which APV 8.6.x and 10.x require. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Array Networks APV Series ADC

**About Array Networks**

[Array Networks](https://www.arraynetworks.com/) provides application delivery, network functions virtualization and secure access solutions.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
