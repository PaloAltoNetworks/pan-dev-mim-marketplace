<#
//----------------------------------------------------------------------- 
// DigiCert_Adaptable_Script.ps1
//
// Copyright (c) 2020 Venafi, Inc. All rights reserved.

// This software is licensed by the DigiCert, Inc., in addition to Venafi. 
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

$global:version = "v1.6.7"

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#From Config file
$additionalCustomFields = $null
$script_dir = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Scripts\AdaptableCA\"
if (test-path "$script_dir\additionalConfig.json") {
    $additionalCustomFields = (Get-Content -Raw -Path "$script_dir\additionalConfig.json") | ConvertFrom-Json
}

<#############################
# START global configuration
##############################>

$global:api_base_url = "https://api.digicert.com/services/v2" # default base URL
$global:validity_years = 1 # default order validity
$global:server_licenses = 1 # default server license
$global:signature_hash = "sha256" # default signature hash
$global:product = "ssl_securesite_flex"
$global:disable_renewal_notifications = $true
$global:locale = "en"
$global:profile_option = $null
$global:cs_provisioning_method = $null
$global:dcv_method = "email"
$global:ca_cert_id = $null <#example: "EEFDCC678DFC4638"; <String> ID of the public intermediate certificate authority (ICA) that you want to sign the certificate.
If you provide the ID of an ICA that you cannot use to sign the certificate, the request returns an error.
To get IDs for the public ICAs that can sign each type of certificate, use the Product limits(https://dev.digicert.com/services-api/containers/product-limits/) endpoint
OR Product Info endpoint: https://dev.digicert.com/services-api/products/product-info/#>
$global:server_platform = @{id = -1}; #example: @{id = -1}; <Integer> Server platform ID. See https://dev.digicert.com/glossary/#server-platforms
$global:cert_validity = $null #example1: @{"years"=1}; example2: @{"days"=100}; example3: @{"custom_expiration_date"="09 JUN 2025"}; <Object> Defines the validity period of the first certificate issued for this order. Cannot exceed order validity period. This object is not used for requests from accounts that do not have Multi-year Plans enabled.
$global:order_validity = $null #example1: @{"days"=100}; example2: @{"custom_expiration_date"="09 JUN 2025"}; <Object> Defines the order validity. If defined, overrides 'validity_years'.
$global:comments = "venafi cc integration v1.6.7"; #example: "venafi cc integration v1.6.7"; <String> Comments about the order for the approver.
$global:apply_cr_discount = $null #example: $true; <Boolean> When true, applies any competitive replacement discounts that are available for the domains on the order.  To calculate competitive replacement discounts before you place an order, use the List replacement benefits endpoint (https://dev.digicert.com/services-api/finance/list-competitive-replacement-benefits/).
$global:serial_number = $null #example: "043AA19C54E10301A8B0BDD5A69141C2"; <String> Serial number of the non-DigiCert certificate for which you expect to receive a competitive replacement discount when you place the order
$global:auto_renew = $null #example: 0; <Integer> Specify if the certificate should automatically renew. Allowed values: 0 (disabled), 1 (enabled)
$global:custom_renewal_message = $null #example: "renewed automatically"; <String> Custom message to be included in renewal notifications.
$global:additional_emails = $null #example: $global:additional_emails = @('dev1@email.com','dev2@email.com'); array of <String> Additional email addresses to receive certificate notification emails.
$global:payment_method = $null #example: "balance"; <String> Specify the payment method to use. Allowed values: balance, card, profile. Default: balance
$global:container = $null #example: @{"id"=1234}; # <Object> If needed, specify the container the order should be placed under. In the CertCentral UI, containers are called divisions. Container ID can be obtained from List Containers endpoint: https://dev.digicert.com/services-api/containers/list-containers/
$global:proxy_url = "http://proxy:port"

<###########################
# END global configuration
############################>



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
        # check if the product is enabled in the account
        Get-Product $General

        return @{ Result = "Success" }
    }
    catch {
        throw Decode-Error($_.Exception)
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
   # write-venafidebug -message "submit-csrasnew"
    try {
        $response = Submit-Csr $General $Specific $false
        return $response
    }
    catch {
        throw Decode-Error($_.Exception)
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
   # write-venafidebug -message "submit-csrasrenewal"
    try {
        $response = Submit-Csr $General $Specific $true
        return $response
    }
    catch {
        throw Decode-Error($_.Exception)
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
   # write-venafidebug -message "submit-csrasreplacement"
    try {
        $locale = $global:locale
        $ca_cert_id = $global:ca_cert_id
        $server_platform = $global:server_platform
        $profile_option = $global:profile_option

        foreach ($key in $General.CustomFields.Keys) {

            $custom_value = $General.CustomFields[$key]

            if (![string]::IsNullOrEmpty($custom_value)) {
                $start_index = $custom_value.LastIndexOf('(')
                if ($start_index -gt -1) {
                    $val = $custom_value.Substring($start_index + 1)
                    $end_index = $val.LastIndexOf(')')
                    if ($end_index -gt -1) {
                        $val = $val.Remove($end_index)
                        if (![string]::IsNullOrEmpty($val)) {
                            if ($key -eq "Locale") {
                                $locale = $val
                            }
                            if ($key -eq "Profile option") {
                                $profile_option = $val
                            }
                            if ($key -eq "ICA") {
                                $ca_cert_id = $val
                            }
                            if ($key -eq "Server Platform") {
                                $server_platform = @{id = $val}
                            }
                        }
                    }
                }
            }

            if ($key -eq "Cert validity years") {
                $cert_validity_years = [int]$custom_value[0]
            }
            if ($key -eq "Cert validity days") {
                $cert_validity_days = $custom_value
            }
            if ($key -eq "Cert validity custom expiration date") {
                $cert_validity_custom_expiration_date = $custom_value
            }
        }
    }
    catch {
        throw Decode-Error($_.Exception)
    }

    $cn = $Specific.SubjectDN.CN
    $ou = @() + $( $Specific.SubjectDN.OU | ? { $_ } )  # an array of Organizational Units, possibly empty
    if (($Specific.SubjectDN.OU -eq "n/a") -or ($Specific.SubjectDN.OU -eq "na") -or ($Specific.SubjectDN.OU -eq "N/a") -or ($Specific.SubjectDN.OU -eq "Na") -or ($Specific.SubjectDN.OU -eq "n/A") -or ($Specific.SubjectDN.OU -eq "nA") -or ($Specific.SubjectDN.OU -eq "N/A") -or ($Specific.SubjectDN.OU -eq "NA")) {
        $ou = @()
    }
    $sans_dns = @() + $( $Specific.SubjAltNames.DNS | ? { $_ } )  # an array of DNS Subject Alternative Names, possibly empty

    try {
        $cert_validity = $global:cert_validity
        if ($cert_validity_years -ne $null -or $cert_validity_days -ne $null -or $cert_validity_custom_expiration_date -ne $null ) {
            $cert_validity = @{
                years = $cert_validity_years;
                days = $cert_validity_days;
                custom_expiration_date = $cert_validity_custom_expiration_date;
            };
        }
        
        $order_id = Get-Order-Id-From-Cert $General $Specific
        # submit a CSR for reissuance
        
        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        $url = $base_url + "/order/certificate/" + $order_id + "/reissue"

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass
        }

        $body = @{
            certificate    = @{
                common_name     = $cn; # Required.
                dns_names       = $sans_dns;
                csr             = $Specific.Pkcs10; # Required.
                organization_units = $ou; #  array of <String> . Per DigiCert API doc: currently only one OU is supported.
                signature_hash  = $global:signature_hash; # Required.
                server_platform = $server_platform; # Required.
                ca_cert_id      = $ca_cert_id
                profile_option	= $profile_option
                cert_validity   = $cert_validity; # Defines the validity period of the first certificate issued for this order. Cannot exceed order validity period. This object is not used for requests from accounts that do not have Multi-year Plans enabled.
                <#@{
                    years=$null
                    days=$null
                    custom_expiration_date=$null
                }#>
                emails          = $global:additional_emails;
            }
            comments       = $global:comments; # Message about the reissue.
            locale         = $locale; # Language that the DCV email should use
            payment_method = $global:payment_method; # Specify the payment method to use. Allowed values: balance, card, profile. Default: balance
        } | ConvertTo-Json
        
        $proxy_url = Get-Proxy $General
        $params = @{ 'Uri' = $url; 'Method' = 'Post'; 'Headers' = $headers; 'Body' = $body; 'ContentType' = 'application/json' } + $proxy_url

        $response = Invoke-RestMethod @params

        # Transaction ID shall include both Order ID and Request ID
        if ($response.requests -eq $null) {
            $transaction_id = $response.id.ToString()
            return @{ Result = "Success"; TransId = $transaction_id }
        }
        $transaction_id = $response.id.ToString() + ":" + $response.requests[0].id.ToString()
        return @{ Result = "Success"; TransId = $transaction_id }
    }
    catch {
        $exception = $_.Exception
        if ($exception.Response.StatusCode -eq [system.net.httpstatuscode]::NotFound) {
            return Submit-Csr $General $Specific $false
        }
        throw Decode-Error($_.Exception)
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

    $transaction_id = $Specific.CertId -split ":"
    $order_id = Get-Order-Id $General $Specific
    $request_id = $transaction_id[1]

    try {
        # look up the certificate id using the order id
        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        $url = $base_url + "/order/certificate/" + $order_id

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass;
        }

        $proxy_url = Get-Proxy $General
        $params = @{ 'Uri' = $url; 'Method' = 'Get'; 'Headers' = $headers; 'ContentType' = 'application/json' } + $proxy_url

        try {
            $response = Invoke-RestMethod @params
        }
        catch {
            $exception = $_.Exception
            if ($exception.Response.StatusCode -eq [system.net.httpstatuscode]::NotFound) {
                $order_id = Legacy-Order-Lookup $General $CurrOrderId
                $url = $base_url + "/order/certificate/" + $order_id

                $headers = @{
                    "X-DC-DEVKEY" = $General.UserPass;
                }

                $proxy_url = Get-Proxy $General
                $params = @{ 'Uri' = $url; 'Method' = 'Get'; 'Headers' = $headers; 'ContentType' = 'application/json' } + $proxy_url
                
                $response = Invoke-RestMethod @params
            }
            else {
                throw $_.Exception
            }
        }

        $is_ready = $false
        if ([string]::IsNullOrEmpty($request_id)) {
            $is_ready = $true
        }
        else {
            foreach ($request in $response.requests) {
                if ($request.id -eq $request_id) {
                    # API currently doesn't not tell us when a reissued cert has been issued so we must wait 10 minutes
                    $is_ready = ($request.type -eq "new_request") -or (([DateTime]::Now - ([DateTime]$request.date)).TotalMinutes -ge 1)
                }
            }
        }

        if ($response.status -eq "pending" -or $response.status -eq "processing" -or $response.status -eq "reissue_pending" -or $response.status -eq "needs_approval" -or -not$is_ready) {
            return @{ Result = "Success"; Status = "Pending"; PKCS7 = $null }
        }
        elseif ( $response.status -eq "issued" ) {
            # retrieve the certificate
            $headers = @{
                "X-DC-DEVKEY" = $General.UserPass;
            }

            $url = $base_url + "/certificate/" + $response.certificate[0].id + "/download/format/p7b"
            $proxy_url = Get-Proxy $General
            $params = @{ 'Uri' = $url; 'Method' = 'Get'; 'Headers' = $headers;  'UseBasicParsing' = $null; } + $proxy_url
            $response = Invoke-WebRequest @params
            $bytes = $response.Content

            return @{ Result = "Success"; Status = "Issued"; PKCS7 = $bytes }
        }

        throw "Unexpected order status: " + $response.status
    }
    catch {
        throw Decode-Error($_.Exception)
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
        $serial_number = Get-Serial-Number-From-PEM $General $Specific
        
        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        # revoke the certificate
        $url = $base_url + "/certificate/" + $serial_number + "/revoke"

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass;
        }

        $body = @{
            comments      = $Specific.Comment # Required.
            skip_approval = $true; # Specify if the order should skip the approval step and be immediately submitted for validation and issued when complete.
        } | ConvertTo-Json

        $proxy_url = Get-Proxy $General
        $params = @{ 'Uri' = $url; 'Method' = 'Put'; 'Headers' = $headers; 'Body' = $body; 'ContentType' = 'application/json' } + $proxy_url
        $response = Invoke-RestMethod @params

        return @{ Result = "Success" }
    }
    catch {
        throw Decode-Error($_.Exception)
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Get-Proxy-Original() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    if (![string]::IsNullOrEmpty($General.AuxPass) -and ![string]::IsNullOrEmpty($General.AuxUser)) {
        $pass = ConvertTo-SecureString $General.AuxPass -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $General.AuxUser, $pass
        return @{"Proxy"=$global:proxy_url; "ProxyCredential"=$cred }
    }
    return @{ }

}

