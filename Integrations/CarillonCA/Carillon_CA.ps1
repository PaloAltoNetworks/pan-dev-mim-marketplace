<#
//---------------------------------------------------------------------------
// Carillon_CA.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// This software is licensed by Carillon Information Security Inc., in addition
// to Venafi.  Additional license terms may apply. The software and its
// contents are provided by Venafi to customers for the purposes of integrating
// with services and platforms. Modification of this script is only allowed to
// update any necessary configuration details. Any sharing of the software
// outside your organization without consent from Venafi is strictly
// prohibited. Without limiting the foregoing, the above copyright notice, this
// paragraph and the following paragraph must appear in all copies,
// modifications, reproductions, and distributions of this software.
//
// IN NO EVENT SHALL VENAFI, INC., ITS DIRECTORS, OFFICERS, EMPLOYEES, AGENTS,
// OR AFFILIATES BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL,
// INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF
// THE USE OF THIS SOFTWARE OR ITS DOCUMENTATION, IF ANY, EVEN IF VENAFI, INC.
// HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.  VENAFI, INC.
// SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, ANY
// IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
// THIS SOFTWARE, ALONG WITH ITS DOCUMENTATION, IF ANY, IS PROVIDED "AS IS".
// VENAFI, INC. HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, OR UPDATES
// FOR THE SOFTWARE OR ITS DOCUMENTATION, IF ANY.
//---------------------------------------------------------------------------
#>


Add-Type -AssemblyName System.Security

<# a URL MAY be configured here, if only one is needed.
 # alternatively, General.ServiceAddress will override this. #>
$global:extreq_url = "CONFIGURATION ERROR: no extreq url defined"
if ( (Get-ItemProperty "HKLM:\SOFTWARE\Carillon\extreq")."URL" )
{
    $global:extreq_url = (Get-ItemProperty "HKLM:\SOFTWARE\Carillon\extreq")."URL"
}

<# a certtype MAY be configured here, if only one is needed.
 # alternatively, a Custom Field named CarillonCertType can be used on a per-policy basis. #>
$global:extreq_certtype = "VenafiClientDevice"
if ( (Get-ItemProperty "HKLM:\SOFTWARE\Carillon\extreq")."certtype" )
{
    $global:extreq_certtype = (Get-ItemProperty "HKLM:\SOFTWARE\Carillon\extreq")."certtype"
}


<##################################################################################################
.NAME
    Test-Settings
.DESCRIPTION
    Verifies the ability to connect to and authenticate with the CA using the supplied credentials
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserName : the username for authenticating with the CA
        UserPass : the password for authenticating with the CA
        PfxData : a PKCS#12 containing client certificate and private key for authenticating with the CA
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

    if (!$General.PfxData -or !$General.PfxPass)
    {
        throw "PfxData and PfxPass must be provided"
    }

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import($General.PfxData, $General.PfxPass,
                 [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet)

    if ( $DEBUG_FILE ) { $cert | Format-List | Out-File $DEBUG_FILE -Append }

    return @{ Result="Success" }
}


<##################################################################################################
.NAME
    Get-ChainCertificates
