<#
//---------------------------------------------------------------------------
// WinRM PEM.ps1
//
// v1.0 - July 2021
//---------------------------------------------------------------------------
// This adaptable driver enables organizations to deploy PEM keystores on
// Windows systems using WinRM.
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// Venafi hereby grants you a limited license to use and modify this
// software, including any Contributions, during only the period in which you
// hold a valid license from Venafi to use the Venafi Trust Protection
// Platform. For the purposes of this copyright notice, “Contributions”
// means any modifications of this software or derivative works based on
// this software. You have a responsibility to share any Contributions you
// may make with the Venafi community. To the extent you may create any,
// Contributions, Venafi will have an irrevocable license to use, modify or
// distribute those Contributions.
//
// THE SOFTWARE IS PROVIDED AS-IS AND WITHOUT ANY WARRANTY, EXPECTATION OF
// COMPATIBILITY, TECHNICAL SUPPORT, ASSISTANCE, UPDATES, OR OTHER SERVICES
// THAT MIGHT BE PROVIDED TO YOU OTHERWISE. YOU ACKNOWLEDGE AND AGREE THAT
// THIS SOFTWARE DOES NOT CONSTITUTE COMMERCIAL RELEASE OF VENAFI SOFTWARE
// AND MAY CONTAIN BUGS OR OTHER ERRORS OR CAUSE ERRORS IN OTHER SOFTWARE OR
// SYSTEMS WHEN USED IN CONJUNCTION THEREWITH. TO THE EXTENT VENAFI HAS MADE
// ANY WARRANTIES TO YOU REGARDING THE FITNESS OF SOFTWARE FOR ANY PURPOSE,
// OR THAT SOFTWARE MAY BE FREE FROM BUGS OR OTHER ERRORS, THIS SOFTWARE AND
// ANY PRODUCTS WHEN USED IN CONJUNCTION THEREWITH ARE EXPRESSLY EXCLUDED
// FROM ANY SUCH WARRANTIES. BY USING THIS SOFTWARE, YOU HEREBY AGREE TO
// FOREVER RELEASE AND HOLD HARMLESS VENAFI, ITS DIRECTORS, OFFICERS,
// EMPLOYEES, AGENTS, AND AFFILIATES FROM ANY LIABILITY OR DEMANDS ARISING
// THEREFROM OR RELATING THERETO, REGARDLESS OF THE THEORY OF LIABILITY.
//
// The software and its contents are provided by Venafi to customers for the
// purposes of integrating with services and platforms. Any sharing of the
// software outside your organization without consent from Venafi is
// strictly prohibited. Without limiting the foregoing, the above copyright
// notice, preceding paragraphs, this paragraph and the following paragraph
// must appear in all copies, modifications, reproductions, and
// distributions of this software.
//
// IN NO EVENT SHALL VENAFI, ITS DIRECTORS, OFFICERS, EMPLOYEES, AGENTS, OR
// AFFILIATES BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL,
// INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT
// OF THE USE OF THIS SOFTWARE OR ITS DOCUMENTATION, IF ANY, EVEN IF VENAFI
// HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. VENAFI SPECIFICALLY
// DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. THIS
// SOFTWARE, ALONG WITH ITS DOCUMENTATION, IF ANY, IS PROVIDED "AS IS".  
//---------------------------------------------------------------------------
             
<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Policyable
Bit 3 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text1|Private Key File|111
Text2|Certificate File|111
Text3|Certificate Chain File|110
Text4|Text Field #4|000
Text5|Text Field #5|000
Option1|Overwrite Existing Chain|110
Option2|Yes/No Option #2
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

 
 

$securePassword = ConvertTo-SecureString $General.UserPass -AsPlainText -force
$cred = New-Object System.Management.Automation.PsCredential($General.UserName,$securePassword)

 Invoke-Command -ComputerName  $General.HostAddress -ScriptBlock {

  #############################################################################################
# Check if Keystore with same name already exists                                           #
#############################################################################################
$KeystoreFilename = Split-Path $using:General.VarText3 -leaf
$keystoreFolder = Split-Path -Path $using:General.VarText3
$result = Get-ChildItem -Path $keystoreFolder -Filter $KeystoreFilename -Recurse | %{$_.FullName}
#############################################################################################
# Crearea backup file when create is true and resuse is true                                #
#############################################################################################

 if($result -ne $null -and $using:General.VarBool1 -eq $true){
   
   Move-Item -Path $using:General.VarText1 -Destination "$($keystoreFolder)\$($KeystoreFilename)-ved.bak" -Force 
}



 if ($using:General.VarText3 -ne $null){

 try {     
      [io.file]::WriteAllText("$($using:General.VarText3)",$using:Specific.ChainPem)
         }
        catch {
          throw ('Unable to export Chain. Exception: {0}' -f $_.Exception.InnerException.Message)
        }

    }

 }-credential $cred

    return @{ Result="Success"; }
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

      

      $securePassword = ConvertTo-SecureString $General.UserPass -AsPlainText -force
      $cred = New-Object System.Management.Automation.PsCredential($General.UserName,$securePassword)

 Invoke-Command -ComputerName  $General.HostAddress -ScriptBlock {

 try {     
     [io.file]::WriteAllText("$($using:General.VarText1)",$using:Specific.PrivKeyPem )

         }
        catch {
          throw ('Unable to export Private Key. Exception: {0}' -f $_.Exception.InnerException.Message)
        }

   
 }-credential $cred

     
    return @{ Result="Success"; }
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


 try {     
       [io.file]::WriteAllText("$($using:General.VarText2)",$using:Specific.CertPem )
         }
        catch {
          throw ('Unable to export Certificate. Exception: {0}' -f $_.Exception.InnerException.Message)
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
$results = Invoke-Command -ComputerName  $General.HostAddress -ScriptBlock {

 
  

   $x509 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
   $x509.Import($using:General.VarText2)

   New-Object -TypeName PSCustomObject -Property  @{Serial = $(  $x509.SerialNumber); Thumprint = $(  $x509.Thumbprint)}



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