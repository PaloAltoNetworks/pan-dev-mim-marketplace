# Nameshield AC Connector

The purpose of this document is to provide information regarding the configuration of `Nameshield Connector` for integration with Venafi Trust Protection Platform (TPP).

*The information provided in this document is considered proprietary and confidential.*

>This integration guide, as well as the software and/or products described in it, are furnished under agreement with `Nameshield` and may be used only in accordance with the terms of such agreement.
>Except as permitted by such agreement, no part of this publication may be reproduced, stored in a retrieval system, or transmitted, in any form or by any means, electronic, mechanical, recording, or otherwise, without prior written permission of Nameshield.

## TABLE OF CONTENTS

[[_TOC_]]

## About Us

## Integration with Venafi

Venafi’s Trust Protection Platform integrates with the Nameshield Certificate Area for the purposes of managing public certificates. The primary benefit of this is to manage certificates lifecycle.

## Prerequisites

Before following the steps in this integration guide, the following prerequisite items must be installed and/or configured:

- Venafi Trust Protection Platform
- Nameshield Certificate Area

## Installation and Configuration

### Retrieving configuration datas

To enable Trust Protection Platform integration, the following must be completed:

1. Creation of an api access (getting the token)
2. Retrieving organization identifiant. 
3. Retrieving product identifiant
4. Retrieving optionnal billing Information

For any question or more information, please contact Certificates Team.

### Configuration 

To use Nameshield connector, you must specify some configuration informations

``` yaml
#################
# Configuration #
#################

# Address of the Nameshield API
$global:ServiceAddress = "https://api.nameshield.net/ssl/v2";

# Nameshield Access Token
$global:UserPass = "YOUR TOKEN";

# Product identification
$global:ProfileString = "PRODUCT ID";

# Organization identification
$global:CustomFields:organization = "ORGANISATION ID";

# Nameshield scope identification (optionnal)
$global:CustomFields:scopeNms = "SCOPE ID";

# Analytical Account (optionnal)
$global:CustomFields:analyticalAccount = "ANALYTICAL ACCOUNT";

```

## Usage

When configuration is done, you can perform these following operations:

### Retriving all the certificates included in your portfolio

Operation will retrieve all certificates included in your portfolio. 
Organization is not filtered, you will retrieve all your certificates

### Order a new Certificate

Order certificate to be attached to the specified organization and product .

### Renew or replace an existing Certificate

During reissue or replace process, organization could be changed. Initial product is kept.

### Revoking a certificate

All certificats managed or retrieved by Venafi Trust Protection Platform could be revoked.
Organization and product are not mandatory during revocation process

## Troubleshooting

### Error Messages

If an error is encountered, Nameshield Connector should provide an error message that is displayed within Trust Protection Platform.
Please copy this message and contact Certificates.

## Appendix A - Nameshield Contact Information

E-mail: certificates@nameshield.net
