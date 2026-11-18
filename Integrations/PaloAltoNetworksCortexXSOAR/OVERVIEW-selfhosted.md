# Palo Alto Networks Cortex XSOAR

TLS certificates are a core security asset, and their number keeps growing as certificate lifetimes get shorter. Security Operations Center (SOC) teams need certificate context during investigations and response, but switching between consoles slows them down. The Cortex XSOAR integration brings certificate data from Certificate Manager, Self-Hosted into Cortex XSOAR, so SOC teams can use it in playbooks and automations instead of looking it up by hand.

**Value Highlights**

- **Bring certificate context into the SOC**: Query certificates managed by Certificate Manager, Self-Hosted from the Cortex XSOAR War Room, CLI or playbooks.
- **Find certificates fast**: Search by subject attributes, issuer, key algorithm, creation date, lifecycle stage, error state or policy folder.
- **Speed up mitigation**: Use certificate details in automated workflows to respond to certificate-related issues and outages sooner.
- **Reduce manual effort**: Replace console lookups with automation, cutting time spent and human error.

**How it Works**

The integration is part of the CyberArk Certificate Manager Self-Hosted content pack for Cortex XSOAR. It connects to the Certificate Manager, Self-Hosted API with a username, password and OAuth client ID, and provides commands to search certificates (`venafi-get-certificates`) and retrieve full details for a certificate (`venafi-get-certificate-details`). Results can be used in any playbook. See the Documentation tab for configuration.

**Applicability**

Available on Cortex XSOAR 6.9.0 and later, Cortex XSIAM and Cortex XPANSE. Requires active licenses for Certificate Manager, Self-Hosted and the Cortex platform.

**Solution Components**

- Certificate Manager, Self-Hosted
- Palo Alto Networks Cortex XSOAR, Cortex XSIAM or Cortex XPANSE

**About Palo Alto Networks**

[Palo Alto Networks](https://www.paloaltonetworks.com/) provides cybersecurity platforms and services, including the Cortex security operations platform.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
