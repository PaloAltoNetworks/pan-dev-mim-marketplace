<#
//---------------------------------------------------------------------------
// Palo Alto Networks NGFW - Bulk Provisioning
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. (“Venafi”). All rights reserved.
//
// Venafi hereby grants you a limited license to use and modify this
// software, including any Contributions, during only the period in which you
// hold a valid license from Venafi to use the Venafi Trust Protection
// Platform. For the purposes of this copyright notice, “Contributions” means
// any modifications of this software or derivative works based on this
// software. You have a responsibility to share any Contributions you may
// make with the Venafi community. To the extent you may create any
// Contributions, Venafi will have an irrevocable license to use, modify or
// distribute those Contributions.
//
// THE SOFTWARE IS PROVIDED AS-IS AND WITHOUT ANY WARRANTY, EXPECTATION OF
// COMPATIBILITY, TECHNICAL SUPPORT, ASSISTANCE, UPDATES, OR OTHER SERVICES
// THAT MIGHT BE PROVIDED TO YOU OTHERWISE. YOU ACKNOWLEDGE AND AGREE THAT
// THIS SOFTWARE DOES NOT CONSTITUTE COMMERCIAL RELEASE OF VENAFI SOFTWARE
// AND MAY CONTAIN BUGS OR OTHER ERRORS OR CAUSE ERRORS IN OTHER SOFTWARE OR
// SYSTEMS WHEN USED IN CONJUNCTION THEREWITH. TO THE EXTENT VENAFI HAS MADE
// ANY WARRANTIES TO YOU REGARDING THE FITNESS OF SOFTWARE FOR ANY PURPOSE,
// OR THAT SOFTWARE MAY BE FREE FROM BUGS OR OTHER ERRORS, THIS SOFTWARE AND
// ANY PRODUCTS WHEN USED IN CONJUNCTION THEREWITH ARE EXPRESSLY EXCLUDED
// FROM ANY SUCH WARRANTIES. BY USING THIS SOFTWARE, YOU HEREBY AGREE TO
// FOREVER RELEASE AND HOLD HARMLESS VENAFI, ITS DIRECTORS, OFFICERS,
// EMPLOYEES, AGENTS, AND AFFILIATES FROM ANY LIABILITY OR DEMANDS ARISING
// THEREFROM OR RELATING THERETO, REGARDLESS OF THE THEORY OF LIABILITY.
// 
// The software and its contents are provided by Venafi to customers for the
// purposes of integrating with services and platforms. Any sharing of the
// software outside your organization without consent from Venafi is strictly
// prohibited. Without limiting the foregoing, the above copyright notice,
// preceding paragraphs, this paragraph and the following paragraph must
// appear in all copies, modifications, reproductions, and distributions of
// this software.
//
// IN NO EVENT SHALL VENAFI, ITS DIRECTORS, OFFICERS, EMPLOYEES, AGENTS, OR
// AFFILIATES BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL,
// INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT
// OF THE USE OF THIS SOFTWARE OR ITS DOCUMENTATION, IF ANY, EVEN IF VENAFI
// HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. VENAFI SPECIFICALLY
// DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. THIS
// SOFTWARE, ALONG WITH ITS DOCUMENTATION, IF ANY, IS PROVIDED "AS IS". 
//---------------------------------------------------------------------------

<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Policyable
Bit 3 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text1|Decryption Profile Name|100
Text2|Not Used|000
Text3|Not Used|000
Text4|Not Used|000
Text5|Not Used|000
Option1|Update Decryption Policy Rules|100
Option2|Create Decryption Policy Rules|100
Passwd|Not Used|000
-----END FIELD DEFINITIONS-----
#>

# the following allows us to interface with the default, self-signed/untrusted device certificate
Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$ErrorActionPreference = "Stop"


<##################################################################################################
.NAME
    Install-Certificates
