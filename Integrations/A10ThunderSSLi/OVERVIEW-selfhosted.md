# A10 Thunder SSLi

Attackers use encrypted traffic to hide malware and move through networks. A10 Thunder SSLi (SSL Insight) decrypts that traffic so your security devices can inspect it, but inspection only works when Thunder SSLi has the current key and certificate for every protected server. A missing or expired key creates a gap in visibility.

The integration between Certificate Manager, Self-Hosted and A10 Thunder SSLi keeps those keys and certificates current. Certificate Manager, Self-Hosted delivers renewed certificates and keys to Thunder SSLi automatically, so decryption and inspection continue without manual updates.

**Value Highlights**

- **Reduce the risk of security incidents** caused by improperly handled keys.
- **Close visibility gaps** by provisioning renewed certificates before the old ones expire.
- **Scale HTTPS inspection** without difficult setup or maintenance.
- **Eliminate outages** with continuous key and certificate updates.
- **Build a complete inventory** of the machine identities used for decryption.

**How it Works**

Certificate Manager, Self-Hosted manages the lifecycle of the certificates and private keys that Thunder SSLi uses to decrypt inbound traffic. The integration uses the Adaptable Application framework to push each renewed certificate and key to the Thunder SSLi device, so the device always holds the keys it needs to decrypt and pass traffic to your inspection tools. Policy in Certificate Manager, Self-Hosted controls key strength and renewal timing.

**Solution Components**

- Certificate Manager, Self-Hosted
- A10 Thunder SSLi

**About A10 Networks**

[A10 Networks](https://www.a10networks.com/) provides secure application services and solutions, including high-performance application delivery and SSL inspection products, that keep business-critical applications secure and available.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
