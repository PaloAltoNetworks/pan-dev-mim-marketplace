<#
//----------------------------------------------------------------------- 
// WisekeyUra.ps1
//
// Copyright (c) 2022 Venafi, Inc. All rights reserved.

// This software is licensed by WISeKey, in addition to Venafi. 
// Additional license terms may apply. The software and its contents are provided by 
// Venafi to customers for the purposes of integrating with services and platforms. 
// Modification of this script is only allowed to update any necessary configuration details. 
// Any sharing of the software outside your organization without consent from Venafi is strictly prohibited. 
// Without limiting the foregoing, the above copyright notice, this paragraph and the following paragraph 
// must appear in all copies, modifications, reproductions, and distributions of this software. 

// IN NO EVENT SHALL VENAFI, INC., ITS DIRECTORS, OFFICERS, EMPLOYEES, AGENTS, OR AFFILIATES BE 
// LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, 
// INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE OR ITS DOCUMENTATION, IF ANY, 
// EVEN IF VENAFI, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. VENAFI, INC. 
// SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES 
// OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. THIS SOFTWARE, ALONG WITH ITS DOCUMENTATION, 
// IF ANY, IS PROVIDED "AS IS". VENAFI, INC. HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, 
// OR UPDATES FOR THE SOFTWARE OR ITS DOCUMENTATION, IF ANY.
//----------------------------------------------------------------------- 
#>

# Note: Starting in 20.1 consider passing the following in $General.ServiceAddress and $General.ProfileString
$global:app_host = "https://trustcenter.certifyiddemo.com/ura/api/v1/"
$global:userId = 1095
$global:templateId = 1042

$base_path = (Get-Location).Path
if ( (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" )
{
    $base_path = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Scripts"
}

$global:temp_dir = $base_path + "\Temp"
If ( !(Test-Path $global:temp_dir) )
{
   New-Item $global:temp_dir -Type Directory
}

$global:issued_cert = $base_path + "\CertsData"
If ( !(Test-Path $global:issued_cert) )
{
   New-Item $global:issued_cert -Type Directory
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


<##################################################################################################
.NAME
    Test-Settings
.DESCRIPTION
    Verifies the ability to connect to and authenticate with the URA using the supplied credentials
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserName : the username for authenticating with the URA
        UserPass : the password for authenticating with the URA
        PfxData : a PKCS#12 containing client certificate and private key for authenticating with the URA
        PfxPass : the password for access to the private key in the PKCS#12
        AuxUser : a username paired with AuxPass for secondary authentication purposes
        AuxPass : the password for the AuxUser (username credential), AuxPfxData (certificate credential), or independent (password credential)
        AuxPfxData : a PKCS#12 containing client certificate and private key for secondary authentication purposes
        CertObjDN : the Venafi distinguished name of the certificate object in the policy tree
        CustomFields : hashtable of Custom Fields; keys are field labels and values are strings (single valued) or string arrays (multi-valued)
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Test-Settings
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    try
    {
        # Get and check client certificate
        $cert = Get-AuthCert $General.PfxData $General.PfxPass
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }

        # Call API check connection
        $url = "{0}/authentication" -f $global:app_host
        $headers = Make-Request-Header $General.UserName
        $testResult = Invoke-RestMethod -Uri $url -Method "GET" -Headers $headers -Certificate $cert

        # Check result return
        if ($testResult){
            if ($testResult.code){
                if ($testResult.code -eq 200){
                    return @{ Result="Success" }
                }
            }
        }

        throw
    }
    catch
    {
        $respCode = Parse-Error-Code($_)
        $respContent = Parse-Error-Message($_)
        Out-Log-String -ht_str ("" + $respCode + " - " + $respContent)

        throw "Failed to connect/authenticate with API endpoint. errorCode={0}; errorMessage={1}" -f $respCode,$respContent
    }
}


<##################################################################################################
.NAME
    Get-ChainCertificates
.DESCRIPTION
    Retrieves the chain of URA certificates applicable to certificates issued by the URA
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs7 : a collection that includes all of the URA certificates in the issuing chain
##################################################################################################>
function Get-ChainCertificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed" }
}


