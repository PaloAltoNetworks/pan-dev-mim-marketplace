<#
//---------------------------------------------------------------------------
// A10-Thunder.ps1
//
// Version 2.5.1
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// This software is licensed by A10 Networks, in addition to Venafi.
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
Text1|Virtual Server|101
Text2|Port Number (Default 443) |110
Text3|VPort Protocol (Default HTTPS)|110
Text4|Partition|110
Text5|Client SSL Template Name|101
Option1|Use Insecure Connection to Management Interface|010
Option2|UNUSED|000
Passwd|UNUSED|000
-----END FIELD DEFINITIONS-----
#>


Add-Type -AssemblyName System
Add-Type -AssemblyName System.Collections

if ( $PSVersionTable.PSEdition -eq 'Core' ) {
    # ps core, assume vaas
    $PSDefaultParameterValues['Invoke-WebRequest:SkipCertificateCheck'] = $true

    $script:logFileOut = $global:DEBUG_FILE
    $script:logFileError = $global:DEBUG_FILE
    $script:logFileDebug = $global:DEBUG_FILE

}
else {
    # need the following to interface with an untrusted certificate
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

    $script:base_path = "$(Get-Item -Path ".\")\venafi\"
    $script:logFileOut = $DEBUG_FILE -replace "debug.log$", "mdlog.txt"
    $script:logFileError = $DEBUG_FILE -replace "debug.log$", "mderr.txt"
    $script:logFileDebug = $DEBUG_FILE -replace "debug.log$", "mddebug.txt"

    $certName = "mynewcert"
    $certPass = [System.String]::Empty
    $keyName = "mynewkey"
    $vportName = "myhttpsport"
}



function Test-Connection {

    # VaaS connector test

    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Write-Log "Info" "Test-Connection"
    $null = Invoke-Authorization -General $General
    return @{ Result = "Success" }
}

