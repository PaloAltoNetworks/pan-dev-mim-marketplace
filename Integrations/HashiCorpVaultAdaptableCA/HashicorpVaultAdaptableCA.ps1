<#
//-----------------------------------------------------------------------
// HashiCorp Vault CA.ps1
//
// Copyright (c) 2019 Venafi, Inc.  All rights reserved.
//
// This sample script and its contents are provided by Venafi to customers
// and authorized technology partners for the purposes of integrating with
// services and platforms that are not owned or supported by Venafi.  Any
// sharing of this script or its contents without consent from Venafi is
// prohibited.
//
// This sample is provided "as is" without warranty of any kind.
//-----------------------------------------------------------------------
//
// This sample assumes a Vault that contains both a root and issuing CA
// for the purposes of obtaining certificates for the full chain.
//
// The Adaptable CA template for this script requires a Username
// credential that specifies the Vault Token it will use to authenticate
// with the Vault as its password (the username portion does not matter).
//-----------------------------------------------------------------------
#>

$vault_url = "http://172.31.18.32:8300/v1"
$vault_root_path = "pki"
$vault_issuer_path = "pki_int"
$vault_issuer_role = "example-dot-com"
$vault_key_gen = $false 


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
        AuxUser : a username paired with AuxPass for secondary authentication purposes
        AuxPass : the password for the AuxUser (username credential), AuxPfxData (certificate credential), or independent (password credential)
        AuxPfxData : a PKCS#12 containing client certificate and private key for secondary authentication purposes
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
        $headers = @{ "Content-Type"="application/json"; "X-Vault-Token"=$General.UserPass }
        $uri = "{0}/{1}/roles/{2}" -f $vault_url,$vault_issuer_path,$vault_issuer_role
        Invoke-WebAPI -RestMethod -Method GET -Uri $uri -Headers $headers -UseBasicParsing

        Done-Normal @{ Result="Success" }
        return
    }
    catch
    {
        throw ((Done-Abnormal $_).ErrorDetails.Message | ConvertFrom-Json).errors
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

    try
    {
        $certs = @()

        $uri = "{0}/{1}/ca/pem" -f $vault_url,$vault_root_path
        $result = Invoke-WebAPI -Method GET -Uri $uri -UseBasicParsing
        $certs += ([Text.Encoding]::ASCII.GetString($result.Content))

        $uri = "{0}/{1}/ca/pem" -f $vault_url,$vault_issuer_path
        $result = Invoke-WebAPI -Method GET -Uri $uri -UseBasicParsing
        $certs += ([Text.Encoding]::ASCII.GetString($result.Content))

        $bytes = [byte[]](Convert-PemCertToPkcs7 -Pems $certs)

        Done-Normal @{ Result="Success"; Pkcs7=$bytes }
        return
    }
    catch
    {
        throw (Done-Abnormal $_).Exception
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
function Prepare-ForRequest
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Done-Normal @{ Result="NotUsed" }
    return
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
    Returns a hashtable that includes the following variables
        Result : 'Success' to indicate the non-error completion state; this function is required
        TransId : the identifier used to subsequently approve and/or retrieve the certificate from the CA
        Pkcs7 : a collection that includes the issued certificate and optionally includes all of the CA certificates in the chain
Pkcs12 : a collection that includes the issued certificate, its private key, and optionally all of the CA certificates in the chain
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

    try # Vault API calls will throw an exception if the request is rejected
    {
        if ( $vault_key_gen )
        {
            $cn = $Specific.SubjectDN.CN

            # ensure sans are always expressed as string arrays
            $sans_dns = @() + $($Specific.SubjAltNames.DNS | ? {$_})
            $sans_ip = @() + $($Specific.SubjAltNames.IP | ? {$_})
            $sans_uri = @() + $($Specific.SubjAltNames.URI | ? {$_})
            $sans_upn = (@() + $($Specific.SubjAltNames.UPN | ? {$_})) | % { "1.3.6.1.4.1.311.20.2.3;UTF8:$_" }

            $headers = @{ "Content-Type"="application/json"; "X-Vault-Token"=$General.UserPass }
            $uri = "{0}/{1}/issue/{2}" -f $vault_url,$vault_issuer_path,$vault_issuer_role

            $body = @{
                "common_name" = $cn;
                "alt_names" = $sans_dns -join ",";
                "ip_sans" = $sans_ip -join ",";
                "uri_sans" = $sans_uri -join ",";
                "other_sans" = $sans_upn -join ",";
                "private_key_format" = "pkcs8"
            } | ConvertTo-Json

            $result = Invoke-WebAPI -RestMethod -Method POST -Uri $uri -Body $body -Headers $headers -UseBasicParsing

            $cert = [byte[]](Convert-PemCertToPkcs7 -Pems @(,$result.data.certificate))
            $key = $result.data.private_key

            Done-Normal @{ Result="Success"; TransId=$result.data.serial_number; Pkcs7=$cert; PrivKeyPem=$key }
            return
        }
        else
        {
            $headers = @{ "Content-Type"="application/json"; "X-Vault-Token"=$General.UserPass }
            $uri = "{0}/{1}/sign/{2}" -f $vault_url,$vault_issuer_path,$vault_issuer_role
            $body = @{
                "csr"=$Specific.Pkcs10
            } | ConvertTo-Json
            $result = Invoke-WebAPI -RestMethod -Method POST -Uri $uri -Body $body -Headers $headers -UseBasicParsing

            $cert = [byte[]](Convert-PemCertToPkcs7 -Pems @(,$result.data.certificate))

            Done-Normal @{ Result="Success"; TransId=$result.data.serial_number; Pkcs7=$cert }
            return
        }
    }
    catch
    {
        throw ((Done-Abnormal $_).ErrorDetails.Message | ConvertFrom-Json).errors
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

    return Submit-CsrAsNew -general $General -specific $Specific
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

    return Submit-CsrAsNew -general $General -specific $Specific
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
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Done-Normal @{ Result="NotUsed" }
    return
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

    Done-Normal @{ Result="NotUsed" }
    return
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

    try # this call with throw an exception if revocation fails
    {
        $headers = @{ "Content-Type"="application/json"; "X-Vault-Token"=$General.UserPass }
        $uri = "{0}/{1}/revoke" -f $vault_url,$vault_issuer_path
        $body = @{ "serial_number"=$Specific.CertId } | ConvertTo-Json
        $null = Invoke-RestMethod -Method POST -Uri $uri -Body $body -Headers $headers -UseBasicParsing

        Done-Normal @{ Result="Success" }
        return
    }
    catch
    {
        throw ((Done-Abnormal $_).ErrorDetails.Message | ConvertFrom-Json).errors
    }
}


<##################################################################################################
.NAME
    Import-Certificates
.DESCRIPTION
    Imports PEM formatted certificates and private keys into Trust Protection Platform
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings minus CertObjDN and CustomFields)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        IncludeRevoked : whether to include revoked certificates
        IncludeExpired : whether to include expired certificates
        LastJobStarted : datetime value that indicates when the previous import job started
        LastProcessedId : string value with the ID of the last certificate that was previously imported by the job
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Certificates: A hashtable containing certificate/key data
            CustomName: Sets the name of certificate object in Policy tree
            ContactEmail: Contact email address; resolve to identity and assigned as the Contact if possible, otherwise value is assigned to Internet Email Address attribute
            TransactionId: Unique ID of the CA transaction needed for renewal/replacement/revocation
            Name: PEM file name (required)
            PEM: PEM file content (required)
            RevocationDate: Certificate revocation date
            Attributes: A hashtable of Config attribute values to assign to the Certificate object
            CustomFields: A hashtable of Custom Fields values to assign to the Certificate object
        LastProcessedId : string value with the ID of the last certificate in the Certificates hash table
        RunAfter : Number of hours after which script will be executed again
##################################################################################################>
function Import-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $certs = @()
    $headers = @{ "X-Vault-Token" = $General.UserPass }

    # the Vault REST method for listing certificates uses a non-standard
    # verb (LIST) so we can't use Invoke-RestMethod to execute it

    try
    {
        Add-Type -AssemblyName System.Net.Http

        $client = New-Object System.Net.Http.HttpClient
        $msg = New-Object System.Net.Http.HttpRequestMessage
        $msg.Method = "LIST"
        $msg.RequestUri = "{0}/{1}/certs" -f $vault_url,$vault_issuer_path
        $msg.Headers.Add("X-Vault-Token", $headers.'X-Vault-Token')

        $resp = $client.SendAsync($msg)
        while (-not $resp.AsyncWaitHandle.WaitOne(200)) { }
        $null = $resp.GetAwaiter().GetResult()

        $result = $resp.Result.Content.ReadAsStringAsync().Result | ConvertFrom-Json

        foreach ( $key in $result.data.keys )
        {
            $uri = "{0}/{1}/cert/{2}" -f $vault_url,$vault_issuer_path,$key
            $resp = Invoke-WebAPI -RestMethod -Method GET -Uri $uri -Headers $headers -UseBasicParsing

            $certs += @{ Name=$key; PEM=$resp.data.certificate }
        }
    }
    catch
    {
        throw (Done-Abnormal $_).Exception
    }

    Done-Normal @{ Result="Success"; Certificates=$certs }
    return
}


