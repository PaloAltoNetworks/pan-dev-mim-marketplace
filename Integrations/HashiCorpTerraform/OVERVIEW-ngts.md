# HashiCorp Terraform

DevOps teams that need certificates faster than ad-hoc security processes allow often get them from unmanaged tools, which leaves the security team blind to certificates embedded across the infrastructure. The CyberArk Certificate Manager Provider for HashiCorp Terraform lets Terraform request certificates from Next-Gen Trust Security as part of a normal Terraform deployment, so teams get certificates automatically while the security team keeps visibility and policy control.

**Value Highlights**

- **Move faster**: Request keys and certificates in the same Terraform plan that builds the infrastructure, without waiting on manual requests.
- **Stay in policy**: Every certificate is issued under the policy defined in Next-Gen Trust Security.
- **Keep visibility**: The security team sees every certificate Terraform requests, even in infrastructure it does not own.
- **Retire cleanly**: When infrastructure is destroyed, the provider retires the associated certificate.

**How it Works**

The provider is open source and published to the Terraform Registry, so `terraform init` downloads it when a configuration references it. You configure the provider with a Palo Alto Networks service account (client ID and secret), your tenant service group (TSG) ID, and an issuing template as the zone. The `venafi_certificate` resource generates a key pair and requests a certificate, and the result is available to other resources in the same plan. See the Documentation tab for provider configuration.

**Applicability**

The provider suits any organization whose DevOps or application teams use HashiCorp Terraform to build development, test and production infrastructure. It supports Terraform 0.13 or later.

**Solution Components**

- Next-Gen Trust Security
- HashiCorp Terraform
- [CyberArk Certificate Manager Provider](https://registry.terraform.io/providers/Venafi/venafi/latest) ([source on GitHub](https://github.com/Venafi/terraform-provider-venafi))
