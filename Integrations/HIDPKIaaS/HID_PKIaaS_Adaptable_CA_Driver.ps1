<#
//---------------------------------------------------------------------------
// HID_PKIaaS_Adaptable_CA_Driver.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2022 Venafi, Inc. All rights reserved.
//
// This software is licensed by HydrantID, in addition to Venafi.
// Additional license terms may apply. The software and its contents are
// provided by Venafi to customers for the purposes of integrating with
// services and platforms. Modification of this script is only allowed to
// update any necessary configuration details. Any sharing of the software
// outside your organization without consent from Venafi is strictly
// prohibited. Without limiting the foregoing, the above copyright notice,
// this paragraph and the following paragraph must appear in all copies,
// modifications, reproductions, and distributions of this software.
//
// IN NO EVENT SHALL VENAFI, INC., ITS DIRECTORS, OFFICERS, EMPLOYEES,
// AGENTS, OR AFFILIATES BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
// SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS,
// ARISING OUT OF THE USE OF THIS SOFTWARE OR ITS DOCUMENTATION, IF ANY,
// EVEN IF VENAFI, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
// VENAFI, INC. SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A
// PARTICULAR PURPOSE. THIS SOFTWARE, ALONG WITH ITS DOCUMENTATION, IF ANY,
// IS PROVIDED "AS IS". VENAFI, INC. HAS NO OBLIGATION TO PROVIDE
// MAINTENANCE, SUPPORT, OR UPDATES FOR THE SOFTWARE OR ITS DOCUMENTATION,
// IF ANY.
//---------------------------------------------------------------------------
#>

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$global:issueRetry = 5
$global:issueWait = 500

$global:customValidityFieldDays = "HydrantID ACM: Validity Days"
$global:customValidityFieldMonths = "HydrantID ACM: Validity Months"
$global:customValidityFieldYears = "HydrantID ACM: Validity Years"

$global:customAEPApplicationPolicies = "AEP: Application Policies"
$global:customAEPCertificateTemplate = "AEP: Certificate Template"

<##################################################################################################
.NAME
    Test-Settings
.DESCRIPTION
    Verifies that Trust Protection Platform can authenticate with the CA using the supplied credentials.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserName: the username required to authenticate with the CA
        UserPass: the password required to authenticate with the CA
        PfxData: a PKCS#12 containing a client certificate and private key required to authenticate with the CA
        PfxPass: the password required to access the private key in the PKCS#12
        CertObjDN : the Venafi distinguished name of the certificate object in the policy tree
        CustomFields : the hash table of Custom Fields. Keys are field labels and values are either strings (single valued) or string arrays (multi-valued).
        ServiceAddress:
        ProfileString:
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Test-Settings {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    try {
        # look up the policy
        $Parameters = @{
            Method      = "GET"
            Uri         = $General.ServiceAddress + "/api/v2/policies/" + $General.ProfileString
            ContentType = "application/json"
            HawkID      = $General.UserName
            HawkKey     = $General.UserPass
        }
        $policy = Invoke-RestMethodWithHawk @Parameters
        Write-DebugLog "Test-Settings Result = $($policy | ConvertTo-Json -Depth 5)"

        # make sure the policy is found and has the appropriate id
        if (($null -ne $policy.id) -and ($General.ProfileString -eq $policy.id)) {
            return @{ Result = "Success" }
        }
        throw "No policy for: " + $General.ProfileString + "!"
    }
    catch {
        Write-DebugLog($_ | ConvertTo-Json -Depth 2)
        throw Format-Error($_.Exception)
    }
}


<##################################################################################################
.NAME
    Get-ChainCertificates
.DESCRIPTION
    Retrieves the chain of CA certificates that are applicable to certificates issued by the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.NOTES
    Returns a hashtable that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs7: a collection that includes all of the CA certificates in the issuing chain
##################################################################################################>
function Get-ChainCertificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    return @{ Result = "NotUsed" }
}


<##################################################################################################
.NAME
    Prepare-ForRequest
.DESCRIPTION
    Performs any tasks that are necessary to prior to submitting a certificate signing request to the CA
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
function Prepare-ForRequest {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    return @{ Result = "NotUsed" }
}


