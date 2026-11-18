# AWS KMS

## Prerequisites

- A Kubernetes cluster with cert-manager v1.17 or later.
- An AWS role that can create and use KMS keys, available to the kms-issuer controller.
- An asymmetric KMS key with `SIGN_VERIFY` usage, or permission for kms-issuer to create one.

## Installation

1. Install the controller from the official Helm chart:

   ```bash
   helm upgrade --install kms-issuer oci://ghcr.io/skyscanner/charts/kms-issuer --namespace kms-issuer-system --create-namespace
   ```

2. To install a specific version, add `--version <version>` to the command.

## Configuration

1. Create a `KMSKey` resource to provision a signing key, or use an existing KMS key.
2. Create a `KMSIssuer` that references the key ID or alias and sets the root certificate's common name and duration. The controller generates a root certificate signed by the KMS key.
3. Create cert-manager `Certificate` resources that reference the `KMSIssuer`.

By default, a certificate request must be approved before KMS signs it. See the [kms-issuer project](https://github.com/Skyscanner/kms-issuer) for full examples and options.

## Usage

To view the certificates cert-manager issues, connect the cluster to Certificate Manager, SaaS.
