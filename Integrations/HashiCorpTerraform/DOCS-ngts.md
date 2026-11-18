# HashiCorp Terraform

## Prerequisites

- HashiCorp Terraform 0.13 or later.
- A Palo Alto Networks service account (client ID and client secret) with access to Next-Gen Trust Security.
- Your tenant service group (TSG) ID.
- The name of the issuing template to use as the `zone`, for example `Enterprise CIT`.

## Installation

The provider is published to the [Terraform Registry](https://registry.terraform.io/providers/Venafi/venafi/latest). `terraform init` downloads it when a configuration references it, so no separate installation is needed.

## Configuration

```hcl
provider "venafi" {
  url           = "https://api.strata.paloaltonetworks.com/ngts"
  client_id     = "your-service-account@panserviceaccount.com"
  client_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  token_url     = "https://auth.apps.paloaltonetworks.com/auth/v1/oauth2/access_token"
  tsg_id        = "1234567890"
  zone          = "Built-In CA Open Policy"
}

resource "venafi_certificate" "webserver" {
  # ...
}
```

## Usage

See the [provider documentation](https://registry.terraform.io/providers/Venafi/venafi/latest/docs) for the full argument reference and the `venafi_certificate` resource.
