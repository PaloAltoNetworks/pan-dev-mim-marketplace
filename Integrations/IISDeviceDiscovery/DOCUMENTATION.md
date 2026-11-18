# IIS Device Discovery

## Prerequisites

- A Windows server with PowerShell 5.0 or later. The script must run as Administrator.
- An OAuth access token for Certificate Manager, Self-Hosted with the `Configuration:manage` scope.
- **View** permission on the base policy folder and **Create** permission on the device policy folder for the token user.
- To read hosts from Active Directory or to validate IIS, the "Active Directory Domain Services Tools" or "Active Directory module for PowerShell". If neither is installed and you are not using a CSV file, the script prompts you to install it.
- An Active Directory account with read permissions, if you read from Active Directory or validate IIS.

## Configuration

The script reads its settings from a `properties.json` file that must be in the same folder as the script. The file is not included in this listing, so create it with these keys:

| Key | Description |
|:---:|---|
| `tppFQDN` | Fully qualified domain name of the Certificate Manager, Self-Hosted server where the WebSDK API is installed and enabled. |
| `token` | OAuth access token with the `Configuration:manage` scope. |
| `validateIIS` | `true` to connect to each host and confirm that IIS is running and which bindings are present. |
| `onlyhttps` | `true` to add only sites that have an HTTPS binding. |
| `CSV.readFile` | `true` to read the host list from a CSV file. If `false`, hosts come from Active Directory. |
| `CSV.inputFile` | Path of the CSV file with the host list. Required if `readFile` is `true`. |
| `CSV.fileDelimiter` | Delimiter used in the CSV file. Required if `readFile` is `true`. |
| `basePolicyLocation` | Policy DN where the script searches for devices that already exist. The token user needs **View** permission. |
| `devicePolicyLocation` | Policy DN where discovered devices are imported. The token user needs **Create** permission. |
| `daysInactive` | Number of days since a host last signed in. Applies to Active Directory hosts only. |
| `logging` | `true` to write debug-level logs to a file. If `false`, messages go to the console. |

If you are not reading from a file, you can omit the `CSV` section. The sample `IISHostList.csv` shows the expected format, with a `PSComputerName` column.

## Usage

1. Copy `IIS_Device_Discovery.ps1` to a folder on a Windows server.
2. Create `properties.json` in the same folder.
3. From a PowerShell prompt, run `./IIS_Device_Discovery.ps1`.
4. If `validateIIS` is `true` or the script reads from Active Directory, enter an Active Directory account with read permissions when prompted. If the script reads from a CSV file without validating IIS, it does not prompt for credentials.
5. In an onboard discovery job, select the device policy folder as the devices folder.

## Logs

Logs are written to the `Logs` folder where the script runs.
