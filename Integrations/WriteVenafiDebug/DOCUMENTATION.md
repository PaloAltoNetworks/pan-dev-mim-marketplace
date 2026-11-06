# Write-VenafiDebug

Generic debug logging function to be used in adaptable scripts. Hashtables are supported and secret
info, e.g. from `$General`, will be logged as `***hidden***`. There is an option to throw an
exception at the same time as writing to the log. Also, a mutex has been implemented to ensure
multiple executions of this script don't cause 'file in use' errors.

## Usage

Dot-source or include `Write-VenafiDebug.ps1` in your Adaptable script, then call the
`Write-VenafiDebug` function to write structured debug output to your log file. Sensitive values
(such as those from the `$General` object) are automatically redacted as `***hidden***`.
