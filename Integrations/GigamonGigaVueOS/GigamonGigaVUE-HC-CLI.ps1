<#
//---------------------------------------------------------------------------
// GigamonGigaVUE-HC-CLI.ps1
//
// Version 0.9.2
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
//---------------------------------------------------------------------------
// This script requires the PowerShell Posh-SSH Module to be installed.
//
// Simple Installation Instructions
// 
// 1. As Administrator at PowerShell command prompt issue command: 
// 
//     Install-Module -Name Posh-SSH 
//
// Alternate Installation Instructions
//
// 1. Download zip from https://github.com/darkoperator/Posh-SSH/releases
// 2. Right-click to ensure Windows isn't blocking the file (General tab)
// 3. Unzip it on your TPP server
// 4. Move the folder to C:\Program Files\WindowsPowerShell\Modules 
// 5. Rename the directory to "Posh-SSH"
//---------------------------------------------------------------------------

<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Policyable
Bit 3 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text1|Not Used|000
Text2|Not Used|000
Text3|Not Used|000
Text4|Not Used|000
Text5|Not Used|000
Option1|Not Used|000
Option2|Not Used|000
Passwd|Not Used|000
-----END FIELD DEFINITIONS-----
#>

Import-Module -Name Posh-SSH
if ((Get-Module -Name "Posh-SSH") -eq $null)
{
    throw "Posh-SSH failed to import"
}

$_gimo_version = "v0.9.2"

# GV-OS asset name length limitation
$asset_name_limit = 40

# Knob to introduce more/less delay in certain areas
$timing_factor = 1.0

if ($TEST_DRIVER -eq $true)
{
    $global:debug_log = $VENDOR_DEBUG_FILE
}
else
{
    $global:debug_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\Gigamon-debug.log"
}

<######################################################################################################################
.NAME
    Install-Chain
.DESCRIPTION
    Installs the certificate chain (as well as individual certificate) on the hosting platform.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        AssetName : the name (alias) to be used when installing this chain

.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        ChainPem : all chain certificates concatentated together one after the other

.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################>
function Install-Chain
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


<######################################################################################################################
.NAME
    Install-PrivateKey
.DESCRIPTION
    Installs the private key on the hosting platform.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        AssetName : the name (alias) to be used when installing this private key

.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        PrivKeyPem : the non-encrypted private key in RSA Base64 PEM format
        PrivKeyPemEncrypted : the password encrypted private key in RSA Base64 PEM format
        EncryptPass : the string password that was used to encrypt the private key and PKCS#12 keystore

.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
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
    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    return @{ Result="NotUsed" }
}


<######################################################################################################################
.NAME
    Install-Certificate
.DESCRIPTION
    Installs the certificate and optionally the private key on the hosting platform. Certificate is installed first.
    If key install fails after certificate install, certificate will be removed and an error is thrown.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        AssetName : the name (alias) to be used when installing this certificate/chain and private key
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        CertPem : the X509 certificate to be provisioned in Base64 PEM format
        PrivKeyPem : the non-encrypted private key in RSA Base64 PEM format
        PrivKeyPemEncrypted : the password encrypted private key in RSA Base64 PEM format
        ChainPem : all chain certificates concatentated together one after the other
        EncryptPass : the string password that was used to encrypt the private key and PKCS#12 keystore
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
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
    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    $certpem = $Specific.CertPem + $Specific.ChainPem
    $certpem = $certpem -replace "(?m)^\s*\r?\n","" # remove blank lines
    $certpem = $certpem -replace "`r`n","`n" # remove carriage returns (i.e. convert windows newlines to linux)

    $certname = Transform-Asset-Name( $General.AssetName )
    $keypass = $Specific.EncryptPass 
    if ($keypass.Length -gt 0)
    {
        $keypem = $Specific.PrivKeyPemEncrypted
    }
    else
    {
        $keypem = $Specific.PrivKeyPem
    }
    $keypem = $keypem -replace "`r`n","`n" # remove carriage returns

    if ( $certpem -and $certname)
    {
        $session = New-CLI-Session -HostAddress $General.HostAddress -TcpPort $General.TcpPort -UserName $General.UserName -UserPass $General.UserPass
        $stream = New-CLI-Stream -SessionId $session.SessionId 

        $response = Install-Certificate-CLI $stream $certname $certpem 
        $exitcode = $response.ExitStatus

        if ( $exitcode -ne 0 )
        {
            Remove-SSHSession -SSHSession $session | Out-Null
            throw "INSTALL-CERTIFICATE: FAILURE INSTALLING CERTIFICATE ON TARGET"
        }

        if ($keypem.Length -gt 0) 
        {
            # install private key
            $response = Install-PrivateKey-CLI $stream $certname $keypem $keypass
            $exitcode = $response.ExitStatus

            if ( $exitcode -ne 0 )
            {
                Remove-Certificate-CLI $stream $certname 
                Remove-SSHSession -SSHSession $session | Out-Null
                throw "INSTALL-CERTIFICATE: FAILURE INSTALLING PRIVATE KEY ON TARGET"
            }
            Remove-SSHSession -SSHSession $session | Out-Null
        }

        return @{ Result="Success"; AssetName=$certname }
    }
    else
    {
        throw "INSTALL-CERTIFICATE: NAME OR PEM NOT PROVIDED"        
        return @{ Result="Error"; AssetName = $certname }
    }

    return @{ Result="NotUsed" }
}


