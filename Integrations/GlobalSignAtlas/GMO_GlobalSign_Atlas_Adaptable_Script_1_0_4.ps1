<#
//----------------------------------------------------------------------- 
// GMO_GlobalSign_Atlas_Adaptable_Script.ps1
//
// Copyright (c) 2020 Venafi, Inc. All rights reserved.

// This software is licensed by the GMO GlobalSign Ltd, in addition to Venafi. 
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

$global:version = "v1.0.4"

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

<#############################
# START global configuration
##############################>

$global:api_base_url = "https://emea.api.hvca.globalsign.com:8443/v2" # default base URL
$global:signature_hash = "SHA-256" # default signature hash
$global:proxy_url = ""   # empty = no proxy; set to e.g. http://proxy.corp.local:8080
$global:request_mode = @{new = 'new'; renew = 'renew';}

<###########################
# END global configuration
############################>






<##########################################################p########################################
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
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Test-Settings {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Write-Venafi-Debug -Message "Test-Settings"

    Login-GlobalSign-Atlas-API $General

    return @{ Result = "Success" }
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
    
    Write-Venafi-Debug -Message "Get-ChainCertificates"

    $auth_token = Login-GlobalSign-Atlas-API $General

    try {
        $response = Get-GlobalSign-Atlas-API $General "/trustchain/" $auth_token
        $trustchain = $response.JsonData

        if ($response.Response.StatusCode -eq 200) {
            $enc = [system.Text.Encoding]::UTF8
            $chainPem = $trustchain -join "`r`n"
            
            Write-Venafi-Debug -Message "pkcs7: $($chainPem)"

            return @{
                Result = "Success"
                PKCS7 = $enc.GetBytes($chainPem)
            }
        }
        
        throw "Unexpected result: " + $trustchain
    }
    catch {
        throw Get-GlobalSign-Atlas-API-Error($_.Exception)
    }
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

    Write-Venafi-Debug -Message "Submit-CsrAsNew"

    try {
        $response = Submit-Csr $General $Specific $global:request_mode.new
        return $response
    }
    catch [AuthenticationError] {
        throw $_.Exception
    }
    catch {
        throw Get-GlobalSign-Atlas-API-Error($_.Exception)
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

    Write-Venafi-Debug -Message "Submit-CsrAsRenewal"
    
    try {
        $response = Submit-Csr $General $Specific $global:request_mode.renew
        return $response
    }
    catch {
        throw Get-GlobalSign-Atlas-API-Error($_.Exception)
    }
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

    Write-Venafi-Debug -Message "Submit-CsrAsReplacement"

    $auth_token = Login-GlobalSign-Atlas-API $General
    
    #todo support other hash algorithm and algorithm from custom fields
    try {        
        $hash_algorithm = $General.CustomFields.hash_algorithm
        if ([string]::IsNullOrEmpty($hash_algorithm)) {
            $hash_algorithm = $global:signature_hash
        }

        $request_body = @{
            signature = @{
                hash_algorithm = $hash_algorithm
            };
            public_key = $Specific.Pkcs10
        }

        $response = Post-GlobalSign-Atlas-API $General "/certificates/$($Specific.CertId)/rekey" $request_body $auth_token
        $certificate_id = Get-IdFromResponse $response

        return @{ Result = "Success"; TransId = $certificate_id }
    }
    catch {
        throw Get-GlobalSign-Atlas-API-Error($_.Exception)
    }
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
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "Success" }
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

    Write-Venafi-Debug -Message 'Retrieve-Certificate'

    $auth_token = Login-GlobalSign-Atlas-API $General

    try {
        $response = Get-GlobalSign-Atlas-API $General "/certificates/$($Specific.CertId)" $auth_token
        $cert = $response.JsonData

        if ($response.Response.StatusCode -eq 202) {
            return @{ Result = "Success"; Status = "Pending"; PKCS7 = $null }
        }

        if ( $cert.status -eq "ISSUED" ) {
            $enc = [system.Text.Encoding]::UTF8
            return @{ Result = "Success"; Status = "Issued"; PKCS7 = $enc.GetBytes($cert.certificate) }
        }
        elseif ( $cert.status -eq "REVOKED" ) {
            throw "The certificate has been revoked"
        }

        throw "Unexpected order status: " + $cert.status
    }
    catch {
        throw Get-GlobalSign-Atlas-API-Error($_.Exception)
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

    Write-Venafi-Debug -Message 'Revoke-Certificate'

    $auth_token = Login-GlobalSign-Atlas-API $General

    try {
        $revocation_reason = Get-Revocation-Reason $Specific.ReasonCode
        $request_body = @{
            revocation_reason = $revocation_reason
        }
        
        Patch-GlobalSign-Atlas-API $General "/certificates/$($Specific.CertId)" $request_body $auth_token

        return @{ Result = "Success" }
    }
    catch {
        throw Get-GlobalSign-Atlas-API-Error($_.Exception)
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Get-Proxy() {
    Param([Parameter(Mandatory=$true)][System.Collections.Hashtable]$General)
    if ( [string]::IsNullOrEmpty($global:proxy_url) ) {
         return @{ } 
        }
    return @{ Proxy = $global:proxy_url; ProxyUseDefaultCredentials = $true }
}

function Submit-Csr() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific,
        [Parameter(Mandatory = $true, HelpMessage = "Set to true if Renewal")]
        [string]$RequestMode
    )
    # Write-Venafi-Debug -Message "submit-csr-globalsign"
    $auth_token = Login-GlobalSign-Atlas-API $General

    $renewal_body = @{ }
    if ($RequestMode -eq $global:request_mode.renew) {
        # Renewal same as issuance"
    }

    $extended_key_usages_body = @{}
    if (![string]::IsNullOrEmpty($General.CustomFields.extended_key_usages)) {
        $extended_key_usages = @()        
        $extended_key_usages_input = $General.CustomFields.extended_key_usages -split ','

        foreach ($extended_key_usage in $extended_key_usages_input) {
            $extended_key_usage = $extended_key_usage.Trim()
            $extended_key_usages += $extended_key_usage
        }
        
        $extended_key_usages_body = @{
            extended_key_usages = $extended_key_usages 
        }
    }

    $subject_dn = @{}
    if (![string]::IsNullOrEmpty($Specific.SubjectDN.CN)) {$subject_dn.Add('common_name', $Specific.SubjectDN.CN)}
    # if (![string]::IsNullOrEmpty($Specific.SubjectDN.O)) {$subject_dn.Add('organization', $Specific.SubjectDN.O)}
    # if (![string]::IsNullOrEmpty($Specific.SubjectDN.OU)) {$subject_dn.Add('organizational_unit', $Specific.SubjectDN.OU)}
    # if (![string]::IsNullOrEmpty($Specific.SubjectDN.L)) {$subject_dn.Add('locality', $Specific.SubjectDN.L)}
    # if (![string]::IsNullOrEmpty($Specific.SubjectDN.C)) {$subject_dn.Add('country', $Specific.SubjectDN.C)}
    # if (![string]::IsNullOrEmpty($Specific.SubjectDN.ST)) {$subject_dn.Add('state', $Specific.SubjectDN.ST)}

    $san = @{}
    if ($Specific.SubjAltNames.DNS.Count -gt 0) {$san.Add('dns_names', $Specific.SubjAltNames.DNS)}
    if ($Specific.SubjAltNames.IP.Count -gt 0) {$san.Add('ip_addresses', $Specific.SubjAltNames.IP)}
    if ($Specific.SubjAltNames.Email.Count -gt 0) {$san.Add('emails', $Specific.SubjAltNames.Email)}
    if ($Specific.SubjAltNames.URI.Count -gt 0) {$san.Add('uris', $Specific.SubjAltNames.URI)}
    if ($Specific.SubjAltNames.UPN.Count -gt 0) {
        if ($Specific.SubjAltNames.UPN.Count -ne 1) {throw "Only one User Principal Name (other name) supported"}
        if ([string]::IsNullOrEmpty($General.CustomFields.user_principal_name_type)) {throw Missing-Mandatory-Configuration "user_principal_name_type must be defined for User Principal Subject Alternative Name "}

        $other_names = @()
        foreach ($upn in $Specific.SubjAltNames.UPN) {
            $other_names += @{
                type = $General.CustomFields.user_principal_name_type;
                value = $upn
            }
        }
        Write-Venafi-Debug -Message 'other names'
        $other_names | Write-Venafi-Debug

        $san.Add('other_names', $other_names)
    }

    $hash_algorithm = $General.CustomFields.hash_algorithm
    if ([string]::IsNullOrEmpty($hash_algorithm)) {
        $hash_algorithm = $global:signature_hash
    }
    
    $tempDate = [datetime]::MinValue
    $not_before = Get-Date
    if (![string]::IsNullOrEmpty($General.CustomFields.validity_not_before) -and [datetime]::TryParseExact($General.CustomFields.validity_not_before, 'yyyy-MM-dd HH:mm:ss', $null, [System.Globalization.DateTimeStyles]::None, [ref]$tempDate)) {
        Write-Venafi-Debug -Message "DateTime provided in validity_not_before input"
        $given_not_before = [datetime]::ParseExact($General.CustomFields.validity_not_before, 'yyyy-MM-dd HH:mm:ss', $null)
        Write-Venafi-Debug "validity_not_before raw value"
        $given_not_before | Write-Venafi-Debug

        if ($given_not_before -ge $not_before) {
            $not_before = $given_not_before
        }
    } elseif (![string]::IsNullOrEmpty($General.CustomFields.validity_not_before) -and [datetime]::TryParseExact($General.CustomFields.validity_not_before, 'yyyy-MM-dd',$null, [System.Globalization.DateTimeStyles]::None, [ref]$tempDate)) {
        Write-Venafi-Debug -Message "Only Date provided in validity_not_before input"
        $given_not_before = [datetime]::ParseExact($General.CustomFields.validity_not_before, 'yyyy-MM-dd', $null)
        Write-Venafi-Debug "validity_not_before raw value"
        $given_not_before | Write-Venafi-Debug

        if ($given_not_before -ne $not_before.Date) {
            throw "Exception: API error: validity.not_before: cannot be more than 180 seconds in the future"
        }
    }

    Write-Venafi-Debug "validity_not_before value: '$not_before'"

    $validity = @{
	    not_before = [long] (([DateTimeOffset]$not_before.ToUniversalTime()).ToUnixTimeSeconds())
    }

    if (![string]::IsNullOrEmpty($General.CustomFields.validity_not_after)) {
        try {
                $not_after = [datetime]::ParseExact($General.CustomFields.validity_not_after, 'yyyy-MM-dd HH:mm:ss', $null)
        }
        catch {
                throw "Exception: Provided validity_not_after is not valid."       
            }

        $validity = $validity + @{
            not_after = ([DateTimeOffset]$not_after.ToUniversalTime()).ToUnixTimeSeconds()
        }
    }

    $body = @{
        validity = $validity;
        signature = @{
            hash_algorithm = $hash_algorithm;
        };
        public_key = $Specific.Pkcs10;
    }

    if ($subject_dn.Count -ne 0) {$body = $body + @{'subject_dn' = $subject_dn};}
    if ($san.Count -ne 0) {$body = $body + @{'san' = $san};}

    $request_body = $body + $renewal_body + $extended_key_usages_body
    $response = Post-GlobalSign-Atlas-API $General '/certificates' $request_body $auth_token
    $certificate_id = Get-IdFromResponse $response

    return @{ Result = "Success"; TransId = $certificate_id }
}

function Get-Base-Url-GlobalSign-Atlas-API {    
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    $base_url = $General.ServiceAddress

    if ([string]::IsNullOrEmpty($base_url)) {
        $base_url = $global:api_base_url
    }

    return $base_url;
}

function Get-Authentication-Certificate-Parameter {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    if ([string]::IsNullOrEmpty($General.PfxData)) { throw Missing-Mandatory-Configuration 'Client Certificate File'}
    if ([string]::IsNullOrEmpty($General.PfxPass)) { throw Missing-Mandatory-Configuration 'Client Certificate File Password'}

    try {
        $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($General.PfxData, $General.PfxPass)
    }
    catch {
        throw "Unable to use the authentication certificate. " + $_.Exception.Message
    }

    return @{
        Certificate = $certificate
    }
}

function Get-GlobalSign-Atlas-API {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        
        [Parameter(Mandatory = $true, HelpMessage = "URI")]
        [string]$RelativeUri,
        
        [Parameter(Mandatory = $true, HelpMessage = "Authentication token")]
        [string]$AuthToken,
        
        [Parameter(Mandatory = $false, HelpMessage = "Debug logging")]
        [bool]$Logging = $False
    )

    Write-Venafi-Debug -Message "API request GET $($RelativeUri)"

    $parameters = Request-Parameters-GlobalSign-Atlas-API -General $General -Method 'GET' -RelativeUri $RelativeUri -AuthToken $AuthToken -Logging $Logging
    $response = Invoke-WebRequest @parameters -UseBasicParsing

    if ($Logging) {
        Write-Venafi-Debug -Message 'API response'
        $Response | Write-Venafi-Debug
    }

    $json_data = $Response.Content | ConvertFrom-Json

    Write-Venafi-Debug -Message 'API JsonData'
    if ($null -eq $json_data) {
        Write-Venafi-Debug -Message 'null'
    } elseif ($Logging) {
        $json_data | Write-Venafi-Debug
    }

    return @{Response = $response; JsonData = $json_data}
}

