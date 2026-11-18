# IIS Device Discovery

Before Certificate Manager, Self-Hosted can discover and manage the certificates on your IIS servers, those servers need to exist as devices in its policy tree. Adding hundreds of Windows servers by hand is slow and error-prone. The IIS Device Discovery script imports Windows servers running IIS 7.x and later into a policy folder you choose, so you can quickly build a device inventory and point an onboard discovery job at it.

**Value Highlights**

- **Build inventory fast**: Bulk-import IIS Windows servers as devices for onboard discovery.
- **Use the host source you have**: Read hosts from Active Directory or from a CSV host list.
- **Import only real IIS servers**: Optionally confirm that IIS is running and inspect site bindings before import.
- **Focus on TLS**: Optionally import only hosts that have an HTTPS binding.
- **Skip stale hosts**: Exclude Active Directory computers that have not signed in for a set number of days.

**How it Works**

The PowerShell script reads its settings from a `properties.json` file, gets the host list from Active Directory or a CSV file, and checks which hosts already exist under a base policy folder. It then uses the Certificate Manager, Self-Hosted WebSDK REST API to create devices for the new hosts in the target policy folder. You select that folder as the devices folder in an onboard discovery job. See the Documentation tab for configuration and usage.

**Solution Components**

- Certificate Manager, Self-Hosted with the WebSDK API enabled
- Windows servers running IIS 7.x or later
- `IIS_Device_Discovery.ps1` and the sample `IISHostList.csv` (included in this listing)

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
