<#
//---------------------------------------------------------------------------
// Arbor-Edge-Defense.ps1
//
// January 2021
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by NETSCOUT, in addition to Venafi.
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

<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Policyable
Bit 3 = Mandatory

The following fields are provided to functions via the General Parameters in this way
Passwd  -> $General.VarPass
Option1 -> $General.VarBool1

-----BEGIN FIELD DEFINITIONS-----
Passwd|API Token|101
Option1|Disable SSL Host Validation|111
-----END FIELD DEFINITIONS-----

#>

# allow more SSL protocols. By default, .NET 4.5 only allows TLS1.0 and SSLv3
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

# function should halt if rest command raises an error
$ErrorActionPreference = "Stop"

# define a type that can be used to disable SSL host validation
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

<##################################################################################################
.NAME
    Disable-SSL-Host-Validation
##################################################################################################>
function Disable-SSL-Host-Validation
{
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}


<##################################################################################################
.NAME
    Build-Headers
.DESCRIPTION
    Build a headers dictionary given HSM credentials and api token
.PARAMETER ApiToken
    The Arbux API token
.PARAMETER HsmUsername
    The cu username for the HSM module
.PARAMETER HsmPassword
    The cu password for the HSM module
##################################################################################################>
function Build-Headers
{
    Param(
        [parameter(mandatory=$true)]
        [string]$ApiToken,
        [parameter(mandatory=$true)]
        [string]$HsmUsername,
        [parameter(mandatory=$true)]
        [string]$HsmPassword
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Arbux-APIToken", $ApiToken)
    $headers.Add("X-Arbux-HSMUsername", $HsmUsername)
    $headers.Add("X-Arbux-HSMPassword", $HsmPassword)
    return $headers
}


<##################################################################################################
.NAME
    Install-Chain
.DESCRIPTION
    Installs the certificate chain on the hosting platform.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        ChainPem : all chain certificates concatentated together one after the other
        ChainPkcs7 : byte array PKCS#7 collection that includes all chain certificates
.NOTES
    Returns...
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Install-Chain
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
    Install-PrivateKey
.DESCRIPTION
    Installs the private key on the hosting platform.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        PrivKeyPem : the non-encrypted private key in RSA Base64 PEM format
        PrivKeyPemEncrypted : the password encrypted private key in RSA Base64 PEM format
        EncryptPass : the string password that was used to encrypt the private key and PKCS#12 keystore
.NOTES
    Returns...
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-error completion state
        AssetName : (optional) the base name used to reference the private key as it was installed on the device; if not supplied the auto-generated name is assumed
##################################################################################################>
function Install-PrivateKey
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
    Install-Certificate
.DESCRIPTION
    Installs the certificate on the hosting platform.  May optionally be used to also install the private key and chain.
    Implementing logic for this function is REQUIRED.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        CertPem : the X509 certificate to be provisioned in Base64 PEM format
        PrivKeyPem : the non-encrypted private key in RSA Base64 PEM format
        PrivKeyPemEncrypted : the password encrypted private key in RSA Base64 PEM format
        ChainPem : all chain certificates concatentated together one after the other
        ChainPkcs7 : byte array PKCS#7 collection that includes all chain certificates
        Pkcs12 : byte array PKCS#12 collection that includes certificate, private key, and chain
        EncryptPass : the string password that was used to encrypt the private key and PKCS#12 keystore
.NOTES
    Returns...
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-error completion state (may only be 'NotUsed' if Install-PrivateKey did not return 'NotUsed')
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed
##################################################################################################>
function Install-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    If ($General.VarBool1 -eq $True) {
        Disable-SSL-Host-Validation
    }

    # ahsm_tool only allows alpha numeric and [,.-@]
    $General.AssetName = $General.AssetName -replace '([^A-Z,0-9,-,.,\,,@])', '-'

    # remove the cert if it exists to support Venafi re-push behavior
    $removeGeneral = @{
        VarPass=$General.VarPass
        UserName=$General.UserName
        UserPass=$General.UserPass
        HostAddress=$General.HostAddress
    }
    $removeSpecific = @{
        AssetNameOld=$General.AssetName
    }
    Remove-Certificate `
        -General $removeGeneral `
        -Specific $removeSpecific

    $headers = Build-Headers `
        -ApiToken $General.VarPass `
        -HsmUsername $General.UserName `
        -HsmPassword $General.UserPass

    $body = @{
        label = $General.AssetName
        privateKey = $Specific.PrivKeyPem
        certificate = $Specific.CertPem
    }
    $json = $body | ConvertTo-Json

    $builder = New-Object System.UriBuilder
    $builder.Host = $General.HostAddress
    $builder.Scheme = "https"
    $builder.Path = "api/aps/v3/hsm/certificates/"

    $response = Invoke-RestMethod `
        -Method POST `
        -Uri $builder.ToString() `
        -Headers $headers `
        -Body $json `
        -ContentType "application/json"

    return @{
        Result="Success"
        AssetName=$General.AssetName
    }
}


