# Palo Alto NGFW Bulk Provisioning

## Overview

This Adaptable Bulk Provisioning driver for Palo Alto Networks NGFW lets Certificate Manager,
Self-Hosted provision many certificates from a source policy folder to a target NGFW device in a
single operation. It is designed for scenarios where large numbers of certificates must be deployed
to a firewall efficiently.

**SOLUTION HIGHLIGHTS**

- Bulk-provision many certificates from a source policy folder to a target Palo Alto NGFW device
- Runs as a standard Bulk Provisioning job using the Adaptable framework
- Credential-based authentication to the target NGFW

## Prerequisites

- A Username Credential containing the username and password for the target NGFW device
- The script placed in the Venafi `AdaptableBulk` scripts folder on all engine servers

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
