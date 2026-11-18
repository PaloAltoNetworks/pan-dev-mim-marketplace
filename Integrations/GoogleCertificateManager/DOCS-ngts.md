# Google Certificate Manager

## Prerequisites

- Access to enable the IAM API, Cloud Resource Manager API and Certificate Manager API in your Google Cloud project.
- The Google Cloud CLI, installed and authenticated.
- At least one active VSatellite to provision certificates to Google Cloud.
- A Google service account with the permissions Next-Gen Trust Security needs, or a Workload Identity Federation setup.

## Configuration

1. Create a Google custom role with the permissions Next-Gen Trust Security needs.
2. Create a Google service account and assign it the custom role.
3. Enable the required Google APIs in the project.
4. Create a Google Cloud Platform cloud provider in Next-Gen Trust Security and validate the connection.
5. Add a Google cloud keystore for the project and Google Certificate Manager region.

## Usage

1. Run discovery on the cloud keystore to import the certificates it holds, optionally on a schedule.
2. Provision a certificate from your Next-Gen Trust Security inventory to the cloud keystore.
