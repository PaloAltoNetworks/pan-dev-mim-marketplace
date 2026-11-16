<#
//---------------------------------------------------------------------------
// Adaptable Driver for Broadcom Layer7 API Gateway
//
// v1.0
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by APIIDA, in addition to Venafi.
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
Text1|Listen Port to bind key to|110
Text2|Certificate Mode|110
Text3|Enable Debug Mode|110
Text4|Text4|000
Text5|Text5|000
Option1|Skip Activation|111
Option2|Install to Trusted Certificates|111
Passwd|Password|000
-----END FIELD DEFINITIONS-----
#>


<##################################################################################################
.DESCRIPTION
    keyStoreId : The key store to use within the gateway. 
    globalGeneral : This variable allows us to omit the General parameter in almost all subsequent
        calls
##################################################################################################>
$keyStoreId = "00000000000000000000000000000002";
$global:globalGeneral = @{ };



<##################################################################################################
.NAME
    Prepare-KeyStore
.DESCRIPTION
    Remotely create and/or verify keystore on the hosting platform.  Remote generation is considered UNSUPPORTED if this
    function is ommitted or commented out.

    The gateway initializes its key store upon installation. No need to do additional tasks when connected to Venafi
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

    Initialize-AdaptableApp -General $General
    Write-Log "Prepare-KeyStore was called. Returning NotUsed."

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
    
    Initialize-AdaptableApp -General $General


    # This function is not supported when installing a certificate to trusted certificates.
    # It can only be used to generate a "real" SSL/TLS key for use with the listen ports. 
    
    if ($global:globalGeneral.VarBool2 -eq "true") {
        Write-Log("Generate-KeyPair is not support when installing as trusted certificates.")
        return @{ Result = "NotUsed"; }
    }




    
    Write-Log "Generating a key pair with key size $($Specific.KeySize) and alias $($General.AssetName)"

    if ($Specific.KeySize -lt 512) {
        Write-Log "Invalid key size"
        throw "Key size needs to be at least 512."
    }
    if ($Specific.KeySize -gt 8192) {
        Write-Log "Invalid key size"
        throw "Key size can be 8192 at maximum."
    }

    try {
        Start-Transcriptlog "Generate-KeyPair"

        # Prepare the data 
        $uri = Get-RestmanUrl "privateKeys/$($keyStoreId):$($General.AssetName)"
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass
        $xml = Get-CreatePrivateKeyXml -Alias $General.AssetName -KeySize $Specific.KeySize
        
        # Perform the request
        Invoke-RestMethod -Uri $uri -Method Post -Body $xml -Headers $headers -ContentType "text/xml" -Verbose
    
        Stop-Transcriptlog
        return @{ Result = "Success"; }
    } 
    catch {
        Stop-Transcriptlog
        throw Get-ErrorReason($_.Exception)
    }
    
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

    Initialize-AdaptableApp -General $General


    # This function is not supported when installing a certificate to trusted certificates.
    # It can only be used to generate a "real" SSL/TLS key for use with the listen ports. 
    
    if ($global:globalGeneral.VarBool2 -eq "true") {
        Write-Log("Generate-CSR is not support when installing as trusted certificates.")
        return @{ Result = "NotUsed"; }
    }




    Write-Log "Generating a CSR for alias $($General.AssetName) and subject $($Specific.SubjectDN)"

    try {
        Start-Transcriptlog "Generate-CSR"
    
        # Prepare the data 
        $uri = Get-RestmanUrl "privateKeys/$($keyStoreId):$($General.AssetName)/generateCSR"
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass

        # Perform the request
        $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -ContentType "text/xml" -Verbose

        # Analyze result
        if (!$result.DocumentElement.Resource.PrivateKeyGenerateCsrResult.CsrData) {
            throw "CSR failed. Please check the logs"
        }

        $csr = $result.DocumentElement.Resource.PrivateKeyGenerateCsrResult.CsrData;       
        
        Stop-Transcriptlog
        return @{ Result = "Success"; Pkcs10 = $csr; AssetName = $General.AssetName }
    }
    catch {
        Stop-Transcriptlog
        throw Get-ErrorReason($_.Exception)
    }    

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
    
    Initialize-AdaptableApp -General $General
    Write-Log "Installing certificate chain for $($General.AssetName). Return NotUsed"

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
    
    Initialize-AdaptableApp -General $General
    Write-Log "Installing private key $($General.AssetName)"

    Return @{ Result = "NotUsed" }

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
    

    Initialize-AdaptableApp -General $General
    Write-Log "Installing certificate with asset name $($General.AssetName)"



    if ($global:globalGeneral.VarBool2 -eq "true") {
        # Switch to installing as trusted certificate if the boolean is set so 
        return Install-TrustedCertificate -General $General -Specific $Specific
    }



    try {
        Start-Transcriptlog "Install-Certificate"


        # Do we need to import the PKCS12? (new key)
        if ($Specific.PrivKeyPem) {           
            $result = Install-Pkcs12 -Alias $General.AssetName -Pkcs12 $Specific.Pkcs12 -Password $Specific.EncryptPass

            Stop-Transcriptlog
            if ($result -ne "AlreadyInstalled") {
                return @{ Result = "Success" }
            }
            else {
                return @{ Result = "AlreadyInstalled" }
            }
        }


        $chain = @()
        $modes = ($global:globalGeneral.VarText2.Split(",")).Trim()

        if ($modes.contains("skipChainImport")) {
            Write-Log "Skipping certificate chain import."
        }
        else {
            # Split the certificate chain into seperate items 
            if ($Specific.ChainPem) {
                $chain = $Specific.ChainPem -split "-----BEGIN CERTIFICATE-----"
            }
        }

        # Prepare the data 
        $uri = Get-RestmanUrl "privateKeys/$($keyStoreId):$($General.AssetName)"
        $headers = Get-AuthenticationHeader -UserName $General.UserName -Password $General.UserPass
        $xml = Get-InstallCertificateXml -Alias $General.AssetName -KeyStoreId $keyStoreId -CertPem $Specific.CertPem -Chain $chain


        # Update the key on the gateway 
        Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $xml -ContentType "text/xml" -Verbose


        Stop-Transcriptlog    
        # return the alias from the gateway
        # hexadecimal string 
        return @{ Result = "Success"; AssetName = $General.AssetName }
    }
    catch {
        Stop-Transcriptlog
        throw Get-ErrorReason($_.Exception)
    }

}


