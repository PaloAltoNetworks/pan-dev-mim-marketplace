<#
//---------------------------------------------------------------------------
// IdenTrust.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by IdenTrust, in addition to Venafi.
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
#>############################################################################################################
# SETTINGS
#
# The following settings will be setup in the Venafi system through custom fields.
# In the event the settings are not specified in the Venafi system, a fallback method is to configure 
# those settings in this file through the following properties
############################################################################################################
#$AccountNumber=30025236
#$AccountType=201
#$CertificateType=230018

#Primary Contact Data
#$ContactFirstName='Venafi_First_Name'
#$ContactLastName='Venafi_Last_Name'
#$ContactEmailAddress='Delete.Me@IdenTrust.com'
#$ContactPhoneNumber='0000000000'


# XSMS URL
$XSMS_URL="https://secure.identrust.com/app/TSAutoLRA"

# Set to TRUE to enable debugging
$DEBUG_MODE=$FALSE
############################################################################################################
# GLOBAL SETUP
##################################################################################################>

# XML Namespace Constants
$XSMS_NAMESPACE = "http://www.identrust.com/xsms/v1#"
$DS_NAMESPACE = "http://www.w3.org/2000/09/xmldsig#"
$SOAP_NAMESPACE = "http://www.w3.org/2003/05/soap-envelope"

if($DEBUG_MODE -eq $TRUE) {
  Try # to write to Venafi Log Directory.  If this fails, use current path
  {
    $basePath = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs"
    $tempFile = $basePath + "\IdenTrustCaDebug_Verify_Access"
    [IO.File]::OpenWrite($tempFile).Close()
    [IO.File]::Delete($tempFile)
  }
  Catch
  {
    $basePath = (Get-Location).Path
  }

  $basePath = (Get-Location).Path
  $global:file_prefix = $basePath + "\IdenTrustCaDebug_"
}

Add-Type -AssemblyName System.Security
<##################################################################################################
 // Extend the SignedXml Class so that we can reference by soapsec:id
 // See this stack overflow post for information on why this Invoke-Expression is required
 // https://stackoverflow.com/questions/42837447/powershell-unable-to-find-type-when-using-ps-5-classes
##################################################################################################>
Invoke-Expression @'
class SignedXmlWithId : System.Security.Cryptography.Xml.SignedXml {
  SignedXmlWithId([xml] $xml) : base($xml) {}

  [System.Xml.XmlElement]GetIdElement([System.Xml.XmlDocument] $doc, [String] $id) {
    $idElement = ([System.Security.Cryptography.Xml.SignedXml]$this).GetIdElement($doc, $id)
    if($idElement -eq $null) {
      $nsManager = New-object System.xml.XmlNamespaceManager($doc.NameTable)
      $nsManager.AddNamespace("soapsec", "http://schemas.xmlsoap.org/soap/security/2000-12");
      $idElement = $doc.SelectSingleNode('//*[@soapsec:id="' + $id + '"]', $nsManager) 
    }

    return $idElement
  }
  
}
'@

##################################################################################################>
# XSMS message templates
##################################################################################################>

# Common message prefix
$messagePrefix = @'
<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:soapsec="http://schemas.xmlsoap.org/soap/security/2000-12" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<soapenv:Header>
<soapsec:Signature soapenv:mustUnderstand="1" soapenv:role="http://schemas.xmlsoap.org/soap/actor/next">
</soapsec:Signature>
</soapenv:Header>
<soapenv:Body soapsec:id="Body">
'@

# Common message suffix
$messageSuffix = @'
</soapenv:Body></soapenv:Envelope>
'@

# Test Message Body
$testTemplate = @'
<xsms:TestXSMSRequest xmlns:xsms="http://www.identrust.com/xsms/v1#" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:ec="http://www.w3.org/2001/04/xmlenc#" xmlns:xkms="http://www.w3.org/2002/03/xkms#" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Id="{id}" Service="https://secure-dev.identrust.com/dev4/app/TSAutoLRA" Nonce="{nonce}"><xsms:TestXSMS><xsms:Mode>HBRI</xsms:Mode></xsms:TestXSMS></xsms:TestXSMSRequest>
'@

