<#
//------------------------------------------------------------------------
// Radware_Alteon_Connector_For_PaloAlto_1.0.0.ps1
// Version:  1.0.0
// Author:   Yehuda Pinchas, yehudap@radware.com
// Support:  ase@radware.com; support@radware.com
// Copyright (c) 2026 Radware LTD.  All rights reserved.
//------------------------------------------------------------------------

<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Policyable
Bit 3 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text1|Virtual Server|110
Text2|Service Port|110
Text3|SSL Policy|110
Text4|Certificate Name in Alteon|101
Option1|Trust Insecure Alteon Device Management Certificate|110
Option2|Not Used|000
Passwd|Not Used|000
-----END FIELD DEFINITIONS-----
#>

function Write-VenafiDebug
{
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Message
    )

    if ($global:DEBUG_FILE) {
        ('{0} : {1}' -f (Get-Date), $Message) |
            Out-File -FilePath $global:DEBUG_FILE -Encoding UTF8 -Append
    }
}


<######################################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    Discover Certificates
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################>

function Discover-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    if ( $DEBUG_FILE ) { "Starting Discover-Certificates function" | Write-VenafiDebug }

    # TcpPort can be empty during onboard discovery (no application object yet).
    $mgmtPort = if ([int]$General.TcpPort) { $General.TcpPort } else { 443 }
    $alteon = "$($General.HostAddress):$mgmtPort"
    $username = [string]$General.UserName
    $password = [string]$General.UserPass
    $trustInsecure = $General.VarBool1 -eq $true

    $vips = (Invoke-AlteonApi GET "https://$alteon/config/SlbCurCfgEnhVirtServerTable?count=3000&props=VirtServerIndex,VirtServerIpVer,VirtServerIpAddress,VirtServerIpv6Addr" | ConvertFrom-Json).SlbCurCfgEnhVirtServerTable
    $services = (Invoke-AlteonApi GET "https://$alteon/config/SlbCurCfgEnhVirtServicesTable?count=3000&props=ServIndex,Index,VirtPort" | ConvertFrom-Json).SlbCurCfgEnhVirtServicesTable
    $bindings = (Invoke-AlteonApi GET "https://$alteon/config/SlbCurCfgEnhVirtServicesSecondPartTable?count=3000&props=ServSecondPartIndex,SecondPartIndex,SSLpol,ServCert" | ConvertFrom-Json).SlbCurCfgEnhVirtServicesSecondPartTable

    # Skips services bound to a certificate group (no single certificate to export).
    $serverCerts = @(Get-CertificateRows | Where-Object { [int]$_.Type -eq 3 }).ID
    $apps = @()

    foreach ($b in @($bindings | Where-Object { $serverCerts -contains $_.ServCert })) {
        $vip = [string]$b.ServSecondPartIndex
        $port = [string]($services | Where-Object { $_.ServIndex -eq $vip -and $_.Index -eq $b.SecondPartIndex } | Select-Object -First 1).VirtPort
        $vipRow = $vips | Where-Object { $_.VirtServerIndex -eq $vip } | Select-Object -First 1
        $vipAddress = if ([int]$vipRow.VirtServerIpVer -eq 2) { [string]$vipRow.VirtServerIpv6Addr } else { [string]$vipRow.VirtServerIpAddress }

        $pem = Invoke-AlteonApi GET "https://$alteon/config/getcert?id=$([Uri]::EscapeDataString($b.ServCert))&src=txt&type=srvcrt"

        $apps += @{
            Name              = "$vip-$port"
            PEM               = $pem
            ValidationAddress = $vipAddress
            ValidationPort    = $port
            Attributes = @{
                'Text Field 1' = $vip
                'Text Field 2' = $port
                'Text Field 3' = [string]$b.SSLpol
                'Text Field 4' = [string]$b.ServCert
            }
        }
    }

    if ( $DEBUG_FILE ) { "Discovered $($apps.Count) application(s)" | Write-VenafiDebug }

    return @{ Result="Success"; Applications=$apps; }
}