<##################################################################################################
.NAME
    Prepare-ForRequest
.DESCRIPTION
    Performs any tasks that are necessary to prior to submitting a certificate signing request to the URA
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        SubjectDN : the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames : hashtable keyed by SAN type; values are string arrays
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Prepare-ForRequest
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="NotUsed" }
}


<##################################################################################################
.NAME
    Submit-CsrAsNew
.DESCRIPTION
    Submits a CSR to URA for enrollment as a new, first time certificate
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        Pkcs10 : the Base64-encoded PKCS#10 formatted certificate signing request to be enrolled
        SubjectDN : the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames : hashtable keyed by SAN type; values are string arrays
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' to indicate the non-error completion state; this function is required
        TransId : the identifier used to subsequently approve and/or retrieve the certificate request from the URA
        Pkcs7 : a collection that includes the issued certificate and optionally includes all of the URA certificates in the chain
        Pkcs12 : a collection that includes the issued certificate, its private key, and optionally all of the URA certificates in the chain
        PrivKeyPem : an OpenSSL or PKCS#8 private key in PEM format
        EncryptPass : the password used to encrypt the private key or PKCS#12
##################################################################################################>
function Submit-CsrAsNew
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    try
    {
        #### Get and check client certificate ####
        $cert = Get-AuthCert $General.PfxData $General.PfxPass
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }

        #### Prepare parameter ####
        $url = "{0}/request/submit" -f $global:app_host

        $headers = Make-Request-Header $General.UserName
        $body = Build-Request-Body $General $Specific
		
        $strBody = $body | ConvertTo-Json -Compress

        #### Call service and check result ####
        $result = Invoke-RestMethod -Uri $url -Method "POST" -Headers $headers -Body $strBody -Certificate $cert
        if ($result){
            if ($result.requestid){
                return @{ Result="Success"; TransId = $result.requestid.ToString(); }
            }
        }

        throw
    }
    catch
    {
        $respCode = Parse-Error-Code($_)
        $respContent = Parse-Error-Message($_)
        Out-Log-String -ht_str ("" + $respCode + " - " + $respContent)

        throw "Failed to submit certificate request. errorCode={0}; errorMessage={1}" -f $respCode,$respContent
    }
}

<##################################################################################################
.NAME
    Submit-CsrAsRenewal
.DESCRIPTION
    Submits a CSR to a URA for enrollment as a renewal of an existing certificate
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function (see Submit-CsrAsNew plus the following)
        CertId : a integer that the URA can use to uniquely identify the certificate request being renewed
        CertPem : the raw, Base64-encoded X509 certificate to be renewed
.NOTES
    Returns a hashtable that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsRenewal
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return Submit-CsrAsNew -general $General -specific $Specific
}

<##################################################################################################
.NAME
    Submit-CsrAsReplacement
.DESCRIPTION
    Submits a CSR to a URA for enrollment as a replacement for an existing certificate
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function (see Submit-CsrAsNew plus the following)
        CertId : a integer that the URA can use to uniquely identify the certificate request being replaced
        CertPem : the raw, Base64-encoded X509 certificate to be replaced
.NOTES
    Returns a hashtable that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsReplacement
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return Submit-CsrAsNew -general $General -specific $Specific
}

<##################################################################################################
.NAME
    Approve-Request