function Get-Proxy() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    if (![string]::IsNullOrEmpty($General.AuxPass) -and ![string]::IsNullOrEmpty($General.AuxUser)) {
        $proxy = New-Object System.Net.WebProxy($global:proxy_url,$true)
        $proxy.Credentials = New-Object System.Net.NetworkCredential($General.AuxUser, $General.AuxPass)
        [System.Net.WebRequest]::DefaultWebProxy = $proxy
    }
    return @{ }

}

function Get-Org() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    try {
        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        # look up the organization id
        $url = $base_url + "/organization"

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass;
        }

        $proxy_url = Get-Proxy $General
        $params = @{ 'Uri' = $url; 'Method' = 'Get'; 'Headers' = $headers; 'ContentType' = 'application/json' } + $proxy_url
        return Invoke-RestMethod @params
    }
    catch {
        throw $_.Exception
    }
}

function Submit-Csr() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific,
        [Parameter(Mandatory = $true, HelpMessage = "Set to true if Renewal")]
        [bool]$IsRenewal
    )
   # write-venafidebug -message "submit-csr-digi"
    $cn = $Specific.SubjectDN.CN
    $ou = @() + $( $Specific.SubjectDN.OU | ? { $_ } )  # an array of Organizational Units, possibly empty
    if (($Specific.SubjectDN.OU -eq "n/a") -or ($Specific.SubjectDN.OU -eq "na") -or ($Specific.SubjectDN.OU -eq "N/a") -or ($Specific.SubjectDN.OU -eq "Na") -or ($Specific.SubjectDN.OU -eq "n/A") -or ($Specific.SubjectDN.OU -eq "nA") -or ($Specific.SubjectDN.OU -eq "N/A") -or ($Specific.SubjectDN.OU -eq "NA")) {
        $ou = @()
    }
    $sans_dns = @() + $( $Specific.SubjAltNames.DNS | ? { $_ } )  # an array of DNS Subject Alternative Names, possibly empty
    $org = $Specific.SubjectDN.O
    $fields = @()

    try {
        $org_resp = Get-Org $General
        foreach ($o in $org_resp.organizations) {
            #if ( $org.CompareTo($o.name) -eq 0 )
            if ($o.status -eq "active" -and $org.CompareTo($o.name) -eq 0) {
                $orgid = $o.id
            }
        }
    }
    catch {

        throw $_.Exception
    }
    if (-not$orgid) {
        throw "Could not locate the requested organization [" + $org + "]"
    }

    try {
        $product = $global:product
        $locale = $global:locale
        $ca_cert_id = $global:ca_cert_id
        $server_platform = $global:server_platform
        $container = $global:container
        $consider_org_from_csr = "FALSE"
        $order_validity_years = $global:validity_years
        $order_validity_days = $global:order_validity.days
        $order_validity_custom_expiration_date = $global:order_validity.custom_expiration_date
        $cert_validity_years = $null
        $cert_validity_days = $null
        $cert_validity_custom_expiration_date = $null
        $cs_provisioning_method = $global:cs_provisioning_method
        $server_licenses = $global:server_licenses
        $profile_option = $global:profile_option
        
        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        # look up the custom field ids
        $url = $base_url + "/account/metadata"

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass
        }

        $proxy_url = Get-Proxy $General
        $params = @{ 'Uri' = $url; 'Method' = 'Get'; 'Headers' = $headers; 'ContentType' = 'application/json' } + $proxy_url
        $resp = Invoke-RestMethod @params
        
        foreach ($key in $General.CustomFields.Keys) {
            $custom_value = $General.CustomFields[$key]
            # if there is a DigiCert custom field w/ label that matches TPP custom field label, include it in request
            if ($meta = $resp.metadata | Where-Object { $_.is_active } | Where-Object { $_.label -eq $key }) {
                $fields += @{ metadata_id = $meta.id; value = $custom_value }
            }

            if (![string]::IsNullOrEmpty($custom_value)) {
                $start_index = $custom_value.LastIndexOf('(')
                if ($start_index -gt -1) {
                    $val = $custom_value.Substring($start_index + 1)
                    $end_index = $val.LastIndexOf(')')
                    if ($end_index -gt -1) {
                        $val = $val.Remove($end_index)
                        if (![string]::IsNullOrEmpty($val)) {
                            if ($key -eq "Code Signing Provisioning Method") {
                                $cs_provisioning_method = $val
                            }
                            if ($key -eq "Locale") {
                                $locale = $val
                            }
                            if ($key -eq "ICA") {
                                $ca_cert_id = $val
                            }
                            if ($key -eq "Profile option") {
                                $profile_option = $val
                            }
                            if ($key -eq "Server Platform") {
                                $server_platform = @{id = $val}
                            }
                            if ($key -eq "Division") {
                                $container = @{"id" = $val}
                            }
                            if ($key -eq "Organization") {
                                foreach ($o in $org_resp.organizations) {
                                    if ($o.id -eq $val) {
                                        $custom_orgid = $o.id
                                    }
                                }
                                if (-not$custom_orgid) {
                                    throw "Could not locate the requested organization id [" + $val + "]"
                                }
                                $orgid = $val
                            }
                            if ($key -eq "Product") {
                                $product = $val
                            }
                        }
                    }
                }
            }
            
            if ($key -eq "Order validity years") {
                $order_validity_years = [int]$custom_value[0]
            }
            if ($key -eq "Order validity days") {
                $order_validity_days = $custom_value
            }
            if ($key -eq "Order validity custom expiration date") {
                $order_validity_custom_expiration_date = $custom_value
            }
            if ($key -eq "Cert validity years") {
                $cert_validity_years = [int]$custom_value[0]
            }
            if ($key -eq "Cert validity days") {
                $cert_validity_days = $custom_value
            }
            if ($key -eq "Cert validity custom expiration date") {
                $cert_validity_custom_expiration_date = $custom_value
            }
            if ($key -eq "Server licenses") {
                $server_licenses = $custom_value
            }
        }

    }
    catch {
        throw $_.Exception
    }

    try {
        $cert_validity = $global:cert_validity
        if ($cert_validity_years -ne $null -or $cert_validity_days -ne $null -or $cert_validity_custom_expiration_date -ne $null ) {
            $cert_validity = @{
                years = $cert_validity_years;
                days = $cert_validity_days;
                custom_expiration_date = $cert_validity_custom_expiration_date;
            };
        }
        
        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        # submit a CSR for enrollment
        $url = $base_url + "/order/certificate/" + $product

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass
        }

        $renewal_body = @{ }
        if ($IsRenewal) {
            $order_id = Get-Order-Id-From-Cert $General $Specific
            $renewal_body = @{
                renewal_of_order_id = $order_id # Required for renewal
            }
        }
        
        $body = $null
        if ($additionalCustomFields -ne $null -and $product -eq "code_signing_ev") {
            $body = @{
                certificate                   = @{
                    common_name        = $cn; #  <String> Required.
                    dns_names          = $sans_dns;
                    csr                = $Specific.Pkcs10; #  <String> Required.
                    organization_units = $ou; #  array of <String> . Per DigiCert API doc: currently only one OU is supported.
                    signature_hash     = $global:signature_hash; #<String> Required.
                    ca_cert_id         = $ca_cert_id <# <String> ID of the public intermediate certificate authority (ICA) that you want to sign the certificate.
                    If you provide the ID of an ICA that you cannot use to sign the certificate, the request returns an error.
                    To get IDs for the public ICAs that can sign each type of certificate, use the Product limits(https://dev.digicert.com/services-api/containers/product-limits/) endpoint
                    OR Product Info endpoint: https://dev.digicert.com/services-api/products/product-info/#>
                    server_platform    = $server_platform;
                    $additionalCustomFields.custom_oid_key = $additionalCustomFields.custom_oid_value;
                    profile_option     = $profile_option;
                    cert_validity      = $cert_validity; # Defines the validity period of the first certificate issued for this order. Cannot exceed order validity period. This object is not used for requests from accounts that do not have Multi-year Plans enabled.
                    <#@{
                        years=$null
                        days=$null
                        custom_expiration_date=$null
                    }#>
                };
                cs_provisioning_method  = $cs_provisioning_method;
                order_validity                = @{
                    # Required. <Object> Defines the validity period of the order. Order validity determines the length of a Multi-year Plan.
                    years                  = $order_validity_years; # <Integer> Number of years the order is valid.
                    days                   = $order_validity_days; # <Integer> Number of days the order is valid.Overrides order_validity.years.
                    custom_expiration_date = $order_validity_custom_expiration_date; # <String> Custom expiration date for the order. Overrides order_validity.days and order_validity.years. Format: dd MMM YYYY (for example, "09 JUN 2025"). Range: Must be within six years of the date you request the order.
                };
                comments                      = $global:comments; # <String> Comments about the order for the approver.
                apply_cr_discount             = $global:apply_cr_discount; # <Boolean> When true, applies any competitive replacement discounts that are available for the domains on the order.  To calculate competitive replacement discounts before you place an order, use the List replacement benefits endpoint (https://dev.digicert.com/services-api/finance/list-competitive-replacement-benefits/).
                serial_number                 = $global:serial_number; # <String> Serial number of the non-DigiCert certificate for which you expect to receive a competitive replacement discount when you place the order
                auto_renew                    = $global:auto_renew; # <Integer> Specify if the certificate should automatically renew. Allowed values: 0 (disabled), 1 (enabled)
                disable_renewal_notifications = $global:disable_renewal_notifications; # <Boolean> Specify if renewal notification emails should be disabled
                custom_renewal_message        = $global:custom_renewal_message; # <String> Custom message to be included in renewal notifications.
                additional_emails             = $global:additional_emails; # array of <String> Additional email addresses to receive certificate notification emails. Input type: Array of Strings
                locale                        = $locale; # <String> Language that the DCV email should use. See https://dev.digicert.com/certcentral/api/glossary/#locale-codes
                dcv_method                    = $global:dcv_method; # <String> DCV method to use when verifying domain control. See https://dev.digicert.com/certcentral/api/glossary/#dcv-methods
                payment_method                = $global:payment_method; # <String> Specify the payment method to use. Allowed values: balance, card, profile. Default: balance
                organization                  = @{
                    # <Object> Required.
                    id = $orgid # <Integer> The ID of an existing organization to associate with the order
                };
                container                     = $container;
                custom_fields                 = $fields; #<Object> Account-specific custom fields. Whether or not these fields are required depends on your custom field settings
                server_licenses               = $server_licenses;
            }
        } else {
            $body = @{
                certificate                   = @{
                    # Required.
                    common_name        = $cn; #  <String> Required.
                    dns_names          = $sans_dns;
                    csr                = $Specific.Pkcs10; #  <String> Required.
                    organization_units = $ou; #  array of <String> . Per DigiCert API doc: currently only one OU is supported.
                    signature_hash     = $global:signature_hash; #<String> Required.
                    ca_cert_id         = $ca_cert_id <# <String> ID of the public intermediate certificate authority (ICA) that you want to sign the certificate.
                    If you provide the ID of an ICA that you cannot use to sign the certificate, the request returns an error.
                    To get IDs for the public ICAs that can sign each type of certificate, use the Product limits(https://dev.digicert.com/services-api/containers/product-limits/) endpoint
                    OR Product Info endpoint: https://dev.digicert.com/services-api/products/product-info/#>
                    server_platform    = $server_platform;
                    profile_option     = $profile_option;
                    cert_validity      = $cert_validity; # Defines the validity period of the first certificate issued for this order. Cannot exceed order validity period. This object is not used for requests from accounts that do not have Multi-year Plans enabled.
                    <#@{
                        years=$null
                        days=$null
                        custom_expiration_date=$null
                    }#>
                };
                cs_provisioning_method  = $cs_provisioning_method;
                order_validity                = @{
                    # Required. <Object> Defines the validity period of the order. Order validity determines the length of a Multi-year Plan.
                    years                  = $order_validity_years; # <Integer> Number of years the order is valid.
                    days                   = $order_validity_days; # <Integer> Number of days the order is valid.Overrides order_validity.years.
                    custom_expiration_date = $order_validity_custom_expiration_date; # <String> Custom expiration date for the order. Overrides order_validity.days and order_validity.years. Format: dd MMM YYYY (for example, "09 JUN 2025"). Range: Must be within six years of the date you request the order.
                };
                comments                      = $global:comments; # <String> Comments about the order for the approver.
                apply_cr_discount             = $global:apply_cr_discount; # <Boolean> When true, applies any competitive replacement discounts that are available for the domains on the order.  To calculate competitive replacement discounts before you place an order, use the List replacement benefits endpoint (https://dev.digicert.com/services-api/finance/list-competitive-replacement-benefits/).
                serial_number                 = $global:serial_number; # <String> Serial number of the non-DigiCert certificate for which you expect to receive a competitive replacement discount when you place the order
                auto_renew                    = $global:auto_renew; # <Integer> Specify if the certificate should automatically renew. Allowed values: 0 (disabled), 1 (enabled)
                disable_renewal_notifications = $global:disable_renewal_notifications; # <Boolean> Specify if renewal notification emails should be disabled
                custom_renewal_message        = $global:custom_renewal_message; # <String> Custom message to be included in renewal notifications.
                additional_emails             = $global:additional_emails; # array of <String> Additional email addresses to receive certificate notification emails. Input type: Array of Strings
                locale                        = $locale; # <String> Language that the DCV email should use. See https://dev.digicert.com/certcentral/api/glossary/#locale-codes
                dcv_method                    = $global:dcv_method; # <String> DCV method to use when verifying domain control. See https://dev.digicert.com/certcentral/api/glossary/#dcv-methods
                payment_method                = $global:payment_method; # <String> Specify the payment method to use. Allowed values: balance, card, profile. Default: balance
                organization                  = @{
                    # <Object> Required.
                    id = $orgid # <Integer> The ID of an existing organization to associate with the order
                };
                container                     = $container;
                custom_fields                 = $fields; #<Object> Account-specific custom fields. Whether or not these fields are required depends on your custom field settings
                server_licenses               = $server_licenses;
            }
        }


        $request_body = $body + $renewal_body
        $request_body = $request_body | ConvertTo-Json
      #  $request_body | write-venafidebug
        $proxy_url = Get-Proxy $General
        $params = @{ 'Uri' = $url; 'Method' = 'Post'; 'Headers' = $headers; 'Body' = $request_body; 'ContentType' = 'application/json' } + $proxy_url
        $response = Invoke-RestMethod @params

        # Transaction ID shall include both Order ID and Request ID
        if ($response.requests -eq $null) {
            $transaction_id = $response.id.ToString()
            return @{ Result = "Success"; TransId = $transaction_id }
        }
        $transaction_id = $response.id.ToString() + ":" + $response.requests[0].id.ToString()
        return @{ Result = "Success"; TransId = $transaction_id }
    }
    catch {
        $exception = $_.Exception
        if ($IsRenewal -and $exception.Response.StatusCode -eq [system.net.httpstatuscode]::NotFound) {
            return Submit-Csr $General $Specific $false
        }
        throw $_.Exception
    }
}

