<#
//---------------------------------------------------------------------------
// Actalis_Adaptable_Script.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// This software is licensed by ACTALIS S.p.A., in addition to Venafi.
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
#>

$global:version = "v1.1.0"      # version
$global:proxy_user = "" # set proxy user
$global:proxy_password = "" # set proxy password
$global:proxy_url = "" # set proxy url

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12


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
    try
    {
        $auth_cert = Get-AuthCert $General.PfxData $General.PfxPass $General.AuxPfxData $General.AuxPass
        
        $body = "test connection with adaptable CA script " + $global:version
        $headers = @{
            "Content-Type" = "text/plain"
        }
        $uri = $General.ServiceAddress + "/api/test/echo"
        $method = "POST"
        $proxy = Get-Proxy-Original $General
        $params = @{
            "Method" = $method
            "Uri" = $uri
            "Headers" = $headers
            "Certificate" = $auth_cert
            "Body" = $body
            "UseBasicParsing" = $null
        } + $proxy;

        if ( $DEBUG_FILE )
        {
            Log-RestMethodCall $params
        }

        $response = Invoke-WebRequest @params

        if ( $DEBUG_FILE )
        {
            Log-RestMethodResponse $params $response
        }

        return @{ Result="Success" }  
    }
    catch
    {
        throw (Done-Abnormal $_)
    }
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

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
    
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

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

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
    try
    {
        $auth_cert = Get-AuthCert $General.PfxData $General.PfxPass $General.AuxPfxData $General.AuxPass

        # Create organization unit parameters

        $ouArray = @() + $($Specific.SubjectDN.OU | ? {$_})  # an array of Organizational Units, possibly empty
        $ou1, $ou2 = $ouArray

        # Create subjectAN parameter
        $sans_dns = @() + $($Specific.SubjAltNames.DNS | ? {$_})  # an array of DNS Subject Alternative Names, possibly empty
        $sans_ip = @() + $($Specific.SubjAltNames.IP | ? {$_})  # an array of IP Subject Alternative Names, possibly empty
        $subjectAN = Get-SubjectAN $sans_dns $sans_ip

        # Get class and duration from input
        $certClass = ""
        if ($General.CustomFields.Actalis_Certificate_Class -is [array]) {
            $certClass = $General.CustomFields.Actalis_Certificate_Class[0]
        }
        elseif ($General.CustomFields.Actalis_Certificate_Class -is [string]) {
            $certClass = $General.CustomFields.Actalis_Certificate_Class
        }
        $certDuration = ""
        if ($General.CustomFields.Actalis_Validity_In_Months -is [array]) {
            $certDuration = $General.CustomFields.Actalis_Validity_In_Months[0]
        }
        elseif ($General.CustomFields.Actalis_Validity_In_Months -is [string]) {
            $certDuration = $General.CustomFields.Actalis_Validity_In_Months
        }

        $body = @{
            "certClass" = $certClass
            "duration" = $certDuration
            "operation" = "NEW"
            "subjectCN" = $Specific.SubjectDN.CN
            "subjectAN" = $subjectAN
            "organizationName" = $Specific.SubjectDN.O
            "orgUnit1" = $ou1
            "orgUnit2" = $ou2
            "referenceEmail" = $General.CustomFields.Actalis_Reference_Email
            "pkcs10" = $Specific.Pkcs10
        } | ConvertTo-Json
        $headers = @{
            "Content-Type" = "application/json"
        }
        $uri = $General.ServiceAddress + "/api/ca/enrollCertificate"
        $method = "POST"
        $proxy = Get-Proxy-Original $General
        $params = @{
            "Method" = $method
            "Uri" = $uri
            "Headers" = $headers
            "Certificate" = $auth_cert
            "Body" = $body
            "UseBasicParsing" = $null
        } + $proxy
        if ( $DEBUG_FILE )
        {
            Log-RestMethodCall $params
        }

        $response = Invoke-WebRequest @params
        if ( $DEBUG_FILE )
        {
            Log-RestMethodResponse $params $response
        }

        $certificateId = $response.Content

        return @{ Result="Success";TransId=$certificateId }
    }
    catch
    {
        throw (Done-Abnormal $_)
    }
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

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
    try
    {   
        if ( $Specific.CertId )
        {
            $auth_cert = Get-AuthCert $General.PfxData $General.PfxPass $General.AuxPfxData $General.AuxPass
            $body = @{
                "certificateId" = $Specific.CertId
                "operation" = "RENEW"
                "pkcs10" = $Specific.Pkcs10
            } | ConvertTo-Json
            $headers = @{
                "Content-Type" = "application/json"
            }
            $uri = $General.ServiceAddress + "/api/ca/enrollCertificate"
            $method = "POST"
            $proxy = Get-Proxy-Original $General
            $params = @{
                "Method" = $method
                "Uri" = $uri
                "Headers" = $headers
                "Certificate" = $auth_cert
                "Body" = $body
                "UseBasicParsing" = $null
            } + $proxy

            if ( $DEBUG_FILE )
            {
                Log-RestMethodCall $params
            }

            $response = Invoke-WebRequest @params
            if ( $DEBUG_FILE )
            {
                Log-RestMethodResponse $params $response
            }

            $certificateId = $response.Content

            return @{ Result="Success";TransId=$certificateId }
        }
        else
        {
            throw "the required CertId was not provided"
        }
    }
    catch
    {
        throw (Done-Abnormal $_)
    }
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

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
    try
    {   
        if ( $Specific.CertId )
        {
            $auth_cert = Get-AuthCert $General.PfxData $General.PfxPass $General.AuxPfxData $General.AuxPass

            # Create subjectAN parameter
            $sans_dns = @() + $($Specific.SubjAltNames.DNS | ? {$_})  # an array of DNS Subject Alternative Names, possibly empty
            $sans_ip = @() + $($Specific.SubjAltNames.IP | ? {$_})  # an array of IP Subject Alternative Names, possibly empty
            $subjectAN = Get-SubjectAN $sans_dns $sans_ip

            $body = @{
                "certificateId" = $Specific.CertId
                "operation" = "REISSUE"
                "subjectAN" = $subjectAN
                "pkcs10" = $Specific.Pkcs10
            } | ConvertTo-Json
            $headers = @{
                "Content-Type" = "application/json"
            }
            $uri = $General.ServiceAddress + "/api/ca/enrollCertificate"
            $method = "POST"
            $proxy = Get-Proxy-Original $General
            $params = @{
                "Method" = $method
                "Uri" = $uri
                "Headers" = $headers
                "Certificate" = $auth_cert
                "Body" = $body
                "UseBasicParsing" = $null
            } + $proxy
            if ( $DEBUG_FILE )
            {
                Log-RestMethodCall $params
            }

            $response = Invoke-WebRequest @params
            if ( $DEBUG_FILE )
            {
                Log-RestMethodResponse $params $response
            }

            $certificateId = $response.Content

            return @{ Result="Success";TransId=$certificateId }
        }
        else
        {
            throw "the required CertId was not provided"
        }
    }
    catch
    {
        throw (Done-Abnormal $_)
    }
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

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    return @{ Result="Success" }
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
    $ThisHost = Get-Host
    $ThisHost | Out-File $DEBUG_FILE -Append 
    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
    try
    {
        if ( $Specific.CertId )
        {
            $auth_cert = Get-AuthCert $General.PfxData $General.PfxPass $General.AuxPfxData $General.AuxPass

            # Preapare certificate chain for response
            $certs = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
            

            # Retrieve certificate end entity
            $uri = $General.ServiceAddress + "/api/ca/retrieveCertificateById?certificateId="+$Specific.CertId
            $method = "GET"
            $proxy = Get-Proxy-Original $General
            $params = @{
                "Method" = $method
                "Uri" = $uri
                "Certificate" = $auth_cert
                "UseBasicParsing" = $null
            } + $proxy
            
            if ( $DEBUG_FILE )
            {
                Log-RestMethodCall $params
            }

            $response = Invoke-WebRequest @params
            if ( $DEBUG_FILE )
            {
                Log-RestMethodResponse $params $response
            }

            # Retrieve end endtity certificate
            $retrieveCertificateJson = ConvertFrom-Json $response.Content
            $endEntity = $retrieveCertificateJson.eeCertificate.Replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----","").Replace("`r`n","")
            

            # Retrieve certificate chain
            $uri = $General.ServiceAddress + "/api/ca/getCaCerts?authword="+$retrieveCertificateJson.authword+".FC"
            $method = "GET"
            $proxy = Get-Proxy-Original $General
            $params = @{
                "Method" = $method
                "Uri" = $uri
                "Certificate" = $auth_cert
                "UseBasicParsing" = $null
            } + $proxy
            if ( $DEBUG_FILE )
            {
                Log-RestMethodCall $params
            }

            $response = Invoke-WebRequest @params
            if ( $DEBUG_FILE )
            {
                Log-RestMethodResponse $params $response
            }

            $retrieveChainArray = ConvertFrom-Json $response.Content

            # Import chain and end entity
            foreach ($element in $retrieveChainArray) {
                $certs.Import([Convert]::FromBase64String($element.certificate)) | Out-Null
                $element.label + " certificate added to chain" | Out-File $DEBUG_FILE -Append
            }
            $certs.Import([Convert]::FromBase64String($endEntity)) | Out-Null

            #Export certificates into result variable
            $bytes = $certs.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
            
            return @{ Result="Success"; Status="Issued"; PKCS7=$bytes }
        }
        else
        {
            throw "the required CertId was not provided"
        }
    }
    catch
    {
        throw (Done-Abnormal $_)
    }
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
    try
    {
        if ( $Specific.CertId )
        {
            $auth_cert = Get-AuthCert $General.PfxData $General.PfxPass $General.AuxPfxData $General.AuxPass

            # Prepare params
            $revokeReasons = @( "Unspecified", "Key Compromise", "CA Compromise", "Affiliation Changed", "Superseded", "Cessation of Operation" )
            $revokeReason = $revokeReasons[$Specific.ReasonCode]
            $body = @{
                "reason" = $revokeReason
            } | ConvertTo-Json
            $headers = @{
                "Content-Type" = "application/json"
            }
            $uri = $General.ServiceAddress + "/api/ca/revokeCertificateById/"+$Specific.CertId
            $method = "PUT"
            $proxy = Get-Proxy-Original $General
            $params = @{
                "Method" = $method
                "Uri" = $uri
                "Headers" = $headers
                "Certificate" = $auth_cert
                "Body" = $body
                "UseBasicParsing" = $null
            } + $proxy
            if ( $DEBUG_FILE )
            {
                Log-RestMethodCall $params
            }

            $response = Invoke-WebRequest @params
            if ( $DEBUG_FILE )
            {
                Log-RestMethodResponse $params $response
            }
            return @{ Result="Success" }
        }
        else
        {
            throw "the required CertId was not provided"
        }
    }
    catch
    {
        throw (Done-Abnormal $_)
    }
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

