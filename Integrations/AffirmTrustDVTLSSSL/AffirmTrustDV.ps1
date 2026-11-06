<#
//----------------------------------------------------------------------- 
// AffirmTrustDV.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by AffirmTrust, in addition to Venafi.
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

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3 -bor [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

$base_path = (Get-Location).Path
$global:temp_dir = $base_path + "\Temp"

If (!(Test-Path $global:temp_dir)) {
   New-Item $global:temp_dir -Type Directory
}
[int]$GET_ORDER_CHECK_INTERVAL_SECS = 3
[int]$GET_ORDER_CHECK_MAX_TIMES = 10
[string]$URI_INTERMEDIATE_CA = "http://www.affirmtrust.com/downloads/affirmtrust_certificate_authority_dv1.crt"
[string]$URI_ROOT_CA = "http://www.affirmtrust.com/downloads/affirmtrust_commercial.crt"
[string]$REST_API_Server = "partners.entrust.net/api"
[string]$DV_RECORDS_FILENAME_BASE = "AffirmTrust-DV-"
[hashtable]$AUTO_VERIFICATION_METHODS = @{
   "FILE" = "AUTO_VALIDATION_FILE"
   "DNS" = "AUTO_VALIDATION_DNS"
}
[boolean]$DEBUG = $false
[string]$DEBUG_FILE = $base_path + "\DEBUG.txt"

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
function Test-Settings {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [hashtable]$General
   )

   [string]$errorMessages = ""
   [string]$errorMessage = $null

   $errorMessage = Check-Field -fieldName 'CA Username' -fieldValue ($General.UserName) -additionalMessage 'Credentials for contacting the AffirmTrust CA must be provided'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-Field -fieldName 'CA Password' -fieldValue ($General.UserPass) -additionalMessage 'Credentials for contacting the AffirmTrust CA must be provided'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   
   if(![string]::IsNullOrEmpty($errorMessages)) {
      throw $errorMessages
   }
   
   try {
      # Call GetVersion on the API to test connectivity and credentials
      $endpoint = "/info/version"
      $getAPIResult = Get-API -apiUser $General.UserName -apiPassword $General.UserPass -apiPath $endpoint
      return @{ Result = "Success" }
   }
   catch {
      throw "Error calling the AffirmTrust CA: " + $_.Exception.Message
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
function Get-ChainCertificates {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [Collections.Hashtable]$General
   )


   try {
      # Grab the intermediate root "AffirmTrust Certificate Authority - DV1"
      $intermediateCert = (Invoke-WebRequest -Uri $URI_INTERMEDIATE_CA -Method "Get" -TimeoutSec 100).Content
      # Grab the root "AffirmTrust Commercial"
      $rootCert = (Invoke-WebRequest -Uri $URI_ROOT_CA -Method "Get" -TimeoutSec 100).Content

      $certChain = @($rootCert, $intermediateCert)

      $certs = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection

      foreach ($cert in $certChain) {
         $certObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$cert)
         $certs.Add($certObject)
      }

      [byte[]]$bytes = $certs.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
      #[IO.File]::WriteAllBytes($global:temp_dir + "\get-chain-certificates.p7b", $bytes)
      return @{ Result = "Success"; PKCS7 = $bytes }
   }
   catch {
      throw "Unable to retrieve and assemble AffirmTrust DV certificate chain: " + $_.Exception.Message
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
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   [string]$errorMessages = ""
   [string]$errorMessage = $null

   # Check the other 'built-in' fields. AffirmTrust doesn't use the Organizational Units field, so it is not checked
   $errorMessage = Check-Field -fieldName 'Common Name' -fieldValue ($Specific.SubjectDN.CN) -additionalMessage 'A Common Name (e.g. mycompany.com) must be provided'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-Field -fieldName 'Organization' -fieldValue ($Specific.SubjectDN.O) -additionalMessage 'An organization name (e.g., MyCompany, Inc.) must be provided. This is used as the organization name of the contact person specified by Contact Name/Email'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-Field -fieldName 'City/Locality' -fieldValue ($Specific.SubjectDN.L) -additionalMessage 'A city/locality (e.g., Toronto) must be provided. This is used as the city/locality of the contact person specified by Contact Name/Email'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-Field -fieldName 'State/Province' -fieldValue ($Specific.SubjectDN.ST) -additionalMessage 'A state/province (e.g., "MA" for Massachusetts) must be provided. This is used as the state/province of the contact person specified by Contact Name/Email'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-Field -fieldName 'Country' -fieldValue ($Specific.SubjectDN.C) -additionalMessage 'A country, as a two-letter country code such as "US", must be provided. This is used as the country of the contact person specified by Contact Name/Email'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }

   # Check the Custom Fields, that is, fields specific to this AffirmTrustCA driver
   $errorMessage = Check-Field -fieldName 'Contact Name' -fieldValue ($General.CustomFields['AffirmTrust:ContactName']) -additionalMessage 'Must provide the name (e.g., John Smith) of the person requesting the certificate. This may be the person who is reading this message, i.e., you'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-Field -fieldName 'Contact Email' -fieldValue ($General.CustomFields['AffirmTrust:ContactEmail']) -additionalMessage 'Must provide the email address (e.g., johnsmith@mycompany.com) of the person requesting the certificate. This may be the person who is reading this message, i.e., you'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-Field -fieldName 'Validity Years' -fieldValue ($General.CustomFields['AffirmTrust:ValidityYears']) -additionalMessage 'Must specify how many years for which the requested certificate will be valid'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-Field -fieldName 'Verification Method' -fieldValue ($General.CustomFields['AffirmTrust:VerificationMethod']) -additionalMessage 'Must specify the method for verifying domain control, either "FILE" or "DNS"'
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }
   $errorMessage = Check-VerificationFolder -verificationFolder ($General.CustomFields['AffirmTrust:VerificationFolder'])
   if($errorMessage -ne $null) { $errorMessages += $errorMessage }

   if(![string]::IsNullOrEmpty($errorMessages)) {
      throw $errorMessages
   }

   # If we got here, the value given for AffirmTrust:VerificationFolder is a valid path. Create the directory if it doesn't already exist.
   # If this is gonna fail, we want it to fail now, before calling the API to place an order
   Create-VerificationFolder -verificationFolder $General.CustomFields['AffirmTrust:VerificationFolder']

   # All required fields have been entered/provided
   return @{ Result = "Success" }


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
function Submit-CsrAsNew {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   $submitCsrResult = Submit-Csr -General $General -Specific $Specific
   return @{ Result = "Success"; TransId = $submitCsrResult.TransId }
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

   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   $orderIDCertID = Get-OrderIDCertIDFromTransID -transID $Specific.CertId
   $orderID = $orderIDCertID.OrderID
   $certID = $orderIDCertID.CertID # this is the existing/previous cert that Venafi admin wants to renew.
   $submitCsrResult = Submit-Csr -General $General -Specific $Specific -RenewalCertID $certID

   return @{ Result = "Success"; TransId = $submitCsrResult.TransId }
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

   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   Do-CsrAsReplacementAdjustments -General $General -Specific $Specific
   $orderIDCertID = Get-OrderIDCertIDFromTransID -transID $Specific.CertId
   $orderID = $orderIDCertID.OrderID
   $certID = $orderIDCertID.CertID

   $csr = $Specific.Pkcs10 -replace "[`r`n]", ''    # Remove the carriage returns
   $bodyJson = Assemble-BodyJsonReissue -General $General -Specific $Specific -Csr $csr -OrderID $orderID -CertID $certID

   try {
      $endpoint = "/order/request-reissue"
      Post-API -apiUser $General.UserName -apiPassword $General.UserPass -apiPath $endpoint -bodyJSON $bodyJson
      $orderObject = Get-VerificationReadyOrder -orderID $orderID
      $certID = $orderObject.latestCertificateTrackingID
      [hashtable]$domainVerificationRecords = Get-DomainValidationInfoFromOrder -orderObject $orderObject
      Do-DomainVerificationProcessing -domainVerificationRecords $domainVerificationRecords -orderID $orderObject.orderID -certID $certID -domainVerificationFolder $General.CustomFields["AffirmTrust:VerificationFolder"]
      $tid = $orderID + "|" + $certID
      return @{ Result = "Success"; TransId = $tid }
   }
   catch {
      throw "Unable to complete cert replacement request: " + $_.Exception.Message
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
function Approve-Request {
   Param (
      [Parameter(Mandatory, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   return @{ Result = "NotUsed" }
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
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   if ($Specific.CertId) {
      $orderIDCertID = Get-OrderIDCertIDFromTransID -transID $Specific.CertId
      $orderID = $orderIDCertID.OrderID
      $certID = $orderIDCertID.CertID

      # Get the order data (which contains the certs)
      $endpoint = "/order/" + $orderID

      try {
         $getAPIResult = Get-API -apiUser $General.UserName -apiPassword $General.UserPass -apiPath $endpoint
         $orderJson = $getAPIResult.Content
      }
      catch {
         throw "Error calling the AffirmTrust CA to retrieve certificate " + $certID + ": " + $_.Exception.Message
      }

      $orderObject = $orderJson | ConvertFrom-Json

      if ($orderObject.status -ne 'COMPLETE') {
         # validation and cert generation have not yet occurred. 
         # Return "Pending" so that Venafi will call this function again after some interval
         return @{ Result = "Success"; Status = "Pending" }
      }

      # The order is complete, now check the cert status. Find the matching certificate
      $certRecord = Get-CertRecordFromOrderObject -orderObject $orderObject -certID $certID

      if ($certRecord.status -ne 'Active') {
         # Cert is not ready, return 'Pending'. This can happen (order complete but cert pending) if this is a replacement/reissue
         return @{ Result = "Success"; Status = "Pending" }
      }

      # Cert is generated - go get it
      [string]$endCert = $certRecord.certificate
      [string[]]$certChain = New-Object -TypeName string[]
      [string[]]$cChain = $certRecord.certificateChain
      [array]::Reverse($cChain)
      $certChain = @($cChain, $endCert) # so, the intermediate and end cert strings should be in $certChain
      $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
      # Grab the root AffirmTrust Commercial and add it to the collection
      $rootCert = (Invoke-WebRequest -Uri $URI_ROOT_CA -Method "Get" -TimeoutSec 100).Content
      $rootCertObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$rootCert)
      $certCollection.Add($rootCertObject)

      # Convert the intermediate and end cert strings to cert objects and add to the collection
      foreach ($certString in $certChain) {
         $certString = $certString.Replace("-----BEGIN CERTIFICATE-----", "")
         $certString = $certString.Replace("-----END CERTIFICATE-----", "")
         $localbytes = [Convert]::FromBase64String($certString)
         $certObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$localbytes)
         $certCollection.Add($certObject)
      }

      # Create the P7 to return
      [byte[]]$bytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
      #[IO.File]::WriteAllBytes($global:temp_dir + "\response.p7b", $bytes)
      return @{ Result = "Success"; Status = "Issued"; Pkcs7 = $bytes; DiscardPrivateKeyAndCsr = $false; Pkcs7size = $bytes.Count }

   }
   else {
      throw "The required CertId parameter was not provided"
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
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   if ($Specific.CertId) {
      $orderIDCertID = Get-OrderIDCertIDFromTransID -transID $Specific.CertId
      $orderID = $orderIDCertID.OrderID
      $certID = $orderIDCertID.CertID


      # Get the order data (which contains the certs)
      $endpoint = "/order/" + $orderID

      try {
         $getAPIResult = Get-API -apiUser $General.UserName -apiPassword $General.UserPass -apiPath $endpoint
         $orderJson = $getAPIResult.Content
      }
      catch {
         throw "Error calling the AffirmTrust CA to retrieve requested certificate for revocation " + $certID + ": " + $_.Exception.Message
      }

      try {
         $orderObject = $orderJson | ConvertFrom-Json

         if ($orderObject.status -ne 'COMPLETE') {
            throw "OrderID " + $orderID + " not eligible for revocation"
         }

         # The order is complete, now find the cert
         $certRecord = $null

         # Find the matching certificate
         $orderObject.detail.certificates | ForEach-Object {
            if ($_.trackingID -eq $certID) {
               $certRecord = $_
               return
            }
         }

         if ($certRecord -eq $null) {
            throw "No cert " + $certID + " found for order " + $orderID
         }

         if ($certRecord.status -eq 'Deactivated') {
            # Cert is already revoked (somehow, through an out-of-band process).
            # Per Venafi, this function should return success in this case.
            return @{ Result = "Success" }
         }

         if ($certRecord.status -ne 'Active') {
            throw "CertID " + $orderID + " not eligible for revocation"
         }


         throw "AffirmTrust DV revocation not available via the Venafi Platform. To revoke certificate with domain '" + $certRecord.domain + "', a whois contact for this domain must contact AffirmTrust directly at support@affirmtrust.com."
      }
      catch {
         throw $_.Exception.Message
      }
   }
   else {
      throw "The required CertId parameter was not provided"
   }


}

function Import-Certificates {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   throw "Not Implemented"
   return @{ Result = "NotUsed" }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Get-APIURI([string]$apiPath) {
   return "https://" + $REST_API_Server + $apiPath
}

function Get-APIRequestHeader([string]$apiUser, [string]$apiPassword) {
   return @{ "Authorization" = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($apiUser + ":" + $apiPassword)) }
}

function Post-API([string]$apiUser, [string]$apiPassword, [string]$apiPath, [string]$bodyJSON) {
   $URI = Get-APIURI -apiPath $apiPath
   $Header = Get-APIRequestHeader -apiUser $apiUser -apiPassword $apiPassword
   $ApplicationType = "application/json"
   $webRequestResult = Invoke-RestMethod -Uri $URI -Method "Post" -TimeoutSec 100 -Headers $Header -ContentType $ApplicationType -Body $bodyJSON
   return $webRequestResult
}

function Get-API([string]$apiUser, [string]$apiPassword, [string]$apiPath) {
   $URI = Get-APIURI -apiPath $apiPath
   $Header = Get-APIRequestHeader -apiUser $apiUser -apiPassword $apiPassword
   $ApplicationType = "application/json"
   $webRequestResult = Invoke-WebRequest -Uri $URI -Method "Get" -TimeoutSec 100 -Headers $Header -ContentType $ApplicationType
   return $webRequestResult
}

function Assemble-BodyJson {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific,
      [Parameter(Mandatory = $true, HelpMessage = "CSR")]
      [string]$Csr,
      [Parameter(Mandatory = $false, HelpMessage = "RenewalCertID")]
      [string]$RenewalCertID
   )

   $sansJson = $Specific.SubjAltNames.DNS | ConvertTo-Json
   $sansJson = $sansJson -replace '[\[\]]', '' # get rid of the enclosing square brackets


   [string]$contractID = $General.CustomFields."AffirmTrust:ContractID"
   [boolean]$hasContractID = ![string]::IsNullOrEmpty($contractID)
   [string]$contractIDJson = ''
   if ($hasContractID) {
      $contractIDJson = '"contractID" : ' + $contractID + ','
   }

   [boolean]$isRenewal = ![string]::IsNullOrEmpty($RenewalCertID)

   [string]$renewalJson = ''
   [string]$renewalItemJson = ''

   if ($isRenewal) {
      $renewalJson = '"renewal": "true",'
      $renewalItemJson = '"renewalTrackingID": ' + $RenewalCertID + ','
   }

   [string]$specifiedVerificationMethod = $General.CustomFields["AffirmTrust:VerificationMethod"] # This must be either "FILE" or "DNS"
   [string]$apiValidationMethod = $AUTO_VERIFICATION_METHODS.$specifiedVerificationMethod

   [string]$bodyJson = '{
      ' + $renewalJson + '
      "orderType": "SSL",
      ' + $contractIDJson + '
      "accountContact": "TECHNICAL",
      "organization": {
        "companyName": "' + $Specific.SubjectDN.O + '",
        "address": {
            "streetAddress": "Not available",
            "city": "' + $Specific.SubjectDN.L + '",
            "stateProvince": "' + $Specific.SubjectDN.ST + '",
            "postalCode": "00000",
            "country": "' + $Specific.SubjectDN.C + '"
        }
      },
      "items": [
        {
            '`
           + $renewalItemJson + '
            "type": "SSL",
            "product": "DV_SSL",
            "quantity": 1,
            "termYears": ' + $General.CustomFields."AffirmTrust:ValidityYears" + ',
            "signatureHashAlgorithm": "SHA2",
            "csr" : "' + $Csr + '",
            "sans": [' + $sansJson + '],

            "autoValidationMethod": "' + $apiValidationMethod + '"
        }
      ],
      "contacts": [
        {
            "contactType": "TECHNICAL",
            "companyName": "' + $Specific.SubjectDN.O + '",
            "address": {
               "streetAddress": "Not available",
               "city": "' + $Specific.SubjectDN.L + '",
               "stateProvince": "' + $Specific.SubjectDN.ST + '",
               "postalCode": "00000",
               "country": "' + $Specific.SubjectDN.C + '"
            },
            "fullName" : "' + $General.CustomFields["AffirmTrust:ContactName"] + '",
            "title": "Not available",
            "email": "' + $General.CustomFields["AffirmTrust:ContactEmail"] + '",
            "phone": "000-0000"
        }
      ]
   }'

   return $bodyJson

}

function Assemble-BodyJsonReissue {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific,
      [Parameter(Mandatory = $true, HelpMessage = "CSR")]
      [string]$Csr,
      [Parameter(Mandatory = $true, HelpMessage = "Order ID")]
      [string]$OrderID,
      [Parameter(Mandatory = $true, HelpMessage = "Cert ID")]
      [string]$CertID
   )

   $sansJson = $Specific.SubjAltNames.DNS | ConvertTo-Json
   $sansJson = $sansJson -replace '[\[\]]', '' # get rid of the enclosing square brackets

   [string]$contractID = $General.CustomFields."AffirmTrust:ContractID"
   [boolean]$hasContractID = ![string]::IsNullOrEmpty($contractID)
   [string]$contractIDJson = ''
   if ($hasContractID) {
      $contractIDJson = '"contractID" : ' + $contractID + ','
   }

   $bodyJson = '{
       "certificateTrackingID": "' + $CertID + '",
       "signatureHashAlgorithm": "SHA2",
       "orderID": "' + $OrderID + '",
       ' + $contractIDJson + '
       "csr" : "' + $Csr + '",
       "sans": [' + $sansJson + ']
       }'

   return $bodyJson
}

