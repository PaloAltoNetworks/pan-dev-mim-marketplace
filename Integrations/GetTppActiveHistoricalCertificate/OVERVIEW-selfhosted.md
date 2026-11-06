# Get-TppActiveHistoricalCertificate

## Overview

`Get-TppActiveHistoricalCertificate` is a PowerShell utility that finds active/valid historical
certificates in Certificate Manager, Self-Hosted. It uses the VenafiPS PowerShell module to search
certificate history and surface certificates that remain active.

> **NOTE:** This script can still be used, but the capability has been added to VenafiPS as
> `Search-TppHistory`, which can search on all attributes, not just active ones.

**SOLUTION HIGHLIGHTS**

- Locate active/valid historical certificates across your inventory
- Built on the widely used VenafiPS PowerShell module
- Simple session-based execution against the WebSDK API

## Prerequisites

- VenafiPS PowerShell module, v4.2.0 or later
- PowerShell 7 or later

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
