<#
//-----------------------------------------------------------------------------
//Venafi Adaptable Driver for F5 Silverline
//    Version:  1.01a
//    Author:   Scott Altman, scott@f5.com
//    Support:  support@f5silverline.com
//    API Spec: https://portal.f5silverline.com/docs/api/v1/index.md
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by F5, in addition to Venafi.
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
Text1|F5 Silverline Cert/Key Name|101
Option1|Enable Driver Debugging|100
-----END FIELD DEFINITIONS-----
#>

$base_path = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs"

Try # to write to the directory
{
    $temp_file = $base_path + "\_verify_access"
    [IO.File]::OpenWrite($temp_file).Close()
    [IO.File]::Delete($temp_file)
}
Catch
{
    $base_path = (Get-Location).Path
}

$global:file_prefix = $base_path + "\AdaptableAppDebug_"
$global:temp_dir = $base_path + "\Temp"

If ( !(Test-Path $global:temp_dir) )
{
   New-Item $global:temp_dir -Type Directory
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
        
F5 Silverline Notes
    This function is not used.  F5 Silverline does not presently support remote Cert/Key Generation.
##################################################################################################>
function Prepare-KeyStore
{
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General
    # )
    # $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    # "`n##### GENERAL PARAMETERS #####" | Out-File $file
    # $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    # $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
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
        
F5 Silverline Notes
    This function is not used.  F5 Silverline does not presently support remote Cert/Key Generation.
##################################################################################################>
function Generate-KeyPair
{
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General,
    #     [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
    #     [System.Collections.Hashtable]$Specific
    # )
    # 
    # $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    # 
    # "`n##### GENERAL PARAMETERS #####" | Out-File $file
    # $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    # $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
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
        
F5 Silverline Notes
    This function is not used.  F5 Silverline does not presently support remote Cert/Key Generation.
##################################################################################################>
function Generate-CSR
{
#     Param(
#         [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
#         [System.Collections.Hashtable]$General,
#         [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
#         [System.Collections.Hashtable]$Specific
#     )
# 
#     $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
# 
#     "`n##### GENERAL PARAMETERS #####" | Out-File $file
#     $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
# 
#     "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
#     $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
# 
#     $csr = @"
# -----BEGIN CERTIFICATE REQUEST-----
# MIIDkTCCAnkCAQAwgb4xCzAJBgNVBAYTAlVTMQ0wCwYDVQQIEwRVdGFoMRcwFQYD
# VQQHEw5TYWx0IExha2UgQ2l0eTEVMBMGA1UEChMMVmVuYWZpLCBJbmMuMRswGQYD
# VQQLExJQcm9kdWN0IE1hbmFnZW1lbnQxFDASBgNVBAsTC0VuZ2luZWVyaW5nMRow
# GAYDVQQLExFRdWFsaXR5IEFzc3VyYW5jZTEhMB8GA1UEAxMYYWRhcHRhYmxlLnZl
# bmFmaS5leGFtcGxlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAscwz
# g3g4dcg+ZqBcHqUBsUqGBjyGwGVy2ZWYxDlvp0tCbmj0lyGSZEmWNuYH/XtZT1T/
# ULnSvj/SNw2KINuRESHXoRqnSKPTTnqdIPoylguNB0x9jIRwt5Zg24JN3VA0rIYY
# /pgUzUa1udpZPHcmIbxRYnI0TikMr7LerPRh7aKEPzT3dK59Cax2K66d3Qbnl3YD
# GFR2V6rJZOqNBsnNmRbuCfDJZ3DygXlQ8u5fuiMgvke3GmNda//i9cfqs52xP5BT
# C90h0RJ04cNuWBlm5NFnI/qTbOMkMw1lJQyMn4MGSoR7N+B+08ecvybgoJwl6l6L
# GiKPjd1WpMao2lQNgQIDAQABoIGMMIGJBgkqhkiG9w0BCQ4xfDB6MHgGA1UdEQRx
# MG+CGGFkYXB0YWJsZS52ZW5hZmkuZXhhbXBsZYIZYWRhcHRhYmxlMS52ZW5hZmku
# ZXhhbXBsZYIZYWRhcHRhYmxlMi52ZW5hZmkuZXhhbXBsZYEXam9obi5kb2VAdmVu
# YWZpLmV4YW1wbGWHBAoUHigwDQYJKoZIhvcNAQELBQADggEBAKp/KZPVa66hPc2z
# W2XrjDPV5T4yTDukowl5c2p5TfrTSsoCW5TrC+Qvr56YrPhTrNaKO9YbVn967NgC
# COFBRqrBlpWmjdZVHrNavbYYCvpi2lh6odh1CWgU4tJCADfUoyiJ5kCQUC5fKWRe
# CgfH57Ksw7o+HbxnpRw/7apdr3fUezSfcTel3Z0nJeFryorDMujK8P+8WkrdzOxy
# u+AkPGQieXbnguQxOq6vI6LVpD3iJWAW3US5vEA5w9bXDa1QzVNjQ0mTElu37Xa4
# PACcaBR82fkFpwiBkdQ0pF8POgZNJW9PBoCh7gy1i4v5W8iH85pKZbqmP6MAkxKv
# tum6ysQ=
# -----END CERTIFICATE REQUEST-----
# "@
# 
#     $name = (Get-Date).ToUniversalTime().ToString("yyMMdd-HHmmss")
#     $name = "adaptable.venafi.example_" + $name
#    return @{ Result="NotUsed"; Pkcs10=$csr; AssetName=$name }
    return @{ Result="NotUsed" }
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
        
F5 Silverline Notes
    This function is not used.  The chain/intermediate certificates are installed with the Install-Certificate function
##################################################################################################>
function Install-Chain
{
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General,
    #     [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
    #     [System.Collections.Hashtable]$Specific
    # )
    # 
    # $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    # 
    # "`n##### GENERAL PARAMETERS #####" | Out-File $file
    # $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    # $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # if ( $Specific.ChainPkcs7 )
    # {
    #     $chain = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    #     $chain.Import( $Specific.ChainPkcs7 )
    # 
    #     foreach ( $cert in $chain )
    #     {
    #         $cert.Subject | Out-File $file -Append
    #     }
    # 
    #     [IO.File]::WriteAllBytes($global:temp_dir + "\chain.p7b", $Specific.ChainPkcs7)
    # }
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
        
F5 Silverline Notes
    This function is not used.  The private key is installed with the Install-Certificate function
##################################################################################################>
function Install-PrivateKey
{
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General,
    #     [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
    #     [System.Collections.Hashtable]$Specific
    # )
    # 
    # $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    # $basename = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
    # 
    # "`n##### GENERAL PARAMETERS #####" | Out-File $file
    # $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    # $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # if ( $Specific.EncryptPass )
    # {
    #     $Specific.PrivKeyPemEncrypted | Out-File $($global:temp_dir + "\" + $basename + ".key")
    # }
    # else
    # {
    #     $Specific.PrivKeyPem | Out-File $($global:temp_dir + "\" + $basename + ".key")
    # }
    # 
    # //return @{ Result="Success"; AssetName=$basename}
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
        ChainPem : all chain certificates concatentated together one after the other  --  Issuer, Intermediate, Root (per Ben)
        ChainPkcs7 : byte array PKCS#7 collection that includes all chain certificates
        Pkcs12 : byte array PKCS#12 collection that includes certificate, private key, and chain
        EncryptPass : the string password that was used to encrypt the private key and PKCS#12 keystore
.NOTES
    Returns...
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-error completion state (may only be 'NotUsed' if Install-PrivateKey did not return 'NotUsed')
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed

###
F5 Silverline Implementation Notes
    - The F5 Silverline API for Certificate and Key management handle the installation of the Certificate, Key and Intermediates in a single "create" API call
    - The API will first check to see if the Cert/Key object already exists, if it does, it will send an Update/PUT if it doesn't, it will send a Create/POST
    - All API calls to F5 Silverline require an API Token that is generated in the Silverline portal by the customer; the API key is set in the Password field for the Adaptable Driver
    - The API Token value must be included as a X-Authorization-Token header
    - API Endpoint for Production use is:  portal.f5silverline.com:443
    - AssetName is not used by the Install Certificate function; the F5 Cert/Key object is defined by the additional text field and includes RegEx validation

API HTTP Method:  POST

JSON Data Structure:
	"data": {
		"type": "ssl_certificates",
		"attributes": {
			"name": "certKey1",
			"passphrase": "admin123",
			"certificate": "-----BEGIN CERTIFICATE-----",
			"key": "-----BEGIN RSA PRIVATE KEY-----",
			"intermediates": [{
				"certificate": "-----BEGIN CERTIFICATE-----"
			}],
			"note": "This is my Cert & Key!"
		}
	}
}

Details:
    type:                Required, must be "ssl_certificates" to differentiate from other API call types
    attributes:          Required, a JSON Array containing...
        name:            Required, must be unique within the Silverline customer; attempting to create a new SSL Certificate & Key object with a duplicate name will result in a failed API call; HTTP XXX (ERROR)
                         Name attribute does not support . as a valid naming convention
        passphrase:      Optional, the passphrase used for key encryption
        certificate:     Required, the X509 certificate to be installed in Base64 PEM format
        key:             Required, the key associated with the certificate in either encrypted or un-encrypted Base64 PEM format
        intermediates:   Optional, a JSON array containing...
           certificate: the specific intermediate certificate to be installed at this position; order is implied based on location in the JSON array
        note:            Optional, a free text field available to users

API Response Codes:
    201 Created - The Create request was successfully processed

##################################################################################################>
function Install-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $debug = $FALSE
    if ( $General.VarBool1 -eq $TRUE ) {
        $debug=$TRUE

        ### Establish Logging
        $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
        if ( $debug ) { "##### DEBUG ENABLED" | Out-File $file }
        "`n##### GENERAL PARAMETERS #####" | Out-File $file - Append
        $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
        "`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
        $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    }

    $certKey = $General.VarText1 
    ### Validate F5 Silverline Cert/Key Object Name contains appropriate characters [a-z0-9A-Z_\-]
    if($certKey -match "^[a-z0-9A-Z_\-]+$" -eq $False) {
        ### Provided Cert/Key Object name does not match valid pattern for F5 Silverline
        if ( $debug ) { "`n##### ERROR: Invalid Cert/Key Object Name:  $certKey does not match RegEx: ^[a-z0-9A-Z_\-]+$" | Out-File $file -Append }
        throw "ERROR Invalid Cert/Key Object Name:  $certKey does not match RegEx: ^[a-z0-9A-Z_\-]+$"
    }

    ### Check for existence of Cert/Key Object to determine workflow of Create or Update
    ### If Cert/Key is found, use PUT method with Cert/Key name in URL
    ### If Cert/Key is NOT found, use POST method and don't include name in URL
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $url = "https://$($General.HostAddress)/api/v1/ssl/cert_keys/" + $certKey

    $createMethod = "PUT"

    if ( $debug ) { "`n##### PROCESS: Check for existence of Cert/Key object to determine Update/Install method" | Out-File $file -Append }
    if ( $debug ) { "`n##### PROCESS: Invoke-WebRequest -Uri " + $url + " -UseBasicParsing -Method Get -Headers " + '@{"X-Authorization-Token"="' + $General.UserPass + '";"Content-Type"="application/json";}' | Out-File $file -Append }

    $certTest = try {
        Invoke-WebRequest -Uri $url -UseBasicParsing -Method Get -Headers @{"X-Authorization-Token"=$General.UserPass;"Content-Type"="application/json";}
        if ( $debug ) { "`n##### PROCESS: Certificate Object $certKey exists; using PUT method" | Out-File $file -Append }
    } catch {
        $e = $_.Exception
        switch ( $e.Response.StatusCode ) {
            'Unauthorized' {
                if ( $debug ) { "`n##### ERROR Unauthorized:  The API key for F5 Silverline is incorrect or deleted from the F5 Silverline portal" | Out-File $file -Append }
                throw "ERROR Unauthorized:  The API key for F5 Silverline is incorrect or deleted from the F5 Silverline portal"
            }
            'NotFound' {
                $createMethod = "POST"                
                $url = "https://$($General.HostAddress)/api/v1/ssl/cert_keys"
                if ( $debug ) { "`n##### PROCESS: Certificate Object $certKey does not exist; using POST method" | Out-File $file -Append }
            }
            'BadRequest' {
                if ( $debug ) { "`n##### ERROR Exception Message: " + $e.Message | Out-File $file -Append }            
                if ( $debug ) { "`n##### ERROR Bad Request:  The API request was not accepted, please contact F5 Silverline Support." | Out-File $file -Append }
                throw "ERROR Bad Request:  The API request was not accepted, please contact F5 Silverline Support."
            }            
           default {
                if ( $debug ) { "`n##### ERROR Exception Message: " + $e.Message | Out-File $file -Append }
                if ( $debug ) { "`n##### ERROR Unknown:  An unknown error was encountered, please contact F5 Silverline Support." | Out-File $file -Append }
                throw "ERROR Unknown:  An unknown error was encountered, please contact F5 Silverline Support."
            }
        }
    }
    if ( $debug ) { "`r##### PROCESS: Cert/Key Check Complete`r" | Out-File $file -Append }
    if ( $debug ) { "`r##### PROCESS: Start Install / Update Cert/Key Object`r" | Out-File $file -Append }

    ### If EncryptPass is included, use the Encrypted Key file, otherwise use the unencrypted one.
    if ($Specific.EncryptPass) {
        $key = $Specific.PrivKeyPemEncrypted
    } else {
        $key = $Specific.PrivKeyPem
    }
    
    ### Process Intermediates from concatenated ChainPem value if present
    if($Specific.ChainPem.Length -gt 0) {
        $chainArray = $Specific.ChainPem -split '-----END CERTIFICATE-----'
        $chainJsonArray = @()
        for ($x=0; $x -lt $chainArray.Count-1; $x++) {
            $chainArray[$x] += '-----END CERTIFICATE-----'
            $chainElementHash = @{"certificate" = $chainArray[$x].Trim()}
            $chainJsonArray += $chainElementHash
        }
        $chainJson =  $chainJsonArray | ConvertTo-Json             
    } else {
        $chainJson = "[]"
    }

    $body = @{
        "data"=@{
            "type"="ssl_certificate";
            "attributes"=@{
                "certificate"=$Specific.CertPem;
                "key"=$key;
                "passphrase"=$Specific.EncryptPass;
                "intermediates" = "INTERMEDIATES";
                "name"=$certKey;
            };
        };
    } | ConvertTo-Json
    $body = $body -creplace '"INTERMEDIATES"', $chainJson
    
    if ( $debug ) { "`n##### URL: $url " | Out-File $file -Append }
    if ( $debug ) { "`n##### Body: " + $body  | Out-File $file -Append }

    $response = try {
        Invoke-WebRequest -Uri $url -UseBasicParsing -Method $createMethod -Headers @{"X-Authorization-Token"=$General.UserPass;"Content-Type"="application/json";} -Body $body
    } catch {
        $e = $_.Exception
        switch  ( $e.Response.StatusCode ) {
            'BadRequest' {
                if ( $debug ) { "`n##### ERROR Exception Message: " + $e.Message | Out-File $file -Append }
                if ( $debug ) { "`n##### ERROR Bad Request:  The API request was not accepted, please contact F5 Silverline Support." | Out-File $file -Append }
                throw "ERROR Bad Request:  The API request was not accepted, please contact F5 Silverline Support."
            }
            default {
                if ( $debug ) { "`n##### ERROR Exception Message: " + $e.Message | Out-File $file -Append }
                if ( $debug ) { "`n##### ERROR Unknown:  An unknown error was encountered, please contact F5 Silverline Support." | Out-File $file -Append }
                throw "ERROR Unknown:  An unknown error was encountered, please contact F5 Silverline Support."
            }
        }
    }

    if ( $debug ) { "`n##### Response:   $Response" | Out-File $file -Append }
    if ( $debug ) { "`n##### HTTP Response Code: " + $response.StatusCode | Out-File $file -Append }
    if ( $debug ) { "`r##### PROCESS: Start Install / Update Cert/Key Object Complete" | Out-File $file -Append }
     return @{ Result="Success"; AssetName="AssetName is not used by the F5 Silverline Adaptable Driver"}
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

F5 Silverline Notes
    This function is not currently used.  Binding Cert/Keys installed in Silverline to specific proxy definitions is outside the scope of this implementation.
##################################################################################################>
function Update-Binding
{
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General
    # )
    # 
    # $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    # 
    # "`n##### GENERAL PARAMETERS #####" | Out-File $file
    # $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    # $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append

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
        
F5 Silverline Notes
    This function is not used.  All installed Cert/Keys are immediately active; F5 Silverline does not support an activate function such as this.
##################################################################################################>
function Activate-Certificate
{
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General
    # )
    # 
    # $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    # 
    # "`n##### GENERAL PARAMETERS #####" | Out-File $file
    # $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    # $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append

    return @{ Result="NotUsed"; }
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
        Serial : the serial number of the X509 certificate referenced by AssetName
        Thumbprint : the SHA1 thumprint of the X509 certificate referenced by AssetName
            
### F5 Silverline Implementation Notes
    - All API calls to F5 Silverline require an API Token that is generated in the Silverline portal by the customer; username & password are not used
    - The API Token value must be included as a X-Authorization-Token header
    - API Endpoint for Production use is:  portal.f5silverline.com:443

API HTTP Method:  GET

HTTP URI:  https://portal.f5silverline.com/api/v1/ssl/cert_keys/[AssetName]"

API Response Codes:
    200 OK - The Get request was successfully processed
    404 Not Found - The requested object was not found
    
##################################################################################################>
function Extract-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    $debug = $FALSE
    if ( $General.VarBool1 -eq $TRUE ) {
        $debug=$TRUE

        ### Establish Logging
        $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
        if ( $debug ) { "##### DEBUG ENABLED" | Out-File $file }
        "`n##### GENERAL PARAMETERS #####" | Out-File $file - Append
        $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
        "`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
        $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    }

    $pem = Get-Content $($global:temp_dir + "\" + $General.AssetName + ".crt") | Out-String
    $bytes = [Convert]::FromBase64String($pem.Replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----",""))
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import($bytes)

    ### Validate F5 Silverline Cert/Key Object name retrieved from Adaptable Driver
    $certKey = $General.VarText1
    if($certKey -match "^[a-z0-9A-Z_\-]+$" -eq $False) {
        ### Provided Cert/Key Object name does not match valid pattern for F5 Silverline
        if ( $debug ) { "`n##### ERROR: Invalid Cert/Key Object Name:  $certKey does not match RegEx: ^[a-z0-9A-Z_\-]+$" | Out-File $file -Append }
        throw "ERROR Invalid Cert/Key Object Name:  $certKey does not match RegEx: ^[a-z0-9A-Z_\-]+$"
    }    
    
    ### F5 Silverline does not allow assets to have period characters; they are stripped on creation by the API
    $url = "https://$($General.HostAddress)/api/v1/ssl/cert_keys" + "/" + $certKey
    
    $headers = @{
        "X-Authorization-Token"=$General.UserPass;
        "Content-Type"="application/json";
    }
    if ( $debug ) { "`r##### PROCESS: Start Extract Certificate`r" | Out-File $file -Append }          
    if ( $debug ) { "`n##### URL: $url " | Out-File $file -Append }
    if ( $debug ) { "`n##### Headers: " | Out-File $file -Append }
    if ( $debug ) { $headers.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append }

    $response = try {
        Invoke-WebRequest -Uri $url -UseBasicParsing -Method Get -Headers $headers
    } catch {
        $e = $_.Exception
        switch ( $e.Response.StatusCode ) {
            'Unauthorized' {
                if ( $debug ) { "##### ERROR Unauthorized:  The API key for F5 Silverline is incorrect or deleted from the F5 Silverline portal" | Out-File $file -Append }
                throw "ERROR Unauthorized:  The API key for F5 Silverline is incorrect or deleted from the F5 Silverline portal"
            }
            'NotFound' {
                if ( $debug ) { "##### ERROR Not Found:  The requested SSL Certificate / Key object was not found" | Out-File $file -Append }
                throw "ERROR Not Found:  The requested SSL Cert/Key Object $certKey was not found."
            }
            default {
                if ( $debug ) { "`n##### ERROR Exception Message: " + $e.Message | Out-File $file -Append }
                if ( $debug ) { "`n##### ERROR Unknown:  An unknown error was encountered, please contact F5 Silverline Support." | Out-File $file -Append }
                throw "ERROR Unknown:  An unknown error was encountered, please contact F5 Silverline Support."
            }
        }
    }

    if ( $debug ) { "`n##### API Response: " + $response  | Out-File $file -Append }
    if ( $debug ) { "`n##### HTTP Response Code: " + $response.StatusCode | Out-File $file -Append }
    $jsonResponse = $response | ConvertFrom-Json
    
    $pem = $jsonResponse.data.attributes.certificate
    if ( $debug ) { "`n##### Cert: " + $pem| Out-File $file -Append }

    ### Load the Certificate into an X509 Object to extract Thumbprint and Serial Number
    $certObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $certByteArray = [System.Text.Encoding]::UTF8.GetBytes($pem)
    $certObject.Import($certByteArray)
    
    $serialNumber = $certObject.GetSerialNumberString()
    if ( $debug ) { "`n##### Serial: " + $serialNumber | Out-File $file -Append }

    $thumbprint = $certObject.GetCertHashString()
    if ( $debug ) { "`n##### Thumbprint: " + $thumbprint | Out-File $file -Append }
    if ( $debug ) { "`r##### PROCESS:  Extract Certificate Complete" | Out-File $file -Append }          

    return @{ Result="Success"; CertPem="$pem"; Serial="$serialNumber"; Thumprint="$thumbprint" }
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
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General,
    #     [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
    #     [System.Collections.Hashtable]$Specific
    # )
    # 
    # $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    # 
    # "`n##### GENERAL PARAMETERS #####" | Out-File $file
    # $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    # $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # $pem = Get-Content $($global:temp_dir + "\" + $General.AssetName + ".key") | Out-String
    # 
    # return @{ Result="Success"; PrivKeyPem="$pem" }
    return @{ Result="NotUsed"}
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
        
###F5 Silverline Notes
    This function is not used.  All installed Cert/Keys are immediately active; F5 Silverline does not support an remove unused Cert function such as this.
##################################################################################################>
function Remove-Certificate
{
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General,
    #     [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
    #     [System.Collections.Hashtable]$Specific
    # )

    # ### Establish Logging
    # $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    # "`n##### GENERAL PARAMETERS #####" | Out-File $file
    # $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    # $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    #
    # This section is no longer used per discussions with Venafi, keeping until final release and testing is complete.
    ### Build API data elements
    # 
    # ### F5 Silverline does not allow assets to have period characters; they are stripped on creation by the API
    # $url = "https://$($General.HostAddress)/api/v1/ssl/cert_keys" + "/" + $General.AssetName.Replace(".","")
    # 
    # $headers = @{
    #     "X-Authorization-Token"=$General.VarText1;
    #     "Content-Type"="application.json";
    # }
    #       
    # "`n`n##### URL:     $url " | Out-File $file -Append
    # "`n`n##### Headers: " | Out-File $file -Append
    # $headers.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    # 
    # try {
    #     ### Use Invoke-WebRequest because F5 Silverline Portal uses TLS1.2
    #     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    #     #$response = Invoke-WebRequest -Uri $url -Method Delete -Headers $headers -WebSession $session
    #     "`n`n##### Response:   $Response" | Out-File $file -Append
    #     "HTTP Response Code: " + $response.StatusCode | Out-File $file -Append
    # } catch {
    #     "StatusCode: $_.Exception.Response.StatusCode.value__ " | Out-File $file -Append
    #     "StatusDescription: $_.Exception.Response.StatusDescription" | Out-File $file -Append
    #     return @{ Result="Failure"; }
    #     throw Decode-Error($_.Exception)
    # 
    # }

    ### Discuss what to do about these lines with Venafi; commenting for now
    # Remove-Item $($global:temp_dir + "\" + $Specific.AssetNameOld + ".crt")
    # Remove-Item $($global:temp_dir + "\" + $Specific.AssetNameOld + ".key")
    # Remove-Item $($global:temp_dir + "\" + $Specific.AssetNameOld + ".p12")

    return @{ Result="NotUsed"}
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Show-Variables ( $name, $value )
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