function Post-GlobalSign-Atlas-API {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        
        [Parameter(Mandatory = $true, HelpMessage = "URI")]
        [string]$RelativeUri,

        [Parameter(Mandatory = $false, HelpMessage = "Request body")]
        [System.Collections.Hashtable]$Body,
        
        [Parameter(Mandatory = $false, HelpMessage = "Authentication token")]
        [string]$AuthToken = $null,
        
        [Parameter(Mandatory = $false, HelpMessage = "Debug logging")]
        [bool]$Logging = $false
    )

    Write-Venafi-Debug -Message "API request POST $($RelativeUri)"

    $parameters = Request-Parameters-GlobalSign-Atlas-API $General 'POST' $RelativeUri $Body $AuthToken $Logging
    $response = Invoke-WebRequest @parameters -UseBasicParsing

    if ($Logging) {
        Write-Venafi-Debug -Message 'API response'
        $Response | Write-Venafi-Debug
    }

    $json_data = $Response.Content | ConvertFrom-Json

    Write-Venafi-Debug -Message 'API JsonData'
    if ($null -eq $json_data) {
        Write-Venafi-Debug -Message 'null'
    } elseif ($Logging) {
        $json_data | Write-Venafi-Debug
    }

    return @{Response = $response; JsonData = $json_data}
}