.DESCRIPTION
    Retrieves the chain of CA certificates applicable to certificates issued by the CA
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs7 : a collection that includes all of the CA certificates in the issuing chain
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
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        Pkcs10 : the Base64-encoded PKCS#10 formatted certificate signing request to be enrolled
        SubjectDN : the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames : hashtable keyed by SAN type; values are string arrays
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

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    $cn = $Specific.SubjectDN["CN"]
    $pkcs10 = $Specific.Pkcs10

    $certtype = $General.CustomFields["CarillonCertType"]
    if (!$certtype)
    {
        $certtype = $global:extreq_certtype
    }
    $url = $General.ServiceAddress;
    if (!$url)
    {
        $url = $global:extreq_url
    }

    $xml = ("<eCarillonPKICertRequest>`n" `
           +"    <subuniq>$cn</subuniq>`n" `
           +"    <cardsn>N/A</cardsn>`n" `
           +"    <certtype>$certtype</certtype>`n" `
           +"    <needcms>true</needcms>`n" `
           +"    <pkcs10>$pkcs10</pkcs10>`n" `
           +"</eCarillonPKICertRequest>`n")

    $xmlstr = CIS-Sign-Xml $xml $General.PfxData $General.PfxPass

    if ( $DEBUG_FILE ) { $xmlstr | Out-File $DEBUG_FILE -Append }

    $respxml = CIS-Extreq-Post $url $xmlstr

    $cmses = $respxml.GetElementsByTagname("cms")
    if ($cmses.Count -eq 0)
    {
        $errstr = "Response did not include a CMS structure"
        if ( $DEBUG_FILE ) { $errstr | Out-File $DEBUG_FILE -Append }
        throw $errstr
    }
    $cms = $cmses[0].InnerText
    $refs = $respxml.GetElementsByTagname("ref")
    if ($refs.Count -eq 0)
    {
        $errstr = "Response did not include a certref"
        if ( $DEBUG_FILE ) { $errstr | Out-File $DEBUG_FILE -Append }
        throw $errstr
    }
    $ref = $refs[0].InnerText

    return @{ Result="Success";TransId="$ref";Status="Issued";Pkcs7=[System.Convert]::FromBase64String($cms) }
}


<##################################################################################################
.NAME
    Submit-CsrAsRenewal
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a renewal of an existing certificate
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function (see Submit-CsrAsNew plus the following)
        CertId : a string that the CA can use to uniquely identify the certificate being renewed
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
    Submits a CSR to a CA for enrollment as a replacement for an existing certificate
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function (see Submit-CsrAsNew plus the following)
        CertId : a string that the CA can use to uniquely identify the certificate being replaced
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

    return @{ Result="NotUsed" }
}


<##################################################################################################
.NAME
    Retrieve-Certificate
.DESCRIPTION
    Retrieves a signed certificate from the CA
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        CertId : a string that uniquely identifies the certificate issued by the CA
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Status : 'Pending' or 'Issued' to indicate whether the certificate has been issued by the CA
        Pkcs7 : a collection that includes the issued certificate and optionally all of the CA certificates in the chain
                Pkcs12 : a collection that includes the issued certificate, its private key, and optionally all of the CA certificates in the chain
                PrivKeyPem : an OpenSSL or PKCS#8 private key in PEM format
                EncryptPass : the password used to encrypt the private key or PKCS#12
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

    # Not used, because we get the cert right in the SubmitCsr response.

    return @{ Result="NotUsed" }
}


<##################################################################################################
.NAME
    Revoke-Certificate
.DESCRIPTION
    Revokes a certificate issued by the CA
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        CertId : a string that uniquely identifies the certificate issued by the CA
        CertPem : the raw, Base64-encoded X509 certificate to be revoked
        ReasonCode : 1 (User Key Compromised), 2 (CA Key Compromised), 3 (User Changed Affiliation), 4 (Certificate Superseded), 5 (Original Use No Longer Valid)
        Comment : a comment provided by the revocation requester
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Revoke-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    # We have CertId but extreq wants serial...
    # This will change, but for now we can get the serial from the cert and
    # send that too.

    try
    {
        <# simulator provides base64-encoded DER #>
        $bytes = [Convert]::FromBase64String($Specific.CertPem)
    }
    catch
    {
        <# TPP actually provides PEM #>
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Specific.CertPem)
    }
    if (!$bytes.length)
    {
        $errstr = "Revoke-Certificate unable to read certificate"
        if ( $DEBUG_FILE ) { $errstr | Out-File $DEBUG_FILE -Append }
        throw $errstr
    }

    try
    {
        $x509 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $x509.Import($bytes)
        $serial = $x509.SerialNumber
    }
    catch
    {
        $errstr = "Revoke-Certificate failed to get serial number: $_"
        if ( $DEBUG_FILE ) { $errstr | Out-File $DEBUG_FILE -Append }
        throw $errstr
    }

    $thingstr = "serial number to revoke: $serial"
    if ( $DEBUG_FILE ) { $thingstr | Out-File $DEBUG_FILE -Append }

    $reason = $Specific.ReasonCode

    $ref = $Specific.CertId

    $xml = ("<eCarillonPKIRevRequest>`n" `
           +"    <ref>$ref</ref>`n" `
           +"    <serial>$serial</serial>`n" `
           +"    <reason>$reason</reason>`n" `
           +"</eCarillonPKIRevRequest>`n")

    $url = $General.ServiceAddress;
    if (!$url)
    {
        $url = $global:extreq_url
    }

    $xmlstr = CIS-Sign-Xml $xml $General.PfxData $General.PfxPass

    if ( $DEBUG_FILE ) { $xmlstr | Out-File $DEBUG_FILE -Append }

    $respxml = CIS-Extreq-Post $url $xmlstr

    return @{ Result="Success" }
}


