<#
//---------------------------------------------------------------------------
// Secur AWS CA script.ps1
//---------------------------------------------------------------------------

// Copyright (c) 2024 Venafi, Inc. All rights reserved.
// This software is licensed by Secur Solutions, in addition to Venafi.
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

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12


<##################################################################################################
.NAME
    Test-Settings
.DESCRIPTION
    Verifies that Trust Protection Platform can authenticate with the CA using the supplied credentials.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserName: the username required to authenticate with the CA
        UserPass: the password required to authenticate with the CA
        PfxData: a PKCS#12 containing a client certificate and private key required to authenticate with the CA
        PfxPass: the password required to access the private key in the PKCS#12
        AuxUser: a username paired with AuxPass for secondary authentication purposes
        AuxPass: the password for the AuxUser (username credential), AuxPfxData (certificate credential), or independent (password credential)
        AuxPfxData: a PKCS#12 containing client certificate and private key for secondary authentication purposes
        CertObjDN: the Venafi distinguished name of the certificate object in the policy tree
        CustomFields: the hash table of Custom Fields. Keys are field labels and values are either strings (single valued) or string arrays (multi-valued)
        ServiceAddress: URI, IP address or FQDN of the service you want to connect to
        ProfileString: String, can be delimited, which identifies product or profile associated with the service
		WebSdkUrl: string representing the complete URL for the TPP WebSDK. Null is always passed as a value 
			for the "Test-Settings" and "Get-ChainCertificates" functions, because those are only used for CA settings validation.
		OAuthAccessToken: OAuth token string. Tokens are passed only after you've provided the required information in 
			the WebSDK OAuth Token Configuration settings of the Adaptable object. Null is always passed as a value 
			for the "Test-Settings" and "Get-ChainCertificates" functions, because those are only used for CA settings validation.
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Test-Settings
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

   

    try
    {
        if ( 1 -eq 1 )
        {
            Done-Normal @{ Result="Success" }
            return
        }
        else
        {
            throw "Error test-settings"
        }
    }
    catch
    {
        throw (Done-Abnormal $_).Exception.Message
    }
}


<##################################################################################################
.NAME
    Get-ChainCertificates
.DESCRIPTION
    Retrieves the chain of CA certificates that are applicable to certificates issued by the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.NOTES
    Returns a hashtable that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs7: a collection that includes all of the CA certificates in the issuing chain
##################################################################################################>
function Get-ChainCertificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )


    try
    {
       

        if ( 1 -eq 1 )
        {
            Done-Normal @{ Result="Success" }
            return
        }
        else
        {
            Done-Normal @{ Result="NotUsed" }
            return
        }
    }
    catch
    {
        throw Decode-Error((Done-Abnormal $_).Exception)
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
        SubjectDN: the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames: hashtable keyed by SAN type; values are string arrays
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Prepare-ForRequest
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Done-Normal @{ Result="NotUsed" }
    return
}


<##################################################################################################
.NAME
    Submit-CsrAsNew
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a new, first time certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        Pkcs10: the Base64-encoded PKCS#10-formatted certificate signing request (CSR) to be enrolled
        SubjectDN: the requested subject distiguished name as a hash table. OU is a string array and all others are strings
        SubjAltNames: hash table keyed by SAN type. Values are string arrays.
        KeySize: the integer key size to be used if the CA creates the key pair
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' to indicate the non-error completion state. NOTE: this function is required.
        TransId: the identifier used to subsequently approve and/or retrieve the certificate from the CA
        Pkcs7: a collection that includes the issued certificate and (optionally) includes all of the CA certificates in the chain
        Pkcs12: a collection that includes the issued certificate, its private key, and optionally all of the CA certificates in the chain
        PrivKeyPem: an OpenSSL or PKCS#8 private key in PEM format
        EncryptPass: the password used to encrypt the private key or PKCS#12