<##################################################################################################
.NAME
    Submit-CsrAsNew
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a new, first time certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        Pkcs10: the Base64-encoded PKCS#10-formatted certificate signing request (CSR) to be enrolled
        SubjectDN: the requested subject distiguished name as a hash table. OU is a string array and all others are strings.
        SubjAltNames: hash table keyed by SAN type. Values are string arrays.
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' to indicate the non-error completion state. NOTE: this function is required.
        TransId: the identifier used to subsequently approve and/or retrieve the certificate from the CA
        Pkcs7: a collection that includes the issued certificate and (optionally) includes all of the CA certificates in the chain
##################################################################################################>
function Submit-CsrAsNew {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    try {
        $spec = $Specific | ConvertTo-Json
        Write-DebugLog "Specific = $spec"

        $customExtensions = Initialize-CustomExtensions -Policy $General.ProfileString -Csr $Specific.Pkcs10

        # form request
        $request = @{
            policy           = $General.ProfileString
            csr              = $Specific.Pkcs10
            dnComponents     = @{
                CN = $Specific.SubjectDN.CN
            }
            subjectAltNames  = @{}
            customExtensions = $customExtensions
        }

        if ($Specific.SubjectDN.OU.Count -gt 0) {
            # if there is only 1 element, make sure it's put in as an array
            if ($Specific.SubjectDN.OU.Count -eq 1) {
                $request.dnComponents.OU = @($Specific.SubjectDN.OU)
            }
            else {
                $request.dnComponents.OU = $Specific.SubjectDN.OU
            }
        }
        if ($Specific.SubjectDN.O) {
            $request.dnComponents.Add("O", $Specific.SubjectDN.O)
        }
        if ($Specific.SubjectDN.L) {
            $request.dnComponents.Add("L", $Specific.SubjectDN.L)
        }
        if ($Specific.SubjectDN.ST) {
            $request.dnComponents.Add("ST", $Specific.SubjectDN.ST)
        }
        if ($Specific.SubjectDN.C) {
            $request.dnComponents.Add("C", $Specific.SubjectDN.C)
        }

        if ($Specific.SubjAltNames.DNS.Count -gt 0) {
            $request.subjectAltNames.Add("DNSNAME", $Specific.SubjAltNames.DNS)
        }
        if ($Specific.SubjAltNames.IP.Count -gt 0) {
            $request.subjectAltNames.Add("IPADDRESS", $Specific.SubjAltNames.IP)
        }
        if ($Specific.SubjAltNames.Email.Count -gt 0) {
            $request.subjectAltNames.Add("RFC822NAME", $Specific.SubjAltNames.Email)
        }
        if ($Specific.SubjAltNames.UPN.Count -gt 0) {
            $request.subjectAltNames.Add("UPN", $Specific.SubjAltNames.UPN)
        }

        $validityDays = $General.CustomFields[$global:customValidityFieldDays];
        $validityMonths = $General.CustomFields[$global:customValidityFieldMonths];
        $validityYears = $General.CustomFields[$global:customValidityFieldYears];
        $validity = @{}
        if ($validityDays) {
            if ($validityDays -is [array]) {
                $validity.add("days", [int]$validityDays[0])
            }
            else {
                $validity.add("days", [int]$validityDays)
            }
        }
        if ($validityMonths) {
            if ($validityMonths -is [array]) {
                $validity.add("months", [int]$validityMonths[0])
            }
            else {
                $validity.add("months", [int]$validityMonths)
            }
        }
        if ($validityYears) {
            if ($validityYears -is [array]) {
                $validity.add("years", [int]$validityYears[0])
            }
            else {
                $validity.add("years", [int]$validityYears)
            }
        }
        if ($validityDays -or $validityMonths -or $validityYears) {
            $request.Add("validity", $validity);
        }

        $aepApplicationPolicies = $General.CustomFields[$global:customAEPApplicationPolicies]
        if ($aepApplicationPolicies) {
            if ($aepApplicationPolicies -is [array]) {
                $request.customExtensions["1.3.6.1.4.1.311.21.10"] = $aepApplicationPolicies[0]
            }
            else {
                $request.customExtensions["1.3.6.1.4.1.311.21.10"] = $aepApplicationPolicies
            }
        }

        $aepCertificateTemplate = $General.CustomFields[$global:customAEPCertificateTemplate]
        if ($aepCertificateTemplate) {
            if ($aepCertificateTemplate -is [array]) {
                $request.customExtensions["1.3.6.1.4.1.311.21.7"] = $aepCertificateTemplate[0]
            }
            else {
                $request.customExtensions["1.3.6.1.4.1.311.21.7"] = $aepCertificateTemplate
            }
        }			
    
        $body = $request | ConvertTo-Json -Depth 5

        Write-DebugLog "Body = $body"

        $requestParameters = @{
            Method  = "POST"
            Uri     = $General.ServiceAddress + "/api/v2/csr"
            HawkID  = $General.UserName
            HawkKey = $General.UserPass
            Body    = $body
        }
        $csrResult = Invoke-RestMethodWithHawk @requestParameters
        Write-DebugLog "CSR Result = $($csrResult | ConvertTo-Json -Depth 5)"

        $result = @{
            Result  = "Success"
            TransId = $csrResult.id
        }
        if ($global:issueRetry -gt 0) {
            $retrieveCert = @{}
            for ($try = 0; $try -lt $global:issueRetry; $try++) {
                Start-Sleep -Milliseconds $global:issueWait
                $Specific.CertId = $csrResult.id
                $retrieveCert = Retrieve-Certificate $General $Specific
                if (($retrieveCert.Result -eq "Success") -and ($retrieveCert.Status -eq "Issued")) {
                    $result.Result = "Success"
                    $result.TransId = $csrResult.id
                    $result.PKCS7 = $retrieveCert.PKCS7
                    break
                }
            }
        }
        return $result
    }
    catch {
        Write-DebugLog($_ | ConvertTo-Json -Depth 2)
        throw Format-Error($_.Exception)
    }
}


