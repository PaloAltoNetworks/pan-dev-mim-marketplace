## Installation

The complete user guide for this integration is in the [VMware Documentation Portal](https://docs.vmware.com/en/VMware-NSX-Advanced-Load-Balancer/22.1/Configuration_Guide/GUID-A25E91D4-0CB1-41A3-8F25-60BEEA5E644B.html).

## Usage

When a new application is created or a new TLS certificate is required, use the following workflow:

1. In Certificate Manager, Self-Hosted, create a new certificate for the NSX Advanced Load Balancer. Behind the scenes, Certificate Manager, Self-Hosted:
    1. Sends the API calls needed to generate a CSR on the NSX Advanced Load Balancer and import it.
    2. Forwards the CSR to the configured certificate authority.
    3. Receives the signed certificate from the CA.
    4. Pushes the certificate to the NSX Advanced Load Balancer, along with any required chain certificates.
2. In the NSX Advanced Load Balancer, create a new application virtual service and attach the certificate.

After this:

- Any later updates to the certificate received by the Controller are pushed automatically and transparently to the Service Engines that use the certificate.
- Certificate Manager, Self-Hosted learns the mapping of the virtual service name to the certificate and handles certificate renewals automatically.