function Get-LatestCertIDFromOrder {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "Order ID")]
      [string]$orderID
   )

   $resultObject = Get-OrderObject -General $General -orderID $orderID
   [int]$trackingID = $resultObject.latestCertId   # eventually latestCertId will be removed from the AffirmTrust API

   if(($trackingID -eq 0) -or ($trackingID -eq $null)) {
      "Could not find latestCertId. Trying latestCertificateTrackingID" | Out-Host
      $trackingID = $resultObject.latestCertificateTrackingID
   }

   return @{ LatestCertId = $trackingID; OrderObject = $resultObject }
}

function Get-OrderIDCertIDFromTransID {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "TransID")]
      [string]$transID
   )

   $splitArray = $transID.Split("|")
   return @{ OrderID = $splitArray[0]; CertID = $splitArray[1] }
}


function Submit-Csr {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific,
      [Parameter(Mandatory = $false, HelpMessage = "Renewal Cert ID, only required for renewal requests")]
      [string]$RenewalCertID
   )

   $csr = $Specific.Pkcs10 -replace "[`r`n]", ''    # Remove the carriage returns
   $bodyJson = Assemble-BodyJson -General $General -Specific $Specific -Csr $csr -RenewalCertID $RenewalCertID

   try {
      $endpoint = "/order"
      $placeOrderResult = Post-API -apiUser $General.UserName -apiPassword $General.UserPass -apiPath $endpoint -bodyJSON $bodyJson
      $orderID = $placeOrderResult.resourceID
      $orderObject = Get-VerificationReadyOrder -orderID $orderID
      $certID = $orderObject.latestCertificateTrackingID
      [hashtable]$domainVerificationRecords = Get-DomainValidationInfoFromOrder -orderObject $orderObject
      Do-DomainVerificationProcessing -domainVerificationRecords $domainVerificationRecords -orderID $orderObject.orderID -certID $certID -domainVerificationFolder $General.CustomFields["AffirmTrust:VerificationFolder"]
      $tid = $placeOrderResult.resourceID + "|" + $certID
      return @{ OrderObject = $orderObject; TransId = $tid }
   }
   catch {
      throw "Unable to complete cert request: " + $_.Exception.Message
   }

}

