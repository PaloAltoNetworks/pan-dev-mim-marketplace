<#
//----------------------------------------------------------------------- 
// Nexus.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by Nexus Group, in addition to Venafi.
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

#List of enabled security protocols
[System.Net.ServicePointManager]::SecurityProtocol = `
    [System.Net.SecurityProtocolType]::Tls -bor `
    [System.Net.SecurityProtocolType]::Tls11 -bor `
    [System.Net.SecurityProtocolType]::Tls12

#This callback will validate whatever certificate provided by Nexus during SSL handshake
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

#Substitute following url with url to production service
$global:wsdl_url = "https://qa.nexusgroup.com:8443/cmws/CMWS?WSDL"

$global:wsdl_file = "C:\Program Files\Venafi\Scripts\AdaptableCA\CMWS.wsdl"

<##############################################################################
.NAME
	Test-Settings
.DESCRIPTION
	Verifies the ability to connect to and authenticate with the CA using the supplied credentials
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions
		UserName : the username for authenticating with the CA
		UserPass : the password for authenticating with the CA
		PfxData : PKCS#12 containing client certificate and private key for authenticating with the CA
		PfxPass : the password for access to the private key in the PKCS#12
		CustomFields : hashtable of Custom Fields; keys are field labels and values are strings (single valued) or string arrays (multi-valued)
.NOTES
	Returns a hashtable that includes the following variables
		Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##############################################################################>
function Test-Settings
{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="General Parameters")]
		[System.Collections.Hashtable]$General
	)
	
    try
    {
        $auth_cert = GetAuthCertificate $General
	
	    $ws = New-WebServiceProxy -Uri $global:wsdl_file
	    $ws.Url = $global:wsdl_url
	    $ws.ClientCertificates.Add($auth_cert)
        
		$request = New-Object ($ws.GetType().Namespace + ".searchRequest")
		$parameter = New-Object ($ws.GetType().Namespace + ".searchParameter")
		$criteria = New-Object ($ws.GetType().Namespace + ".searchCriteria")

		$criteria.commonName = ""
		$parameter.Item = $criteria
		$request.Item = $parameter
		$request.ItemElementName = "searchCertificates"

		$version = "1.2"
		$response = $ws.execute($request, [ref]$version)
		
		if (!$response){
			throw "Failed to invoke Search method"
		}
		
        return @{ Result="Success" }
    }
    catch
    {
        return @{Result=$_.Exception.Message}
    }
}

<##############################################################################
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
##############################################################################>
function Get-ChainCertificates
{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="General Parameters")]
		[System.Collections.Hashtable]$General
	)

	return @{ Result="NotUsed" }
}

<##############################################################################
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
##############################################################################>
function Submit-CsrAsNew
{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="General Parameters")]
		[System.Collections.Hashtable]$General,
		[Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
		[System.Collections.Hashtable]$Specific
	)

	try{
        $auth_cert = GetAuthCertificate $General

	    $ws = New-WebServiceProxy -Uri $global:wsdl_file
	    $ws.Url = $global:wsdl_url
	    $ws.ClientCertificates.Add($auth_cert)
	    
	    $request = New-Object ($ws.GetType().Namespace + ".enrollRequest")
	    $subject = New-Object ($ws.GetType().Namespace + ".subjectData")
	    $key = New-Object ($ws.GetType().Namespace + ".keyData")
	    $keyData = New-Object($ws.GetType().Namespace + ".publicKey")

	    $key_string = ParseCSR $Specific.Pkcs10

	    $key_bytes =  [Convert]::FromBase64String($key_string)
	    $keyData.encoded = $key_bytes
	    $keyData.format = "X.509"
	    $keyData.algorithm = "RSA"
	    $key.Item = $keyData
	    

	    $subject.commonName = $Specific.SubjectDN.CN
	    $subject.organization = $Specific.SubjectDN.O
	    $subject.countryName = $Specific.SubjectDN.C
	    $subject.stateOrProvince = $Specific.SubjectDN.ST
	    $subject.locality = $Specific.SubjectDN.L

        if ($Specific.SubjectDN.OU){
            $subject.organizationUnits = @() + $($Specific.SubjectDN.OU | ? {$_})
        }

	    
        $subject.data = @()
	    $dns = @() + $($Specific.SubjAltNames.DNS | ? {$_})
	    $ips = @() + $($Specific.SubjAltNames.IP | ? {$_})
	    $emails = @() + $($Specific.SubjAltNames.Email | ? {$_})
	    
	    AddSANs $dns $subject "dnsname"
	    AddSANs $ips $subject "ipaddress"
	    AddSANs $emails $subject "rfc822name"

	    $request.subjectData = $subject
	    $request.keyData = $key

        if ($General.CustomFields.Get_Item("NEXUS Token Procedure")){
            $request.procedure = $General.CustomFields.Get_Item("NEXUS Token Procedure")
        }

	    [string]$version = "1.2"

		$response = $ws.execute($request, [ref]$version)

	    if ($response.enrollResponseData){ 
            
			$collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection

            $certificate_bytes = [byte[]]$response.enrollResponseData[0].certificate
			$certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(, $certificate_bytes)

            $certificate.PublicKey.EncodedKeyValue.RawData = [Convert]::FromBase64String($key_string)

            $collection.Add($certificate)

			foreach($chain_cert_bytes in $response.caChainCertificate){
			    $chain_certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(, $chain_cert_bytes)
                $collection.Add($chain_certificate)
			}			

            $bytes = $collection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)

   			return @{ Result="Success";TransId=$certificate.SerialNumber;Pkcs7=$bytes}
		}
		
		return @{ Result="Error" }
	}
	catch
	{
		return @{ Result = $_.Exception.Message }
	}
}


<##############################################################################
.NAME
	Submit-CsrAsRenewal
.DESCRIPTION
	Submits a CSR to a CA for enrollment as a renewal of an existing certificate
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
	A hashtable containing the specific set of variables needed by this function (see Submit-CsrAsNew plus the following)
		CertPem : the raw, Base64-encoded X509 certificate to be renewed
.NOTES
	Returns a hashtable that includes the same variables detailed in Submit-CsrAsNew
##############################################################################>
function Submit-CsrAsRenewal
{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="General Parameters")]
		[System.Collections.Hashtable]$General,
		[Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
		[System.Collections.Hashtable]$Specific
	)

	return Submit-CsrAsNew $General $Specific
}


<##############################################################################
.NAME
	Submit-CsrAsReplacement
.DESCRIPTION
	Submits a CSR to a CA for enrollment as a replacement for an existing certificate
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
	A hashtable containing the specific set of variables needed by this function (see Submit-CsrAsNew plus the following)
		CertPem : the raw, Base64-encoded X509 certificate to be replaced
.NOTES
	Returns a hashtable that includes the same variables detailed in Submit-CsrAsNew
##############################################################################>
function Submit-CsrAsReplacement
{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="General Parameters")]
		[System.Collections.Hashtable]$General,
		[Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
		[System.Collections.Hashtable]$Specific
	)

	return Submit-CsrAsNew $General $Specific
}

<##############################################################################
.NAME
	Approve-Request
.DESCRIPTION
	Approves a previously submitted CSR
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
	A hashtable containing the specific set of variables needed by this function
		RequestId : a string that uniquely identifies the certificate issued by the CA
.NOTES
	Returns a hashtable that includes the following variables
		Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##############################################################################>
function Approve-Request
{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="General Parameters")]
		[System.Collections.Hashtable]$General,
		[Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
		[System.Collections.Hashtable]$Specific
	)

	return @{ Result="NotUsed" }
}

<##############################################################################
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
		Pkcs7 : a collection that includes the issued certificate and optionally includes all of the CA certificates in the chain
##############################################################################>
function Retrieve-Certificate
{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="General Parameters")]
		[System.Collections.Hashtable]$General,
		[Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
		[System.Collections.Hashtable]$Specific
	)

	return @{ Result="NotUsed" }
}

<##############################################################################
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
		ReasonCode : the revocation reason code
		Comment : a comment provided by the revocation requester
.NOTES
	Returns a hashtable that includes the following variables
		Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##############################################################################>
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
        $auth_cert = GetAuthCertificate $General

	    $global:ws = New-WebServiceProxy -Uri $global:wsdl_file
	    $global:ws.Url = $global:wsdl_url
	    $global:ws.ClientCertificates.Add($auth_cert)
    
        $certificate_id = SearchForCertificate $Specific.CertPem

        if(!$certificate_id){
            return @{Result="No such certificate found."}
        }

        $request = New-Object ($global:ws.GetType().Namespace + ".revokeRequest")
        $certificateToRevoke = New-Object ($global:ws.GetType().Namespace + ".revokeCertificate")

        $certificateToRevoke.reason = $Specific.ReasonCode
        $certificateToRevoke.certificateId =  $certificate_id

        $request.Items = $certificateToRevoke

        $version = "1.2"

        $response = $global:ws.execute($request, [ref]$version)
        
        foreach ($error in $response.revokeResponseErrors){
            return @{Result=$error.errorMessage}
        }
        
        return @{Result="Success"}
    }
    catch
    {
        return @{Result=$_.Exception.Message}
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
function Prepare-ForRequest
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="NotUsed" }
}


<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function ParseCSR($csr){
	$pkcs10 = New-Object -ComObject X509Enrollment.CX509CertificateRequestPkcs10
	$publicKey = New-Object -ComObject X509Enrollment.CX509PublicKey
	$pkcs10.InitializeDecode($csr, 0);
	return $pkcs10.PublicKey.EncodedKey()
}

function AddSANs($sans, $subject, $name){
	if ($sans.Length -gt 0){
		$count = 0
		foreach ($element in $sans) {
			$param = New-Object ($ws.GetType().Namespace + ".parameter")
			$param.name = "extension.subjectaltname.attributes." + $count + "." + $name + ".value"
			$param.value = $element
			$subject.data += $param
			$count++
		}
	}
}

function GetAuthCertificate{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="General Parameters")]
		[System.Collections.Hashtable]$General
	)

    try{	
        if ( $General.PfxData -ne $null )
	    {
	    	$auth_cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($General.PfxData, $General.PfxPass)
	    }
	    else
	    {
	    	throw "A client certificate credential is required."
	    }

        if ( -not (Test-Path $global:wsdl_file) )
        {
            throw "Local WSDL file not found (" + $global:wsdl_file + ")"
        }
        
        return $auth_cert
    }
    catch
    {
        throw $_.Exception.Message
    }
}

function SearchForCertificate{
	Param(
		[Parameter(Mandatory=$true,HelpMessage="Certificate PEM")]
		[string]$CertPem
	)

    try{
        $existing_cert_pem = $CertPem
        $existing_cert_pem = ([string]$existing_cert_pem).Replace("-----BEGIN CERTIFICATE-----", "").Replace("-----END CERTIFICATE-----", "")
        $existing_cert_bytes = [Convert]::FromBase64String($existing_cert_pem)
        $existing_cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(, $existing_cert_bytes)


	    $request = New-Object ($global:ws.GetType().Namespace + ".searchRequest")
	    $parameter = New-Object ($global:ws.GetType().Namespace + ".searchParameter")
	    $criteria = New-Object ($global:ws.GetType().Namespace + ".searchCriteria")

        $criteria.certificateSerialNumber = $existing_cert.SerialNumber
        $parameter.Item = $criteria

        $request.Item = $parameter
        $request.ItemElementName = "searchCertificates"

	    [string]$version = "1.2"

		$response = $global:ws.execute($request, [ref]$version)

	    if ($response.Items){
            if ($response.Items.Length -gt 1){
                throw "There is more then one certificate with such Serial Number."
            }
 
            return $response.Items[0]
		}
	}
	catch
	{
		throw $_.Exception.Message
	}   
}