function Patch-GlobalSign-Atlas-API {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        
        [Parameter(Mandatory = $true, HelpMessage = "URI")]
        [string]$RelativeUri,

        [Parameter(Mandatory = $false, HelpMessage = "Request body")]
        [System.Collections.Hashtable]$Body,
        
        [Parameter(Mandatory = $false, HelpMessage = "Authentication token")]
        [string]$AuthToken,
        
        [Parameter(Mandatory = $false, HelpMessage = "Debug logging")]
        [bool]$Logging = $False
    )

    Write-Venafi-Debug -Message "API request PATCH $($RelativeUri)"

    $parameters = Request-Parameters-GlobalSign-Atlas-API $General 'PATCH' $RelativeUri $Body $AuthToken $Logging
    $response = Invoke-WebRequest @parameters -UseBasicParsing

    if ($Logging) {
        Write-Venafi-Debug -Message 'API response'
        $Response | Write-Venafi-Debug
    }

    $json_data = $Response.Content | ConvertFrom-Json

    Write-Venafi-Debug -Message 'API JsonData'
    if ($null -eq $json_data) {
        Write-Venafi-Debug -Message 'null'
    } elseif ($Logging) {
        $json_data | Write-Venafi-Debug
    }

    return @{Response = $response; JsonData = $json_data}
}