function Get-VerificationReadyOrder {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "Order ID")]
      [string]$orderID
   )

   [int]$loopCount = 0
   $orderObject = $null

   do {
      if($loopCount -eq $GET_ORDER_CHECK_MAX_TIMES) {
         throw "Exceeded maximum attempts to retrieve verification info for CN and all SANs. Aborting this cert request. Please start a new cert request"
      }

      Start-Sleep -Seconds $GET_ORDER_CHECK_INTERVAL_SECS
      $getOrderResult = Get-LatestCertIDFromOrder -orderID $orderID
      $orderObject = $getOrderResult.OrderObject
      $certID = $getOrderResult.LatestCertId
      $loopCount = $loopCount + 1
      [string]$msg = 'Inside Get-VerificationReadyOrder: Loop number ' + $loopCount
      $msg | Out-Host
   }  while(!(Get-OrderIsReadyForDomainVerification -orderObject $orderObject -certId $certID) -and ($loopCount -le $GET_ORDER_CHECK_MAX_TIMES))

   return $orderObject
}

function Check-Field {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "Field Name to check")]
      [string]$fieldName,
      [Parameter(Mandatory = $true, HelpMessage = "Field Value to check")]
      [string]$fieldValue,
      [Parameter(Mandatory = $false, HelpMessage = "Error message if fieldValue is invalid")]
      [string]$additionalMessage
   )

   [string]$errorMessage = "No value supplied for field: "

   if ( [string]::IsNullOrWhiteSpace($fieldValue)) {
      $errorMessage = $errorMessage + $fieldName + "."

      if (![string]::IsNullOrWhiteSpace($additionalMessage)) {
         $errorMessage = $errorMessage + " " + $additionalMessage + "."
      }

      return ($errorMessage + "`n")
   }
   else {
      return $null
   }
}

