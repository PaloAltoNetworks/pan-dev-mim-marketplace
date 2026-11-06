# Automate certificates for Radware Alteon with Venafi platform.

## Introduction:
Radware and Venafi have teamed up to make it easy to get started and fully automate the use of keys and certificates for application teams using Radware Alteon Load Balancer and/or Application Delivery Controllers.
The script automatically performs the apply-save configuration.
The input parameters are:
Virtual server, Service port, SSL policy.


## Supported versions:
This driver script applies to Venafi version 22.1 and above.

## Purpose:
Radware and Venafi have teamed up to make it easy to get started and fully automate the use of keys and certificates.

## How to use:

Download the driver from Venafi's marketplace or contact Venafi support.

Open your Venafi platform and create a new policy called "Alteon" (or any relevant name).

Click on the new policy and under the "Application" tab --> "Adaptable Settings" --> "PowerShell Script" choose the driver script that you downloaded, and click "Save".

Right-click on the new policy and navigate to "Add" --> "Devices" --> "device" to create a new device object, Under "General" fill in the "Device Name" field with a relevant name, and under "Host Information" fill the "Hostname/Address" field with the IP address of the Alteon (contact with Radware support if needed), and click "Save".

In the case of auto-sync mode, please set only the MASTER device in the Venafi platform.

Right-click on the device and navigate to "Add" --> "Credential" --> "Username Credential" to create a new credential object, Under "General" fill in the "Credential Name" field with a relevant name, and under "Settings" fill the "Expires" field (if needed), and under the "Credential" fill the following fields: "User Name", "Password", and "Confirm Password".

Navigate back to the "Device" and in the "Device Credentials" choose the credential object that you created earlier.

Right-click on the device and navigate to "Add" --> "Application" --> "Adaptable" to create a new adaptable object, Under "General" fill in the "Application Name" with a relevant name, under "certificate" choose the relevant certificate (contact with Venafi support if needed).

Under "Adaptable Settings" fill the following:
Virtual Server - Set the name of the virtual server whose certificate you want to push or replace.
Service Port - the port that the service with the SSL listens on.
SSL policy - the relevant policy for that service.


## Covered scenarios:
### This driver script covers the following scenarios:
Push Certificate - in this case the Venafi uploads the certificate to the Alteon and attaches the cert and policy to the service.
Renew Certificate - in this case the Venafi replaces the new certificate in the Alteon and attaches the cert and policy to the service, then deletes the old certificate.


## Logs:
### This driver can generate 2 log files:
Debug log - For debugging (The "Enable Debug Logging" should be enabled).
Error log - In the case of error (even if the debug is disabled).

### Note:
This script is for use at your own choice.
The script is provided as is without any warranty of any kind and Radware disclaims any and all liability regarding any use of the script.
