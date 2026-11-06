<#
//---------------------------------------------------------------------------
// SwissSign_Adaptable_Script.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2024 Venafi, Inc. All rights reserved.
//
// This software is licensed by SwissSign AG, in addition to Venafi.
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
//
// IN NO EVENT SHALL SWISSSIGN AG, ITS DIRECTORS, OFFICERS, EMPLOYEES,
// AGENTS, OR AFFILIATES BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
// SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS,
// ARISING OUT OF THE USE OF THIS SOFTWARE OR ITS DOCUMENTATION, IF ANY,
// EVEN IF SWISSSIGN AG HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
// SWISSSIGN AG SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A
// PARTICULAR PURPOSE. THIS SOFTWARE, ALONG WITH ITS DOCUMENTATION, IF ANY,
// IS PROVIDED "AS IS". SWISSSIGN HAS NO OBLIGATION TO PROVIDE
// MAINTENANCE, SUPPORT, OR UPDATES FOR THE SOFTWARE OR ITS DOCUMENTATION,
// IF ANY.
//---------------------------------------------------------------------------


Service Address:

 - Production:     https://api.ra.swisssign.ch
 - Pre-Production: https://api.ra.pre.swisssign.ch


Configuration:

 - Find available client name (column "Client") and policy name
   (column "Policy Name") in your SwissSign account at:
   https://ra.swisssign.ch/issue

 - Set ProfileString to "policy-name [client-name]",
   e.g. "SwissSign DV SSL Silver Wildcard [MPKI5000003 - Firma Muster AG]".

 - Alternatively, set ProfileString to policy-name
   (e.g. "SwissSign DV SSL Silver Wildcard") and CustomField "Client"
   to client-name (e.g. "MPKI5000003 - Firma Muster AG").

 - Alternatively (not recommended, see below), set ProfileString to
   product reference (e.g. "pma-123e4567-e89b-12d3-a456-426614174000").


Known Bugs:

 - If setting ProfileString to a inexistent (or disallowed) product
   reference, the test phase will pass but you will get an error while
   submitting the CSR. This is due to the API not providing a way to
   check for correct product references.

 - Error handling: when trying to issue certificates with illegal
   input (e.g. disallowed RDN), we currently simply return the error
   code instead of the full error message from the server: "ERROR:
   Failed to issue certificate: The remote server returned an error:
   (400) Bad Request.". See comment in Submit-CsrAsNew function.


For additional information, refer to Venafi documentation:

https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/c-drivers-AdaptableCA-PowerShell-reference.php

#>

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

function Test-Settings
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    # Note that if General.ProfileString is a product reference
    # (pma_uuid), there is no way of checking this.
    $headers = Get-AuthHeaders $General
    $pma_uuid = Get-ProductReference $General $headers

    return @{ Result = "Success" }
}

function Get-ChainCertificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    # This is not possible without an order reference
    return @{ Result = "NotUsed" }
}

function Prepare-ForRequest
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed" }
}

function Submit-CsrAsNew
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    try {
        $headers = Get-AuthHeaders $General
        $pma_uuid = Get-ProductReference $General $headers

        $uri = "{0}/v2/issue/csr/{1}" -f $General.ServiceAddress, $pma_uuid
        $body = $Specific.Pkcs10
        $resp = Invoke-WebRequest -Uri $uri -Method "POST" -ContentType "text/plain" -Headers $headers -Body $body
        $json = $resp.Content | ConvertFrom-Json
    } catch {
        # It is not possible to get $resp.content if the request
        # failed (the RA API provides an errorMessage in case of 400
        # bad request). The internet suggests to use
        # System.Net.WebRequest, but this does not seems adequate here.
        throw "Failed to issue certificate: " + $_.Exception.Message
    }

    $ord_uuid = $json.uuid
    if ($DEBUG_FILE) {
        "$(Get-Date) certificate order uuid=$ord_uuid status=" + $json.status | Out-File $DEBUG_FILE -Append
    }

    if ([string]::IsNullOrEmpty($ord_uuid)) {
        throw "Unexpected response from issue certificate: missing uuid"
    }

    return @{ Result = "Success"; TransId = $ord_uuid }
}