function Get-AuthCert( [byte[]] $pfxData, [System.Security.SecureString] $pfxPass, [byte[]] $auxPfxData, [System.Security.SecureString] $auxPfxPass )
{
    if ( $pfxData -ne $null )
    {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import( $pfxData, $pfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )
        return $cert
    } 
    elseif ( $auxPfxData -ne $null ) 
    {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import( $auxPfxData, $auxPfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )
        return $cert
    }
    else
    {
        throw "A client certificate credential is required for the Actalis PKI Service."
    }
}

function Get-SubjectAN( [array] $sans_dns, [array] $sans_ip)
{
    $dnsNamePrefix = "dNSName="
    $subjectAnArrayDns = $sans_dns | ForEach-Object { $dnsNamePrefix + $_ }
    $ipAddressPrefix = "iPAddress="
    $subjectAnArrayIp = $sans_ip | ForEach-Object { $ipAddressPrefix + $_ }
    $subjectAnArray = @() + $subjectAnArrayDns + $subjectAnArrayIp
    if ($subjectAnArray.Count -eq 0) {
        return ""
    } else {
        return $subjectAnArray -join ","
    }
}

function Get-Proxy-Original() {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )
    if (![string]::IsNullOrEmpty($global:proxy_password) -and ![string]::IsNullOrEmpty($global:proxy_user)) {
        $pass = ConvertTo-SecureString $global:proxy_password -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $global:proxy_user, $pass
        return @{"Proxy"=$global:proxy_url; "ProxyCredential"=$cred }
    } elseif (![string]::IsNullOrEmpty($global:proxy_url)) {
        return @{"Proxy"=$global:proxy_url}
    }
    return @{ }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE SUPPORT DEBUG LOGGING ##########>