<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

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


function CIS-Sign-Xml ( [string]$xmlin, [byte[]]$pfxname, [SecureString]$pfxpass )
{
    [xml]$xml = $xmlin

    try
    {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($pfxname, $pfxpass,
                     [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

        $cspParams = New-Object Security.Cryptography.CspParameters -Property @{
            ProviderType = 24
            ProviderName = "Microsoft Enhanced RSA and AES Cryptographic Provider"
        }

        $exported = $cert.PrivateKey.ToXmlString($true)

        $newprivkey = New-Object Security.Cryptography.RSACryptoServiceProvider $cspParams
        $newprivkey.FromXmlString($exported)

        $cert.PrivateKey = $newprivkey

        $signed = New-Object System.Security.Cryptography.Xml.SignedXml -ArgumentList $xml
        $signed.SigningKey = $cert.PrivateKey

        $keyInfo = New-Object System.Security.Cryptography.Xml.KeyInfo
        $keyInfo.AddClause((New-Object System.Security.Cryptography.Xml.KeyInfoX509Data -ArgumentList $cert))
        $signed.KeyInfo = $keyInfo

        $Reference = New-Object System.Security.Cryptography.Xml.Reference
        $Reference.Uri = ""

        $env = New-Object System.Security.Cryptography.Xml.XmlDsigEnvelopedSignatureTransform

        $Reference.AddTransform($env)
        $Reference.DigestMethod = [System.Security.Cryptography.Xml.SignedXml]::XmlDsigSHA256Url
        $signed.AddReference($Reference)
        $signed.SignedInfo.SignatureMethod = [System.Security.Cryptography.Xml.SignedXml]::XmlDsigRSASHA256Url
        $signed.ComputeSignature()

        [System.Xml.XmlElement]$xmlSignature = $signed.GetXml()

        #Add signature to end of xml file
        [void]$xml.DocumentElement.AppendChild($xml.ImportNode($xmlSignature, $true))

        if ($xml.FirstChild -is [system.xml.XmlDeclaration])
        {
            $xml.RemoveChild($xml.FirstChild)
        }
        $xmlstr = $xml.OuterXml
        return $xmlstr
    }
    catch
    {
        $errstr = "CIS-Sign-Xml failed: $_"
        if ( $DEBUG_FILE ) { $errstr | Out-File $DEBUG_FILE -Append }
        throw $errstr
    }
}


function CIS-Extreq-Post ( [string]$url, [string]$body )
{
    try
    {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url `
                                  -ContentType "application/eCarillonPKIReq+xml" `
                                  -Method POST -Body $body
        $respstr = "Received response from CertServ: $resp"
        if ( $DEBUG_FILE ) { $respstr | Out-File $DEBUG_FILE -Append }
    }
    catch
    {
        $errstr = "Failed to send POST request: $_"
        if ( $DEBUG_FILE ) { $errstr | Out-File $DEBUG_FILE -Append }
        throw $errstr
    }
    $respxml = [xml]$resp
    $errors = $respxml.GetElementsByTagname("error")
    if ($errors.Count -ne 0)
    {
        $err = $errors[0].InnerText
        $errstr = "Received an error response from CertServ: $err"
        if ( $DEBUG_FILE ) { $errstr | Out-File $DEBUG_FILE -Append }
        throw $errstr
    }

    return $respxml
}