<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Convert-PemCertToPkcs7( [string[]] $Pems )
{
    $header = "-----BEGIN CERTIFICATE-----"
    $footer = "-----END CERTIFICATE-----"
    $certs = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection

    foreach ( $pem in $Pems )
    {
        $raw = $pem.Replace($header,"").Replace($footer,"")
        $bytes = [System.Convert]::FromBase64String($raw)
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$bytes)
        $certs.Add($cert) | Out-Null
    }

    return $certs.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE SUPPORT DEBUG LOGGING ##########>

function Invoke-WebAPI
{
param(
        [parameter(position=0, mandatory=$false)]
        [switch] $RestMethod,
        [parameter(position=1, mandatory=$true)]
        [string] $Method,
        [parameter(position=2, mandatory=$true)]
        [string] $Uri,
        [parameter(position=3, mandatory=$false)]
        [Collections.Hashtable] $Headers,
        [parameter(position=4, mandatory=$false)]
        [string] $Body,
        [parameter(position=5, mandatory=$false)]
        [string] $ContentType,
        [parameter(position=6, mandatory=$false)]
        [Security.Cryptography.X509Certificates.X509Certificate2] $Certificate,
        [parameter(position=7, mandatory=$false)]
        [switch] $UseBasicParsing
    )

$params = @{ Method=$Method; Uri=$Uri }

    if ( $DEBUG_FILE )
    {
        "".PadLeft(80,"_") | Out-File $DEBUG_FILE -Append
        "$(Get-Date) - $Method $Uri" | Out-File $DEBUG_FILE -Append
    }

    if ( $Headers )
    {
        if ( $DEBUG_FILE )
        {
            "[Headers]" | Out-File $DEBUG_FILE -Append
            $headers.GetEnumerator() | % { "{0}: {1}" -f $_.Name,$_.Value } | Out-File $DEBUG_FILE -Append
        }
        $params.Add( "Headers", $Headers )
    }

if ( $ContentType )
    {
        if ( $DEBUG_FILE ) { "Content-Type: {0}" -f $ContentType | Out-File $DEBUG_FILE -Append }
        $params.Add( "ContentType", $ContentType )
    }

    if ( $Certificate )
    {
        if ( $DEBUG_FILE )
        {
            "[Client Certificate]" | Out-File $DEBUG_FILE -Append
            "Subject: $($Certificate.Subject)" | Out-File $DEBUG_FILE -Append
            "Issuer: $($Certificate.Issuer)" | Out-File $DEBUG_FILE -Append
            "SerialNumber: $($Certificate.SerialNumber)" | Out-File $DEBUG_FILE -Append
            "Thumbprint: $($Certificate.Thumbprint)" | Out-File $DEBUG_FILE -Append
            "NotBefore: $($Certificate.NotBefore)" | Out-File $DEBUG_FILE -Append
            "NotAfter: $($Certificate.NotAfter)" | Out-File $DEBUG_FILE -Append
        }
        $params.Add( "Certificate", $Certificate )
    }

    if ( $UseBasicParsing )
    {
        $params.Add( "UseBasicParsing", $true )
    }

    if ( $Body )
    {
        if ( $DEBUG_FILE ) { "[Body]`r`n$Body" | Out-File $DEBUG_FILE -Append }
        $params.Add( "Body", $body )
    }

    $response = Invoke-WebRequest @params

    if ( $DEBUG_FILE )
    {
        "[Response]`r`n$($response.RawContent)" | Out-File $DEBUG_FILE -Append
    }

    if ( $RestMethod ) { return ($response.Content | ConvertFrom-Json) }

    return $response
}

