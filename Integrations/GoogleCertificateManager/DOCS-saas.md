# Google Certificate Manager

## Prerequisites

- A Google Cloud project that uses Google Certificate Manager.
- Permission to create custom roles and service accounts and to enable APIs in the project.

## Configuration

1. Create a Google custom role with the permissions Certificate Manager, SaaS needs.
2. Create a Google service account and assign it the custom role.
3. Enable the required Google APIs in the project.
4. Create a Google Cloud Platform cloud provider in Certificate Manager, SaaS and validate the connection.
5. Add a Google cloud keystore for the project and Google Certificate Manager region.

## Usage

1. Run discovery on the cloud keystore to import the certificates it holds, optionally on a schedule.
2. Provision a certificate from your Certificate Manager, SaaS inventory to the cloud keystore.
