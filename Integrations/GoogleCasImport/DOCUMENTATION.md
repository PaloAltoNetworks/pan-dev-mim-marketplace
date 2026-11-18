# Google CAS Import

## Prerequisites

- A Google Cloud project with Certificate Authority Service set up.
- The [Certificate Authority API](https://console.cloud.google.com/apis/library/privateca.googleapis.com) enabled for the project.
- At least one CA pool that contains certificates. Only Enterprise-tier certificates can be discovered.
- A Google service account with the `CA Service Auditor` and `Certificate Manager Viewer` roles.
- The JSON key for the service account.

## Installation

1. Download `Google CAS Import.ps1` from this listing.
2. Copy it to the `AdaptableCA` folder under the Certificate Manager, Self-Hosted installation folder on every engine server, typically `C:\Program Files\Venafi\Scripts\AdaptableCA`.

## Configuration

Create a Username Credential from the service account key:

1. Open the JSON key in a text editor and convert it to a single line.
2. Copy the value of `private_key`. This is the credential **Password**.
3. Replace the value of `private_key` with `{{PRIVATE_KEY}}`.
4. Use the resulting single-line string as the credential **Username**.

## Usage

Create the import job:

1. Go to **Configuration** > **Jobs** and click **+ Create New Job**.
2. Select **Certificate Import** for the job type and click **Next**.
3. Enter a name and, optionally, a description and contact.
4. Select **Adaptable** for **Import Type** and click **Next**.
5. Select **Google CAS Import** for **PowerShell Script**.
6. Select the credential you created for **Username Credential**.
7. Optionally, turn on debug logging, then click **Next**.
8. Select a placement folder and click **Next**.
9. Select a frequency, then click **Create Job** or **Create & Run**.