.DESCRIPTION
    Installs the multiple certificates and their private keys on the target device or application.
    Implementing logic for this function is REQUIRED.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
        AppObjectDN : a string containing the TPP distiguished name of the calling application object
        AssetName : a string containing a Venafi standard auto-generated name that can be used for provisioning (<Common Name>-<ValidTo as YYMMDD>-<Last 4 of SerialNum>)
        VarText1 : a string value for the text custom field defined by the header at the top of this script
        VarText2 : a string value for the text custom field defined by the header at the top of this script
        VarText3 : a string value for the text custom field defined by the header at the top of this script
        VarText4 : a string value for the text custom field defined by the header at the top of this script
        VarText5 : a string value for the text custom field defined by the header at the top of this script
        VarBool1 : a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarBool2 : a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarPass : a string value for the password custom field defined by the header at the top of this script
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        Certificates : an array of hashtables, one for each certificate to be provisioned to the device 
            Name : the certificate Common Name (if exists) or a DNS SAN (if exists) or an OU (if exists), otherwise the serial number
            Certificate : the Base64-encoded X509 certificate PEM
            PrivateKey : the Base64-encoded, non-encrypted private key PEM
            Serial : the serial number of the certificate
            Thumbprint : the SHA1 thumbprint of the certificate
            ValidTo : the expiration date of the certificate as 'YYYYMMDD' string
.NOTES
    Returns...
        Result : 'Success' indicates the non-error completion state
        RejectedCertificates : an array of SHA1 thumbprints for certificates that could not be imported for expected reasons
        FailedCertificates : an array of SHA1 thumbprints for certificates that could not be imported for unexpected reasons
