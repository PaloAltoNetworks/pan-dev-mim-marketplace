# VMware NSX Load Balancer (formerly Avi Vantage)

Enforcing the use of HTTPs encryption is more important than ever but becomes more difficult to accomplish at scale. VMware and Venafi have teamed to make it easy to get started and fully automate the use of keys and certificates for load balancing ops teams.

The VMware NSX Load Balancer provides a Software Load Balancer, Intelligent Web Application Firewall (iWAF) and Elastic Service Mesh to ensure fast, scalable and secure application delivery. VMWare and Venafi have teamed to make it easy to get started and fully automate the use of keys and certificates for networking ops teams.

- **Scale use of HTTPS** without difficult setup or maintenance
- **Eliminate outages** with continuous key and certificate updates
- **Reduce risk** of security incidents from improperly handled keys
- **Gain the full benefits** of application delivery with complete automation
- **Secure and automated** distribution of keys and certificates
- **Fully automated** issuance and renewal
- **Integrate with SSL/TLS inspection** for full encrypted traffic visibility

The VMware NSX Load Balancer integration supports both Certificate Manager, Self-Hosted and Next-Gen Trust Security.

The complete user guide can be found in the [Venafi Documentation](https://docs.venafi.cloud/vaas/machines/vmware-nsx-avi/).

The complete user guide for this integration can be found in the [VMware Documentation Portal](https://docs.vmware.com/en/VMware-NSX-Advanced-Load-Balancer/22.1/Configuration_Guide/GUID-A25E91D4-0CB1-41A3-8F25-60BEEA5E644B.html). At a high level, when a new application is created or a new SSL/ TLS certificate is required, use the following workflow.

- From the Certificate Manager, Self-Hosted, create a new certificate for the NSX Advanced Load Balancer. Behind the scenes, the following happens:
  - Venafi sends the API calls necessary to generate a CSR on NSX Advanced Load Balancer and import it.
  - Venafi forwards the CSR to the configured certificate authority.
  - Venafi receives the signed certificate and key from the CA.
  - Venafi pushes the certificate and key to NSX Advanced Load Balancer, along with any required chain certificates.
- From the NSX Advanced Load Balancer, create a new application virtual service, attaching the certificate.

- Any subsequent updates to the certificate received by the Controller will automatically and transparently be pushed to Service Engines using the certificate.
- Venafi will learn the mapping of the virtual service name to the certificate. It will automatically handle certificate renewals.
