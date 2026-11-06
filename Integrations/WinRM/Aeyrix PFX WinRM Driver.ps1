<#
//---------------------------------------------------------------------------
// Aeyrix PFX WinRM Driver - Copyright (c) 2020-2021. All Rights Reserved
//
// v1.0 - July 2021
//---------------------------------------------------------------------------
// This adaptable driver enables organizations to deploy PFX keystores on
// Windows systems using WinRM.
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by Aeyrix, in addition to Venafi.
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
Text1|PKCS#12 File|111
Text2|Friendly Name|110
Text3|Certificate Chain File|110
Text4|Text Field #4|000
Text5|Text Field #5|000
Option1|Create|111
Option2|Reuse Friendly Name|111
Passwd|Password Field|000
-----END FIELD DEFINITIONS-----
#>

<######################################################################################################################
.NAME
    Prepare-KeyStore
.DESCRIPTION
    Remotely create and/or verify keystore on the hosting platform.  Remote generation is considered UNSUPPORTED if this
    function is ommitted or commented out.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
        AppObjectDN : a string containing the TPP distiguished name of the calling application object
        AssetName : a string containing a Venafi standard auto-generated name that can be used for provisioning
                    (<Common Name>-<ValidTo as YYMMDD>-<Last 4 of SerialNum>)
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
######################################################################################################################>
function Prepare-KeyStore
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
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
        EncryptPass : the password string to use if encrypting the remotely generated private key
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device;
                    if not supplied the auto-generated name is assumed
######################################################################################################################>
function Generate-KeyPair
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
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
        SubjAltNames : hashtable keyed by SAN type; values are string arrays of the individual SANs
        KeySize : the integer key size to be used when creating a key pair
        EncryptPass : the password string to use if encrypting the remotely generated private key
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs10 : a string representation of the CSR in PKCS#10 format
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device;
                    if not supplied the auto-generated name is assumed
######################################################################################################################>
function Generate-CSR
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result="Success"; Pkcs10="-----BEGIN CERTIFICATE REQUEST-----..."; }
}


<######################################################################################################################
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
######################################################################################################################>
function Install-Chain
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

 
 

    return @{Result="NotUsed"; }
}


<######################################################################################################################
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
        AssetName : (optional) the base name used to reference the private key as it was installed on the device;
                    if not supplied the auto-generated name is assumed
######################################################################################################################>
function Install-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

      

      

     
    return @{ Result="NotUsed";}
}


<######################################################################################################################
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
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-error completion state
                 (may only be 'NotUsed' if Install-PrivateKey did not return 'NotUsed')
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device;
                    if not supplied the auto-generated name is assumed
######################################################################################################################>
function Install-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

          
       
      $securePassword = ConvertTo-SecureString $General.UserPass -AsPlainText -force
      $cred = New-Object System.Management.Automation.PsCredential($General.UserName,$securePassword)

 Invoke-Command -ComputerName  $General.HostAddress -ScriptBlock {

 #############################################################################################
# Check if Keystore with same name already exists                                           #
#############################################################################################
$KeystoreFilename = Split-Path $using:General.VarText1 -leaf
$keystoreFolder = Split-Path -Path $using:General.VarText1
$result = Get-ChildItem -Path $keystoreFolder -Filter $KeystoreFilename -Recurse | %{$_.FullName}
#############################################################################################
# if Keystore with same name already exists and create keystore No                          #
#############################################################################################

 if($using:General.VarBool1 -eq $false -and $result -eq $null){
 
  throw "Install Certificate failed with error: The 'Create Store' option is unchecked and no key store exists."
  
}
   #############################################################################################
# if Keystore with same name already exists and create keystore No and Reuse Friendly is No    #
###############################################################################################

 if($using:General.VarBool1 -eq $false -and $result -ne $null -and $using:General.VarBool2 -eq $false){

 $pwd = ConvertTo-SecureString -String $using:Specific.EncryptPass -Force -AsPlainText
 $pfxData = Get-PfxData -FilePath $using:General.VarText1  -Password $mypwd

 if($pfxData.EndEntityCertificates.FriendlyName -eq $using:General.VarText2){
 
  throw "Install Certificate failed with error: A duplicate friendly name was found in the collection. Friendly name reuse is not permitted here."
  }
}

#############################################################################################
# Crearea backup file when create is true and resuse is true                                #
#############################################################################################

 if($using:General.VarBool1 -eq $true -and $result -ne $null -and $using:General.VarBool2 -eq $true){
   
   Move-Item -Path $using:General.VarText1 -Destination "$($keystoreFolder)\$($KeystoreFilename)-ved.bak" -Force 
}
      
#############################################################################################
# create backup when create is false and reuse is false                                #
#############################################################################################

if($using:General.VarBool1 -eq $false -and $result -ne $null -and $using:General.VarBool2 -eq $true){

  Copy-Item $using:General.VarText1 -Destination "$($keystoreFolder)\$($KeystoreFilename)-ved.bak"

}         
      $PFXPASS = $using:Specific.EncryptPass
      $chain = "$($using:General.VarText3)"

      if( $chain -eq $null ){
      
      $PFX = New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2Collection'
      $PFX.Import($using:Specific.Pkcs12,$PFXPASS,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
      $PFX.Item(0).FriendlyName =$using:General.VarText2

      try {
   
      $ExportPFX = $PFX.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx,$PFXPASS)
      
      [io.file]::WriteAllBytes($($using:General.VarText1),$ExportPFX)
      }
      catch {
         throw ('Unable to export X509Certificate. Exception: {0}' -f $_.Exception.InnerException.Message)
        }

      [io.file]::WriteAllText("$($keystoreFolder)\Validation.cer", $using:Specific.CertPem )
       
        }
        
        if($chain -ne $null){
              
        [io.file]::WriteAllText($($using:General.VarText3),$using:Specific.ChainPem)
        $PFXNoChain = New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2Collection'
        $PFXChain= New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2Collection'
        $ChainBytes = [System.Text.Encoding]::UTF8.GetBytes($using:Specific.ChainPem)
        $PFXNoChain.Import($using:Specific.Pkcs12,$PFXPASS,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
        $PFXChain.Import($using:Specific.ChainPkcs7)
        $PFXNoChain.RemoveRange($PFXChain)
        $PFXNoChain.Item(0).FriendlyName = $using:General.VarText2

        try {     
        $Export = $PFXNoChain.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx,$PFXPASS)
        [io.file]::WriteAllBytes($($using:General.VarText1),$Export)
         }
        catch {
          throw ('Unable to export X509Certificate. Exception: {0}' -f $_.Exception.InnerException.Message)
        }

           
        
        [io.file]::WriteAllText("$($keystoreFolder)\Validation.cer", $using:Specific.CertPem )

        }

        
 }-credential $cred




    return @{ Result="Success"; }
}


