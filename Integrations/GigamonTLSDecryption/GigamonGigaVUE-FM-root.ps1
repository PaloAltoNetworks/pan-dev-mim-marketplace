<#
//-----------------------------------------------------------------------
// GigamonGigaVUE-FM.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by Gigamon, in addition to Venafi.
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
//
// Please contact Gigamon technical support for help.
//-----------------------------------------------------------------------

<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Policyable
Bit 3 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text1|Cluster ID|101
Text2|Not Used|000
Text3|Not Used|000
Text4|Not Used|000
Text5|Not Used|000
Option1|Not Used|00
Option2|Not Used|000
Passwd|Venafi OAuth Token|110
-----END FIELD DEFINITIONS-----
#>

# uncomment the following to allow TPP to interface with self-signed/untrusted device certificate
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

$ErrorActionPreference = "Stop"

$global:ALIAS_NOT_USED = 0
$global:ALIAS_HAS_KEY = 1
$global:ALIAS_HAS_CERT = 2
$global:ALIAS_SAME_CERT = 4

$websdk_url = "https://localhost"

<##################################################################################################
.NAME
    Install-Certificates
.DESCRIPTION
    Installs the multiple certificates and their private keys on the target device or application.
    Implementing logic for this function is REQUIRED.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
        AppObjectDN : a string containing the TPP distiguished name of the calling application object
        AssetName : a string containing a Venafi standard auto-generated name that can be used for provisioning (<Common Name>-<ValidTo as YYMMDD>-<Last 4 of SerialNum>)
        VarText1 : a string containing the clustername or IP address part of device inventory
        VarText2 : a string value for the text custom field defined by the header at the top of this script
        VarText3 : a string value for the text custom field defined by the header at the top of this script
        VarText4 : a string value for the text custom field defined by the header at the top of this script
        VarText5 : a string value for the text custom field defined by the header at the top of this script
        VarBool1 : a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarBool2 : a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarPass : a string value for the password custom field defined by the header at the top of this script
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        Certificates : an array of hashtables, one for each certificate to be provisioned to the device
            Name : the certificate Common Name (if exists) or a DNS SAN (if exists) or an OU (if exists), otherwise the serial number
            Certificate : the Base64-encoded X509 certificate PEM
            PrivateKey : the Base64-encoded, non-encrypted private key PEM
            Serial : the serial number of the certificate
            Thumbprint : the SHA1 thumbprint of the certificate
            ValidTo : the expiration date of the certificate as 'YYYYMMDD' string
.NOTES
    Returns...
        Result : 'Success' indicates the non-error completion state
        RejectedCertificates : an array of SHA1 thumbprints for certificates that could not be imported for expected reasons
        FailedCertificates : an array of SHA1 thumbprints for certificates that could not be imported for unexpected reasons
