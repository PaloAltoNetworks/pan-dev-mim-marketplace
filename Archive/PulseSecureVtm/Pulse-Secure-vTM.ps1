<#
//---------------------------------------------------------------------------
// Ivanti vTM.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2020 Venafi, Inc. All rights reserved.
//
// This software is licensed by Ivanti, in addition to Venafi.
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
Text1|vTM API Version |111
Text2|Text2 (Enabled-Policyable-Optional)|000
Text3|Text3 (Enabled-NonPolicy-Mandatory)|000
Text4|Text4 (Enabled-NonPolicy-Optional)|000
Text5|Text5 (Disabled)|000
Option1|Option1 (Enabled-Policyable-Mandatory)|000
Option2|Option2 (Enabled-NonPolicy-Mandatory)|000
Passwd|Password (Enabled-Policyable-Optional)|000
-----END FIELD DEFINITIONS-----
# #>

$global:base_path = "$(Get-Item -Path ".\")\venafi\"
$global:logFileOut = $DEBUG_FILE -replace "debug.log$", "mdlog.txt"
$global:logFileError = $DEBUG_FILE -replace "debug.log$", "mderr.txt"
$global:logFileDebug = $DEBUG_FILE -replace "debug.log$", "mddebug.txt"

function Write-Log ([string]$type, [string]$msg) {
    switch ($type) {
        "Debug" { $logFile = $global:logFileDebug }
        "Error" { $logFile = $global:logFileError }
        "Info" { $logFile = $global:logFileOut }
    }
    if ($logFile -ne "" -And $msg -ne "") {
        Write-Output "[$(Get-Date)]     - $msg" | Out-File $logFile -Append -Encoding ascii
    }
}

Add-Type -AssemblyName System
Add-Type -AssemblyName System.Collections

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

#TLS1.2 Support
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
   

    return @{ Result = "NotUsed"; }
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

    return @{ Result = "NotUsed"; }
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
    Write-Log "Info" "#################### Starting Certificate Install Process ####################"
    Write-Log "Info" "Installing $($General.AssetName) Certificate"
    $addr = $General.HostAddress
    $user = $General.UserName
    $pass = $General.UserPass
    $version = $General.VarText1
    $certName = $General.AssetName
    $credentials = "$($user):$($pass)"
    $EncodedCredential = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))
    $headers = @{ Authorization = "Basic $EncodedCredential"; Accept = "application/json"; 'Content-Type' = "application/json" }
    $result = "Success"
   
    try {
        Write-Log "Info" "Creating Request Body"
        $body = @{
            "properties" = @{
                "basic" = @{
                    "note"    = ""
                    "private" = "$($Specific.PrivKeyPem)"
                    "public"  = "$($Specific.CertPem)"
                }
            }
        } | ConvertTo-Json
        Write-Log "Info" "Creating Request URL"
        $url = "https://$($addr):9070/api/tm/$($version)/config/active/ssl/server_keys/$($certName)"
        Write-Log "Info" "Sending API Request to create Certificate"
        $rcert = Invoke-restmethod $url -Method PUT -Headers $headers -ContentType application/json -Body $body
        
    }
    catch {
        $ex = $_
        Write-Log "Error" $ex.Exception.Message
        $result = "NotUsed"
    }
    return @{ Result = "$($result)"; AssetName = "$($certName)" }
    
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
    Write-Log "Info" "#################### Starting Binding Process ####################"

    Write-Log "Info" "Getting General Information"
    $addr = $General.HostAddress
    $user = $General.UserName
    $pass = $General.UserPass
    $version = $General.VarText1
    $certName = $General.AssetName
    $Server = $General.AppObjectDN -split "\\"
    $credentials = "$($user):$($pass)"
    $EncodedCredential = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Basic $($EncodedCredential)")
    $headers.Add("Content-Type", "application/json")
    
    $result = "Success"
   
    try {
        
        $body = @{
            properties = @{
                ssl = @{
                    server_cert_default = "$($certName)"
                }
            }
        } | ConvertTo-Json -Compress
        Write-Log "Info" "Creating Request Body: $($body)"
        $url = "https://$($addr):9070/api/tm/$($version)/config/active/virtual_servers/$($Server[$Server.length -1])"

        Write-Log "Info" "Creating Request URL: $($url)"
        Write-Log "Info" "Sending API Request to create Certificate"
        $rcert = Invoke-restmethod $url -Method 'PUT' -Headers $headers -Body $body
        Write-Log "Info" $rcert | ConvertTo-Json -Depth 4
      
    }
    catch {
        $ex = $_
        Write-Log "Error" "Binding Error: $($ex.Exception.Message)"
        $result = "NotUsed"
        
    }

    return @{ Result = "$($result)"; }
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
    Write-Log "Info" "#################### Starting Extraction Process ####################"
    Write-Log "Info" "Getting General Information"
    $addr = $General.HostAddress
    $user = $General.UserName
    $pass = $General.UserPass
    $version = $General.VarText1
    $certName = $General.AssetName
    $credentials = "$($user):$($pass)"
    $EncodedCredential = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))
    $headers = @{ Authorization = "Basic $EncodedCredential"; Accept = "application/json"; 'Content-Type' = "application/json" }
    $result = "Success"

    try {
        Write-Log "Info" "Creating Request URL"
        $url = "https://$($addr):9070/api/tm/$($version)/config/active/ssl/server_keys/$($certName)"
        Write-Log "Info" $url
        Write-Log "Info" "Sending API Request"
        $response = Invoke-restmethod $url -Method GET -Headers $headers 
        Write-Log "Info" ($response | ConvertTo-Json -Depth 4)
        $pem = $response.properties.basic.public -replace '\n', ''
        Write-Log "Info" "Getting Pem data: $($pem)"
        
        $bytes = [Convert]::FromBase64String($pem.Replace("-----BEGIN CERTIFICATE-----", "").Replace("-----END CERTIFICATE-----", ""))
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($bytes)
        Write-Log "Info" "Getting Serial number: $($cert.SerialNumber) and thumbprint: $($cert.Thumbprint)"
         
    }
    catch {
        $ex = $_
        Write-Log "Error" "Extraction Error: $($ex.Exception.Message)"
        $result = "NotUsed"
    }


    return @{ Result = "$result"; CertPem = "$pem"; Serial = "$($cert.SerialNumber)"; Thumprint = "$($cert.Thumbprint)" }
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
    Create script such that the cert is not directly tied to a active vr server Add logic to prevent the removal
    return @{ Result = "Success"; }
}