function Write-Log {

    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('Debug', 'Error', 'Info')]
        [string]$type,

        [Parameter(Mandatory, Position = 1)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$msg
    )

    switch ($type) {
        "Debug" { $logFile = $script:logFileDebug }
        "Error" { $logFile = $script:logFileError }
        "Info" { $logFile = $script:logFileOut }
    }

    if ($logFile -and $msg) {
        Write-Output "[$(Get-Date)]     - $msg" | Out-File -FilePath $logFile -Append -Encoding ascii
    }
}
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
function Prepare-KeyStore {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result = "NotUsed"; }
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
function Generate-KeyPair {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed"; }
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
function Generate-CSR {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed"; }
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
function Install-Chain {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $chain = $null;
    $importedChain = $false;

    [bool]$importedChain = $false


    if ($Specific.ChainPkcs7) {

        Write-Log "Info" "Importing PKCS7 Chain..."

        try {
            $chain = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
            $chain.Import($Specific.ChainPkcs7)
            $importedChain = $true;
        }
        Catch {
            $ex = $_
            Write-Log "Error" $ex.message 
            $importedChain = $false;
        }
    }
    ElseIf ($Specific.ChainPem -and $Specific.ChainPem.Length -gt 0) {

        Write-Log "Info" "Importing PEM Chain..."

        try {
            $chain = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
            $chain.Import($Specific.ChainPem)
            $importedChain = $true;
        }
        Catch {
            $ex = $_
            Write-Log "Error" $ex.message
            $importedChain = $false;
        }

    }
    try {
        $authorization = Invoke-Authorization($General)
    }
    catch {
        $ex = $_
        Write-Log "Error" $ex.Exception.Message
        $importedChain = $false
        Write-Log "Error" $ex.Exception.InnerException
        throw "Authorization failed. Error: " + $ex.Exception.Message
    }

    $ctr = 0
    if ($chain -and $importedChain) {
        ForEach ($cert in $chain) {
            $ctr += 1
            try {
                Invoke-UploadCertificate -Authorization $authorization -Cert $cert -Ctr $ctr -General $General
            }
            catch {
                $ex = $_
                Write-Log "Error" $ex.Exception.Message
                $importedChain = $false
                Break
            }
        }
    }

    if (-not $importedChain) {
        throw "Certificate chain was not imported"
    }

    return @{ Result = "Success"; }
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
function Install-PrivateKey {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Write-Log "Info" "Importing Key..."

    if ($Specific.PrivKeyPemEncrypted.Length -gt 0) {
        # It's encrypted if there's a password
        $keyData = $Specific.PrivKeyPemEncrypted
    }

    if ($Specific.PrivKeyPem.Length -gt 0) {
        # It's not?
        $keyData = $Specific.PrivKeyPem
    }

    $encoder = New-Object System.Text.UTF8Encoding
    $keyBuffer = ($encoder.GetBytes($keyData) -as [byte[]])

    If ($keyBuffer.Length -gt 0) {
        try {
            $authorization = Invoke-Authorization($General)
        }
        catch {
            $ex = $_
            Write-Log "Error" $ex.Exception.Message
            Write-Log "Error" $ex.Exception.InnerException
            throw "Authorization failed. Error: " + $ex.Exception.Message
        }
        Try {
            Write-Log "Info" "Converted"
            Write-Log "Info" "Outputting... "

            $fileName = $General.AssetName
            $uri = Get-Uri($General)
            $uri = "$uri/file/ssl-key"
            $payload = @{ "ssl-key" = @{ file = "{0}_key" -f $fileName
                    #size                      = $keyData.Length
                    action                    = "import"
                    "file-handle"             = $fileName
                }
            }

            $payloadJson = $payload | ConvertTo-Json

            Invoke-PostMultipartForm -Authorization $authorization -File $keyData -Json $payloadJson -FileName $fileName -Uri $uri

            Write-Log "Info" "Imported... "
        }
        Catch {
            $ex = $_
            Write-Log "Error" $ex.Exception.Message
            throw "Private key installation failed. Error: " + $ex.Exception.Message
        }
    }

    return @{ Result = "Success"; } 
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
function Install-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    # Assume things don't work as a safety measure.
    [String]$certPass = ($Specific.EncryptPass -as [String])

    try {
        $authorization = Invoke-Authorization($General)
    }
    catch {
        $ex = $_
        Write-Log "Error" $ex.Exception.Message
        Write-Log "Error" $ex.Exception.InnerException
        throw "Authorization failed. Error: " + $ex.Exception.Message
    }

    try {

        Write-Log "Info" 'Begin Install Certificate'

        if (![String]::IsNullOrEmpty($Specific.CertPem)) {
            try {
                # If we have a PEM cert, we probably have PEM key and CA
                # Convert to byte array.
                Write-Log "Info" "Processing PEM Install"
                $pemCert = $Specific.CertPem
                if (-not [String]::IsNullOrWhiteSpace($certPass)) {
                    $pemKey = $Specific.PrivKeyPemEncrypted
                }
                else {
                    $pemKey = $Specific.PrivKeyPem
                }
                # in the future we might want to decrypt the private key if found here
                Invoke-UploadCertificate -Authorization $authorization -RawCert $pemCert -Ctr -1 -General $General
            }
            catch {
                Write-Log "Error" $_.Exception
                throw "Certificate upload failed. Error: " + $_.Exception.Message
            }
        }
    }
    catch {
        Write-Log "Error" $_.Exception
        throw "Certificate upload failed. Error: " + $_.Exception.Message
    }
    Write-Log "Info" "PREOP"

    if ($null -ne $pemKey -and $pemKey.Length -gt 0) {
        Write-Log "Info" "pemKey found, sending"
        Try {
            Write-Log "Info" "Converted"
            Write-Log "Info" "Outputting... "

            $fileName = $General.AssetName
            $keyName = "{0}_key" -f $assetName
            $uri = Get-Uri($General)
            $uri = "$uri/file/ssl-key"
            $payload = @{ "ssl-key" = @{ file = $fileName
                    #size                      = $pemKey.Length
                    action                    = "import"
                    "file-handle"             = $fileName
                }
            }

            $payloadJson = $payload | ConvertTo-Json
            Invoke-PostMultipartForm -Authorization $authorization -File $pemKey -Json $payloadJson -FileName $fileName -Uri $uri

            Write-Log "Info" "Imported... "
        }
        Catch {
            $ex = $_
            Write-Log "Error" $ex.Exception.Message
            "Certificate upload failed. Error: " + $ex.Exception.Message
        }
    }

    return @{Result = "Success"}
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
function Update-Binding {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    try {
        $vportName = $General.VarText1
        $vPortNumberRaw = $General.VarText2
        $vportProtocolRaw = ($General.VarText3 -as [String])
        # this variable does not seem to be being properly passed in
        $vpass = $General.VarPass
        [System.UInt16]$vportNumber = 443

        if ($vportNumberRaw.Length -gt 0) {
            try {
                $vportNumber = [System.Convert]::ToUInt16($vportNumberRaw)

                if (-not $vportNumber -gt 0) {
                    $vportNumber = 443
                }
            }
            catch {
                $vportNumber = 443
            }
        }

        if ($vportProtocolRaw.Length -gt 0) {
            $vportProtocol = $vportProtocolRaw
        }
        else {
            $vportProtocol = "https"
        }
        Write-Log "Info" "Update Binding.."
        $assetName = $General.AssetName
        #Write-Log "Info" $General.AssetName
        $templateName = $General.VarText5
        $certName = $assetName
        $keyName = "{0}_key" -f $assetName
        $chainName = "{0}_chain" -f $assetName

        $authorization = Invoke-Authorization($General)
        $headers = @{ 'Authorization' = $authorization }
        # check if template with the same name already exists
        #Write-Log "Info" "template name:: $templateName"
        $template = Get-CertsFromTemplate -authorization $authorization -templateName $templateName -General $General
        #Write-Log "Info" "Template Exists: $template"
        $commonParams = @{
            Headers         = $headers
            UseBasicParsing = $true
        }

        if ($template -eq "" -or $template.cert -eq $null) {
            $payload = @{
                    "client-ssl"= @{
                        "name"= $templateName
                        "certificate"= @{
                                    "cert"= $certName
                                    "key"= $keyName
                                }
                    }
                }
            
            $payloadJson = $payload | ConvertTo-Json -Depth 5
            $uri = Get-Uri($General)
            $uri = "$uri/slb/template/client-ssl"
            #Write-Log "Info" "uri: $uri" 
            #Write-Log "Info" "payload: $payloadJson"
            $null = Invoke-WebRequest -Uri $uri -Method POST -Body $payloadJson -ContentType "application/json" @commonParams
            #Write-Log "Info" "Created Template $templateName"
        }
        else {
            $payload = @{
                    "certificate" = @{
                            "cert"         = $certName
                            "key"          = $keyName
                        }
            }
            $payloadJson = $payload | ConvertTo-Json -Depth 5
            $uri = Get-Uri($General)
            #Write-Log "Info" "certName ($certName) == $template.cert"
            if($certName -eq $template.cert) {
                #For Push
                $uri = "$uri/slb/template/client-ssl/$templateName/certificate/$certName"
            }
            else {
                #For Renewal
                $uri = "$uri/slb/template/client-ssl/$templateName/certificate/"
            }
            #Write-Log "Info" "Updating Template:"
            #Write-Log "Info" "uri: $uri"
            #Write-Log "Info" "payload: $payloadJson"
            $null = Invoke-WebRequest -Uri $uri -Method POST -Body $payloadJson -ContentType "application/json" @commonParams
            #Write-Log "Info" "Updated Template $templateName"
        }
    }
    catch { 
        throw $_.Exception.Message
    }
    Try {
        #Write-Log "Info" "Associating Template $templateName with $vportProtocol"

        $uri = Get-Uri($General)

        $uri = "$uri/slb/virtual-server/$vportname/port/$vportNumber+$vportProtocol"
        try {
            #Write-Log "Info" "uri: $uri"
            $response = Invoke-WebRequest -Uri $uri -Method GET @commonParams
            #Write-Log "Info" "response: $response"
        }
        catch {
            $msg = 'Protocol {0} and port {1} combination not found on this virtual server' -f $vportProtocol, $vportNumber
            Write-Log "Error" $msg
            throw $msg
        }
        $vport = $response.Content | ConvertFrom-Json
        $vport.port.psobject.properties | ForEach-Object -begin { $h = @{} } -process { $h."$($_.Name)" = $_.Value }

        $h["template-client-ssl"] = $templateName
        $body = @{
            port = $h
        }
        $json = $body | ConvertTo-Json -Depth 4
        $response = Invoke-WebRequest -Uri $uri -Body $json -Method PUT -ContentType "application/json" @commonParams
        Write-Log "Info" $response.StatusCode
    }
    Catch {
        $ex = $_
        Write-Log "Error" $ex.Exception
        Write-Log "Error" $ex.Exception.InnerException
        $ex.Exception.Data | ForEach-Object {
            Write-Log "Error" $_.Key
            Write-Log "Error" $_.Value
        }
        throw "Binding to template failed. Error: " + $ex.Exception.Message
    }

    return @{ Result = "Success"; }
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
function Activate-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result = "NotUsed"; }
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
function Extract-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    $certName = $General.AssetName

    try {
        #Write-Log "Info" "Extract Certificate"
        $authorization = Invoke-Authorization($General)
        $headers = @{ 'Authorization' = $authorization }
        $uri = Get-Uri($General)
        $uri = "$uri/ssl/certificate/$certName"
        $params = @{
            Uri             = $uri
            Method          = 'GET'
            Headers         = $headers
            UseBasicParsing = $true
        }
        $response = Invoke-WebRequest @params
        #Write-Log "Info" $response
        if ( $response.StatusCode -ne 200) {
            Write-Log "Error" "Could not retrieve ssl certificate.  Status code: $($response.StatusCode)"
            throw "Could not retrieve ssl certificate.  Status code: $($response.StatusCode)"
        }
        $pem = $response.Content
        $index = $pem.IndexOf("-----BEGIN CERTIFICATE-----")
        $pem = $pem.Substring($index)
    }
    Catch {
        $ex = $_
        Write-Log "Error" $ex.Exception
        Write-Log "Error" $ex.Exception.InnerException
        $ex.Exception.Data | ForEach-Object {
            Write-Log "Error" $_.Key
            Write-Log "Error" $_.Value
        }
        throw "Certificate discovery failed. Error: " + $ex.Exception.Message
    }
    return @{ Result = "Success"; CertPem = $pem; Serial = ""; Thumprint = "" }
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
function Extract-PrivateKey {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed"; }
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
function Remove-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed"; }
}


<##################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    Gets a list of all of the Client SSL Certificates belonging to the authenticated account.
.NOTES
    Returns...
        Result : IEnumerable<ClientSsl>
##################################################################################################>
function Discover-Certificates() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    $result = Get-VirtualServers($General)
    if ($result.Result -ne "Success") {
        throw "Get virtual servers failed."
    }
    $apps = [System.Collections.ArrayList]@()
    try {
        $authorization = Invoke-Authorization($General)
        $headers = @{ 'Authorization' = $authorization }
        foreach ( $server in $result.Applications ) {
            foreach ($port in $server.'port-list') {
                $TemplateName = $port.'template-client-ssl'
                $Port = $port.'port-number'

                $certList = Get-CertsFromTemplate -authorization $authorization -templateName $TemplateName -General $General

                foreach ($cert in $certList)
                {
                    $certName = $cert.cert

                    $uri = Get-Uri($General)
                    $uri = "$uri/ssl/certificate/$certName"

                    $params = @{
                        Uri             = $uri
                        Method          = 'GET'
                        Headers         = $headers
                        UseBasicParsing = $true
                    }
                    $response = Invoke-WebRequest @params

                    if ( $response.StatusCode -ne 200) {
                        Write-Log "Error" "Could not retrieve ssl certificate.  Status code: $($response.StatusCode)"
                        throw "Could not retrieve ssl certificate.  Status code: $($response.StatusCode)"
                    }
                    $pem = $response.Content
                    $index = $pem.IndexOf("-----BEGIN CERTIFICATE-----")
                    $pem = $pem.Substring($index)
                    $indexstop = $pem.IndexOf("-----END CERTIFICATE-----") + 26
                    $pem = $pem.Substring(0, $indexstop) 
                    $apps.Add( @{
                            Name             = $server.name;
                            ApplicationClass = "Adaptable App";
                            PEM              = $pem;
                            Attributes       = @{
                                "Text Field 1" = $server.name;
                                "Text Field 2" = $Port;
                                "Text Field 5" = $TemplateName;
                            }
                        })
                }
            }
        }
    }
    Catch {
        $ex = $_
        Write-Log "Error" $ex.Exception
        Write-Log "Error" $ex.Exception.InnerException
        $ex.Exception.Data | ForEach-Object {
            Write-Log "Error" $_.Key
            Write-Log "Error" $_.Value
        }
        throw "Certificate discovery failed. Error: " + $ex.Exception.Message
    }
    return @{ Result = "Success"; Applications = $apps.ToArray() }
}

<##################################################################################################
.NAME
    Get-VirtualServers
.DESCRIPTION
	Gets a list all of the Virtual Servers belonging to the authenticated account.
.NOTES
    Returns...
        Result : IEnumerable<VirtualServer>
##################################################################################################>
function Get-VirtualServers() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    try {
        $authorization = Invoke-Authorization($General)
        $headers = @{ 'Authorization' = $authorization }
        $uri = Get-Uri($General)
        $uri = "$uri/slb/virtual-server"
        $params = @{
            Uri             = $uri
            Method          = 'GET'
            Headers         = $headers
            UseBasicParsing = $true
        }
        $response = Invoke-WebRequest @params
        if ( $response.StatusCode -eq 204) {
            return @{ Result = "Success" }
        }
        #Write-Log "Info" $response.Content
        $servers = $response.Content | ConvertFrom-Json
        $apps = $servers.'virtual-server-list'
        return @{ Result = "Success"; Applications = $apps }
    }
    Catch {
        $ex = $_
        Write-Log "Error" $ex.Exception
        Write-Log "Error" $ex.Exception.InnerException
        $ex.Exception.Data | ForEach-Object {
            Write-Log "Error" $_.Key
            Write-Log "Error" $_.Value
        }
        return @{ Result = "Error" }
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Get-Uri {
    [OutputType([String])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    $hostAddress = $General["HostAddress"]
    $port = $General["TcpPort"]
    if ( -not $port ) { $port = '443' }
    return "https://${hostAddress}:$port/axapi/v3"
}

function Invoke-Authorization {
    [OutputType([string])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    #Write-Log "Info" "Invoke-Authorization"
    $hash = @{
        credentials = @{
            username = $General["UserName"]
            password = $General["UserPass"]
        }
    }
    $json = $hash | ConvertTo-Json
    $uri = Get-Uri($General)
    $uri = "$uri/auth"

    $params = @{
        Uri             = $uri
        Method          = 'POST'
        Body            = $json
        ContentType     = 'application/json'
        UseBasicParsing = $true
    }
    $response = Invoke-WebRequest @params

    $auth = $response.Content | ConvertFrom-Json
    $signature = $auth.authresponse.signature
    return "A10 $signature"
}

function Invoke-UploadCertificate {
    [CmdletBinding()]
    param(
        [Parameter()]
        [String]
        $Authorization,

        [Parameter()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Cert,

        [Parameter()]
        [int]
        $Ctr,

        [Parameter()]
        [String]
        $RawCert,

        [Parameter()]
        [System.Collections.Hashtable]$General
    )
    Write-Log "Info" "Invoke-UploadCertificate"
    if ($Cert) {
        $caCertData = ($Cert.RawData -as [byte[]])
        $encodedCert = "-----BEGIN CERTIFICATE-----`r`n$([Convert]::ToBase64String($caCertData, [System.Base64FormattingOptions]::InsertLineBreaks))`r`n-----END CERTIFICATE-----"
    }
    else {
        $encodedCert = $RawCert
    }

    if ($Ctr -lt 0) {
        $fname = $General.AssetName
    }
    else {
        $fname = "{0}-{1}" -f $General.AssetName, $Ctr
    }
    $caCertName = $fname.Replace("adaptable.", "")
    #Write-Log "Info" "caCertName = $caCertname"
    $payload = @{
        "ssl-cert" = @{
            action             = "import"
            "certificate-type" = "pem"
            "file-handle"      = $caCertName
            file               = $caCertName
            #size               = $encodedCert.Length
        }
    }
    $payloadJson = $payload | ConvertTo-Json
    $uri = Get-Uri($General)
    $uri = "$uri/file/ssl-cert"
    Invoke-PostMultipartForm -Uri $uri -FileName $caCertName -Json $payloadJson -File $encodedCert -Authorization $Authorization
}

function Invoke-PostMultipartForm {
    [CmdletBinding()]
    param(
        [Parameter()]
        [String]
        $Uri,

        [Parameter()]
        [String]
        $FileName,

        [Parameter()]
        [String]
        $Json,

        [Parameter()]
        [String]
        $File,

        [Parameter()]
        [String]
        $Authorization
    )

    $boundary = [System.Guid]::NewGuid().ToString()

    $contentType = "multipart/form-data; boundary=$boundary"

    $body = "--$boundary`r`nContent-Disposition: form-data; name=`"json`"; filename=`"blob`"" + `
        "`r`nContent-Type: application/json" + `
        "`r`n`r`n$Json" + `
        "`r`n--$boundary`r`nContent-Disposition: form-data; name=`"file`"; filename=`"$FileName`"" + `
        "`r`nContent-Type: application/octet-stream" + `
        "`r`n`r`n$File" + `
        "`r`n--$boundary--`r`n"

    # $body = "--$boundary$([System.Environment]::NewLine)Content-Disposition: form-data; name=`"json`"; filename=`"blob`"" + `
    #     "$([System.Environment]::NewLine)Content-Type: application/json" + `
    #     "$([System.Environment]::NewLine)$([System.Environment]::NewLine)$Json" + `
    #     "$([System.Environment]::NewLine)--$boundary$([System.Environment]::NewLine)Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`"" + `
    #     "$([System.Environment]::NewLine)Content-Type: application/octet-stream" + `
    #     "$([System.Environment]::NewLine)$([System.Environment]::NewLine)$File" + `
    #     "$([System.Environment]::NewLine)--$boundary--$([System.Environment]::NewLine)"

    $headers = @{ 'Authorization' = $Authorization }

    $params = @{
        Uri             = $uri
        Method          = 'POST'
        Body            = $body
        ContentType     = $contentType
        Headers         = $headers
        UseBasicParsing = $true
    }

    $response = Invoke-WebRequest @params
}

function Get-CertsFromTemplate {
    [CmdletBinding()]
    param(
        [Parameter()] [String] $authorization,
        [Parameter()] [String] $templateName,
        [Parameter()] [System.Collections.Hashtable] $General
    )
    try {
        $uri = Get-Uri($General)
        $uri = "$uri/slb/template/client-ssl/{0}" -f $templateName
        
        #Write-Log "Info" "Get certs from Template:..."
        #Write-Log "Info" "uri: $uri"

        $headers = @{ 'Authorization' = $authorization }

        $params = @{
            Uri             = $uri
            Method          = 'GET'
            Headers         = $headers
            UseBasicParsing = $true
        }
        $response = Invoke-WebRequest @params
        $content = $response.Content | ConvertFrom-Json
        $clientSSL = $content.'client-ssl'
        $certs = $clientSSL.'certificate-list'
        
        #Write-Log "Info" "Response: $response"
        return $certs
    }
    catch {
        Write-Log "Info" "No Certs found"
        return ""
    }
}