function Check-VerificationFolder {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "VerificationFolder path")]
      [string]$verificationFolder
   )

   [string]$errorMessage = $null
   $errorMessage = Check-Field -fieldName 'Verification Folder' -fieldValue $verificationFolder -additionalMessage 'Must specify the full path to the folder in which the required domain verification records file is to be written (for further company-specific processing)'

   if(![string]::IsNullOrEmpty($errorMessage)) {
      return $errorMessage
   }

   # a non-null value was supplied. Now check if it's a syntactically-valid path (regardless of whether or not it actually exists)
   if(!(Test-Path -Path $verificationFolder.Trim() -IsValid)) {
      return "VerificationFolder value is not a valid path: " + $verificationFolder
   }
}

[string]$VERIFICATION_METHOD_KEY = "VERIFICATION_METHOD_KEY"

function Get-DomainValidationInfoFromOrder {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "Order object")]
      $orderObject
   )

   [hashtable]$domainVerificationRecords = @{ }

   try {
      [array]$vettingRecords = $orderObject.vettingStatus

      # Compile a hashtable of domain verification info for each domain that needs verification, being sure not to add duplicates.
      # For a given order, the entries should be either all AUTO_VALIDATION_FILE or all AUTO_VALIDATION_DNS. There should not be a mix.
      foreach ($vettingRecord in $vettingRecords) {
         if (Get-IsReadyForVerification -vettingRecord $vettingRecord) {
            if ($vettingRecord.autoValidationMethod -eq $AUTO_VERIFICATION_METHODS.FILE) {
               $key = $vettingRecord.autoValidationFileContent
               [boolean]$containsKey = $domainVerificationRecords.ContainsKey($key)

               if (!$containsKey) {
                  $domainVerificationRecords.Add($key, $vettingRecord.autoValidationFilePath)
               }

               if (!$domainVerificationRecords.ContainsKey($VERIFICATION_METHOD_KEY)) {
                  $domainVerificationRecords.Add($VERIFICATION_METHOD_KEY, "FILE")
               }
            }
            elseif ($vettingRecord.autoValidationMethod -eq $AUTO_VERIFICATION_METHODS.DNS) {
               $key = ($vettingRecord.autoValidationDnsEntryValue + "|" + $vettingRecord.autoValidationDnsEntryType)
               [boolean]$containsKey = $domainVerificationRecords.ContainsKey($key)

               if (!$containsKey) {
                  $domainVerificationRecords.Add($key, $vettingRecord.autoValidationDnsEntryName)
               }

               if (!$domainVerificationRecords.ContainsKey($VERIFICATION_METHOD_KEY)) {
                  $domainVerificationRecords.Add($VERIFICATION_METHOD_KEY, "DNS")
               }
            }
         }
      }

      return $domainVerificationRecords
   }
   catch {
      throw "Error extracting domain validation info for order " + $orderObject.orderID + ": " + $_.Exception.Message
   }
}

