# MuleSoft Dedicated Load Balancer

MuleSoft CloudHub Dedicated Load Balancers terminate TLS for Mule applications through SSL endpoints, each with its own certificate. Renewing those certificates by hand in Runtime Manager across VPCs and load balancers takes time and risks an outage when one is missed.

Next-Gen Trust Security connects to MuleSoft Anypoint Platform to discover the certificates on your Dedicated Load Balancer SSL endpoints and renew them in place.

**Value Highlights**

- **Discover endpoint certificates**: Read the certificate each started load balancer serves and record one installation for each SSL endpoint.
- **Renew existing endpoints**: Replace the certificate and private key of an SSL endpoint while other endpoints, mapping rules, and the default endpoint stay unchanged.
- **Scope discovery**: Limit discovery to one environment, specific VPCs, or named load balancers.
- **Connect directly**: Sign in to Anypoint Platform with a Connected App on the US, EU, or Gov control plane, with no VSatellite.
- **Schedule changes**: Run discovery and provisioning daily, weekly, or monthly.

**How it Works**

You create a machine with the Anypoint organization or business group ID and the client ID and secret of a Connected App with the CloudHub Network Viewer permission for discovery and the CloudHub Network Administrator permission for provisioning. Provisioning renews only SSL endpoints that already exist, matched by common name.

The machine type supports CloudHub 1.0 Dedicated Load Balancers. It doesn't support CloudHub 2.0 or Anypoint Platform Private Cloud Edition. This machine type is currently a preview feature. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- MuleSoft Anypoint Platform with CloudHub 1.0 Dedicated Load Balancers
- Anypoint Connected App with CloudHub network permissions