##################################################################################################>
function Install-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $failures = @()
    $rejections = @()

    $cert_header = "-----BEGIN CERTIFICATE-----"
    $cert_footer = "-----END CERTIFICATE-----"

    try
    {
	    $apikey = Login -Server $General.HostAddress -Username $General.UserName -Password $General.UserPass
        $locked = Lock-Config -Server $General.HostAddress -ApiKey $apikey

        foreach ( $cert in $Specific.Certificates )
        {
            $installed = $false
            $cert_name = Get-CertNameForDevice $cert.Name $cert.Thumbprint
            $policy_name = $cert.Name.Substring(0, [Math]::Min(31, $cert.Name.Length))

            try # to install the certificate 
            {
                $output = Upload-Certificate -Server $General.HostAddress -ApiKey $apikey -CertName $cert_name `
                            -CertificatePem $cert.Certificate -PrivateKeyPem $cert.PrivateKey

                $installed = $true
            }
            catch
            {
                # Palo Alto NGFW does not allow self-signed EE or expired certificates to be imported
                if ( $_.Exception.Message.Contains("Only self signed CA certificates") -or 
                     $_.Exception.Message.Contains("Certificate is expired") )
                {
                    $rejections += $cert.Thumbprint
                }
                else # unexpected error
                {
                    $failures += $cert.Thumbprint
                }
            }

            if ( $installed -and $General.VarBool1.Equals("true") )
            {
                try # add certificate to Decryption Policy Rule
                {
                    if ( (Test-DecryptionPolicy -Server $General.HostAddress -ApiKey $apikey -Policy $policy_name) )
                    {
                        $null = Update-DecryptionPolicy -Server $General.HostAddress -ApiKey $apikey `
                                    -Policy $policy_name -CertName $cert_name
                    }
                    elseif ( $General.VarBool2.Equals("true") )
                    {
                        $addrs = @()
                    
                        $pem = $cert.Certificate.Replace($cert_header,[string]::Empty).Replace($cert_footer,[string]::Empty)
                        $bytes = [Convert]::FromBase64String($pem)
                        $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$bytes)

                        # default to the common name
                        $fqdns = @($cert2.GetNameInfo([System.Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false))

                        if ($san_exts = $cert.Extensions | ? { $_.Oid.Value -eq "2.5.29.17" })
                        {
                            $sans = $san_exts.Format(1).Split("`n") | ? { $_.StartsWith("DNS Name=") }
                            $fqdns = $sans | % { $_.Substring(9,$_.Length-10) }
                        }

                        foreach ( $fqdn in $fqdns )
                        {
                            $addrs += Set-Address -Server $General.HostAddress -ApiKey $apikey -Address $fqdn
                        }

                        $null = Create-DecryptionPolicy -Server $General.HostAddress -ApiKey $apikey `
                                    -Policy $policy_name -CertName $cert_name -Addresses $addrs -Profile $General.VarText1
                    }
                }
                catch
                {
                    throw "Decryption Policy binding failed for '{0}' to '{1}' ({2})" -f $policy_name,$cert.Thumbprint,$_.Exception.Message
                }
            }
        }
    }
    finally
    {
        if ( $locked ) 
        { 
            $null = Unlock-Config -Server $General.HostAddress -ApiKey $apikey
            $null = Commit-Changes -Server $General.HostAddress -ApiKey $apikey
        }
    }

    if ( $failures.Count -gt 0 )
    {
        return @{ Result="Errors"; FailedCertificates=$failures; RejectedCertificates=$rejections }
    }

    return @{ Result="Success"; RejectedCertificates=$rejections }
}


<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Login
( 
    [string] $Server,
    [string] $Username,
    [string] $Password
)
{
    $url = "https://{0}/api/?type=keygen&user={1}&password={2}" -f $Server,$Username,$Password
	$response = Invoke-WebRequest -Method Get -Uri $url -UseBasicParsing

    $data = Handle-Response $response
    
    return $data.result.key # API Key
}


function Lock-Config
( 
    [string] $Server,
    [string] $ApiKey
)
{
    $url = "https://{0}/api/?key={1}&type=op&cmd=<request><config-lock><add></add></config-lock></request>" -f $Server,$ApiKey
    $response = Invoke-WebRequest -Method Get -Uri $url -UseBasicParsing

    $output = Handle-Response $response

    if ( $output.result.StartsWith("Successfully acquired lock") )
    {
        return $true
    }

    throw "Failed to lock device configuration"
}


function Unlock-Config
( 
    [string] $Server,
    [string] $ApiKey
)
{
    $url = "https://{0}/api/?key={1}&type=op&cmd=<request><config-lock><remove></remove></config-lock></request>" -f $Server,$ApiKey
    $response = Invoke-WebRequest -Method Get -Uri $url -UseBasicParsing

    $output = Handle-Response $response
    
    if ( $output.result.StartsWith("Config lock released") )
    {
        return $true
    }

    throw "Failed to unlock device configuration"
}


function Commit-Changes
( 
    [string] $Server,
    [string] $ApiKey
)
{
    $url = "https://{0}/api/?key={1}&type=commit&cmd=<commit></commit>" -f $Server,$ApiKey
    $response = Invoke-WebRequest -Method Get -Uri $url -UseBasicParsing

    return (Handle-Response $response)
}


function Upload-Certificate
( 
    [string] $Server,
    [string] $ApiKey,
    [string] $CertName,
    [string] $CertificatePem,
    [string] $PrivateKeyPem
)
{
    $url = "https://{0}/api/?key={1}&type=import&category=keypair&certificate-name={2}&format=pem&passphrase=null" -f $Server,$ApiKey,$CertName

    $boundary = "------" + (Get-Date).Ticks.ToString("x", [Globalization.NumberFormatInfo]::InvariantInfo)

    $content_type = "multipart/form-data; boundary={0}" -f $boundary

    $body = "--" + $boundary + "`r`n" +
        "Content-Disposition: form-data; name=`"file`"; filename=`"" + $CertName + "`"`r`n" +
        "Content-Type: application/octet-stream`r`n`r`n" +
        $CertificatePem + "`r`n" +
        $PrivateKeyPem + "`r`n" +
        "--" + $boundary +"--`r`n"
        
    $response = Invoke-WebRequest -Method Post -Uri $url -Body $body -ContentType $content_type -UseBasicParsing
    return (Handle-Response $response)
}


function Set-Address
( 
    [string] $Server, 
    [string] $ApiKey, 
    [string] $Address 
)
{
    $name = $Address.Replace("/","_")

    $xpath = "/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/address"
 
    $element = "<entry name=`"" + $name + "`">"

    if ( [RegEx]::IsMatch($Address, "[A-Za-z]" ) )
    {
        $element += "<fqdn>{0}</fqdn>" -f $Address
    }
    elseif ( [RegEx]::IsMatch($Address, "[\-]") )
    {
        $element += "<ip-range>{0}</ip-range>" -f $Address
    }
    else
    {
        $element += "<ip-netmask>{0}</ip-netmask>" -f $Address
    }
        
    $element += "</entry>"

    $url = "https://{0}/api/?key={1}&type=config&action=set&xpath={2}&element={3}" -f $Server,$ApiKey,$xpath,$element

    $response = Invoke-WebRequest -Method Get -Uri $url -ContentType "application/xml; charset=UTF-8;" -UseBasicParsing

    if ( $response.content.Contains("<msg>command succeeded</msg>") )
    {
        return $name
    }

    throw "Failed to set address"
}


function Test-DecryptionPolicy
( 
    [string] $Server,
    [string] $ApiKey,
    [string] $Policy
)
{
    $xpath = "/config/devices/entry[@name='localhost.localdomain']" +
        "/vsys/entry[@name='vsys1']/rulebase/decryption/rules/entry[@name='{0}']" -f $Policy
    
    $url = "https://{0}/api/?key={1}&type=config&action=get&xpath={2}" -f $Server,$ApiKey,$xpath

    $response = Invoke-WebRequest -Method Get -Uri $url -ContentType "application/xml; charset=UTF-8;" -UseBasicParsing
    return ( -not $response.content.Contains("<result/>") )
}


function Create-DecryptionPolicy
( 
    [string] $Server,
    [string] $ApiKey,
    [string] $Policy,
    [string] $CertName,
    [string[]] $Addresses = @("any"),
    [string] $Profile = ""
)
{    
    $destinations = ""

    foreach ( $address in $Addresses )
    {
        $destinations += "<member>" + $address + "</member>"
    }

    $xpath = "/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/rulebase/decryption/rules"

    $element = "<entry name=`"" + $Policy + "`"><category><member>any</member></category>" +
        "<type><ssl-inbound-inspection>" + $CertName + "</ssl-inbound-inspection></type><from><member>any</member></from>" +
        "<to><member>any</member></to><source><member>any</member></source><destination>" + $destinations +
        "</destination><source-user><member>any</member></source-user><profile>" + $Profile + "</profile>" +
        "<action>decrypt</action></entry>"

    $url = "https://{0}/api/?key={1}&type=config&action=set&xpath={2}&element={3}" -f $Server,$ApiKey,$xpath,$element

    $response = Invoke-WebRequest -Method Get -Uri $url -ContentType "application/xml; charset=UTF-8;" -UseBasicParsing
    return (Handle-Response $response)
}


function Update-DecryptionPolicy
( 
    [string] $Server,
    [string] $ApiKey,
    [string] $Policy,
    [string] $CertName
)
{
    $xpath = "/config/devices/entry[@name='localhost.localdomain']" +
        "/vsys/entry[@name='vsys1']/rulebase/decryption/rules/entry[@name='{0}']" -f $Policy
    
    $element = "<type><ssl-inbound-inspection>{0}</ssl-inbound-inspection></type>" -f $CertName
    
    $url = "https://{0}/api/?key={1}&type=config&action=set&xpath={2}&element={3}" -f $Server,$ApiKey,$xpath,$element

    $response = Invoke-WebRequest -Method Get -Uri $url -ContentType "application/xml; charset=UTF-8;" -UseBasicParsing
    return (Handle-Response $response)
}


function Get-CertNameForDevice
( 
    [string] $name, 
    [string] $thumbprint 
)
{
    $max_name_length = 31 # certificates can be 63 characters long unless they're used by a decryption policy
    
    # deal with wildcard certificates and unsupported characters
    $name = [Regex]::Replace($name, "^\*\.", "WC.")
    $name = [Regex]::Replace($name, "[^A-Za-z0-9-._]", [String]::Empty)

    $suffix = "_{0}" -f $thumbprint.Substring($thumbprint.length-4)

    if ( $name.Length -gt ($max_name_length - $suffix.Length - 1) )
    {
        $name = $name.Substring(0, $max_name_length - $suffix.Length - 1)
    }

    return "{0}{1}" -f $name,$suffix
}


function Handle-Response( $resp )
{
    $data = $null
    $error = $null
    
    try
    {
        $data = ([xml]$resp.Content).response

        if ( $data.status -ne "success" )
        {
            $msg = $data.msg.line

            if ( $msg."#cdata-section" )
            {
                $error = ($msg."#cdata-section" -join ". ").Trim()
            }
            else
            {
                $error = $msg.Trim()
            }
        }
    }
    catch
    {
        throw
    }

    if ( $error )
    {
        throw $error
    }

    return $data
}