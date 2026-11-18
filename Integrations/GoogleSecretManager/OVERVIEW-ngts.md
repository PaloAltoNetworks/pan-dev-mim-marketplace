# Google Secret Manager

Applications on Google Cloud often read their TLS certificates and private keys from Google Secret Manager. Keeping those secrets current as certificates renew is easy to get wrong across many projects.

Next-Gen Trust Security discovers the certificates stored in your secrets and provisions certificates to them. When a certificate is renewed, Next-Gen Trust Security adds a new version to the same secret, so applications that read the latest version get the renewed certificate on their next read, with no restart.

**Value Highlights**

- **Pick the storage format your application reads**: JSON, Kubernetes TLS, PEM, password-protected PKCS#12 or Java KeyStore (JKS).
- **Manage many projects from one machine**: one service account key reaches every project it has access to, optionally limited by an allowed project list.
- **Choose location and encryption**: global or regional secrets, automatic or user-managed replication, and an optional customer-managed Cloud KMS key.
- **Leave other secrets untouched**: Next-Gen Trust Security writes only to secrets labeled venafi-managed=true.
- **Control older versions**: disable previous secret versions on each push, or keep them enabled for rollback.

**How it Works**

A Google Secret Manager machine signs in to Google Cloud with a service account JSON key. The service account needs a custom IAM role with the Secret Manager permissions for discovery and provisioning, granted only on the projects you want managed. Each managed secret is labeled with the certificate's serial number and expiration date.

This machine type manages certificates stored in secrets. Using Google Secret Manager as a credential manager for machine sign-in is a separate setup. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Google Secret Manager in your Google Cloud projects