function Request-Parameters-GlobalSign-Atlas-API {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        
        [Parameter(Mandatory = $true, HelpMessage = "HTTP method")]
        [string]$Method,
        
        [Parameter(Mandatory = $true, HelpMessage = "URI")]
        [string]$RelativeUri,

        [Parameter(Mandatory = $false, HelpMessage = "Request body")]
        [System.Collections.Hashtable]$Body,
        
        [Parameter(Mandatory = $false, HelpMessage = "Authentication token")]
        [string]$AuthToken = $null,
        
        [Parameter(Mandatory = $false, HelpMessage = "Debug logging")]
        [bool]$Logging = $False
    )

    $authHeader = @{}
    if ($AuthToken -ne $null) {
        $authHeader = @{'Authorization' = 'Bearer ' + $AuthToken}
    }

    $headers = @{
        "Content-Type" = "application/json;charset=utf-8"
    } + $authHeader

    $uri = Get-Base-Url-GlobalSign-Atlas-API $General
    $uri = $uri + $RelativeUri

    $proxy_url = Get-Proxy $General
    $certificate = Get-Authentication-Certificate-Parameter $General

    $bodyParam = @{}
    if ($PSBoundParameters.ContainsKey('Body')) {
        if ($Logging) {
            Write-Venafi-Debug -Message 'Body'
            $Body | Write-Venafi-Debug
        }

        $bodyParam = @{'Body' = ($Body | ConvertTo-Json)};
    }

    $params = @{
        'Uri' = $uri;
        'Method' = $Method;
        'Headers' = $headers;
        'ContentType' = 'application/json;charset=utf-8';
    } + $bodyParam + $certificate + $proxy_url

    return $params
}