.DESCRIPTION
    Approves a previously submitted CSR
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        TransId : a integer that uniquely identifies the certificate request submitted to the URA
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Approve-Request
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    try
    {
        #### Get and check client certificate ####
        $cert = Get-AuthCert $General.PfxData $General.PfxPass
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }

        if (!$Specific.TransId) {
            throw "A request id is required for the approved request."
        }

        #### Prepare parameter ####
        $url = "{0}/request/approve"
        $url = $url -f $global:app_host

        $body = @{
            requestId = $Specific.TransId
        }
        $string_body = $body | ConvertTo-Json -Compress

        $headers = Make-Request-Header $General.UserName

        #### Call service and check result ####
        $result = Invoke-RestMethod -Uri $url -Method "POST" -Headers $headers -Certificate $cert -Body $string_body

        if ($result){
            if ($result.certificateid){
                return @{ Result= "Success" }
            }
        }

        throw
    }
    catch
    {
        $respCode = Parse-Error-Code($_)
        $respContent = Parse-Error-Message($_)
        Out-Log-String -ht_str ("" + $respCode + " - " + $respContent)

        throw "Failed to approve certificate request. errorCode={0}; errorMessage={1}" -f $respCode,$respContent
    }

}


<##################################################################################################
.NAME
    Retrieve-Certificate
.DESCRIPTION
    Retrieves a signed certificate from the URA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId : a integer that uniquely identifies the certificate request issued by the URA
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Status: 'Pending' or 'Issued' to indicate whether the certificate has been issued by the URA
        Pkcs7: a collection that includes the issued certificate and (optionally) all of the URA certificates in the chain
        DiscardPrivateKeyAndCsr : boolean that when $true tells the driver to discard stored assets that will not match the certificate being returned
##################################################################################################>
function Retrieve-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    try
    {

        #### Get and check client certificate ####
        $cert = Get-AuthCert $General.PfxData $General.PfxPass
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }

        if (!$Specific.CertId) {
            throw "A Certificate ID is required for the retrieve certificate."
        }

        #### Prepare parameter ####
        $url = "{0}/certificate/getbyrequest?requestid=" + $Specific.CertId
        $url = $url -f $global:app_host

        $headers = Make-Request-Header $General.UserName

        #### Call service and check result ####
        $result = Invoke-RestMethod -Uri $url -Method "GET" -Headers $headers -Certificate $cert

        if ($result){
            if ($result.certificateid){
                if ($result.certificate){
                    $certs = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
                    $certResult = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                    $certResult.Import([Convert]::FromBase64String($result.certificate))
                    $certs.Add($certResult) | Out-Null
                    $bytes = $certs.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
                    return @{ Result="Success"; Status = "Issued"; Pkcs7= $bytes; }
                }
            }
        }

        throw
    }
    catch
    {
        $respCode = Parse-Error-Code($_)
        $respContent = Parse-Error-Message($_)
        Out-Log-String -ht_str ("" + $respCode + " - " + $respContent)

        throw "Failed to retrieve certificate. errorCode={0}; errorMessage={1}" -f $respCode,$respContent
    }
}


<##################################################################################################
.NAME
    Revoke-Certificate
.DESCRIPTION
    Revokes a certificate issued by the URA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId: a integer that uniquely identifies the certificate request issued by the URA
        CertPem: the raw, Base64-encoded X509 certificate to be revoked
        ReasonCode : 1 (User Key Compromised), 2 (CA Key Compromised), 3 (User Changed Affiliation), 4 (Certificate Superseded), 5 (Original Use No Longer Valid)
        Comment: a comment provided by the revocation requester