<######################################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    Discovers certificates and their instance metadata from a target device
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
.NOTES
    Returns...
        Result : 'Success' to indicate the non-error completion state
        Applications : an array of hashtables that include the following data for a certificate instance:
            Name - the name of the application object that represents this instance under the device object
            ApplicationClass - the schema class of the application object (defaults to 'Adaptable App')
            DriverName - the value of the Driver Name attribute (defaults to 'appadaptable')
            PEM - the raw X509 certificate in base64 encoded text format
            ValidationAddress - FQDN, hostname, or IP address where the server is presenting the certificate
            ValidationPort - TCP port on which the server is presending the certificate (integer between 1-65535, defaults to 443)
            Attributes - a hashtable that specifies zero or more Config attribute-value pairs to set on the application object
######################################################################################################################>
function Discover-Certificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    try {
        Write-Log "Info" "#################### Starting Discovery Process ####################"
        $addr = $General.HostAddress
        $user = $General.UserName
        $pass = $General.UserPass
        $version = "8.3"
        $credentials = "$($user):$($pass)"
        $EncodedCredential = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))
        $headers = @{ Authorization = "Basic $EncodedCredential"; Accept = "application/json"; 'Content-Type' = "application/json" }
    
		
        $url = "https://$($addr):9070/api/tm/$($version)/config/active/virtual_servers/"
        Write-Log "Info" "Creating Virtual ServerList Url: $($url)"
        Write-Log "Info" "Requesting a list of all virtual Servers"
        $response = Invoke-restmethod $url -Method GET -Headers $headers 
      
        $apps = @()
        Write-Log "Info" "Looping through the list of the servers"
        foreach ($vserver in $response.children) {
            #$obj = New-Object PSObject
            Write-Log "Info" "Getting Individual Server information for $($vserver.name)"
            $url = "https://$($addr):9070/api/tm/$($version)/config/active/virtual_servers/$($vserver.name)"
            Write-Log "Info" "Getting Individual Server URL for $($vserver.name): $($url)"
            $rserver = Invoke-restmethod $url -Method GET -Headers $headers
            Write-Log "Info" "Getting Individual Server Certificate for $($vserver.name)"
            $surl = "https://$($addr):9070/api/tm/$($version)/config/active/ssl/server_keys/$($rserver.properties.ssl.server_cert_default)"
            Write-Log "Info" "Getting Individual Server Certificate URL for $($vserver.name): $($surl)"
            Write-Log "Info" "Requesting Individual Server Certificate information for $($vserver.name)"
            $pem = Invoke-restmethod $surl -Method GET -Headers $headers 
            Write-Log "Info" "Response Request for $($vserver.name): $pem"
			if($rserver.properties.basic.ssl_decrypt){
				Write-Log "Info" "Creating Virtual Service Hashtable"
				$apps += @{
					Name              = $vserver.name
					ApplicationClass  = "Adaptable App"
					DriverName        = "appadaptable"
					PEM               = ($pem.properties.basic.public -replace '\n', '')
				  #  ValidationAddress = $rserver.properties.basic.listen_on_hosts
				   # ValidationPort    = $rserver.properties.basic.port
				} 
			}
			Write-Log "Info" "Unable to create hash for $($vserver.name) Becasue it does not contains a valid certificate"
			
        }
        Write-Log "Info" "Application data: $($apps | Convertto-json)"
        $result = "Success"
        Write-Log "Info" "Discovery Complete"
    }
    catch {
		Write-Log "Info" "Error: $($ex.Exception.Message)"
        $result = "Error"
        
    }


   
    return @{ Result = $result ; Applications = $apps }
}
<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>