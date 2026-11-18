# Thycotic Adaptable Credentials

## Prerequisites

- Certificate Manager, Self-Hosted
- A Thycotic (Delinea) Secret Server instance reachable from the Certificate Manager, Self-Hosted server
- An account authorized to read the target secrets from Secret Server

## Installation

1. Copy `ThycoticAdaptableCredential.ps1` into the Adaptable Credential scripts directory on the Certificate Manager, Self-Hosted server.

## Configuration

1. In the Policy Tree, add an Adaptable Credential object and select the Thycotic driver.
2. Set the **Secret Identifier** field to the identifier of the secret in Secret Server.
3. Reference the resulting credential object from any object that consumes a credential, such as a CA template, application driver or discovery job.

## Usage

When a consuming object needs the credential, the driver fetches the current value from Secret Server, so rotations performed in the vault are picked up without re-entering secrets in Certificate Manager, Self-Hosted.
