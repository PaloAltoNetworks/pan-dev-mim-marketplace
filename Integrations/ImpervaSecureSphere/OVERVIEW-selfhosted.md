# Imperva SecureSphere

A web application firewall can only stop attacks it can see, and most web traffic is encrypted. To inspect HTTPS traffic, Imperva SecureSphere needs the same keys and certificates as the web servers it protects, and those keys change every time a certificate is renewed. Certificate Manager, Self-Hosted distributes keys and certificates to Imperva SecureSphere automatically, so the firewall keeps inspecting encrypted traffic and detecting threats.

**Value Highlights**

- **Get started fast**: Use your existing key and certificate inventory.
- **Maximize WAF utilization**: Use full key and certificate discovery so the firewall can inspect more traffic.
- **Maintain protection**: Keep WAF inspection in place with a fully automated lifecycle and key distribution.
- **Distribute immediately**: Push keys that are already discovered to the firewall.
- **Follow every renewal**: Distribute replacement keys automatically when new keys are generated.

**How it Works**

Certificate Manager, Self-Hosted includes a built-in Imperva MX driver. The driver provisions certificate and private key pairs to the Imperva SecureSphere Management Server (MX), which synchronizes them to Imperva web application firewalls and database firewalls. You can associate each key pair with the matching site, server group and service in the SecureSphere tree. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Imperva SecureSphere Management Server (MX) and the firewalls it manages

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
