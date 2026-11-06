<#
//---------------------------------------------------------------------------
// Nameshield.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2025 Venafi, Inc. All rights reserved.
//
// This software is licensed by Nameshield, in addition to Venafi.
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
    "Validating Settings :" | Write-DebugLog
    try {
        $response = Request-Nameshield -General $General -EndpointPath "/organizations" -HttpMethod "GET"

        "Test-Settings Result:" | Write-DebugLog
        $responsetext = $response.Content | ConvertFrom-Json
        $responsetext | Write-DebugLog

         if ( $response.StatusCode -eq 200 ) {
            return @{ 'Result' = 'Success' }
        }
        else {
            throw $response.Content
        }
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

    "Submit-CsrAsNew Settings :" | Write-DebugLog
    Request-Certificate -General $General -Specific $Specific -Action "create"
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

    "Submit-CsrAsRenewal Settings :" | Write-DebugLog
    Request-Certificate -General $General -Specific $Specific -Action "renew"
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

    "Submit-CsrAsReissue Settings :" | Write-DebugLog
    Request-Certificate -General $General -Specific $Specific -Action "reissue"
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

    "Retrieve-Certificate Settings :" | Write-DebugLog

    $Specifictext = $Specific | ConvertTo-Json
    "Specific :" | Write-DebugLog
    $Specifictext | Write-DebugLog

    $OrderId = $Specific.CertId
    "OrderID" | Write-DebugLog
    $OrderId | Write-DebugLog

    try {
        $endpointPath = "/orders/$OrderId/certificate?fields[certificate][]=status&fields[certificate][]=pkcs7"

        $response = Request-Nameshield -General $General -EndpointPath $endpointPath -HttpMethod "GET"

        "Response Result :" | Write-DebugLog
        $response | Write-DebugLog

        $certdetails = $response.content | ConvertFrom-Json
        $certstatus = $certdetails.data.attributes.status
        "Certificate Status" | Write-DebugLog
        $certstatus | Write-DebugLog

        if ( $certstatus -eq 'active') {

            # As the cert status is active, we are going to retrieve it
            $certid = $certdetails.data.id
            "Certificate ID:" | Write-DebugLog
            $certid | Write-DebugLog

            "Retrieve Cert Result :" | Write-DebugLog
            $cert | Write-DebugLog

            # Checking there is cert data to retrieve
            if ( $null -ne $certdetails.data.attributes.pkcs7 ) {
                "Certificate in PEM Format:" | Write-DebugLog
                $certdetails.data.attributes.pkcs7 | Write-DebugLog
 
                $cert_AsbyteArray = [System.Text.Encoding]::UTF8.GetBytes($certdetails.data.attributes.pkcs7)

                return @{
                    Result  = 'Success'
                    Status = 'Issued'
                    TransId = $certid
                    Pkcs7 = $cert_AsbyteArray
                }
            }
        }
        else {
            # If the certificate status is not active, we are setting it to pending so TPP can try to retrieve it later, there may be a better way to do that or more checks as teh status can be
            if ( $certstatus -eq 'active') {
                return @{
                    Result = 'Success'
                    Status = 'Pending'
                }
            } else {
                throw 'certificate is ' + $certstatus
            }
        }
    }
    catch {
        # Write-DebugLog($_ | ConvertTo-Json -Depth 2)
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

    "Revoke-Certificate Settings :" | Write-DebugLog

    $Specifictext = $Specific | ConvertTo-Json
    "Specific :" | Write-DebugLog
    $Specifictext | Write-DebugLog
    
    $certdata = $Specific.CertPem
    
    if(-not ($certdata.StartsWith("-----BEGIN CERTIFICATE-----"))) {
        $certdata = "-----BEGIN CERTIFICATE-----`n" + $certdata + "`n-----END CERTIFICATE-----"
    }
    
    $cleanX509String = $certdata -replace "\r\n", ""

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($cleanX509String)
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($bytes)

    $Serial = $cert.SerialNumber
    "Certificate Serial Number:" | Write-DebugLog
    $Serial | Write-DebugLog

    try{

        $pathEndpoint = "/certificates/" + $Serial + "/revoke"
        $response = Request-Nameshield -General $General -EndpointPath $pathEndpoint -HttpMethod "POST"

        "Response:" | Write-DebugLog
        $responsetext = $response.Content | ConvertFrom-Json
        $responsetext | Write-DebugLog

        "Revocation Status:" | Write-DebugLog
        $revocationstatus = $responsetext.data.attributes.status
        $revocationstatus | Write-DebugLog

        if ($revocationstatus -eq 'REVOKE_REQUESTED') {
            return @{
                Result = 'Success'
            }
        }
        else {
            # something unexpected
            $response | convertto-json | Write-VenafiDebug
            return $response
        }
    }
    catch {
        Write-DebugLog($_ | ConvertTo-Json -Depth 2)
        throw Format-Error($_.Exception)

        if ( $_.ErrorDetails.Message ) {
           throw $_.ErrorDetails.Message
        }
        else {
            throw $_.Exception.Message
        }
    }
}


<##################################################################################################
.NAME
    Import-Certificates
.DESCRIPTION
    Imports certificates from Nameshield portfoliuo
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserPass: string value of the password credential that holds the Nameshield API Key
        ServiceAddress: URI, IP address or FQDN of the service you want to connect to
        ProfileString: String, can be delimited, which identifies product or profile associated with the service
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        IncludeRevoked : boolean value indicating whether the job says to include revoked certificates
        IncludeExpired : boolean value indicating whether the job says to include expired certificates
        LastJobStarted : datetime value that indicates when the previous import job started
        LastProcessedId : string value with the ID of the last certificate that was previously imported by the job
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state. 'Incomplete' to re-run method later
        Certificates: A hashtable containing certificate data
            Name : (required) identifier that will appear in log event if certificate fails to import
            PEM : (required) the raw certificate in PEM format
            ContactEmail : the email address of the certificate contact
            TransactionId : the unique DigiCert ID of the certificate
            Attributes : A hashtable of additional attributes to set when importing the certificate
        LastProcessedId : string value with the ID of the last certificate in the Certificates hash table
		RunAfter : Number of hours after which script will be executed again
##################################################################################################>

function Import-Certificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    "Trying to Import Certificates" | Write-DebugLog

    $Specifictext = $Specific | ConvertTo-Json
    "Specific :" | Write-DebugLog
    $Specifictext | Write-DebugLog

    $uri = $General.ServiceAddress + "/certificates?fields[certificate][]=x509&fields[certificate][]=status&fields[certificate][]=common_name&filter[status][]=active"

    if ($Specific.IncludeRevoked) {
        $uri += "&filter[status][]=revoked"
    }
    if ($Specific.IncludeExpired) {
        $uri += "&filter[status][]=expired"
    }
    "URI :" | Write-DebugLog
    $uri | Write-DebugLog

    $bearerToken = $General.UserPass
    $OAuth = "Bearer $BearerToken"

    $headers = @{
        Authorization = $OAuth
    }

    $certificates = @()
    try {
        "Try to list certificate" | Write-DebugLog
        "Command to be sent :" | Write-DebugLog
        Write-Output "Invoke-WebRequest -Usebasicparsing $uri -Method 'Get' -Headers ****" | Write-DebugLog

        do {
            $ListCert = Invoke-WebRequest -Usebasicparsing $uri -Method 'Get' -Headers $headers

            "Result :"| Write-DebugLog
            $ListCert | Write-DebugLog

            $Certlist = $ListCert.Content | ConvertFrom-Json
            $CertlistData = $Certlist.data


            $i=0
            Foreach ($number in $CertlistData.id) {
                $certid = $number
                "CertID :" | Write-DebugLog
                $certid | Write-DebugLog

                $certdata = $CertlistData[$i].attributes.x509
                $cn = $CertlistData[$i].attributes.common_name

                $certificates += @{
                    Name=[string]$certid."_".$cn;;
                    PEM=[String]$certData;
                    TransactionId=[string]$certid;
                }
                $i = $i + 1
            }
            $uri = $Certlist.links.next
            $uri | Write-DebugLog
        } while( $null -ne $uri )

    }
    catch {
        Write-DebugLog($_ | ConvertTo-Json -Depth 2)
        throw Format-Error($_.Exception)
    }
    return @{
                Result = "Success"; Certificates=$certificates;
            }

}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

