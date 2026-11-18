# ACME

CAs such as Let's Encrypt have made it easy for application owners to get publicly trusted certificates without complex verification steps or human involvement. When each team requests certificates on its own, though, the organization loses visibility and control over which certificates exist and which CA policy they follow.

The ACME Adaptable CA driver lets Certificate Manager, Self-Hosted request, renew and revoke certificates from any CA that implements the ACMEv2 protocol. You keep the ease of ACME issuance and add the inventory, policy and automation of Certificate Manager, Self-Hosted.

**Value Highlights**

- **See and manage every certificate** from a single interface, including those issued by ACME CAs.
- **Reduce risk by centralizing CA policy** in Certificate Manager, Self-Hosted instead of delegating it to application owners.
- **Request, renew and revoke** TLS certificates with a built-in ACMEv2 client.
- **Automate domain validation** with any Posh-ACME DNS plugin, with plugin credentials stored in a credential object instead of hardcoded.
- **Connect to private CAs** with External Account Binding and proxy support.
- **Extend existing automation** so applications already managed by Certificate Manager, Self-Hosted can use ACME CAs.

**How it Works**

The driver is an Adaptable CA driver (`AcmeAdaptableCA.ps1`) that runs on your Certificate Manager, Self-Hosted servers and uses the Posh-ACME PowerShell module as its ACMEv2 client. You create an Adaptable CA template that points to the CA's ACME directory URL and a per-CA configuration directory. The driver completes DNS-01 domain validation through your DNS provider's Posh-ACME plugin when the CA requires it. See the Documentation tab for installation and configuration.

**Solution Components**

- Certificate Manager, Self-Hosted
- Any CA that implements the ACMEv2 protocol, such as Let's Encrypt
- The Posh-ACME PowerShell module and OpenSSL

**About ACME**

ACME (Automated Certificate Management Environment) is a protocol for automating certificate issuance and domain validation without user interaction. It was designed by the Internet Security Research Group (ISRG) for its Let's Encrypt service.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
