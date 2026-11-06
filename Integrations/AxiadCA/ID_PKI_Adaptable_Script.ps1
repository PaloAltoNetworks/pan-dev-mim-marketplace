<#
//---------------------------------------------------------------------------
// ID_PKI_Adaptable_Script.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2022 Venafi, Inc. All rights reserved.
//
// This software is licensed by Axiad IDS Inc., in addition to Venafi.
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

Add-Type -AssemblyName System.Security

$global:version = "v1.1.0"

$base_path = (Get-Location).Path

# Global variables - adjust based on organization

$global:requestPreamble = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:req="http://www.idnomic.com/ngca/connector/1_2"
xmlns:ws="http://www.idnomic.com/ngca/connector/ws/1_2"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<SOAP-ENV:Header/>
<SOAP-ENV:Body>' #Preamble for requests



if ( (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" )
{
    $base_path = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Scripts"
}

<#$global:temp_dir = $base_path + "\Temp"

If ( !(Test-Path $global:temp_dir) )
{
   New-Item $global:temp_dir -Type Directory
}
#>

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
        CertObjDN : the Venafi distinguished name of the certificate object in the policy tree
        CustomFields : the hash table of Custom Fields. Keys are field labels and values are either strings (single valued) or string arrays (multi-valued).
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

	
	$loginResult = logintoCA $General

    return $loginResult
	
    #return @{ Result="Success" }
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

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
  
    
# Get the certificate request information from the parameters

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
	$cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )

    $cn=$Specific.SubjectDN.CN
    $SANDNS=@() + $( $Specific.SubjAltNames.DNS | ? { $_ } )
    $SANURI=@() + $( $Specific.SubjAltNames.URI | ? { $_ } )
    $SANIP=@() + $( $Specific.SubjAltNames.IP | ? { $_ } )
    $SANUPN=@() + $( $Specific.SubjAltNames.UPN | ? { $_ } )
    $SANEmail=@() + $( $Specific.SubjAltNames.Email | ? { $_ } )
    
    
    $country=$Specific.SubjectDN.C
    $state=$Specific.SubjectDN.S
    $local=$Specific.SubjectDN.L
    $Org=$Specific.SubjectDN.O
    $OU=@() + $( $Specific.SubjectDN.OU | ? { $_ } )
    $base_url=$General.ServiceAddress
    $CAPartition=$General.CustomFields["CAPartition"]
    $CertificateTemplate=$General.ProfileString
    $issuerDN=$General.CustomFields["IssuerDN"]

# Construct the SAN portion

    $SANString = New-Object -TypeName System.Text.StringBuilder
    
    if (!$Specific.SubjAltNames.DNS) {
        $SANDNS=@() +$($Specific.SubjectDN.CN)
    }
    foreach ($element in $SANDNS)
    {
        $null = $SANString.Append('<value>')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    } 
    
    foreach ($element in $SANEmail)
    {
        $null = $SANString.Append('<value>')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    }
    
    foreach ($element in $SANURI)
    {
        $null = $SANString.Append('<value>')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    }
    
    foreach ($element in $SANUPN)
    {
        $null = $SANString.Append('<value>')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    }
    
    foreach ($element in $SANIP)
    {
        $null = $SANString.Append('<value>]')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    }  

    $mergedSAN=$SANString.ToString()
        

if ( $DEBUG_FILE ) { $Specific.SubjAltNames | Out-File $DEBUG_FILE -Append }
if ( $DEBUG_FILE ) { $Specific.SubjectDN | Out-File $DEBUG_FILE -Append }
if ( $DEBUG_FILE ) { $Specific.SubjAltNames.DNS | Out-File $DEBUG_FILE -Append }

if ( $DEBUG_FILE ) { $mergedSAN | Out-File $DEBUG_FILE -Append }

    

## Deal with CSR

    $requestCSRtemp=[string]::join("",($Specific.Pkcs10.Split("`n`r")))
    $requestCSR=$requestCSRtemp -replace '-----BEGIN CERTIFICATE REQUEST-----','' -replace '-----END CERTIFICATE REQUEST-----',''
## Uncomment below if using the simulator for testing
##    $requestCSR=$requestCSRtemp -replace '-----BEGIN NEW CERTIFICATE REQUEST-----','' -replace '-----END NEW CERTIFICATE REQUEST-----',''
    if ( $DEBUG_FILE ) { $requestCSR | Format-List | Out-File $DEBUG_FILE -Append }


## 

# Set up the SOAP request to IDPKI

[xml]$requestCertEnroll = '<soapenv:Envelope xmlns:_0="http://www.idnomic.com/ngca/connector/ws/1_2"
xmlns:_01="http://www.idnomic.com/ngca/connector/1_2"
xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<soapenv:Header/>
<soapenv:Body>
<_0:enroll>
<_01:EnrollmentRequest xsi:type="_01:X509EnrollmentRequestType">
<certificateProfile>/' + $CAPartition + '/' + $CertificateTemplate + '</certificateProfile>
<partition>/' + $CAPartition + '</partition>
<csr>' + $requestCSR + '</csr>
<cn>'+$cn+'</cn>
<certificateFormat>DER</certificateFormat>
<certificateData>
<param name="subjectAltName">

'+$mergedSAN+'

</param>
</certificateData>
</_01:EnrollmentRequest>
</_0:enroll>
</soapenv:Body>
</soapenv:Envelope>'


    if ( $DEBUG_FILE ) { $requestCertEnroll.InnerXML | Out-File $DEBUG_FILE -Append }
    if ( $DEBUG_FILE ) { $mergedSAN | Out-File $DEBUG_FILE -Append }


# Sign the certificate request XML
 
    try {
    [System.Security.Cryptography.Xml.SignedXml]$signedXMLRequest = New-Object System.Security.Cryptography.Xml.SignedXml -ArgumentList $requestCertEnroll
    }

    catch 
    {
        throw($_)
    
    }

	$cryptoConfig = (New-Object System.Security.Cryptography.CspParameters(24))
	$cryptoConfig.KeyContainerName = "XML_DSIG_RSA_KEY"
	$RSAKey = New-Object System.Security.Cryptography.RSACryptoServiceProvider(2048,$cryptoConfig)
	
	$RSAKey.key = cert.PrivateKey
	$signedXMLRequest.SigningKey = $RSAKey
	$signedXMLRequest.SigningKey.SignatureMethond = SecurityAlgorithms.RsaSha256Signature
	

	if ( $DEBUG_FILE ) { $cert.HasPrivateKey | Out-File $DEBUG_FILE -Append }
   
    if ( $DEBUG_FILE ) { $signedXMLRequest.SigningKey | Out-File $DEBUG_FILE -Append }

    try {
    $keyInfo = New-Object System.Security.Cryptography.Xml.KeyInfo
    $keyInfo.AddClause((New-Object System.Security.Cryptography.Xml.KeyInfoX509Data -ArgumentList $cert))
    $signedXMLRequest.KeyInfo = $keyInfo
	

    }

    catch 
    {
        throw($_)
    
    }

    $Reference = New-Object System.Security.Cryptography.Xml.Reference
    $Reference.Uri = ""

    $env = New-Object System.Security.Cryptography.Xml.XmlDsigEnvelopedSignatureTransform

    $Reference.AddTransform($env)
    $signedXMLRequest.AddReference($Reference)
    try
    {
        $signedXMLRequest.ComputeSignature()
    }
    catch 
    {
        throw($_)
    
    }
    
    
# Set up the cert request



    [System.Xml.XmlElement]$xmlSignature = $signedXMLRequest.GetXml()

    if ( $DEBUG_FILE ) { $xmlSignature | Out-File $DEBUG_FILE -Append }


    $requestCertEnroll.DocumentElement.AppendChild($requestCertEnroll.ImportNode($xmlSignature, $true))

    if ( $DEBUG_FILE ) { $requestCertEnroll.InnerXml | Format-List | Out-File $DEBUG_FILE -Append }

    if($requestCertEnroll.FirstChild -is [System.Xml.XmlDeclaration])
    {
        $requestCertEnroll.RemoveChild($requestCertEnroll.FirstChild)
    }

    


# Send the enrollment request to IDPKI

try {
    [xml]$WebAccessReq = Invoke-WebRequest -Uri $base_url -Certificate $cert -Method Post -ContentType 'text/xml' -Body $requestCertEnroll
    
    

     ##if ( $DEBUG_FILE ) { $WebAccessReq | Out-File $DEBUG_FILE -Append }
       
    if ( $DEBUG_FILE ) { $WebAccessReq.InnerXml | Out-File $DEBUG_FILE -Append }

# Extract the Certificate from the response and set up the return Hash table

    $dataread = $WebAccessReq.SelectNodes('//certificate') | Select-Object -Expand '#text'

    $returnedCertData = New-Object System.Text.StringBuilder
    $returnedCertData.AppendLine("-----BEGIN CERTIFICATE-----")
    $returnedCertData.AppendLine($dataread)
    $returnedCertData.AppendLine("-----END CERTIFICATE-----")

    $certFilePath = $base_path + '\cert' + (Get-Date).ToString("yyyyMMdd-hhmmss") + '.crt'
     
    $returnedCertData.ToString() | Out-File $certFilePath

    if ( $DEBUG_FILE ) { $dataread | Out-File $DEBUG_FILE -Append }
    
    [System.Security.Cryptography.X509Certificates.X509Certificate2]$returnedCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
	$returnedCert.Import($certFilePath)
    
    $serialNo = $returnedCert.SerialNumber
    $decoder=[system.Text.Encoding]::UTF8

    Remove-Item $certFilePath
    
    return @{ Result="Success";TransId=$serialNo;Pkcs7=$decoder.GetBytes($returnedCertData) }
    }
    catch {
        
        throw($_)
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
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
  
    
# Get the certificate request information from the parameters

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
	$cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )

    $cn=$Specific.SubjectDN.CN
    $SANDNS=@() + $( $Specific.SubjAltNames.DNS | ? { $_ } )
    $SANURI=@() + $( $Specific.SubjAltNames.URI | ? { $_ } )
    $SANIP=@() + $( $Specific.SubjAltNames.IP | ? { $_ } )
    $SANUPN=@() + $( $Specific.SubjAltNames.UPN | ? { $_ } )
    $SANEmail=@() + $( $Specific.SubjAltNames.Email | ? { $_ } )
    
    
    $country=$Specific.SubjectDN.C
    $state=$Specific.SubjectDN.S
    $local=$Specific.SubjectDN.L
    $Org=$Specific.SubjectDN.O
    $OU=@() + $( $Specific.SubjectDN.OU | ? { $_ } )
    $base_url=$General.ServiceAddress
    $CAPartition=$General.CustomFields["CAPartition"]
    $CertificateTemplate=$General.ProfileString
    $issuerDN=$General.CustomFields["IssuerDN"]

# Construct the SAN portion

    $SANString = New-Object -TypeName System.Text.StringBuilder

     if (!$Specific.SubjAltNames.DNS) {
        $SANDNS=@() +$($Specific.SubjectDN.CN)
    }

    foreach ($element in $SANDNS)
    {
        $null = $SANString.Append('<value>')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    } 
    
    foreach ($element in $SANEmail)
    {
        $null = $SANString.Append('<value>')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    }
    
    foreach ($element in $SANURI)
    {
        $null = $SANString.Append('<value>')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    }
    
    foreach ($element in $SANUPN)
    {
        $null = $SANString.Append('<value>')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    }
    
    foreach ($element in $SANIP)
    {
        $null = $SANString.Append('<value>]')
        $null = $SANString.Append($element)
        $null = $SANString.Append('</value>')
        
    }  

    $mergedSAN=$SANString.ToString()
        

if ( $DEBUG_FILE ) { $Specific.SubjAltNames | Out-File $DEBUG_FILE -Append }
if ( $DEBUG_FILE ) { $Specific.SubjectDN | Out-File $DEBUG_FILE -Append }

if ( $DEBUG_FILE ) { $Specific.SubjAltNames.Count | Out-File $DEBUG_FILE -Append }

if ( $DEBUG_FILE ) { $mergedSAN | Out-File $DEBUG_FILE -Append }

    

## Deal with CSR

    $requestCSRtemp=[string]::join("",($Specific.Pkcs10.Split("`n`r")))
    $requestCSR=$requestCSRtemp -replace '-----BEGIN CERTIFICATE REQUEST-----','' -replace '-----END CERTIFICATE REQUEST-----',''

## Uncomment below if using the simulator for testing
    ##    $requestCSR=$requestCSRtemp -replace '-----BEGIN NEW CERTIFICATE REQUEST-----','' -replace '-----END NEW CERTIFICATE REQUEST-----',''
    if ( $DEBUG_FILE ) { $requestCSR | Format-List | Out-File $DEBUG_FILE -Append }


## 

# Set up the SOAP request to IDPKI

[xml]$requestCertEnroll = '<soapenv:Envelope xmlns:_0="http://www.idnomic.com/ngca/connector/ws/1_2"
xmlns:_01="http://www.idnomic.com/ngca/connector/1_2"
xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<soapenv:Header/>
<soapenv:Body>
<_0:enroll>
<_01:EnrollmentRequest xsi:type="_01:X509EnrollmentRequestType">
<certificateProfile>/' + $CAPartition + '/' + $CertificateTemplate + '</certificateProfile>
<partition>/' + $CAPartition + '</partition>
<csr>' + $requestCSR + '</csr>
<cn>'+$cn+'</cn>
<certificateFormat>DER</certificateFormat>
<certificateData>
<param name="subjectAltName">

'+$mergedSAN+'

</param>
</certificateData>
</_01:EnrollmentRequest>
</_0:enroll>
</soapenv:Body>
</soapenv:Envelope>'


    if ( $DEBUG_FILE ) { $requestCertEnroll.InnerXML | Out-File $DEBUG_FILE -Append }
    if ( $DEBUG_FILE ) { $mergedSAN | Out-File $DEBUG_FILE -Append }


# Sign the certificate request XML
 
    try {
    [System.Security.Cryptography.Xml.SignedXml]$signedXMLRequest = New-Object System.Security.Cryptography.Xml.SignedXml -ArgumentList $requestCertEnroll
    }

    catch 
    {
        throw($_)
    
    }

	$cryptoConfig = (New-Object System.Security.Cryptography.CspParameters(24))
	$cryptoConfig.KeyContainerName = "XML_DSIG_RSA_KEY"
	$RSAKey = New-Object System.Security.Cryptography.RSACryptoServiceProvider(2048,$cryptoConfig)
	
	$RSAKey.key = cert.PrivateKey
	$signedXMLRequest.SigningKey = $RSAKey
	$signedXMLRequest.SigningKey.SignatureMethond = SecurityAlgorithms.RsaSha256Signature
	

	if ( $DEBUG_FILE ) { $cert.HasPrivateKey | Out-File $DEBUG_FILE -Append }
   
    if ( $DEBUG_FILE ) { $signedXMLRequest.SigningKey | Out-File $DEBUG_FILE -Append }

    try {
    $keyInfo = New-Object System.Security.Cryptography.Xml.KeyInfo
    $keyInfo.AddClause((New-Object System.Security.Cryptography.Xml.KeyInfoX509Data -ArgumentList $cert))
    $signedXMLRequest.KeyInfo = $keyInfo
	

    }

    catch 
    {
        throw($_)
    
    }

    $Reference = New-Object System.Security.Cryptography.Xml.Reference
    $Reference.Uri = ""

    $env = New-Object System.Security.Cryptography.Xml.XmlDsigEnvelopedSignatureTransform

    $Reference.AddTransform($env)
    $signedXMLRequest.AddReference($Reference)
    try
    {
        $signedXMLRequest.ComputeSignature()
    }
    catch 
    {
        throw($_)
    
    }
    
    
# Set up the cert request



    [System.Xml.XmlElement]$xmlSignature = $signedXMLRequest.GetXml()

    if ( $DEBUG_FILE ) { $xmlSignature | Out-File $DEBUG_FILE -Append }


    $requestCertEnroll.DocumentElement.AppendChild($requestCertEnroll.ImportNode($xmlSignature, $true))

    if ( $DEBUG_FILE ) { $requestCertEnroll.InnerXml | Format-List | Out-File $DEBUG_FILE -Append }

    if($requestCertEnroll.FirstChild -is [System.Xml.XmlDeclaration])
    {
        $requestCertEnroll.RemoveChild($requestCertEnroll.FirstChild)
    }

    


# Send the enrollment request to IDPKI

try {
    [xml]$WebAccessReq = Invoke-WebRequest -Uri $base_url -Certificate $cert -Method Post -ContentType 'text/xml' -Body $requestCertEnroll
    
    

     ##if ( $DEBUG_FILE ) { $WebAccessReq | Out-File $DEBUG_FILE -Append }
       
    if ( $DEBUG_FILE ) { $WebAccessReq.InnerXml | Out-File $DEBUG_FILE -Append }

# Extract the Certificate from the response and set up the return Hash table

    $dataread = $WebAccessReq.SelectNodes('//certificate') | Select-Object -Expand '#text'

    $returnedCertData = New-Object System.Text.StringBuilder
    $returnedCertData.AppendLine("-----BEGIN CERTIFICATE-----")
    $returnedCertData.AppendLine($dataread)
    $returnedCertData.AppendLine("-----END CERTIFICATE-----")

    $certFilePath = $base_path + '\cert' + (Get-Date).ToString("yyyyMMdd-hhmmss") + '.crt'
     
    $returnedCertData.ToString() | Out-File $certFilePath

    if ( $DEBUG_FILE ) { $dataread | Out-File $DEBUG_FILE -Append }
    
    [System.Security.Cryptography.X509Certificates.X509Certificate2]$returnedCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
	$returnedCert.Import($certFilePath)
    
    $serialNo = $returnedCert.SerialNumber
    $decoder=[system.Text.Encoding]::UTF8

    Remove-Item $certFilePath
    
    return @{ Result="Success";TransId=$serialNo;Pkcs7=$decoder.GetBytes($returnedCertData) }
    }
    catch {
        
        throw($_)
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

    Revoke-Certificate $General $Specific

    return Submit-CsrAsNew $General $Specific
    
  
    

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

    return @{ Result="NotUsed" }
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

    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    if ( $DEBUG_FILE ) { $General | Format-List | Out-File $DEBUG_FILE -Append }
    if ( $DEBUG_FILE ) { $Specific | Format-List | Out-File $DEBUG_FILE -Append }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get the authentication cert for the download request

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )

# CertID is assumed to contain the certificate serial number.  Verify it exists in the request and set up for the request
    if ( $Specific.CertId )
    {


    $CertSerial = $Specific.CertId.toString()
    $base_url=$General.ServiceAddress
    $CAPartition=$General.CustomFields["CAPartition"]
    $CertificateTemplate=$General.ProfileString
    $issuerDN=$General.CustomFields["IssuerDN"]

# Build the SOAP request

[xml]$requestCertDownload = '<soapenv:Envelope xmlns:_0="http://www.idnomic.com/ngca/connector/ws/1_2"
xmlns:_01="http://www.idnomic.com/ngca/connector/1_2"
xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<soapenv:Header/>
<soapenv:Body>
<_0:download>
<_01:DownloadRequest xsi:type="_01:X509DownloadRequestType">
<serialNumber>' + $CertSerial + '</serialNumber>
<issuerDn>' + $issuerDN + '</issuerDn>
<withCaChain>true</withCaChain>
</_01:DownloadRequest>
</_0:download>
</soapenv:Body>
</soapenv:Envelope>'

   

if ( $DEBUG_FILE ) { $requestCertDownload.InnerXml | Out-File $DEBUG_FILE -Append }

if ( $DEBUG_FILE ) { $CertSerial | Out-File $DEBUG_FILE -Append }

#Download the certificate
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [xml]$restAccessResp = Invoke-RestMethod -URI $base_url -Certificate $cert -Method Post -Body $requestCertDownload

    $dataread = $restAccessResp.SelectNodes('//certificate') | Select-Object -Expand '#text'

    $returnedCertData = New-Object System.Text.StringBuilder
    $returnedCertData.AppendLine("-----BEGIN CERTIFICATE-----")
    $returnedCertData.AppendLine($dataread)
    $returnedCertData.AppendLine("-----END CERTIFICATE-----")

    
    ##$certFilePath = $base_path + '\downloadedcert' + (Get-Date).ToString("yyyyMMdd-hhmmss") + '.crt'
     
    ##$returnedCertData.ToString() | Out-File $certFilePath
    
    if ( $DEBUG_FILE ) { $cert | Format-List | Out-File $DEBUG_FILE -Append }

    if ( $DEBUG_FILE ) { $dataread | Out-File $DEBUG_FILE -Append }

# Build the response hash table and return if a cert is found

    $decoder=[system.Text.Encoding]::UTF8
    [System.Collections.Hashtable]$resultTable = @{ Result="Success"; Status="Issued"; Pkcs7 =$decoder.GetBytes($dataread) } 

    return $resultTable
       
    }
    else
    {
        return @{ Result="No Certificate Found." }
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

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )

    if ( $DEBUG_FILE ) { $Specific.CertId | Format-List | Out-File $DEBUG_FILE -Append }
    if ( $DEBUG_FILE ) { $Specific.CertPem | Format-List | Out-File $DEBUG_FILE -Append }
    
    $revCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    
    $encoder = [System.Text.Encoding]::UTF8
    $revCert.Import($encoder.GetBytes($Specific.CertPem))
     

    if ($revCert -ne $null)
    {
        $CertSerial = $revCert.SerialNumber.toString()


        if ( $DEBUG_FILE ) { "Certificate" | Format-List | Out-File $DEBUG_FILE -Append }
        if ( $DEBUG_FILE ) { $revCert | Format-List | Out-File $DEBUG_FILE -Append }
        if ( $DEBUG_FILE ) { $CertSerial | Format-List | Out-File $DEBUG_FILE -Append }
       


    }

    else

    {
        $CertSerial = $Specific.CertId.toString()
        if ( $DEBUG_FILE ) { "Serial Number from ID" | Format-List | Out-File $DEBUG_FILE -Append }
        if ( $DEBUG_FILE ) { $CertSerial | Format-List | Out-File $DEBUG_FILE -Append }
    }


    $revokeDate = (Get-Date).ToString("yyyy-MM-ddThh:mm:ss.fffK")
    $revokeComment = $Specific.Comment.toString()
    $revokeReason = "unspecified"

    $base_url=$General.ServiceAddress
    $CAPartition=$General.CustomFields["CAPartition"]
    $CertificateTemplate=$General.ProfileString
    $issuerDN=$General.CustomFields["IssuerDN"]

    switch ($Specific.ReasonCode)
    {
        1 {$revokeReason = "keyCompromise"}
        2 {$revokeReason = "cACompromise"}
        3 {$revokeReason = "affiliationChanged"}
        4 {$revokeReason = "superseded"}
        5 {$revokeReason = "cessationOfOperation"}
    }

    

    [xml]$revokeCertXML='<soapenv:Envelope
xmlns:_0="http://www.idnomic.com/ngca/connector/ws/1_2"
xmlns:_01="http://www.idnomic.com/ngca/connector/1_2"
xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<soapenv:Header/>
<soapenv:Body>
<_0:revoke>
<_01:RevocationRequest xsi:type="_01:X509RevocationRequestType">
<revocationRequestEntries>
<revocationRequestEntry>
<serialNumber>'+$CertSerial+'</serialNumber>
<issuerDn>' + $issuerDN + '</issuerDn>
<reason>' + $revokeReason + '</reason>
<comment>' + $revokeComment + '</comment>
<invalidityDate>' + $revokeDate + '</invalidityDate>
</revocationRequestEntry>
</revocationRequestEntries>
</_01:RevocationRequest>
</_0:revoke>
</soapenv:Body>
</soapenv:Envelope>'


if ( $DEBUG_FILE ) { $revokeCertXML.InnerXml | Format-List | Out-File $DEBUG_FILE -Append }


try {


    [xml]$restAccessResp = Invoke-RestMethod -URI $base_url -Certificate $cert -Method Post -Body $revokeCertXML

    return @{ Result="Success" }
}

catch {
    
    throw($_)
    return @{ Result="Failure" }

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


function digSign {

Param(
    [Parameter(Mandatory=$true,HelpMessage="XML to sign")]
    [xml]$XMLtoSign,
    [Parameter(Mandatory=$true,HelpMessage="Signing certificate")]
    [System.Security.Cryptography.X509Certificates.X509Certificate2]$cert
    )

    if ( $DEBUG_FILE ) { $XMLtoSign.InnerXML | Format-List | Out-File $DEBUG_FILE -Append }

    [System.Security.Cryptography.Xml.SignedXml]$signedXMLRequest = New-Object System.Security.Cryptography.Xml.SignedXml -ArgumentList $XMLtoSign
    $signedXMLRequest.SigningKey = $cert.PrivateKey 
    $keyInfo = New-Object System.Security.Cryptography.Xml.KeyInfo
    $keyInfo.AddClause((New-Object System.Security.Cryptography.Xml.KeyInfoX509Data -ArgumentList $cert))
    $signedXMLRequest.KeyInfo = $keyInfo

    $Reference = New-Object System.Security.Cryptography.Xml.Reference
    $Reference.Uri = ""

    $env = New-Object System.Security.Cryptography.Xml.XmlDsigEnvelopedSignatureTransform

    $Reference.AddTransform($env)
    $signedXMLRequest.AddReference($Reference)
    $signedXMLRequest.ComputeSignature()

    [System.Xml.XmlElement]$xmlSignature = $signedXMLRequest.GetXml()

    $XMLtoSign.DocumentElement.AppendChild($XMLtoSign.ImportNode($xmlSignature, $true))

    if($XMLtoSign.FirstChild -is [System.Xml.XmlDeclaration])
    {
        $XMLtoSign.RemoveChild($XMLtoSign.FirstChild)
    }

    if ( $DEBUG_FILE ) { $XMLtoSign.InnerXml | Format-List | Out-File $DEBUG_FILE -Append }

    return ($XMLtoSign)



}

function loginToCA {

Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    if ( $General.PfxData )
	{
		$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
		$cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet )

        $base_url=$General.ServiceAddress
        $CAPartition=$General.CustomFields["CAPartition"]
        $CertificateTemplate=$General.ProfileString
        $issuerDN=$General.CustomFields["issuerDN"]

	
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


    [xml]$requestCertProfiles = $global:requestPreamble+'
<ws:listCertificateProfiles>
  <partition>'+$CApartition+'</partition>
</ws:listCertificateProfiles>

</SOAP-ENV:Body>
</SOAP-ENV:Envelope>'

    $requestBody = @'
    <ws:listCertificateProfiles>
  <partition>'+$CApartition+'</partition>
</ws:listCertificateProfiles>
'@
    
    
    [xml]$restAccessResp = Invoke-RestMethod -URI $base_url -Certificate $cert -Method Post -Body $requestCertProfiles
     
    
    
    if ( $DEBUG_FILE ) { $restAccessResp.InnerXml |Format-Table | Out-File $DEBUG_FILE -Append }


     $dataread = Select-Xml -Xml $restAccessResp -XPath "//certificateProfile" | Select-Object -ExpandProperty Node
    
    if ( $DEBUG_FILE ) { $cert | Format-List | Out-File $DEBUG_FILE -Append }

    #if ( $DEBUG_FILE ) { $WebAccessReq.InnerXml | Out-File $DEBUG_FILE -Append }

    
    if ( $DEBUG_FILE ) { $dataread | Out-File $DEBUG_FILE -Append }


    return @{ Result="Success" }
    }

    else
    {
        return @{ Result="Fail - no login certificate provided." }
    }


    

}
