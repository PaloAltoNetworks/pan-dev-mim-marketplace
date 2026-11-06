<#
//---------------------------------------------------------------------------
// OpenXPKI-AdaptableCA.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// This software is licensed by INSERT DEVELOPER NAME, in addition to Venafi.
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
 
 
 #Requires -Version 5
 [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
 $ErrorActionPreference = "STOP" 
 
 $global:base_url = https://oxi-ee-demo.whiterabbitsecurity.com/rpc/venafi       #demo       
 
 <##################################################################################################
 .NAME
     Test-Settings
 .DESCRIPTION
     Verifies that fiven configuration parameters can be loaded successfully by calling Load-Config $General
 .PARAMETER General
     A hashtable containing the general set of variables needed by all or most functions
         UserName: not used
         UserPass: not used
         PfxData: a PKCS#12 containing a client certificate and private key required to authenticate with the CA
         PfxPass: the password required to access the private key in the PKCS#12
         AuxUser: not used
         AuxPass: not used
         AuxPfxData: not used
         CertObjDN: not used
         CustomFields: not used
 .NOTES
     Returns a hashtable that includes the following variables
         Result: 'Success' or 'NotUsed' to indicate the non-error completion state
 ##################################################################################################>
 function Test-Settings
 {
     Param(
         [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
         [Hashtable]$General
     )
 
     $answer = Invoke-RestMethod -Uri https://oxi-ee-demo.whiterabbitsecurity.com/healthcheck/ping
     if (1 -eq $answer.ping) {
        return @{ Result="Success" }
     }
 
     else { throw $Error[0] }
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
         [Hashtable]$General,
         [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
         [Hashtable]$Specific
     )
 
     return @{ Result="NotUsed" }
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
         [Hashtable]$General,
         [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
         [Hashtable]$Specific
     )
 
     return @{ Result="NotUsed" }
 }
 
 <##################################################################################################
 .NAME
     Submit-CsrAsReplacement
 .DESCRIPTION
     Submits a CSR to a CA for enrollment as a replacement for an existing certificate. Uses Submit-CsrAsNew internally
 .PARAMETER General
     A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
 .PARAMETER Specific
     A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
         CertId: not used
         CertPem: the raw, Base64-encoded X509 certificate to be replaced
 .NOTES
     Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
 ##################################################################################################>
 function Submit-CsrAsReplacement
 {
     Param(
         [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
         [Hashtable]$General,
         [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
         [Hashtable]$Specific
     )
 
     return Submit-CsrAsNew $General $Specific
 }
 
 <##################################################################################################
 .NAME
     Submit-CsrAsRenewal
 .DESCRIPTION
     Submits a CSR to a CA for enrollment as a renewal of an existing certificate. Uses Submit-CsrAsNew internally
 .PARAMETER General
     A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
 .PARAMETER Specific
     A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
         CertId: not used
         CertPem: the raw, Base64-encoded X509 certificate to be renewed
 .NOTES
     Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
 ##################################################################################################>
 function Submit-CsrAsRenewal
 {
     Param(
         [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
         [Hashtable]$General,
         [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
         [Hashtable]$Specific
     )
 
     return Submit-CsrAsNew $General $Specific
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
         [Hashtable]$General
     )
 
     return @{ Result="NotUsed" }
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
         PrivKeyPem: not used
         EncryptPass: not used
         DiscardPrivateKeyAndCsr: not used
 ##################################################################################################>
 function Retrieve-Certificate
 {
     Param(
         [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
         [Hashtable]$General,
         [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
         [Hashtable]$Specific
     )
 
     return Submit-CsrAsNew $General $Specific
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
         CertPem: the raw, Base64-encoded X509 certificate to be revoked
         ReasonCode: 1 (User Key Compromised), 3 (User Changed Affiliation), 4 (Certificate Superseded), All other codes are mapped to UNSPECIFIED
         Comment: not used
 .NOTES
     Returns a hashtable that includes the following variables:
         Result: 'Success' or 'NotUsed' to indicate the non-error completion state
 ##################################################################################################>
 function Revoke-Certificate
 {
     Param(
         [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
         [Hashtable]$General,
         [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
         [Hashtable]$Specific
     )
    
    #Needs further testing, endpoint was not available at this time of writing (22-11-15)
    $body = @{ "method" = "RevokeCertificateByIdentifier";
               "cert_identifier" = $Specific.TransId;
               "reason_code" = $Specific.ReasonCode;
               "comment" = $Specific.comment }
    try
        {
            $answer = Invoke-RestMethod -Method Post -Uri "$global:base_url/RevokeCertificateByIdentifier" -Body $body
        }
    
    catch { throw $Error[0] }
 
     return @{ Result="SUCCESS" }
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
         Pkcs10: the Base64-encoded PKCS#10-formatted certificate signing request (CSR) to be enrolled. Only PublicKey is used of.
         SubjectDN: the requested subject distiguished name as a hash table. OU is a string array and all others are strings
         SubjAltNames: hash table keyed by SAN type. Values are string arrays.
         KeySize: not used
 .NOTES
     Returns a hash table that includes the following variables:
         Result: 'Success' to indicate the non-error completion state. NOTE: this function is required.
         TransId: the identifier used to subsequently approve and/or retrieve the certificate from the CA 
         Pkcs7: a collection that includes the issued certificate and (optionally) includes all of the CA certificates in the chain
         Pkcs12: a collection that includes the issued certificate, its private key, and optionally all of the CA certificates in the chain
         PrivKeyPem: not used
         EncryptPass: not used
 ##################################################################################################>
 function Submit-CsrAsNew
 {
     Param(
         [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
         [Hashtable]$General,
         [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
         [Hashtable]$Specific
     )
    
    #Sanatie request from line breaks and return characters, otherwise openxpki endpoint throws "400 - Bad request"
    [string]$csr = $Specific.Pkcs10 -replace "(-----|BEGIN CERTIFICATE REQUEST|END CERTIFICATE REQUEST|\r|\n)"  
    $body =  @{ "pkcs10" = $("-----BEGIN CERTIFICATE REQUEST-----`n" + $csr + "`n-----END CERTIFICATE REQUEST-----") } 
 
    try
     {
        $answer = Invoke-RestMethod -Method Post -Uri "$global:base_url/RequestCertificate" -Body $body
         
        #Just logging...
        #$answer.result | Out-File -FilePath "C:\Program Files\Venafi\Scripts\AdaptableCA\openxpki.log" -Append -Force -NoClobber -Encoding utf8
 
        if ("SUCCESS" -eq $answer.result.state) {
            
            #Combine certificate and chain
            [string]$fullCertificate = "$($answer.result.data.Certificate)`n$($answer.result.data.chain)"
            
            #Just logging...
            #$fullCertificate | Out-File -FilePath "C:\Program Files\Venafi\Scripts\AdaptableCA\openxpki.log" -Append -Force -NoClobber -Encoding utf8
            
            #Convert string header and base64 certificate content to one base64 block
            $b64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($fullCertificate)) 
            
            #Make sure to convert base64 block to byte array for filling the Pkcs7 hash table field 
            #Use "cert_identifier" as TransId instead of "transaction_id". "cert_identifier is needed for certificate revocation"
            return @{ Result="Success"; TransId=$answer.result.data.cert_identifier; Pkcs7=[System.Convert]::FromBase64String($b64)} 
 
        }
     }
     
     catch 
     {
 
         throw $error[0] 
     }
 } 