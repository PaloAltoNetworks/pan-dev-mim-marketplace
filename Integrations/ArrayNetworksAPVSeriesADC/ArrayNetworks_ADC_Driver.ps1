<#
//---------------------------------------------------------------------------
// ArrayNetworks_ADC_Driver.ps1
//
// Version 1.0
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by Array Networks, in addition to Venafi.
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

-----BEGIN FIELD DEFINITIONS-----
Text1|SSL Virtual Host|101
Text2|Domain Name|100
Text3|NOT USED - Index of Certificate (Default 1)|000
Text4|NOT USED|000
Text5|NOT USED|000
Option1|Activate Certificate After Installation|111
Option2|NOT USED|000
Passwd|NOT USED|000
-----END FIELD DEFINITIONS-----
#>

<# Need the following to interface with an untrusted certificate. Debug only.
   For APV self-signed certificate, we also need to skip the certificate chian checking. #>
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

# Prevent http code 417
[System.Net.ServicePointManager]::Expect100Continue = $false;
# Need set TLS to 1.2 for APV 8.6.x / 10.x
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Array ADC global variables
# $index, index of certificate, 1~3, default to 1 if user not provided
$index = 1
# $certType, default "RSA" required on activate/inactivate/delete a certificate
$certType = "RSA"
# $isActivateCert, controll activation of installed certificate
$isActivateCert = $true
# $isEnableSslVhAfterActiveCert, enable the target SSL VH after activate certificate (pre-condition: $isActivateCert must in true)
$isEnableSslVhAfterActiveCert = $true

<##################################################################################################
.NAME
    Prepare-KeyStore
.DESCRIPTION
    Remotely create and/or verify keystore on the hosting platform.  Remote generation is considered UNSUPPORTED if this
    function is ommitted or commented out.
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
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Prepare-KeyStore
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )
    return @{ Result="NotUsed"; }
}


<##################################################################################################
.NAME
    Generate-KeyPair
.DESCRIPTION
    Remotely generates a public-private key pair on the hosting platform.  Remote generation is 
    considered UNSUPPORTED if this function is ommitted or commented out.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        KeySize : the integer key size to be used when creating a key pair
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed
##################################################################################################>
function Generate-KeyPair
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    return @{ Result="NotUsed"; }
}


<##################################################################################################
.NAME
    Generate-CSR
