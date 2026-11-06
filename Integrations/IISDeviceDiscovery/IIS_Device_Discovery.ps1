<#
//---------------------------------------------------------------------------
// IIS_Device_Discovery.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2020 Venafi, Inc. (“Venafi”). All rights reserved.
//
// Venafi hereby grants you a limited license to use and modify this
// software, including any Contributions, during only the period in which you
// hold a valid license from Venafi to use the Venafi Trust Protection
// Platform. For the purposes of this copyright notice, “Contributions” means
// any modifications of this software or derivative works based on this
// software. You have a responsibility to share any Contributions you may
// make with the Venafi community. To the extent you may create any
// Contributions, Venafi will have an irrevocable license to use, modify or
// distribute those Contributions.
//
// THE SOFTWARE IS PROVIDED AS-IS AND WITHOUT ANY WARRANTY, EXPECTATION OF
// COMPATIBILITY, TECHNICAL SUPPORT, ASSISTANCE, UPDATES, OR OTHER SERVICES
// THAT MIGHT BE PROVIDED TO YOU OTHERWISE. YOU ACKNOWLEDGE AND AGREE THAT
// THIS SOFTWARE DOES NOT CONSTITUTE COMMERCIAL RELEASE OF VENAFI SOFTWARE
// AND MAY CONTAIN BUGS OR OTHER ERRORS OR CAUSE ERRORS IN OTHER SOFTWARE OR
// SYSTEMS WHEN USED IN CONJUNCTION THEREWITH. TO THE EXTENT VENAFI HAS MADE
// ANY WARRANTIES TO YOU REGARDING THE FITNESS OF SOFTWARE FOR ANY PURPOSE,
// OR THAT SOFTWARE MAY BE FREE FROM BUGS OR OTHER ERRORS, THIS SOFTWARE AND
// ANY PRODUCTS WHEN USED IN CONJUNCTION THEREWITH ARE EXPRESSLY EXCLUDED
// FROM ANY SUCH WARRANTIES. BY USING THIS SOFTWARE, YOU HEREBY AGREE TO
// FOREVER RELEASE AND HOLD HARMLESS VENAFI, ITS DIRECTORS, OFFICERS,
// EMPLOYEES, AGENTS, AND AFFILIATES FROM ANY LIABILITY OR DEMANDS ARISING
// THEREFROM OR RELATING THERETO, REGARDLESS OF THE THEORY OF LIABILITY.
//
// The software and its contents are provided by Venafi to customers for the
// purposes of integrating with services and platforms. Any sharing of the
// software outside your organization without consent from Venafi is strictly
// prohibited. Without limiting the foregoing, the above copyright notice,
// preceding paragraphs, this paragraph and the following paragraph must
// appear in all copies, modifications, reproductions, and distributions of
// this software.
//
// IN NO EVENT SHALL VENAFI, ITS DIRECTORS, OFFICERS, EMPLOYEES, AGENTS, OR
// AFFILIATES BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL,
// INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT
// OF THE USE OF THIS SOFTWARE OR ITS DOCUMENTATION, IF ANY, EVEN IF VENAFI
// HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. VENAFI SPECIFICALLY
// DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. THIS
// SOFTWARE, ALONG WITH ITS DOCUMENTATION, IF ANY, IS PROVIDED "AS IS".
//---------------------------------------------------------------------------
#>

#requires -Version 5.0
#requires -RunAsAdministrator

$properties_path = "$($PSScriptRoot)\properties.json" # path of properties file
$properties = @{}
if (Test-Path  $properties_path) {
    $properties = ConvertFrom-Json (Get-Content $properties_path -Raw )  -ErrorAction Stop;
} else {
    Write-Error "Cannot find properties file" -ErrorAction Stop
}

#set values parsed from properties file
$TPPServer = $properties.tppFQDN
$Validate = $properties.validateIIS
$OnlyHTTPS = $properties.onlyhttps
$CSV = @{}
$properties.CSV.psobject.properties | ForEach-Object { $CSV[$_.Name] = $_.Value }
$basePolicyLocation = $properties.basePolicyLocation
$devicePolicyLocation = $properties.devicePolicyLocation
$daysInactive = $properties.daysInactive
$logging = $properties.logging
$Token = New-Object System.Management.Automation.PSCredential('AccessToken', ($properties.token | ConvertTo-SecureString -AsPlainText -Force))