function Retrieve-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    # from Submit-CsrAsNew -> TransId
    $ord_uuid = $Specific.CertId

    try {
        $uri = "{0}/v2/order/{1}" -f $General.ServiceAddress, $ord_uuid
        $headers = Get-AuthHeaders $General
        $resp = Invoke-WebRequest -Uri $uri -Method "POST" -ContentType "application/json" -Headers $headers
        $json = $resp.Content | ConvertFrom-Json
    } catch {
        throw "Failed to fetch certificate order information: " + $_.Exception.Message
    }

    if ($DEBUG_FILE) {
        "$(Get-Date) certificate order uuid=$ord_uuid status=" + $json.status | Out-File $DEBUG_FILE -Append
    }

    $status = $json.status
    if ($status -eq "ISSUED") {
        $chain_base64 = $json.certificateChain
        $certs = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
        foreach ( $item in $chain_base64 ) {
            $certs.Import([Convert]::FromBase64String($item))
        }
        # NOTE: leaf cert is included in chain
        #$cert_base64  = $json.certificate.certificate
        #$certs.Import([Convert]::FromBase64String($cert_base64))
        if ($DEBUG_FILE) {
            "$(Get-Date) retrieved cert and chain:" | Out-File $DEBUG_FILE -Append
            $certs | Out-File $DEBUG_FILE -Append
        }
        $bytes = $certs.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
        return @{ Result = "Success"; Status = "Issued"; PKCS7 = $bytes }
    }
    if (@('REVOKED', 'FAILED', 'REJECTED', 'UNKNOWN') -contains $status) {
        throw "Unexpected certificate status: " + $status
    }
    # All other stati are regarded as pending:
    # NEW, KEY_VALIDATION, PRE_VALIDATION, GENERATE_TBS, PENDING_AUTH,
    # PRE_ISSUE, ISSUE, POST_VALIDATION, FINALIZE_ISSUANCE,
    # PENDING_CSR_RENEWAL
    return @{ Result = "Success"; Status = "Pending" }
}

function Revoke-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $reason = @{
        0 = "UNUSED";
        1 = "KEY_COMPROMISE";
        3 = "AFFILIATION_CHANGED";
        4 = "SUPERSEDED";
        5 = "CESSATION_OF_OPERATION"
    }[$Specific.ReasonCode]
    if ( -not $reason ) {
        throw "Illegal revocation reason code: " + $Specific.ReasonCode
    }

    $cert_pem = ([string]$Specific.CertPem).Replace("-----BEGIN CERTIFICATE-----", "").Replace("-----END CERTIFICATE-----", "")
    $cert_bytes = [Convert]::FromBase64String($cert_pem)
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(, $cert_bytes)

    if ($DEBUG_FILE) {
        "$(Get-Date) revoke issuer='" + $cert.Issuer + "' serial=" + $cert.SerialNumber + " reason=" + $reason | Out-File $DEBUG_FILE -Append
    }

    try {
        $uri = "{0}/v2/revoke" -f $General.ServiceAddress
        $body = ConvertTo-Json @( @{
            serialNumber     = $cert.SerialNumber;
            issuerName       = $cert.Issuer;
            revocationReason = $reason
        } )
        $headers = Get-AuthHeaders $General
        $resp = Invoke-RestMethod -Uri $uri -Method "POST" -ContentType "application/json" -Headers $headers -Body $body
    } catch {
        throw "Failed to revoke certificate: " + $_.Exception.Message
    }
    # There is no way to print warnings. RA API documentation states
    # that this API call returns 204, but certificate will probably be
    # revoked for all non-error codes.
    #if ($resp.StatusCode -ne "204") {
    #    throw "Unexpected status=" + $resp.StatusCode + " from certificate revocation: issuer='" + $cert.Issuer + "', serial=" + $cert.SerialNumber
    #}
    return @{ Result = "Success" }
}

function Prepare-ForRequest
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed" }
}