.DESCRIPTION
    Remotely generates a CSR on the hosting platform.  Remote generation is considered UNSUPPORTED
    if this function is ommitted or commented out.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        SubjectDN : the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames : hashtable keyed by SAN type; values are string arrays
        KeySize : the integer key size to be used when creating a key pair
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs10 : a string representation of the CSR in PKCS#10 format
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed
##################################################################################################>
function Generate-CSR
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    return @{ Result="NotUsed"; }
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
    return @{ Result="NotUsed"; }
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
    return @{ Result="NotUsed"; }
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

    #"`n#APV RESTful import certificate process" 
    $cert = $Specific.CertPem 
    #$privKey = $Specific.PrivKeyPem
    $privKeyPemEncrypted = $Specific.PrivKeyPemEncrypted
    $encryptPass = $Specific.EncryptPass
    $hostAddrWithPort = $General.HostAddress+':'+$General.TcpPort
    $user = $General.UserName
    $pass = $General.UserPass

    $target = $General.VarText1
    $domainName = $General.VarText2

    $headers = Get-RequestHeaders $user $pass
    try
    {
        #check available index
        $currentCerts = @()
        $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost/$target/certs"
        $url = "https://$hostAddrWithPort$apvRestfulUrl"
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

        if ($response.SSLVirtualHost.certs) {
            foreach ($currentCert in $response.SSLVirtualHost.certs) {<#
                $certName = ("{0}-{1}-{2}" -f $currentCert.index,$certType,$target)
                if ($currentCert.domain_name) { #string not null or empty
                    $certName = ("{0}-{1}-{2}-{3}" -f $currentCert.index,$certType,$target,$currentCert.domain_name)
                }#>
                if ($domainName -eq $currentCert.domain_name) { # Get all certs of same domain
                    $currentCerts += $currentCert
                }
            }
        }
        #check available index to install
        $index1Exist = $false
        $index2Exist = $false
        $index3Exist = $false
        $index1Active = $false
        $index2Active = $false
        $index3Active = $false

        foreach ($currentCert in $currentCerts) {
            switch ($currentCert.index) {
                "1" {
                    $index1Exist = $true;
                    $index1Active = $currentCert.activated_state;
                    break
                }
                "2" {
                    $index2Exist = $true;
                    $index2Active = $currentCert.activated_state;
                    break
                }
                "3" {
                    $index3Exist = $true;
                    $index3Active = $currentCert.activated_state;
                    break
                }
                Default { break }
            }
        }
        #manually rotation, check index and stack by 1, 2, 3
        if (-not $index1Exist -and -not $index2Exist -and -not $index3Exist) {
            $index = 1
        } elseif (-not $index2Exist -and -not $index3Exist) {
            $index = 2
        } elseif (-not $index3Exist -and $index1Exist -and (-not $index1Active)) {
            $index = 3
        }
        elseif ($index1Exist -and (-not $index1Active) -and $index2Exist -and (-not $index2Active)) {
            $index = 1
        } 
        elseif ($index1Exist -and $index1Active -and (-not $index2Exist) -and $index3Exist) { #1: act, 2: non, 3:In-act
            $index = 2
        } 
        elseif ($index2Exist -and -not $index2Active -and $index1Exist) {
            $index = 2
        }
        elseif ($index3Exist -and -not $index3Active -and $index2Exist) {
            $index = 3
        }

        #install cert
        #$headers = Get-RequestHeaders $user $pass
        $body = (@{
            "targets"=$target;
            "using"=@{
                "manual_input"=@{ 
                    "index" = $index;
                    "key_passphrase"=$encryptPass;
                    "cert_content"=$cert;
                    "domain_name"=$domainName;
                    "key"=$privKeyPemEncrypted;
                };
            };
        } | ConvertTo-Json).replace("\r\n","\n") #replace "\r\n" to "\n" avoid APV import certificate error
        #build $assoTargets first, if RESTful API error, then output $assoTargets to error message
        $assoTargets = ("{0}-{1}-{2}" -f $index,$certType,$target)
        if ($domainName) { #string not null or empty
            $assoTargets = ("{0}-{1}-{2}-{3}" -f $index,$certType,$target,$domainName)
        }

        $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost/_Import_Cert"
        $url = "https://$hostAddrWithPort$apvRestfulUrl"
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body

        return @{ Result="Success"; AssetName=$assoTargets;}
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__) {
            $statusCode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim();
        }
        if  ($_.Exception.Message) {
            $exceptionMessage = ($_.Exception.Message).ToString().Trim();
        }
        # Check if there is a response.
        if ($_.Exception.Response) {
            # Get the response body with more error detail.
            $respStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($respStream)
            $respBody = $reader.ReadToEnd() | ConvertFrom-Json
            #{  "msg": "Perform Import_Cert failed: Import Failed: the certificate file already exists."  }
            $errorMessage = $respBody.msg
            if ($errorMessage -like "*the certificate file already exists*") {
                Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Information -Message ("(AlreadyInstalled:"+$assoTargets+") " + $errorMessage)
                return @{ Result='AlreadyInstalled'; }   
            }
            #Other errors to throw exception
            #"Perform Import_Cert failed: Please activate a certificate for virtual host SSL_TEST_01"
            #"Perform Import_Cert failed: SNI domain-name "adaptable.arraynetworks.net" does not exist for host ""SSL_TEST_01""."
            #"Perform Import_Cert failed: Import Failed: wrong format."
            Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message $errorMessage
            throw $errorMessage
        }
        Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message ($statusCode +": "+$exceptionMessage)
        throw $exceptionMessage
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
    return @{ Result="NotUsed"; }
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

    $hostAddrWithPort = $General.HostAddress+':'+$General.TcpPort

    # Activate APV SSL VH Cert process
    # $isActivateCert = $General.VarBool1
    if ($General.VarBool1) {
        $isActivateCert = $General.VarBool1
    }
    if ($isActivateCert -eq $false) {
        return @{ Result="NotUsed"; }
    }
    $user = $General.UserName
    $pass = $General.UserPass
    $target = $General.VarText1
    $domainName =  $General.VarText2

    $assoTargets = $General.AssetName;
    $body = @{
        "targets" = $target;
        "asso_targets" = $assoTargets;
    } | ConvertTo-Json

    $headers = Get-RequestHeaders $user $pass
    try
    {
        $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost/_Activate"
        $url = "https://$hostAddrWithPort$apvRestfulUrl"
        "`n url: " + $url
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body

        if ($isEnableSslVhAfterActiveCert -eq $true) {
            Activate-ApvSslVh $hostAddrWithPort $target $user $pass
        }
        return @{ Result="Success"; }
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__) {
            $statusCode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim()
        }
        if  ($_.Exception.Message) {
            $exceptionMessage = ($_.Exception.Message).ToString().Trim()
        }
        # Check if there is a response.
        if ($_.Exception.Response) {
            # Get the response body with more error detail.
            $respStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($respStream)
            $respBody = $reader.ReadToEnd() | ConvertFrom-Json
            #{  "msg": "Perform Activate failed: Certificate is already active."  }
            $errorMessage = $respBody.msg

            if ($errorMessage -like "*Certificate is already active*") {
                return @{ Result='AlreadyInstalled'; }
            }
            #"Perform Activate failed: SNI domain-name "adaptable.arraynetworks.net" does not exist for host "SSL_TEST_01"."
            if ($domainName -and ($errorMessage -like "*SNI domain-name """+$domainName+""" does not exist for host*")) {
                Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message $errorMessage
                throw $errorMessage
            }
        }
        Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message ($statusCode +": "+$exceptionMessage)
        throw $exceptionMessage
    }
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

    $hostAddrWithPort = $General.HostAddress+':'+$General.TcpPort

    $hostAddrWithPort = $General.HostAddress+':'+$General.TcpPort
    $user = $General.UserName
    $pass = $General.UserPass
    $target = $General.VarText1

    $assoTargets = $General.AssetName;
    $index = $assoTargets.Substring(0, 1)
    $headers = Get-RequestHeaders $user $pass
    try
    {
        #Note: ADC have no API for get cert by name ($assoTargets), still need iterate over certs list.
        $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost/$target/certs"
        $url = "https://$hostAddrWithPort$apvRestfulUrl"
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        ($response | ConvertTo-Json)
        if ($response.SSLVirtualHost) {
            foreach ($cert in $response.SSLVirtualHost.certs) {
                if ($cert.index -eq $index) {
                    ("`ncert json ("+$assoTargets+"): `n" + $cert)
                    $pem = $cert.cert_text
                    <# Extract Cert. #>
                    $b64 = $pem.Replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----","").Replace("`n","")
                    $bytes = [Convert]::FromBase64String($b64)
                    $certObj = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$bytes)
                    return @{ Result="Success"; CertPem=$pem; Serial=$certObj.SerialNumber; Thumbprint=$certObj.Thumbprint }
                }
            }
        }
        throw "No certificate named '" + $assoTargets + "' was found on SSL_VH '$target': certIndex[$index]."
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__) {
            $statusCode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim()
        }
        if  ($_.Exception.Message) {
            $exceptionMessage = ($_.Exception.Message).ToString().Trim()
        }  
        # Check if there is a response.
        if ($_.Exception.Response) {
            # Get the response body with more error detail.
            $respStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($respStream)
            $respBody = $reader.ReadToEnd() | ConvertFrom-Json
            $errorMessage = $respBody.msg
            Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message $errorMessage
            throw $errorMessage
        }
        Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message ($statusCode +": "+$exceptionMessage)
        throw $exceptionMessage
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
    return @{ Result="NotUsed"; }
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
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Remove-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    return @{ Result="NotUsed"; }
}

<##################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    For discover Array ADC Virtual Services Certificates (activated) of all SSL Virtual Hosts
    The process will go througth all SSL Virtual Hosts of target ADC appliance and return all activated certificates 
    within all Virtaul Service
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Applications : 
##################################################################################################>

function Discover-Certificates {
    Param(
    [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    [System.Collections.Hashtable]$General
    )
    $hostAddrWithPort = $General.HostAddress+':'+$General.TcpPort
    $user = $General.UserName
    $pass = $General.UserPass

    $headers = Get-RequestHeaders $user $pass
    $apps = @()

    try {
        #"`n# Get SSL VH list"
        $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost"
        $url = "https://$hostAddrWithPort$apvRestfulUrl"

        $responseSslVhList = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        #$sslVhCount = $responseSslVhList.SSLVirtualHost.Count

        $target = $null
        $domainName = $null
        $certType = $null
        $assoTargets = $null
        if ($responseSslVhList.SSLVirtualHost) {
            foreach ($sslVh in $responseSslVhList.SSLVirtualHost) {
                $target = $sslVh.instance_id
                #$sslVhStatus = $sslVh.host_status
                #"`n# Get certificate list of "+ $target
                $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost/$target/certs"
                $url = "https://$hostAddrWithPort$apvRestfulUrl"
                $responseCerts = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

                if ($responseCerts.SSLVirtualHost.certs) {
                    #count certs
                    #$certCount = $responseCerts.SSLVirtualHost.certs.Count
                    #"`n# Total certs of SSL VH[$target]: "+ $certCount
                    #certificate is share with all virtual service
                    foreach ($cert in $responseCerts.SSLVirtualHost.certs) {
                        if ($cert.activated_state -eq $true) { # Get the activated cert.
                            $pem = $cert.cert_text
                            $index = $cert.index
                            $domainName = $cert.domain_name
                            $certType = $cert.type
                            $assoTargets = ("{0}-{1}-{2}" -f $index, $certType, $target)
                            if ($domainName) { #string not null or empty
                                $assoTargets = ("{0}-{1}-{2}-{3}" -f $index, $certType, $target, $domainName)
                            }
                            #"`n# Get the activated cert.: "+ $assoTargets
                            break
                        }
                    }
                    #"`n# Query all virtual services of [$target] and compose as an $ app"
                    $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost/$target/vs"
                    $url = "https://$hostAddrWithPort$apvRestfulUrl"
                    $responseSslVhVsList = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

                    foreach ($vs in $responseSslVhVsList.SSLVirtualHost.vs) {
                        $vsId = $vs

                        $apvRestfulUrl = "/rest/apv/loadbalancing/slb/vs/VirtualService/$vsId/default"
                        $url = "https://$hostAddrWithPort$apvRestfulUrl"
                        $responseVs = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
                        $validationAddress = $responseVs.VirtualService.vip
                        $validationPort = $responseVs.VirtualService.vport
                    
                        $app = @{
                            Name = $vsId; #Virtual Service which associate with SSL Virtual Host
                            PEM = $pem;
                            ValidationAddress = $validationAddress;
                            ValidationPort = $validationPort;
                            Attributes = @{ #The Attributes specified will be the variables used in the header
                                "Certificate Name" = $assoTargets;
                                "Text Field 1" = $target; #SSL VH Name
                                "Text Field 2" = $domainName;
                                <#
                                "Service Enabled" = $responseVs.VirtualService.enable;
                                "SSL VH Status" = $sslVhStatus;
                                "Total Certs Of SSL VH" = $certCount;
                                #>
                            }
                        }
                        "`n# $ app: "+$vsId
                        ($app | ConvertTo-Json)
                        $apps += $app
                    }
                }
            }
        }
        #"`n`n#### Array ADC [$hostAddrWithPort] : Total VirtualServices " + $apps.Count + " (found in $sslVhCount SSL VHs)"
        return @{ Result="Success"; Applications=$apps }
    } catch {
        if ($_.Exception.Response.StatusCode.value__) {
            $statusCode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim()
        }
        if  ($_.Exception.Message) {
            $exceptionMessage = ($_.Exception.Message).ToString().Trim()
        }  
        # Check if there is a response.
        if ($_.Exception.Response) {
            # Get the response body with more error detail.
            $respStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($respStream)
            $respBody = $reader.ReadToEnd() | ConvertFrom-Json
            $errorMessage = $respBody.msg
            Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message $errorMessage
            throw $errorMessage
        }
        Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message ($statusCode +": "+$exceptionMessage)
        throw $exceptionMessage;
    }
}

function Get-RequestHeaders([string] $user, [string] $pass) {
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$pass)))
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Basic {0}" -f $base64AuthInfo)
    #$headers.Add("Authorization", "Basic cmVzdDpyZXN0")
    $headers.Add("Accept", "application/json")
    return $headers
}

function Activate-ApvSslVh([string] $hostAddrWithPort, [string] $target, [string] $user, [string] $pass)
{
    try {
        $headers = Get-RequestHeaders $user $pass
        #"`n### Query(Get) status and Enable target SSL Virtual Host"
        $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost/$target/default/host_status"
        $url = "https://$hostAddrWithPort$apvRestfulUrl" 

        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        ($response| ConvertTo-Json)
        if ($response.SSLVirtualHost.host_status -eq $false) {
            $apvRestfulUrl = "/rest/apv/loadbalancing/slb/ssl/SSLVirtualHost/_Enable"
            $body = @{
                "targets" = $target;
            } | ConvertTo-Json
            $url = "https://$hostAddrWithPort$apvRestfulUrl" 
            $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
        }
    } catch {
        if ($_.Exception.Response.StatusCode.value__) {
            $statusCode = ($_.Exception.Response.StatusCode.value__ ).ToString().Trim()
        }
        if  ($_.Exception.Message) {
            $exceptionMessage = ($_.Exception.Message).ToString().Trim()
        }  
        # Check if there is a response.
        if ($_.Exception.Response) {
            # Get the response body with more error detail.
            $respStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($respStream)
            $respBody = $reader.ReadToEnd() | ConvertFrom-Json
            $errorMessage = $respBody.msg
            Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message $errorMessage
        }
        Write-EventLog -LogName "Application" -Source "Application Error" -EventID 3002 -EntryType Error -Message ($statusCode +": "+$exceptionMessage)
    }
}