<#
//---------------------------------------------------------------------------
// Venafi Adaptable Driver for F5 Distributed Cloud (XC)
//---------------------------------------------------------------------------
// Version:  1.15
// Author:   Michael Coleman, Michael@f5.com
// Support:  support@cloud.f5.com
// API Spec: https://docs.cloud.f5.com/docs/api/certificate
//
// Reference:   https://marketplace.venafi.com/xchange/620d2d6ed419fb06a5c5bd36/solution/63e5234d5385d9b04b559018
//---------------------------------------------------------------------------
// Copyright (c) 2024 Venafi, Inc. All rights reserved.
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
Text1|Namespace|111
Text2|Load Balancer FQDN|110
Text3|Static Asset Name|110
Text4|NotUsed|000
Text5|NotUsed|000
Option1|Enable XC Driver Debug|110
Passwd|NotUsed|000
-----END FIELD DEFINITIONS-----
#>

$Script:AdaptableAppVer = "1.15"
$Script:AdaptableAppDrv = "F5-Distributed-Cloud"

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
        Result : 'Success' or 'NotUsed' to indicate the non-[error]  completion state
        
F5 Distributed Cloud Notes
    This function is not used.
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
        Result : 'Success' or 'NotUsed' to indicate the non-[error]  completion state
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed
        
F5 Distributed Cloud Notes
    This function is not used.
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
        Result : 'Success' or 'NotUsed' to indicate the non-[error]  completion state
        Pkcs10 : a string representation of the CSR in PKCS#10 format
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed
        
F5 Distributed Cloud Notes
    This function is not used.