# Register Message Body
$registerTemplate = @'
<xsms:RegisterRequest xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:ec="http://www.w3.org/2001/04/xmlenc#" xmlns:xkms="http://www.w3.org/2002/03/xkms#" xmlns:xsms="http://www.identrust.com/xsms/v1#" Id="{id}" Nonce="{nonce}" Service="https://secure.identrust.com/app/TSAutoLRA"><xsms:CertificateBinding BindingID="binding_1" RequestType="obtainCertificateAndPublish" RespondWithX509Chain="true"><xsms:CertificateInformation><xsms:CertificateIdentifier Type="AccountType">{acct_type}</xsms:CertificateIdentifier><xsms:CertificateIdentifier Type="CertificateType">{cert_type}</xsms:CertificateIdentifier><xsms:DomainName>{common_name}</xsms:DomainName><xsms:MultiDomainNames/><xsms:CertificateSigningRequest Format="PKCS10">{pkcs10}</xsms:CertificateSigningRequest><xsms:PivInterim>false</xsms:PivInterim></xsms:CertificateInformation></xsms:CertificateBinding><xsms:Subscriber><xsms:Name><xsms:NameFirst>{contact_first_name}</xsms:NameFirst><xsms:NameLast>{contact_last_name}</xsms:NameLast></xsms:Name><xsms:EmailAddress>{contact_email}</xsms:EmailAddress><xsms:Company Identifier="{parent_account}"><xsms:Phone Type="WORK">{contact_phone}</xsms:Phone></xsms:Company></xsms:Subscriber></xsms:RegisterRequest>
'@

# Revoke Message Body
$revokeTemplate = @'
<xsms:RevokeRequest xmlns:xsms="http://www.identrust.com/xsms/v1#" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:ec="http://www.w3.org/2001/04/xmlenc#" xmlns:xkms="http://www.w3.org/2002/03/xkms#" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Id="{id}" Service="https://secure.identrust.com/app/TSAutoLRA" Nonce="{nonce}"><xsms:RevokeCertificateBinding BindingID="binding_1" RequestType="revokeCertificate"><xsms:RevokeKeyBinding><ds:KeyInfo><ds:X509Data><ds:X509Certificate>{cert_pem}</ds:X509Certificate></ds:X509Data></ds:KeyInfo></xsms:RevokeKeyBinding><xsms:RevocationReasonCode>{reason_code}</xsms:RevocationReasonCode></xsms:RevokeCertificateBinding><xsms:Subscriber/></xsms:RevokeRequest>
'@

