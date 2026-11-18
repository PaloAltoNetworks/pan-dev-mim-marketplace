# Axiad Cloud PKI Integration README

This document describes how to configure Axiad Cloud PKI for integration with Certificate Manager, Self-Hosted.

**Terms of Use**

This integration guide, as well as the software and/or products described in it, are furnished under agreement with Axiad and may be used only in accordance with the terms of such agreement. Except as permitted by such agreement, no part of this publication may be reproduced, stored in a retrieval system, or transmitted, in any form or by any means, electronic, mechanical, recording, or otherwise, without prior written permission of Axiad.

## Prerequisites

- Certificate Manager, Self-Hosted
- Axiad Cloud PKI (ID_PKI), with a service account that Axiad has provisioned on your instance for Certificate Manager, Self-Hosted
- The client certificate for that service account, as a PFX or PKCS#12 file from your PKI administrator

## Installation

1. Copy the driver to the Adaptable CA script folder on each Certificate Manager, Self-Hosted server:
   - `ID_PKI_Adaptable_ScriptRA.ps1` for RA-based provisioning (preferred)
   - `ID_PKI_Adaptable_Script.ps1` for CA-based provisioning

## Configuration

### Create the Certificate Credential

The connection to the PKI is authenticated with the service account's client certificate.

1. In the web interface, go to **Policy** and right-click the folder that will store the credential.
2. Choose **Add > Credential > Certificate Credential**.
3. Enter a name, description and contact information.
4. Select **Import certificate**, then click **Import Certificate**.
5. Upload the PFX or PKCS#12 file and enter the password from your PKI administrator.
6. Save and exit.

### Create the Custom Fields

Custom field names are case sensitive.

1. Go to **Configuration > Custom Fields**.
2. Click **+Add New Custom Field** and enter:
   - **Name**: `IssuerDN`
   - **Field Type**: String
   - **Make Field**: **Required**
   - **Apply to**: **Certificates**
3. Click **Save**.
4. Repeat steps 2 and 3 for `CAPartition`.
5. If you use the RA driver, repeat steps 2 and 3 for `RequesterEmail`.

### Create the CA Template

1. In the Policy Tree, right-click the location for the CA template and choose **Add > CA Template > Adaptable**.
2. Enter a name and description.
3. Leave the username blank.
4. Select the certificate credential you created.
5. Enter the **Service Address** from your PKI administrator.
6. In **Profile String**, enter the certificate template name from your PKI administrator.
7. Select `ID_PKI_Adaptable_ScriptRA` or `ID_PKI_Adaptable_Script` as the PowerShell script.
8. Under **Custom Fields**, add the custom fields you created.
9. Click **Validate**, then save.

## Usage

When you request a certificate from this CA template, enter the `CAPartition` and `IssuerDN` values from your PKI administrator. A CA can have multiple management partitions. With the RA driver, also enter `RequesterEmail`, which is required for initial enrollment through the RA.

## Troubleshooting

Contact Axiad support:

- United States: +1 (408) 320-8822
- Canada: +1 (416) 665-9237
- Web: https://www.axiad.com/support
- Email: support@axiad.com