function Write-Log {
	[cmdletbinding()]
	Param(
		[parameter(ValueFromPipeline)]
		[string]$message
	)
    Begin
    {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
	Process {
        if ($logging) {
            $base_path = $PSScriptRoot + "\Logs\"
            $file_prefix = $base_path + "$(Get-Date -format MMM-dd-yyyy-HH-mm)-"
            $file = $file_prefix + "ADComputers_log.txt"
            # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
            if (!(Test-Path $file)) {
                Write-Output "Creating log file $($file)."
                New-Item $file -Force -ItemType File | Out-Null
            }
            #Write log entry
            "$(Get-Date): $_" | Add-Content -Path $file
        }
	}
}

function Test-WindowsFeature {
    # This is simply checking we have what we need to run this script
    $OSVersion = (Get-CimInstance Win32_OperatingSystem).Caption
    if ($OSVersion -match "Server") {
        #Server version found
        try {
            Import-Module ServerManager
            $RSAT = Get-WindowsFeature -ErrorAction Stop | Where-Object { $_.Name -eq "RSAT-AD-PowerShell" }
        } catch {
            if ($logging) {
                $_ | ConvertTo-Json -Depth 2 | Write-Log
                Write-Error $_ -ErrorAction Stop
            } else {
                Write-Error $_ -ErrorAction Stop
            }
        }
        if ($RSAT.InstallState -eq "Installed") {
            if ($logging) {
                "Active Directory module for PowerShell is Installed" | Write-Log
            }
            else {
                Write-Output "Active Directory module for PowerShell is Installed"
            }
        }
        else {
            $InstallRSAT = Read-Host -Prompt 'Active Directory module for PowerShell is required but not installed, would you like to install? (y|n)'
            if ($InstallRSAT -imatch '^y(es)?$') {
                if ($logging) {
                    Install-WindowsFeature -Name RSAT-AD-PowerShell | Write-Log
                }
                else {
                    Install-WindowsFeature -Name RSAT-AD-PowerShell | Out-Null
                }
            }
            else {
                Write-Error 'Active Directory module is required, exiting.'
                exit
            }
        }
    }
    else {
        #Client version found
        try {
            $RSAT = Get-WindowsCapability -Online -ErrorAction Stop | Where-Object { $_.Name -match "RSAT.ActiveDirectory" }
        } catch {
            if ($logging) {
                $_ | ConvertTo-Json -Depth 2 | Write-Log
                Write-Error $_ -ErrorAction Stop
            } else {
                Write-Error $_ -ErrorAction Stop
            }
        }
        if ($RSAT.State -eq "Installed") {
            if ($logging) {
                "Active Directory Domain Services Tools are Installed" | Write-Log
            }
            else {
                Write-Output "Active Directory Domain Services Tools are Installed"
            }
        }
        else {
            $InstallRSAT = Read-Host -Prompt 'Active Directory Domain Services Tools are required but not installed, would you like to install? (y|n)'
            if ($InstallRSAT -imatch '^y(es)?$') {
                if ($logging) {
                    Add-WindowsCapability -online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" | Write-Log
                }
                else {
                    Add-WindowsCapability -online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" | Out-Null
                }
            }
            else {
                Write-Error 'Active Directory module is required, exiting.'
                exit
            }
        }
    }

}

function Get-CSVFile {
    <#
	.SYNOPSIS
		Get valid data from CSV file
	#>
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InputFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ColumnsExpected
    )
    # Checks to make sure we have a correct file to import
    if (-not (Test-Path $InputFile)) {
        Throw "Unable to open Input File"
    }

    # Import and verify row data from CSV
    if ($logging) {
        "Importing CSV $($InputFile) using a delimiter of $($CSV.fileDelimiter)" | Write-Log
    }
    $rows = Import-CSV $InputFile -Delimiter $CSV.fileDelimiter
    $RowsCsv = Get-Content $InputFile | Measure-Object -Line
    if ($RowsCsv.Lines -eq 1) {
        if ($logging) {
            "No viable rows found!" | Write-Log
        }
        Throw "The csv format is incorrect! - No rows to import"
    }
    # Verify that all expected columns are there (additional columns in the csv will be ignored)
    $ColumnsCsv = $rows | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    if ($null -ne $ColumnsExpected) {
        $ColumnsExpected | ForEach-Object {
            If ($ColumnsCsv -notcontains $_) {
                if ($logging) {
                    "Expected column not found: '$($_)'" | Write-Log
                }
                Throw "The csv format is incorrect! - Column missing"
            }
        }
    }
    else {
        Throw "Name of columns must be specified"
    }
    if ($logging) {
        "$($InputFile) contains the correct information" | Write-Log
    }
    return $rows
}
function Invoke-TPPRestMethod {
    [CmdletBinding()]

    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [pscredential] $AccessToken,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('ServerUrl')]
        [String] $Server,

        [Parameter()]
        [ValidateSet("Get", "Post")]
        [String] $Method = 'Get',

        [Parameter()]
        [String] $UriRoot = 'vedsdk',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $UriLeaf,

        [Parameter()]
        [hashtable] $Header,

        [Parameter()]
        [Hashtable] $Body,

        [Parameter()]
        [switch] $FullResponse,

        [Parameter()]
        [switch] $SkipCertificateCheck
    )

    if ( $AccessToken ) {
        $allHeaders = @{'Authorization' = 'Bearer {0}' -f $AccessToken.GetNetworkCredential().password }
    }

    $serverUrl = $Server
    # add prefix if just server url was provided
    if ( $serverUrl -notlike 'https://*') {
        $Server = 'https://{0}' -f $serverUrl
    }

    $uri = '{0}/{1}/{2}' -f $Server, $UriRoot, $UriLeaf

    $params = @{
        Method          = $Method
        Uri             = $uri
        ContentType     = 'application/json'
        UseBasicParsing = $true
    }

    # append any headers passed in
    if ( $Header ) { $allHeaders += $Header }
    # if there are any headers, add to the rest payload
    # in the case of inital authentication, eg, there won't be any
    if ( $allHeaders ) { $params.Headers = $allHeaders }

    if ( $Body ) {
        $restBody = $Body
        switch ($Method.ToLower()) {
            'get' {
                $params.Body = $restBody
            }

            Default {
                $restBody = ConvertTo-Json $Body -Depth 20 -Compress
                $params.Body = $restBody
            }
        }
    }

    if ( $SkipCertificateCheck ) {
        if ( $PSVersionTable.PSVersion.Major -lt 6 ) {
            if ( [System.Net.ServicePointManager]::CertificatePolicy.GetType().FullName -ne 'TrustAllCertsPolicy' ) {
                add-type @"
                using System.Net;
                using System.Security.Cryptography.X509Certificates;
                public class TrustAllCertsPolicy : ICertificatePolicy {
                    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                        return true;
                    }
                }
"@
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            }
        }
        else {
            $params.Add('SkipCertificateCheck', $true)
        }
    }

    $oldProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    try {
        $response = Invoke-WebRequest @params -ErrorAction Stop
    }
    catch {

        # if trying with a slash below doesn't work, we want to provide the original error
        $originalError = $_

        $statusCode = [int]$originalError.Exception.Response.StatusCode
        Write-Verbose ('Response status code {0}' -f $statusCode)

        switch ($statusCode) {
            403 {
                throw 'A permissions error was encountered.  Ensure both the permissions and token scope are correct.'
            }

            409 {
                # 409 = item already exists.  some functions use this for a 'force' option, eg. Set-TppPermission
                # treat this as non error/exception if FullResponse provided
                if ( $FullResponse ) {
                    $response = [pscustomobject] @{
                        StatusCode = $statusCode
                        Error      =
                        try {
                            $originalError.ErrorDetails.Message | ConvertFrom-Json
                        }
                        catch {
                            $originalError.ErrorDetails.Message
                        }
                    }
                }
                else {
                    throw $originalError
                }
            }

            Default {
                throw $originalError
            }
        }

    }
    finally {
        $ProgressPreference = $oldProgressPreference
    }

    if ( $FullResponse ) {
        $response
    }
    else {
        if ( $response.Content ) {
            try {
                $response.Content | ConvertFrom-Json
            }
            catch {
                throw ('Invalid JSON response {0}' -f $response.Content)
            }
        }
    }
}
function Find-Devices {
    <#
	.SYNOPSIS
		Finds all device objects that are the specific class, returns DN if successful, error otherwise
	#>
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ParentDN,
        [string]
        $Pattern,
        [bool]
        $Recursive = $true,
        [Parameter(Mandatory)]
        [pscredential] $AccessToken,
        [Parameter()]
        [switch] $SkipCertificateCheck
    )

    begin {
        $serverUrl = $TPPServer

        $params = @{
            Server  = $serverUrl
            Method  = 'POST'
            UriLeaf = 'Config/FindObjectsOfClass'
            AccessToken = $AccessToken
        }

        $bodyHash = @{'Class'='Device'}
        if ($ParentDN) {
            $bodyHash.Add('ObjectDN', $ParentDN)
        }
        if ($Pattern) {
            $bodyHash.Add('Pattern', $Pattern)
        }
        if ($Recursive) {
            $bodyHash.Add('Recursive', $Recursive)
        }
        $params.Body = $bodyHash

        if ($SkipCertificateCheck) {
            $params.SkipCertificateCheck = $SkipCertificateCheck
        }

        Write-Verbose ($params | Out-String)

    }

    process {
        try {
            $response = Invoke-TPPRestMethod @params -ErrorAction Stop
        } catch {
            $originalError = $_
            $statusCode = [int]$originalError.Exception.Response.StatusCode
            Write-Verbose ('Response status code {0}' -f $statusCode)
            switch ($statusCode) {
                400 {
                    throw ('Invalid request. Cannot retrieve objects.')
                }
                401 {
                    throw ('Token is revoked, has expired, or is invalid. Please generate a new token and add to the properties file.')
                }
                Default {
                    throw $originalError
                }
            }
        }

        if (($response.Result -eq 1) -and ($null -ne $response.objects)) {
            return $response.Objects
        } else {
            Write-Error ('Retrieval of class Device failed with error {0}' -f $response.Error)
        }
    }
}