##################################################################################################>
# Venafi API Functions
##################################################################################################>

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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n" + 
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) + 
                 "`n" + (Get-Debug-Params)) $myCommand $FALSE
    }
 
    # Replace variables
    $xsmsRequest = "$messagePrefix $testTemplate $messageSuffix"
    $idGuid = New-Guid
    $nonceGuid = New-Guid
    $xsmsRequest = $xsmsRequest.replace("{id}", $idGuid)
    $xsmsRequest = $xsmsRequest.replace("{nonce}", $nonceGuid)

    [xml]$XMLsource = $xsmsRequest

    # Output xsms request
    if($DEBUG_MODE -eq $TRUE) {
      Debug-Log ("`n`n##### REQUEST TEMPLATE #####`n" + $xsmsRequest) $myCommand $TRUE
    }

	  $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    if ( $General.PfxData -and $General.PfxPass ) {
		  $cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable )
	  } else {
      throw 'Error: PfxData and PfxPass must be specified'
    }

    # Sign the xsms request with the selected p12
    Sign-XML -xml $XMLsource -SigningCert $cert
    $XMLsource.PreserveWhitespace = $true;
    $signedXml = $Xmlsource.OuterXml

    # Output signed xml
    if($DEBUG_MODE -eq $TRUE) {
      Debug-Log ("`n`n##### REQUEST TEMPLATE SIGNED #####`n" + $signedXml) $myCommand $TRUE
    }

    # Make XSMS call
    $xsmsResponse = Send-XSMS -signedXml $signedXml

    # Output the XSMS Response
    if($DEBUG_MODE -eq $TRUE) {
        if($xsmsResponse) {
            $responseLog = @"
##### XSMS RESPONSE #####
HTTP Status: $($xsmsResponse.StatusCode)
HTTP Status Description: $($xsmsResponse.StatusDescription)

##### XSMS RESPONSE HEADERS #####
$xsmsResponse.Headers
##### XSMS RESPONSE CONTENT #####
$($xsmsResponse.Content)
"@

            Debug-Log $responseLog $myCommand $TRUE
        } else {
            Debug-Log "XSMS Response Null." $myCommand $TRUE
        }
    }

    # Parse the Test Result
    Parse-Test-Result $xsmsResponse.Content

    return @{ Result="Success" }
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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n" + 
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value })) $myCommand $FALSE
    }

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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n" + 
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) + 
                 "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" + 
                 ($Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value })) $myCommand $FALSE
    }

    # Check for p12 parameters
    if(!$General.PfxData) {
      throw 'PfxData must be specified'
    }
    if(!$General.PfxPass) {
      throw 'PfxPass must be specified'
    }

    # Check Required Custom Fields
    $customFields = $General.Item("CustomFields")
    if($customFields) {
      $tempAccountType = $customFields.Item("IdenTrust: Account Type")
      if($tempAccountType) {
        $AccountType = $tempAccountType
      }
      $tempCertificateType = $customFields.Item("IdenTrust: Certificate Type")
      if($tempCertificateType) {
        $CertificateType = $tempCertificateType
      }
      $tempAccountNumber = $customFields.Item("IdenTrust: Account Number")
      if($tempAccountNumber) {
        $AccountNumber = $tempAccountNumber
      }
      $tempContactFirstName = $customFields.Item("IdenTrust: Contact First Name")
      if($tempContactFirstName) {
        $ContactFirstName = $tempContactFirstName
      }
      $tempContactLastName = $customFields.Item("IdenTrust: Contact Last Name")
      if($tempContactLastName) {
        $ContactLastName = $tempContactLastName
      }
      $tempContactEmailAddress = $customFields.Item("IdenTrust: Contact Email Address")
      if($tempContactEmailAddress) {
        $ContactEmailAddress = $tempContactEmailAddress
      }
      $tempContactPhoneNumber = $customFields.Item("IdenTrust: Contact Phone Number")
      if($tempContactPhoneNumber) {
        $ContactPhoneNumber = $tempContactPhoneNumber
      }
    }

    if(!$AccountType) { 
      throw 'Custom Field must be populated: IdenTrust: Account Type'
    }
    if(!$CertificateType) { 
      throw 'Custom Field must be populated: IdenTrust: Certificate Type'
    }
    if(!$AccountNumber) { 
      throw 'Custom Field must be populated: IdenTrust: Account Number'
    }
    if(!$ContactFirstName) { 
      throw 'Custom Field must be populated: IdenTrust: Contact First Name'
    }
    if(!$ContactLastName) { 
      throw 'Custom Field must be populated: IdenTrust: Contact Last Name'
    }
    if(!$ContactEmailAddress) { 
      throw 'Custom Field must be populated: IdenTrust: Contact Email Address'
    }
    if(!$ContactPhoneNumber) { 
      throw 'Custom Field must be populated: IdenTrust: Contact Phone Number'
    }

    return @{ Result="Success" }
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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n" + 
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) + 
                 "`n`n##### FUNCTION SPECIFIC PARAMETERS #####`n" +
                 ($Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) +
                 "`n" +
                 (Get-Debug-Params)) $myCommand $FALSE
    }

    # Set Required Custom Fields
    $customFields = $General.Item("CustomFields")
    if($customFields) {
      $tempAccountType = $customFields.Item("IdenTrust: Account Type")
      if($tempAccountType) {
        $AccountType = $tempAccountType
      }
      $tempCertificateType = $customFields.Item("IdenTrust: Certificate Type")
      if($tempCertificateType) {
        $CertificateType = $tempCertificateType
      }
      $tempAccountNumber = $customFields.Item("IdenTrust: Account Number")
      if($tempAccountNumber) {
        $AccountNumber = $tempAccountNumber
      }
      $tempContactFirstName = $customFields.Item("IdenTrust: Contact First Name")
      if($tempContactFirstName) {
        $ContactFirstName = $tempContactFirstName
      }
      $tempContactLastName = $customFields.Item("IdenTrust: Contact Last Name")
      if($tempContactLastName) {
        $ContactLastName = $tempContactLastName
      }
      $tempContactEmailAddress = $customFields.Item("IdenTrust: Contact Email Address")
      if($tempContactEmailAddress) {
        $ContactEmailAddress = $tempContactEmailAddress
      }
      $tempContactPhoneNumber = $customFields.Item("IdenTrust: Contact Phone Number")
      if($tempContactPhoneNumber) {
        $ContactPhoneNumber = $tempContactPhoneNumber
      }
    }

    if(!$AccountType) {
      throw 'Custom Field must be populated: IdenTrust: Account Type'
    }
    if(!$CertificateType) {
      throw 'Custom Field must be populated: IdenTrust: Certificate Type'
    }
    if(!$AccountNumber) {
      throw 'Custom Field must be populated: IdenTrust: Account Number'
    }
    if(!$ContactFirstName) {
      throw 'Custom Field must be populated: IdenTrust: Contact First Name'
    }
    if(!$ContactLastName) {
      throw 'Custom Field must be populated: IdenTrust: Contact Last Name'
    }
    if(!$ContactEmailAddress) {
      throw 'Custom Field must be populated: IdenTrust: Contact Email Address'
    }
    if(!$ContactPhoneNumber) {
      throw 'Custom Field must be populated: IdenTrust: Contact Phone Number'
    }

    # Error handling in case any of the required variables are not present
    if(!$Specific -or !$Specific.Item("SubjectDN") -or !$Specific.Item("SubjectDN").Item("CN")) {
      throw 'Error: Common Name must be defined.'
    } elseif(!$Specific -or !$Specific.Item("Pkcs10")) {
      throw 'Error: Pkcs10 must be defined.'
    }

    #Read values from parameters
    $common_name = $Specific.Item("SubjectDN").Item("CN")
    $pkcs10 = $Specific.Item("Pkcs10")
    $pkcs10 = $pkcs10.replace("`r", "").replace("`n", "")
    $pkcs10 = $pkcs10.replace("-----BEGIN NEW CERTIFICATE REQUEST-----", "")
    $pkcs10 = $pkcs10.replace("-----END NEW CERTIFICATE REQUEST-----", "")
    $sanDomainArray = $()
    if($Specific.Item("SubjAltNames") -and $Specific.Item("SubjAltNames").Item("DNS")) {
      $sanDomainArray = $Specific.Item("SubjAltNames").Item("DNS")
      if(!$sanDomainArray) {
        $sanDomainArray = $()
      }
    }

    # Replace variables
    $xsmsRequest = "$messagePrefix $registerTemplate $messageSuffix"
    $idGuid = New-Guid
    $nonceGuid = New-Guid
    $xsmsRequest = $xsmsRequest.replace("{id}", $idGuid)
    $xsmsRequest = $xsmsRequest.replace("{nonce}", $nonceGuid)
    $xsmsRequest = $xsmsRequest.replace("{acct_type}", $AccountType)
    $xsmsRequest = $xsmsRequest.replace("{cert_type}", $CertificateType)
    $xsmsRequest = $xsmsRequest.replace("{parent_account}", $AccountNumber)
    $xsmsRequest = $xsmsRequest.replace("{common_name}", $common_name)
    $xsmsRequest = $xsmsRequest.replace("{pkcs10}", $pkcs10)
    $xsmsRequest = $xsmsRequest.replace("{contact_first_name}", $ContactFirstName)
    $xsmsRequest = $xsmsRequest.replace("{contact_last_name}", $ContactLastName)
    $xsmsRequest = $xsmsRequest.replace("{contact_email}", $ContactEmailAddress)
    $xsmsRequest = $xsmsRequest.replace("{contact_phone}", $ContactPhoneNumber)

    [xml]$XMLsource = $xsmsRequest

    #Add Multidomain
    if($sanDomainArray) {
      $MultiDomainNodeList = $XMLsource.GetElementsByTagName("MultiDomainNames", $XSMS_NAMESPACE)
      $MultiDomainNode = $MultiDomainNodeList.Item(0);

      # Loop adding MD
      foreach ($san in $sanDomainArray) {
        # Loop adding MD
        $loopSAN = $XMLsource.CreateElement("xsms", "Domain", $XSMS_NAMESPACE)
        $loopSAN.innerText=$san
        $MultiDomainNode.AppendChild($loopSAN)
      }
    }

    # Output xsms request
    if($DEBUG_MODE -eq $TRUE) {
      Debug-Log ("`n`n##### REQUEST TEMPLATE #####`n" + $xsmsRequest) $myCommand $TRUE
    }

	  $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    if ( $General.PfxData -and $General.PfxPass ) {
		  $cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable )
	  } else {
      throw 'Error: PfxData and PfxPass must be specified'
    }

    # Sign the xsms request with the selected p12
    Sign-XML -xml $XMLsource -SigningCert $cert
    $XMLsource.PreserveWhitespace = $true;

    $signedXml = $Xmlsource.OuterXml

    # Output signed xml
    if($DEBUG_MODE -eq $true) {
      Debug-Log ("`n`n##### XSMS REQUEST #####`n" + $signedXml) $myCommand $TRUE
    }

    # Make XSMS call
    $xsmsResponse = Send-XSMS -signedXml $signedXml

    # Output the XSMS Response
    if($DEBUG_MODE -eq $TRUE) {
        if($xsmsResponse) {
            $responseLog = @"
##### XSMS RESPONSE #####
HTTP Status: $($xsmsResponse.StatusCode)
HTTP Status Description: $($xsmsResponse.StatusDescription)

##### XSMS RESPONSE HEADERS #####
$xsmsResponse.Headers
##### XSMS RESPONSE CONTENT #####
$($xsmsResponse.Content)
"@
            Debug-Log $responseLog $myCommand $TRUE
        } else {
            Debug-Log "XSMS Response Null." $myCommand $TRUE
        }
    }

    # Parse the Register Result
    $parsedResultValues = Parse-Register-Result $xsmsResponse.Content
    $identifier = $parsedResultValues[0]
    [byte[]]$issuedCertChain = $parsedResultValues[1]

    if($DEBUG_MODE -eq $true) {
        Debug-Log ("`n`n##### ISSUED PKCS7 CHAIN #####`n" + (To-Base-64 $issuedCertChain)) $myCommand $TRUE
    }

    return @{ Result="Success";TransId=$identifier;Pkcs7=$issuedCertChain }
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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n" + 
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) + 
                 "`n`n##### FUNCTION SPECIFIC PARAMETERS #####`n" +
                 ($Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value })) $myCommand $FALSE
    }

    return Submit-CsrAsNew $General $Specific
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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n"  +
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) + 
                 "`n`n##### FUNCTION SPECIFIC PARAMETERS #####`n" +
                 ($Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value })) $myCommand $FALSE
    }

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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n" +
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) +
                 "`n`n##### FUNCTION SPECIFIC PARAMETERS #####`n" +
                 ($Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value })) $myCommand $FALSE
    }
  
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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n" +
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) +
                 "`n`n##### FUNCTION SPECIFIC PARAMETERS #####`n" +
                 ($Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value })) $myCommand $FALSE
    }

    return @{ Result="NotUsed" }
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

    if($DEBUG_MODE -eq $TRUE) {
      $myCommand = $MyInvocation.MyCommand

      Debug-Log ("##### GENERAL PARAMETERS #####`n" +
                 ($General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) + 
                 "`n`n##### FUNCTION SPECIFIC PARAMETERS #####`n" +
                 ($Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value }) +
                 "`n" + 
                 (Get-Debug-Params)) $myCommand $FALSE
    }

    # Error handling in case any of the required variables are not present
    if(!$Specific -or !$Specific.Item("CertPem")) {
      throw 'Error: CertPem must be defined.'
    } elseif(!$Specific -or !$Specific.Item("ReasonCode")) {
      throw 'Error: ReasonCode must be defined.'
    }

    #Read values from parameters
    $certPem = $Specific.Item("CertPem")
    $certPem = $certPem.replace("`r", "").replace("`n", "")
    $reasonCode = $Specific.Item("ReasonCode")

    # Replace variables
    $xsmsRequest = "$messagePrefix $revokeTemplate $messageSuffix"
    $idGuid = New-Guid
    $nonceGuid = New-Guid
    $xsmsRequest = $xsmsRequest.replace("{id}", $idGuid)
    $xsmsRequest = $xsmsRequest.replace("{nonce}", $nonceGuid)
    $xsmsRequest = $xsmsRequest.replace("{cert_pem}", $certPem)
    $xsmsRequest = $xsmsRequest.replace("{reason_code}", $reasonCode)

    [xml]$XMLsource = $xsmsRequest

    # Output xsms request
    if($DEBUG_MODE -eq $TRUE) {
      Debug-Log ("`n`n##### REQUEST TEMPLATE #####`n" + $xsmsRequest) $myCommand $TRUE
    }

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    if ( $General.PfxData -and $General.PfxPass ) {
      $cert.Import( $General.PfxData, $General.PfxPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable )
    } else {
      throw 'Error: PfxData and PfxPass must be specified'
    }

    # Sign the xsms request with the selected p12
    Sign-XML -xml $XMLsource -SigningCert $cert
    $XMLsource.PreserveWhitespace = $true;
    $signedXml = $Xmlsource.OuterXml

    # Output signed xml
    if($DEBUG_MODE -eq $TRUE) {
      Debug-Log ("`n`n##### REQUEST TEMPLATE SIGNED #####`n" + $signedXml) $myCommand $TRUE
    }

    # Make XSMS call
    $xsmsResponse = Send-XSMS -signedXml $signedXml


    # Output the XSMS Response
    if($DEBUG_MODE -eq $TRUE) {
        if($xsmsResponse) {
            $responseLog = @"
##### XSMS RESPONSE #####
HTTP Status: $($xsmsResponse.StatusCode)
HTTP Status Description: $($xsmsResponse.StatusDescription)

##### XSMS RESPONSE HEADERS #####
$xsmsResponse.Headers
##### XSMS RESPONSE CONTENT #####
$($xsmsResponse.Content)
"@

            Debug-Log $responseLog $myCommand $TRUE
        } else {
            Debug-Log "XSMS Response Null." $myCommand $TRUE
        }
    }

    # Parse the Revoke Result
    Parse-Revoke-Result $xsmsResponse.Content

    return @{ Result="Success" }
}

