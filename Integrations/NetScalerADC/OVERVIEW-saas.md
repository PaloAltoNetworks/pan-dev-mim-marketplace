# NetScaler ADC

Load balancers front end many applications, so a single NetScaler ADC can host hundreds of certificates, one for each backend application it serves. Without automation it is hard to keep track of them all or renew them before they expire, and a missed renewal takes customer-facing services offline. Certificate Manager, SaaS integrates with NetScaler ADC so load balancing teams can automate key and certificate management at scale.

**Value Highlights**

- **Scale HTTPS** without difficult setup or maintenance.
- **Eliminate outages** with continuous key and certificate updates.
- **Reduce risk** of security incidents from improperly handled keys.
- **Discover existing certificates** already in use on your NetScaler ADC appliances.
- **Automate issuance and renewal** end to end.

**How it Works**

The NetScaler ADC machine type is built into Certificate Manager, SaaS, so there is nothing to install. You create a Citrix ADC machine that connects to the appliance's NITRO API through a VSatellite. Certificate Manager, SaaS then discovers the certificates bound to virtual servers, services and service groups, and provisions new and renewed certificates to them. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS, with a VSatellite
- NetScaler ADC (formerly Citrix ADC)

**About NetScaler**

[NetScaler](https://www.netscaler.com/) ADC, formerly Citrix ADC, is an application delivery controller that provides delivery services for traditional, containerized and microservice applications from your data center or any cloud.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
