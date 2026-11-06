#Requires -Modules @{ ModuleName='VenafiPS'; ModuleVersion='4.2.0' }
#Requires -Version 7.0

<#
.SYNOPSIS
Find active/valid historical certificates in TPP

.DESCRIPTION
Find active/valid historical certificates in TPP.
Create a new session with New-VenafiSession before executing this script.

.PARAMETER Path
Path to start the search for certificates

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
None

.OUTPUTS
PSCustomObject with the following properties:
    Path - path to current cert
    ActiveHistory - list of valid historical certs.  Properties VaultId, Serial, and ValidTo

.EXAMPLE
$certs = & Get-TppActiveHistoricalCertificate.ps1 -Path '\ved\policy\mycerts'
Find all active historical certs starting at the path provided and searching recursively

#>

[CmdletBinding()]

param (
    [Parameter()]
    [String] $Path = '\ved\policy',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [VenafiSession] $VenafiSession = $VenafiSession
)

$certs = Find-VenafiCertificate -Path $Path -Recursive -First 5000 -IncludeTotalCount -VenafiSession $VenafiSession | Get-VenafiCertificate -IncludePreviousVersions -VenafiSession $VenafiSession

$certs | ForEach-Object -ThrottleLimit 100 -Parallel {

    $thisCert = $_

    if ( $thisCert.PreviousVersions.Count -gt 0 ) {
        $activePrev = foreach ($prev in $thisCert.PreviousVersions) {
            if ( $prev.CertificateDetails.ValidTo -gt (Get-Date)) {
                [pscustomobject]@{
                    VaultId = $prev.VaultId
                    Serial  = $prev.CertificateDetails.Serial
                    ValidTo = $prev.CertificateDetails.ValidTo
                }
            }
        }

        if ( $activePrev ) {
            [pscustomobject]@{
                Path          = $thisCert.Path
                ActiveHistory = $activePrev
            }
        }
    }
}
