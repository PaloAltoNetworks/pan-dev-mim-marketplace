# EJBCA Enterprise w/ Custom Serial Number

This guide configures Secur Solutions' EJBCA Legacy Adaptable CA driver (`Secur EJBCA script.ps1`) for Certificate Manager, Self-Hosted.

*The information provided in this document is considered proprietary and confidential.*

> This integration guide, as well as the software and/or products described in it, are furnished under agreement with Secur Solutions and may be used only in accordance with the terms of such agreement. Except as permitted by such agreement, no part of this publication may be reproduced, stored in a retrieval system, or transmitted, in any form or by any means, electronic, mechanical, recording, or otherwise, without prior written permission of Secur Solutions.

## Prerequisites

- Certificate Manager, Self-Hosted
- EJBCA Enterprise
- A certificate credential for the EJBCA REST API in Certificate Manager, Self-Hosted

## EJBCA Configuration

The EJBCA side may already be configured. If it is, skip to [Certificate Manager, Self-Hosted Configuration](#certificate-manager-self-hosted-configuration). Otherwise, use these general steps to set up an end entity profile that works with Certificate Manager, Self-Hosted.

1. Go to **Certificate Profiles**.

    ![Cert profile](readme-images/cert_profile.png)

2. Clone a certificate profile to suit your needs.

    - For example, add a 1-year server profile by cloning the **SERVER** profile.

        ![Profile list](readme-images/profile_list.png)

    - Edit each new profile as needed, for example change the validity period to 1 year, and click **Save**.

        ![Edit profile](readme-images/edit_cert_profile.png)

3. Create a new end entity profile.

    ![End profile](readme-images/end_profile.png)

    - Name it, for example `Venafi`.

        ![End list](readme-images/end_list.png)

    - Add the subject DN attributes C, ST, L, O and OU.

        ![Edit profile 1](readme-images/end_profile_1.png)

    - Associate it with the certificate profiles this end entity should use.

        ![Edit profile 2](readme-images/end_profile_2.png)

    - Add the Subject Alternative Name **DNS Name** and select **Use entity CN field**.

        ![Edit profile 3](readme-images/end_profile_3.png)

4. (Optional) To import certificates, enable version 2 of the REST API under **System Configuration** > **Protocol Configuration**.

    ![REST v2 for import](readme-images/RestV2_cert_import.png)

5. For issuance, renewal and revocation, enable the version 1 REST API under **System Configuration** > **Protocol Configuration**: **REST Certificate Management** (`/ejbca/ejbca-rest-api/v1/certificate`).

    ![REST v1 for issuance and revocation](readme-images/RestV1_cert_issuance_revocation.png)

6. For certificate renewal, disable **Enforce unique DN** on the certificate authority.

    ![CA setting](readme-images/ca_setting.png)

The CA configuration is now complete.

## Certificate Manager, Self-Hosted Configuration

The driver reads its settings from custom fields, which must be created with the exact names listed in the [custom field reference](#custom-field-reference).

1. Copy `Secur EJBCA script.ps1` to `C:\Program Files\Venafi\Scripts\AdaptableCA` on every Certificate Manager, Self-Hosted server.

    ![Adaptable folder](readme-images/adaptable_folder.png)

2. In the web console, create the custom fields.

    ![Custom fields](readme-images/aperture_custom.png)

3. Add the seven entries the driver expects.

    ![Custom field values 1](readme-images/aperture_values.png)

    ![Custom field values 2](readme-images/aperture_values_2.png)

    For the certificate profile name, make sure the field allows the characters you will use, for example `^[A-Za-z0-9-_\s]*$`.

4. In the Admin console (VEDAdmin), configure the EJBCA driver. A certificate credential is needed to pass the **Validate** check.

5. Create the EJBCA CA template object and configure it as shown, making sure the two additional custom fields are selected.

    ![Adaptable CA template](readme-images/tpp_adaptable.png)

6. Configure the policy folder to use the CA template.

    ![Policy folder](readme-images/policy_folder.png)

    These five fields are strict and case-sensitive:

    - **EJBCA CA Name** (`ManagementCA` is the default EJBCA CA name)
    - **EJBCA End Entity Profile Name** (`Venafi` in the example above)
    - **EJBCA Certificate Profile Name** (`Server - 1 Year` in the example above)
    - **Secur Legacy Certificate Serial Number**
    - **Secur Legacy Certificate Serial Number Prefix**

    ![Policy folder values 1](readme-images/custom_values_tpp_2.png)

    ![Policy folder values 2](readme-images/custom_values_tpp_3.png)

You can now issue certificates through Certificate Manager, Self-Hosted.

## Custom Field Reference

| Field name | Example | Reference |
| --- | --- | --- |
| EJBCA CA Name | ManagementCA | [Certification Authority](https://doc.primekey.com/ejbca/ejbca-introduction/ejbca-concepts#EJBCAConcepts-CertificationAuthority(CA)) |
| EJBCA Certificate Profile Name | Server - 1 Year | [Certificate Profile](https://doc.primekey.com/ejbca/ejbca-introduction/ejbca-concepts#EJBCAConcepts-CertificateProfile) |
| EJBCA End Entity Profile Name | Venafi | [End Entity Profile](https://doc.primekey.com/ejbca/ejbca-introduction/ejbca-concepts#EJBCAConcepts-EndEntityProfile) |
| EJBCA Email | john.doe@example.com | |
| EJBCA User Name | John | |
| Secur Legacy Certificate Serial Number | Yes, No | |
| Secur Legacy Certificate Serial Number Prefix | 00A | |
