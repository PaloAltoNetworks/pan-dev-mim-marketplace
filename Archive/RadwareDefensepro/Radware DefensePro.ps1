<#
//---------------------------------------------------------------------------
// Radware DefensePro.ps1
//
// Version 0.6
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by Radware, in addition to Venafi.
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
Text1|Object Name|111
Text2|service Ip|110
Text3|Service Port|110
Text4|Object Arguments|110
Text5|Not Used|000
Option1|Not Used|000
Option2|Not Used|000
Passwd|Not Used|000
-----END FIELD DEFINITIONS-----
#>

$global:error_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\radware-error.log"

Import-Module -Name Posh-SSH

if ((Get-Module -Name "Posh-SSH") -eq $null)
{
    throw "Posh-SSH failed to import"
}

<##################################################################################################
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
        AppObjectDN : a string containing the TPP distiguished name of the calling application object
        AssetName : a string containing a Venafi standard automatically generated name that can be used for provisioning (<Common Name>-<ValidTo as YYMMDD>-<Last 4 of SerialNum>)
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
##################################################################################################>
function Prepare-KeyStore
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )
    return @{ Result="NotUsed"; }
}


<##################################################################################################
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
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
################################################################################################## >
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


<##################################################################################################
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
        SubjAltNames : hashtable keyed by SAN type; values are string arrays
        KeySize : the integer key size to be used when creating a key pair
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs10 : a string representation of the CSR in PKCS#10 format
################################################################################################## >
function Generate-CSR
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    return @{ Result="NotUsed"; }
}


<##################################################################################################
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
##################################################################################################>
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


<##################################################################################################
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
        AssetName : (optional) the name used to reference the private key as it was installed on the device; if not supplied the automatically generated name is assumed
##################################################################################################>

function Install-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific)

    $result = "NotUsed"
    return @{ Result=$result; AssetName=$name }
}


<##################################################################################################
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
        Result : 'Success', 'AlreadyInstalled' or 'NotUsed' to indicate the non-error completion state (may only be 'NotUsed' if Install-PrivateKey did not return 'NotUsed')
        AssetName : (optional) the name used to reference the certificate as it was installed on the device; if not supplied the automatically generated name is assumed
##################################################################################################>
function Install-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $result = $null

    Assert-NotNullOrEmpty "Private Key Name" $General.AssetName
    #Assert-NotNullOrEmpty "Private Key PEM" $Specific.PrivKeyPem
    Assert-NotNullOrEmpty "Private Key PEM Encrypted" $Specific.PrivKeyPemEncrypted
    Assert-NotNullOrEmpty "Private Key string password" $Specific.EncryptPass
    Assert-NotNullOrEmpty "Certificate PEM" $Specific.CertPem

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    Start-Sleep -Seconds 1
    $output = $stream.Read()
    
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
        $stream.Write("y`n")
        Start-Sleep -Seconds 1
    }
    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    $chain.Import( $Specific.ChainPkcs7 )

    $name = Fix-CertKeyName $General.AssetName 
    $chain = $($Specific.ChainPem) -replace "`n`n" -replace "`n"
    $PrivKeyEncrypted = $($Specific.PrivKeyPemEncrypted) -replace "`n`n" -replace "`n"
    $cert =  $($Specific.CertPem) -replace "`n`n" -replace "`n"


    # importing certificate chain
    $stream.Write("ssl-settings certificates-repository import $name-Chain -t interm`n")
    Start-Sleep -Seconds 1
    $output = $stream.Read()
    if($output -like '*Error: Entry with this name already exist*' -or $output -like '*Error: Entry already exist*')
    {
        # private key already exists so we're done
        $result = "AlreadyInstalled"
    }
    elseif($output -like '*Please paste Intermediate CA Certificate*')
    {
        $stream.Write("$chain`n`n.`n")
        Start-Sleep -Seconds 12
        $output = $stream.Read()

        if ($output -like '*Operation succeeded*') #continue to import the private key
        {
             
            # importing private key   
            $stream.Write("ssl-settings certificates-repository import $name -t key -p $($Specific.EncryptPass)`n")
            Start-Sleep -Seconds 1
            $output = $stream.Read()

            if ($output -like '*Error. The entry already exists - operation failed*' -or $output -like '*Error: Entry already exists with different type*')
            {
                # private key already exists so we're done
                $result = "AlreadyInstalled"
            }
            else
            {
                $stream.Write("$PrivKeyEncrypted`n.`n")
                Start-Sleep -Seconds 10
                $output = $stream.Read()
                
                if ($output -like '*Operation succeeded*') #continue to import the certificate
                {

                    $stream.Write("ssl-settings certificates-repository import $name -t certificate`n")
                    Start-Sleep -Seconds 1
                    $output = $stream.Read()

                    if ($output -like '*Error. The entry already exists - operation failed*' -or $output -like '*Error: Entry already exists with different type*')
                    {
                    # certificate already exists so we're done
                    $result = "AlreadyInstalled"
                    }
                    else
                    {
                        $stream.Write("$cert`n`n.`n")
                        Start-Sleep -Seconds 10
                        $output = $stream.Read()

                        if ($output -like '*Operation succeeded*')
                        {
                            $result = "Success"
                        }
                    }
                }          
            }
         }
    }

    $stream.Write("logout`n")
    Start-Sleep -Seconds 1
    $stream.Write("y`n")
    $stream.Read() | Out-Null
    $stream.Close()
    Remove-SSHSession -SSHSession $session | Out-Null

    if ( $result )
    {
        return @{ Result=$result; }
    }
    else
    {
        $output | Out-File -Append $global:error_log
        throw "Certificate installation failed. " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line})
    }
}


