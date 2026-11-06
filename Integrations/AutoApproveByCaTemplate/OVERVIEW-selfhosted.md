# Auto-Approve by CA Template

## Overview

`CAAutoApproval.ps1` is a PowerShell script driven by an Adaptable Workflow object in Certificate
Manager, Self-Hosted. The script evaluates the location of an X.509 certificate object's CA template
to determine whether the residing parent policy folder DN matches a designated "auto-approve" policy
folder DN. When they match, the workflow stage is automatically approved during enrollment or renewal;
otherwise the workflow object falls back to its configured approval behavior.

**SOLUTION HIGHLIGHTS**

- Streamline certificate issuance by auto-approving requests that use pre-approved CA templates
- Preserve manual review for CA templates that reside outside the designated policy folder
- Configurable per policy folder via a standard Adaptable Workflow object
- Optional debug logging for troubleshooting approval decisions

## Prerequisites

- A policy folder in which CA templates designated for auto-approval have been placed.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