##################################################################################################>
# Utility Functions
##################################################################################################>

function Debug-Popup {
  Param ( [string]$debug_output )
  $wshell = New-Object -ComObject Wscript.Shell
  $wshell.Popup("$debug_output",0,"Done",0x1) | Out-Null
}

function Debug-Hash-Popup {
  Param ( [hashtable]$hashTable )
  Debug-Popup($hashTable.Keys | % { "key = $_ , value = " + $hashTable.Item($_) })
}

function Debug-Log {
    Param(
      [string] $debugString,
      [string] $debugCommand,
      [bool] $append
    )

    $debugFile = $global:file_prefix + $debugCommand + ".txt"
  

    if($append) {
      $debugString | Out-File $debugFile -Append
    } else {
      $debugString | Out-File $debugFile
    }

    Debug-Windows-Event $debugString $debugCommand
}

function Debug-Windows-Event {
    Param (
      [string] $debugString,
      [string] $debugCommand
    )

    $eventSource = "IdenTrust CA Venafi Driver"

    try # to create the event source if it doesn't already exist
    {
        New-EventLog -LogName "Application" -Source $eventSource -ErrorAction Stop
    }
    catch [System.InvalidOperationException]
    {
        if ( -not $_.Exception.Message.Contains("source is already registered") )
        {
            throw $_.Exception
        }
    }

    $eventId = 1000
    if($debugCommand -eq "Approve-Request") {
      $eventId = 100
    } elseif($debugCommand -eq "Get-ChainCertificates") {
      $eventId = 200
    } elseif($debugCommand -eq "Prepare-ForRequest") {
      $eventId = 300
    } elseif($debugCommand -eq "Retrieve-Certificate") {
      $eventId = 400
    } elseif($debugCommand -eq "Revoke-Certificate") {
      $eventId = 500
    } elseif($debugCommand -eq "Submit-CsrAsNew") {
      $eventId = 600
    } elseif($debugCommand -eq "Submit-CsrAsRenewal") {
      $eventId = 700
    } elseif($debugCommand -eq "Submit-CsrAsReplacement") {
      $eventId = 800
    } elseif($debugCommand -eq "Test-Settings") {
      $eventId = 900
    }

    Write-EventLog -LogName "Application" -Source $eventSource -EntryType "Information" -EventId $eventId -Category 0 -Message ($debugCommand + "`n`n" + $debugString)
}



