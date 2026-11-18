# Amazon Secrets Manager

Applications that read TLS certificates and private keys from Amazon Secrets Manager need those secrets updated every time a certificate is renewed. Doing that by hand across accounts and regions is slow and easy to miss.

Next-Gen Trust Security stores certificates as secrets in an Amazon Web Services (AWS) account and region, discovers the certificates already stored there, and writes each renewed certificate as a new version of the same secret, so the secret name never changes.

**Value Highlights**

- **Store certificates in the format your applications expect**: JSON, Kubernetes TLS (tls.crt, tls.key, ca.crt) or PKCS#12, with the issuing chain optional.
- **Renew without changing secret names**: each renewal writes a new version of the same secret and makes it the current version.
- **Find certificates already stored**: discovery reads certificates held as JSON, Kubernetes, PEM or password-less PKCS#12 secrets, filtered by a tag you choose.
- **Leave other secrets untouched**: Next-Gen Trust Security writes only to secrets tagged venafi:managed=true and never deletes secrets.
- **Use your own encryption key**: new secrets can be encrypted with a customer-managed AWS KMS key instead of the AWS-managed key.
- **Trace secrets back to certificates**: each managed secret is tagged with the certificate's serial number and expiration date.

**How it Works**

An Amazon Secrets Manager machine connects to one AWS region with the access keys of an IAM user that holds a small set of secretsmanager permissions. Create one machine for each region you use, including AWS GovCloud (US) and China regions.

Each provisioned certificate and its private key are stored together in one secret, optionally under a name prefix set on the machine. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Amazon Secrets Manager in your AWS account
