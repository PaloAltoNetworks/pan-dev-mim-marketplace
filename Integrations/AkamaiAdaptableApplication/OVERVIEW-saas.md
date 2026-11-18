# Akamai Adaptable Application

Akamai manages certificates as part of the edge services it delivers, and those certificates need the same visibility and renewal discipline as the rest of your estate. Certificate Manager, SaaS connects to Akamai as a cloud provider, discovers your existing Akamai enrollments, and issues and provisions certificates to them.

**Value Highlights**

- **Discover Akamai certificates**: find the certificates on your Akamai enrollments, on demand or on a daily, weekly or custom schedule.
- **Issue and provision in one step**: enroll a discovered Akamai enrollment and have the issued certificate installed in Akamai CPS.
- **Use your chosen CA**: certificates are issued by the certificate authority selected in your request policy.
- **Keep key generation at Akamai**: Akamai generates the key and CSR for each enrollment.
- **Scope by contract**: limit each cloud keystore to a specific Akamai contract.

**How it Works**

You create an Akamai cloud provider under **Cloud Providers** using Akamai API client credentials with READ-WRITE access to the Certificate Provisioning System, and validate the connection. You then add an Akamai CDN cloud keystore to discover certificates. To issue, you choose **Enroll (Issue and provision)** on a discovered enrollment. Certificates are issued and provisioned only through discovered Akamai enrollments, and at least one VSatellite is required. See the Documentation tab for setup steps.

**Solution Components**

- Certificate Manager, SaaS
- VSatellite
- Akamai Certificate Provisioning System

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