<##################################################################################################
.NAME
    Install-TrustedCertificate
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
function Install-TrustedCertificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    
    try {
        Start-Transcriptlog "Install-TrustedCertificate"

        # Prepare the data 
        $uri = Get-RestmanUrl "trustedCertificates"
        $headers = Get-AuthenticationHeader -UserName $General.UserName -Password $General.UserPass
        $xml = Get-InstallTrustedCertificateXml -Name $General.AssetName -CertPem $Specific.CertPem 

        # Update the certificate on the gateway 
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $xml -ContentType "text/xml" -Verbose

        $id = $response.DocumentElement.Id
        Write-Log "ID is $id"

        Stop-Transcriptlog    
        return @{ Result = "Success"; AssetName = $id }
    }
    catch {
        Stop-Transcriptlog
        $errorMessage = Get-ErrorReason($_.Exception)
        if ($errorMessage -eq "Certificate already installed") {
            return @{ Result = "AlreadyInstalled" }
        } 
        throw $error
    }
}

<##################################################################################################
.NAME
    Install-Pkcs12
.DESCRIPTION
    Installs a PKCS12 store on the gateway
.PARAMETER PKcs12
    The PKCS12 store to install as byte array
.PARAMETER Alias
    The Alias of the key (taken from General.AssetName)
.PARAMETER Password
    The encryption pass used for the PKCS12 store