<##################################################################################################
.NAME
    Submit-CsrAsRenewal
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a renewal of an existing certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
        CertId : a string that uniquely identifies the certificate issued by the CA to be renewed
        CertPem : the raw, Base64-encoded X509 certificate to be renewed
.NOTES
    Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsRenewal {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    return Submit-CsrAsNew $General $Specific
}

<##################################################################################################
.NAME
    Submit-CsrAsReplacement
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a replacement for an existing certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
        CertId : a string that uniquely identifies the certificate issued by the CA to be replaced
        CertPem : the raw, Base64-encoded X509 certificate to be replaced
.NOTES
    Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsReplacement {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    return Submit-CsrAsNew $General $Specific
}


<##################################################################################################
.NAME
    Approve-Request
.DESCRIPTION
    Approves a previously submitted CSR
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        TransId : a string that uniquely identifies the certificate request submitted to the CA
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Approve-Request {
    return @{ Result = "NotUsed" }
}

<##################################################################################################
.NAME
    Retrieve-Certificate
.DESCRIPTION
    Retrieves a signed certificate from the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId : a string that uniquely identifies the certificate issued by the CA
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Status: 'Pending' or 'Issued' to indicate whether the certificate has been issued by the CA
        Pkcs7: a collection that includes the issued certificate and (optionally) all of the CA certificates in the chain
        DiscardPrivateKeyAndCsr : boolean that when $true tells the driver to discard stored assets that will not match the certificate being returned
##################################################################################################>
function Retrieve-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $certRequestId = $Specific.CertId

    try {
        # look up the certRequest status
        $Parameters = @{
            Method  = "GET"
            Uri     = $General.ServiceAddress + "/api/v2/csr/" + $certRequestId + "/status"
            HawkID  = $General.UserName
            HawkKey = $General.UserPass
        }
        $csrStatus = Invoke-RestMethodWithHawk @Parameters
        Write-DebugLog "CSR Status = $($csrStatus | ConvertTo-Json -Depth 5)"

        if (($csrStatus.issuanceStatus -ne "ISSUED") -and ($csrStatus.issuanceStatus -ne "FAILED")) {
            return @{
                Result = "Success"
                Status = "Pending"
                PKCS7  = $null
            }
        }
        
        if ($csrStatus.issuanceStatus -eq "FAILED") {
            throw "Failed to issue certificate: " + $csrStatus.issuanceStatusDetails + "!";
        }

        if ($csrStatus.issuanceStatus -eq "ISSUED") {
            $certificateId = $csrStatus.certificateId
            $Parameters.Uri = $General.ServiceAddress + "/api/v2/certificates/$certificateId/der?chain=true"
            $chain = Invoke-WebRequestWithHawk @Parameters

            $b64Chain = [Convert]::ToBase64String($chain)

            Write-DebugLog "CHAIN = $b64Chain"
            return @{
                Result = "Success"
                Status = "Issued"
                PKCS7  = [byte[]]$chain
            }
        }

        throw "Unexpected issuanceStatus: " + $csrStatus.issuanceStatus
    }
    catch {
        throw Format-Error($_.Exception)
    }
}