function Login-GlobalSign-Atlas-API {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    #  if (($null -ne $General.CustomFields.globalsign_atlas_auth_token_expiry) -and ($General.CustomFields.globalsign_atlas_auth_token_expiry -gt (Get-Date).AddMinutes(1))) {
    #     Write-Venafi-Debug -Message "auth token from cache"
        
    #     return $General.CustomFields.globalsign_atlas_auth_token
    # }

    Write-Venafi-Debug -Message "Login-GlobalSign-Atlas-API"

    if ([string]::IsNullOrEmpty($General.UserName)) { throw Missing-Mandatory-Configuration 'API key in the Username field'}
    if ([string]::IsNullOrEmpty($General.UserPass)) { throw Missing-Mandatory-Configuration 'API secret in teh Password field'}

    $request_body = @{
        "api_key" = $General.UserName;
        "api_secret" = $General.UserPass
    }

    try {
        $response = Post-GlobalSign-Atlas-API $General "/login" $request_body
    }
    catch {
        throw [AuthenticationError] $_.Exception
    }

    $globalsign_atlas_auth_token = $response.JsonData.access_token
    # $General.CustomFields.globalsign_atlas_auth_token = $globalsign_atlas_auth_token
    # $General.CustomFields.globalsign_atlas_auth_token_expiry = (Get-Date).AddMinutes(10)

    return $globalsign_atlas_auth_token
}