##################################################################################################>
function Submit-CsrAsNew
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    try
    {
        $Csr = $Specific.Pkcs10
		$base64EncodedCsr = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Csr))
        $caARN = SetFrom $General.CustomFields "AWS Private CA Name (by Secur)" $true
        
        $keyUsages = SetFrom $General.CustomFields "AWS Private CA Certificate Key Usage (by Secur)" $false
        $extendedKeyUsages = SetFrom $General.CustomFields "AWS Private CA Extended Key Usage (by Secur)" $false

        $pqID = SetFrom $General.CustomFields "AWS Private CA Policy Qualifier ID (by Secur)" $false
        $policyID = SetFrom $General.CustomFields "AWS Private CA Policy Identifier (by Secur)" $false
        $quaz = SetFrom $General.CustomFields "AWS Private CA Qualifier (by Secur)" $false
		$qua = $quaz -replace ' ', ''

        $val = SetFrom $General.CustomFields "AWS Private CA Validity Period (by Secur)" $true 
        $extendedKey = New-Object System.Collections.ArrayList
        $dataEncipherment = 'false'
        $digitalSignature = 'false'
        $keyEncipherment = 'false'
        $nonRepudiation = 'false'
        foreach ( $key in $keyUsages )
        {
            if ( $key -eq "DataEncipherment" )
            {
                $dataEncipherment = 'true'
            }
            if ( $key -eq "DigitalSignature" )
            {
                $digitalSignature = 'true'
            }
            if ( $key -eq "KeyEncipherment" )
            {
                $keyEncipherment = 'true'
            }
            if ( $key -eq "NonRepudiation" )
            {
                $nonRepudiation = 'true'
            }
        }
        if($extendedKeyUsages -eq $null) {
        "null extendedkeyusage" | Out-File "C:\error.txt"
        }
        
        
        if($extendedKeyUsages -ne $null -and $extendedKeyUsages -notcontains "NOT_REQUIRED") {
            foreach ( $ekey in $extendedKeyUsages )
            {
                $extendedKey.Add(@{ExtendedKeyUsageType=$ekey});
            }
        }
		
		$jsonString = $extendedKey | ConvertTo-Json 
		$convertedObject = $jsonString | ConvertFrom-Json
		$convertedJsonString = $convertedObject | ConvertTo-Json
		$convertedJsonString = $convertedJsonString -replace '"','\"'
		$convertedJsonString = $convertedJsonString -replace '\s+',''
		$count = $extendedKey.Count
		#$count | Out-File "C:\counts.txt"
		if($count -eq 1) {
			$convertedJsonString = "["+$convertedJsonString+"]"
		}
		#$convertedJsonString | Out-File "C:\jsonString.txt"

        $keys = Get-AWSKeys 'secur-aws-pca' $General.UserName $General.UserPass 'security:manage' $General.ServiceAddress
	    #$General | Out-File "C:\generals.txt"
        if($pqID -ne $null -and $qua -ne $null -and $policyID -ne $null) {

            if($extendedKey -ne $null -and $extendedKeyUsages -notcontains "NOT_REQUIRED") {
				$syntaxJson = '{\"Extensions\":{\"CertificatePolicies\":[{\"CertPolicyId\":\"'+$policyID+'\",\"PolicyQualifiers\":[{\"PolicyQualifierId\":\"'+$pqID+'\",\"Qualifier\":{\"CpsUri\":\"'+$qua+'\"}}]}],\"KeyUsage\":{\"DigitalSignature\":'+($digitalSignature)+',\"DataEncipherment\":'+($dataEncipherment)+',\"KeyEncipherment\":'+($keyEncipherment)+',\"NonRepudiation\":'+($nonRepudiation)+'},\"ExtendedKeyUsage\":'+$convertedJsonString+'}}'
            } else {
				$syntaxJson = '{\"Extensions\":{\"CertificatePolicies\":[{\"CertPolicyId\":\"'+$policyID+'\",\"PolicyQualifiers\":[{\"PolicyQualifierId\":\"'+$pqID+'\",\"Qualifier\":{\"CpsUri\":\"'+$qua+'\"}}]}],\"KeyUsage\":{\"DigitalSignature\":'+($digitalSignature)+',\"DataEncipherment\":'+($dataEncipherment)+',\"KeyEncipherment\":'+($keyEncipherment)+',\"NonRepudiation\":'+($nonRepudiation)+'}}}'
            }
        } else {
            if($extendedKey -ne $null -and $extendedKeyUsages -notcontains "NOT_REQUIRED") {
				$syntaxJson = '{\"Extensions\":{\"KeyUsage\":{\"DigitalSignature\":'+($digitalSignature)+',\"DataEncipherment\":'+($dataEncipherment)+',\"KeyEncipherment\":'+($keyEncipherment)+',\"NonRepudiation\":'+($nonRepudiation)+'},\"ExtendedKeyUsage\":'+$convertedJsonString+'}}'
			} else {
				$syntaxJson = '{\"Extensions\":{\"KeyUsage\":{\"DigitalSignature\":'+($digitalSignature)+',\"DataEncipherment\":'+($dataEncipherment)+',\"KeyEncipherment\":'+($keyEncipherment)+',\"NonRepudiation\":'+($nonRepudiation)+'}}}'
            }
        }

		$awsCommand = "aws acm-pca issue-certificate --csr $base64EncodedCsr --region ap-southeast-1 --certificate-authority-arn $caARN --signing-algorithm 'SHA256WITHRSA' --validity Value=$val,Type='DAYS' --template-arn 'arn:aws:acm-pca:::template/BlankEndEntityCertificate_APIPassthrough/V1' --api-passthrough '$syntaxJson' "
		
		Invoke-Expression -Command "aws acm-pca issue-certificate --csr $base64EncodedCsr --region ap-southeast-1 --certificate-authority-arn $caARN --signing-algorithm 'SHA256WITHRSA' --validity Value=$val,Type='DAYS' --template-arn 'arn:aws:acm-pca:::template/BlankEndEntityCertificate_APIPassthrough/V1' --api-passthrough '$syntaxJson' " | Tee-Object -Variable resp 
		
		#$awsCommand | Out-File "C:\awsCommand.txt"
		#$resp | Out-File "C:\output.txt"
        $respString = $resp | Out-String  # Assuming $yourVariable holds the tee-object output

		$respJson = ConvertFrom-Json $respString

		$certificateArn = $respJson.CertificateArn
		#$certificateArn | Out-File "C:\outputcertarn.txt"
        
        Done-Normal @{ Result="Success"; TransID = $certificateArn}
        return

    }
    catch
    {
		$_.Exception | Out-File "C:\exception.txt"
    $_.Exception.InvocationInfo.ScriptLineNumber
        throw Decode-Error((Done-Abnormal $_).Exception)
    }
}