function To-Base-64 {
  Param ([byte[]] $bytes)

  $base64 = [System.Convert]::ToBase64String($bytes)
  return $base64
}

# Sign SOAP body with XML Dsig
function Sign-XML
{
 Param ( [xml]$xml, [system.Security.Cryptography.X509Certificates.X509Certificate2]$SigningCert )

 $exportedKey = $SigningCert.PrivateKey.ToXmlString($true)

 # 24 is PROV_RSA_AES, a provider capable of SHA256 
 $cspParams = New-Object System.Security.Cryptography.CspParameters(24)
 $privKey = New-Object System.Security.Cryptography.RSACryptoServiceProvider($cspParams)
 $privKey.PersistKeyInCsp=$false
 $privKey.FromXmlString($exportedKey)
  
 $signedXml = New-Object SignedXmlWithId -ArgumentList $xml
 $signedXml.SigningKey = $privKey
 $signedXml.SignedInfo.SignatureMethod = "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"

 $KeyInfo = New-Object System.Security.Cryptography.xml.KeyInfo 
 $KeyInfoX509Data = New-Object System.Security.Cryptography.xml.KeyInfoX509Data($SigningCert)
 $KeyInfo.AddClause($KeyInfoX509Data)
 $KeyInfoRSAKey = New-Object System.Security.Cryptography.xml.RSAKeyValue
 $KeyInfoRSAKey.Key = [System.Security.Cryptography.RSA] $SigningCert.PublicKey.Key
 $KeyInfo.AddClause($KeyInfoRSAKey)
 $signedXml.KeyInfo = $KeyInfo

 $Reference = New-Object System.Security.Cryptography.Xml.Reference
 $Reference.DigestMethod = "http://www.w3.org/2001/04/xmlenc#sha256"
 $Reference.Uri = "#Body"
  
 $signedXml.AddReference($Reference)
 $signedXml.ComputeSignature()
  
 [System.Xml.XmlElement]$xmlSignature = $signedXml.GetXml()

 $SoapHeaderList = $xml.GetElementsByTagName("Signature", "http://schemas.xmlsoap.org/soap/security/2000-12")
 $SoapHeaderList.Item(0).AppendChild($xml.ImportNode($xmlSignature, $true))
  
 if ($xml.FirstChild -is [system.xml.XmlDeclaration])
 {
  $xml.RemoveChild($xml.FirstChild);
 }
 $xml
}

