# Write-VenafiDebug

## Overview

Write-VenafiDebug is a generic debug logging helper for use inside Adaptable scripts in Certificate
Manager, Self-Hosted. It provides consistent, safe logging so script authors can troubleshoot
Adaptable drivers, workflows, and logs without leaking sensitive data.

**SOLUTION HIGHLIGHTS**

- Drop-in debug logging function for any Adaptable script
- Hashtables are supported and formatted for readable output
- Secret information (e.g. values from `$General`) is automatically redacted as `***hidden***`
- Optional exception throwing at the same time as writing to the log
- Built-in mutex prevents "file in use" errors when multiple executions run concurrently

## Prerequisites

- Certificate Manager, Self-Hosted with the Adaptable framework
- Include or dot-source `Write-VenafiDebug.ps1` from your Adaptable script

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