function Get-IsReadyForVerification
{
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "Vetting record")]
      $vettingRecord
   )

   return ($vettingRecord.type -eq "DOMAIN") -and (([string]::IsNullOrEmpty($vettingRecord.status) -or ($vettingRecord.status -eq "IN_PROGRESS")))
}

<#
      Write domain verification info to the specified folder
#>
function Do-DomainVerificationProcessing {
   Param (
      [Parameter(Mandatory = $true, HelpMessage = "Auth File Records. Key/Name is the contents. Value is the URL")]
      [hashtable]$domainVerificationRecords,
      [Parameter(Mandatory = $true, HelpMessage = "Order ID, for use in the filename")]
      [string]$orderID,
      [Parameter(Mandatory = $true, HelpMessage = "Cert ID, for use in the filename")]
      [string]$certID,
      [Parameter(Mandatory = $true, HelpMessage = "Where to write the FileAuth records file")]
      [string]$domainVerificationFolder
   )

   [int]$recordCount = $domainVerificationRecords.Count

   if ($recordCount -gt 1) {
      $depositoryFile = $domainVerificationFolder + "\" + $DV_RECORDS_FILENAME_BASE + (Get-Date -Format yyyyMMddHHmmssfff) + "-" + $orderID + "-" + $certID + ".txt"
      # The first line is the verification method (FILE or DNS)
      [string]$depositoryFileContent = $domainVerificationRecords.$VERIFICATION_METHOD_KEY + "`r`n"
      [int]$iRecord = 0

      $domainVerificationRecords.GetEnumerator() | ForEach-Object {
         if ($_.Name -ne $VERIFICATION_METHOD_KEY) {
            $depositoryFileContent += ($_.Value + "|" + $_.Name)
            # Avoid adding an extra empty line at the bottom of the file
            if ($iRecord -lt ($recordCount - 1)) {
               $depositoryFileContent += "`r`n"
            }
         }

         $iRecord += 1
      }

      $depositoryFileContent | Out-File $depositoryFile
   }
}

