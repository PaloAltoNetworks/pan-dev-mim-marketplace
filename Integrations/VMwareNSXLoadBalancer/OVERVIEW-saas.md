# VMware NSX Load Balancer (formerly Avi Vantage)

Enforcing HTTPS everywhere matters more than ever, but keeping certificates current across load balancers becomes difficult at scale. VMware NSX Advanced Load Balancer provides a software load balancer, web application firewall and service mesh for fast, scalable and secure application delivery. With Certificate Manager, SaaS, load balancing teams can discover the certificates on their controllers and fully automate certificate provisioning and renewal.

**Value Highlights**

- **Scale HTTPS**: Expand the use of HTTPS without difficult setup or maintenance.
- **Eliminate outages**: Keep certificates continuously updated before they expire.
- **Reduce risk**: Avoid security incidents caused by improperly handled keys.
- **Gain visibility**: Discover the TLS certificates in the controller's tenants.
- **Automate delivery**: Issue, renew and provision certificates to virtual services automatically.

**How it Works**

You create a VMware NSX Advanced Load Balancer (AVI) machine in Certificate Manager, SaaS. It connects to the controller through a VSatellite using a controller account with administrative permissions in the admin tenant and in every tenant you manage. Certificate Manager, SaaS then discovers the certificates in those tenants and provisions new and renewed certificates to the controller's virtual services. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- VSatellite
- VMware NSX Advanced Load Balancer controller

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