<##################################################################################################
.NAME
    Revoke-Certificate
.DESCRIPTION
    Revokes a certificate issued by the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId: a string that uniquely identifies the certificate issued by the CA
        CertPem: the raw, Base64-encoded X509 certificate to be revoked
        ReasonCode : 1 (User Key Compromised), 2 (CA Key Compromised), 3 (User Changed Affiliation), 4 (Certificate Superseded), 5 (Original Use No Longer Valid)
        Comment: a comment provided by the revocation requester
.NOTES
    Returns a hashtable that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Revoke-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $certRequestId = $Specific.CertId
    try {
        # look up the certRequest status
        $Parameters = @{
            Method  = "GET"
            Uri     = $General.ServiceAddress + "/api/v2/csr/" + $certRequestId + "/status"
            HawkID  = $General.UserName
            HawkKey = $General.UserPass
        }
        $csrStatus = Invoke-RestMethodWithHawk @Parameters
        Write-DebugLog "CSR Status = $($csrStatus | ConvertTo-Json -Depth 5)"

        $certificateId = $csrStatus.certificateId
        
        $Parameters.Method = "PATCH"
        $Parameters.Uri = $General.ServiceAddress + "/api/v2/certificates/" + $certificateId
        $Parameters.Body = @{
            reason = $Specific.ReasonCode
        } | ConvertTo-Json

        $revokeStatus = Invoke-RestMethodWithHawk @Parameters
        Write-DebugLog "Revoke Result = $($revokeStatus | ConvertTo-Json -Depth 5)"

        return @{ Result = "Success" }        
    }
    catch {
        throw Format-Error($_.Exception)
    }
}

function Initialize-CustomExtensions {
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String]$Policy,
        [Parameter(Mandatory = $True, Position = 1)]
        [String]$Csr    
    )
    try {
        # form request
        $request = @{
            policy = $Policy
            csr    = $Csr
        }    
        $body = $request | ConvertTo-Json -Depth 5
        Write-DebugLog "Validate Body = $body"

        $requestParameters = @{
            Method  = "POST"
            Uri     = $General.ServiceAddress + "/api/v2/csr/validate"
            HawkID  = $General.UserName
            HawkKey = $General.UserPass
            Body    = $body
        }
        $validateResult = Invoke-RestMethodWithHawk @requestParameters
        Write-DebugLog "Validate Result = $($validateResult | ConvertTo-Json -Depth 5)"

        $customExtensions = @{}
        if ($validateResult.details.customExtensions.Count -gt 0) {
            foreach ($extension in $validateResult.details.customExtensions) {
                $customExtensions[$extension.oid] = $extension.defaultValue
            }
        }
        return $customExtensions
    }
    catch {
        throw Format-Error($_.Exception)
    }
}

function Write-DebugLog {
    param( [string]$message )

    if ($null -ne $DEBUG_FILE) {
        Write-Output "[$(Get-Date -Format FileDateTimeUniversal)] - $message" | Out-File $DEBUG_FILE -append
    }
}