<######################################################################################################################
.NAME
    Prepare-KeyStore
.DESCRIPTION
    Remotely create and/or verify keystore on the hosting platform.  Remote generation is considered UNSUPPORTED if this
    function is ommitted or commented out.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
        AppObjectDN : a string containing the TPP distiguished name of the calling application object
        AssetName : a string containing a Venafi standard auto-generated name that can be used for provisioning
                    (<Common Name>-<ValidTo as YYMMDD>-<Last 4 of SerialNum>)
        VarText1 : a string value for the text custom field defined by the header at the top of this script
        VarText2 : a string value for the text custom field defined by the header at the top of this script
        VarText3 : a string value for the text custom field defined by the header at the top of this script
        VarText4 : a string value for the text custom field defined by the header at the top of this script
        VarText5 : a string value for the text custom field defined by the header at the top of this script
        VarBool1 : a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarBool2 : a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarPass : a string value for the password custom field defined by the header at the top of this script
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################>
function Prepare-KeyStore
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Generate-KeyPair
.DESCRIPTION
    Remotely generates a public-private key pair on the hosting platform.  Remote generation is
    considered UNSUPPORTED if this function is ommitted or commented out.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        KeySize : the integer key size to be used when creating a key pair
        EncryptPass : the password string to use if encrypting the remotely generated private key
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device;
                    if not supplied the auto-generated name is assumed
######################################################################################################################>
function Generate-KeyPair
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Generate-CSR
.DESCRIPTION
    Remotely generates a CSR on the hosting platform.  Remote generation is considered UNSUPPORTED
    if this function is ommitted or commented out.
######################################################################################################################>
function Generate-CSR
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="Success"; Pkcs10="-----BEGIN CERTIFICATE REQUEST-----..."; }
}


<######################################################################################################################
.NAME
    Install-Chain
.DESCRIPTION
    Installs the certificate chain on the hosting platform.
######################################################################################################################>
function Install-Chain
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Install-PrivateKey
.DESCRIPTION
    Installs the private key on the hosting platform.
######################################################################################################################>
function Install-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="Success"; }
}


<######################################################################################################################
.NAME
    Install-Certificate
.DESCRIPTION
    Installs the certificate on the hosting platform.  May optionally be used to also install the private key and chain.
    Implementing logic for this function is REQUIRED.