function Log-RestMethodCall {
    param (
        [hashtable]$Params
    )
    # Prepare log message
    $method = $Params["Method"]
    $uri = $Params["Uri"]
    $headers = $Params["Headers"]
    $body = $Params["Body"]
    $logMessage = @"
##### ACTALIS WS REQUEST #####
[$(Get-Date)] - $method request to $uri
Headers:                $(ConvertTo-Json -InputObject $headers -Depth 4)
Parameters:             $body

"@
    # Write message to log
    $logMessage | Out-File $DEBUG_FILE -Append
}
function Log-RestMethodResponse {
    param (
        [hashtable]$Params,
        [Object] $Response
    )
    # Prepare log message
    $method = $Params["Method"]
    $uri = $Params["Uri"]
    $logMessage = @"
##### ACTALIS WS RESPONSE #####
[$(Get-Date)] - response to $method method $uri
StatusCode:             $($Response.StatusCode)
StatusDescription:      $($Response.StatusDescription)
Headers:                $(ConvertTo-Json -InputObject $Response.Headers -Depth 4)
Content:                $($Response.Content)

"@
    # Write message to log
    $logMessage | Out-File $DEBUG_FILE -Append
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
        "[$(Get-Date)] - Fatal Error Details" | Out-File $DEBUG_FILE -Append
        $Data.Exception.GetType().FullName | Out-File $DEBUG_FILE -Append
        $Data.Exception.Message | Out-File $DEBUG_FILE -Append
        $Data.ScriptStackTrace | Out-File $DEBUG_FILE -Append
    }

    $customMessage = $Data.Exception.Message

    if ( $Data.Exception -is [System.Net.WebException] )
    {
        $resp = $Data.Exception.Response
        if ( $DEBUG_FILE )
        {
            "[Response]" | Out-File $DEBUG_FILE -Append
            "HTTP/{0} {1} {2}`r`n" -f $resp.ProtocolVersion.ToString(), `
                [int]$resp.StatusCode,$resp.StatusDescription | Out-File $DEBUG_FILE -Append
        }
        if ( $null -ne $Data.Exception.Response.GetResponseStream() -and $Data.Exception.Response.GetResponseStream().CanRead )
        {
            $streamReader = New-Object System.IO.StreamReader $Data.Exception.Response.GetResponseStream()
            $jsonContent = $streamReader.ReadToEnd()
            try {    
                # convert error message to JSON
                $jsonObject = $jsonContent | ConvertFrom-Json
                if ($jsonObject.message -and $jsonObject.errorCode)
                {
                    $customMessage = "errorCode: {0} - message: {1}" -f $jsonObject.errorCode,$jsonObject.message
                }        
            }
            catch 
            {
                #error response is not a JSON object
                $customMessage = $jsonContent
            }
            finally 
            {
                $streamReader.Close()
            }
        }
    }
    if ( $DEBUG_FILE )
    {
        $customMessage | Out-File $DEBUG_FILE -Append
    }

    return $customMessage
}