<######################################################################################################################
.NAME
    Update-Binding
.DESCRIPTION
    Binds the installed certificate with the consuming application or service on the hosting platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Install-Chain)
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
    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General
    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Activate-Certificate
.DESCRIPTION
    Performs any post-installation operations necessary to make the certificate active (such as restarting a service)
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Install-Chain)
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
    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General 

    $actname = Transform-Asset-Name( $General.AssetName )

    if ( $actname )
    {
        $session = New-CLI-Session -HostAddress $General.HostAddress -TcpPort $General.TcpPort -UserName $General.UserName -UserPass $General.UserPass
        $stream = New-CLI-Stream -SessionId $session.SessionId 

        $response = Activate-Certificate-CLI $stream $actname 
        $exitcode = $response.ExitStatus

        Remove-SSHSession -SSHSession $session | Out-Null

        if ( $exitcode -ne 0 )
        {
            throw "ACTIVATE-CERTIFICATE: CERTIFICATE COULD NOT BE ACTIVATED ON TARGET"
        }

        return @{ Result="Success" }

    }
    else
    {
        throw "ACTIVATE-CERTIFICATE: NAME NOT PROVIDED"        
    }

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Extract-Certificate
.DESCRIPTION
    Extracts the active certificate from the hosting platform.  If the platform does not provide a method for exporting the
    raw certificate then it is sufficient to return only the Serial and Thumprint.  This function is REQUIRED.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Install-Chain)
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
    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General 

    $extname = Transform-Asset-Name( $General.AssetName )

    if ( $extname )
    {
        $session = New-CLI-Session -HostAddress $General.HostAddress -TcpPort $General.TcpPort -UserName $General.UserName -UserPass $General.UserPass
        $stream = New-CLI-Stream -SessionId $session.SessionId 

        $response = Extract-Certificate-CLI $stream $extname 
        $exitcode = $response.ExitStatus

        Remove-SSHSession -SSHSession $session | Out-Null

        if ( $exitcode -ne 0 )
        {
            throw "EXTRACT-CERTIFICATE: CERTIFICATE COULD NOT BE EXTRACTED ON TARGET"
        }

        return @{ Result="Success"; CertPem = $response.PEM; Serial=$response.Serial; Thumbprint=$response.Thumbprint }

    }
    else
    {
        throw "EXTRACT-CERTIFICATE: NAME NOT PROVIDED"        
    }

    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Extract-PrivateKey
.DESCRIPTION
    Extracts the private key associated with the certificate from the hosting platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Install-Chain)
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
    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
    return @{ Result="NotUsed"; }
}


<######################################################################################################################
.NAME
    Remove-Certificate
.DESCRIPTION
    Removes an existing certificate (or private key) from the device.  Only implement the body of
    this function if TPP can/should remove old generations of the same asset.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Install-Chain)
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
    Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific

    $remname = Transform-Asset-Name( $Specific.AssetNameOld )

    if ( $remname )
    {
        $session = New-CLI-Session -HostAddress $General.HostAddress -TcpPort $General.TcpPort -UserName $General.UserName -UserPass $General.UserPass
        $stream = New-CLI-Stream -SessionId $session.SessionId 

        $response = Remove-Certificate-CLI $stream $remname 
        $exitcode = $response.ExitStatus

        Remove-SSHSession -SSHSession $session | Out-Null

        if ( $exitcode -ne 0 )
        {
            throw "REMOVE-CERTIFICATE: CERTIFICATE COULD NOT BE REMOVED ON TARGET"
        }

        return @{ Result="Success" }

    }
    else
    {
        throw "REMOVE-CERTIFICATE: NAME NOT PROVIDED"        
    }

    return @{ Result="NotUsed"; }
}


