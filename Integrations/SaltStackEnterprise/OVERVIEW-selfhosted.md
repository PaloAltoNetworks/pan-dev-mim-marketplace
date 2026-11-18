# SaltStack Enterprise

Orchestration lets enterprises move fast, but automating HTTPS has traditionally required custom code and integration work. The Salt Venafi runner connects Salt to Certificate Manager, Self-Hosted, so teams can request and renew policy-enforced certificates for their minions as part of the same orchestration that deploys and scales their applications.

**Value Highlights**

- **Eliminate the hassle** and risk of requesting and installing keys and certificates with native Salt integration.
- **Scale elastically** without the constraints of traditional certificate request processes.
- **Enforce policy**: Every certificate is issued under your Certificate Manager, Self-Hosted policy.
- **Set up quickly**: Configure the connection once in the Salt master configuration.
- **Fit DevOps workflows**: Use certificates in continuous delivery and automation, including through Salt Pillar.

**How it Works**

Salt includes a Venafi runner module that uses the VCert Python library. You configure the Certificate Manager, Self-Hosted URL, credentials and trust bundle in the Salt master configuration, then use `salt-run venafi.request` and `salt-run venafi.renew` to obtain and renew certificates for a minion from a policy zone. The runner keeps a cache of requested domains and certificates on the master. See the Documentation tab for the runner reference.

**Solution Components**

- Certificate Manager, Self-Hosted
- Salt (SaltStack Enterprise) master and minions
- VCert Python library

**About Salt Project**

[Salt](https://saltproject.io/) is an open-source orchestration and configuration management platform for securing and managing infrastructure across data centers and clouds.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
