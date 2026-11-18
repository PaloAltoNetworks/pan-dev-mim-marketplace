# Apache Certificate Provisioning Connector

Apache HTTP Server deployments need their certificates and keys renewed on time, placed in the right locations and protected with the right file ownership and permissions. Doing this by hand across many servers causes outages from expired or misconfigured certificates and creates compliance risk.

The Apache Certificate Provisioning Connector from Secur Solutions automates this for Certificate Manager, SaaS. Certificates that Certificate Manager, SaaS issues and manages are provisioned to your Apache instances with the correct locations, ownership and permissions.

**Value Highlights**

- **Automate Apache certificates end to end**, from issuance through deployment and renewal.
- **Prevent downtime** from expired or misconfigured certificates.
- **Harden security** by setting ownership and permissions on certificate and key files.
- **Run custom post-provisioning commands**, such as restarting Apache, reloading configuration or updating monitoring agents.
- **Extend DevOps workflows** with your own scripts after each deployment.

**How it Works**

The connector adds Apache provisioning to Certificate Manager, SaaS and connects to each Apache server over SSH. After it places the certificate and key files, it runs any number of shell commands you configure, either as the connecting SSH user or with sudo privileges. Contact Secur Solutions for setup documentation.

**Solution Components**

- Certificate Manager, SaaS
- Apache HTTP Server

**About Secur Solutions Group**

[Secur Solutions Group](https://secursolutionsgroup.com/) is a Singapore-based identity and digital security company that builds integrations for CyberArk certificate management products.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