######################################################################################################################>
function Install-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,

        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    if ( $DEBUG_FILE ) { "Starting Install-certificate function" | Write-VenafiDebug }

    $alteon = "$($General.HostAddress):$($General.TcpPort)"
    $username = [string]$General.UserName
    $password = [string]$General.UserPass
    $certName = [string]$General.VarText4
    $trustInsecure = $General.VarBool1 -eq $true

    if ( $DEBUG_FILE ) { "alteon is: $alteon, username is: $username, certName is: $certName, trustInsecure is: $trustInsecure" | Write-VenafiDebug }
    if ( $DEBUG_FILE ) { "chain PEM is: $($Specific.ChainPem)" | Write-VenafiDebug }
    $changed = $false
    $desiredLeafFp = Get-Fingerprint $Specific.CertPem
    if ( $DEBUG_FILE ) { "desiredLeafFp is: $desiredLeafFp" | Write-VenafiDebug }
    $cas = @(Get-IntermediateCertificates $Specific.ChainPem)
    $groupName = if ($cas.Count) { Get-GroupName $cas } else { $null }
    if ( $DEBUG_FILE ) { "groupName is: $groupName" | Write-VenafiDebug }

    # ---------------------------------------------------------------------------
    # Intermediate CA(s) + group
    # ---------------------------------------------------------------------------

    if ($groupName) {
        $certRows = Get-CertificateRows
        $newCas = @()

        foreach ($ca in $cas) {
            $row = $certRows | Where-Object { $_.ID -eq $ca.Name -and [int]$_.Type -eq 5 } | Select-Object -First 1
            $id = [Uri]::EscapeDataString($ca.Name)

            if (-not $row) {
                if ( $DEBUG_FILE ) { "Uploading intermediate CA: $($ca.Name) ($($ca.CommonName))" | Write-VenafiDebug }
                Invoke-AlteonApi POST "https://$alteon/config/sslcertimport?renew=0&id=$id&type=inca&src=txt" -Body $ca.Pem -ContentType 'text/plain;charset=UTF-8' | Out-Null
                $newCas += $ca.Name
                $changed = $true
            }
            elseif ([string]$row.CommonName -ne $ca.CommonName) {
                if ( $DEBUG_FILE ) { "Replacing intermediate CA: $($ca.Name) (device CN: $($row.CommonName), chain CN: $($ca.CommonName))" | Write-VenafiDebug }
                Invoke-AlteonApi POST "https://$alteon/config/sslcertimport?renew=1&id=$id&type=inca&src=txt" -Body $ca.Pem -ContentType 'text/plain;charset=UTF-8' | Out-Null
                $changed = $true
            }
        }

        $group = Get-GroupRows | Where-Object { $_.ID -eq $groupName } | Select-Object -First 1

        if (-not $group) {
            if ( $DEBUG_FILE ) { "Creating intermediate group: $groupName" | Write-VenafiDebug }

            $body = @{Type=5} | ConvertTo-Json -Compress
            Invoke-AlteonApi POST "https://$alteon/config/SlbNewSslCfgGroupsTable/$groupName/" -Body $body | Out-Null

            foreach ($ca in $cas) {
                $body = @{AddCert=$ca.Name} | ConvertTo-Json -Compress
                Invoke-AlteonApi PUT "https://$alteon/config/SlbNewSslCfgGroupsTable/$groupName/" -Body $body | Out-Null
            }

            $changed = $true
        }
        else {
            foreach ($ca in $newCas) {
                $body = @{AddCert=$ca} | ConvertTo-Json -Compress
                Invoke-AlteonApi PUT "https://$alteon/config/SlbNewSslCfgGroupsTable/$groupName/" -Body $body | Out-Null
            }
        }
    }

    # ---------------------------------------------------------------------------
    # Server certificate
    # ---------------------------------------------------------------------------

    $certRows = Get-CertificateRows
    $serverRow = $certRows | Where-Object { $_.ID -eq $certName -and [int]$_.Type -eq 3 } | Select-Object -First 1

    $oldChainType = [string]$serverRow.IntermcaChainType
    $oldChainName = [string]$serverRow.IntermcaChainName

    $serverExists = [bool]$serverRow
    $serverMatches = $false
    $id = [Uri]::EscapeDataString($certName)

    if ($serverExists) {
        try {
            $pem = Invoke-AlteonApi GET "https://$alteon/config/getcert?id=$id&src=txt&type=srvcrt"
            $serverMatches = (Get-Fingerprint $pem) -eq $desiredLeafFp
        }
        catch { if ( $DEBUG_FILE ) { "getcert failed: $_" | Write-VenafiDebug } }
    }

    if ( $DEBUG_FILE ) { "Server certificate $certName exists: $serverExists, matches: $serverMatches, old chain: $oldChainType $oldChainName" | Write-VenafiDebug }

    if (-not $serverMatches) {
        $renew = if ($serverExists) { 1 } else { 0 }

        Invoke-AlteonApi POST "https://$alteon/config/sslcertimport?renew=$renew&id=$id&type=cert&src=txt" -Body $Specific.CertPem -ContentType 'text/plain;charset=UTF-8' | Out-Null
        Invoke-AlteonApi POST "https://$alteon/config/sslcertimport?renew=$renew&id=$id&type=key&src=txt" -Body $Specific.PrivKeyPem -ContentType 'text/plain;charset=UTF-8' | Out-Null

        $changed = $true
    }

    # ---------------------------------------------------------------------------
    # Attach desired group
    # ---------------------------------------------------------------------------

    if ($groupName) {
        $serverRow = Get-CertificateRows | Where-Object { $_.ID -eq $certName -and [int]$_.Type -eq 3 } | Select-Object -First 1

        if (
            [string]$serverRow.IntermcaChainType -ne 'group' -or
            [string]$serverRow.IntermcaChainName -ne $groupName
        ) {
            if ( $DEBUG_FILE ) { "Attaching group: $groupName" | Write-VenafiDebug }

            $body = @{IntermcaChainType='group'} | ConvertTo-Json -Compress
            Invoke-AlteonApi PUT "https://$alteon/config/SlbNewSslCfgCertsTable/$id/3/" -Body $body | Out-Null

            $body = @{IntermcaChainName=$groupName} | ConvertTo-Json -Compress
            Invoke-AlteonApi PUT "https://$alteon/config/SlbNewSslCfgCertsTable/$id/3/" -Body $body | Out-Null

            $serverRow = Get-CertificateRows | Where-Object { $_.ID -eq $certName -and [int]$_.Type -eq 3 } | Select-Object -First 1

            if (
                [string]$serverRow.IntermcaChainType -ne 'group' -or
                [string]$serverRow.IntermcaChainName -ne $groupName
            ) {
                throw 'Intermediate group binding verification failed'
            }

            $changed = $true
        }
    }

    # ---------------------------------------------------------------------------
    # Cleanup: old group + orphaned driver-managed intermediate CAs
    # ---------------------------------------------------------------------------

    if ($oldChainType -eq 'group' -and $oldChainName -and $oldChainName -ne $groupName) {

        $certRows = Get-CertificateRows

        # Old group still bound to another server certificate?
        $groupUsed = @($certRows | Where-Object {
            [int]$_.Type -eq 3 -and $_.IntermcaChainType -eq 'group' -and $_.IntermcaChainName -eq $oldChainName
        }).Count -gt 0

        if ($groupUsed) {
            if ( $DEBUG_FILE ) { "Keeping old group - still used: $oldChainName" | Write-VenafiDebug }
        }
        else {
            if (Get-GroupRows | Where-Object { $_.ID -eq $oldChainName }) {
                if ( $DEBUG_FILE ) { "Deleting unused group: $oldChainName" | Write-VenafiDebug }
                $gid = [Uri]::EscapeDataString($oldChainName)
                Invoke-AlteonApi DELETE "https://$alteon/config/SlbNewSslCfgGroupsTable/$gid/" | Out-Null
                $changed = $true
            }

            # Commit group removal first - device won't delete a CA still referenced by it.
            if ($changed) { Invoke-AlteonApplySaveSync }

            # Re-read committed state; driver CAs not in the desired chain + slots used by remaining groups.
            $certRows  = Get-CertificateRows
            $caRows    = @($certRows | Where-Object { [int]$_.Type -eq 5 -and $_.ID -like 'vca_*' -and $cas.Name -notcontains $_.ID })
            $caSlots   = if ($caRows.Count) { Get-CaSlots $caRows.ID } else { @{} }
            $usedSlots = @(Get-GroupRows | ForEach-Object { Get-BmapSlots $_.CertBmap })
            if ( $DEBUG_FILE ) { "caSlots is: $(($caSlots.Keys | ForEach-Object { "$_=$($caSlots[$_])" }) -join ', '), usedSlots is: $($usedSlots -join ',')" | Write-VenafiDebug }

            # Delete those not in any group or bound to a cert.
            foreach ($ca in $caRows) {
                $caName = [string]$ca.ID

                $directUse = @($certRows | Where-Object {
                    [int]$_.Type -eq 3 -and $_.IntermcaChainType -eq 'cert' -and $_.IntermcaChainName -eq $caName
                }).Count -gt 0

                if (($usedSlots -contains $caSlots[$caName]) -or $directUse) { continue }

                if ( $DEBUG_FILE ) { "Deleting orphan intermediate CA: $caName" | Write-VenafiDebug }
                $caId = [Uri]::EscapeDataString($caName)
                Invoke-AlteonApi DELETE "https://$alteon/config/SlbNewSslCfgCertsTable/$caId/5/" -Body '{}' | Out-Null
                $changed = $true
            }
        }
    }

    # ---------------------------------------------------------------------------
    # Apply / Save / Sync once
    # ---------------------------------------------------------------------------

    if ($changed) {
        if ( $DEBUG_FILE ) { "Configuration changed - Apply / Save / Sync" | Write-VenafiDebug }
        Invoke-AlteonApplySaveSync
    }
    else {
        if ( $DEBUG_FILE ) { "Certificate, chain and binding already match" | Write-VenafiDebug }
    }

    return @{ Result = 'Success'; AssetName = $certName }
}