function Submit-CsrAsRenewal
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return Submit-CsrAsNew $General $Specific
}

function Submit-CsrAsReplacement
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return Submit-CsrAsNew $General $Specific
}

function Approve-Request
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="NotUsed" }
}


###
### Helper functions
###

function Get-AuthToken
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    try {
        # NOTE: This call does NOT fail on wrong credentials, it
        # merely provides a lazy way of creating a jwt token.
        $uri = "{0}/v2/jwt/{1}" -f $General.ServiceAddress, $General.UserName
        $body = "userSecret=" + $General.UserPass
        $headers = @{ Accept = "text/plain" }
        $resp = Invoke-WebRequest -Uri $uri -Method "POST" -ContentType "application/x-www-form-urlencoded" -Headers $headers -Body $body
        $token = $resp.Content
    } catch {
        throw "Failed to fetch authentication token: " + $_.Exception.Message
    }
    if ([string]::IsNullOrWhiteSpace($token)) {
        throw "Unexpected response from auth token request: no data"
    }
    return $token
}

function Get-AuthHeaders
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    $token = Get-AuthToken $General
    return @{
        Authorization = "Bearer {0}" -f $token;
        Accept = "application/json"
    }
}

# If ProfileString is a product reference, return it.
# If ProfileString is "policy-name [client-name]", or ProfileString is
# policy-name and CustomField[Client] is client-name, search for
# product reference using API.
function Get-ProductReference
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Auth Headers")]
        [System.Collections.Hashtable]$AuthHeaders
    )

    if ($General.ProfileString -match '^pma-[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$') {
        $pma_uuid = $General.ProfileString
        if ($DEBUG_FILE) {
            "$(Get-Date) Identified ProfileString as product reference uuid=$pma_uuid" | Out-File $DEBUG_FILE -Append
        }
        return $pma_uuid
    }
    if ($General.ProfileString -match '^(.*)\s*\[(.*)\]$') {
        $product_name = ($Matches.1).Trim()
        $client       = ($Matches.2).Trim()
        if ($DEBUG_FILE) {
            "$(Get-Date) Identified ProfileString as product='$product_name' and client='$client'" | Out-File $DEBUG_FILE -Append
        }
    }
    elseif ( -not [string]::IsNullOrEmpty($General.ProfileString) ) {
        $product_name = $General.ProfileString
        $client       = $General.CustomFields.Get_Item("Client");
        if ([string]::IsNullOrEmpty($client)) {
            throw 'Missing client name. Either specify ProfileString="policy-name [client-name]", or set ProfileString to policy-name and CustomField "Client" to client-name'
        }
        if ($DEBUG_FILE) {
            "$(Get-Date) Identified ProfileString as product='$product_name', and CustomField Client='$client'" | Out-File $DEBUG_FILE -Append
        }
    }
    else {
        throw 'Missing ProfileString. Please specify ProfileString="policy-name [client-name]"'
    }

    # Use first product matching product_name
    try {
        if ($AuthHeaders) {
            $headers = $AuthHeaders
        } else {
            $headers = Get-AuthHeaders $General
        }
        $uri = "{0}/v2/clients?search={1}" -f $General.ServiceAddress, [uri]::EscapeDataString($client)
        $resp = Invoke-WebRequest -Uri $uri -Method "POST" -ContentType "application/json" -Headers $headers
        $json = $resp.Content | ConvertFrom-Json
    } catch {
        throw "Failed to fetch client information: " + $_.Exception.Message
    }
    if ($json.count -eq 0) {
        throw "Unknown client '$client'"
    }

    $pma_uuid = ($json.products | Where-Object productName -eq $product_name | Select-Object uuid).uuid

    if ($DEBUG_FILE) {
        "$(Get-Date) Client search: product='$product_name' client='$client' --> product_reference=$pma_uuid" | Out-File $DEBUG_FILE -Append
    }

    if ([string]::IsNullOrEmpty($pma_uuid)) {
        throw "Failed to find product '$product_name' for client '$client'"
    }

    return $pma_uuid
}