function Get-Revocation-Reason {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Reason code")]
        [string]$ReasonCode
    )

    switch ($ReasonCode) {
        1 { $reason = 'keyCompromise'; break }

        # 2 cACompromise not supported
        
        3 { $reason = 'affiliationChanged'; break }
        
        4 { $reason = 'superseded'; break }
        
        5 { $reason = 'cessationOfOperation'; break }

        Default {
            $reason = 'unspecified'
        }
    }

    return $reason
}

function Get-GlobalSign-Atlas-API-Error([Exception] $ex) {
    try {
        $result = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $json = $reader.ReadToEnd() | ConvertFrom-Json
        
        Write-Venafi-Debug -Message "Exception: API error: $($json.description) $($ex.Source) $($ex.Data)"

        $description = $json.description
        if ( [string]::IsNullOrEmpty($description) ) {
             return $ex.Message 
        }
        return $description
    }
    catch {
        # the response is either not JSON or not in the expected format
        Write-Venafi-Debug -Message "Exception: $($ex.Message) $($ex.Source) $($ex.Data)"

        return $ex.Message
    }
}

class AuthenticationError: System.Exception{
    $Message
    AuthenticationError([System.Exception] $ex) {
        try {
            $description = Get-GlobalSign-Atlas-API-Error $ex
            $this.Message = "Authentication error. $($description) $($ex.Source) $($ex.Data)"
        }
        catch {            
            $this.Message = $ex.Message
        }

        Write-Venafi-Debug -Message "Exception: $($this.Message) $($ex.Source) $($ex.Data)"
    }
}

function Get-IdFromResponse([System.Collections.Hashtable] $response) {
    if ($response.Response.Headers.Location -match '/(?<id>[A-Z0-9]+)$' -ne $true) {
        throw "Unexpected response from server."
    }

    return $Matches.id
}

function Missing-Mandatory-Configuration([string] $missingKey) {
    return "Missing configuration: $($missingKey)."
}

<#
    .SYNOPSIS
    Write info to the adaptable debug log

    .DESCRIPTION
    Assuming the option has been selected, write info to the adaptable debug log.
    Hashtables are supported and secret info will not be logged, eg. $General.

    .PARAMETER Message
    The info to be logged

    .PARAMETER ThrowException
    After logging the message, throw an exception to terminate the script

    .EXAMPLE
    Write-Venafi-Debug -Message 'connected to server'

    Write info to the log

    .EXAMPLE
    $General | Write-Venafi-Debug

    Write input parameter values to the log

    .EXAMPLE
    Write-Venafi-Debug -Message 'this was not good' -ThrowException

    Write to the log and throw an exception
    ###>    
function Write-Venafi-Debug {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject] $Message,

        [Parameter()]
        [switch] $ThrowException
    )

    if ( $global:DEBUG_FILE ) {

        $newMessage = $Message
        
        if ( $newMessage.GetType().Name -eq 'Hashtable' ) {
            $newMessage = $Message.Clone()
            'UserPass', 'AuxPass', 'PfxPass', 'Certificate', 'PfxData' | ForEach-Object {
                if ( $newMessage[$_] ) {
                    $newMessage[$_] = '***hidden***'
                }
            }
            $newMessage = $newMessage | ConvertTo-Json -Depth 5
        }

        try {
            # use a mutex to ensure multiple executions of this script don't cause 'file in use' errors
            $mutex = New-Object System.Threading.Mutex($false, [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName))
            if ( -not $mutex.WaitOne(0) ) {
                $mutex.WaitOne()
            }
            ('{0} : {1}' -f (Get-Date), ($newMessage | Out-String)) | Out-File -FilePath $global:DEBUG_FILE -Encoding 'UTF8' -Append
        } catch {
            throw $_
        } finally {
            $null = $mutex.ReleaseMutex()
        }
    }

    if ( $ThrowException ) {
        throw $Message
    }
}