<##################################################################################################
.NAME
    Request-Certificate
.DESCRIPTION
    Send request to order a certificate (new, renew or reissue).
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
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        Pkcs10: the Base64-encoded PKCS#10-formatted certificate signing request (CSR) to be enrolled
        CertId: a string that uniquely identifies the certificate issued by the CA to be renewed or reissued. If operation is new, value should be empty.
.PARAMETER Action
    A string indicate with type of request (new, renew or reissue)
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        TransId: the identifier used to subsequently retrieve the certificate from the CA (Order Id)
##################################################################################################>
function Request-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific,
        [Parameter(Mandatory = $true, HelpMessage = "Action")]
        [string] $Action
    )

    $Specifictext = $Specific | ConvertTo-Json
    "Specific :" | Write-DebugLog
    $Specifictext | Write-DebugLog

    $csr=$Specific.Pkcs10 -replace "`n","" -replace "`r",""

    "CSR after replace:" | Write-DebugLog
    $csr | Write-DebugLog

    $attributestxt = "`"action`":`""+$Action+"`",`"csr`":`"" + $csr + "`",`"duration`":`"1 year`""
    if ( $General.CustomFields.scopeNms ) {
        $attributestxt = $attributestxt + ",`"customer_id`":" + $General.CustomFields.scopeNms
    }

    if ( $General.CustomFields.analyticalAccount ) {
        $attributestxt = $attributestxt + ",`"ca`":`"" + $General.CustomFields.analyticalAccount +"`""
    }

    $producttxt = "`"data`":`{`"id`":`"" + $General.ProfileString + "`"`}"
    $organizationtxt = "`"data`":`{`"id`":`""+$General.CustomFields.organization+"`"`}"
    if("create" -eq $action) {
        $relationshipstxt = "`"organization`":`{" + $organizationtxt + "`},`"product`":`{" + $producttxt + "`}"
    } else {
        $CertID = $Specific.CertId
        $certificatetxt = "`"data`":`{`"id`":`"" + $CertId + "`"`}"
        $relationshipstxt = "`"organization`":`{" + $organizationtxt + "`},`"product`":`{" + $producttxt + "`},`"certificate`":`{" + $certificatetxt + "`}"
    }

    $Form = "`{`"data`":`{`"relationships`":`{" + $relationshipstxt + "`},`"attributes`":`{" + $attributestxt + "`}`}`}"

    try {
        $response = Request-Nameshield -General $General -EndpointPath "/orders" -HttpMethod "POST" -Body $Form

        if ( $response.StatusCode -eq 201 ) {
            $responsedata = $Response.Content | ConvertFrom-Json
            "Response Data :" | Write-DebugLog
            $responsedata | Write-DebugLog
            "Transaction ID:" | Write-DebugLog
            $responsedata.data.id | Write-DebugLog

            # Adding a waiting timer as if the request is successfull, we try to retrieve straight away, and NameShield server answers with a 404 not found
            "Start waiting" | Write-DebugLog
            Start-Sleep -Seconds 15
            "Continue with script" | Write-DebugLog

            return @{
                Result  = 'Success'
                TransId = $responsedata.data.id
                }
        }
    }
    catch {
        Write-DebugLog($_ | ConvertTo-Json -Depth 2)
        throw Format-Error($_.Exception)
    }

}



<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

<##################################################################################################
.NAME
    Request-Nameshield
.DESCRIPTION
    Send request to any Nameshield endpoint
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
.PARAMETER EndpointPath
    A string with the endpoint path to add to serviceAdress. Used to identify required service
.PARAMETER HttpMethod
    A string indicate the type of Http request (GET, POST, ...)
.PARAMETER Body
    Optionnal parameter used in some case like POST requests.
.NOTES
    Returns a response of WebRequest (BasicHtmlWebResponseObject)
##################################################################################################>
function Request-Nameshield {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable] $General,
        [Parameter(Mandatory = $true, HelpMessage = "endPoint Path")]
        [string] $EndpointPath,
        [Parameter(Mandatory = $true, HelpMessage = "http Method")]
        [string] $HttpMethod,
        [Parameter(Mandatory = $false, HelpMessage = "Body")]
        [string] $Body
    )
    $uri = $General.ServiceAddress + $endpointPath
    "URI :" | Write-DebugLog
    $uri | Write-DebugLog

    $BearerToken = $General.UserPass

    try {
        $OAuth = "Bearer $BearerToken"

        $headers = @{
            Authorization = $OAuth
        }

        "Command to be sent :" | Write-DebugLog
        if ($Body ) {
            Write-Output "Invoke-WebRequest -Usebasicparsing $uri -Method $HttpMethod -Headers **** -Body $Body -ContentType 'application/json'" | Write-DebugLog
            $response = Invoke-WebRequest -Usebasicparsing $uri -Method $HttpMethod -Headers $headers -Body $Body -ContentType 'application/json'
        } else {
            Write-Output "Invoke-WebRequest -Usebasicparsing $uri -Method $HttpMethod -Headers **** " | Write-DebugLog
            $response = Invoke-WebRequest -Usebasicparsing $uri -Method $HttpMethod -Headers $headers
        }

        return $response
    }
    catch {
        throw Format-Error($_.Exception)
    }
}

function Write-DebugLog {
    [cmdletbinding()]
    Param(
        [parameter(ValueFromPipeline)]
        [string]$message
    )

    Process {
        if ($DEBUG_FILE) {
            "$(Get-Date): $message" | Out-File $DEBUG_FILE -Append
        }
    }
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