<######################################################################################################################
.NAME
    Update-Binding
.DESCRIPTION
    Binds the installed certificate with the consuming application or service on the hosting platform
######################################################################################################################>
function Update-Binding
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Activate-Certificate
.DESCRIPTION
    Performs any post-installation operations necessary to make the certificate active (such as restarting a service)
######################################################################################################################>
function Activate-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Extract-Certificate
.DESCRIPTION
    Extracts the active certificate from the hosting platform.
######################################################################################################################>
function Extract-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    if ( $DEBUG_FILE ) { "Starting Extract-Certificate function" | Write-VenafiDebug }

    $alteon = "$($General.HostAddress):$($General.TcpPort)"
    $username = [string]$General.UserName
    $password = [string]$General.UserPass
    $certName = [string]$General.VarText4
    $trustInsecure = $General.VarBool1 -eq $true

    $pem = Invoke-AlteonApi GET "https://$alteon/config/getcert?id=$([Uri]::EscapeDataString($certName))&src=txt&type=srvcrt"
    if ($pem -notmatch 'BEGIN CERTIFICATE') { throw "Certificate '$certName' was not found on Alteon" }

    return @{ Result="Success"; CertPem=$pem; }
}


<######################################################################################################################
.NAME
    Extract-PrivateKey
.DESCRIPTION
    Extracts the private key associated with the certificate from the hosting platform
