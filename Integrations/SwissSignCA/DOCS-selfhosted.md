# SwissSign Adaptable CA

The purpose of this document is to provide information regarding the
configuration of `SwissSign Managed PKI` for integration with Venafi
Trust Protection Platform (TPP).

*The information provided in this document is considered proprietary and confidential.*

> This integration guide, as well as the software and/or products
> described in it, are furnished under agreement with `SwissSign AG`
> and may be used only in accordance with the terms of such agreement.
> Except as permitted by such agreement, no part of this publication
> may be reproduced, stored in a retrieval system, or transmitted, in
> any form or by any means, electronic, mechanical, recording, or
> otherwise, without prior written permission of SwissSign AG.


## TABLE OF CONTENTS

- [Prerequisites](#prerequisites)

- [Installation and Configuration](#installation-and-configuration)


## Prerequisites

Before following the steps in this integration guide, the following
prerequisite items must be installed and configured:

- Venafi Trust Protection Platform

- SwissSign Managed PKI \[[link](https://www.swisssign.com/managed-pki.html)\]


## Installation and Configuration

To enable Trust Protection Platform integration, the following must be
completed:

### Step 1: Username Credential

Create a "Username Credential", using an API key from your SwissSign
account. Either:

- Use the "Service API Key" from your SwissSign account:
  [https://ra.swisssign.ch/account/my/SAAPIKeys](https://ra.swisssign.ch/account/my/SAAPIKeys)
  (columns: "Service Account", "API Key")

  - User Name: `<service-account>` (e.g. `MPKI5000042.AutoRAO`)
  - Password:  `<api-key>`

- Or create a "Account API Key" in your SwissSign account:
  [https://ra.swisssign.ch/account/my/keys](https://ra.swisssign.ch/account/my/keys)
  (columns: "API Key")

  - User Name: `<account-username>` (e.g. `my-email@example.com`)
  - Password:  `<api-key>`


### Step 2: Adaptable CA Template

At the time of writing, the following products (called `policy-name`
in this document) are available for
[SwissSign Managed PKI Service](https://www.swisssign.com/managed-pki/managed-pki-service.html):

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


Note that not all customers have all products available. Customers of
[SwissSign Private Managed PKI](https://www.swisssign.com/en/managed-pki/private-managed-pki.html)
also have customized products. For a complete product listing refer to
your SwissSign account:

 - [https://ra.swisssign.ch/issue](https://ra.swisssign.ch/issue)
    for production, or

 - [https://ra.pre.swisssign.ch/issue](https://ra.pre.swisssign.ch/issue)
   for pre-production (testing) environment.


#### Set up a "CA Template":

- Set "CA Name" (e.g. `MPKI5000042 - SwissSign EV SSL Gold Single-Domain`).

- Pick "Username Credential" from step 1.

- Set "Service Address", either:

  - Service Address: **`https://api.ra.swisssign.ch`** for production, or

  - Service Address: `https://api.ra.pre.swisssign.ch` for pre-production (testing)

- Set "Profile String". The issuing CA (more precisely: the
  "product reference") is defined by `client-name` ("MPKIxxx -
  Client Name") and `policy-name` ("SwissSign EV SSL Gold
  Single-Domain", ...).

  Pick a client and policy from your SwissSign account:
  [https://ra.swisssign.ch/issue](https://ra.swisssign.ch/issue)
  (columns: "Client", "Policy Name")

  - Profile String: **`policy-name [client-name]`**
    (e.g. `SwissSign EV SSL Gold Single-Domain [MPKI5000042 - Firma Muster AG]`).
    Both client-name and policy-name are required values, there is no default.


### Step 3: Server Certificate

- Set "Certificate Name" (e.g. `my.example.com - SwissSign EV`).

- In "Subject DN", specify at least a "**Common Name**" (CN). Values
  pre-set from the SwissSign policy are not required (such as
  Organization for OV and EV), and will silently be overwritten with
  correct SwissSign validated values.

- For multi-domain policies, also set "Subject Alt Name(s)" (SAN) of
  type DNS.

- Pick the "CA Template" created in step 2.
