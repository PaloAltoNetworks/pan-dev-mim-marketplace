# Palo Alto NGFW Bulk Provisioning

## Introduction

This is an adaptable bulk provisioning driver for Palo Alto Networks NGFW. The purpose is to provision many certificates from a source Policy Folder to a target device. 

## Setup

1. Download the PowerShell script and place it in the proper Venafi AdaptableBulk folder under the TPP installation folder, typically `C:\Program Files\Venafi\Scripts\AdaptableBulk`.

2. Create a new Username Credential and supply the username and password for the target NGFW device.

3. Create a new Bulk Provisioning job according to the official [Venafi Docs](https://docs.venafi.com/Docs/current/TopNav/Content/Provision/t-Provision-BulkProvisioning-Job-creating.php?tocpath=TLS%20Protect%7CCertificate%20Management%20Guide%7CCertificate%20installation%7CInstalling%20(provisioning)%20lots%20of%20certificates%20and%20keys%20at%20one%20time%7C_____2).