######################################################################################################################>
function Extract-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Remove-Certificate
.DESCRIPTION
    Removes an existing certificate (or private key) from the device.
######################################################################################################################>
function Remove-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="NotUsed"; }
}


<###################### THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ######################>
function Invoke-AlteonApi {
    param(
        [Parameter(Mandatory=$true)][ValidateSet('GET','POST','PUT','DELETE')][string]$Method,
        [Parameter(Mandatory=$true)][string]$Url,
        [string]$Body,
        [string]$ContentType = 'application/json;charset=UTF-8'
    )

    $hasBody = $PSBoundParameters.ContainsKey('Body')
    $bodyFile = $null
    $lastError = ''

    if ( $DEBUG_FILE ) {
        # Copy-paste form for Windows PowerShell 5.1 (\" escaping); password and private key are never logged.
        $cmd = "curl.exe$(if ($trustInsecure) { ' -k' }) -sS -u '$username' -X $Method -H 'Accept: application/json'"
        if ($hasBody) {
            $data = if ($Body -match 'PRIVATE KEY') { '@privkey.pem' } else { $Body -replace '"','\"' }
            $cmd += " -H 'Content-Type: $ContentType' --data-binary '$data'"
        }
        "$cmd '$Url'" | Write-VenafiDebug
    }

    try {
        if ($hasBody) {
            $bodyFile = [IO.Path]::GetTempFileName()
            [IO.File]::WriteAllText($bodyFile,$Body,(New-Object System.Text.UTF8Encoding))
        }

        for ($attempt=1; $attempt -le 3; $attempt++) {
            $args = @('-sS','--fail-with-body')
            if ($trustInsecure) { $args += '-k' }

            $args += @(
                '-u',"$username`:$password",
                '-X',$Method,
                '-H','Accept: application/json'
            )

            if ($hasBody) {
                $args += @('-H',"Content-Type: $ContentType",'--data-binary',"@$bodyFile")
            }

            $r = & curl.exe @args $Url 2>&1
            if ($LASTEXITCODE -eq 0) {
                if ( $DEBUG_FILE -and $Method -ne 'GET' ) { "Response: $r" | Write-VenafiDebug }
                return ($r -join "`n")
            }

            $lastError = $r -join "`n"
            if ( $DEBUG_FILE ) { "REST $Method failed - attempt $attempt of 3: $lastError" | Write-VenafiDebug }
            if ($attempt -lt 3) { Start-Sleep 10 }
        }

        throw "REST $Method failed after 3 attempts: $Url`n$lastError"
    }
    finally {
        if ($bodyFile -and (Test-Path $bodyFile)) {
            Remove-Item $bodyFile -Force -ErrorAction SilentlyContinue
        }
    }
}