##################################################################################################>
function Install-Pkcs12([Byte[]] $Pkcs12, [string] $Alias, [string] $Password) {

    # This is quite messy. We send the PKCS12 structure to the gateway and omit the
    # Alias. RestMan docs state, that it picks the first certificate from the PKCS12 store.
    # In our tests the gateway instead returns the aliases of the certificates in an 
    # error message. If this happens we read that error message and resend the request
    # using the alias from the message

    try {
        # Install the key 
        Write-Log "Performing import of PKCS12 structure"

        $headers = Get-AuthenticationHeader -UserName $global:globalGeneral.UserName -Password $global:globalGeneral.UserPass
        
        $uri = Get-RestmanUrl "privateKeys/$($keyStoreId):$Alias/import"
        $xml = Get-ImportPrivateKeyXml -Alias "Dummy" -Password $Password -Pkcs12 $Pkcs12

        Invoke-RestMethod -Uri $uri -Method Post -Body $xml -Headers $headers -ContentType "text/xml" -Verbose
    }
    catch {
        $message = Get-ErrorReason($_.Exception)
        if ($message.IndexOf("Alias must") -gt -1) {
            Write-Log "Gateway needs a hint on the alias. Extracting and resending."

            $matches = $message | Select-String -Pattern "\[([a-zA-Z0-9\-]*)\]"
            $alias = $matches.Matches[0].Captures[0].Groups[1].Value

            $xml = Get-ImportPrivateKeyXml -Alias $alias -Password $Password -Pkcs12 $Pkcs12
    
            try {
                Write-Log "Sending alias $alias"
                Invoke-RestMethod -Uri $uri -Method Post -Body $xml -Headers $headers -ContentType "text/xml" -Verbose
                return "Success"
            }
            catch {
                $error = Get-ErrorReason($_.Exception)
                if ($error -eq "Key already installed") {
                    return "AlreadyInstalled"
                } 
                throw $error
            }

        }
        else {
            throw $message;
        }
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
function Update-Binding {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Initialize-AdaptableApp -General $General
    Write-Log "Update Binding was called. Returning NotUsed"
    
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
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Activate-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    
    Initialize-AdaptableApp -General $General


    # Check the skip activation toggle
    if ($global:globalGeneral.VarBool1 -eq "true") {
        Write-Log("Activate-Certificate skipped.")
        return @{ Result = "NotUsed"; }       
    }


    # This function is not supported when installing a certificate to trusted certificates.
    # It can only be used to generate a "real" SSL/TLS key for use with the listen ports. 
    
    if ($global:globalGeneral.VarBool2 -eq "true") {
        Write-Log("Activate-Certificate is not supported when installing as trusted certificates.")
        return @{ Result = "NotUsed"; }
    }



    Write-Log("Activating certificate $($General.AssetName) for port $($General.VarText1)")

    try {
        Start-TranscriptLog "Activate-Certificate"
    
        if (!$General.VarText1) {
            # Set special purpose when we don't have a listening port

            $uri = Get-RestmanUrl "privateKeys/$($keyStoreId):$($General.AssetName)/specialPurpose?purpose=SSL";
            $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass            

            Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Verbose;

            Write-Log "Set Special Purpose SSL on private key. Changes will not take effect until alle cluster nodes have been restarted!"
        }
        else {
            # Set reference in listening port

            $uri = Get-RestmanUrl "listenPorts?port=$($General.VarText1)";
            $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass            

            $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -Verbose;

            $port = $result.DocumentElement.Item.Resource.ListenPort
            $keyRef = $port.TlsSettings.PrivateKeyReference

            if (!$keyRef) {
                Write-Log "Port $($port.Name) uses the default key currently. Adding Key-Ref"

                $keyRef = $result.CreateElement("l7:PrivateKeyReference", "http://ns.l7tech.com/2010/04/gateway-management")
                $keyRef.SetAttribute("id", "$($keyStoreId):$($General.AssetName)")                
                $authenticationNode = $port.TlsSettings.ChildNodes[1]
                $port.TlsSettings.InsertAfter($keyRef, $authenticationNode)
                            
                $port.RemoveAttribute("version")
                $baseXml = $port.OuterXml 
            }
            else {
                Write-Log "Port $($port.Name) uses a key ref. Changing Key-Ref to new key"
                
                $port.RemoveAttribute("version");
                $keyRef.SetAttribute("id", "$($keyStoreId):$($General.AssetName)");
                $baseXml = $port.OuterXml                
            }

            $uri = Get-RestmanUrl ("listenPorts/" + [string]$port.GetAttribute("id"));
            $result = Invoke-RestMethod -Uri $uri -Method Put -Body $baseXml -Headers $headers -ContentType "text/xml" -Verbose;

        }

        Stop-Transcriptlog
        return @{ Result = "Success" }
    }
    catch {
        Stop-Transcriptlog
        throw Get-ErrorReason($_.Exception)
    }
}


<##################################################################################################
.NAME
    Extract-Certificate
.DESCRIPTION
    Extracts the certificate from the hosting platform.  If the platform does not provide a method for exporting the
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
    
    Initialize-AdaptableApp -General $General


    if ($global:globalGeneral.VarBool2 -eq "true") {
        # Get one of the installed trusted certificates
        return Extract-TrustedCertificate -General $General
    }


    Write-Log "Extracting certificate with asset name $($General.AssetName)"

    try {
        Start-Transcriptlog "Extract-Certificate"
    
        # Prepare the data 
        $uri = Get-RestmanUrl "privateKeys/$($keyStoreId):$($General.AssetName)"
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass


        # Perform the request
        $result = Invoke-RestMethod -Uri $uri -Method Get -Body $xml -Headers $headers -Verbose;

        # Analyze result
        if (!$result.DocumentElement.Resource.PrivateKey.CertificateChain) {
            throw "Unable to extract certificate. Please see logs for more information";
        }


        $chain = $result.DocumentElement.Resource.PrivateKey.CertificateChain
        if ($chain.CertificateData -is [array]) {
            $certData = $chain.CertificateData[0];
        }
        else {
            $certData = $chain.CertificateData;
        }
        $pem = $certData.Encoded;
        $serial = $certData.SerialNumber;

        Stop-Transcriptlog

        # Omitting the thumbprint as it is not supplied by the gateway
        return @{ Result = "Success"; CertPem = $pem; Serial = $serial }

    }
    catch {
        Stop-Transcriptlog
        throw Get-ErrorReason($_.Exception)
    }

}



<##################################################################################################
.NAME
    Extract-TrustedCertificate
.DESCRIPTION
    Extracts the certificate from the hosting platform.  If the platform does not provide a method for exporting the
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
function Extract-TrustedCertificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    
    Initialize-AdaptableApp -General $General
    Write-Log "Extracting trusted certificate with asset name $($General.AssetName)"

    try {
        Start-Transcriptlog "Extract-TrustedCertificate"
    
        # Prepare the data 
        $uri = Get-RestmanUrl "trustedCertificates/$($General.AssetName)"
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass


        # Perform the request
        $result = Invoke-RestMethod -Uri $uri -Method Get -Body $xml -Headers $headers -Verbose

        # Analyze result
        if (!$result.DocumentElement.Resource.TrustedCertificate.CertificateData) {
            throw "Unable to extract certificate. Please see logs for more information"
        }

        $certData = $result.DocumentElement.Resource.TrustedCertificate.CertificateData
        $pem = $certData.Encoded
        $serial = $certData.SerialNumber

        Stop-Transcriptlog

        # Omitting the thumbprint as it is not supplied by the gateway
        return @{ Result = "Success"; CertPem = $pem; Serial = $serial }

    }
    catch {
        Stop-Transcriptlog
        throw Get-ErrorReason($_.Exception)
    }
}

