# SwissSign Adaptable CA

This document describes how to configure `SwissSign Managed PKI` for integration with Certificate Manager, Self-Hosted.

*The information provided in this document is considered proprietary and confidential.*

> This integration guide, as well as the software and/or products described in it, are furnished under agreement with `SwissSign AG` and may be used only in accordance with the terms of such agreement. Except as permitted by such agreement, no part of this publication may be reproduced, stored in a retrieval system, or transmitted, in any form or by any means, electronic, mechanical, recording, or otherwise, without prior written permission of SwissSign AG.

## Prerequisites

The following must be installed and configured before you start:

- Certificate Manager, Self-Hosted
- [SwissSign Managed PKI](https://www.swisssign.com/managed-pki.html)

## Installation and Configuration

### Step 1: Username Credential

Create a **Username Credential** using an API key from your SwissSign account. Use one of the following:

- The **Service API Key** from your SwissSign account at [https://ra.swisssign.ch/account/my/SAAPIKeys](https://ra.swisssign.ch/account/my/SAAPIKeys) (columns **Service Account** and **API Key**):
    - **User Name**: `<service-account>` (for example `MPKI5000042.AutoRAO`)
    - **Password**: `<api-key>`
- An **Account API Key** created in your SwissSign account at [https://ra.swisssign.ch/account/my/keys](https://ra.swisssign.ch/account/my/keys) (column **API Key**):
    - **User Name**: `<account-username>` (for example `my-email@example.com`)
    - **Password**: `<api-key>`

### Step 2: Adaptable CA Template

At the time of writing, the following products (called `policy-name` in this document) are available for [SwissSign Managed PKI Service](https://www.swisssign.com/managed-pki/managed-pki-service.html):

- Domain Validation (DV)
    - `SwissSign DV SSL Silver Single-Domain`
    - `SwissSign DV SSL Silver Multi-Domain`
    - `SwissSign DV SSL Silver Wildcard`
- Organisation Validation (OV)
    - `SwissSign OV SSL Gold Single-Domain`
    - `SwissSign OV SSL Gold Multi-Domain`
    - `SwissSign OV SSL Gold Wildcard`
- Extended Validation (EV)
    - `SwissSign EV SSL Gold Single-Domain`
    - `SwissSign EV SSL Gold Multi-Domain`
- E-Mail (S/MIME)
    - `SwissSign Pro S/MIME E-Mail ID Gold`
    - `SwissSign Pro S/MIME E-Mail ID Gold with Auth`
    - `SwissSign Pro S/MIME E-Mail ID Gold RSASSA-PSS`

Not all customers have all products available. Customers of [SwissSign Private Managed PKI](https://www.swisssign.com/en/managed-pki/private-managed-pki.html) also have customized products. For a complete product listing, refer to your SwissSign account:

- [https://ra.swisssign.ch/issue](https://ra.swisssign.ch/issue) for production
- [https://ra.pre.swisssign.ch/issue](https://ra.pre.swisssign.ch/issue) for the pre-production (testing) environment

Set up a **CA Template**:

1. Set **CA Name** (for example `MPKI5000042 - SwissSign EV SSL Gold Single-Domain`).
2. Select the **Username Credential** from step 1.
3. Set **Service Address** to `https://api.ra.swisssign.ch` for production, or `https://api.ra.pre.swisssign.ch` for pre-production (testing).
4. Set **Profile String**. The issuing CA (more precisely, the product reference) is defined by `client-name` ("MPKIxxx - Client Name") and `policy-name` ("SwissSign EV SSL Gold Single-Domain", and so on). Pick a client and policy from your SwissSign account at [https://ra.swisssign.ch/issue](https://ra.swisssign.ch/issue) (columns **Client** and **Policy Name**), then set **Profile String** to `policy-name [client-name]`, for example `SwissSign EV SSL Gold Single-Domain [MPKI5000042 - Firma Muster AG]`. Both client-name and policy-name are required, and there is no default.

### Step 3: Server Certificate

1. Set **Certificate Name** (for example `my.example.com - SwissSign EV`).
2. In **Subject DN**, specify at least a **Common Name** (CN). Values preset by the SwissSign policy (such as Organization for OV and EV) are not required and are silently overwritten with the correct SwissSign-validated values.
3. For multi-domain policies, also set **Subject Alt Name(s)** (SAN) of type DNS.
4. Select the **CA Template** created in step 2.