function Get-AlteonProperty([string]$Name) {
    $v = (Invoke-AlteonApi GET "https://$alteon/config?prop=$Name" | ConvertFrom-Json).$Name
    if ( $DEBUG_FILE ) { "$Name is: $v" | Write-VenafiDebug }
    $v
}

function Get-Fingerprint([string]$Pem) {
    $b64 = $Pem -replace '-----BEGIN CERTIFICATE-----','' -replace '-----END CERTIFICATE-----','' -replace '\s',''
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        (($sha.ComputeHash([Convert]::FromBase64String($b64)) | ForEach-Object { $_.ToString('X2') }) -join '')
    }
    finally { $sha.Dispose() }
}

function Get-X509([string]$Pem) {
    $b64 = $Pem -replace '-----BEGIN CERTIFICATE-----','' -replace '-----END CERTIFICATE-----','' -replace '\s',''
    New-Object Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,[Convert]::FromBase64String($b64))
}

function Get-IntermediateCertificates([string]$ChainPem) {
    $out = @()
    $certs = [regex]::Matches($ChainPem,'(?s)-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----')
    foreach ($m in $certs) {
        $pem = $m.Value
        $x = Get-X509 $pem
        # A lone cert is used as the intermediate even if self-signed.
        if ($certs.Count -gt 1 -and $x.Subject -eq $x.Issuer) { continue }

        $fp = Get-Fingerprint $pem
        $out += [pscustomobject]@{
            Name       = "vca_$($fp.Substring(0,28))"
            Pem        = $pem
            Fingerprint= $fp
            CommonName = $x.GetNameInfo([Security.Cryptography.X509Certificates.X509NameType]::SimpleName,$false)
        }
    }
    $out
}

function Get-GroupName($Certificates) {
    $text = (@($Certificates | ForEach-Object { $_.Fingerprint } | Sort-Object) -join '|')
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $h = (($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($text)) | ForEach-Object { $_.ToString('X2') }) -join '')
        "vgrp_$($h.Substring(0,27))"
    }
    finally { $sha.Dispose() }
}

function Get-CertificateRows {
    $r = Invoke-AlteonApi GET "https://$alteon/config/SlbNewSslCfgCertsTable?count=3000&props=ID,Type,CommonName,IntermcaChainType,IntermcaChainName" | ConvertFrom-Json
    @($r.SlbNewSslCfgCertsTable)
}

function Get-GroupRows {
    $r = Invoke-AlteonApi GET "https://$alteon/config/SlbNewSslCfgGroupsTable?count=1024&props=ID,Type,CertBmap" | ConvertFrom-Json
    @($r.SlbNewSslCfgGroupsTable)
}