.NOTES
    Returns a hashtable that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Revoke-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    try
    {
        #### Get and check client certificate ####
        $cert = Get-AuthCert $General.PfxData $General.PfxPass
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }
        if (!$Specific.CertId) {
            throw "A Certificate ID is required for revoking the certificate."
        }

        if (!$Specific.ReasonCode) {
            throw "A reason code is required for revoking the certificate."
        }

        if (!$Specific.Comment) {
            $Specific.Comment = "no comment provided"
        }

        #### Prepare parameter ####
        $url = "{0}/certificate/getbyrequest?requestid=" + $Specific.CertId
        $url = $url -f $global:app_host

        $headers = Make-Request-Header $General.UserName

        #### Call service and check result ####
        $result = Invoke-RestMethod -Uri $url -Method "GET" -Headers $headers -Certificate $cert

        if ($result){
            if ($result.certificateid){
               $Specific.CertId = $result.certificateid
            }
        }

        #### Prepare parameter ####
        $url = "{0}/certificate/revoke" -f $global:app_host

        $headers = Make-Request-Header $General.UserName
        $body = @{
            certificateId = $Specific.CertId
            revocationReasonId = $Specific.ReasonCode
            revocationComment = $Specific.Comment
        }
        $string_body = $body | ConvertTo-Json -Compress

        #### Call service and check result ####
        $result = Invoke-RestMethod -Uri $url -Method "POST" -Headers $headers -Body $string_body -Certificate $cert

        if ($result){
            if ($result.code -eq 200){
                return @{ Result = 'Success' }
            }
        }

        throw
    }
    catch
    {
        $respCode = Parse-Error-Code($_)
        $respContent = Parse-Error-Message($_)
        Out-Log-String -ht_str ("" + $respCode + " - " + $respContent)

        throw "Failed to revoke certificate. errorCode={0}; errorMessage={1}" -f $respCode,$respContent
    }

}


<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Get-AuthCert( [byte[]] $pkcs12, [System.Security.SecureString] $passwd )
{
    if ( $pkcs12 -ne $null )
    {
        return New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pkcs12, $passwd)
    }
    else
    {
        throw "A client certificate credential is required."
    }
}

function Make-Request-Header ($appId){
    return @{
        "Accept"="application/json"
        "Content-Type"="application/json; charset=utf-8"
        "X-App-ID"= $appId
    }
}


function Build-Request-Body( $General, $Specific )
{
    $csr = $Specific.Pkcs10

    $CN = ''
    if ( $Specific.SubjectDN.CN )
    {
        $CN = $Specific.SubjectDN.CN
    }

    $O = ''
    if ( $Specific.SubjectDN.O )
    {
        $O = $Specific.SubjectDN.O
    }

    $C = ''
    if ( $Specific.SubjectDN.C )
    {
        $C = $Specific.SubjectDN.C
    }

    $OU = ''
    if ($Specific.SubjectDN.OU -gt 0){
        foreach ($element in $Specific.SubjectDN.OU) {
            $OU = $element
            break;
        }
    }

    $ST = ''
    if ( $Specific.SubjectDN.ST )
    {
        $ST = $Specific.SubjectDN.ST
    }

    $L = ''
    if ( $Specific.SubjectDN.L )
    {
        $L = $Specific.SubjectDN.L
    }

    $sans = @()
    if ($Specific.SubjAltNames.DNS -gt 0){
        foreach ($element in $Specific.SubjAltNames.DNS) {
            $sans = $sans + $element
        }
    }

    $validity = "1"
    if ( $General.CustomFields.'Validity Period' )
    {
        $validity = $General.CustomFields.'Validity Period'
    }

    $body = @{
        csr = $csr
        subject = @{
            "2.5.4.3" = $CN		#Common Name
            "2.5.4.11" = $OU   	#Organizational Unit
            "2.5.4.10" = $O		#Organization
            "2.5.4.7" = $L		#Locality
            "2.5.4.8" = $ST		#State Or Province
            "2.5.4.6" = $C		#Country
        }
        san = @{ dns =  $sans }
        userId = $global:userId
        templateId = $global:templateId
        validity_period = $validity
    }

    return $body
}


function Parse-Error-Code($Error) {
    $result = -1
    try
    {
        if ($Error.Exception.Response){
            $result = $Error.Exception.Response.StatusCode
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                if ($Error.Exception.Response) {
                    $Reader = New-Object System.IO.StreamReader($Error.Exception.Response.GetResponseStream())
                    $Reader.BaseStream.Position = 0
                    $Reader.DiscardBufferedData()
                    $ResponseBody = $Reader.ReadToEnd()
                    if ($ResponseBody.StartsWith('{')) {
                        $ResponseBody = $ResponseBody | ConvertFrom-Json
                    }
                    return $ResponseBody
                    if ($ResponseBody.error_code){
                        $result = $ResponseBody.error_code
                    }
                    error_code
                }
            }
            else {
                return $Error.ErrorDetails.Message
            }
        }
    }
    catch
    {

    }
    return $result
}