# Sign A message to XSMS and emit the response
function Send-XSMS
{
  Param (
    [xml]$signedXml
  )

  try {
    $xsmsResponse = Invoke-WebRequest -UseBasicParsing $XSMS_URL -Method POST -Body $signedXml
  } catch {
    throw "IdenTrust CA: HTTP Error Connecting to XSMS: $($_.Exception.Response.StatusCode)"
  }

  $xsmsResponse
}

# Perform an XML Dsig verification of the XSMS response
function Verify-XSMS-Signature
{
  Param (
    [xml] $xsmsResponse
  )

  $signedXml = New-Object SignedXmlWithId -ArgumentList $xsmsResponse
  $signatureNodeList = $xsmsResponse.GetElementsByTagName("Signature", "http://www.w3.org/2000/09/xmldsig#")

  if($signatureNodeList.Count -ne 1) {
    throw "IdenTrust CA: Error: Expected exactly one Signature in the XSMS response.  Encountered: $signatureNodeList.Count"
  }

  $signatureNode = $signatureNodeList[0]
  $signedXml.LoadXml($signatureNode)
  $check = $signedXml.CheckSignature()
  return $check
}

# Parses a RegisterResult, returning the identifier and pkcs7
function Parse-Register-Result
{
  Param(
    [xml]$xml
  )

  $verified = Verify-XSMS-Signature($xml)
  if($verified) {
    throw 'IdenTrust CA: Unable to verify XSMS Signature'
  }

  # Locate RegisterResult
  $XmlNodeList = $xml.GetElementsByTagName("RegisterResult", $XSMS_NAMESPACE)
  $registerResult = $XmlNodeList[0]
  if($registerResult -eq $null) {

    # Check for a SOAP Fault
    Check-SOAP-Fault($xml)

    throw 'IdenTrust CA: Unable to parse RegisterResult from XSMS Response'
  }

  # Check the Result codes
  Check-Result-Codes($registerResult)

  # Parse CertificateBindings
  $certBindings = $xml.GetElementsByTagName("CertificateBindingResult", $XSMS_NAMESPACE)
  if($certBindings.Count -ne 1) {
    throw "IdenTrust CA: Error: Expected exactly 1 CertificateBindingResult.  Received $($certBindings.Count)"
  }
  $certBinding = $certBindings[0]
  if($certBinding -eq $null) {
    throw 'IdenTrust CA: Error: Null CertBinding'
  }

  $resultMinor = $certBinding.getAttribute("ResultMinor")
  if($resultMinor -ne "" -and $resultMinor -ne "Success") {

    # Look for an ErrorMessage
    $errorMessage='Not Specified'
    $errorMessages = $xml.GetElementsByTagName("ErrorMessage", $XSMS_NAMESPACE)
    if($errorMessages.Count -ge 1) {
      $errorMessage = $errorMessages[0].InnerXml
    }
    $certBinding = $certBindings[0]

    throw "IdenTrust CA: XSMS Response included error: $resultMinor - $errorMessage"
  }

  # Parse Certificate
  $certificates = $certBinding.GetElementsByTagName("X509Certificate", $DS_NAMESPACE)
  if($certificates.Count -ne 1) {
    throw "IdenTrust CA: Error: Expected exactly 1 X509Certificate.  Received $($certificates.Count)"
  }
  $cert = $certificates[0]
  if($cert -eq $null) {
    throw 'IdenTrust CA: Error: Null X509Certificate'
  }

  #Parse Pkcs7
  $pkcs7s = $certBinding.GetElementsByTagName("Pkcs7", $XSMS_NAMESPACE)
  if($pkcs7s.Count -ne 1) {
    throw "IdenTrust CA: Error: Expected exactly 1 Pkcs7.  Received $($pkcs7s.Count)"
  }
  $pkcs7 = $pkcs7s[0]
  if($cert -eq $null) {
    throw 'IdenTrust CA: Error: Null Pkcs7'
  }

  #Parse Account Identifier (Account Number)
  $subscribers = $xml.GetElementsByTagName("Subscriber", $XSMS_NAMESPACE)
  if($subscribers.Count -ne 1) {
    throw "IdenTrust CA: Error: Expected exactly 1 Subscriber in Result.  Received $($subscribers.Count)"
  }
  $subscriber = $subscribers[0]
  $identifier = $subscriber.GetAttribute("Identifier")
  if($identifier -eq $null) {
    throw "IdenTrust CA: Error: No Subscriber Identifier found in Result."
  }

  # Construct a pkcs7 containing EE first and chain next
  $certBytes = [System.Convert]::FromBase64String($cert.InnerXml)
  $importCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
  $importCert.Import($certBytes)
  $importPkcs7 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
  $importPkcs7.Add($importCert) | Out-Null

  $pkcs7Bytes = [System.Convert]::FromBase64String($pkcs7.InnerXml)
  $importPkcs7.Import($pkcs7Bytes)

  # Export bytes and return
  $fullPkcs7 = $importPkcs7.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
  return $identifier, $fullPkcs7
}

