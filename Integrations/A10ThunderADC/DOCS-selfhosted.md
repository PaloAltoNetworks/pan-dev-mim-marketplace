# A10 Thunder

## Prerequisites

- Certificate Manager, Self-Hosted with the Adaptable Application driver framework.
- An A10 Networks Thunder ADC running ACOS 5.2.1 or later.
- An administrator account on the Thunder ADC that can manage the target partition.

## Installation

1. Download `A10-Thunder.ps1` from this listing.
2. Copy it to the Adaptable Application driver scripts folder on each Certificate Manager, Self-Hosted server, as described in the [Adaptable Application driver documentation](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/cco-drivers-AdaptableApp-Overview.php).

## Configuration

Create an Adaptable application object that uses `A10-Thunder.ps1` and fill in the driver fields:

- **Virtual Server** (required): the virtual server that uses the certificate.
- **Port Number**: the virtual port. Default is 443.
- **VPort Protocol**: the virtual port protocol. Default is HTTPS.
- **Partition**: the Thunder ADC partition that contains the virtual server.
- **Client SSL Template Name** (required): the client SSL template the certificate is bound to.
- **Use Insecure Connection to Management Interface**: skip TLS validation of the management interface certificate.

For full configuration instructions, see the [Adaptable Application driver documentation](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/cco-drivers-AdaptableApp-Overview.php).
