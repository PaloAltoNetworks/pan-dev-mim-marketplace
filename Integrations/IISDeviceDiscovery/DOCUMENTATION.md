# Deploying the IIS Device Discovery Script

## Overview

The IIS Device Discovery script is intended to import Windows servers running IIS (7.x and later) into a specified policy folder in Trust Protection Platform. The devices folder can be specified during an onboard discovery job.

If the "Active Directory Domain Services Tools" or "Active Directory module for PowerShell" is not installed and not using a CSV file, the script will prompt the user to install before continuing.

## Prerequisites

The IIS_Device_Discovery.ps1 script utilizes a `properties.json` file to set script variables and switches. Read the following details for configuring this file and place in the **same location** where the script will be executed.

`properties.json`

|Key|Description|
|:---:|---|
|tppFQDN|The Fully Qualified Domain Name of the TPP server where the WebSDK API is installed and enabled.|
|token|Provide an OAuth access token with the following scope: *Configuration:manage*|
|validateIIS|When set to *true*, the script will connect to each host to confirm if IIS is running and what bindings are present. Options are *true* or *false*.|
|onlyhttps|When set to *true*, the script will only add sites that have an https binding. Options are *true* or *false*.|
|readFile|Set to *true* if a script will parse a CSV file for list of hosts. Options are *true* or *false*. If *true*, you must set **inputFile** and **fileDelimiter** values. If *false* then the list of hosts is obtained from Active Directory.|
|inputFile|The file path of the CSV file containing a list of hosts. Required if **readFile** set to *true*|
|fileDelimiter|The delimiter of the CSV file content. Required if **readFile** set to *true*|
|basePolicyLocation|Policy DN where the script will search for all devices currently in TPP. The TPP token user must have View permission to this DN.|
|devicePolicyLocation|Policy DN where devices which were discovered by the script will be imported to. The TPP token user must have Create permission to this DN.|
|daysInactive|Number of days(n) since a host was last logged into. *Only Active Directory hosts*|
|logging|Set to *true* for debug-level logging written to a file. if *false* then messages will be output to console.|

>Note: If NOT reading from file, you may omit the "CSV" section of the JSON.

## Deployment Instructions

1. Copy the IIS_Device_Discovery.ps1 script folder to any executable folder on a Windows server.
2. Update the `properties.json` file with required information.
3. From a PowerShell command prompt, run the following command:

    `./IIS_Device_Discovery.ps1`

4. If validation is set to *true* or the script is configured to read from Active Directory, the script will then prompt for an AD account which has read permissions.
5. If reading from a CSV file, and not validating IIS, you will not be prompted to enter any credentials.

>Logs are located in the **Logs** folder where the script was executed.