<##################################################################################################
.NAME
    Update-Binding
.DESCRIPTION
    Binds the installed certificate with the consuming application or service on the hosting platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Update-Binding 
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Assert-NotNullOrEmpty "Certificate Name" $General.AssetName
    Assert-NotNullOrEmpty "object name" $General.VarText1
    #Assert-NotNullOrEmpty "service Ip" $General.VarText2
    #Assert-NotNullOrEmpty "Service Port" $General.VarText3
    #Assert-NotNullOrEmpty "object aruments" $General.VarText4

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    Start-Sleep -Seconds 1
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
        $stream.Write("y`n")
        Start-Sleep -Seconds 1
    }
  
    $newCreation = $false

    #check if object name exist
    $stream.Write("ssl-settings protected-ssl-objects table get $($General.VarText1)`n")
    Start-Sleep -Seconds 1
    $output = $stream.Read()

    if($output -like '*Error: no such instance*')# case object name not exist
    {
        $newCreation = $true
        if($General.VarText2 -and $General.VarText3) # check if ip/port provided
        {
            if ($General.VarText4) # arguments provided
            {
                $stream.Write("ssl-settings protected-ssl-objects table add $($General.VarText1) -ip $($General.VarText2) -port $($General.VarText3) $($General.VarText4) -enabled`n")
            }
            else
            {
               $stream.Write("ssl-settings protected-ssl-objects table add $($General.VarText1) -ip $($General.VarText2) -port $($General.VarText3) -enabled`n") 
            }
            Start-Sleep -Seconds 1
            $output = $stream.Read()
            if(-not($output -like '*Created successfully*'))
            {
                $stream.Write("logout`n")
                Start-Sleep -Seconds 1
                $stream.Read() | Out-Null
                $stream.Write("y`n")
                $stream.Close()
                Remove-SSHSession -SSHSession $session | Out-Null
                $output | Out-File -Append $global:error_log
                throw "Bind certificate to consumer failed - new object creation failed " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line})
            }
        }
        else
        {
            $stream.Write("logout`n")
            Start-Sleep -Seconds 1
            $stream.Read() | Out-Null
            $stream.Write("y`n")
            $stream.Close()
            Remove-SSHSession -SSHSession $session | Out-Null
            $output | Out-File -Append $global:error_log
            throw "An Object with this name is not found and Ip/Port not provided"
        }

    }
    if($output -like '*SSL Object Status*')#case object exist
    {   
        $stream.Write(" `n`n`n")
        Start-Sleep -Seconds 1
        #creating new binding to certificate
        $stream.Write("ssl-settings protected-ssl-objects certificate-association add $($General.VarText1) $($General.AssetName)`n")
        Start-Sleep -Seconds 1
        $output = $stream.Read()

        if($output -like '*Created successfully*') #case binding succesful
        {
            $result = "Success"     
        }
    }
    
    if ( $result )
    {
        return @{ Result=$result; }
    }
    else
    {
        $output | Out-File -Append $global:error_log
        throw "Bind certificate to consumer failed. " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line})
    }
}

<##################################################################################################
.NAME
    Activate-Certificate
.DESCRIPTION
    Performs any post-installation operations necessary to make the certificate active (such as restarting a service)
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Activate-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )
    return @{ Result="NotUsed"; }
}


<##################################################################################################
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
##################################################################################################>
function Extract-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Assert-NotNullOrEmpty "Certificate Key Name" $General.AssetName

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
        $stream.Write("y`n")
    }
    

    $stream.Write("ssl-settings certificates-repository export $($General.AssetName) -t certificate`n")
    Start-Sleep -Seconds 10
    $stream.Write(" ")
    Start-Sleep -Seconds 1
    $output = $stream.Read()
    
    $header = "-----BEGIN CERTIFICATE-----"
    $footer = "-----END CERTIFICATE-----"

    if ( $output -like "*$header*" )
    {
        $CertPem = ($output -split $header,2)[1]
        $CertPem = ($CertPem -split $footer,2)[0]

        $CertPem = $header + "`n" + $CertPem.Trim() + "`n" + $footer

        $stream.Write("logout`n")
        Start-Sleep -Seconds 1
        $stream.Write("y`n")
        $stream.Read() | Out-Null
        $stream.Close()
        Remove-SSHSession -SSHSession $session | Out-Null

        return @{ Result="Success"; CertPem=$CertPem}
    }
    else
    {
        $output | Out-File -Append $global:error_log
        throw "Certificate extraction failed. " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line} )
    }
}