function New-Device {
    <#
	.SYNOPSIS
		Creates a new device object, returns DN if successful, error otherwise
	#>
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ParentDN,
        [string]
        $Hostname,
        [Parameter(Mandatory)]
        [pscredential] $AccessToken,
        [Parameter()]
        [switch] $SkipCertificateCheck
    )

    begin {
        $serverUrl = $TPPServer

        $params = @{
            Server  = $serverUrl
            Method  = 'POST'
            UriLeaf = 'Config/Create'
            AccessToken = $AccessToken
        }

        $bodyHash = @{'Class'='Device'}
        if ($ParentDN) {
            $bodyHash.Add('ObjectDN', $ParentDN)
        }
        if ($hostname) {
            $attList = @( @{Name = "Host"; Value = "$Hostname" } )
            $bodyHash.Add('NameAttributeList', $attList)
        }
        $params.Body = $bodyHash

        if ($SkipCertificateCheck) {
            $params.SkipCertificateCheck = $SkipCertificateCheck
        }

        Write-Verbose ($params | Out-String)

    }

    process {
        try {
            $response = Invoke-TPPRestMethod @params -ErrorAction Stop
        } catch {
            $originalError = $_
            $statusCode = [int]$originalError.Exception.Response.StatusCode
            Write-Verbose ('Response status code {0}' -f $statusCode)
            switch ($statusCode) {
                400 {
                    throw ('Invalid request. Cannot create objects.')
                }
                401 {
                    throw ('Token is revoked, has expired, or is invalid. Please generate a new token and add to the properties file.')
                }
                Default {
                    throw $originalError
                }
            }
        }

        if (($response.Result -eq 1) -and ($null -ne $response.object)) {
            return $response.Object
        }
        else {
            Write-Error ('Creation of class Device failed with error {0}' -f $response.Error)
            Continue
        }
    }
}

