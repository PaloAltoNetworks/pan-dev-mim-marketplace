# Google CAS Import

## Introduction

This Adaptable CA will import certificates from Google CAS to TPP.

## Setup

### Google CAS

Ensure your project is setup and perform the following:
- Install the Certificate Authority Service
- Enable the [Certificate Authority API](https://console.cloud.google.com/apis/library/privateca.googleapis.com)
- Create at least 1 CA pool and ensure it is populated with certificates.  Note, only Enterprise tier certificates can be discovered.
- Create a service account with roles `CA Service Auditor` and `Certificate Manager Viewer`.
- Download the JSON key for the service account and keep it for a later step.

### TPP

- Download the most recent [release](https://coolsolutions.venafi.com/venafi/google-cas-import/-/releases/permalink/latest) and copy `Google CAS Import.ps1` to the AdaptableCA folder under the TPP installation folder, typically c:\Program Files\Venafi\Scripts\AdaptableCA, for all Venafi engine servers.
- Create a new Username Credential:
  - Open the JSON key in a text editor and convert it to one line
  - Copy the value for private_key, this will be the Credential Password
  - Replace the value for private_key with `{{PRIVATE_KEY}}`
  - This new one line string is the Username
- Create a new job:
  - Configuration -> Jobs -> Click + Create New Job
  - Select `Certificate Import` for the job type
  - Click Next
  - Provide a name and optionally a description and contact
  - Select `Adaptable` for Import Type
  - Click Next
  - Select `Google CAS Import` for PowerShell Script
  - Select the credential created earlier for Username Credential
  - Optionally, turn on debug logging
  - Click Next
  - Select a placement folder
  - Click Next
  - Select a frequency
  - Click Create Job or Create & Run