<##################################################################################################
.NAME
    Submit-CsrAsRenewal
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a renewal of an existing certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
        CertId: a string that uniquely identifies the certificate issued by the CA to be renewed
        CertPem: the raw, Base64-encoded X509 certificate to be renewed
.NOTES
    Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsRenewal
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return Submit-CsrAsNew -general $General -specific $Specific
}


<##################################################################################################
.NAME
    Submit-CsrAsReplacement
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a replacement for an existing certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
        CertId: a string that uniquely identifies the certificate issued by the CA to be replaced
        CertPem: the raw, Base64-encoded X509 certificate to be replaced
.NOTES
    Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsReplacement
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
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
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        TransId: a string that uniquely identifies the certificate request submitted to the CA
        SubjectDN: the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames: hashtable keyed by SAN type; values are string arrays
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Approve-Request
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Done-Normal @{ Result="NotUsed" }
    return
}


<##################################################################################################
.NAME
    Retrieve-Certificate
.DESCRIPTION
    Retrieves a signed certificate from the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId: a string that uniquely identifies the certificate issued by the CA
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Status: 'Pending' or 'Issued' to indicate whether the certificate has been issued by the CA
        Pkcs7: a collection that includes the issued certificate and (optionally) all of the CA certificates in the chain
        Pkcs12: a collection that includes the issued certificate, its private key, and optionally all of the CA certificates in the chain
        PrivKeyPem: an OpenSSL or PKCS#8 private key in PEM format
        EncryptPass: the password used to encrypt the private key or PKCS#12
        DiscardPrivateKeyAndCsr: boolean that when $true tells the driver to discard stored assets that will not match the certificate being returned