function Get-Product {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    try {
        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        $url = $base_url + "/product"

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass;
        }

        $proxy_url = Get-Proxy $General
        $params = @{ 'Uri' = $url; 'Method' = 'Get'; 'Headers' = $headers; 'ContentType' = 'application/json' } + $proxy_url
        $response = Invoke-RestMethod @params

        return $response
    }
    catch {
        throw $_.Exception
    }
}

function Get-Order-Id {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    try {
        $transaction_id = $Specific.CertId -split ":"
        $CurrOrderId = $transaction_id[0]
        return $CurrOrderId
    }
    catch {
        $exception = $_.Exception
        if ($exception.Response.StatusCode -eq [system.net.httpstatuscode]::NotFound) {
            return $CurrOrderId
        }
        throw Decode-Error($exception)
    }
}

function Get-Order-Id-From-Cert {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    try {
        $serial_number = Get-Serial-Number-From-PEM $General $Specific

        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        # look up the certificate id using the serial number
        $url = $base_url + "/order/certificate/" + $serial_number

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass;
        }

        $proxy_url = Get-Proxy $General

        $params = @{ 'Uri' = $url; 'Method' = 'Get'; 'Headers' = $headers; 'ContentType' = 'application/json' } + $proxy_url
        $response = Invoke-RestMethod @params

        return $response.id
    }
    catch {
        throw $_.Exception
    }
}

