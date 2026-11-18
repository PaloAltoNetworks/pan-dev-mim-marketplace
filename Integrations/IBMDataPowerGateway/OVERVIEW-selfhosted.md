# IBM DataPower Gateway

IBM DataPower Gateway secures and integrates APIs, web services, mobile, B2B and cloud workloads, and each of those services depends on certificates installed on the appliance. Certificate Manager, Self-Hosted automates the full certificate lifecycle on DataPower, provisioning keys and certificates and binding them to the SSL profiles that secure DataPower workloads.

**Value Highlights**

- **Automate the lifecycle**: Enroll, provision, monitor, renew and revoke certificates on DataPower.
- **Provision keys and certificates**: Generate the private key and CSR, then install the key and certificate on the device.
- **Bind to SSL profiles**: Associate certificates with SSL Client, Server and Proxy profiles.
- **Manage trust**: Provision certificates into the DataPower trust store.
- **Prevent outages**: Renew certificates manually or automatically ahead of expiration.

**How it Works**

Certificate Manager, Self-Hosted includes a built-in DataPower driver. You create a DataPower application object for each appliance. During provisioning, Certificate Manager, Self-Hosted generates the private key and CSR, retrieves the certificate from the CA, installs both on the device, creates Identification and Validation Credential objects, and associates the certificate with the configured SSL Client, Server or Proxy profiles. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- IBM DataPower Gateway

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
