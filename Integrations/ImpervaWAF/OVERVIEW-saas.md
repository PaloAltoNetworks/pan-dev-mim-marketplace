# Imperva WAF

Web application attacks deny services and steal sensitive data. Imperva Web Application Firewall (WAF) analyzes and inspects requests coming into applications and stops these attacks. But traditional security controls are blind to these attacks and underperform without the proper visibility. Venafi makes it easy to unlock encrypted traffic with your Imperva WAF and stop attacks at the firewall.

  

**SOLUTION HIGHLIGHTS**

- **Get started fast **with inventories of existing keys and certificates 
- **Maximize WAF utilization **with full discovery of keys and certificates 
- **Maintain WAF inspection levels **with fully automated lifecycle and key distribution 
- **Installed SSL certificates **on each site are monitored for expiration and network validation

  

**SOLUTION OVERVIEW**

Imperva is a cloud web application firewall that is used to protect websites against attacks. One of the features is site forwarding. Site forwarding can use custom certificates that will be served with the SSL connection to the site. Using this driver, all these site certificates can be managed by the Venafi Certificate Manager. It allows for discovery of all sites and certificates associated with an API key. It also allows for the external creation and subsequent upload to an Imperva protected site.

  

With this Venafi-developed Adaptable Application Driver enables the following:

  

Imperva WAF Provisioning

- Install-Certificate: The driver pushes a certificate to the custom certificate settings section of the Imperva site.

  

Imperva WAF Discovery

- Discover-Certificates: The driver calls the /v1/sites/list endpoint in Imperva to get a list of all the sites for an account. It then connects to each site and get the SSL certificate if it is served one. These are sent back to the discovery job to be handled by the Venafi Platform.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
