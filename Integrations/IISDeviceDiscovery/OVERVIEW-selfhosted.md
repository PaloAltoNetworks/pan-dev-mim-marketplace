# IIS Device Discovery

## Overview

The IIS Device Discovery script imports Windows servers running IIS (7.x and later) into a specified
policy folder in Certificate Manager, Self-Hosted. The target devices folder can be specified during
an onboard discovery job, letting you rapidly build a device inventory from Active Directory or a
CSV host list.

**SOLUTION HIGHLIGHTS**

- Bulk-import IIS Windows servers as devices for onboard discovery
- Source hosts from Active Directory or a supplied CSV file
- Optionally validate that IIS is running and inspect bindings before import
- Optionally restrict imports to hosts with an HTTPS binding

## Prerequisites

- A `properties.json` configuration file placed alongside the script (see Documentation)
- An OAuth access token with the `Configuration:manage` scope
- For Active Directory sourcing/validation: the "Active Directory module for PowerShell" (the script
  prompts to install if missing)

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
