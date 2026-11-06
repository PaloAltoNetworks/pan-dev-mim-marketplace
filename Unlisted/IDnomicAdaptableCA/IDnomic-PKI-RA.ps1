<#
//---------------------------------------------------------------------------
// IDnomic-PKI-RA.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// This software is licensed by Kwantec, in addition to Venafi.
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

# Ignore SSL/TLS certificate validation errors
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

$base_path = (Get-Location).Path

if ( (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" ) {
    $base_path = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Scripts"
}

# Temporary dir for logs
$global:temp_dir = $base_path + "\Temp"

# vendor-specific subtype. The content is related to Public Key Infrastructure (PKI) Registration Authority (RA) functionality
$global:vnd_idnomic_pki_ra = 'application/vnd.idnomic.pki.ra.v1+json'

# Default Test Workflow
$global:defaultWorkflow = 'SSL Server Workflow'

If ( !(Test-Path $global:temp_dir) ) {
    New-Item $global:temp_dir -Type Directory
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
        WebSdkUrl: string representing the complete URL for the TPP WebSDK. Null is always passed as a value 
            for the "Test-Settings" and "Get-ChainCertificates" functions, because those are only used for CA settings validation.
        OAuthAccessToken: OAuth token string. Tokens are passed only after you've provided the required information in 
            the WebSDK OAuth Token Configuration settings of the Adaptable object. Null is always passed as a value 
            for the "Test-Settings" and "Get-ChainCertificates" functions, because those are only used for CA settings validation.
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Test-Settings {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    if ( $General.PfxData ) {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )
		
        [IO.File]::WriteAllBytes($global:temp_dir + "/CA_PfxData.pfx", $General.PfxData)

        if ( $DEBUG_FILE ) { $cert | Format-List | Out-File $DEBUG_FILE -Append }
    }
	
    if ( $General.AuxPfxData ) {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import( $General.AuxPfxData, $General.AuxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )
		
        [IO.File]::WriteAllBytes($global:temp_dir + "/CA_AuxPfxData.pfx", $General.AuxPfxData)

        if ( $DEBUG_FILE ) { $cert | Format-List | Out-File $DEBUG_FILE -Append }
    }

    # We are using search request so these variables are only to test the valid certificate authentication
    $page = 1
    $resultsPerPage = 1

    #### Prepare uri ####        
    $url = "{0}/idpki/ra/certificates?resultsPerPage={1}&page={2}&workflowName={3}" -f $General.ServiceAddress.Trim(), $resultsPerPage, $page, $General.ProfileString.Trim()        

    # Headers
    $headers = @{            
        'Content-Type' = $global:vnd_idnomic_pki_ra
    }

    # Calling search rest endpoint with one result because it is just to validate the certificate
    $result = Invoke-RestMethod -Uri $url -Method "GET" -Headers $headers -Certificate $cert

    if (!$result -or !$result.searchResponseEntries) {
        throw "Unable to connect the server" 
    }

	
    return @{ Result = "Success" }
}


<##################################################################################################
.NAME
    Submit-CsrAsNew
.DESCRIPTION
    Submits a CSR to URA for enrollment as a new, first time certificate
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
        TransId : the identifier used to subsequently approve and/or retrieve the certificate request from the URA
        Pkcs7 : a collection that includes the issued certificate and optionally includes all of the URA certificates in the chain
        Pkcs12 : a collection that includes the issued certificate, its private key, and optionally all of the URA certificates in the chain
        PrivKeyPem : an OpenSSL or PKCS#8 private key in PEM format
        EncryptPass : the password used to encrypt the private key or PKCS#12
##################################################################################################>
function Submit-CsrAsNew {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
    
    try {
        # Get and Validate certificate
        $cert = Get-AuthCert $General.PfxData $General.PfxPass        
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }           
        # Service address is the variable where we have the server url
        if (!$General.ServiceAddress -or $General.ServiceAddress -eq "") {
            throw "Invalid specified ServiceAddress"
        }    

        #IMPORTANT: This Content Type is pointing to test env and version 1                                  
        $headers = @{
            'Content-Type' = $global:vnd_idnomic_pki_ra
        }                   
        
        #### Prepare uri ####
        $enrollUrl = "{0}/idpki/ra/certificates/enroll" -f $General.ServiceAddress.Trim()  

        #$headers = Make-Request-Header $General.UserName
        $body = Build-Request $General $Specific           
		
        # Remove unused content in the cert
        $strBody = $body | ConvertTo-Json -Compress
        $strBody = $strBody.Replace("\r\n", "")                    
        
        #### Call enroll service and check result ####
        $enrollResult = Invoke-RestMethod -Uri $enrollUrl -Method "POST" -Body $strBody -Certificate $cert -Headers $headers  
        if (!$enrollResult -or !$enrollResult.certificate) {
            throw "Invalid enrolled"
        }                      
        # Create the cert collection in order to returns the entire certificate chain
        $certificates = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection

        $enrollCertResult = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $enrollCertResult.Import([Convert]::FromBase64String($enrollResult.certificate))       
        $certificates.Add($enrollCertResult) 

        $serialNumber = $enrollCertResult.SerialNumber
        $issuerDn = $enrollCertResult.Issuer        

        $transId = $issuerDn + '/' + $serialNumber

        # Now include the cert chain if is possible
        $chainCertUrl = $General.ServiceAddress + "/idpki/ra/certificates/" + $transId + "/certificate-chain"
        $chainCert = Invoke-RestMethod -Uri $chainCertUrl -Method "GET" -Headers $headers -Certificate $cert
        if ($chainCert -and $chainCert.authorities -and $chainCert.authorities.Count -gt 0) {
            foreach ($authority in $chainCert.authorities) {
                $chainCertResult = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                $chainCertResult.Import([Convert]::FromBase64String($authority))
                $certificates.Add($chainCertResult)
            }
        }
        
        $bytes = $certificates.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
        # WARNING! transid is an URL formed by serialNumber and issuerDn
        return @{ Result = "Success"; TransID = $transId; Pkcs7 = $bytes; }   
    }
    catch {                        
        # Uncomment to get a better infor about logs
        #$path = $global:temp_dir + "\submit-log.txt"        
        #$_ | Out-File -FilePath $path -Encoding UTF8
        throw $_.Exception.Message
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
function Submit-CsrAsRenewal {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    <# NOTE: For the following reasons call 'CsrAsSubmit' as new in the renew process:
    1.- Renew enpoint is bugged and it doesn't response any body or confirmation
    2.- We have to have a VALID certificate if we try to renew a certificate. The problem
        is: The simulator revokes all certificates before the renew step  
    #>    
    return Submit-CsrAsNew -general $General -specific $Specific
    
    <#Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    try {                
        # Get and Validate certificate
        $cert = Get-AuthCert $General.PfxData $General.PfxPass           
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }           
        # Service address is the variable where we have the server url
        if (!$General.ServiceAddress -or $General.ServiceAddress -eq "") {
            throw "Invalid specified ServiceAddress"
        }  
        # In this step we require the Certid in order to renew the certifcate
        if (!$Specific.CertId) {
            throw "A Certificate ID is required for revoking the certificate."
        }
        
        #IMPORTANT: This Content Type is pointing to test env and version 1                                  
        $headers = @{
            'Content-Type' = 'application/' + $global:vnd_idnomic_pki_ra
        } 
      
        # Now we are ready to revoke the cert        
        $url = $General.ServiceAddress + "/idpki/ra/certificates/" + $Specific.CertId + "/renew-certificate"

        # Cleaning the cert        
        $csr = $Specific.Pkcs10
        $csr = Remove-Text-From-Certificate($csr)
        $body = @{                    
            csr = $csr         
        }

        $strBody = $body | ConvertTo-Json -Compress
        $strBody = $strBody.Replace("\r\n", "")        
        $result = Invoke-RestMethod -Uri $url -Method "POST" -Body $strBody -Headers $headers -Certificate $cert

        $path = $global:temp_dir + "\renew-result-log.txt"        
        $result | Out-File -FilePath $path -Encoding UTF8        

        # NOTE: Right now the renew endpoint isn't returning a response payload so we validate by http status
        if ($result -and $result.StatusCode -eq 201) {
            return @{ Result = 'Success' }
        }        
       
        throw "Unable to renew cert"
    }
    catch {
        $path = $global:temp_dir + "\renew-log.txt"        
        $_ | Out-File -FilePath $path -Encoding UTF8
        throw $_.Exception.Message
    }#>           
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
function Submit-CsrAsReplacement {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
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
function Approve-Request {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
    
    return @{ Result = "Success" }
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
function Retrieve-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    try {
        # Get and Validate certificate
        $cert = Get-AuthCert $General.PfxData $General.PfxPass           
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }           
        # Service address is the variable where we have the server url
        if (!$General.ServiceAddress -or $General.ServiceAddress -eq "") {
            throw "Invalid specified ServiceAddress"
        }  
        # In this step we require the Certid in order to renew the certifcate
        if (!$Specific.CertId) {
            throw "A Certificate ID is required for revoking the certificate."
        }       

        #IMPORTANT: This Content Type is pointing to test env and version 1                                  
        $headers = @{
            'Content-Type' = $global:vnd_idnomic_pki_ra
        } 
                
        $retrieveUrl = $General.ServiceAddress + "/idpki/ra/certificates/" + $Specific.CertId
        
        # Invoke the method trying to get the cert
        $retrieveCert = Invoke-RestMethod -Uri $retrieveUrl -Method "GET" -Headers $headers -Certificate $cert        

        if (!$retrieveCert -or !$retrieveCert.certificate) {
            throw "Certificate not found"                  
        } 

        # Retrieve certificate                    
        $retrieveCertResult = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $retrieveCertResult.Import([Convert]::FromBase64String($retrieveCert.certificate))            
        
        # Create the collection and add certificates
        $certificates = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
        $certificates.Add($retrieveCertResult) | Out-Null

        # Now include the cert chain if is possible
        $chainCertUrl = $General.ServiceAddress + "/idpki/ra/certificates/" + $Specific.CertId + "/certificate-chain"
        $chainCert = Invoke-RestMethod -Uri $chainCertUrl -Method "GET" -Headers $headers -Certificate $cert
        if ($chainCert -and $chainCert.authorities -and $chainCert.authorities.Count -gt 0) {
            foreach ($authority in $chainCert.authorities) {
                $chainCertResult = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                $chainCertResult.Import([Convert]::FromBase64String($authority))
                $certificates.Add($chainCertResult)
            }
        }

        $bytes = $certificates.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
        return @{ Result = "Success"; Status = "Issued"; Pkcs7 = $bytes; }  

        throw "Certificate not found"
    }
    catch {
        # Uncomment to get a better infor about logs
        #$path = $global:temp_dir + "\retrieve-log.txt"        
        #$_ | Out-File -FilePath $path -Encoding UTF8
        throw $_.Exception.Message  
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
function Revoke-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    try {           
        # Get and Validate certificate
        $cert = Get-AuthCert $General.PfxData $General.PfxPass           
        if (!$cert) {
            throw "A client certificate credential is required for the URA Service."
        }           
        # Service address is the variable where we have the server url
        if (!$General.ServiceAddress -or $General.ServiceAddress -eq "") {
            throw "Invalid specified ServiceAddress"
        } 
        if (!$Specific.ReasonCode -or $Specific.ReasonCode -eq "") {
            throw "A reason code is required for revoking the certificate."
        }

        #IMPORTANT: This Content Type is pointing to test env and version 1                                  
        $headers = @{
            'Content-Type' = $global:vnd_idnomic_pki_ra
        } 
      
        # Now we are ready to revoke the cert        
        $url = $General.ServiceAddress + "/idpki/ra/certificates/" + $Specific.CertId + "/revocation-attributes"
        $body = @{        
            reason = $Specific.ReasonCode               
        }

        $strBody = $body | ConvertTo-Json -Compress
        $result = Invoke-RestMethod -Uri $url -Method "PUT" -Body $strBody -Headers $headers -Certificate $cert

        if ($result -and $result.outcome -eq "REVOKED") {
            return @{ Result = 'Success' }
        }        
       
        throw "Unable to revoke cert"
    }
    catch {
        # Uncomment to get a better infor about logs
        #$path = $global:temp_dir + "\revoke-log.txt"        
        #$_ | Out-File -FilePath $path -Encoding UTF8
        throw $_.Exception.Message
    }            
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
function Prepare-ForRequest {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    return @{ Result = "Success" }
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
function Get-ChainCertificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
    
    return @{ Result = "NotUsed" }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Get-AuthCert( [byte[]] $pkcs12, [System.Security.SecureString] $passwd ) {
    if ( $pkcs12 -ne $null ) {
        return New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pkcs12, $passwd)
    }
    else {
        throw "A client certificate credential is required."
    }
}

function Out-Log ( $nm_func, $ht_gen, $ht_spec ) {
    if ( $DEBUG_FILE ) {
        $buf = "[{0}] {1}" -f $nm_func, $("." * (100 - $nm_func.Length))

        $buf += "`n`n##### GENERAL PARAMETERS #####`n "
        $buf += ($ht_gen.GetEnumerator() | sort Name | % { Show-Vars $_.Name $_.Value })
 
        if ( $ht_spec.Count -gt 0 ) {
            $buf += "`n`n##### FUNCTION SPECIFIC PARAMETERS #####`n "
            $buf += ($ht_spec.GetEnumerator() | sort Name | % { Show-Vars $_.Name $_.Value })
        }

        $buf | Out-File $DEBUG_FILE -Append
    }
}

function Show-Vars ( $name, $value ) {
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

function Remove-Text-From-Certificate ($csr) {    
    # The regex pattern
    $pattern = '-----[^-]*-----'
    # Replacing unused text inside certificate
    return $csr -replace $pattern, ''
}

function Build-Request( $General, $Specific ) {

    $csr = $Specific.Pkcs10
    $csr = Remove-Text-From-Certificate($csr)    

    $requestWorkflow = $global:defaultWorkflow    
    if ($General.ProfileString) {
        $requestWorkflow = $General.ProfileString.Trim()
    }    
    $certificateHolderEmail = ""
    if ($Specific.SubjAltNames.Email -gt 0) {
        foreach ($element in $Specific.SubjAltNames.Email) {
            $certificateHolderEmail = $element
        }        
    }    

    $body = @{
        certificateData        = @{
            csr = @($csr)
        }        
        requestWorkflow        = $requestWorkflow        
        certificateHolderEmail = $certificateHolderEmail        
    }

    return $body
}