function Done-Normal
{
    param(
        [parameter(position=0, mandatory=$true)]
        [Collections.Hashtable] $Data
    )

    if ( $DEBUG_FILE )
    {
        "".PadLeft(80,"_") | Out-File $DEBUG_FILE -Append
        $caller = (Get-PSCallStack)[1].FunctionName
        "$(Get-Date) - Data Returned by $caller" | Out-File $DEBUG_FILE -Append

        $vars = $Data.Clone()

        foreach ( $key in $Data.Keys )
        {
            if ( $Data[$key] -is [System.Byte[]] )
            {
                # response data sometimes includes byte arrays so base64 encode for debug logging purposes
                $vars[$key] = [Convert]::ToBase64String($Data[$key])
            }
        }

        $vars | ConvertTo-Json -Depth 10 | Out-File $DEBUG_FILE -Append
    }

    return $Data
}

function Done-Abnormal
{
    param(
        [parameter(position=0, mandatory=$true)]
        [Management.Automation.ErrorRecord] $Data
    )

    if ( $DEBUG_FILE )
    {
        "".PadLeft(80,"_") | Out-File $DEBUG_FILE -Append
        "$(Get-Date) - Fatal Error Details" | Out-File $DEBUG_FILE -Append
        $Data.Exception.GetType().FullName | Out-File $DEBUG_FILE -Append
        $Data.Exception.Message | Out-File $DEBUG_FILE -Append
        $Data.ScriptStackTrace | Out-File $DEBUG_FILE -Append

        if ( $Data.Exception -is [System.Net.WebException] )
        {
            $resp = $Data.Exception.Response

            "[Response]" | Out-File $DEBUG_FILE -Append
            "HTTP/{0} {1} {2}`r`n" -f $resp.ProtocolVersion.ToString(), `
                [int]$resp.StatusCode,$resp.StatusDescription | Out-File $DEBUG_FILE -Append

            if ( $Data.Exception.Response.ContentLength -gt 0 )
            {
                $result = $Data.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $reader.ReadToEnd() | Out-File $DEBUG_FILE -Append
            }
        }
    }

    return $Data
}
