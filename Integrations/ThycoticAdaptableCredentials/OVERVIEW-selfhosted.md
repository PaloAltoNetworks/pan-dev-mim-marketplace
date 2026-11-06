# Thycotic Adaptable Credentials

This driver lets you create an Adaptable Credential object in Certificate Manager, Self-Hosted (formerly Venafi Trust Protection Platform) that references `username`/`password` or `password` credentials stored in the Thycotic (Delinea) Secret Server. Instead of holding a copy of the secret in Venafi, the credential is retrieved from Thycotic on demand, so secrets stay centralized in the vault.

## How it works

The `ThycoticAdaptableCredential.ps1` script implements the Venafi Adaptable Credential framework. It resolves a secret in Thycotic Secret Server by its **Secret Identifier** (a required, policyable field on the credential object) and returns the stored credential to Venafi for use by other objects — CA templates, application drivers, and discovery jobs — that consume a credential.

## Prerequisites

- Certificate Manager, Self-Hosted (Trust Protection Platform)
- A Thycotic (Delinea) Secret Server instance reachable from the Venafi server
- An account authorized to read the target secrets from Secret Server

## Installation and configuration

1. Copy `ThycoticAdaptableCredential.ps1` into the Adaptable Credential scripts directory on the Venafi server.
2. In the Policy Tree, add an Adaptable Credential object and select the Thycotic driver.
3. Set the **Secret Identifier** field to the identifier of the secret in Thycotic Secret Server to reference.
4. Reference the resulting credential object from any Venafi object that consumes a credential.

## Usage

When a consuming object needs the credential, the driver fetches the current value from Thycotic Secret Server, so rotations performed in the vault are picked up without re-entering secrets in Venafi.