# Parses a RevokeResult
function Parse-Revoke-Result
{
  Param(
    [xml]$xml
  )

  $verified = Verify-XSMS-Signature($xml)
  if($verified) {
    throw 'IdenTrust CA: Unable to verify XSMS Signature'
  }

  # Locate RevokeResult
  $XmlNodeList = $xml.GetElementsByTagName("RevokeResult", $XSMS_NAMESPACE)
  $revokeResult = $XmlNodeList[0]
  if($revokeResult -eq $null) {

    # Check for a SOAP Fault
    Check-SOAP-Fault($xml)

    throw 'IdenTrust CA: Unable to parse RevokeResult from XSMS Response'
  }

  # Check the Result codes
  Check-Result-Codes($revokeResult)
}

# Parses a TestResult
function Parse-Test-Result
{
  Param(
    [xml]$xml
  )

  $verified = Verify-XSMS-Signature($xml)
  if($verified) {
    throw 'IdenTrust CA: Unable to verify XSMS Signature'
  }

  # Locate TestResult
  $XmlNodeList = $xml.GetElementsByTagName("TestXSMSResult", $XSMS_NAMESPACE)
  $revokeResult = $XmlNodeList[0]
  if($revokeResult -eq $null) {

    # Check for a SOAP Fault
    Check-SOAP-Fault($xml)

    throw 'IdenTrust CA: Unable to parse TestXSMSResult from XSMS Response'
  }

  # Check the Result codes
  Check-Result-Codes($revokeResult)
}