<###################### THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ######################>

#
# GigaVUE-OS command line interface does not support Unix mode SSH. As such, the Invoke-SSHCommand style of commands 
# provided by Posh-SSH do not work. The command line interface requires the creation of a session followed by the creation 
# of an SSH Shell Stream and associated command and response handling.   
#

function New-CLI-Session
{
    Param(
        [OutputType([SSH.SshSession])]
        [Parameter(Mandatory=$true,HelpMessage="Host Address")]
        [String]$HostAddress,
        [Parameter(Mandatory=$true,HelpMessage="TCP Port")]
        [System.Int32]$TcpPort,
        [Parameter(Mandatory=$true,HelpMessage="UserName")]
        [System.String]$UserName,
        [Parameter(Mandatory=$true,HelpMessage="UserPass")]
        [System.String]$UserPass
    )

    Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text "I: Creating SSH Connection"

	$pwd = ConvertTo-SecureString $UserPass -AsPlainText -Force
	$creds = New-Object System.Management.Automation.PSCredential($UserName, $pwd)
    $session = $null

    $session = New-SSHSession -ComputerName $HostAddress -Port $TcpPort -Credential $creds -Force #-AcceptKey -Verbose -WarningAction SilentlyContinue 
    if ($session -eq $null -or $session.Connected -ne $true)
    {
        Out-Log-Vendor-Buf -vendor_text "E: SSH Connection failed."
        throw "New-CLI-Session: Can't create SSH session"
    }
   
    Out-Log-Vendor-Buf -vendor_text "I: SSH Connection Successful"
    Out-Log-Vendor-Buf -vendor_text $session | Format-Table -AutoSize
    #detailed SSH session info if required
    #$buf = $session.session.ConnectionInfo 
    #Out-Log-Vendor-Buf -vendor_text $buf

    return $session
}

function New-CLI-Stream
{
    Param(
        [OutputType([Renci.SshNet.ShellStream])]
        [Parameter(Mandatory=$true,HelpMessage="SSH Session ID")]
        [System.Int32]$SessionId 
    )
	
    Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text "I: Creating SSH Stream"

    $msg ="E: Unknown state"
    $SSHstream = $null

	$SSHstream = New-SSHShellStream -Index $SessionId -Rows 1024 -BufferSize 8192
    if ($SSHstream)
    {
        Out-Log-Vendor-Buf -vendor_text "D: ## Opened Stream - logging on to target"

	    # After initially connecting, it can take a few seconds for CLI to give ready prompt. Specify null cmd and wait for prompt
        if ((Invoke-CLI-Command $SSHstream "" ">" "" "").Status -eq $true)
        {   
            Out-Log-Vendor-Buf -vendor_text "D: ## System Ready"
            if ((Invoke-CLI-Command $SSHstream "enable" "#" "" "").Status -eq $true)
            {
                Out-Log-Vendor-Buf -vendor_text "D: ## Enable Mode"
                if ((Invoke-CLI-Command $SSHstream "config term" "(config) #" "" "").Status -eq $true)
                {
                   Out-Log-Vendor-Buf -vendor_text "D: ## Config Mode"
                   $msg = "I: SSH stream creation and target logon Successful"
                }
                else
                {
                    $msg = "E: Config Mode failed"
                }
            }
            else
            {
                $msg = "E: Enable Mode failed"
            }
        }
        else
        {
            $msg = "E: No prompt from target"
        }
    }
    else
    {
        Out-Log-Vendor-Buf -vendor_text "E: SSH stream creation failed."
        throw "New-CLI-Stream: Can't open SSH Stream"
    }
    Out-Log-Vendor-Buf -vendor_text $msg 
    Out-Log-Vendor-Buf -vendor_text $SSHstream | Format-Table -AutoSize
    return $SSHstream
}

