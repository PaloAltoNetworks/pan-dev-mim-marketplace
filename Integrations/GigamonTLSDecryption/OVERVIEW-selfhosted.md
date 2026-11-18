# Gigamon TLS Decryption

The inability to decrypt traffic at vital ingress and egress points poses great risk to an organization. When the keys and certificates used for TLS decryption are invalid or expired, threats hidden in encrypted traffic go undetected.

With this Gigamon integration, Certificate Manager, Self-Hosted manages the lifecycle of the keys and certificates used for GigaSMART Inline SSL decryption on GigaVUE nodes. Automated delivery of certificate and key pairs limits gaps in traffic inspection during certificate renewal.

**Value Highlights**

- **Get started fast** with your existing key and certificate inventory.
- **Maintain inspection** with automated lifecycle management and key distribution.
- **Close renewal gaps** by distributing replacement keys automatically when new keys are generated.
- **Provision at scale** with scheduled bulk provisioning jobs for each GigaVUE node.
- **Clean up old keys** by removing certificates from the node key store when they are revoked.

**How it Works**

A PowerShell driver for the Certificate Manager, Self-Hosted Adaptable Bulk provisioning framework connects over HTTPS to the GigaVUE-FM API. A bulk provisioning job sends the certificates and private keys from one or more policy folders to the key store of a specific GigaVUE node managed by GigaVUE-FM, where decryption takes place. GigaVUE-FM options can enable each new certificate automatically and delete older certificates for the same entity. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Gigamon GigaVUE-FM
- GigaVUE HC Series nodes with GigaSMART Inline SSL

**About Gigamon**

[Gigamon](https://www.gigamon.com) provides deep observability across hybrid and multi-cloud networks.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
