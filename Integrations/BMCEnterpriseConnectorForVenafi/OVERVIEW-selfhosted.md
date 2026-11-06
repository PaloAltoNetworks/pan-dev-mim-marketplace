# BMC Enterprise Connector for Venafi

This Adaptable Driver communicates with the Enterprise Connector for Venafi product from BMC Software, Inc. to provide certificate management for RACF, TSS, and ACF2 environments on z/OS.

**SOLUTION COMPONENTS**

Certificate Manager, Self-Hosted; RACF, TSS, or ACF2 on IBM z/OS; BMC Enterprise Connector for Venafi

**SOLUTION OVERVIEW**

Enterprise Connector for Venafi is under continuous development, and new versions incorporate additional features that require associated changes to the Certificate Manager, Self-Hosted (Adaptable Driver). This listing includes one driver script per Enterprise Connector for Venafi version — you must use the script that matches the version of Enterprise Connector for Venafi installed on your mainframe.

Each driver script also requires a set of DLLs supplied by BMC Software, installed at a version-specific path. If your DLLs are installed elsewhere, update the `$DLLPath` variable in the script to match.

**CHOOSING THE RIGHT DRIVER**

| Driver file | Enterprise Connector for Venafi version | Required DLL path |
| --- | --- | --- |
| `EC for Venafi SPE2304.ps1` | SPE2304 | `C:\Program Files\Venafi\Utilities\ECVenafi` |
| `EC for Venafi SPE2307.ps1` | SPE2307 | `C:\Program Files\Venafi\Utilities\ECVenafi` |
| `EC for Venafi SPE2310.ps1` | SPE2310 | `C:\Program Files\Venafi\Utilities\ECVenafi` |
| `EC for Venafi SPE2401.ps1` | SPE2401 | `C:\Program Files\Venafi\Utilities\ECVenafi` |
| `EC for Venafi SPE2404.ps1` | SPE2404 | `C:\Program Files\Venafi\Utilities\ECVenafi` |
| `EC for Venafi SPE2407.ps1` | SPE2407 | `C:\Program Files\Venafi\Utilities\ECVenafi` |
| `EC for Venafi SPE2410.ps1` | SPE2410 | `C:\Program Files\Venafi\Utilities\ECVenafi SPE2410` |
| `EC for Venafi SPE2501.ps1` | SPE2501 | `C:\Program Files\Venafi\Utilities\ECVenafi SPE2501` |
| `EC for Venafi SPE2504.ps1` | SPE2504 | `C:\Program Files\Venafi\Utilities\ECVenafi SPE2504` |
| `EC for Venafi SPE2507.ps1` | SPE2507 | `C:\Program Files\Venafi\Utilities\ECVenafi SPE2507` |

Each version of Enterprise Connector for Venafi must be used with its matching DLLs and driver script — using a mismatched pair is not supported.

**INSTALLATION AND CONFIGURATION**

1. Identify the version of Enterprise Connector for Venafi installed on your mainframe environment.
2. Copy the matching driver script to the Adaptable Application/Driver scripts directory on the Certificate Manager, Self-Hosted server.
3. Confirm the BMC-supplied DLLs for that version are installed at the required path above (or update `$DLLPath` in the script if they're installed elsewhere).
4. Configure the Adaptable Driver in Certificate Manager, Self-Hosted per BMC's documentation for Enterprise Connector for Venafi.

Full details on configuring application objects managed by this driver are included in the documentation provided by BMC Software. Contact BMC Software for support requests regarding Enterprise Connector for Venafi or these scripts.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