function Invoke-CLI-Command ([Renci.SshNet.ShellStream]$SSHstream, [System.String]$cmd, [System.String]$prompt, [System.String]$match, [System.String]$errtext)
{
    Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ("D: Command Len="+$cmd.Length+" Text="+$cmd)

    # send command and poll for response every $pause ms for up to $tries times
    $pause = 1 # milliseconds
    $tries = 10000  # up to 10 seconds
    $out = ""
    $success = $false

    if ($cmd.Length -gt 0)
    {
        $SSHstream.WriteLine($cmd)
    }

	do {
		Start-Sleep -Milliseconds $pause 
		$Result = $SSHstream.Read()
        if ($Result.Length -gt 0) 
        {
            $out += $Result
            # if response contains prompt, it's finished
            if ($out.EndsWith($prompt+" ")) 
            {
                # if response contains errtext it's a failure
                if (($errtext.Length -gt 0) -and ($out.Contains($errtext) -eq $true))
                {
                    break
                }
                # if match text specified, ensure the response contains it
                if ($match.Length -gt 0)
                {
                    if ($out.Contains($match) -eq $true)
                    {
                        $success = $true
                        break
                    }
                    #otherwise match was specificed but not found so no success
                    break
                }
                # otherwise just the prompt indicates success
                $success = $true
                break
            }
        }
	} until (--$tries -eq 0)

    Out-Log-Vendor-Buf -vendor_text ("D: Response Len="+$out.Length+" Text=`n"+$out)
    Out-Log-Vendor-Buf -vendor_text ("D: ## Tries remaining:"+$tries)

    if ($success -eq $false)  
    {
        Out-Log-Vendor-Buf -vendor_text "E: SSH Invoke Command failed."
    }
    else
    {
        Out-Log-Vendor-Buf -vendor_text "I: SSH Invoke Command success."
    }
    return @{ Status=$success; Text=$out }
}

#
# Core routines to carry out the specific Gigamon CLI operations
#

function Install-Certificate-CLI ([Renci.SshNet.ShellStream]$SSHstream, [System.String]$alias, [System.Object]$certdata)
{
    Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ""

    $stream = $SSHstream
    $cmd = "crypto certificate name "+$alias+" public-cert pem "+'"'
    $term = '"'

    $success = Invoke-CLI-Command $stream $cmd ">" "" "%"
    if ($success.Status -eq $true)
    {
        foreach ($line in $certdata)
        {
            $success = Invoke-CLI-Command $stream $line ">" "" "%"
            if ($success.Status -ne $true) { break }
            # introduce a brief pause between PEM lines to prevent potential character loss due to slower systems
            Start-Sleep -Milliseconds (10 * $timing_factor)
        }
        if ($success.Status -eq $true)
        {
            $success = Invoke-CLI-Command $stream $term "#" "Successfully installed certificate" "%"
            # There is a case where the cert gets installed but CLI returns warning message with '%' character making it seem like an error
            # If status doesn't come back true, query cert by name to determine if it is actually installed  
            if ($success.Status -ne $true) 
            { 
                # next 3 lines borrowed from Extract-Certificate-CLI
                $cmd = "show crypto certificate name "+$alias
                $success = Invoke-CLI-Command $stream $cmd "#" "" "%"
            }
        }
    }

    if ($success.Status -ne $true) { return @{ ExitStatus = 1 } }
    return @{ ExitStatus = 0 } 
}

function Install-PrivateKey-CLI ([Renci.SshNet.ShellStream]$SSHstream, [System.String]$alias, [System.Object]$keydata, [System.String]$keypassword)
{
    Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ""

    $stream = $SSHstream
    $cmd = "crypto certificate name "+$alias+" private-key pem "+'"'
    $term = '"'

    $success = Invoke-CLI-Command $stream $cmd ">" "" "%"

    if ($success.Status -eq $true)
    {
        foreach ($line in $keydata)
        {
            $success = Invoke-CLI-Command $stream $line ">" "" "%"
            if ($success.Status -ne $true) { break }
            # introduce a brief pause between PEM lines to prevent potential character loss due to slower systems
            Start-Sleep -Milliseconds (10 * $timing_factor)
        }
        if ($success.Status -eq $true)
        {
            $success = Invoke-CLI-Command $stream $term ":" "Enter private key passphrase" "%"
            if ($success.Status -eq $true)
            {
                if ($keypassword.Length -gt 0)
                {
                    $success = Invoke-CLI-Command $stream $keypassword "#" "" "%"
                }
                else
                {
                    $success = Invoke-CLI-Command $stream "`n" "#" "" "%"
                }
            }
        }
    }
    if ($success.Status -ne $true) { return @{ ExitStatus = 1 } }
    return @{ ExitStatus = 0 } 
}

