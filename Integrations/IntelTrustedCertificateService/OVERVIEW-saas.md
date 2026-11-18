# Intel® Trusted Certificate Service

The private key behind a certificate proves the identity of the server or workload that uses it, yet it is often protected in ways that are either expensive or risky. Data at rest is protected by encryption and data in transit by TLS, but keys in use in memory get little protection, and that risk grows as workloads move to public and hybrid clouds where hardware is shared. Intel® Software Guard Extensions (Intel® SGX) combined with Certificate Manager, SaaS protects private keys inside hardware-based secure enclaves, so machine identities are harder to misuse or compromise in on-premises, cloud and edge deployments.

**Value Highlights**

- **Minimize risk**: Reduce the chance of machine identity compromise while the private key is in use in memory.
- **Protect identities in untrusted environments**: Keep keys protected on shared or third-party infrastructure.
- **Use built-in hardware security**: Rely on the security features of SGX-enabled processors.
- **Reduce cost**: Lower the cost of operating and maintaining dedicated security hardware.
- **Stay transparent to app teams**: Add protection without disrupting application teams.
- **Generate and use keys securely**: Create and use keys inside the enclave.

**How it Works**

Intel SGX provides a hardware-based trusted execution environment. Intel® Trusted Certificate Service (TCS) is an open-source Kubernetes certificate signing solution, implemented as a cert-manager external issuer, that generates and uses its signing key inside SGX enclaves so the key is never stored in clear anywhere in the system. Certificate lifecycle management in Certificate Manager, SaaS combined with SGX key protection covers machine identities from issuance through use.

**Applicability**

TCS requires Kubernetes nodes with SGX-capable hardware, the Intel SGX device plugin and cert-manager. Intel has announced that the TCS project is no longer actively maintained (see the [project repository](https://github.com/intel/trusted-certificate-issuer)).

**Solution Components**

- Certificate Manager, SaaS
- Intel SGX-enabled servers
- Intel Trusted Certificate Service and cert-manager

**About Intel**

Intel designs the processors and platform technologies, including Intel SGX, that power data center, cloud and edge computing.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