function Parse-Error-Message($Error) {
    $result = $Error.Exception.Message
    try
    {
        if ($Error.Exception.Response){
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                if ($Error.Exception.Response) {
                    $Reader = New-Object System.IO.StreamReader($Error.Exception.Response.GetResponseStream())
                    $Reader.BaseStream.Position = 0
                    $Reader.DiscardBufferedData()
                    $ResponseBody = $Reader.ReadToEnd()
                    if ($ResponseBody.StartsWith('{')) {
                        $ResponseBody = $ResponseBody | ConvertFrom-Json
                    }
                    if ($ResponseBody.message){
                        $result = $ResponseBody.message
                    }
                }
            }
            else {
                return $Error.ErrorDetails.Message
            }
        }
    }
    catch
    {

    }
    return $result
}


function Out-Log ( $nm_func, $ht_gen, $ht_spec )
{
    if ( $DEBUG_FILE )
    {
        $buf = "[{0}] {1}" -f $nm_func,$("."*(100-$nm_func.Length))

        $buf += "`n`n##### GENERAL PARAMETERS #####`n "
        $buf += ($ht_gen.GetEnumerator() | sort Name | % { Show-Vars $_.Name $_.Value })

        if ( $ht_spec.Count -gt 0 )
        {
            $buf += "`n`n##### FUNCTION SPECIFIC PARAMETERS #####`n "
            $buf += ($ht_spec.GetEnumerator() | sort Name | % { Show-Vars $_.Name $_.Value })
        }

        $buf | Out-File $DEBUG_FILE -Append
    }
}


function Show-Vars ( $name, $value )
{
    $result = "_____ $name _____`r`n"

    if ( $value.GetType().Name -eq "Hashtable" )
    {
        $maxlen = 0

        For ( $i=0; $i -lt $value.Keys.Count; $i++ )
        {
            if ( $($value.Keys)[$i].Length -gt $maxlen )
            {
                $maxlen = $($value.Keys)[$i].Length
            }
        }

        ForEach ( $key in $value.Keys )
        {
            if ( $($value.Item($key)).GetType().BaseType.Name -eq "Array" )
            {
                if ( $value.Item($key).Count -le 24 )
                {
                    $result += $($key + ":").PadRight($maxlen + 4," ") + "{" + ($value.Item($key) -join ", ") + "}`r`n"
                }
                else
                {
                    $result += $($key + ":").PadRight($maxlen + 4," ") + "{" + ($value.Item($key)[0..23] -join ", ") + ", ...}`r`n"
                }
            }
            else
            {
                $result += $($key + ":").PadRight($maxlen + 4," ") + $value.Item($key) + "`r`n"
            }
        }
    }
    elseif ( $value.GetType().BaseType.Name -eq "Array" )
    {
        if ( $value.Count -le 24 )
        {
            $result += "{" + ($value -join ", ") + "}`r`n"
        }
        else
        {
            $result += "{" + ($value[0..23] -join ", ") + ", ...}`r`n"
        }
    }
    elseif ( $value.GetType().Name -eq "SecureString" )
    {
        $result += "".PadRight($value.Length,"*") + "`r`n"
    }
    else
    {
        $result += $value + "`r`n"
    }

    return $result
}


function Out-Log-String ( $ht_str )
{
    if ( $DEBUG_FILE )
    {
        $buf = ""
        $buf += "`n`n##### Log String #####`n`n "
        $buf += "" + $ht_str + "`n`n "

        $buf | Out-File $DEBUG_FILE -Append
    }
}