function Get-Serial-Number-From-PEM {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    try {
        $certPem = $Specific.CertPem
        if ([string]::IsNullOrEmpty($certPem)) {
            throw "PEM is not passed from TPP to adaptable script"
        }
        if ($certPem.GetType().Name -eq "String"){
            $certPem = [system.Text.Encoding]::UTF8.GetBytes($Specific.CertPem)
        }
        $certificates = [System.Security.Cryptography.X509Certificates.X509Certificate2Collection]::new()
        $certificates.Import($certPem)
        $count = $certificates.Count
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$certificate = $certificates[$count - 1]
        return $certificate.SerialNumber
    }
    catch {
        throw $_.Exception
    }
}

function Legacy-Order-Lookup {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Current Order ID")]
        [Int]$CurrOrderId
    )
    try {
        $base_url = $General.ServiceAddress
        if ([string]::IsNullOrEmpty($base_url)) {
            $base_url = $global:api_base_url
        }
        
        $url = $base_url + "/oem-migration/" + $CurrOrderId + "/order-id"

        $headers = @{
            "X-DC-DEVKEY" = $General.UserPass;
        }

        $proxy_url = Get-Proxy $General
        $params = @{'Uri' = $url; 'Method' = 'Get'; 'Headers' = $headers; 'ContentType' = 'application/json' } + $proxy_url
        $response = Invoke-RestMethod @params

        return $response.id
    }
    catch {
        $exception = $_.Exception
        if ($exception.Response.StatusCode -eq [system.net.httpstatuscode]::NotFound) {
            return $CurrOrderId
        }
        throw $exception
    }
}

function Decode-Error([Exception] $ex) {
  #  $ex | convertto-json -depth 1 | write-venafidebug
    try {
        $result = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $json = $reader.ReadToEnd() | ConvertFrom-Json
        if ([string]::IsNullOrEmpty($json.errors.message)) {
            return $json.errors.code
        }
        return $json.errors.message
    }
    catch {
        # the response is either not xml or not in the expected format
        return $ex.Message
    }
}
<#
function Write-VenafiDebug {

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
    Write-VenafiDebug -Message 'connected to server'

    Write info to the log

    .EXAMPLE
    $General | Write-VenafiDebug

    Write input parameter values to the log

    .EXAMPLE
    Write-VenafiDebug -Message 'this was not good' -ThrowException

    Write to the log and throw an exception
    

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
#>