<######################################################################################################################
.NAME
    Update-Binding
.DESCRIPTION
    Binds the installed certificate with the consuming application or service on the hosting platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################>
function Update-Binding
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Activate-Certificate
.DESCRIPTION
    Performs any post-installation operations necessary to make the certificate active (such as restarting a service)
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################>
function Activate-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Extract-Certificate
.DESCRIPTION
    Extracts the active certificate from the hosting platform.  If the platform does not provide a method for exporting the
    raw certificate then it is sufficient to return only the Serial and Thumprint.  This function is REQUIRED.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        CertPem : the extracted X509 certificate referenced by AssetName in Base64 PEM format
        Serial : the serial number of the X509 certificate refernced by AssetName
        Thumbprint : the SHA1 thumprint of the X509 certificate referenced by AssetName
######################################################################################################################>
function Extract-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )
        $securePassword = ConvertTo-SecureString $General.UserPass -AsPlainText -force
      $cred = New-Object System.Management.Automation.PsCredential($General.UserName,$securePassword)

$results = Invoke-Command -ComputerName  $General.HostAddress -ScriptBlock  {

 $keystoreFolder = Split-Path -Path $using:General.VarText1

 
 $Cert = New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2'
 $Cert.Import("$($keystoreFolder)\Validation.cer")


 
    
 New-Object -TypeName PSCustomObject -Property  @{Serial = $( $Cert.SerialNumber); Thumprint = $( $Cert.Thumbprint)}
 Start-Sleep -s 2
 Remove-Item "$($keystoreFolder)\Validation.cer"
          
 }-credential $cred 



    return @{ Result="Success"; Serial=$results.Serial; Thumprint= $results.Thumprint}
}


<######################################################################################################################
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
######################################################################################################################>
function Extract-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    


    return @{ Result="NotUsed"; }
}


<######################################################################################################################
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
######################################################################################################################>
function Remove-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

     



    return @{ Result="NotUsed"; }
}

<###################### THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ######################>

Function Export-X509CertificatePfx {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $True, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [System.Security.Cryptography.X509Certificates.X509Certificate2] $X509Certificate,
    [Parameter(Mandatory = $False, Position = 1)]
    [String] $CertificateFile = '{0}.pfx'-f [System.IO.Path]::GetTempFileName(),
    [Parameter(Mandatory = $False, Position = 2)]
    [securestring] $CertificatePassword
  )

  if ($X509Certificate.GetType().FullName -ne "System.Security.Cryptography.X509Certificates.X509Certificate2") {
    throw ('Unknown X509Certificate object type: "{0}" expected "System.Security.Cryptography.X509Certificates.X509Certificate2".' -f $X509Certificate.GetType().FullName)
  }

  if (Test-Path -Path $CertificateFile) {
    throw('Unable to export X509Certificate to "{0}". File exists.' -f $CertificateFile)
  }

  try {
    $CertBytes = $X509Certificate.Export('pfx', $CertificatePassword)
    [io.file]::WriteAllBytes($CertificateFile, $CertBytes)
  }
  catch {
    throw ('Unable to export X509Certificate. Exception: {0}' -f $_.Exception.InnerException.Message)
  }

  return $CertificateFile

}