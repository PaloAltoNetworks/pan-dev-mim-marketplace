# HashiCorp Terraform

## Prerequisites

- HashiCorp Terraform 0.13 or later.
- A Certificate Manager, SaaS API key. Find it by clicking your name in the top right of the web interface.
- A `zone`, formed from an application name and issuing template API alias, for example `Business App\Enterprise CIT`.

## Installation

The provider is published to the [Terraform Registry](https://registry.terraform.io/providers/Venafi/venafi/latest). `terraform init` downloads it when a configuration references it, so no separate installation is needed.

## Configuration

The US API URL is the default. Tenants in other regions set `url`, for example `https://api.venafi.eu` for EU tenants.

```hcl
provider "venafi" {
  api_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  zone    = "Business App\\Enterprise CIT"
}

resource "venafi_certificate" "webserver" {
  # ...
}
```

## Usage

See the [provider documentation](https://registry.terraform.io/providers/Venafi/venafi/latest/docs) for the full argument reference, regional API URLs, and the `venafi_certificate` and `venafi_cloud_keystore_installation` resources.
