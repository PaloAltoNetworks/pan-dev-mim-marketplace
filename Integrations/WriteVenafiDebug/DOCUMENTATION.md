# Write-VenafiDebug

## Prerequisites

- Certificate Manager, Self-Hosted with the Adaptable framework
- An Adaptable script that you want to add debug logging to

## Usage

1. Dot-source or include `Write-VenafiDebug.ps1` in your Adaptable script.
2. Call the `Write-VenafiDebug` function to write debug output to your log file.

Behavior:

- Hashtables are supported and formatted for readable output.
- Secret information, for example values from the `$General` object, is logged as `***hidden***`.
- You can throw an exception at the same time as writing to the log.
- A mutex ensures that multiple executions of the script don't cause "file in use" errors.