function Get-TppTokenExpiry {

    [CmdletBinding(DefaultParameterSetName = 'AccessToken')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [ValidateScript( {
                if ( $_ -match '^(https?:\/\/)?(((?!-))(xn--|_{1,1})?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$' ) {
                    $true
                }
                else {
                    throw 'Please enter a valid server, https://venafi.company.com or venafi.company.com'
                }
            }
        )]
        [Alias('Server')]
        [string] $AuthServer,

        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [pscredential] $AccessToken
    )
    begin {
        $serverUrl = $AuthServer

        $params = @{
            Server  = $serverUrl
            Method  = 'GET'
            UriRoot = 'vedauth'
            UriLeaf = 'Authorize/Verify'
            AccessToken = $AccessToken
            }

            Write-Verbose ($params | Out-String)

        }

    process {
        try {
            $response = Invoke-TPPRestMethod @params -FullResponse

            switch ( $response.StatusCode ) {

                200 {
                    $responseData = $response.Content | ConvertFrom-Json
                    $AccessIssued = ([datetime] '1970-01-01 00:00:00').AddSeconds($responseData.access_issued_on_unix_time)
                    $responseValidFor = $AccessIssued.AddSeconds($responseData.valid_for)
                    return "Token is valid until $($responseValidFor)"
                }

                Default {
                    throw ('Grant has been revoked, has expired, or the refresh token is invalid.')
                }
            }
        } catch {
            throw ('Token is revoked, has expired, or is invalid. Please generate a new token and add to the properties file.')
        }
    }
}