##################################################################################################>
function Generate-CSR {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    #dont touch this value for encryption
    #encryptionKey = "Q29sZW1hbiB3YXMgaGVyZSE="

    return @{ Result = "NotUsed"; Pkcs10 = "NotUsed"; AssetName = "NotUsed" }
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
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-[error]  completion state
        
F5 Distributed Cloud Notes
    This function might be used.  The chain/intermediate certificates are installed with the Install-Certificate function

    Create Chain: https://docs.cloud.f5.com/api/config/namespaces/{metadata.namespace}/certificate_chains

##################################################################################################>
function Install-Chain {
    # Param(
    #     [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
    #     [System.Collections.Hashtable]$General,
    #     [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
    #     [System.Collections.Hashtable]$Specific
    # )

    return @{ Result = "NotUsed" }
    
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
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-[error]  completion state
        AssetName : (optional) the base name used to reference the private key as it was installed on the device; if not supplied the auto-generated name is assumed
        
F5 Distributed Cloud Notes
    This function is not used.  The private key is installed with the Install-Certificate function
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
    
    CertPem [String]: End-entity X509 certificate to be provisioned in Base64 PEM format.
    PrivKeyPem [String]: The non-encrypted RSA private key being provisioned in Base64 PEM format.
    PrivKeyPemEncrypted [String]: The RSA private key being provisioned in Base64 PEM format and encrypted using the EncryptPass password.
    ChainPem [String]: All of the CA certificates in the trust chain for the end-entity certificate in Base64 PEM format concatenated together
    ChainPkcs7 [Byte Array]: All of the CA certificates in the trust chain for the end-entity certificate in PKCS#7 format.
    Pkcs12 [Byte Array]: PKCS#12 keystore that includes certificate, private key, and chain
    EncryptPass [String]: Password used to encrypt the PrivKeyPemEncrypted private key and Pkcs12 keystore.

.NOTES
    Returns...
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-[error]  completion state (may only be 'NotUsed' if Install-PrivateKey did not return 'NotUsed')
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed

###
F5 Distributed Cloud Implementation Notes
    - The F5 Distributed CLoud API for Certificate and Key management handle the installation of the Certificate, Key and Intermediates
    - The API will first check to see if the Cert/Key object already exists, if it does, it will send an Update/PUT if it doesn't, it will send a Create/POST
    - All API calls to F5 Distributed Cloud (XC) require an API Token that is generated in the XC Console by the customer; the API Token is set in the Password field for the Adaptable Driver
    - The API Token value must be included as a Authorization: APIToken [token] header
    - API Endpoint for Production use is:  [tenant].console.ves.volterra.io/api:443
    - AssetName is not used by the Install Certificate function; the F5 Cert/Key object is defined by the additional text field and includes RegEx validation

API HTTP Method:  POST

{
    "metadata": {
        "name": "cert1",
        "namespace": "ns1"
    },
    "spec": {
        "certificate_url": "string:///\u003cBase64\u003e",
        "private_key": {
            "blindfold_secret_info": {
                "location": "string:///\u003cBase64\u003e"
            }
            OR
            "clear_secret_info": {
                "location": "string:///\u003cBase64\u003e"
            }
        }
    }
}

Details:
    type:                       Required, must be "ssl_certificates" to differentiate from other API call types
    attributes:                 Required, a JSON Array containing...
        name:                   Required, must be unique within the Distributed Cloud customer; attempting to create a new SSL Certificate & Key object with a duplicate name will result in a failed API call; HTTP XXX ([error] )
                                Name attribute does not support . as a valid naming convention
        namespace:              Required, will default to Shared.                 
        certificate_url:        Required, the PEM certificate to be installed in Base64 PEM format
        blindfold_secret_into:  Optional, Key has been blindfolded using vesctl.
        clear_secret_info:      Optional, Key has not been blindfolded.
        location:               Required, Base64 encoded string of private key.

API Response Codes:
    200 Created - The Create request was successfully processed

Coleman Notes:

Get Chain: https://docs.cloud.f5.com/api/config/namespaces/{namespace}/certificate_chains/{name}

##################################################################################################>
function Install-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Initialize-Debug -General $General

    #$certKey = Convert-AssetName -inputString $General.AssetName

    # Use Static Asset Name if provided in VarText3, otherwise use AssetName
    $certKey = if (-not [string]::IsNullOrWhiteSpace($General.VarText3)) {
        Convert-AssetName -inputString $General.VarText3
    }
    else {
        Convert-AssetName -inputString $General.AssetName
    }

    $cleanNamespace = $General.VarText1
    $cleanNamespace = $cleanNamespace.ToLower()
    $cleanNamespace = $cleanNamespace -replace '[^a-z0-9-]|\.', '-'
    $cleanNamespace = $cleanNamespace.Trim('-')
    if ($cleanNamespace.Length -gt 199) {
        $cleanNamespace = $cleanNamespace.Substring(0, 199)
    }
    $cleanNamespace = $cleanNamespace.TrimStart('-')

    # Ensure the final result adheres to minimum length requirements of RFC 1123 (if applicable)
    # For example, ensuring it's at least 1 character long (adjust based on your specific needs)
    if ($certKey.Length -eq 0) {
        Write-Debug "[error] Invalid Cert/Key Object: After conversion, Cert/Key Object Name is empty. Original name: $($General.AssetName) or $($General.VarText3)"
        #Select-ErrorMessage 
        throw "[error] After conversion, Cert/Key Object Name is empty. Original name: $($General.AssetName) or $($General.VarText3)"
    }
    if ($cleanNamespace.Length -eq 0) {
        Write-Debug "[error] Invalid Namespace Object: After conversion, Namespace Object Name is empty. Original name: $($General.VarText1)"
        #Select-ErrorMessage
        throw "[error] After conversion, Namespace Object Name is empty. Original name: $General.VarText1"
    }

    ### Check for existence of Cert/Key Object to determine workflow of Create or Update
    ### If Cert/Key is found, use PUT method with Cert/Key name in URL
    ### If Cert/Key is NOT found, use POST method and don't include name in URL
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Lets make sure the HostAddress is cleaned up before we use it.
    # Step 1: Remove the protocol
    $hostAddressWithoutProtocol = $General.HostAddress -replace 'http[s]?://', ''

    # Step 2: Remove any trailing paths
    $hostAddressCleaned = $hostAddressWithoutProtocol -replace '/.*', ''

    $url = "https://$hostAddressCleaned/api/config/namespaces/$cleanNamespace/certificates"

    $existsUrl = "https://$hostAddressCleaned/api/config/namespaces/$cleanNamespace/certificates/$certKey"

    $createMethod = "PUT" # Assume Cert exists by default
    $certExists = $false

    $logHeader = @{
        "Authorization" = "APIToken **********"
        "Content-Type"  = "application/json"
    }

    $authHeader = @{
        "Authorization" = "APIToken $($General.UserPass)"
        "Content-Type"  = "application/json"
    }

    Write-Debug "[process] Check for existence of Cert/Key object to determine Update/Install method"
    Write-Debug "[process] Invoke-WebRequest -Uri $existsUrl -UseBasicParsing -Method Get -Headers $($logHeader)"

    $response = try {
        $response = Invoke-WebRequest -Uri $existsUrl -UseBasicParsing -Method Get -Headers $authHeader
        Write-Debug "[process] Certificate Object $certKey exists; using PUT method"
        # Debug output for response object
        if ($null -eq $response) {
            Write-Debug "No response received from server."
        }
        else {
            Write-Debug "Response Status Code: $($response.StatusCode)"
            #Write-Debug "Response Content: $($response.Content)"
            #Write-Debug "Full Response Object: $($response | Out-String)"
        }
        $certExists = $true
        $response
    }
    catch {
        $e = $_.Exception
        if ($null -ne $e) {
            switch ( $e.Response.StatusCode ) {
                'Unauthorized' {
                    Write-Debug "[error]  Unauthorized:  The API Token for F5 Distributed Cloud is incorrect or deleted from the F5 Distributed Cloud Console"
                    throw "[error] Unauthorized:  The API Token for F5 Distributed Cloud is incorrect or deleted from the F5 Distributed Cloud Console"
                }
                'NotFound' {
                    $createMethod = "POST"    
                    $certExists = $false
                    Write-Debug "[process] Certificate Object $certKey does not exist; using POST method"
                }
                'BadRequest' {
                    Write-Debug "[error]  Exception Message: " + $e.Message            
                    Write-Debug "[error]  Bad Request:  The API request was not accepted, please contact F5 Distributed Cloud Support."
                    throw "[error]  Bad Request:  The API request was not accepted, please contact F5 Distributed Cloud Support."
                }            
                default {
                    Write-Debug "[error]  Exception Message: " + $e.Message
                    Write-Debug "[error]  Unknown:  An unknown [error]  was encountered, please contact F5 Distributed Cloud Support."
                    throw Select-ErrorMessage Message($e)
                }
            }
        }
        else {
            Write-Debug "[error] General exception: $($e.Message)"
            throw $e.Message
        }
    }
    
    Write-Debug "[process] Cert & Key Check Complete`r"
    Write-Debug "[process] Start Install & Update Key Pair Object: $certKey`r"

    # Normalize newlines: Ensure there's exactly one newline character at the end of each PEM block
    $CertPem = $Specific.CertPem.TrimEnd() + "`n"
    $ChainPem = $Specific.ChainPem.TrimEnd() + "`n"
    $combinedPem = $CertPem + $ChainPem

    # Base64 encode the certificate and key
    $certBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($combinedPem))
    $keyBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Specific.PrivKeyPem))
    
    # Construct the object according to the new schema, but will need to do plain text for now, dont know if can blindfold here
    $body = @{
        metadata = @{
            name      = $certKey
            namespace = $cleanNamespace
        }
        spec     = @{
            certificate_url = "string:///$certBase64"
            private_key     = @{
                clear_secret_info = @{
                    provider = ""
                    url      = "string:///$keyBase64"
                }
            }
        }
    } | ConvertTo-Json -Depth 5

    if ($certExists) {
        $url = $existsUrl
    }

    Write-Debug "[Install-Certificate] URL: $url " 
    #Write-Debug "[Install-Certificate] Body: $($body)"
    
    $response = try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -Method $createMethod -Headers $authHeader -Body $body
        $response
    }
    catch {
        $e = $_.Exception
        switch ( $e.Response.StatusCode ) {
            'BadRequest' {
                Write-Debug "[error]  Exception Message: " + $e.Message
                Write-Debug "[error]  Bad Request:  The API request was not accepted, please contact F5 Distributed Cloud Support."
                throw Select-ErrorMessage Message($_.Exception)
            }
            default {
                Write-Debug "[error]  Exception Message: " + $e.Message
                Write-Debug "[error]  Unknown:  An unknown [error]  was encountered, please contact F5 Distributed Cloud Support."
                throw Select-ErrorMessage Message($_.Exception)
            }
        }
    }
    
    Write-Debug "[process] HTTP Response Code: $($response.StatusCode)"
    Write-Debug "[process] Install / Update Cert/Key Object Complete"

    return @{ Result = "Success"; AssetName = $General.AssetName }
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
        Result : 'Success' or 'NotUsed' to indicate the non-[error]  completion state

