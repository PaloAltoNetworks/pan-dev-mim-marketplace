# Array Networks APV

## Prerequisites

- Certificate Manager, Self-Hosted with the Adaptable Application driver framework.
- An Array Networks APV Series ADC with the RESTful API enabled.
- An APV account that can manage SSL virtual hosts and certificates.

## Installation

1. Download `ArrayNetworks_ADC_Driver.ps1` from this listing.
2. Copy it to the Adaptable Application driver scripts folder on each Certificate Manager, Self-Hosted server, as described in the [Adaptable Application driver documentation](https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/cco-drivers-AdaptableApp-Overview.php).

## Configuration

1. Create a device object for the APV appliance with its address, the RESTful API port and the APV credential.
2. Create an Adaptable application object that uses `ArrayNetworks_ADC_Driver.ps1` and fill in the driver fields:
   - **SSL Virtual Host** (required): the SSL virtual host that uses the certificate.
   - **Domain Name**: the domain name for the certificate on the virtual host.
   - **Activate Certificate After Installation**: activates the certificate on the virtual host after it is installed.
