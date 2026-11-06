<#
//---------------------------------------------------------------------------
// Crypto4A_Adaptable_CA.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by Crypto4A, in addition to Venafi.
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

#$global:base_url = "https://klondike3.crypto4a.com:8443/ca"
$global:base_url = "http://klondike3.crypto4a.com:8002/ca"
$global:validity_years = 1
$global:signature_hash = "sha256"

$base_path = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs"
$global:file_prefix = $base_path + "\SPACaDebug_"

$global:ca_authority_name = "hss-ca"
$global:host = "klondike3.crypto4a.com"

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
function Test-Settings
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    try
    {
        $url = $global:base_url + "/getConfiguredAuthorities"
        $headers = @{
            "apikey"=$General.UserPass;
            "Host"=$global:host;
            "Accept"="application/json"
        }
        Invoke-RestMethod -Uri $url -Method Post -Headers $headers -ContentType "application/json"
        return @{ Result="Success" }
    }
    catch
    {
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
function Submit-CsrAsNew
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    try
    {
        # submit a CSR for enrollment
        $url = $global:base_url + "/signCertificateJSON"
        $headers = @{
            "Host"=$global:host;
            "apikey"=$General.UserPass;
            "Accept"="application/json"
        }

        $csr = Fix-CSRHeader($Specific.Pkcs10)
        $body = @{
            name=$global:ca_authority_name;
            csr=$csr;
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"

        # Transaction ID shall include both Order ID and Request ID
        $serial_id = $response.serialNumber.ToString()
        return @{ Result="Success";TransId=$serial_id }
    }
    catch
    {
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
function Submit-CsrAsRenewal
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $cert_id = $Specific.CertId
    $csr = $csr = Fix-CSRHeader($Specific.Pkcs10)
    try
    {
        # submit a CSR for enrollment
        $url = $global:base_url + "/certificate/" + $cert_id + "/renew"
        $headers = @{
            "Host"=$global:host;
            "apikey"=$General.UserPass;
            "Accept"="application/json"
        }

        $body = @{
            name=$global:ca_authority_name;
            csr = $csr;
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body -ContentType "application/json"

        $transaction_id = $response.serialNumber.ToString()
        return @{ Result="Success";TransId=$transaction_id }
    }
    catch
    {
        $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
        $csr | Out-File $file
        $_ | Out-File $file -Append
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
function Submit-CsrAsReplacement
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $cert_id = $Specific.CertId
    $csr = $csr = Fix-CSRHeader($Specific.Pkcs10)

    try
    {
        # submit a CSR for reissuance
        $url = $global:base_url + "/certificate/" + $cert_id + "/reissue"
        $headers = @{
            "Host"=$global:host;
            "apikey"=$General.UserPass;
            "Accept"="application/json"
        }

        $body = @{
            name=$global:ca_authority_name;
            csr=$csr
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body -ContentType "application/json"

        $transaction_id = $response.serialNumber.ToString()
        return @{ Result="Success";TransId=$transaction_id }
    }
    catch
    {
        $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
        $_ | Out-File $file
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
function Approve-Request
{
    return @{ Result="Success" }
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
function Retrieve-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $cert_id = $Specific.CertId

    try
    {
        # look up the certificate id using the order id
        $url = $global:base_url + "/certificate/" + $cert_id

        $headers = @{
            "Host"=$global:host;
            "apikey"=$General.UserPass;
            "Accept"="application/json"
        }

        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json"
        $cert_str = $response.certificate

        $enc = [system.Text.Encoding]::UTF8
        $bytes = $enc.GetBytes($cert_str)
        return @{ Result="Success";Status="Issued";PKCS7=$bytes }
    }
    catch
    {
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
function Revoke-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $cert_id = $Specific.CertId
    $reason = $Specific.ReasonCode
    try
    {
        # revoke the certificate
        $url = $global:base_url + "/certificate/" + $cert_id + "/" + $reason + "/revoke"

        $headers = @{
            "Host"=$global:host;
            "apikey"=$General.UserPass;
            "Accept"="application/json"
        }

        Invoke-RestMethod -Uri $url -Method Put -Headers $headers -ContentType "application/json"

        return @{ Result="Success" }
    }
    catch
    {
        throw Decode-Error($_.Exception)
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Decode-Error( [Exception] $ex )
{
    try
    {
        $result = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $json = $reader.ReadToEnd() | ConvertFrom-Json
        return $json.errors.message
    }
    catch # the response is either not xml or not in the expected format
    {
        return $ex.Message
    }
}

# SPA CA only support standard PEM header "BEGIN CERTIFICATE REQUEST", and
# PEM footer "END CERTIFICATE REQUEST". However, $Specific.Pkcs10 uses the
# non-standard "BEGIN NEW CERTIFICATE REQUEST" and "END NEW CERTIFICATE REQUEST".
# We need to remove the "NEW" from the header and footer.
function Fix-CSRHeader( $Pkcs10 )
{
    $csr = $Pkcs10.Replace("NEW ","")
    return $csr
}