##################################################################################################>
function Retrieve-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    

    try
    {


        $certArn = $Specific.CertId
		
        $caARN = SetFrom $General.CustomFields "AWS Private CA Name (by Secur)" $true
		
        $awsCommand = "aws acm-pca get-certificate --certificate-authority-arn $caARN --certificate-arn $certArn --region ap-southeast-1"
		Invoke-Expression -Command $awsCommand | Tee-Object -Variable cert 
		#$awsCommand | Out-File "C:\getawscommand.txt"
        #$cert | Out-File "C:\awscert.txt"
		
		$certResponse = $cert | Out-String  # Assuming $yourVariable holds the tee-object output

		$certJson = ConvertFrom-Json $certResponse
        $encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($certJson.Certificate)
        $certs = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
        $certs.Import($encodedBytes)

        $encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($certJson.CertificateChain)
        $certs.Import($encodedBytes)
        
        $bytes = $certs.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
        return @{ Result = "Success"; Status = "Issued"; PKCS7 = $bytes }

        return
    }
    catch
    {
        throw Decode-Error((Done-Abnormal $_).Exception)
    }
}


<##################################################################################################
.NAME
    Revoke-Certificate
.DESCRIPTION
    Revokes a certificate issued by the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId: a string that uniquely identifies the certificate issued by the CA
        CertPem: the raw, Base64-encoded X509 certificate to be revoked
        ReasonCode: 1 (User Key Compromised), 2 (CA Key Compromised), 3 (User Changed Affiliation), 4 (Certificate Superseded), 5 (Original Use No Longer Valid)
        Comment: a comment provided by the revocation requester
.NOTES
    Returns a hashtable that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Revoke-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )


    try
    {
        $revokeReasons = @( "UNSPECIFIED", "KEY_COMPROMISE", "CERTIFICATE_AUTHORITY_COMPROMISE", "AFFILIATION_CHANGED", "SUPERSEDED", "CESSATION_OF_OPERATION" )
        $revokeReason = $revokeReasons[$Specific.ReasonCode]
        $certArn = $Specific.CertId
		
            $caARN = SetFrom $General.CustomFields "AWS Private CA Name (by Secur)" $true
			$awsCommand = "aws acm-pca get-certificate --certificate-authority-arn $caARN --certificate-arn $certArn --region ap-southeast-1"
			Invoke-Expression -Command $awsCommand | Tee-Object -Variable cert 
			#$awsCommand | Out-File "C:\getawscommand.txt"
			#$cert | Out-File "C:\awscert.txt"
		  
			$certResponse = $cert | Out-String  # Assuming $yourVariable holds the tee-object output
			$certJson = ConvertFrom-Json $certResponse
            $encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($certJson.Certificate)
            $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
            $cert.Import($encodedBytes)
			
        $serial = $cert.SerialNumber
        
		$awsCommand = "aws acm-pca revoke-certificate --certificate-authority-arn $caARN --certificate-serial $serial --revocation-reason $revokeReason --region ap-southeast-1"
		Invoke-Expression -Command $awsCommand
		  
        Done-Normal @{ Result="Success" }
        return
    }
    catch
    {
		
        throw Decode-Error((Done-Abnormal $_).Exception)
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Get-AuthCert( [byte[]] $pkcs12, [System.Security.SecureString] $passwd )
{
    if ( $pkcs12 -ne $null )
    {
        return New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pkcs12, $passwd)
    }
    else
    {
        throw "A client certificate credential is required for the Symantec Managed PKI Service."
    }
}