function Get-BmapSlots([string]$Bmap) {
    $bytes = @($Bmap.Split(':') | Where-Object { $_ } | ForEach-Object { [Convert]::ToByte($_,16) })
    for ($i=0; $i -lt $bytes.Count; $i++) {
        if ($bytes[$i]) { 0..7 | Where-Object { $bytes[$i] -band (0x80 -shr $_) } | ForEach-Object { $i*8 + $_ } }
    }
}

# CertBmap bit order != API row order: learn each CA's slot via a throw-away group, then revert (drops unapplied changes).
function Get-CaSlots([string[]]$CaNames) {
    if ([int](Get-AlteonProperty 'agApplyPending') -eq 2) { throw 'Unapplied changes pending - cannot probe CA slots' }

    $probe = 'zz_slotprobe'
    $url = "https://$alteon/config/SlbNewSslCfgGroupsTable/$probe/"
    $slots = @{}

    try {
        Invoke-AlteonApi POST $url -Body (@{Type=5} | ConvertTo-Json -Compress) | Out-Null
        foreach ($n in $CaNames) {
            Invoke-AlteonApi PUT $url -Body (@{AddCert=$n} | ConvertTo-Json -Compress) | Out-Null
            $s = @(Get-BmapSlots (Get-GroupRows | Where-Object { $_.ID -eq $probe }).CertBmap)
            if ($s.Count -ne 1) { throw "Cannot resolve CA slot: $n" }
            $slots[$n] = $s[0]
            Invoke-AlteonApi PUT $url -Body (@{RemCert=$n} | ConvertTo-Json -Compress) | Out-Null
        }
    }
    finally { Invoke-AlteonApi POST "https://$alteon/config?action=revert" | Out-Null }

    $slots
}

function Invoke-AlteonApplySaveSync {
    if ([int](Get-AlteonProperty 'agApplyPending') -eq 2) {
        if ( $DEBUG_FILE ) { "Applying configuration" | Write-VenafiDebug }
        Invoke-AlteonApi POST "https://$alteon/config?action=apply" | Out-Null

        for ($i=0;$i -lt 30;$i++) {
            $s=[int](Get-AlteonProperty 'agApplyConfig')
            if ($s -eq 5) { throw 'Apply failed' }
            if ($s -in 4,6) { break }
            Start-Sleep 2
        }
    }

    if ([int](Get-AlteonProperty 'agSavePending') -eq 1) {
        if ( $DEBUG_FILE ) { "Saving configuration" | Write-VenafiDebug }
        Invoke-AlteonApi POST "https://$alteon/config?action=save" | Out-Null

        for ($i=0;$i -lt 30;$i++) {
            $s=[int](Get-AlteonProperty 'agSaveConfig')
            if ($s -eq 5) { throw 'Save failed' }
            if ($s -eq 4) { break }
            Start-Sleep 2
        }
    }

    try {
        $m = Invoke-AlteonApi GET "https://$alteon/monitor?prop=agSyncNeeded,vrrpInfoHAState" | ConvertFrom-Json
        if ([int]$m.agSyncNeeded -ne 1 -or [string]$m.vrrpInfoHAState -notmatch '(?i)master') { return }

        if ( $DEBUG_FILE ) { "Synchronizing configuration" | Write-VenafiDebug }
        Invoke-AlteonApi PUT "https://$alteon/config?action=sync" | Out-Null

        for ($i=0;$i -lt 30;$i++) {
            $s=[int](Get-AlteonProperty 'agSyncStatus')
            if ($s -eq 3) { throw 'Sync failed' }
            if ($s -eq 2) { break }
            Start-Sleep 2
        }
    }
    catch {
        if ( $DEBUG_FILE ) { "Sync skipped: $_" | Write-VenafiDebug }
    }
}