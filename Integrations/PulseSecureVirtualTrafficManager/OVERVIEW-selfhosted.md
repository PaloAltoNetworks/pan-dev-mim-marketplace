# Pulse Secure Virtual Traffic Manager

Pulse Secure Virtual Traffic Manager (vTM), now part of Ivanti, is a software-based application delivery controller that load balances and secures traffic to business-critical applications. Each virtual server that terminates TLS needs a current certificate, and an expired one takes the application behind it offline. This integration lets Certificate Manager, Self-Hosted discover, install and renew the certificates on vTM automatically.

**Value Highlights**

- **Automate provisioning and renewal** of TLS certificates and keys on Pulse Secure vTM.
- **Eliminate outages** caused by expired certificates on virtual servers.
- **Discover existing certificates** bound to vTM virtual servers and bring them into inventory.
- **Bind automatically**: Set the renewed certificate as the virtual server's default certificate as part of each installation.

**How it Works**

The integration is an Adaptable Application driver (`Pulse-Secure-vTM.ps1`) for Certificate Manager, Self-Hosted. It connects to the vTM REST API on port 9070 with a username credential, uploads the certificate, chain and private key as an SSL server key, and binds it to the virtual server that matches the application object's name. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Pulse Secure (Ivanti) Virtual Traffic Manager

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
