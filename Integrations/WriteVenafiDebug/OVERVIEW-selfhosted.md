# Write-VenafiDebug

Troubleshooting Adaptable scripts in Certificate Manager, Self-Hosted often means adding ad hoc logging that can leak credentials or fail when several executions write to the same file. Write-VenafiDebug is a generic debug logging function for Adaptable scripts that gives script authors consistent, safe logging for drivers, workflows and logs.

**Value Highlights**

- **Drop it in anywhere**: Use one debug logging function in any Adaptable script.
- **Log structured data**: Hashtables are supported and formatted for readable output.
- **Protect secrets**: Sensitive values, such as those from `$General`, are redacted as `***hidden***`.
- **Fail and log together**: Optionally throw an exception while writing to the log.
- **Avoid file conflicts**: A mutex prevents "file in use" errors when multiple executions run concurrently.

**How it Works**

Include or dot-source `Write-VenafiDebug.ps1` in your Adaptable script and call the `Write-VenafiDebug` function wherever you need debug output. See the Documentation tab for usage.

**Solution Components**

- Certificate Manager, Self-Hosted (Adaptable framework)
- `Write-VenafiDebug.ps1`

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