Function Get-HawkHeader {
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String]$Uri,
        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet("Delete", "Get", "Head", "Options", "Post", "Patch")]
        [String]$Method = "Get",
        [Parameter(Mandatory = $True, Position = 2)]
        [String]$HawkID,
        [Parameter(Mandatory = $True, Position = 3)]
        [String]$HawkKey,
        [String]$ContentType = "application/json",
        [String]$Body
    )
    $uriParse = [System.Uri]::new($Uri)
    $now = [int]((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date).ToUniversalTime()).TotalSeconds)
    $method = $Method.ToUpper()
    $path = $uriParse.PathAndQuery  # "/api/path/to/resource";
    $hostUri = $uriParse.Host       # "example.com";
    $port = $uriParse.Port          # 80;

    $chars = $(48..57; 65..90; 97..122)
    $nonce = (1..6 | ForEach-Object { Get-Random -InputObject $chars } | ForEach-Object { [char]$_ }) -join ""

    $payloadHash = $null
    if ($null -ne $Body) {
        # set payload hash here
        $payload = "hawk.1.payload" + "`n"
        $payload += $ContentType.split(",")[0].ToLower() + "`n"
        $payload += $Body + "`n"
        $hash = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256") 
        $payloadHash = $hash.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payload))
        $payloadHash = [Convert]::ToBase64String($payloadHash)
    }
    $artifacts = "hawk.1.header" + "`n" + 
    $now + "`n" +
    $nonce + "`n" +
    $method + "`n" +
    $path + "`n" +
    $hostUri + "`n" +
    $port + "`n" +
    $payloadhash + "`n"

    $artifacts += "`n"

    $hmac = [System.Security.Cryptography.HMAC]::Create("HMACSHA256")
    $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($HawkKey)
    $signature = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($artifacts))
    $signature = [Convert]::ToBase64String($signature)

    $header = "Hawk id=`"$HawkID`", ts=`"$now`", nonce=`"$nonce`""
    if ($payloadhash) {
        $header += ", hash=`"$payloadhash`""
    }

    $header += ", mac=`"$signature`""
    Write-DebugLog "Hawk Header = $header"
    return $header
}

Function Invoke-RestMethodWithHawk {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String]$Uri,
        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet("Delete", "Get", "Head", "Options", "Post", "Patch")]
        [String]$Method = "Get",
        [Parameter(Mandatory = $True, Position = 2)]
        [String]$HawkID,
        [Parameter(Mandatory = $True, Position = 3)]
        [String]$HawkKey,
        [String]$ContentType = "application/json",
        [String]$Body
    )

    $HawkParams = @{
        Uri         = $Uri
        Method      = $Method
        HawkID      = $HawkID
        HawkKey     = $HawkKey
        ContentType = $ContentType
        Body        = $Body
    }

    $hawkHeader = Get-HawkHeader @HawkParams

    $invokeParams = @{
        Uri         = $Uri
        Method      = $Method
        ContentTYpe = $ContentType
        Headers     = @{ Authorization = $hawkHeader }
    }

    if (($null -ne $Body) -and ($Body -ne "")) {
        $invokeParams.Add("Body", $Body)
    }
    return Invoke-RestMethod @invokeParams
}

Function Invoke-WebRequestWithHawk {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String]$Uri,
        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet("Delete", "Get", "Head", "Options", "Post", "Patch")]
        [String]$Method = "Get",
        [Parameter(Mandatory = $True, Position = 2)]
        [String]$HawkID,
        [Parameter(Mandatory = $True, Position = 3)]
        [String]$HawkKey,
        [String]$ContentType = "application/json",
        [String]$Body
    )

    $HawkParams = @{
        Uri         = $Uri
        Method      = $Method
        HawkID      = $HawkID
        HawkKey     = $HawkKey
        ContentType = $ContentType
        Body        = $Body
    }

    $hawkHeader = Get-HawkHeader @HawkParams

    $invokeParams = @{
        Uri             = $Uri
        Method          = $Method
        ContentTYpe     = $ContentType
        Headers         = @{ Authorization = $hawkHeader }
        UseBasicParsing = $True
    }

    if (($null -ne $Body) -and ($Body -ne "")) {
        $invokeParams.Add("Body", $Body)
    }
    return (Invoke-WebRequest @invokeParams).Content
}

function Format-Error( [Exception] $ex ) {
    try {
        $result = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        return $reader.ReadToEnd()
        #$json = $reader.ReadToEnd() | ConvertFrom-Json
        #return $json.errors.message
    }
    catch {
        # the response is either not xml or not in the expected format
        return $ex.Message
    }
}