# Look for a SOAP fault and return a textual error message contained in the fault
function Check-SOAP-Fault {
  Param(
    [xml]$xml
  )

  $faults = $xml.GetElementsByTagName("Fault", $SOAP_NAMESPACE)
  if($faults.Count -ge 1) {
    $fault = $faults[0]
    $errorText = $fault.GetElementsByTagName("Text", $SOAP_NAMESPACE)
    if($errorText.Count -ge 1) {
      $errorMessage = $errorText[0].InnerXml
      throw "IdenTrust CA: SOAP Error: $errorMessage"
    }
  }
}

# Check Result Codes from an XSMS response
function Check-Result-Codes
{
  Param(
    [System.Xml.XmlElement]$result
  )

  $ResultMajor = $result.getAttribute("ResultMajor");
  $ResultMinor = $result.getAttribute("ResultMinor");

  if($ResultMajor -ne "Success") {
    throw 'IdenTrust CA: Unexpected XSMS Response ResultMajor: $ResultMajor'
  }

  if($ResultMinor -ne "" -and $ResultMinor -ne "Success") {
    throw 'IdenTrust CA: Unexpected XSMS Response ResultMinor: $ResultMinor'
  }
}

# Function to output selective global settings to file
function Get-Debug-Params {

    $result = @"
##### IDENTRUST SETTINGS #####
AccountNumber=$AccountNumber
AccountType=$AccountType
CertificateType=$CertificateType
XSMS_URL=$XSMS_URL
"@

    return $result
}


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
          if ( $($value.Item($key))) 
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
          } else {
              $result += $($key + ":").PadRight($maxlen + 4," ") + "null`r`n"
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