F5 Distributed Cloud Notes
    This function is not currently used.  Binding Cert/Keys installed in Silverline to specific proxy definitions is outside the scope of this implementation.
##################################################################################################>
function Update-Binding {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result = "NotUsed"; }
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
        Result : 'Success' or 'NotUsed' to indicate the non-[error]  completion state
        
F5 Distributed Cloud Notes
    This function is not used.  All installed Cert/Keys are immediately active; F5 Distributed Cloud does not support an activate function such as this.
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
        Result : 'Success' or 'NotUsed' to indicate the non-[error]  completion state
        CertPem : the extracted X509 certificate referenced by AssetName in Base64 PEM format
        Serial : the serial number of the X509 certificate referenced by AssetName
        Thumbprint : the SHA1 thumprint of the X509 certificate referenced by AssetName
            
### F5 Distributed Cloud Implementation Notes
    - All API calls to F5 Distributed Cloud require an API Token that is generated in the Console by the customer; username & password are not used
    - The API Token value must be included as an Authorization header

API HTTP Method:  GET

API Response Codes:
    200 OK - The Get request was successfully processed
    404 Not Found - The requested object was not found
    
##################################################################################################>
function Extract-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Initialize-Debug -General $General

    # Use Static Asset Name if provided in VarText3, otherwise use AssetName
    $certKey = if (-not [string]::IsNullOrWhiteSpace($General.VarText3)) {
        Convert-AssetName -inputString $General.VarText3
    }
    else {
        Convert-AssetName -inputString $General.AssetName
    }

    $cleanNamespace = $General.VarText1
    $cleanNamespace = $cleanNamespace.ToLower()
    $cleanNamespace = $cleanNamespace -replace '[^a-z0-9-]|\.', '-'
    $cleanNamespace = $cleanNamespace.Trim('-')
    if ($cleanNamespace.Length -gt 199) {
        $cleanNamespace = $cleanNamespace.Substring(0, 199)
    }
    $cleanNamespace = $cleanNamespace.TrimStart('-')

    # Ensure the final result adheres to minimum length requirements of RFC 1123 (if applicable)
    # For example, ensuring it's at least 1 character long (adjust based on your specific needs)
    if ($certKey.Length -eq 0) {
        Write-Debug "[error] Invalid Cert/Key Object: After conversion, Cert/Key Object Name is empty. Original name: $($General.AssetName) or $($General.VarText3)"
        #Select-ErrorMessage 
        throw "[error] After conversion, Cert/Key Object Name is empty. Original name: $($General.AssetName) or $($General.VarText3)"
    }
    if ($cleanNamespace.Length -eq 0) {
        Write-Debug "[error] Invalid Namespace Object: After conversion, Namespace Object Name is empty. Original name: $($General.VarText1)"
        #Select-ErrorMessage
        throw "[error] After conversion, Namespace Object Name is empty. Original name: $General.VarText1"
    }

    ### Check for existence of Cert/Key Object to extract more details about the installed Cert
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Lets make sure the HostAddress is cleaned up before we use it.
    # Step 1: Remove the protocol
    $hostAddressWithoutProtocol = $General.HostAddress -replace 'http[s]?://', ''

    # Step 2: Remove any trailing paths
    $hostAddressCleaned = $hostAddressWithoutProtocol -replace '/.*', ''

    $certGetUrl = "https://$hostAddressCleaned/api/config/namespaces/$cleanNamespace/certificates/$certKey"
    $certExists = $false

    Write-Debug "[process] Check for existence of Cert object to determine validity"
    
    $response = try {
        $logHeader = @{
            "Authorization" = "APIToken **********"
            "Content-Type"  = "application/json"
        }

        $authHeader = @{
            "Authorization" = "APIToken $($General.UserPass)"
            "Content-Type"  = "application/json"
        }
        Write-Debug "[process] Invoke-WebRequest -Uri $certGetUrl -UseBasicParsing -Method Get -Headers $($logHeader)"

        $response = Invoke-WebRequest -Uri $certGetUrl -UseBasicParsing -Method Get -Headers $authHeader
        Write-Debug "[process] Certificate Object $certKey exists; proceed with extracting details on Cert in the response"
        
        # Debug output for response object
        if ($null -eq $response) {
            Write-Debug "No response received from server."
        }
        else {
            Write-Debug "Response Status Code: $($response.StatusCode)"
            #Write-Debug "Response Content: $($response.Content)"
            Write-Debug "Full Response Object: $($response | Out-String)"
        }
        $certExists = $true
        $response
    }
    catch {
        $e = $_.Exception
        if ($null -ne $e) {
            switch ( $e.Response.StatusCode ) {
                'Unauthorized' {
                    Write-Debug "[error]  Unauthorized:  The API Token for F5 Distributed Cloud is incorrect or deleted from the F5 Distributed Cloud Console"
                    throw "[error] Unauthorized:  The API Token for F5 Distributed Cloud is incorrect or deleted from the F5 Distributed Cloud Console"
                }
                'NotFound' {
                    $certExists = $false
                    Write-Debug "[process] Certificate Object $certKey does not exist; Please ensure Cert is pushed to F5 Distributed Cloud"
                }
                'BadRequest' {
                    Write-Debug "[error]  Exception Message: " + $e.Message            
                    Write-Debug "[error]  Bad Request:  The API request was not accepted, please contact F5 Distributed Cloud Support."
                    throw "[error]  Bad Request:  The API request was not accepted, please contact F5 Distributed Cloud Support."
                }            
                default {
                    Write-Debug "[error]  Exception Message: " + $e.Message
                    Write-Debug "[error]  Unknown:  An unknown [error]  was encountered, please contact F5 Distributed Cloud Support."
                    throw Select-ErrorMessage Message($e)
                }
            }
        }
        else {
            Write-Debug "[error] General exception: $($e.Message)"
            throw $e.Message
        }
    }

    # Assuming $response contains the JSON response converted to a PowerShell object
    $jsonResponse = $response.Content | ConvertFrom-Json
    $certificateUrlEncoded = $jsonResponse.spec.certificate_url -replace "^string:///", ""
    Write-Debug "certificateUrlEncoded: $($certificateUrlEncoded | Out-String)"

    # Base64 decode the certificate URL value
    $certificateDecodedBytes = [System.Convert]::FromBase64String($certificateUrlEncoded)
    $certificateDecodedString = [System.Text.Encoding]::UTF8.GetString($certificateDecodedBytes)
    
    $pem = $certificateDecodedString
    
    # Split the certificate chain into individual certificates based on PEM delimiters
    $certificates = $pem -split "(?=-----BEGIN CERTIFICATE-----)"
    $leafPemContent = ""

    foreach ($certBlock in $certificates) {
        if ($certBlock -match "-----BEGIN CERTIFICATE-----") {
            # Convert PEM to X509Certificate2
            $x509Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
            $certByteArray = [System.Text.Encoding]::UTF8.GetBytes($certBlock)
            $x509Cert.Import($certByteArray)
            # Write-Debug "Cert Extensions : $x509Cert.Extensions"
            $leafPemContent = $certBlock
            break
        }
    }

    ### Load the Certificate into an X509 Object to extract Thumbprint and Serial Number
    $certObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $certByteArray = [System.Text.Encoding]::UTF8.GetBytes($leafPemContent)
    $certObject.Import($certByteArray)
    
    $serialNumber = $certObject.GetSerialNumberString()
    Write-Debug "[process] Serial:  $serialNumber"

    $thumbprint = $certObject.GetCertHashString()
    Write-Debug "[process] Thumbprint:  $thumbprint"

    Write-Debug "[process]  Extract Certificate Complete" 

    return @{ Result = "Success"; CertPem = "$pem"; Serial = "$serialNumber"; Thumprint = "$thumbprint" }
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
        Result : 'Success' or 'NotUsed' to indicate the non-[error]  completion state
        PrivKeyPem : the extracted private key in RSA Base64 PEM format (encrypted or not)