<##################################################################################################
.NAME
    Update-Binding
.DESCRIPTION
    Binds the installed certificate with the consuming application or service on the hosting platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Update-Binding
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed" }
}


<##################################################################################################
.NAME
    Activate-Certificate
.DESCRIPTION
    Performs any post-installation operations necessary to make the certificate active (such as restarting a service)
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Activate-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed" }
}


<##################################################################################################
.NAME
    Extract-Certificate
.DESCRIPTION
    Extracts the active certificate from the hosting platform.  If the platform does not provide a method for exporting the
    raw certificate then it is sufficient to return only the Serial and Thumprint.  This function is REQUIRED.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        CertPem : the extracted X509 certificate referenced by AssetName in Base64 PEM format
        Serial : the serial number of the X509 certificate refernced by AssetName
        Thumbprint : the SHA1 thumprint of the X509 certificate referenced by AssetName
##################################################################################################>
function Extract-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    If ([string]::IsNullOrEmpty($General.AssetName)) {
        throw "Cannot extract certificate because AssetName is empty"
    }

    If ($General.VarBool1 -eq $True) {
        Disable-SSL-Host-Validation
    }

    $headers = Build-Headers `
        -ApiToken $General.VarPass `
        -HsmUsername $General.UserName `
        -HsmPassword $General.UserPass
    $builder = New-Object System.UriBuilder
    $builder.Host = $General.HostAddress
    $builder.Scheme = "https"
    $builder.Path = "api/aps/v3/hsm/certificates/" + $General.AssetName + "/"

    $response = Invoke-RestMethod `
        -Method GET `
        -Uri $builder.ToString() `
        -Headers $headers `

    return @{
        Result="Success"
        Serial=$response.serial
        Thumbprint=$response.thumbprint
    }
}


<##################################################################################################
.NAME
    Extract-PrivateKey
.DESCRIPTION
    Extracts the private key associated with the certificate from the hosting platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        EncryptPass : the string password to use when encrypting the private key
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        PrivKeyPem : the extracted private key in RSA Base64 PEM format (encrypted or not)
##################################################################################################>
function Extract-PrivateKey
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
    Remove-Certificate
.DESCRIPTION
    Removes an existing certificate (or private key) from the device.  Only implement the body of 
    this function if TPP can/should remove old generations of the same asset.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        AssetNameOld : the name of a asset that was previously replaced and should be deleted
.NOTES
    Returns...
        Result : 'Success' or 'DoesNotExist' to indicate the non-error completion state
##################################################################################################>
function Remove-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    If ($General.VarBool1 -eq $True) {
        Disable-SSL-Host-Validation
    }

    $headers = Build-Headers `
        -ApiToken $General.VarPass `
        -HsmUsername $General.UserName `
        -HsmPassword $General.UserPass

    $builder = New-Object System.UriBuilder
    $builder.Host = $General.HostAddress
    $builder.Scheme = "https"
    $builder.Path = "api/aps/v3/hsm/certificates/" + $Specific.AssetNameOld + "/"

    echo $builder.ToString()

    try
    {
        $response = Invoke-RestMethod `
            -Method DELETE `
            -Uri $builder.ToString() `
            -Headers $headers `
    }
    catch
    {
        if ($_.Exception.Response.StatusCode.Value__ -eq 404)
        {
            return @{
                Result="DoesNotExist"
            }
        }
        else
        {
            throw
        }
    }

    return @{
        Result="Success"
    }
}