<##################################################################################################
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
##################################################################################################>
function Extract-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Assert-NotNullOrEmpty "Private Key Name" $General.AssetName
    Assert-NotNullOrEmpty "Private Key Password" $Specific.EncryptPass

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
        $stream.Write("y`n")
    }

    $stream.Write("ssl-settings certificates-repository export $($General.AssetName) -t key -p $($Specific.EncryptPass)`n")
    Start-Sleep -Seconds 10
    $stream.Write(" ")
    Start-Sleep -Seconds 1
    $output = $stream.Read()

    $header = "-----BEGIN RSA PRIVATE KEY-----"
    $footer = "-----END RSA PRIVATE KEY-----"

    if ( $output -like "*$header*" )
    {
        $KeyPem = ($output -split $header,2)[1]
        $KeyPem = ($KeyPem -split $footer,2)[0]

        $KeyPem = $header + "`n" + $KeyPem.Trim() + "`n" + $footer

        $stream.Write("logout`n")
        Start-Sleep -Seconds 1
        $stream.Write("y`n")
        $stream.Read() | Out-Null
        $stream.Close()
        Remove-SSHSession -SSHSession $session | Out-Null

        return @{ Result="Success"; PrivKeyPem=$KeyPem }
    }
    else
    {
        $output | Out-File -Append $global:error_log
        throw "Private Key extraction failed. " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line} )
    }
}


<##################################################################################################
.NAME
    Remove-Certificate
.DESCRIPTION
    Removes an existing certificate from IAM.  Only implement the body of this function
    if TPP can/should remove old generations of the same certificate.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        AssetNameOld : the name of a certificate that was previously replaced and should be deleted
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Remove-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Assert-NotNullOrEmpty "Old Certificate Name" $Specific.AssetNameOld

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
        $stream.Write("y`n")
        Start-Sleep -Seconds 1
    }
    
    #check if object name exist
    $stream.Write("ssl-settings protected-ssl-objects certificate-association get $($General.VarText1) $($Specific.AssetNameOld)`n")
    Start-Sleep -Seconds 1
    $output = $stream.Read()

    if(-not($output -like '*Error: no such instance*') -and $output -like '*Object Name*') #case old binding exist
    {
        #delete old binding
        $stream.Write("ssl-settings protected-ssl-objects certificate-association del $($General.VarText1) $($Specific.AssetNameOld)`n")
        Start-Sleep -Seconds 1
        $output = $stream.Read()
        if(-not($output -like '*Deleted successfully*'))
        {
            $stream.Write("logout`n")
            Start-Sleep -Seconds 1
            $stream.Read() | Out-Null
            $stream.Write("y`n")
            $stream.Close()
            Remove-SSHSession -SSHSession $session | Out-Null
            $output | Out-File -Append $global:error_log
            throw "Bind certificate to consumer failed - deletion of old binding failed" + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line})
        }
    }
    

    $stream.Write("ssl-settings certificates-repository table del $($Specific.AssetNameOld)`n")
    Start-Sleep -Seconds 5
    $output = $stream.Read()
            
    if ( $output -like "*Deleted successfully*" )
    {
        $stream.Write("ssl-settings certificates-repository table del $($Specific.AssetNameOld)-Chain`n")
        Start-Sleep -Seconds 5
        $output = $stream.Read()
        if ( $output -like "*Deleted successfully*" )
        {
            $stream.Write("logout`n")
            Start-Sleep -Seconds 1
            $stream.Read() | Out-Null
            $stream.Close()
            Remove-SSHSession -SSHSession $session | Out-Null
            return @{ Result="Success"; }
        }
        elseif( $output -like "*The entry does not exist*")
        {
        $stream.Write("logout`n")
        Start-Sleep -Seconds 1
        $stream.Write("y`n")
        $stream.Read() | Out-Null
        $stream.Close()
        Remove-SSHSession -SSHSession $session | Out-Null
        return @{ Result="NotUsed"; }
        }    
        else
        {
            $output | Out-File -Append $global:error_log
            throw "Chain ertificate removal failed. " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line} )
        }
    }
    elseif( $output -like "*The entry does not exist*")
    {
        $stream.Write("logout`n")
        Start-Sleep -Seconds 1
        $stream.Write("y`n")
        $stream.Read() | Out-Null
        $stream.Close()
        Remove-SSHSession -SSHSession $session | Out-Null
        return @{ Result="NotUsed"; }
    }
    else
    {
        $output | Out-File -Append $global:error_log
        throw "Certificate removal failed. " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line} )
    }
}


<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Assert-NotNullOrEmpty( [string]$name, [string]$value )
{
    if ( !$value )
    {
        throw "$($name) is required."
    }
}

function Fix-CertKeyName ( [string]$name )
{
    # cert/key name must be less than 32 characters
    if ( $name.Length -gt 32 )
    {
        $parts = $name.Split("_")
        $name = "_" + $parts[1] + "_" + $parts[2]  # keep the suffix as-is
        $name = $parts[0].Substring(0, 32 - $name.Length) + $name
    }

    # cert/key name may not include periods or special characters other than - and _
    return $name -Replace "\.","-"
}