##################################################################################################>
function Extract-PrivateKey {
    # Param(
    #     [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    #     [System.Collections.Hashtable]$General,
    #     [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
    #     [System.Collections.Hashtable]$Specific
    # )
    # 

    return @{ Result = "NotUsed" }
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
        Result : 'Success' or 'NotUsed' to indicate the non-[error]  completion state
        
###F5 Distributed Cloud Notes
    
##################################################################################################>
function Remove-Certificate {
    # Param(
    #     [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
    #     [System.Collections.Hashtable]$General,
    #     [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
    #     [System.Collections.Hashtable]$Specific
    # )

    return @{ Result = "NotUsed" }
}



<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Initialize-Debug {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    if ($null -ne $Script:xcDebugFile) {
        Write-Debug "Called by $((Get-PSCallStack)[1].Command)"
        Write-Debug 'WARNING: Initialize-Debug() called more than once!'
        return
    }

    if ($null -eq $DEBUG_FILE) {
        # do nothing and return immediately if debug isn't on
        if ($General.VarBool1 -eq $false) { return }
        # pull Venafi base directory from registry for global debug flag
        $logPath = "$((Get-ItemProperty HKLM:\Software\Venafi\Platform).'Base Path')Logs"
    }
    else {
        # use the path but discard the filename from the DEBUG_FILE variable
        $logPath = "$(Split-Path -Path $DEBUG_FILE)"
    }

    $Script:xcDebugFile = "$($logPath)\$($Script:AdaptableAppDrv.Replace(' ',''))"
    if ($General.HostAddress -ne '') {
        $Script:xcDebugFile += "-$($General.HostAddress)"
    }
    $Script:xcDebugFile += ".log"
    
    Write-Output '' | Add-Content -Path $Script:xcDebugFile

    Write-Debug -NoFunctionTag -LogMessage "$($Script:AdaptableAppDrv) v$($Script:AdaptableAppVer): Venafi called $((Get-PSCallStack)[1].Command)"
    Write-Debug -NoFunctionTag -LogMessage "PowerShell Environment: $($PSVersionTable.PSEdition) Edition, Version $($PSVersionTable.PSVersion.Major)"

    Write-Debug "Called by $((Get-PSCallStack)[1].Command)"

}

function Write-Debug {
    Param(
        [Parameter(Position = 0, Mandatory)][string]$LogMessage,
        [switch]$NoFunctionTag
    )

    filter Add-TS { "$(Get-Date -Format o): $_" }

    # if the logfile isn't initialized then do nothing and return immediately
    if ($null -eq $Script:xcDebugFile) { return }

    if ($NoFunctionTag.IsPresent) {
        $taggedLog = $LogMessage
    }
    else {
        $taggedLog = "[$((Get-PSCallStack)[1].Command)] $($LogMessage)"
    }

    # write the message to the debug file
    Write-Output "$($taggedLog)" | Add-TS | Add-Content -Path $Script:xcDebugFile
}

function Select-ErrorMessage( [Exception] $ex ) {
    try {
        $result = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $json = $reader.ReadToEnd() | ConvertFrom-Json
        
        if ( $json.error ) {
            return $json.error
        }
        else {
            return $ex.Message
        }
    }
    catch {
        # the response is either not xml or not in the expected format
        return $ex.Message
    }
}

function Show-Variables ( $name, $value ) {
    $result = "_____ $name _____`r`n"

    if ( $value.GetType().Name -eq "Hashtable" ) {
        $maxlen = 0

        For ( $i = 0; $i -lt $value.Keys.Count; $i++ ) {
            if ( $($value.Keys)[$i].Length -gt $maxlen ) {
                $maxlen = $($value.Keys)[$i].Length
            }
        }

        ForEach ( $key in $value.Keys ) {
            if ( $($value.Item($key)).GetType().BaseType.Name -eq "Array" ) {
                if ( $value.Item($key).Count -le 24 ) {
                    $result += $($key + ":").PadRight($maxlen + 4, " ") + "{" + ($value.Item($key) -join ", ") + "}`r`n"
                }
                else {
                    $result += $($key + ":").PadRight($maxlen + 4, " ") + "{" + ($value.Item($key)[0..23] -join ", ") + ", ...}`r`n"
                }
            }
            else {
                $result += $($key + ":").PadRight($maxlen + 4, " ") + $value.Item($key) + "`r`n"
            }
        }
    }
    elseif ( $value.GetType().BaseType.Name -eq "Array" ) {
        if ( $value.Count -le 24 ) {
            $result += "{" + ($value -join ", ") + "}`r`n"
        }
        else {
            $result += "{" + ($value[0..23] -join ", ") + ", ...}`r`n"
        }
    }
    elseif ( $value.GetType().Name -eq "SecureString" ) {
        $result += "".PadRight($value.Length, "*") + "`r`n"
    }
    else {
        $result += $value + "`r`n"
    }

    return $result
}

function Remove-NewlinesFromPem {
    param(
        [string]$PemContent
    )

    # Split the content into lines
    $lines = $PemContent -split "`n"
    
    # Initialize variables to rebuild the PEM without newlines in the Base64 content
    $newPemContent = @()

    foreach ($line in $lines) {
        if ($line -match "^-----") {
            # Directly add the BEGIN/END lines to the new content
            $newPemContent += $line
        }
        else {
            # Remove newlines from the Base64 content and add it to the array without adding a newline
            $newPemContent[$newPemContent.Count - 1] += $line
        }
    }

    # Combine the lines back into a single string
    $newPemContent -join "`n"
}

function Convert-AssetName {
    param (
        [string]$inputString
    )

    # Step 1: Convert to lowercase
    $inputString = $inputString.ToLower()

    # Step 2: Replace underscores with hyphens
    $inputString = $inputString -replace '_', '-'
    
    # Step 3: Replace invalid characters (including periods) with hyphens
    # This regex replaces any character not a lowercase letter, digit, or hyphen, and explicitly includes periods to be replaced with hyphens
    $inputString = $inputString -replace '[^a-z0-9-]|\.', '-'
    
    # Step 4: Ensure it does not start or end with a hyphen, trim if necessary
    $inputString = $inputString.Trim('-')
    
    # Step 5: Truncate to 199 characters to ensure it's less than 200 characters
    if ($inputString.Length -gt 199) {
        $inputString = $inputString.Substring(0, 199)
    }
    
    # Additional step: Ensure the string does not start or end with a hyphen after truncation (safeguard)
    $inputString = $inputString.Trim('-')
    
    return $inputString
}