function Create-VerificationFolder {
   Param (
      [Parameter(Mandatory, HelpMessage = "VerificationFolder path")]
      [string]$verificationFolder
   )

   if(!(Test-Path -Path $verificationFolder)) {
      # Folder does not exist, create it
      New-Item -Path $verificationFolder -ItemType directory
   }

}

function Get-OrderObject {
   Param (
      [Parameter(Mandatory, HelpMessage = "General Parameters")]
      [Collections.Hashtable]$General,
      [Parameter(Mandatory, HelpMessage = "Order ID")]
      [string]$orderID
   )

   $endpoint = "/order/" + $orderID

   try {
      $getAPIResult = Get-API -apiUser $General.UserName -apiPassword $General.UserPass -apiPath $endpoint
      $orderJson = $getAPIResult.Content
   }
   catch {
      throw "Error calling the AffirmTrust CA to retrieve order " + $orderID + ": " + $_.Exception.Message
   }

   $orderObject = $orderJson | ConvertFrom-Json
   return $orderObject
}

<#
      This is to adjust for a couple of things with respect to replacements/reissues
      1) Bug in API. It should accept a blank/null ContractID, but instead returns a 500 error. If no ContractID is submitted
      set it to the ContractID of the order
      2) For DV, we must submit the same SANs as for the original/existing cert, otherwise the request will fail (order) validation. 
      So, regardless of what user submitted, we must pull the same SANs (either from the existing cert or the order) and submit those
      with the replacement/reissue request