##################################################################################################>
function Install-Certificates
{
  Param(
    [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    [System.Collections.Hashtable]$General,
    [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
    [System.Collections.Hashtable]$Specific
  )

  $failures = @()
  $rejections = @()

  try
  {
    $ctx = @{
      baseurl = "https://{0}:443" -f $General.HostAddress;
      headers = (Get-AuthHeader -Username $General.UserName -Password $General.UserPass);
      cluster = $General.VarText1;
    }

	$venafiheaders = @{ "Authorization"="Bearer {0}" -f $General.VarPass; "Content-Type"="application/json" }
	
	#if ( $DEBUG_FILE ) { "Bearer = {0} " -f $General.VarPass | Out-File $DEBUG_FILE -Append }
	
	
    foreach ( $cert in $Specific.Certificates )
    {
      
      # expiration date check.
      $cdate = Get-Date -format "yyyyMMdd"
      if ($cdate -gt $cert.ValidTo) {
        $rejections += $cert.Thumbprint
        continue
      } # nothing more to do
       
	  
	  $uri = "{0}/vedsdk/certificates/?thumbprint={1}" -f $websdk_url, $cert.Thumbprint
	  
	  #if ( $DEBUG_FILE ) { "URI = {0}" -f $uri | Out-File $DEBUG_FILE -Append }
	  
	  $Certdetails = Invoke-RestMethod -Method Get -Uri $uri -Headers $venafiheaders -ContentType "application/json"
	  
	  $dnValue = $Certdetails.Certificates[0].DN

	  #if ( $DEBUG_FILE ) { "Cert Details DN = {0} " -f $dnValue | Out-File $DEBUG_FILE -Append }
	  
	  $dnValueFinal = $dnValue.Replace('\', '\\')
	  
	  #if ( $DEBUG_FILE ) { "Replaced DN = {0} " -f $dnValueFinal | Out-File $DEBUG_FILE -Append }
	  
	  $newuri = "{0}/vedsdk/certificates/Retrieve" -f $websdk_url
      $body = @{
	  	CertificateDN = $dnValueFinal ;
        Format = "Base64" ;
        IncludeChain = "true"
      } | ConvertTo-Json
	 # } | ConvertTo-Json -Depth 4

	  $CertChain = Invoke-RestMethod -Method Post -Uri $newuri -Headers $venafiheaders -Body $body -ContentType "application/json"
	  
	  $derivedcert = $CertChain.CertificateData

	  #if ( $DEBUG_FILE ) { "Private Key= {0} " -f $cert.PrivateKey | Out-File $DEBUG_FILE -Append }
	  
	  #if ( $DEBUG_FILE ) { "Derived Certificate = {0} " -f $derivedcert | Out-File $DEBUG_FILE -Append }
	  
	  $DecodedCert = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($derivedcert))
	  
	  #if ( $DEBUG_FILE ) { "Final Certificate = {0} " -f $DecodedText | Out-File $DEBUG_FILE -Append }
	  
	  $alias = Sanitize-Alias -Alias ($cert.Name + "-" + $cert.Thumbprint)
      # alias check.
      $result = -1
      $result = Check-Alias -Context $ctx -Alias $alias -CertPem $cert.Certificate
      if ( $result -eq $ALIAS_HAS_KEY ) {
        $rejections += $cert.Thumbprint
        continue
      } # nothing more to do

      $is_ecc = $cert.PrivateKey -match "EC PRIVATE KEY"
      # Debug
      #Write-Host "Installing", $alias
      
      if ( Install-PrivateKey -Context $ctx -Alias $alias -Pem $cert.PrivateKey -IsEcc $is_ecc )
      {
        #if ( -not (Install-Certificate -Context $ctx -Alias $alias -Pem $cert.Certificate -IsEcc $is_ecc) )
		if ( -not (Install-Certificate -Context $ctx -Alias $alias -Pem $DecodedCert -IsEcc $is_ecc) )
        {
          $failures += $cert.Thumbprint
        }
      }
      else
      {
        $failures += $cert.Thumbprint
      }
    }
  }
  catch
  {
    throw $_.Exception.Message
  }

  if ( $failures.Count -gt 0 )
  {
    return @{ Result="Errors"; FailedCertificates=$failures; RejectedCertificates=$rejections }
  }

  return @{ Result="Success"; RejectedCertificates=$rejections }
}

function Revoke-Certificates
{
  Param(
    [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
    [System.Collections.Hashtable]$General,
    [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
    [System.Collections.Hashtable]$Specific
  )

  $failures = @()
  $rejections = @()

  try
  {
    $ctx = @{
      baseurl = "https://{0}:443" -f $General.HostAddress;
      headers = (Get-AuthHeader -Username $General.UserName -Password $General.UserPass);
      cluster = $General.VarText1;
    }

    foreach ( $cert in $Specific.Certificates )
    {
      $alias = Sanitize-Alias -Alias ($cert.Name + "-" + $cert.Thumbprint)
      $result = Check-Alias -Context $ctx -Alias $alias -CertPem $cert.Certificate
      if($result)
      {
        # Debug
        # Write-Host "Revoking", $Alias
        Delete-Alias -Context $ctx -Alias $alias
      }
    }
  }
  catch
  {
    throw $_.Exception.Message
  }

  if ( $failures.Count -gt 0 )
  {
    return @{ Result="Errors"; FailedCertificates=$failures; RejectedCertificates=$rejections }
  }

  return @{ Result="Success"; RejectedCertificates=$rejections }
}


<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Get-AuthHeader
(
  [string] $Username,
  [string] $Password
)
{
  $base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${Password}"))
  return @{ Authorization = "Basic $base64"; "Content-Type" = "application/json" }
}


function Sanitize-Alias
(
  [string] $Alias
)
{
  # replace any unsupported characters with underscore, TODO check on length limit
  return $Alias -replace "[/\\, :]","_"
}


function Check-Alias
(
  [hashtable] $Context,
  [string] $Alias,
  [string] $CertPem
)
{
  $result = $ALIAS_NOT_USED

  $url = "{0}/api/v1.3/apps/keystore/keys/{1}?clusterId={2}" -f $Context.baseurl,$Alias,$Context.cluster

  try
  {
    $null = Invoke-RestMethod -Method GET -Uri $url -Headers $Context.headers
    $result = $ALIAS_HAS_KEY
  }
  catch
  {
    # expected if alias does not exist
    return $result
  }

  $url = "{0}/api/v1.3/apps/keystore/keys/{1}/certificate?clusterId={2}" -f $Context.baseurl,$Alias,$Context.cluster

  try
  {
    $metadata = (Invoke-RestMethod -Method GET -Uri $url -Headers $Context.headers).certificate
    $result = $result -band $ALIAS_HAS_CERT

    # check whether certificate is the same as we're installing
    $head = "-----BEGIN CERTIFICATE-----"
    $foot = "-----END CERTIFICATE-----"
    $base64 = $CertPem.Replace($head,"").Replace($foot,"").Replace("`r","").Replace("`n","")
    $bytes = [Convert]::FromBase64String($base64)
    $cert_new = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$bytes)
    
    if ( $metadata -match "Not Before: ([^\n]+) GMT" )
    {
      $ValidTo = [datetime]::ParseExact($Matches[1],"MMM dd HH:mm:ss yyyy",$null,[Globalization.DateTimeStyles]::AssumeUniversal)

      if ($validTo.AddDays(90) -lt (Get-Date))
      {
        # delete the alias if the certificate has been expired for at least 90 days
        Delete-Alias -Context $ctx -Alias $Alias
        return $ALIAS_NOT_USED
      }

      if ($ValidTo -eq $cert.NotAfter) { $matched++ }
    }

    if ( $metadata -match "Subject:.*CN=([^,\n]+)" )
    {
      $CommonName = $Matches[1]
      $CN = $cert.GetNameInfo([System.Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false)
      if ($CommonName -eq $CN) { $matched++ }
    }

    if ( $metadata -match "Serial Number:[\s]*([^\s]+)" )
    {
      $Serial = $Matches[1].Replace(":","")
      if ($Serial -eq $cert.SerialNumber) { $matched++ }
    }

    if ( $metadata -match "X509v3 Subject Key Identifier:[\s]*([^\n]+)" )
    {
      $SubjectKeyId = $Matches[1].Replace(":","")
      if ($SubjectKeyId -eq $cert.Extensions.SubjectKeyIdentifier) { $matched++ }
    }

    # if at least 2 pieces of data matched, we'll conclude it is the same certificate
    if ( $matched -gt 1 ) { $result = $result -band $global:ALIAS_SAME_CERT }
  }
  catch
  {
    #expected if alias does not exist
  }

  return $result
}


function Delete-Alias
(
  [hashtable] $Context,
  [string] $Alias
)
{
  $url = "{0}/api/v1.3/apps/keystore/keys/{1}?clusterId={2}" -f $Context.baseUrl,$Alias,$Context.cluster
  $null = Invoke-RestMethod -Method DELETE -Uri $url -Headers $Context.headers
}


function Install-PrivateKey
(
  [hashtable] $Context,
  [string] $Alias,
  [string] $Pem,
  [bool] $IsEcc=$false
)
{
  $url = "{0}/api/v1.3/apps/keystore/keys?clusterId={1}" -f $Context.baseurl,$Context.cluster
  $body = @{
    alias = $Alias;
    comment = "Installed by Venafi Trust Protection Platform";
    type = if ( $IsEcc ) { "ecdsa-private" } else { "private" };
    file = $Pem
  } | ConvertTo-Json
  # To Debug
  # Write-Host "Private Key", $Alias
  # Write-Host $url
  # Write-Host $body

  try
  {
   Invoke-RestMethod -Method POST -Uri $url -Headers $Context.headers -Body $body
   return $true
  }
  catch
  {
   # expected if private key is already installed under a different alias
   return $false
  }
}


function Install-Certificate
(
  [hashtable] $Context,
  [string] $Alias,
  [string] $Pem,
  [bool] $IsEcc=$false
)
{
  $url = "{0}/api/v1.3/apps/keystore/keys?clusterId={1}" -f $Context.baseurl,$Context.cluster

  $body = @{
    alias = $Alias;
    comment = "Installed by Venafi Trust Protection Platform";
    type = if ( $IsEcc ) { "ecdsa-certificate" } else { "certificate" };
    file = $Pem
  } | ConvertTo-Json
  # Debug
  # Write-Host "Certificate", $Alias
  # Write-Host $url
  # Write-Host $body

  try
  {
    $null = Invoke-RestMethod -Method POST -Uri $url -Headers $Context.headers -Body $body
    return $true
  }
  catch
  {
    # expected if certificate is already installed under a different alias
    return $false
  }
}