function Get-IISSiteInfo {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin {
        $SessionParams = @{
            ErrorAction = 'SilentlyContinue'
        }
        $Computers = @()
        foreach ($Computer in $ComputerName) {
            if ($PSBoundParameters['Credential']) {
                if (Test-WSMan -ComputerName $Computer -Authentication Default -Credential $Credential -ErrorAction SilentlyContinue) {
                    $Computers += $Computer
                } else {
                    if ($logging) {
                        "Get-IISSiteInfo: Unable to establish session to $($Computer)" | Write-Log
                    } else {
                        Write-Warning "Get-IISSiteInfo: Unable to establish session to $($Computer)"
                    }
                }
            } else {
                if (Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue) {
                    $Computers += $Computer
                } else {
                    if ($logging) {
                        "Get-IISSiteInfo: Unable to establish session to $($Computer)" | Write-Log
                    } else {
                        Write-Warning "Get-IISSiteInfo: Unable to establish session to $($Computer)"
                    }
                }
            }
        }
        if ([string]::IsNullOrEmpty($Computers)) {
            if ($logging) {
                "Cannot connect to any computers: Insufficient permissions or wrong password" | Write-Log
                Write-Error "Cannot connect to any computers: Insufficient permissions or wrong password" -ErrorAction Stop
            } else {
                Write-Error "Cannot connect to any computers: Insufficient permissions or wrong password" -ErrorAction Stop
            }
        }

        if ($PSBoundParameters['Credential']) {
            $SessionParams.Credential = $Credential
            $SessionParams.ComputerName = $Computers
            try {
                $IISPSSession = New-PSSession @SessionParams
                $IISCimSession = New-CimSession @SessionParams
            } catch {
                if ($logging) {
                    "Get-IISSiteInfo: Unable to establish session to one or more computers" | Write-Log
                    Write-Error "Unable to establish session to one or more computers" -ErrorAction Stop
                } else {
                    Write-Error "Unable to establish session to one or more computers" -ErrorAction Stop
                }
            }
        }
    }

    Process {
        try {
            if ($PSBoundParameters['Credential']) {
                $SiteCheck = @()
                if ($IISCimSession) {
                    $IISCheck = Get-CimInstance -CimSession $IISCimSession -ClassName Win32_Service -Filter "name='W3SVC'" | Where-Object { $_.State -eq "Running" }
                }
                foreach ($check in $IISPSSession.ComputerName) {
                    if ($IISCheck.PSComputerName -notcontains $Check) {
                        if ($logging) {
                            "Get-IISSiteInfo: Unable to get IIS Site Info from $($Check)" | Write-Log
                        } else {
                            Write-Warning "Get-IISSiteInfo: Unable to get IIS Site Info from $($Check)"
                        }
                        Remove-PSSession -ComputerName $check
                        $IISPSSession = Get-PSSession
                    }
                }
                if (($IISCheck.Status -eq 'OK') -and ($IISPSSession)) {
                    $GetSite = New-Object Object
                    $GetSite = Invoke-Command -Session $IISPSSession {
                        $GetWebadmin = Get-Module -ListAvailable | Where-Object { $_.Name -eq "WebAdministration" }
                        if ($null -ne $GetWebadmin) {
                            Get-WebSite -ErrorAction SilentlyContinue | Select-Object Name,
                            @{Name='Bindings'; Expression={$_.Bindings.Collection.Protocol}}
                        }
                    }
                    $SiteCheck = $GetSite | Select-Object @{Name='Name'; Expression={$_.PSComputerName}},
                        @{Name='SiteName'; Expression={$_.Name}},
                        @{Name='IISBindings'; Expression={
                            ForEach-Object {
                                if (($_.Bindings -contains 'https') -and ($_.Bindings -contains 'http')) {
                                    "http/https"
                                } elseif (($_.Bindings -contains 'https') -and ($_.Bindings -notcontains 'http')) {
                                    "https"
                                } elseif (($_.Bindings -contains 'http') -and ($_.Bindings -notcontains 'https')) {
                                    "http"
                                } else {
                                    "Other"
                                }
                            }
                        }
                    }
                    if ($OnlyHTTPS) {
                        $SiteCheck = $SiteCheck | Where-Object { $_.IISBindings -match 'https'}
                    }
                } elseif (($IISCheck.Status -eq 'OK') -and ($IISCimSession)) {
                    Write-Error "PSSession is required to get IIS Site Info" -ErrorAction Stop
                } elseif ($IISCimSession) {
                    Write-Warning "Unable to find additional IIS Sites"
                } else {
                    Write-Error "Unable to get IIS Site Info" -ErrorAction Stop
                }
            }
        } catch {
            Write-Error $_ -ErrorAction Stop
        }
    }

    End {
        $script:SiteStatus = @()
        if ($IISCimSession) {
            Get-CimSession | Remove-CimSession
            Clear-Variable 'IISCimSession'
        }
        if ($IISPSSession) {
            Get-PSSession | Remove-PSSession
            Clear-Variable 'IISPSSession'
        }
        if ($PSBoundParameters['Credential']) {
            $script:SiteStatus = $SiteCheck | Select-Object "Name", "SiteName", "IISBindings" | Where-Object {$_.Name -match '\S'}
            return $script:SiteStatus
        } else {
            $script:SiteStatus = $Computers | Select-Object @{Name='Name'; Expression={$_}} | Where-Object {$_.Name -match '\S'}
            return $script:SiteStatus
        }
    }
}