function Activate-Certificate-CLI ([Renci.SshNet.ShellStream]$SSHstream, [System.String]$alias)
{
    Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ""

    $stream = $SSHstream
    $cmd = "web https certificate name "+$alias
    $success = Invoke-CLI-Command $stream $cmd "#" "" "%"
    if ($success.Status -ne $true) { return @{ ExitStatus = 1 } }
    # if a private key doesn't exist there isn't an error with "%" but a long warning/error message. Check for that
    if ($Success.Text.Length - $cmd.Length -gt 150)
    {
        return @{ ExitStatus = 1 } 
    }
    # last step is to save config to make active cert persistent
    $cmd = "write mem"
    $success = Invoke-CLI-Command $stream $cmd "#" "" "%"
    if ($success.Status -ne $true) { 
        Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ("E: Config save failed")
        return @{ ExitStatus = 1 } 
    } 
    return @{ ExitStatus = 0 } 
}

function Extract-Certificate-CLI ([Renci.SshNet.ShellStream]$SSHstream, [System.String]$alias)
{
    Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ""

    $stream = $SSHstream
    $cmd = "show crypto certificate name "+$alias
    $success = Invoke-CLI-Command $stream $cmd "#" "" "%"
    if ($success.Status -ne $true) { return @{ ExitStatus = 1 } }

    $sp = ($success.Text).split("`n")
    $Serial = ((($sp | Select-String("Serial Number:"))[0])  -split ':' )[1].trim()
    $Fingerprint = ((($sp | Select-String("FIngerprint:"))[0])  -split ':' )[1].trim()

    # The PEM output dumps ALL certificates, not by specific name
    # Need to find and extract the one of interest

    $cmd = "show crypto certificate public-pem"
    $success = Invoke-CLI-Command $stream $cmd "#" "" "%"
    if ($success.Status -ne $true) { return @{ ExitStatus = 1 } }
    
    $i = $success.Text.IndexOf($alias)
    $buffer = $success.Text.Substring($i) 

    $header = "-----BEGIN CERTIFICATE-----"
    $footer = "-----END CERTIFICATE-----"

    $begin = $buffer.IndexOf($header)
    $end = $buffer.IndexOf($footer) - $begin + $footer.Length

    $pem = $buffer.Substring($begin, $end)

    return @{ ExitStatus = 0; PEM = $pem; Serial=$Serial; Thumbprint=$Fingerprint } 
}

function Remove-Certificate-CLI ([Renci.SshNet.ShellStream]$SSHstream, [System.String]$alias)
{
    Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ""

    if ($alias -like "system-self-signed") 
    {
        Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ("E: Not allowed to delete this certificate: "+$alias)
        return @{ ExitStatus = 1 }
    }
    $stream = $SSHstream
    $cmd = "no crypto certificate name "+$alias
    #$success = Invoke-CLI-Command $stream $cmd "#" "Reverting to" "%"
    $success = Invoke-CLI-Command $stream $cmd "#" "" "%"
    if ($success.Status -ne $true) { return @{ ExitStatus = 1 } }
    # after removing cert, system may revert to default cert
    # last step is to save config to make active cert persistent
    $cmd = "write mem"
    $success = Invoke-CLI-Command $stream $cmd "#" "" "%"
    if ($success.Status -ne $true) { 
        Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ("E: Config save failed")
        return @{ ExitStatus = 1 } 
    } 
    return @{ ExitStatus = 0 } 
}

function Transform-Asset-Name ([System.String]$asset_name)
{
    $new_asset_name = $asset_name
    if ($asset_name.length -gt $asset_name_limit)
    {
        $name_parts = $asset_name.Split('.');
        $new_asset_name = $name_parts[0]+'.'+$name_parts[$name_parts.Count-1] 
        Out-Log-Vendor -nm_func $MyInvocation.MyCommand.Name -vendor_text ("I: AssetName transformed to "+$new_asset_name)
    }
    return $new_asset_name
}


#
# Debug support
#

function Out-Log-Vendor ( $nm_func, $vendor_text ) 
{
    if ( $DEBUG_FILE -and $global:debug_log)
    {
        $buf = "`r`n[{0}] {1}" -f $nm_func,$("."*(100-$nm_func.Length))
        $buf += "`n`n##### VENDOR SPECIFIC LOGGING " + $_gimo_version + " " + $(date) + " #####`n"
        $buf += $vendor_text -replace "`r`n`r`n","`r`n" #get rid of double newlines
        $buf | Out-File $global:debug_log -Append
    }
}

function Out-Log-Vendor-Buf ( $vendor_text ) 
{
    if ( $DEBUG_FILE -and $global:debug_log)
    {
        $vendor_text | Out-File $global:debug_log -Append
    }
}

#
# Debug support software provided by Venafi
#

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

function Show-Vars ( $name, $value )
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

#
# END OF FILE
#