function Decode-Error( [Exception] $ex )
{
    try
    {
        $result = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)

        $xml = [xml]$reader.ReadToEnd()

        $errcode = $xml.Envelope.Body.Fault.detail.errorcode."#text"
        $errmsg = $xml.Envelope.Body.Fault.detail.message."#text"
        $line = $ex.StackTrace

        return $("{0} ({1}) : {2}" -f $errmsg, $errcode, $line)
    }
    catch # the response is either not xml or not in the expected format
    {
        return $ex.Message
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE SUPPORT DEBUG LOGGING ##########>

function Invoke-WebAPI
{
  param(
        [parameter(position=0, mandatory=$false)]
        [switch] $RestMethod,
        [parameter(position=1, mandatory=$true)]
        [string] $Method,
        [parameter(position=2, mandatory=$true)]
        [string] $Uri,
        [parameter(position=3, mandatory=$false)]
        [Collections.Hashtable] $Headers,
        [parameter(position=4, mandatory=$false)]
        [string] $Body,
        [parameter(position=5, mandatory=$false)]
        [string] $ContentType,
        [parameter(position=6, mandatory=$false)]
        [Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
    )

  $params = @{ Method=$Method; Uri=$Uri; UseBasicParsing=$true }

    if ( $DEBUG_FILE )
    {
        "".PadLeft(80,"_") | Out-File $DEBUG_FILE -Append
        "$(Get-Date) - $Method $Uri" | Out-File $DEBUG_FILE -Append
    }

    if ( $Headers )
    {
        if ( $DEBUG_FILE )
        {
            "[Headers]" | Out-File $DEBUG_FILE -Append
            $headers.GetEnumerator() | % { "{0}: {1}" -f $_.Name,$_.Value } | Out-File $DEBUG_FILE -Append
        }
        $params.Add( "Headers", $Headers )
    }

  if ( $ContentType )
    {
    if ( $DEBUG_FILE ) { "Content-Type: {0}" -f $ContentType | Out-File $DEBUG_FILE -Append }
        $params.Add( "ContentType", $ContentType )
    }

    if ( $Certificate )
    {
        if ( $DEBUG_FILE )
        {
            "[Client Certificate]" | Out-File $DEBUG_FILE -Append
            "Subject: $($Certificate.Subject)" | Out-File $DEBUG_FILE -Append
            "Issuer: $($Certificate.Issuer)" | Out-File $DEBUG_FILE -Append
            "SerialNumber: $($Certificate.SerialNumber)" | Out-File $DEBUG_FILE -Append
            "Thumbprint: $($Certificate.Thumbprint)" | Out-File $DEBUG_FILE -Append
            "NotBefore: $($Certificate.NotBefore)" | Out-File $DEBUG_FILE -Append
            "NotAfter: $($Certificate.NotAfter)" | Out-File $DEBUG_FILE -Append
        }
        $params.Add( "Certificate", $Certificate )
    }

    if ( $Body )
    {
        if ( $DEBUG_FILE ) { "[Body]`r`n$Body" | Out-File $DEBUG_FILE -Append }
        $params.Add( "Body", $body )
    }

    $response = Invoke-WebRequest @params

    if ( $DEBUG_FILE )
    {
        "[Response]`r`n$($response.RawContent)" | Out-File $DEBUG_FILE -Append
    }

    if ( $RestMethod ) { return ($response.Content | ConvertFrom-Json) }

    return $response
}

function Done-Normal
{
    param(
        [parameter(position=0, mandatory=$true)]
        [Collections.Hashtable] $Data
    )

    if ( $DEBUG_FILE )
    {
        "".PadLeft(80,"_") | Out-File $DEBUG_FILE -Append
        $caller = (Get-PSCallStack)[1].FunctionName
        "$(Get-Date) - Data Returned by $caller" | Out-File $DEBUG_FILE -Append

        $vars = $Data.Clone()

        foreach ( $key in $Data.Keys )
        {
            if ( $Data[$key] -is [System.Byte[]] )
            {
                # response data sometimes includes byte arrays so base64 encode for debug logging purposes
                $vars[$key] = [Convert]::ToBase64String($Data[$key])
            }
        }

        $vars | ConvertTo-Json -Depth 10 | Out-File $DEBUG_FILE -Append
    }

    return $Data
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
        "$(Get-Date) - Fatal Error Details" | Out-File $DEBUG_FILE -Append
        $Data.Exception.GetType().FullName | Out-File $DEBUG_FILE -Append
        $Data.Exception.Message | Out-File $DEBUG_FILE -Append
        $Data.ScriptStackTrace | Out-File $DEBUG_FILE -Append

        if ( $Data.Exception -is [System.Net.WebException] )
        {
            $resp = $Data.Exception.Response

            "[Response]" | Out-File $DEBUG_FILE -Append
            "HTTP/{0} {1} {2}`r`n" -f $resp.ProtocolVersion.ToString(), `
                [int]$resp.StatusCode,$resp.StatusDescription | Out-File $DEBUG_FILE -Append

            if ( $Data.Exception.Response.ContentLength -gt 0 )
            {
                $result = $Data.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $reader.ReadToEnd() | Out-File $DEBUG_FILE -Append
            }
        }
    }

    return $Data
}

function Get-AWSKeys 
{
param(
        [parameter(position=0, mandatory=$true)]
        [string] $ClientID,
        [parameter(position=1, mandatory=$true)]
        [string] $Username,
        [parameter(position=2, mandatory=$true)]
        [string] $Password,
        [parameter(position=3, mandatory=$false)]
        [string] $Scope,
        [parameter(position=4, mandatory=$false)]
        [string] $URL
        
    )

    $jsonauthBody = @{
            client_id = $ClientID
            username = $Username
            password = $Password
            scope = $Scope
        } | ConvertTo-Json -Compress
        $authURL = $URL + "/vedauth/authorize/oauth"
        $tppauthresponse = Invoke-RestMethod -Method POST -Uri $authURL -ContentType 'application/json' -Body $jsonauthBody

        $tpptoken = $tppauthresponse.access_token 
        $tppheaders = @{Authorization = "Bearer $tpptoken"} 

        $credentialURL = $URL + "/vedsdk/Credentials/Retrieve"

        $jsonGetIDBody = @{
            CredentialPath = '\\VED\\Policy\\Administration\\Credentials\\Secur AWS CA'
        } | ConvertTo-Json 

            $tppresponse = Invoke-RestMethod -Method Post -Uri $credentialURL -ContentType 'application/json' -Body $jsonGetIDBody -Headers $tppheaders
            
    $accessKey = $tppresponse.Values[1].Value
    $secretKey = $tppresponse.Values[2].Value

    
    $keys =  @{ AccessKey = $accessKey; SecretKey = $secretKey}
	$Env:AWS_ACCESS_KEY_ID = $accessKey
	$Env:AWS_SECRET_ACCESS_KEY = $secretKey

    return $keys
}


function SetFrom{
    Param(
        [Parameter(Mandatory=$true)]
		[System.Collections.Hashtable]$fields,
		[Parameter(Mandatory=$true)]
		[System.String]$parameter_name,
		[Parameter(Mandatory=$true)]
		[bool]$required
        )
     if (!(IsNullOrEmpty($fields.Get_Item($parameter_name)))){
         return $fields.Get_Item($parameter_name)
     }else {
        if ($required){
            throw "Required parameter : '" + $parameter_name            
        }
     }
     return $null
}



function IsNullOrEmpty($inputString){
    if ($inputString -eq $null) {
        return $true
    }

    if ($inputString -is [String] -and $inputString -eq [String]::Empty) {
        return $true
    }

    return $false
}
