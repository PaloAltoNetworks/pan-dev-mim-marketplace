# AXIAD CLOUD PKI INTEGRATION README

The purpose of this document is to provide information regarding the configuration of Axiad Cloud PKI for integration with Venafi Trust Protection Platform (TPP).

The information provided in this document is considered proprietary and confidential.

#### **TERMS OF USE**

This integration guide, as well as the software and/or products described in it, are furnished under agreement with Axiad and may be used only in accordance with the terms of such agreement. Except as permitted by such agreement, no part of this publication may be reproduced, stored in a retrieval system, or transmitted, in any form or by any means, electronic, mechanical, recording, or otherwise, without prior written permission of Axiad.

## TABLE OF CONTENTS

- [About Us](#about-us)
- [Integration with Venafi](#integration-with-venafi)
- [Prerequisites](#prerequisites)
- [Installation and Configuration](#installation-and-configuration)
- [Usage](#usage)
- [Appendix A - Axiad Support Contact Information](#appendix-a---axiad-support-contact-information)

## About Us

Headquartered in Santa Clara, CA with offices in Canada and India, Axiad provides a single platform that enables passwordless across the enterprise ecosystem, by securing people, machines and digital interactions. We create the foundation for zero trust, by allowing organizations to cohesively deploy their identity credentials, with centralized management and reporting. Axiad Cloud offers PKI and authentication services, in a powerful, yet simple solution, to address all identity assurance requirements. We support the widest range of credentials including FIDO, mobile MFA, Windows Hello for Business, Yubikeys, smart cards, TPM and biometrics. Axiad Cloud is trusted by public sector organizations and Fortune 500 companies across aerospace & defense, financial services, healthcare, oil & energy and more.

## Integration with Venafi

Venafi’s Trust Protection Platform integrates with the Axiad Cloud PKI for the purposes of life cycle management of Axiad Certificates. The primary benefit of this is to automate the issuance, renewal and revokation of machine certificates.

## Prerequisites

Before following the steps in this integration guide, the following prerequisite items must be installed and configured:

- Venafi Trust Protection Platform
- Axiad Cloud PKI

## Installation and Configuration

### Script Installation

To enable Trust Protection Platform integration, the following must be completed:

1. Put the script into the Adaptable CA script folder on your Venafi instance.
    - ID_PKI_Adapatable_Script.ps1 for RA based provisioning (preferred)
    - ID_PKI_Adapatable_Script.ps1 for CA based provisioning
2. Ensure that Axiad has provisioned a service account on your ID_PKI instance and that you have the certificate associated with that account.

### Venafi Configuration

Once the script is copied to the correct folder, create a new credential in the Venafi instance and import the certificate tied to the ID_PKI account that will be used for certificate requests.

In order to authenticate to the PKI, the Connection needs to be authenticated by a certificate.  This certificate will be mapped to the service account for Venafi, and will be provided by the PKI administrator as a PFX or PKCS12 file.  To use the certificate, it must be imported to a Venafi credential.

1. Open the Venafi web interface, go to Policy and Right Click on a folder to store the credential 
2. Choose Add | Credential | Certificate Credential
3. Enter a name for the credential, a description, and contact information
4. Select the "Import certificate"
5. Click "Import Certificate"
6. Upload the pfx or PKCS12 file provided by the PKI administrator and enter the provided password.
7. Save and exit

After importing the certificate, configure the Custom Fields - Note, these are case sensitive.

1. Go to Configuration | Custom Fields
2. Choose "+Add New Custom Field"
3. Enter the following information:
    - Name: IssuerDN
    - Field Type: String
    - Make Field: Check the "Required" box
    - Apply to: Check the "Certificates" box
4. Click Save
5. Repeat 2 & 3, with Name: CAPartition
6. If using the RA connector, Repeat 2 & 3 with name: RequesterEmail

And then configure the CA object:

1. In the policy tree, choose the location you are adding the CA template, and right click and choose "Add |CA Template | Adaptable"
2. Set a Name and Description of your choice
3. Leave username blank
4. Select the certificate credential configured above in the credential creation
5. Enter the Service Address provided by the PKI administrator
6. Enter the Certificate Template name provided by the PKI administrator for the Profile String
7. Choose ID_PKI_Adapatable_Script as the powershell script
8. Under Custom Fields, add the custom fields defined above
9. Click Validate
10. Save the configuration

## Usage

When setting up a certificate request using the CA Template defined above, the CAPartition and IssuerDN need to be entered to request the certificate.  These values are provided by the PKI administrator.  A CA can have multiple management partitions. When using the (preferred) ID_RA connector, the RequesterEmail custom field will also need to be entered as it is required for initial enrollment of a certificate via the RA.


## Appendix A - Axiad Support Contact Information

United States: +1 (408) 320-8822

Canada: +1 (416) 665-9237

Web: https://www.axiad.com/support

E-mail: support@axiad.com