#>
function Do-CsrAsReplacementAdjustments {

   Param (
      [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
      [System.Collections.Hashtable]$General,
      [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
      [System.Collections.Hashtable]$Specific
   )

   $orderIDCertID = Get-OrderIDCertIDFromTransID -transID $Specific.CertId
   $orderID = $orderIDCertID.OrderID
   $certID = $orderIDCertID.CertID
   $orderObject = Get-OrderObject -General $General -orderID $orderID

   [array]$sans = Get-SANsFromOrderObject -orderObject $orderObject -certID $certID
   $Specific.SubjAltNames.DNS = $sans

   [string]$contractID = $General.CustomFields["AffirmTrust:ContractID"]

   if ( [string]::IsNullOrWhiteSpace($contractID)) {
      # if no contractID was submitted, grab it from the order (i.e., submit the same contract that was used before)
      $General.CustomFields["AffirmTrust:ContractID"] = $orderObject.contractNumber
   }

}

function Get-OrderIsReadyForDomainVerification {
   Param (
      [Parameter(Mandatory, HelpMessage = "Order Object")]
      $orderObject,
      [Parameter(Mandatory, HelpMessage = "Cert ID")]
      [string]$certId
   )
   [boolean]$retVal = $false;
   $certRecord = Get-CertRecordFromOrderObject -orderObject $orderObject -certID $certId
   [int]$unverifiedDomainCount = Get-UnverifiedDomainCount -orderObject $orderObject

   if ($certRecord -ne $null) {
      [array]$sans = $certRecord.sans
      [int]$domainCount = $sans.Count + 1
      #('verification-ready ' + $unverifiedDomainCount + '  sans+CN ' + $domainCount) | Out-Host
      if($domainCount -eq $unverifiedDomainCount) {
         $retVal = $true
      }
   }

   return $retVal
}

function Get-UnverifiedDomainCount {
   Param (
      [Parameter(Mandatory, HelpMessage = "Order Object")]
      $orderObject
   )

   [int]$count = 0;

   $orderObject.vettingStatus | ForEach-Object {
      if (Get-IsReadyForVerification -vettingRecord $_) {
         $count = $count + 1
      }
   }

   return $count
}

function Get-SANsFromOrderObject {
   Param (
      [Parameter(Mandatory, HelpMessage = "Order Object")]
      $orderObject,
      [Parameter(Mandatory, HelpMessage = "Cert ID")]
      [string]$certID
   )

   $certRecord = Get-CertRecordFromOrderObject -orderObject $orderObject -certID $certID

   if ($certRecord -ne $null) {
      return $certRecord.sans
   }
   else {
      return $null
   }
}

function Get-CertRecordFromOrderObject {
   Param (
      [Parameter(Mandatory, HelpMessage = "Order Object")]
      $orderObject,
      [Parameter(Mandatory, HelpMessage = "Cert ID")]
      [string]$certID
   )

   # Find the matching certificate
   $orderObject.detail.certificates | ForEach-Object {
      if ($_.trackingID -eq $certID) {
         return $_
      }
   }

   return $null
}

function Write-DebugMessage {
   Param (
      [Parameter(Mandatory, HelpMessage = "Debug Message")]
      [string]$message
   )

   if($DEBUG) {
      ((Get-Date).ToString() + ": " + $message + "`n") | Out-File -FilePath $DEBUG_FILE -Append
   }
}
