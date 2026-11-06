<#
//---------------------------------------------------------------------------
// SSL.com_Adaptable_Script.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2022 Venafi, Inc. All rights reserved.
//
// This software is licensed by SSL.com, in addition to Venafi.
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

$global:version                     = "v1.0.0"      # version
$global:log_type_infor              = "INFO"        # info
$global:log_type_error              = "ERROR"       # error
$global:cert_new                    = 0             # create new order
$global:cert_replacement            = 1             # replace csr
$global:cert_renew                  = 2             # renew
$global:base_url                    = "https://sws.sslpki.com";
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
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
        Out-Log -nm_func 'Test-Settings' -ht_gen $General        
        # check user information
        Get-User-Info $General
        return @{ Result = "Success" }
    }
    catch {
        throw Parse-Error($_.Exception)
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
        Out-Log -nm_func 'Submit-CsrAsNew' -ht_gen $General -ht_spec $Specific
        $response = Submit-Csr $General $Specific $global:cert_new
        return $response
    }
    catch {
        throw Parse-Error($_.Exception)
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

    try {
        Out-Log -nm_func 'Submit-CsrAsRenewal' -ht_gen $General -ht_spec $Specific
        $response = Submit-Csr $General $Specific $global:cert_renew
        return $response
    }
    catch {
        throw Parse-Error($_.Exception)
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

    try {
        Out-Log -nm_func 'Submit-CsrAsReplacement' -ht_gen $General -ht_spec $Specific
        $response = Submit-Csr $General $Specific $global:cert_replacement
        return $response
    }
    catch {
        throw Parse-Error($_.Exception)
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

    try {
        Out-Log -nm_func 'Retrieve-Certificate' -ht_gen $General -ht_spec $Specific
        $ref_id = $Specific.CertId
        Write-Log "Retrieve-Certificate" $global:log_type_infor $ref_id
        $userInfo = Get-User-Info $General
        $url = $global:base_url + "/certificate/" + $ref_id + "?account_key=" + $userInfo.account_key + "&secret_key=" +
        $userInfo.secret_key + "&response_type=pkcs7&response_encoding=base64&query_type=all_certificates"
            
        $params = @{ 'Uri' = $url; 'Method' = 'GET'; 'Headers' = $headers; 'ContentType' = 'application/json' }
        try {
            $response = Invoke-RestMethod @params
        }
        catch {
            $exception = $_.Exception
            throw Parse-Error($exception)
        }    
        if ($response -and $response.order_status -eq "issued") {    
            $enc = [system.Text.Encoding]::UTF8
            $cert_bytes = $enc.GetBytes($response.certificates)             
            return @{ Result = "Success"; Status = "Issued"; PKCS7 = $cert_bytes }        
        }    
        else {
            return @{ Result = "Success"; Status = "Pending"; PKCS7 = $null }
        }        
    }
    catch {
        $exception = $_.Exception
        throw Parse-Error($exception)
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
    try {
        Out-Log -nm_func 'Revoke-Certificate' -ht_gen $General -ht_spec $Specific
        $order_ref = $Specific.CertId
        if (!$order_ref) {
            throw "certificate order ref (transaction id) is missing"
        }
        $reason = $null
        $cert_serials = $null;
        $CertPem = $Specific.CertPem;
        
        if ($General.CustomFields.Keys) {
            foreach ($key in $General.CustomFields.Keys) {
                $custom_value = $General.CustomFields[$key]
                if (![string]::IsNullOrEmpty($custom_value)) {
                    if ($key -eq "reason") {
                        $reason = $custom_value
                    }
                }
            }                    
        }
        
        if (!$reason) {        
            throw "reason for this revocation is missing, please reason for this revocation to Custom Fields (filed name: reason)"
        }
        $CertBytes = [Convert]::FromBase64String($CertPem)
        $x509Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$CertBytes)
        $cert_serial = $x509Cert.SerialNumber;
        $cert_serials = @($cert_serial.ToLower())
        # Check user info
        $userInfo = Get-User-Info $General
        $url = $global:base_url + "/certificate/" + $order_ref ;
       
        $body = @{
            account_key = $userInfo.account_key;
            secret_key  = $userInfo.secret_key;
            ref         = $order_ref;
            reason      = $reason;
            serials     = $cert_serials
        }       
        $body = $body | ConvertTo-Json
        $params = @{ 'Uri' = $url; 'Method' = 'DELETE'; 'Headers' = $headers; 'Body' = $body; 'ContentType' = 'application/json' }
        try {
            $response = Invoke-RestMethod @params
        }
        catch {
            $exception = $_.Exception
            throw Parse-Error($exception)
        }    
        if ($response -and $response.status -eq "revoked") {        
            return @{ Result = "Success"; TransId = $order_ref }        
        }    
        $errDetails = $response | ConvertTo-Json;
        throw "cannot revoke the certificate. error: " + $errDetails;
    }
    catch {
        throw Parse-Error($_.Exception)
    }
}
<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Write-Log {
    Param (
        [Parameter(Mandatory = $true, HelpMessage = "FuncName")]
        [string]$FuncName,
        [Parameter(Mandatory = $true, HelpMessage = "Type")]
        [string]$LogType,
        [Parameter(Mandatory = $false, HelpMessage = "Content")]
        [string]$Content
    )    
    #$DEBUG_FILE = 'A:\WORK\My-Github\Freelancer\20210913-US-eToken\Git\venafi\SSL.com_Adaptable_Script_20220331105721_debug.log';
    if ( $DEBUG_FILE )
    {
        $log_time = $((get-date).ToLocalTime()).ToString("yyyyMMdd HH:mm:ss")
        $log = $log_time + ' ' + $LogType + ' ' + $Content;
        $buf = ""
        $buf += "##### Log #####`n"
        $buf += "" + $log + "`n"

        $buf | Out-File $DEBUG_FILE -Append
    }
}

function Out-Log ( $nm_func, $ht_gen, $ht_spec )
{
    if ( $DEBUG_FILE )
    {
        try
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
        catch {
            throw Parse-Error($_.Exception)
        }
    }
}


function Show-Vars ( $name, $value )
{
    $result = "_____ $name _____`r`n"
    if ($value)
    {
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
    }
    
    return $result
}

function Get-User-Info() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    Write-Log 'Get-User-Info' $global:log_type_infor $General.UserName
    try {
        $url = $global:base_url + "/user/" + $General.UserName + "/?password=" + $General.UserPass        
        $params = @{ 'Uri' = $url; 'Method' = 'GET'; 'Headers' = $headers; 'ContentType' = 'application/json' }

        try {
            $response = Invoke-RestMethod @params
        }
        catch {
            $exception = $_.Exception
            throw Parse-Error($exception)
        }

        if ($response.account_key) {
            return $response;
        }

        throw "Cannot get account info. account: " + $response.account_key + " .status: " + $response.status
    }
    catch {
        throw Parse-Error($_.Exception)
    }
}

function Submit-Csr() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific,
        [Parameter(Mandatory = $true, HelpMessage = "Order Type")]
        [Int]$CsrType
    )
    try {
        # Check user info
        $userInfo = Get-User-Info $General
        # Specific Paramerters
        if (!$Specific.Pkcs10) {
            throw "Pkcs#10 required"
        }
        Write-Log 'Submit-Csr' $global:log_type_infor $Specific.Pkcs10
       
        $ou = ''
        if ($Specific.SubjectDN.OU -gt 0){
            foreach ($element in $Specific.SubjectDN.OU) {
                $ou = $element
                break;
            }
        }
        $sans = @()
        if ($Specific.SubjAltNames.DNS -gt 0){
            foreach ($element in $Specific.SubjAltNames.DNS) {
                $sans = $sans + $element
            }
        }       
        $org = $Specific.SubjectDN.O
        $subjectL = $Specific.SubjectDN.L
        $subjectST = $Specific.SubjectDN.ST
        $subjectC = $Specific.SubjectDN.C
        #
        $order_ref = $null;
        # call api
        try {
            $url = $global:base_url + "/certificates"
            $first_name = $null;
            $last_name = $null;
            $email = $null;
            $phone = $null;
            $product = $null;
            $period = $null;
            $postal_code = $null

            if ($General.CustomFields.Keys) {
                foreach ($key in $General.CustomFields.Keys) {
                    $custom_value = $General.CustomFields[$key]
                    if (![string]::IsNullOrEmpty($custom_value)) {
                        if ($key -eq "first_name") {
                            $first_name = $custom_value
                        }
                        elseif ($key -eq "last_name") {
                            $last_name = $custom_value
                        }
                        elseif ($key -eq "email") {
                            $email = $custom_value
                        }
                        elseif ($key -eq "phone") {
                            $phone = $custom_value
                        }
                        elseif ($key -eq "product") {
                            $product = $custom_value
                        }
                        elseif ($key -eq "period") {
                            $period = $custom_value
                        }
                        elseif ($postal_code -eq 'postal_code')
                        {
                            $postal_code = $custom_value
                        }
                    }                    
                }
            }
            if (!$email)
            {
                throw "admin email is missing, please add admin email to Custom Fields (filed name: email)"
            }
            if (!$phone)
            {
                throw "admin phone is missing, please add admin phone to Custom Fields (filed name: phone)"
            }
            if (!$first_name)
            {
                throw "admin first name is missing, please add admin first name to Custom Fields (filed name: first_name)"
            }
            if (!$last_name)
            {
                throw "admin last name is missing, please add admin last name to Custom Fields (filed name: last_name)"
            }
            if (!$product)
            {
                throw "The product code is missing, please add product code to Custom Fields (filed name: product)
                The product code of the certificate being purchased. Select only one code from the following choices:
                    100 EV UCC SSL
                    101 UCC SSL
                    102 EV SSL
                    103 High Assurance SSL
                    104 Free SSL
                    105 Wildcard SSL
                    106 Basic SSL
                    107 Premium SSL"
            }
            if (!$period)
            {
                throw "The number of days the certificate is missing, please add the value to Custom Fields (filed name: period).
                The number of days the certificate is valid for. Options are available: 
                    365 or 730 for EV SSL certs 
                    30 or 90 for Free Trial SSL certs"
            }
            $body = @{
                account_key            = $userInfo.account_key;
                secret_key             = $userInfo.secret_key;
                product                = $product;
                period                 = $period;
                server_software        = 1;
                domains                = $sans_dns;
                organization           = $org;
                organization_unit      = $ou;
                street_address_1       = $subjectST;
                locality_name          = $subjectL;
                state_or_province_name = $subjectST;
                postal_code            = $postal_code;
                country                = $subjectC;
                csr                    = $Specific.Pkcs10; # Required.                
                contacts               = @{
                    all = @{
                        first_name = $first_name
                        last_name  = $last_name
                        email      = $email
                        phone      = $phone
                    }
                }
            }          
            # CsrType: 0 - create new order, 1 - replace csr, 2 - renew
            if ($CsrType -eq 1 -or $CsrType -eq 2) { # replace csr or renew
                $order_ref = $Specific.CertId
                if (!$order_ref) {
                    throw "certificate order ref (transaction id) is missing"
                }
                else {
                    $url = $global:base_url + "/certificate/" + $order_ref ;
                }
            }
            if ($CsrType -eq 2) { # renenew: renewal_id=<old certificate order ref> 
                $body.renewal_id = $order_ref;
            }          
            $body = $body | ConvertTo-Json
            $params = @{ 'Uri' = $url; 'Method' = 'Post'; 'Headers' = $headers; 'Body' = $body; 'ContentType' = 'application/json' }
            if ($CsrType -eq 1) { # replace csr
                $params = @{ 'Uri' = $url; 'Method' = 'PUT'; 'Headers' = $headers; 'Body' = $body; 'ContentType' = 'application/json' }
            }
            try {
                $response = Invoke-RestMethod @params
            }
            catch {
                $exception = $_.Exception
                throw Parse-Error($exception)
            }    
            if ($response) {        
                $ref_id = $response.ref.ToString()
                return @{ Result = "Success"; TransId = $ref_id }        
            }    
            throw "cannot create order"
        }
        catch {
            throw Parse-Error($_.Exception)
        }       
    }
    catch {
        throw Parse-Error($_.Exception)
    }
}

function Parse-Error([Exception] $ex) {
    Write-Log 'Parse-Error' $global:log_type_error $ex.Message
    return $ex.Message
}