<##################################################################################################
.NAME
    Extract-DefaultKey
.DESCRIPTION
    WOrks like Extract-Certificate but reads the key / certificate with the special purpose 
    Default SSL key from the gateway
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        CertPem : the extracted X509 certificate referenced by AssetName in Base64 PEM format
        Serial : the serial number of the X509 certificate refernced by AssetName
##################################################################################################>
function Extract-DefaultKey() {
 
    Write-Log "Extracting default key and certificate"

    try {
        Start-Transcriptlog "Extract-DefaultKey"
    
        # Prepare the data 
        $uri = Get-RestmanUrl "privateKeys"
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass

        # Perform the request
        $result = Invoke-RestMethod -Uri $uri -Method Get -Body $xml -Headers $headers -Verbose;

        foreach ($item in $result.DocumentElement.Item) {

            $properties = $item.Resource.PrivateKey.Properties
            $isDefault = $false

            foreach ($property in $properties.Property) {
                if ($property.StringValue -eq "Default SSL Key") {
                    $isDefault = $true
                }
            }
            
            if (!$isDefault) {
                continue;
            }

            $chain = $item.Resource.PrivateKey.CertificateChain
            if ($chain.CertificateData -is [array]) {
                $certData = $chain.CertificateData[0];
            }
            else {
                $certData = $chain.CertificateData;
            }
            $pem = $certData.Encoded;
            $serial = $certData.SerialNumber;

            break;
        }


        Stop-Transcriptlog

        # Omitting the thumbprint as it is not supplied by the gateway
        return @{ Result = "Success"; CertPem = $pem; Serial = $serial }

    }
    catch {
        Stop-Transcriptlog
        throw Get-ErrorReason($_.Exception)
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
function Extract-PrivateKey {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    
    Initialize-AdaptableApp -General $General
    Write-Log "Extracting private key $($General.AssetName)"

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
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Remove-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
        
    Initialize-AdaptableApp -General $General


    if ($global:globalGeneral.VarBool2 -eq "true") {
        # Remove one of the installed trusted certificates
        return Remove-TrustedCertificate -General $General -Specific $Specific
    }


    Write-Log "Removing certificate for asset $($General.AssetName)"

    try {
        Start-Transcriptlog "Remove-Certificate"
    
        # Prepare the data 
        $uri = Get-RestmanUrl "privateKeys/$($keyStoreId):$($Specific.AssetNameOld)"
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass

        # Perform the request
        Invoke-RestMethod -Uri $uri -Method Delete -Headers $headers -Verbose;

        Stop-Transcriptlog  
        return @{ Result = "Success" }
    }
    catch {
        Stop-Transcriptlog
        $reason = Get-ErrorReason($_.Exception)

        if ($reason -eq "Resource not found") {
            # If the old key is not available on the gateway, we're all good. No need
            # to delete a key that is not there
            return @{ Result = "Success " }
        }
    }

}


<##################################################################################################
.NAME
    Remove-TrustedCertificate
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
function Remove-TrustedCertificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
           
    Initialize-AdaptableApp -General $General
    Write-Log "Removing trusted certificate with asset name $($Specific.AssetNameOld)"

    try {
        Start-Transcriptlog "Remove-TrustedCertificate"
    
        # Prepare the data 
        $uri = Get-RestmanUrl "trustedCertificates/$($Specific.AssetNameOld)"
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass

        # Perform the request
        Invoke-RestMethod -Uri $uri -Method Delete -Headers $headers -Verbose;

        Stop-Transcriptlog  
        return @{ Result = "Success" }
    }
    catch {
        Stop-Transcriptlog
        $reason = Get-ErrorReason($_.Exception)

        if ($reason -eq "Resource not found") {
            # If the old key is not available on the gateway, we're all good. No need
            # to delete a key that is not there
            return @{ Result = "Success " }
        }
    }
}



<##################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    Returns all certificates there are on the device.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Application : A hashmap of all disvocered applications
            Name : The name of the app
            PEM : The certificate encoded es PEM
            ValidationAddress : 
            ValidationPort : 
            Attributes : A hashmap with the certificate's attributes
                ...
##################################################################################################>
function Discover-Certificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Initialize-AdaptableApp -General $General
    Write-Log "Discover certificates on the gateway using user $($General.UserName)"
    $apps = @()

    try {
        Start-Transcriptlog "Discover-Certificates"
    

        ### Discover trusted Certificates 

        # Prepare the data 
        $uri = Get-RestmanUrl "$restmanUrl/trustedCertificates";
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass

        # Perform the request
        $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -Verbose;

        foreach ( $item in $result.DocumentElement.Item) {

            $certificate = $item.Resource.TrustedCertificate;
            Write-Log "Found certificate $($certificate.Name)"

            $modes = @()
            foreach ( $property in $certificate.Properties.Property) {

                if (($property.key -eq "revocationCheckingEnabled") -and ($property.BooleanValue -eq "true")) {
                    $modes += "revocationChecking"
                }

                if (($property.key -eq "trustAnchor") -and ($property.BooleanValue -eq "true")) {
                    $modes += "trustAnchor"
                }

                if (($property.key -eq "trustedAsSamlAttestingEntity") -and ($property.BooleanValue -eq "true")) {
                    $modes += "samlAttesting"
                }
                
                if (($property.key -eq "trustedAsSamlIssuer") -and ($property.BooleanValue -eq "true")) {
                    $modes += "samlIssuer"
                }

                if (($property.key -eq "trustedForSigningClientCerts") -and ($property.BooleanValue -eq "true")) {
                    $modes += "signClients"
                }                                

                if (($property.key -eq "trustedForSigningServerCerts") -and ($property.BooleanValue -eq "true")) {
                    $modes += "signServers"
                }
                
                if (($property.key -eq "trustedForSsl") -and ($property.BooleanValue -eq "true")) {
                    $modes += "ssl"
                }                

                if (($property.key -eq "verifyHostname") -and ($property.BooleanValue -eq "true")) {
                    $modes += "verifyHostname"
                }                  

            }
            $mode = $modes -join ","
            Write-Log "Certificate supports the following modes: $($mode)";


            $apps += @{
                Name              = $certificate.Name;
                ValidationAddress = $General.HostAddress
                ValidationPort    = $General.TcpPort
                PEM               = $certificate.CertificateData.Encoded
                Attributes        = @{
                    "Text Field 1" = $mode
                    "Option 2"     = "true"
                }
            }

        }



        ### Discover private keys

        # Prepare the data 
        $uri = Get-RestmanUrl "$restmanUrl/listenPorts";
        $headers = Get-AuthenticationHeader -Username $General.UserName -Password $General.UserPass

        # Perform the request
        $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -Verbose;

        $includeDefaultKey = $false

        foreach ( $item in $result.DocumentElement.Item) {

            $port = $item.Resource.ListenPort;
            Write-Log "Found port $($port.Name)"

            if ($port.Protocol -ne "HTTPS") {
                Write-Log "Skipping as it is not a secured port"
                continue;
            }

            $keyUsed = $port.TlsSettings.PrivateKeyReference; 

            if (!$keyUsed) {
                Write-Log "Using default Key"
                $includeDefaultKey = $true
            }
            else {
                $keyId = $keyUsed.Attributes[0].value;

                Write-Log "Using key $keyId"

                # Output the referenced key
                $keyId = $keyId.Substring($keyId.IndexOf(":") + 1)
                $General.AssetName = $keyId; 
                $result = Extract-Certificate -General $General

                $apps += @{
                    Name              = $port.Name;
                    ValidationAddress = $General.HostAddress
                    ValidationPort    = $General.TcpPort
                    PEM               = $result.CertPem
                    Attributes        = @{
                        "Text Field 1" = $port.Port;
                    }

                }

            }
        }

        if ($includeDefaultKey) {
            # Output the default key 

            $result = Extract-DefaultKey

            $apps += @{
                Name = "Default SSL certificate"
                PEM  = $result.CertPem           
            }      
        }


        Stop-Transcriptlog
        return @{ Result = "Success"; Applications = $apps }
    }
    catch {
        Stop-Transcriptlog
        throw Get-ErrorReason($_.Exception)
    }
}



