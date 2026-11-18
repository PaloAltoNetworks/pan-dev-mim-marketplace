# HashiCorp Terraform

## Prerequisites

- HashiCorp Terraform 0.13 or later.
- The URL of the Certificate Manager, Self-Hosted REST API and permission to use it.
- The distinguished name of a policy folder to use as the `zone`. The user needs `View`, `Read`, `Write` and `Create` permissions on it.
- An access token for the `hashicorp-terraform-by-venafi` API application with the `certificate:manage` scope. Get it with the [VCert CLI](https://github.com/Venafi/vcert/blob/master/README-CLI-PLATFORM.md#obtaining-an-authorization-token) `getcred` action or the Authorize REST API method. The `configuration:manage` scope is also needed to set policy with the `venafi_policy` resource.
- A trust bundle with the root CA certificate, if the REST API URL uses a certificate your Terraform host does not trust.

## Installation

The provider is published to the [Terraform Registry](https://registry.terraform.io/providers/Venafi/venafi/latest). `terraform init` downloads it when a configuration references it, so no separate installation is needed.

## Configuration

```hcl
provider "venafi" {
  url          = "https://tpp.venafi.example"
  trust_bundle = "${file("/opt/venafi/bundle.pem")}"
  access_token = "p0WTt3sDPbzm2BDIkoJROQ=="
  zone         = "DevOps\\Terraform"
}

resource "venafi_certificate" "webserver" {
  # ...
}
```

## Usage

See the [provider documentation](https://registry.terraform.io/providers/Venafi/venafi/latest/docs) for the full argument reference and the `venafi_certificate` and `venafi_policy` resources.
