# Akeyless Vault Platform for cert-manager

Kubernetes teams use cert-manager to obtain and renew certificates inside their clusters, but certificates issued directly by a secrets platform can escape the policy and visibility that the security team applies elsewhere.

With Akeyless and open-source cert-manager, Kubernetes workloads get certificates from the Akeyless Vault Platform while either Certificate Manager, SaaS or Akeyless acts as the issuer. Requesting and installing certificates in clusters becomes automatic, and issuance stays under your policy.

**Value Highlights**

- **Remove manual steps and risk** from requesting and installing certificates in Kubernetes.
- **Obtain, renew and manage** cluster certificates with standard cert-manager resources.
- **Protect CA keys** with Akeyless Distributed Fragments Cryptography (DFC) when Akeyless is the issuer.
- **Keep policy control** by issuing through Certificate Manager, SaaS zones.
- **Authenticate cert-manager to Akeyless** with Kubernetes authentication or an API key.

**How it Works**

An Akeyless Gateway hosts a Venafi dynamic secret that connects to Certificate Manager, SaaS. In the cluster, a cert-manager Issuer of type vault points to the gateway and to that dynamic secret's `pki/sign/` path, using a Kubernetes Secret that holds Akeyless credentials. cert-manager then requests certificates from Akeyless for each Certificate resource and renews them before they expire. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, SaaS
- Akeyless Vault Platform with an Akeyless Gateway
- cert-manager in a Kubernetes cluster

**About Akeyless**

[Akeyless](https://docs.akeyless.io/) provides a SaaS secrets management platform that secures credentials, certificates and keys across hybrid and multi-cloud environments.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