<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>












<##################################################################################################
.NAME
    Initialize-AdaptableApp
.DESCRIPTION
    Is called at the start of each method that is called by the Venafi platform. This method 
    allows to execute code, that has to be run prior to any other code in every method.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
##################################################################################################>
function Initialize-AdaptableApp ( $General ) {
    
    $global:globalGeneral = $General

}

<##################################################################################################
.NAME
    Get-CreatePrivateKeyXml
.DESCRIPTION
    Returns the XML structure needed to create a private key as a string
.PARAMETER Alias
    The alias (AssetName) of the key
.PARAMETER KeySize
    The key size of the key
##################################################################################################>
function Get-CreatePrivateKeyXml($Alias, $KeySize) {

    return "
        <l7:PrivateKeyCreationContext xmlns:l7=""http://ns.l7tech.com/2010/04/gateway-management"">
            <l7:Dn>CN=$Alias</l7:Dn>
            <l7:Properties>
                <l7:Property key=""rsaKeySize"">
                    <l7:IntegerValue>$KeySize</l7:IntegerValue>
                </l7:Property>
            </l7:Properties>
        </l7:PrivateKeyCreationContext>
    ";

}

<##################################################################################################
.NAME
    Get-ExportPrivateKeyXml
.DESCRIPTION
    Returns the XML structure needed to export a private key as a string
