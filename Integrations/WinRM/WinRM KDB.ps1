<#
//---------------------------------------------------------------------------
// WinRM KDB.ps1
//
// v1.0 - July 2021
//---------------------------------------------------------------------------
// This adaptable driver enables organizations to deploy KDB keystores on
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
Text1|Key Store Path|111
Text2|Certificate Label|111
Text3|Store Type|000
Text4|Keystore Path|000
Text5|Certicate alias|000
Option1|Create Keystore|111
Option2|Reuse Label|111
Passwd|Key Store Credential|111
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

    return @{ Result="NotUsed"; Pkcs10="-----BEGIN CERTIFICATE REQUEST-----..."; }
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

 
 



    return @{ Result="NotUsed"; }
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

      

    

     
    return @{ Result="NotUsed"; }
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
    
     $BasePath = $(Get-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Venafi\Platform -Name "Base Path").'Base Path'
     Add-Type -Path "$($BasePath)\Service Modules\CertificateManager.dll"
     Add-Type -path 'C:\windows\Microsoft.NET\Framework\v4.0.30319\System.ServiceModel.dll'
     Add-Type -Path "$($BasePath)\Drivers\Applications\AppGSK.dll"

 

     # create credential to for the connection to the endpoint server #
    
     $securePassword = ConvertTo-SecureString $General.UserPass -AsPlainText -force
     $cred = New-Object System.Management.Automation.PsCredential($General.UserName,$securePassword)
        
     #keystore filename and Keystore folder               #

     $KeystoreFilename = Split-Path $General.VarText1 -leaf
     $keystoreFolder = Split-Path -Path $General.VarText1


     #Validate the file extension of the keystore path    #
     if([System.IO.Path]::GetExtension($KeystoreFilename) -ne ".kdb"){
          throw "Mandatory Field 'Keystore Path' must end with '.kdb' " 
      }
        
     #validate that the certificate Alias field is only alphnumerical.
     if($General.VarText2 -match '\W' -or $General.VarText2 -match '\s' ){
          throw "Mandatory Field 'Certificate Alias' contains special characters." 
      }
        


     #############################################################
     # create is true                                            #
     #############################################################
  
     if($General.VarBool1 -eq $true){
     
     
     # Create X509Certificate2 object from byte array PKCS#12 collection  #
     
     $x509 = New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2'
     $x509.Import($Specific.Pkcs12,$Specific.EncryptPass,4)
    
     
     # Create X509Certificate2Collection object from  byte array PKCS#7 collection that includes all chain certificates #
     
     $x509Chain = New-object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2Collection'
     $x509Chain.Import( $Specific.ChainPkcs7)

      
     # Instantiate a CMSKeystore object from the CMSKeystore Class in appgsk.dll #
     
     try{
        $CMSkeystore =  [Venafi.Drivers.Applications.CMSKeystore]::Create([Venafi.Drivers.Applications.KeystoreVersion]::Version3,"$($General.VarPass)")
      }catch{
        throw $_.Exception
        } 
     
     # import the chain to the CMSkeystore object #
     
     $chainimport =$CMSkeystore.ImportCertificateChain($x509Chain)
     
     if($chainimport -ne $null){
         throw "$($chainimport)"
         }
     
      # import the certificate to the CMSkeystore object #
     
      $certimport = $CMSkeystore.ImportCertificate($x509,$Specific.PrivKeyPem,"$($General.VarText2)",$false,$false) 
    
      if($certimport -ne $null){
          throw "$($certimport)"
          }
     
      #Save the CMSkeystore object as gsk keystore file and stash file at the endpoint server#
    
      $memgsk = New-Object -TypeName 'System.IO.MemoryStream'
      $mempass = New-Object -TypeName 'System.IO.MemoryStream'

      $SaveKeystore= $CMSkeystore.Save($memgsk,$mempass)
         
      [byte[]]$bytegsk = $memgsk.ToArray() 
      [byte[]]$bytepass = $mempass.ToArray() 

      Invoke-Command -ComputerName $General.HostAddress -ScriptBlock {

      #check if the keystore file already exists .#
      $result = Get-ChildItem -Path $using:keystoreFolder -Filter $using:KeystoreFilename -Recurse | %{$_.FullName}
      $result_sth = Get-ChildItem -Path $using:keystoreFolder -Filter $($($using:KeystoreFilename).Replace(".kdb",".sth")) -Recurse | %{$_.FullName}

      if($result -ne $null){
      
       Set-location $using:General.VarText1
       Move-Item -Path $using:General.VarText1 -Destination "$($using:keystoreFolder)\$($using:KeystoreFilename)-ved.bak" -Force 
       }

      if($result_sth -ne $null ){
       Set-location $using:General.VarText1
       Move-Item -Path $result_sth -Destination "$($using:keystoreFolder)\$($($using:KeystoreFilename).Replace(".kdb",".sth"))-ved.bak" -Force 
       }

      [io.file]::WriteAllBytes("$($using:General.VarText1)",$using:bytegsk)
      [System.IO.File]::WriteAllBytes("$using:keystoreFolder\$($($using:KeystoreFilename).Replace(".kdb",".sth"))",$using:bytepass)
 
  

    } -credential $cred




    
     }
     
     #############################################################
     # create is false is reuse is false                         #
     #############################################################
    
     if($General.VarBool1 -eq $false -and $General.VarBool2 -eq $false){
     
     $result =  Invoke-Command -ComputerName $General.HostAddress -ScriptBlock {

      #check if the keystore file already exists .#
      $result = Get-ChildItem -Path $using:keystoreFolder -Filter $using:KeystoreFilename -Recurse | %{$_.FullName}
      $result_sth = Get-ChildItem -Path $using:keystoreFolder -Filter $($($using:KeystoreFilename).Replace(".kdb",".sth")) -Recurse | %{$_.FullName}

      if($result -ne $null){
      
       Set-location $using:General.VarText1
       copy-Item -Path $using:General.VarText1 -Destination "$($using:keystoreFolder)\$($using:KeystoreFilename)-ved.bak" -Force 
       }

      if($result_sth -ne $null ){
       Set-location $using:General.VarText1
       copy-Item -Path $result_sth -Destination "$($using:keystoreFolder)\$($($using:KeystoreFilename).Replace(".kdb",".sth"))-ved.bak" -Force 
       }
        
        if($result -eq $null -and $result_sth -eq $null){
        throw "Install Certificate failed with error:keystore does not exist and Create is not selected." 
           }
            
     $gskbytes = [system.io.file]::ReadAllBytes("$($using:General.VarText1)")
     $gskmem = New-Object 'System.IO.MemoryStream'(,$gskbytes)
   
     return $gskmem.ToArray()
  
     } -credential $cred
     
     

     $gskmemCurrent = New-Object 'System.IO.MemoryStream'(,$result)
    
     $CMSkeystoreCurrent =  [Venafi.Drivers.Applications.CMSKeystore]::CreateFrom($gskmemCurrent,"$($General.VarPass)")
    
   if($CMSkeystoreCurrent.RecordLabelList.Contains("$($General.VarText2)") ){
    #$CMSkeystoreCurrent.RecordLabelList.Contains("$($General.VarText2)") | Out-File C:\Temp\kdbtest\result.txt 
     throw "Install Certificate failed with error:Certificate label exists and Reuse Label is not selected."
   }else{
   
      
     # Create X509Certificate2 object from byte array PKCS#12 collection  #
     
     $x509 = New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2'
     $x509.Import($Specific.Pkcs12,$Specific.EncryptPass,4)
    
     $CMSkeystoreCurrent.ImportCertificate($x509,$Specific.PrivKeyPem,"$($General.VarText2)",$false,$true) 
      
          #Save the CMSkeystore object as gsk keystore file and stash file at the endpoint server#
    
      $memgsk = New-Object -TypeName 'System.IO.MemoryStream'
      $mempass = New-Object -TypeName 'System.IO.MemoryStream'

      $SaveKeystore=  $CMSkeystoreCurrent.Save($memgsk,$mempass)
         
      [byte[]]$bytegsk = $memgsk.ToArray() 
      [byte[]]$bytepass = $mempass.ToArray() 

      
       Invoke-Command -ComputerName $General.HostAddress -ScriptBlock {
        
       Set-location $using:General.VarText1
       Remove-Item -Path $using:General.VarText1 -Destination "$($using:keystoreFolder)\$($using:KeystoreFilename)-ved.bak" -Force 
       Remove-Item -Path $result_sth -Destination "$($using:keystoreFolder)\$($($using:KeystoreFilename).Replace(".kdb",".sth"))-ved.bak" -Force 
       
      [io.file]::WriteAllBytes("$($using:General.VarText1)",$using:bytegsk)
      [System.IO.File]::WriteAllBytes("$using:keystoreFolder\$($($using:KeystoreFilename).Replace(".kdb",".sth"))",$using:bytepass)
 
  
     } -credential $cred
   
     }


    }

     #############################################################
     # create is false is reuse is true                          #
     #############################################################
     if($General.VarBool1 -eq $false -and $General.VarBool2 -eq $true){
     
      $result =  Invoke-Command -ComputerName $General.HostAddress -ScriptBlock {

      #check if the keystore file already exists .#
      $result = Get-ChildItem -Path $using:keystoreFolder -Filter $using:KeystoreFilename -Recurse | %{$_.FullName}
      $result_sth = Get-ChildItem -Path $using:keystoreFolder -Filter $($($using:KeystoreFilename).Replace(".kdb",".sth")) -Recurse | %{$_.FullName}

      if($result -ne $null){
      
       Set-location $using:General.VarText1
       copy-Item -Path $using:General.VarText1 -Destination "$($using:keystoreFolder)\$($using:KeystoreFilename)-ved.bak" -Force 
       }

      if($result_sth -ne $null ){
       Set-location $using:General.VarText1
       copy-Item -Path $result_sth -Destination "$($using:keystoreFolder)\$($($using:KeystoreFilename).Replace(".kdb",".sth"))-ved.bak" -Force 
       }
        
        if($result -eq $null -and $result_sth -eq $null){
        throw "Install Certificate failed with error:keystore does not exist and Create is not selected." 
           }
            
     $gskbytes = [system.io.file]::ReadAllBytes("$($using:General.VarText1)")
     $gskmem = New-Object 'System.IO.MemoryStream'(,$gskbytes)
   
     return $gskmem.ToArray()
  
     } -credential $cred
     
       
     # Create X509Certificate2 object from byte array PKCS#12 collection  #
     
     $x509 = New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2'
     $x509.Import($Specific.Pkcs12,$Specific.EncryptPass,4)

     $gskmemCurrent = New-Object 'System.IO.MemoryStream'(,$result)
    
     $CMSkeystoreCurrent =  [Venafi.Drivers.Applications.CMSKeystore]::CreateFrom($gskmemCurrent,"$($General.VarPass)")
    
      $CMSkeystoreCurrent.ImportCertificate($x509,$Specific.PrivKeyPem,"$($General.VarText2)",$true,$true) 
      
          #Save the CMSkeystore object as gsk keystore file and stash file at the endpoint server#
    
      $memgsk = New-Object -TypeName 'System.IO.MemoryStream'
      $mempass = New-Object -TypeName 'System.IO.MemoryStream'

      $SaveKeystore=  $CMSkeystoreCurrent.Save($memgsk,$mempass)
         
      [byte[]]$bytegsk = $memgsk.ToArray() 
      [byte[]]$bytepass = $mempass.ToArray() 

      
       Invoke-Command -ComputerName $General.HostAddress -ScriptBlock {
        
       Set-location $using:General.VarText1
       Remove-Item -Path $using:General.VarText1 -Destination "$($using:keystoreFolder)\$($using:KeystoreFilename)-ved.bak" -Force 
       Remove-Item -Path $result_sth -Destination "$($using:keystoreFolder)\$($($using:KeystoreFilename).Replace(".kdb",".sth"))-ved.bak" -Force 
       
      [io.file]::WriteAllBytes("$($using:General.VarText1)",$using:bytegsk)
      [System.IO.File]::WriteAllBytes("$using:keystoreFolder\$($($using:KeystoreFilename).Replace(".kdb",".sth"))",$using:bytepass)
 
  
     } -credential $cred
   
      
     
     
     
     }

  
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

   $BasePath = $(Get-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Venafi\Platform -Name "Base Path").'Base Path'
     Add-Type -Path "$($BasePath)\Service Modules\CertificateManager.dll"
     Add-Type -path 'C:\windows\Microsoft.NET\Framework\v4.0.30319\System.ServiceModel.dll'
     Add-Type -Path "$($BasePath)\Drivers\Applications\AppGSK.dll"


    $securePassword = ConvertTo-SecureString $General.UserPass -AsPlainText -force
    $cred = New-Object System.Management.Automation.PsCredential($General.UserName,$securePassword)

    $KeystoreFilename = Split-Path $using:General.VarText2 -leaf
    $keystoreFolder = Split-Path -Path $using:General.VarText2

    $results = Invoke-Command -ComputerName  $General.HostAddress -ScriptBlock {

     $gskbytes = [system.io.file]::ReadAllBytes("$($using:General.VarText1)")
     $gskmem = New-Object 'System.IO.MemoryStream'(,$gskbytes)
   
     return $gskmem.ToArray()
    
 }-credential $cred 

     $gskmemCurrent = New-Object 'System.IO.MemoryStream'(,$results)
    
     $CMSkeystoreCurrent =  [Venafi.Drivers.Applications.CMSKeystore]::CreateFrom($gskmemCurrent,"$($General.VarPass)")

     $x509Out =  New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2'
     $pkpem = New-Object 'System.String'('')
     $pkoid = New-Object 'System.string'('')

     $exporttext = $CMSkeystoreCurrent.ExportCertificate("$($General.VarText2)",[ref]$x509Out,[ref]$pkpem,[ref]$pkoid)

         

    return @{ Result="Success"; Serial=$x509Out.SerialNumber; Thumprint= $x509Out.Thumbprint}
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