if ($logging) {
    $testoken = Get-TppTokenExpiry -AuthServer $TPPServer -AccessToken $Token
    $testoken | Write-Log
} else {
    Get-TppTokenExpiry -AuthServer $TPPServer -AccessToken $Token
}

if ((-not $CSV.readFile) -or ($Validate)) {
    Write-Output "Enter AD Credentials"
    $Credentials = Get-Credential
}
#Validate that AD Powershell features are present
if ((-not $CSV.readFile) -and ($Credentials)) {
    Test-WindowsFeature
}

# Get list of all devices in TPP & remove any that are just IP's
$inventory = @()
$devices = Find-Devices -ParentDN $basePolicyLocation -AccessToken $Token
$inventory = foreach ($device in $devices) {
    $IsIP = [ipaddress]::TryParse("$($device.Name)",[ref]$null)
    if (!$IsIP) {
        @{
            Name = $device.Name
            Parent = $device.Parent
        }
    }
}
# Get list of computers to import and remove any already in TPP
$filteredComputers = @()
if ($CSV.readFile) {
    $FileColumns = @('PSComputerName')
    $computers = (Get-CSVFile -InputFile $CSV.inputFile -ColumnsExpected $FileColumns)
    foreach ($ServerImport in $computers.PSComputerName) {
        $IsIP = [ipaddress]::TryParse("$($ServerImport)",[ref]$null)
        If ($IsIP) {
            try {
                $dnsRecord = (Resolve-DnsName $ServerImport -ErrorAction Stop).NameHost
            } catch {
                $dnsRecord = ''
                if ($logging) {
                    "DNS reverse name lookup failed: $($PSItem)" | Write-Log
                    $PSItem.InvocationInfo.PositionMessage | Write-Log
                } else {
                    Write-Output "DNS reverse name lookup failed: $($PSItem)"
                    Write-Verbose "$($PSItem.InvocationInfo.PositionMessage)"
                }
            }
            if ($inventory.Name -contains $dnsRecord) {
                $inv = $inventory | Where-Object {$_.Name -contains $dnsRecord}
                if ($logging) {
                    "$($dnsRecord) was already in $($inv.Parent)" | Write-Log
                } else {
                    Write-Output "$($dnsRecord) was already in $($inv.Parent)"
                }
            } else {
                $filteredComputers += $dnsRecord
            }
        } else {
            try {
                $dnsRecord = (Resolve-DnsName $ServerImport -ErrorAction Stop | Where-Object { $_.Type -eq 'A' }).Name
            } catch {
                $dnsRecord = ''
                if ($logging) {
                    "DNS name lookup failed: $($PSItem)" | Write-Log
                    $PSItem.InvocationInfo.PositionMessage | Write-Log
                } else {
                    Write-Output "DNS name lookup failed: $($PSItem)"
                    Write-Verbose "$($PSItem.InvocationInfo.PositionMessage)"
                }
            }
            if ($inventory.Name -contains $dnsRecord) {
                $inv = $inventory | Where-Object {$_.Name -contains $dnsRecord}
                if ($logging) {
                    "$($dnsRecord) was already in $($inv.Parent)" | Write-Log
                } else {
                    Write-Output "$($dnsRecord) was already in $($inv.Parent)"
                }
            } else {
                $filteredComputers += $dnsRecord
            }
        }
    }
} elseif ((-not $CSV.readFile) -and ($Credentials)) {
        $LastLogon = $(((Get-Date).AddDays(-($daysInactive))).ToFileTime())
        try {
            $ADcomputers = Get-ADComputer -LDAPFilter "(&(operatingSystem=*server*)(lastlogontimestamp>=$LastLogon))" -Credential $Credentials
        } catch {
            if ($logging) {
                "AD Computer lookup failed: $($PSItem)" | Write-Log
                $PSItem.InvocationInfo.PositionMessage | Write-Log
            } else {
                Write-Output "AD Computer lookup failed: $($PSItem)"
                Write-Verbose "$($PSItem.InvocationInfo.PositionMessage)"
            }
        }
        foreach ($ServerImport in $ADcomputers.DNSHostName) {
            try {
                $dnsRecord = (Resolve-DnsName $ServerImport -ErrorAction Stop | Where-Object { $_.Type -eq 'A' }).Name
            } catch {
                $dnsRecord = $null
                if ($logging) {
                    "DNS name lookup failed: $($PSItem)" | Write-Log
                    $PSItem.InvocationInfo.PositionMessage | Write-Log
                } else {
                    Write-Output "DNS name lookup failed: $($PSItem)"
                    Write-Verbose "$($PSItem.InvocationInfo.PositionMessage)"
                }
            }
            if ($inventory.name -contains $dnsRecord) {
                $inv = $inventory | Where-Object {$_.Name -contains $dnsRecord}
                if ($logging) {
                    "$($dnsRecord) was already in $($inv.Parent)" | Write-Log
                } else {
                    Write-Output "$($dnsRecord) was already in $($inv.Parent)"
                }
            } else {
                $filteredComputers += $dnsRecord
            }
        }
} else {
    if ($logging) {
        "No list of computers to import!" | Write-Log
    } else {
        Write-Error "No list of computers to import!" -ErrorAction Stop
    }
}
#Use Get-IISSiteInfo to test connection to server first using test-wsman
$filteredComputers = $filteredComputers | Where-Object {$_ -match '\S'} | Select-Object -Unique
$ComputerCheck = @()
if (($Credentials) -and ($Validate)) {
    $ComputerCheck = Get-IISSiteInfo -ComputerName $filteredComputers -Credential $Credentials
    foreach ($comp in $ComputerCheck) {
        if ($logging) {
            "Found IIS site $($comp.SiteName) on $($comp.Name) using $($comp.IISBindings) bindings." | Write-Log
        } else {
            Write-Host "Found IIS site $($comp.SiteName) on $($comp.Name) using $($comp.IISBindings) bindings."
        }
    }
} else {
    $ComputerCheck = Get-IISSiteInfo -ComputerName $filteredComputers
    foreach ($comp in $ComputerCheck) {
            if ($logging) {
            "Found WinRM running on $($comp.Name)." | Write-Log
        } else {
            Write-Host "Found WinRM running on $($comp.Name)."
        }
    }
}
# loop through each computer, then add to TPP
$ComputerCheck = $ComputerCheck | Sort-Object -Unique -Property Name
foreach ($computer in $ComputerCheck.Name) {
    $CreateDevice = New-Device -ParentDN $devicePolicyLocation\$computer -hostname $computer -AccessToken $Token
    if ($logging) {
        "$($CreateDevice.Name) was added to $($CreateDevice.Parent)" | Write-Log
    } else {
        Write-Output "$($CreateDevice.Name) was added to $($CreateDevice.Parent)"
    }
}