.PARAMETER Password
    The password for the exported key
##################################################################################################>
function Get-ExportPrivateKeyXml($Password) {

    return "
        <l7:PrivateKeyExportContext xmlns:l7=""http://ns.l7tech.com/2010/04/gateway-management"">
            <l7:Password>$Password</l7:Password>
        </l7:PrivateKeyExportContext>
    ";

}


<##################################################################################################
.NAME
    Get-InstallTrustedCertificateXml
.DESCRIPTION
    Returns the XML structure needed to create a trusted certificate
.PARAMETER Name
    The name of the new certificate
.PARAMETER CertPem
    PEM Base64 encoded string with the certificate itself
##################################################################################################>
function Get-InstallTrustedCertificateXml([string] $Name, [string] $CertPem) {

    $header = "
        <l7:TrustedCertificate xmlns:l7=""http://ns.l7tech.com/2010/04/gateway-management"">
            <l7:Name>$Name</l7:Name>
        ";


    $chainXml = Get-CertificateChainXmlSnippet $CertPem
        
    $propertyStart = "<l7:Properties>"
    $propertyEnd = "</l7:Properties>"
    $properties = ""

    $modes = ($global:globalGeneral.VarText2.Split(",")).Trim();



    if ($modes.contains("revocationChecking")) {
        Write-Log "Enable revocationChecking"
        $properties = ($properties + "
            <l7:Property key=""revocationCheckingEnabled"">
                <l7:BooleanValue>true</l7:BooleanValue>
            </l7:Property>");
    }

    if ($modes.contains("trustAnchor")) {
        Write-Log "Enable trustAnchor"
        $properties = ($properties + "
            <l7:Property key=""trustAnchor"">
                <l7:BooleanValue>true</l7:BooleanValue>
            </l7:Property>");
    }

    if ($modes.contains("samlAttesting")) {
        Write-Log "Enable samlAttesting"
        $properties = ($properties + "
            <l7:Property key=""trustedAsSamlAttestingEntity"">
                <l7:BooleanValue>true</l7:BooleanValue>
            </l7:Property>");
    }

    if ($modes.contains("samlIssuer")) {
        Write-Log "Enable samlIssuer"
        $properties = ($properties + "
            <l7:Property key=""trustedAsSamlIssuer"">
                <l7:BooleanValue>true</l7:BooleanValue>
            </l7:Property>");
    }

    if ($modes.contains("signClients")) {
        Write-Log "Enable signClients"
        $properties = ($properties + "
            <l7:Property key=""trustedForSigningClientCerts"">
                <l7:BooleanValue>true</l7:BooleanValue>
            </l7:Property>");
    }

    if ($modes.contains("signServers")) {
        Write-Log "Enable signServers"
        $properties = ($properties + "
            <l7:Property key=""trustedForSigningServerCerts"">
                <l7:BooleanValue>true</l7:BooleanValue>
            </l7:Property>");
    }

    if ($modes.contains("ssl")) {
        Write-Log "Enable ssl"
        $properties = ($properties + "
            <l7:Property key=""trustedForSsl"">
                <l7:BooleanValue>true</l7:BooleanValue>
            </l7:Property>");
    }

    if ($modes.contains("verifyHostname")) {
        Write-Log "Enable verifyHostname"
        $properties = ($properties + "
            <l7:Property key=""verifyHostname"">
                <l7:BooleanValue>true</l7:BooleanValue>
            </l7:Property>");
    }
    else {
        Write-Log "Disable verifyHostname"
        $properties = ($properties + "
            <l7:Property key=""verifyHostname"">
                <l7:BooleanValue>false</l7:BooleanValue>
            </l7:Property>");        
    }

    $footer = "
        </l7:TrustedCertificate>
    ";

    $xml = $header + $chainXml + $propertyStart + $properties + $propertyEnd + $footer;

    #Write-Log $xml
    return $xml
}


<##################################################################################################
.NAME
    Get-InstallCertificateXml
.DESCRIPTION
    Returns the XML structure needed to update the key with certificate information
.PARAMETER Alias
    The alias of the private key, for which the certificate will be installed
.PARAMETER KeyStoreId
    The ID of the key store the private key is store in
.PARAMETER CertPem
    PEM Base64 encoded string with the certificate itself
.PARAMETER Chain
    All certificates of the chain as array (PEM Base64 each)
##################################################################################################>
function Get-InstallCertificateXml($Alias, $KeyStoreId, [string] $CertPem, [string[]] $Chain) {

    $header = "
        <l7:PrivateKey alias=""$Alias"" keystoreId=""$KeyStoreId"" id=""$($KeyStoreId):$Alias"" xmlns:l7=""http://ns.l7tech.com/2010/04/gateway-management"">
        ";

    $chainComplete = ""

    if ($Chain.Count -gt 0) {

        $chainStart = "<l7:CertificateChain>"
        $chainEnd = "</l7:CertificateChain>"

        $chainXml = Get-CertificateChainXmlSnippet $CertPem
    
        [array]::Reverse($Chain)
        foreach ($chainElement in $Chain) {

            if (!$chainElement) {
                continue
            }
            $chainXml += Get-CertificateChainXmlSnippet $chainElement
        
        }

        $chainComplete = $chainStart + $chainXml + $chainEnd
    }
    
    $footer = "
            <l7:Properties>
                <l7:Property key=""keyAlgorithm"">
                    <l7:StringValue>RSA</l7:StringValue>
                </l7:Property>
            </l7:Properties>
        </l7:PrivateKey>
    ";

    return $header + $chainComplete + $footer;
}

<##################################################################################################
.NAME
    Get-CertificateChainXmlSnippet
.DESCRIPTION
    Returns the XML structure needed for one certificate in a certificate chain
.PARAMETER CertPem
    The Bae64 PEM encoded certificate
##################################################################################################>
function Get-CertificateChainXmlSnippet($CertPem) {

    if (!$CertPem) {
        Write-Log "CertPEM is empty!"
        return ""
    }

    $pemWithourMarkers = $CertPem.Replace("-----BEGIN CERTIFICATE-----", "").Replace("-----END CERTIFICATE-----", "").Replace("`n", "").Replace("`r", "")
    $bytes = [Convert]::FromBase64String($pemWithourMarkers)
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import($bytes)

    Write-Log "Imported X509 certificate with hex serial number $($cert.SerialNumber)"
    $serialNumberInt = [System.Numerics.BigInteger]::Parse($cert.SerialNumber, 'AllowHexSpecifier')

    return "
                <l7:CertificateData>
                    <l7:IssuerName>$($cert.IssuerName.Name)</l7:IssuerName>
                    <l7:SerialNumber>$serialNumberInt</l7:SerialNumber>
                    <l7:SubjectName>$($cert.SubjectName.Name)</l7:SubjectName>
                    <l7:Encoded>$pemWithourMarkers</l7:Encoded>
                </l7:CertificateData>    
    ";

}


<##################################################################################################
.NAME
    Get-ImportPrivateKeyXml
.DESCRIPTION
    Returns the XML structure needed to import a PKCS12 store
.PARAMETER Alias
    The alias inside the store (This is not Venafi's asset name)
.PARAMETER Password
    The password used to encrypt the store
.PARAMETER Pkcs12
    THe PKCS12 store as byte array
##################################################################################################>
function Get-ImportPrivateKeyXml($Alias, $Password, $Pkcs12) {

    $pkcs12String = [Convert]::ToBase64String($Pkcs12)

    if ($Alias -ne "Dummy") {
        return "
        <l7:PrivateKeyImportContext xmlns:l7=""http://ns.l7tech.com/2010/04/gateway-management"">
            <l7:Pkcs12Data>$pkcs12String</l7:Pkcs12Data>
            <l7:Alias>$Alias</l7:Alias>
            <l7:Password>$Password</l7:Password>
        </l7:PrivateKeyImportContext>
    ";
    }
    else {
        return "
        <l7:PrivateKeyImportContext xmlns:l7=""http://ns.l7tech.com/2010/04/gateway-management"">
            <l7:Pkcs12Data>$pkcs12String</l7:Pkcs12Data>
            <l7:Password>$Password</l7:Password>
        </l7:PrivateKeyImportContext>
    ";
    }
}

<##################################################################################################
.NAME
    Get-AuthenticationHeader
.DESCRIPTION
    Returns the header to be used in the REST calls (contains BASIC authentication)
.PARAMETER Username
    The username of the management user
.PARAMETER Password
    The password of the management user
##################################################################################################>
function Get-AuthenticationHeader([string] $Username, [string] $Password ) {

    $credential = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))

    return @{Authorization = 'Basic ' + $credential }
}


<##################################################################################################
.NAME
    Get-RestmanUrl
.DESCRIPTION
    This method creates a fully qualified restman URL to be used in the REST calls. The base URL 
    is created from the globalGeneral variable
.PARAMETER Uri
    The variable part of the URI
##################################################################################################>
function Get-RestmanUrl([string] $Uri) {

    return "https://$($global:globalGeneral.HostAddress):$($global:globalGeneral.TcpPort)/restman/1.0/$Uri";

}


<##################################################################################################
.NAME
    Write-Log
.DESCRIPTION
    This method appends a message to the end of the log file. Logging can be turned on and off 
    using the custom boolean field in the general structure.
.PARAMETER Message
    The message that will be appended to the log file
##################################################################################################>
function Write-Log([string] $Message) {

    if ($global:globalGeneral.AppObjectDN) {
        mkdir -Force "logs/$($global:globalGeneral.AppObjectDN)" | Out-Null

        if ($global:globalGeneral.VarText3.Trim() -eq "yes") {
            $Message | Out-File "logs/$($global:globalGeneral.AppObjectDN)/messages.log" -Append 
        }
    }

}


<##################################################################################################
.NAME
    Start-Transcriptlog
.DESCRIPTION
    This is a simple wrapper for the Start-Transcript cmdlet that is only executed when 
    logging is turned on
.PARAMETER CalledMethod
    The method that was called by the Venafi plattform. This value is used to create the 
    transcript file name
##################################################################################################>
function Start-TranscriptLog([string] $CalledMethod) {

    if ($global:globalGeneral.AppObjectDN) {
        mkdir -Force "logs/$($global:globalGeneral.AppObjectDN)" | Out-Null

        if ($global:globalGeneral.VarText3.Trim() -eq "yes") {
            Start-Transcript -Path "logs/$($global:globalGeneral.AppObjectDN)/$CalledMethod.transcript.log"
        }
    }

}


<##################################################################################################
.NAME
    Stop-Transcriptlog
.DESCRIPTION
    This is a simple wrapper for the Stop-Transcript cmdlet that is only executed when 
    logging is turned on
##################################################################################################>
function Stop-TranscriptLog {

    if ($global:globalGeneral.VarText3.Trim() -eq "yes") {
        Stop-Transcript
    }
}

<##################################################################################################
.NAME
    Get-ErrorReason
.DESCRIPTION
    Extracts the error message from Restman error responses. Restman returns differently structured
    XML responses depending on which status code is sent. If the exception has no response 
    object, its error message is returned
.PARAMETER Exception
    The exception from which the error message is read
##################################################################################################>
function Get-ErrorReason($Exception) {

    if (!$Exception.Response) {
        Write-Log "Excpetion does not contain an http response"
        return $Exception.Message
    }

    Write-Log "Failed with status code $($Exception.Response.StatusCode)"

    $responseBody = Out-StringFromStream $Exception.Response.GetResponseStream()
   
    Write-Log "Exception response is $responseBody"

    if ($responseBody.IndexOf("Authentication Failed") -gt -1) {
        return "Authentication Failed!"
    }
    if ($responseBody.IndexOf("syntactically incorrect") -gt -1) {
        return "XML sent to gateway was syntactically incorrect"
    }
    if ($responseBody.IndexOf("Resource not found") -gt -1) {
        return "Resource not found"
    }    
    if ($responseBody.IndexOf("Alias must be specified") -gt -1) {
        $matches = $responseBody | Select-String -Pattern "\[([a-zA-Z0-9\-]*)\]"
        return "Alias must be specified: " + $matches.Matches[0].Value
    }
    if ($responseBody.IndexOf("Keystore already contains an entry") -gt -1) {
        return "Key already installed"
    }
    if ($responseBody.IndexOf("DuplicateObject") -gt -1) {
        return "Certificate already installed"
    }    

    return $response

}

<##################################################################################################
.NAME
    Out-StringFromStream
.DESCRIPTION
    Reads a stream and returns its contents as a string
.PARAMETER Stream
    The stream that is read
##################################################################################################>
function Out-StringFromStream($Stream) {

    $result = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($result)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    return $reader.ReadToEnd()

}