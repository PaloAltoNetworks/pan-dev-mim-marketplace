<#
//-----------------------------------------------------------------------
// Oracle HTTP Server.ps1
//-----------------------------------------------------------------------
//
// This software is licensed by Samara-Tech, in addition to Venafi.
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
Text1|Remote Wallet Path|111
Text2|OHS Instance Bin|111
Text3|walletname|111
Text4|OHS Component|111
Text5|OHS Version(11g/12c)|111
Option1|Restart OHS Server|111
Option2|Sudouser?|111
Passwd|Wallet Credential|111
-----END FIELD DEFINITIONS-----
#>
$base_path = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs"
$WarningPreference = "SilentlyContinue"
Try # to write to the directory
{ 
    $temp_file = $base_path + "\_verify_access"
    [IO.File]::OpenWrite($temp_file).Close() 
    [IO.File]::Delete($temp_file)
}
Catch 
{ 
    $base_path = (Get-Location).Path
}

$global:file_prefix = $base_path + "\AdaptableAppDebug_"
$global:temp_dir = $base_path + "\Temp"
$orapki = 'C:\Oracle\Middleware\Oracle_Home\oracle_common\bin\orapki.bat'

If ( !(Test-Path $global:temp_dir) )
{
   New-Item $global:temp_dir -Type Directory
}
$pem_prefix = "-----BEGIN CERTIFICATE-----"
$pem_suffix = "-----END CERTIFICATE-----"
if (-not $DEBUG_FILE) 
{ 
  $logFilePath = $global:temp_dir
  $today = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
  $logFileName = "/log" + $today + ".txt"
  $DEBUG_FILE = $logFilePath + $logFileName
}
Import-Module -Name Posh-SSH
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
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
        AppObjectDN : a string containing the TPP distiguished name of the calling application object
        AssetName : a string containing a Venafi standard auto-generated name that can be used for provisioning (<Common Name>-<ValidTo as YYMMDD>-<Last 4 of SerialNum>)
        VarText1 : a string value for the text custom field defined by the header at the top of this script
        Var$General.VarPass : a string value for the text custom field defined by the header at the top of this script
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

    $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"

    "`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
 
    "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    
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
        $Specific.KeySize : the integer key size to be used when creating a key pair
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed
##################################################################################################>
function Generate-KeyPair
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"

    "`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
 
    "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    
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
        $Specific.KeySize : the integer key size to be used when creating a key pair
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs10 : a string representation of the CSR in PKCS#10 format
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed
##################################################################################################>
function Generate-CSR
{
Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
Try {
"In Generate-CSR Method " | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$subject_dn = ""
	$subject_dn | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    if ( $Specific.SubjectDn.CN ){$subject_dn += "CN=" + $Specific.SubjectDn.CN}
	$subject_dn | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    if ( $Specific.SubjectDn.OU )
    {
        foreach ( $ou in $Specific.SubjectDn.OU ){$subject_dn += ",OU=" + $ou}
    }
    if ( $Specific.SubjectDn.O ){$subject_dn += ",O=" + $Specific.SubjectDn.O}
    if ( $Specific.SubjectDn.L ){$subject_dn += ",L=" + $Specific.SubjectDn.L}
	if ( $Specific.SubjectDn.ST ){$subject_dn += ",ST=" + $Specific.SubjectDn.ST}
    if ( $Specific.SubjectDn.C ){$subject_dn += ",C=" + $Specific.SubjectDn.C}
	$Dname="`"$subject_dn`""
	$logFilePath = $global:temp_dir
	$basename = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
	$hostname = $General.HostAddress
	$walletpass = $General.VarPass
	$walletname = $General.VarText3
	$keysize = $Specific.KeySize
	$walletloc = $logFilePath + "\$walletname"
	$walletbackup = $logFilePath + "\" + $walletname + "_bkp" + $basename
	$csrname =$walletloc + "\" + $hostname + $basename + ".csr"
	$walletfile = $walletloc + "\wallet.txt"
	Move-item $walletloc $walletbackup -Force
	Remove-Item $walletbackup -Recurse -Force
	$createWallet = Invoke-Expression "$orapki wallet create -wallet '$walletloc' -auto_login -pwd $walletpass"
	$createWallet | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$createWalletStat = Validate-CommandOutput -output $createWallet -success "Oracle" -failure1 "Invalid password" -failure2 ""
    if($createWalletStat -notlike "S"){
        $error = "Generate-CSR: Error: " + $createWalletStat + ". `r`n" + $createWallet 
        $error | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
        return @{ Result="Failure" }
    }
	$removeCert = Invoke-Expression "$orapki wallet remove -trusted_cert_all -wallet '$walletloc' -pwd $walletpass"
	$removeCert | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$removeCertStat = Validate-CommandOutput -output $removeCert -success "Oracle" -failure1 "Invalid password" -failure2 ""
    if($removeCertStat -notlike "S"){
        $error = "Generate-CSR: Error: " + $removeCertStat + ". `r`n" + $removeCert
        $error | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
       return @{ Result="Failure" }
    }
	$addWallet = Invoke-Expression "$orapki wallet add -wallet '$walletloc' -dn $Dname -keysize $keysize -pwd $walletpass"
	$addWallet | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$addWalletStat = Validate-CommandOutput -output $addWallet -success "Oracle" -failure1 "PKI-07008" -failure2 "PKI-07010"
    if($addWalletStat -notlike "S"){
        $error = "Generate-CSR: Error: " + $addWalletStat + ". `r`n" + $addWallet
        $error | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
        return @{ Result="Failure" }
    }
	$exportWallet = Invoke-Expression "$orapki wallet export -wallet '$walletloc' -dn $Dname -pwd $walletpass -request '$csrname'"
	$exportWallet | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$exportWalletStat = Validate-CommandOutput -output $exportWallet -success "Oracle" -failure1 "" -failure2 ""
	if($exportWalletStat -notlike "S"){
        $error = "Generate-CSR: Error: " + $exportWallet
        $error | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
        return @{ Result="Failure" }
    }
	$displayWallet = Invoke-Expression "$orapki wallet display -wallet '$walletloc' -pwd $walletpass" > $walletfile
	$displayWallet | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	if($displayWallet.Output -like "*null*"){
        $error = "Generate-CSR: Error: Error while displaying Wallet" + ". `r`n" + $displayWallet 
        $error | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
        return @{ Result="Failure" }
    }
	$tmp = New-TemporaryFile
	$tmp.FullName
	$content1 = Invoke-Expression "type '$csrname'" > $tmp.FullName
    $content = [IO.File]::ReadAllText($tmp.FullName)
	Remove-Item $tmp.FullName
	$name = (Get-Date).ToUniversalTime().ToString("yyMMdd-HHmmss")
    $name = "adaptable.venafi.example_" + $name
	return @{ Result="Success"; Pkcs10=$content; AssetName=$Specific["Dname"] }
}
Catch{
        $ErrorMessage = "Generate-CSR: Error: " + $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $ErrorMessage | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
		$line = $_.InvocationInfo.ScriptLineNumber
		"Line number is $line" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
        Break
    }
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
	"In Install-Chain Function" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    if ( $Specific.ChainPkcs7 )
    {
		$chain = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
		$chain.Import( $Specific.ChainPkcs7 )
		$logFilePath = $global:temp_dir
		$walletpass = $General.VarPass
		$walletname = $General.VarText3
		$walletloc = $logFilePath + "\$walletname"
		$name = Get-CACertName($cert)
		$tmp = New-TemporaryFile
		$tmp.FullName
		$rootcer = $walletloc + "\root.cer"
		$walletChain = $walletloc + "\walletChain.txt"
		foreach ( $cert in $chain )
		{
			$walletpass = $General.VarPass
			$walletname = $General.VarText3
			$walletloc = $logFilePath + "\$walletname"
			$name = Get-CACertName($cert)
			$tmp = New-TemporaryFile
			$tmp.FullName
			$rootcer = $walletloc + "\root.cer"
			$walletChain = $walletloc + "\walletChain.txt"
			$b64 = [Convert]::ToBase64String($cert.RawData, [Base64FormattingOptions]::InsertLineBreaks)
			$b64 = "-----BEGIN CERTIFICATE-----`n" + $b64 + "`n-----END CERTIFICATE-----"
			$b64 | Out-File $tmp.FullName
			$content = [IO.File]::ReadAllText($tmp.FullName)
			Add-Content $rootcer $content
			$RootInstall = Invoke-Expression "$orapki wallet add -wallet '$walletloc' -trusted_cert -cert '$rootcer' -pwd $walletpass"
			$RootInstall | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$startStat = Validate-CommandOutput -output $RootInstall -success "Oracle" -failure1 "" -failure2 ""
			if($startStat -notlike "S")
			{
				"Install-Chain: Trusted Certificate failed to install" + $RootInstall | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
				return @{ Result="Failure"; }
			}
			Remove-Item $tmp.FullName
			Remove-Item $rootcer
		}
	}
	Invoke-Expression "$orapki wallet display -wallet '$walletloc' -pwd $walletpass" > $walletChain
    return @{ Result="Success"; }
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
        AssetName : (optional) the base name used to reference the private key as it was installed on the device; if not supplied the auto-generated name is assumed
##################################################################################################>
function Install-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    
    $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    $basename = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")

    "`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
 
    "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append

    if ( $Specific.EncryptPass )
    {
        $Specific.PrivKeyPemEncrypted | Out-File $($global:temp_dir + "\" + $basename + ".key")
    }
    else
    {
        $Specific.PrivKeyPem | Out-File $($global:temp_dir + "\" + $basename + ".key")
    }

    return @{ Result="NotUsed"}
}
<##################################################################################################
.NAME
    Copying-Cert
.DESCRIPTION
    Copies the generated wallet to target Oracle HTTP server
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
        AppObjectDN : a string containing the TPP distiguished name of the calling application object
        VarText1 : a string value for the text custom field defined by the header at the top of this script
        Var$General.VarPass : a string value for the text custom field defined by the header at the top of this script
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
function Copying-Cert($General)
{	
	$comp = $General.HostAddress
	$envType = Check-Environment($General)
	$deviceusername = $General.UserName
	$devicepasswd = $General.UserPass
	$walletpass = $General.VarPass
	$walletname = $General.VarText3
	$ohsuser = $General.VarText4
	$logFilePath = $global:temp_dir
	$basename = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
	$walletloc = $logFilePath + "\$walletname"
	$walloc = $General.VarText1
	$wallocbackup = $General.VarText1 + $basename
	$sudouser = $General.VarBool2
	$tmpsrv = "/tmp/"
	$tmpfolder = $tmpsrv + $walletname
	if($envType -notlike "Windows")
	{
		#find user and group of target directory
		$walletparentpath = Split-Path -Path $walloc
		$walletparentpath = $walletparentpath.Replace('\','/')
		$walletparentpath
		$user = Invoke-SSHPRIV-Command "sudo stat -c '%U' $walletparentpath"
		$group = Invoke-SSHPRIV-Command "sudo stat -c '%G' $walletparentpath"
		if($sudouser.equals("true"))
		{
			if($General.UserPrivKey )
			{
				# Posh-SSH requires the private key to be in a file :(
				$auth_key = $temp_dir + "\auth"
				$General.UserPrivKey | Out-File $auth_key
				# SSH key passed to function will never be password encrypted
				$passwd = New-Object System.Security.SecureString
				$credentials = New-Object System.Management.Automation.PSCredential($deviceusername, $passwd)
				New-SSHSession -ComputerName $comp -Credential $credentials -KeyFile $auth_key -Force
				$sshseid = Get-SshSession | select SessionId
				$sshseid | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
				Try{
				Set-SCPFolder -Computername $comp -credential $credentials -KeyFile $auth_key -LocalFolder $walletloc -RemoteFolder $tmpfolder -Force
				}
				Catch{
					$ErrorMessage = "Copying-Cert: Error: Failed to Copy the wallet " + $_.Exception.Message
					$FailedItem = $_.Exception.ItemName
					$ErrorMessage | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
				}
				$addpermission = Invoke-SshCommand -Command "chmod -R 755 $tmpfolder" -SessionId $sshseid.SessionId
				if($addpermission.ExitStatus -ne "0")
				{
					"Changing permissions to wallet failed with $addpermission" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
					throw "Changing permissions to wallet failed with $addpermission"
				}
				else{
					"Permissions for wallet under temp directory changed successfully" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
				}
				Invoke-SSHPRIV-Command "sudo mv $walloc $wallocbackup"
				Invoke-SSHPRIV-Command "sudo chown -R '$user':'$group' $wallocbackup"
				Invoke-SSHPRIV-Command "sudo cp -r $tmpfolder $walloc"
				Invoke-SSHPRIV-Command "sudo chown -R '$user':'$group' $walloc"
				Invoke-SSHPRIV-Command "sudo rm -r $tmpfolder"
			}
			else	# username/password auth
			{
				$sdevicepasswd = ConvertTo-SecureString -String $devicepasswd -AsPlainText -Force
				$credentials = New-Object System.Management.Automation.PSCredential($deviceusername, $sdevicepasswd)
				New-SshSession -Computername $comp -credential $credentials -Force
				$sshseid = Get-SshSession | select SessionId
				Try{
				Set-SCPFolder -Computername $comp -credential $credentials -LocalFolder $walletloc -RemoteFolder $tmpfolder -Force
				}
				Catch{
					$ErrorMessage = "Copying-Cert: Error: Failed to Copy the wallet " + $_.Exception.Message
					$FailedItem = $_.Exception.ItemName
					$ErrorMessage | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
				}
				$addpermission = Invoke-SshCommand -Command "chmod -R 755 $tmpfolder" -SessionId $sshseid.SessionId
				if($addpermission.ExitStatus -ne "0")
				{
					"Changing permissions to wallet failed with $addpermission" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
					throw "Changing permissions to wallet failed with $addpermission"
				}
				else{
					"Permissions for wallet under temp directory changed successfully" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
				}
				Invoke-SSHPRIV-Command "sudo mv $walloc $wallocbackup"
				Invoke-SSHPRIV-Command "sudo chown -R '$user':'$group' $wallocbackup"
				Invoke-SSHPRIV-Command "sudo cp -r $tmpfolder $walloc"
				Invoke-SSHPRIV-Command "sudo chown -R '$user':'$group' $walloc"
				Invoke-SSHPRIV-Command "sudo rm -r $tmpfolder"
			}
		}
		else
		{
			if ( $General.UserPrivKey )
			{
				# Posh-SSH requires the private key to be in a file :(
				$auth_key = $temp_dir + "\auth"
				$General.UserPrivKey | Out-File $auth_key
				# SSH key passed to function will never be password encrypted
				$passwd = New-Object System.Security.SecureString
				$credentials = New-Object System.Management.Automation.PSCredential($deviceusername, $passwd)
				New-SSHSession -ComputerName $comp -Credential $credentials -KeyFile $auth_key -Force
				$sshseid = Get-SshSession | select SessionId
				Invoke-SshCommand -Command "mv $walloc $wallocbackup" -SessionId $sshseid.SessionId
				Set-SCPFolder -Computername $comp -Credential $credentials -KeyFile $auth_key -LocalFolder $walletloc -RemoteFolder $walloc -Force
			}
			else
			{
				$sdevicepasswd = ConvertTo-SecureString -String $devicepasswd -AsPlainText -Force
				$credentials = New-Object System.Management.Automation.PSCredential($deviceusername, $sdevicepasswd)
				New-SshSession -Computername $comp -credential $credentials -Force
				$sshseid = Get-SshSession | select SessionId
				Invoke-SshCommand -Command "mv $walloc $wallocbackup" -SessionId $sshseid.SessionId
				Set-SCPFolder -Computername $comp -Credential $credentials -LocalFolder $walletloc -RemoteFolder $walloc -Force
			}
		}
		Remove-SshSession $sshseid.SessionId
	}
	else
	{
		$wsession = New-PSSession -ComputerName $comp -Credential $credentials
		Invoke-Command -Session $wsession -ScriptBlock { Move-Item -Path $($using:walloc) -Destination $($using:wallocbackup) }
		Copy-Item -Path $walletloc -Destination $walloc -ToSession $wsession -Recurse -Force
		Remove-PSSession -Session $wsession
	}
	return @{ Result="Success"; }
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
        AssetName : (optional) the base name used to reference the certificate as it was installed on the device; if not supplied the auto-generated name is assumed
##################################################################################################>
function Install-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
	"In Install-Certificate Function" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$tmp = New-TemporaryFile
	$tmp.FullName
	$logFilePath = $global:temp_dir
	$walletpass = $General.VarPass
	$walletname = $General.VarText3
	$walletloc = $logFilePath + "\$walletname"
	$usercer = $walletloc + "\user.crt"
	$walletUser=$walletloc + "\walletUser.txt"
	$file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    #"`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    #"`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    $Specific.CertPem | Out-File $tmp.FullName
	$content = [IO.File]::ReadAllText($tmp.FullName)
	Add-Content $usercer $content
	$CertInstall = Invoke-Expression "$orapki wallet add -wallet '$walletloc' -user_cert -cert '$usercer' -pwd $walletpass"
	$CertInstall | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$startStat    = Validate-CommandOutput -output $CertInstall -success "Oracle" -failure1 "" -failure2 ""
	if($startStat -notlike "S"){
		"Install-Certificate: User Certificate failed to install" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
		$CertInstall | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
		return @{ Result="Failure"; }
	}		
    [IO.File]::WriteAllBytes($global:temp_dir + "\" + $General.AssetName + ".p12", $Specific.Pkcs12)
	Invoke-Expression "$orapki wallet display -wallet '$walletloc' -pwd $walletpass" > $walletUser
	Remove-Item $tmp.FullName
	"calling copying function" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	Copying-Cert -General $General
	"Wallet sucessfully copied to the target system" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    return @{ Result="Success"; }
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
    
    $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"

    "`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
 
    "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    
    return @{ Result="NotUsed"; }
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
<########################OHS VARAIBLES###########################################>	
	$walloc = $General.VarText1
	$ohsver = $General.VarText5
	$dorestart = $General.VarBool1
	$ohsbin = $General.VarText2
	$sudouser = $General.VarBool2
	$paswd = $General.VarPass
	$comp=$General.HostAddress
	$ohscomponent = $General.VarText4
	$logFilePath = $global:temp_dir
	#start a new ssh session
	$devicepasswd = $General.UserPass
	$deviceusername = $General.UserName
	$ohsver | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
<########################OHS 12C Script###########################################>
	$ohs12cstart = $ohsbin + '/bin' + '/startComponent.sh'
	$ohs12cstop = $ohsbin + '/bin' + '/stopComponent.sh'
<########################OHS 11G Script###########################################>
	$ohs11gscrpt = $ohsbin + '/bin' + '/opmnctl'
<#####find user and group of target directory#####>
	$envType = Check-Environment($General)
	if($envType -notlike "Windows"){
	$user = Invoke-SSHPRIV-Command "sudo stat -c '%U' $walloc"
	$group = Invoke-SSHPRIV-Command "sudo stat -c '%G' $walloc"
	}
<###################################################################>
	if ($dorestart.equals("true")){
	if ($sudouser.equals("true")){
		if ($ohsver -eq "12c")
		{
			Write-Host "Inside 12c Block"
			$ohs12cstart | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$ohs12cstop | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$stopoutput = Invoke-SSHPRIV-Command "sudo -u $user $ohs12cstop $ohscomponent"
			$nodeStat  = Validate-CommandOutput -output $stopoutput -success "Successfully Connected to Node" -failure1 "" -failure2 ""
			if($nodeStat -notlike "S"){
			"Activate-Certificate: Error: Node Manager is not running/" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$nodeStat | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			return @{ Result="Failure"; }}
			$srvStat  = Validate-CommandOutput -output $stopoutput -success "Successfully killed server ohs1" -failure1 "" -failure2 ""
			if($srvStat -notlike "S"){
			"Activate-Certificate: Error: OHS Server is already down" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$srvStat | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}}
			<###START OHS###>
			$startoutput = Invoke-SSHPRIV-Command "sudo -u $user $ohs12cstart $ohscomponent"
			$startStat    = Validate-CommandOutput -output $startoutput -success "Successfully started server" -failure1 "" -failure2 ""
			if($startStat -notlike "S"){
			"Activate-Certificate: OHS component failed to start" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$startoutput | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			return @{ Result="Failure"; }}
		}
		else{
			<###STOP OHS###>
			$ohs11gscrpt | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$11gstop = Invoke-SSHPRIV-Command "sudo -u $user $ohs11gscrpt stopall"
			Start-Sleep -s 30
			$11gstop | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			<###START OHS###>
			$11gstart = Invoke-SSHPRIV-Command "sudo -u $user $ohs11gscrpt startall"
			Start-Sleep -s 30
			$11gstart | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			}
		}
	else{
	$devicepasswd = ConvertTo-SecureString -String $devicepasswd -AsPlainText -Force
	$creds = New-Object System.Management.Automation.PSCredential($deviceusername, $devicepasswd)
	New-SshSession -Computername $comp -credential $creds
	#get sessionid
	$sshseid =Get-SshSession | select SessionId
		if ($ohsver.equals("12c"))
		{
			Write-Host "Inside 12c Block"
			<###STOP OHS###>
			$ohs12cstart | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$ohs12cstop | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$stopoutput = Invoke-SshCommand -Command "$ohs12cstop $ohscomponent" -SessionId $sshseid.SessionId
			$commandOutput = $stopoutput.Output
			$nodeStat  = Validate-CommandOutput -output $stopoutput.Output -success "Successfully Connected to Node" -failure1 "" -failure2 ""
			Start-Sleep -s 15
			if($nodeStat -notlike "S"){
			$commandOutput | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			"Activate-Certificate: Error: Node Manager is not running/" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			return @{ Result="Failure"; }}
			$srvStat  = Validate-CommandOutput -output $stopoutput.Output -success "Successfully killed server ohs1" -failure1 "" -failure2 ""
			Start-Sleep -s 15
			if($srvStat -notlike "S"){
			"Activate-Certificate: Error: OHS Server is already down" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$commandOutput | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}}
			<###SLEEP###>
			Start-Sleep -s 60
			<###START OHS###>
			$startoutput = Invoke-SshCommand -Command "$ohs12cstart $ohscomponent" -SessionId $sshseid.SessionId
			$commandOutput = $startoutput.Output
			$startStat    = Validate-CommandOutput -output $startoutput.Output -success "Successfully started server" -failure1 "" -failure2 ""
			if($startStat -notlike "S"){
			"Activate-Certificate: OHS component failed to start" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$commandOutput | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			return @{ Result="Failure"; }}
		}
		else{
			<###STOP OHS###>
			$ohs11gscrpt | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			$11gstop = Invoke-SshCommand -Command "$ohs11gscrpt stopall" -SessionId $sshseid.SessionId
			Start-Sleep -s 30
			$11gstop | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			<###START OHS###>
			$11gstart = Invoke-SshCommand -Command "$ohs11gscrpt startall" -SessionId $sshseid.SessionId
			Start-Sleep -s 30
			$11gstart | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
			}
	#close the connection
	Remove-SshSession $sshseid.SessionId
	}
	}
    return @{ Result="Success"; }
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
	$walletloc = $General.VarText1
	$walletname = $General.VarText3
	$sudouser = $General.VarBool2
	$paswd = $General.VarPass
	$comp=$General.HostAddress
	#start a new ssh session
	$devicepasswd = $General.UserPass
	$deviceusername = $General.UserName
	$devicepasswd = ConvertTo-SecureString -String $devicepasswd -AsPlainText -Force
	$creds = New-Object System.Management.Automation.PSCredential($deviceusername, $devicepasswd)
	$envType = Check-Environment($General)
	if($envType -notlike "Windows"){
	if ($sudouser.equals("true")){
		$file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
		"`n##### GENERAL PARAMETERS #####" | Out-File $file
		$General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
		"`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
		$Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
		$tmp = New-TemporaryFile
		$tmp.FullName
		$usercert = $walletloc + "/" + "user.crt"
		$content = Invoke-SSHPRIV-Command "sudo cat $usercert"
		$content | Out-File $tmp.FullName
		$pem = Get-Content $($tmp.FullName) | Out-String
		$bytes = [Convert]::FromBase64String($pem.Replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----",""))
		$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
		$cert.Import($bytes)
		Remove-Item $tmp.FullName
		Write-Host $cert.NotAfter
		Write-Host $cert.SerialNumber
	}
	else{
	New-SshSession -Computername $comp -credential $creds -Force
	$sshseid =Get-SshSession | select SessionId
	$scpout=Get-SCPFolder -Computername $comp -credential $creds -LocalFolder "$tmp" -RemoteFolder $walletloc -Force
	$devicepasswd = ConvertTo-SecureString -String $devicepasswd -AsPlainText -Force
	$creds = New-Object System.Management.Automation.PSCredential($deviceusername, $devicepasswd)
	New-SshSession -Computername $comp -credential $creds
	#get sessionid
	$sshseid =Get-SshSession | select SessionId
    $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"
    "`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
    "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
	$tmp = New-TemporaryFile
	$tmp.FullName
	$usercert = $walletloc + "/" + "user.crt"
	$content = Invoke-SshCommand -Command "cat $usercert" -SessionId $sshseid.SessionId
	$content.Output | Out-File $tmp.FullName
	$pem = Get-Content $($tmp.FullName) | Out-String
	$bytes = [Convert]::FromBase64String($pem.Replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----",""))
	$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
	$cert.Import($bytes)
	Remove-Item $tmp.FullName
	Write-Host $cert.NotAfter
	Write-Host $cert.SerialNumber
###>
Remove-SshSession $sshseid.SessionId
}
    #return @{ Result="Success"; Serial="$($cert.SerialNumber)"; Thumprint="$($cert.Thumbprint)" }
	return @{ Result="Success"; Serial=$cert.SerialNumber; Thumbprint=$cert.Thumbprint }
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
    
	$walloc = $General.VarText1
	$privateKey = $walloc + 'b64pkey.pem'
	$ewallet = $walloc + 'ewallet.p12'
	$paswd = $General.VarPass
	$comp=$General.HostAddress
	#start a new ssh session
	$devicepasswd = $General.UserPass
	$deviceusername = $General.UserName
	$devicepasswd = ConvertTo-SecureString -String $devicepasswd -AsPlainText -Force
	$creds = New-Object System.Management.Automation.PSCredential($deviceusername, $devicepasswd)
	New-SshSession -Computername $comp -credential $creds
	#get sessionid
	$sshseid =Get-SshSession | select SessionId
    
    $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"

    "`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append

    "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
	
	Invoke-SshCommand -Command "openssl pkcs12 -in $ewallet -nocerts -passin pass:$paswd -passout pass:$paswd -out $privateKey -nodes" -SessionId $sshseid.SessionId
	$tmp = New-TemporaryFile
	$tmp.FullName
	$content = Invoke-SshCommand -Command "cat $privateKey" -SessionId $sshseid.SessionId
	$content.Output | Out-File $tmp.FullName
	$pem = Get-Content $($tmp.FullName) | Out-String
	Remove-Item $tmp.FullName
	$pem
###>
Remove-SshSession $sshseid.SessionId
    
	$file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"

    "`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
 
    "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append


    return @{ Result="NotUsed"; PrivKeyPem="$pem" }
}


<##################################################################################################
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
##################################################################################################>
function Remove-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
        
    $file = $global:file_prefix + $($MyInvocation.MyCommand) + ".txt"

    "`n##### GENERAL PARAMETERS #####" | Out-File $file
    $General.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append
 
    "`n`n##### FUNCTION SPECIFIC PARAMETERS #####" | Out-File $file -Append
    $Specific.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { Show-Variables $_.Name $_.Value } | Out-File $file -Append

    Remove-Item $($global:temp_dir + "\" + $Specific.AssetNameOld + ".crt")
    Remove-Item $($global:temp_dir + "\" + $Specific.AssetNameOld + ".key")
    Remove-Item $($global:temp_dir + "\" + $Specific.AssetNameOld + ".p12")

    return @{ Result="NotUsed"; }
}

<######################################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    Discovers certificates and their instance metadata from a target device
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
.NOTES
    Returns...
        Result : 'Success' to indicate the non-error completion state
        Applications : an arrayList that include the following data for a certificate instance:
            Name - the name of the application object that represents this instance under the device object
            ApplicationClass - the schema class of the application object (defaults to 'Adaptable App')
           DriverName - the value of the Driver Name attribute (defaults to 'appadaptable')
            PEM - the raw X509 certificate in base64 encoded text format
            ValidationAddress - FQDN, hostname, or IP address where the server is presenting the certificate
            ValidationPort - TCP port on which the server is presending the certificate (integer between 1-65535, defaults to 443)
            Attributes - a hashtable that specifies zero or more Config attribute-value pairs to set on the application object
######################################################################################################################>
function Discover-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )
    $temp_dir = $null
    $sshsess = $null
    $sftpsess = $null
    $applications = New-Object System.Collections.ArrayList
    $apps = @()
    $virtual_hosts = @()
	$envType = Check-Environment($General)
    $hostname = $General.HostAddress
    $deviceusername = $General.UserName
	$logFilePath = $global:temp_dir
    $devicepasswd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential($deviceusername, $devicepasswd)
    $creds = New-Object System.Management.Automation.PSCredential($deviceusername, $devicepasswd)
    $newsession=''
    if($envType -notlike "Windows"){
        $newsession = New-SshSession -Computername $hostname -credential $creds -Force
        $sshseid = Get-SshSession | select SessionId
    }else{
        $newsession = New-PSSession -ComputerName $comp -Credential $credentials
        $sshseid = $newsession.Id
    }
    "the session id is $sshseid $deviceusername $hostname $devicepasswd $newsession" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    try
    {
        $inventroyfile=''
        if($envType -notlike "Windows")
		{
			$inventroyfile = Invoke-SSHPRIV-Command "sudo find / -wholename *oraInventory/ContentsXML/inventory.xml"
		}
		else
		{
            $invout = Invoke-Command -Session $newsession -ScriptBlock { (Get-Childitem –Path "c:\" -Filter inventory.xml -Recurse -ErrorAction SilentlyContinue).FullName }
            $inventroyfile = $invout | Where-Object { $_ -like '*Inventory\ContentsXML*' }
        }
        $oracleHomes=getOracleHomes $hostname $inventroyfile $newsession
        if([string]::IsNullOrEmpty($oracleHomes))
		{
			Write-Output("Null")
			return "" 
        }
        $response = New-Object System.Collections.ArrayList
        $count=1
        foreach($oracleHome in $oracleHomes)
		{
            $ohsver = getOracleVersion $oracleHome $newsession
            $output = @{}
            if($ohsver -eq "11g")
			{
                $instanceParentPath = "$oracleHome/instances"
				"Parent $instanceParentPath" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                $instancePaths = New-Object System.Collections.ArrayList
                $instances = ''
                if($envType -notlike "Windows")
				{
                    $instance = Invoke-SSHPRIV-Command "sudo ls $instanceParentPath"
					"Instance folders $instance" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
				
					if($instance -ne '' -and $instance -ne $null){
					$instance = $instance.Replace('  ',',')
					$instances = $instance.Split(',')
					}
					$instances | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                }
				else
				{
                    $instances = Invoke-Command -Session $newsession -ScriptBlock { Get-Childitem –Path "$instanceParentPath" -Recurse -ErrorAction SilentlyContinue }
                }
				"instances $instances" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                $ohsComponents = New-Object System.Collections.ArrayList
                $wallets = New-Object System.Collections.ArrayList
                foreach($ins in $instances)
				{
                    "instance $ins" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
					$instancePath = "$instanceParentPath/$ins"
                    $ipath=$instancePaths.Add($instancePath)
                    $comps = getOHSComponents11g($instancePath)
                    foreach($comp in $comps)
					{
                        "component $comp" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
						"$instancePath/config/OHS/$comp/ssl.conf" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
						$out = getVirtualHostDetails($instancePath + "/config/OHS/" + $comp + "/ssl.conf") | Out-File -FilePath "$logFilePath\output.out"
						$hostdetails = Get-Content -Path "$logFilePath\output.out"
						$hostdetails = $hostdetails | Where-Object{$_ -notmatch '#'}
						"$instancePath/config/OHS/$comp/ssl.conf" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                        $hostArr = New-Object System.Collections.ArrayList
                        $row=@{}
                        $vaddr=$vport=''             
                        $walletloc=$walletName=''
                        foreach($line  in $hostdetails)
						{
							if($line -eq ''){continue}
                            if($line.Contains("<") -and $line.Contains(">"))
							{
								
                                $line = $line.Replace('<','').Replace('>','')    
                                $arr=$line.Split(" ")
                                $arr | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                                $hostar = $arr[1].Split(":")
                                $vaddr = $hostar[0]
                                $vport = $hostar[1]
                            }
                            if($line.Contains('"'))
							{
                                $line = $line.Replace('"','').Replace('"','').Trim()
                                $walletlocarr=$line.Split(" ")
                                $walletloc = $walletlocarr[1]
                                $out=''
                                $walletName = $walletloc.Split("/") | Select-Object -Last 1
								"wallect location $walletloc" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                            }
                            $line= $line.Trim()
                            $arr=$line.Split(" ")
                            $hostadd=$hostArr.Add($arr[1]) 
                        }
                        $r0=$row.Add("ValidationAddress",$vaddr)
                        $r1=$row.Add("ValidationPort",$vport)
                        if($walletName -ne 'default')
						{
                            $out = getPEM $walletloc $hostname $credentials
                            $r4=$row.Add("PEM",$out)
                        }
                        $r5=$row.Add("DriverName","appadaptable")
                        $r6=$row.Add("Name","OHS$count")
                        $count=$count+1
                        $r7=$row.Add("ApplicationClass","Adaptable App")
                        $attributes=@{
                            "Text Field 1"=$walletloc; 
                            "Text Field 2"=$instancePath.Replace('"','');
                            "Text Field 3"=$walletName;
                            "Text Field 4"=$comp;
                            "Text Field 5"=$ohsver;
                            "Option 1"="";
                            "Option 2"="";
                            "Password 1"="";
                            "Network Validation Disabled"=0
                            "Use Specified Host"=1
                            "SSL Listen Host" =$vaddr;
                            "SSL Listen Port"=$vport;
                        }
                        $r0=$row.Add('Attributes',$attributes)
                        if(-not [string]::IsNullOrEmpty($walletName))
						{
                            $resadd = $apps+=$row  
                        } 
                        $warr=$wallets.Add($hostArr)
                    }
                    $ohscomp=$ohsComponents.Add($comps)
                    $sslPath = $instancePath 
                }
            }
            else
			{
                $domainout = ''
                if($envType -notlike "Windows")
				{
                    $domloc = Invoke-SSHPRIV-Command "sudo grep 'domain location' $oracleHome/domain-registry.xml"
					if($domloc -ne $null -and $domloc -ne ''){
					$domloc = $domloc.Trim() | Out-File -FilePath "$logFilePath\output.out"
					$domainout = Get-Content -Path "$logFilePath\output.out"
					}
                } else
				{
                    $domainout = Invoke-Command -Session $newsession -ScriptBlock {cat "$oracleHome\domain-registry.xml" | find "domain location"}
                }
				"Domain output $domainout" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                $domainhomes = New-Object System.Collections.ArrayList
                $ohsComponents = New-Object System.Collections.ArrayList
                $wallets = New-Object System.Collections.ArrayList
                foreach ( $line in $domainout )
				{
					"domain $line" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                    $domainhome = [RegEx]::match($line,"<domain location=([^\)]+)[\s]*/>").Groups[1].Value.Trim()
                    $dhome = $domainhomes.Add($domainhome)
                }
                foreach($domhome in $domainhomes)
				{
					"dom12c $domhome" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                    $comps = getOHSComponents12c($domhome)
                    foreach($comp in $comps)
					{
						"comp12c $comp" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                        $hd = getVirtualHostDetails($domhome + "/config/fmwconfig/components/OHS/instances/"+$comp+"/ssl.conf") | Out-File -FilePath "$logFilePath\output.out"
						$hostdetails = Get-Content -Path "$logFilePath\output.out"
                        $hostdetails = $hostdetails | Where-Object{$_ -notmatch '#'} 
                        $hostArr = New-Object System.Collections.ArrayList
                        $row=@{}
                        $vaddr=$vport=''             
                        $walletloc=$walletName=''                                                                         
                        foreach($line  in $hostdetails)
						{
							"host12c $line" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                            if($line.Contains("<") -and $line.Contains(">"))
							{
                                $line = $line.Replace('<','').Replace('>','')    
                                $arr=$line.Split(" ")
                                $hostar = $arr[1].Split(":")
                                $vaddr = $hostar[0]
                                $vport = $hostar[1]
                            }
                            if($line.Contains('"'))
							{
                                $line = $line.Replace('"','').Replace('"','').Trim()
                                $walletlocarr=$line.Split(" ")
                                $walletloc = $walletlocarr[1]
                                $out=''
                                $walletName = $walletloc.Split("/") | Select-Object -Last 1
								"wallet12c $walletloc" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                            }
                            $line= $line.Trim()
                            $arr=$line.Split(" ")
                            $hostadd=$hostArr.Add($arr[1]) 
                        }
                        if($walletName -ne 'default')
						{
                            $out = getPEM $walletloc $hostname $credentials
                            $r4=$row.Add("PEM",$out)
                        }
                        #$r2=$row.Add("walletname",$walletName)
                        #$r3=$row.Add("OHSVersion",$ohsver)
                        $r5=$row.Add("DriverName","appadaptable")
                        $r6=$row.Add("Name","OHS$count")
                        $count=$count+1
                        $r7=$row.Add("ApplicationClass","Adaptable App")
                        $r0=$row.Add("ValidationAddress",$vaddr)
                        $r1=$row.Add("ValidationPort",$vport)
                        $attributes=@{
                                        "Text Field 1"=$walletloc; 
                                        "Text Field 2"=$domhome.Replace('"','');
                                        "Text Field 3"=$walletName;
                                        "Text Field 4"=$comp;
                                        "Text Field 5"=$ohsver;
                                        "Option 1"="";
                                        "Option 2"="";
                                        "Password 1"="";
                                        "Network Validation Disabled"=0
                                        "Use Specified Host"=1
                                        "SSL Listen Host" =$vaddr;
                                        "SSL Listen Port"=$vport;
                                    }
                                    $r0=$row.Add('Attributes',$attributes)
                                    if(-not [string]::IsNullOrEmpty($walletName))
									{
                                        $resadd = $apps+=$row  
                                    }
                                    $wadd=$wallets.Add($hostArr)
                    }
                }
                $ohsadd=$ohsComponents.Add($comps)
                $sslPath = $instancePath
            }
        }
    }
    catch
    {
        $_.Exception.Message | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
		$line = $_.InvocationInfo.ScriptLineNumber
		"Line number is $line" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
        throw $_.Exception.Message
    }
    finally  # remove any temporary files we created and close SSH/SFTP sessions
    {
        $removesession = Remove-SshSession $sshseid.SessionId
    }
	($apps | ConvertTo-Json) | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	return @{ Result="Success"; Applications=$apps }
}
<###################### THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ######################>

<######################################################################################################################
.NAME
    getOracleHomes
.DESCRIPTION
    Discovers the Oracle Home from the Oracle Inventory
.PARAMETER
	This function gets the Parameter from Discover-Certificates Function
        HostName : a string containing the hostname or IP address
        InventoryFile : a file contains all the Oracle Home inforamtion, for all the oracle products installed on the server.
.NOTES
    Returns...
        OracleHomes : Returns an array of Oracle HTTP server Homes directories.
######################################################################################################################>
function getOracleHomes([string]$hostname,[string]$inventroyfile,$newsession)
{
	$envType = Check-Environment($General)
    $oracleHomes = New-Object System.Collections.ArrayList
    $oraclehome = @()
    $out=''
    if($envType -notlike "Windows")
	{
        $response = Invoke-SSHPRIV-Command "sudo grep 'HOME NAME' $inventroyfile"
        $out=$response
    }
	else
	{
        $out= Invoke-Command -Session $newsession -ScriptBlock {cat $inventroyfile | find "HOME NAME"}
    }
	$out = $out.Split('>')
    foreach ( $line in $out )
    {
        $oraclehome = [RegEx]::match($line,"LOC=([^\)]+)[\s]*T").Groups[1].Value.Trim()
		"Oracle home $oraclehome" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
        if ( $oraclehome -ne $null -and $line.Contains("<HOME"))
        {
            $ov=''
            if($envType -notlike "Windows")
			{
				$oraclehome = $oraclehome.Replace('"','')
				$oraclehome1 = "$oraclehome/ohs"
				"Oracle Home $oraclehome1" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
                $ohsvalidate = Invoke-SSHPRIV-Command "sudo ls -l $oraclehome1"
                $ov = $ohsvalidate
            }
			else
			{
                $ov = Invoke-Command -Session $newsession -ScriptBlock { Get-Childitem –Path "$oraclehome/ohs" -ErrorAction SilentlyContinue }
            }    
            if ( $ov -ne $null )
			{
                if(-not $oracleHomes.Contains($oraclehome) )
				{
                    $oracleHomes.Add($oraclehome)
                }
            }
        }
    }
	return $oracleHomes
}
<######################################################################################################################
.NAME
    getOracleVersion
.DESCRIPTION
    Discovers the Version of Oracle Home
.PARAMETER
	This function gets the Parameter from Discover-Certificates Function
        oraclehome : a string containing the Oracle HTTP server Home
        newsession : Session infromation to performe remote operations if required
.NOTES
    Returns...
        OHSVersion : Returns the version of Oracle Home sent by Discover-Certificates.
######################################################################################################################>
function getOracleVersion([string]$oraclehome,$newsession)
{
    if ( $oraclehome -ne $null )
    {
        $envType = Check-Environment($General)
		$ov=''
        if($envType -notlike "Windows")
		{
			$ohsvalidate = Invoke-SSHPRIV-Command "sudo ls -l $oraclehome/ohs"
            $ov = $ohsvalidate
        }
		else
		{
            $ov = Invoke-Command -Session $newsession -ScriptBlock { Get-Childitem –Path "$oraclehome\ohs" -ErrorAction SilentlyContinue }
        }
        if ( $ov -ne $null )
		{
            $ohsvesrion = Invoke-SSHPRIV-Command "sudo find $oraclehome -name opmnctl"
            $versionvalidate = $ohsvesrion
			if ( $versionvalidate -ne $null -and $versionvalidate -ne '' )
			{$ohsver="11g"}
			else{$ohsver="12c"}
			"OHS Version of $oraclehome is $ohsver" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
        }
    }
    return $ohsver
}
<######################################################################################################################
.NAME
    getOHSComponents11g
.DESCRIPTION
    Discovers Oracle HTTP server 11g Components from the Instance Path provided by Discover-Certificates Function
.PARAMETER
	This function gets the Parameter from Discover-Certificates Function
        Path : a string that containing the Instance path of OHS 11g home
.NOTES
    Returns...
        ohsComponents : Returns an array of Oracle HTTP server components for an Instance.
######################################################################################################################>
function getOHSComponents11g([string] $path){
	$envType = Check-Environment($General)
	"component $path" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    $ohsComponents= New-Object Collections.Generic.List[String]
    $instancePath = $path + "/config/OPMN/opmn/opmn.xml"
	"opmn path $instancePath" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    $outputs=''
    if($envType -notlike "Windows")
	{
        $stat = Invoke-SSHPRIV-Command "sudo grep -i 'ias-component id' $instancePath"
		if($stat -ne '' -and $stat -ne $null){
			$stat = $stat.Split(' ')
		}
        $outputs=$stat
    }
	else
	{
        $outputs=$homename = Invoke-Command -Session $newsession -ScriptBlock {cat "$instancePath" | find "ias-component id"}
    }
    foreach($out in $outputs)
	{
        $exp = [RegEx]::match($out,"id=""([^\)]+)[\s]*"">").Groups[1].Value.Trim()
		if($exp -eq ''){continue}
        $ohsa=$ohsComponents.Add($exp)
    }
    return $ohsComponents
}
<######################################################################################################################
.NAME
    getOHSComponents12c
.DESCRIPTION
    Discovers Oracle HTTP server 12c Components from the Instance Path provided by Discover-Certificates Function
.PARAMETER
	This function gets the Parameter from Discover-Certificates Function
        Path : a string that containing the Instance path of OHS 12c home
.NOTES
    Returns...
        ohsComponents : Returns an array of Oracle HTTP server components for a domain.
######################################################################################################################>
function getOHSComponents12c([string] $path)
{
    $envType = Check-Environment($General)
	$logFilePath = $global:temp_dir
	$ohsFound = "false"
    $ohsComponents= New-Object Collections.Generic.List[String]
    $configFile = $path + "/config/config.xml"
    $out=''
    if($envType -notlike "Windows")
	{
        $output = Invoke-SSHPRIV-Command "sudo egrep -i '<system-component>|<component-type>|<name>' $configFile"
        $out = $output
    }
	else
	{
        $out=Invoke-Command -Session $newsession -ScriptBlock {  findstr /c:<system-component> /c:<component-type> /c:<name> "$configFile" }
    }
	$o = $out | Out-File -FilePath "$logFilePath\output.out"
	$out = Get-Content -Path "$logFilePath\output.out"
    foreach($line in $out)
	{
        if($line -eq ''){
            continue
        }
        if($line.Contains("<component-type>") -and $line.Contains("OHS"))
		{
            $ohsFound = "true"
            continue
        }
        if($ohsFound.Equals("true"))
		{
            $ohscomp = [RegEx]::match($line,"<name>([^\)]+)[\s]*</name>").Groups[1].Value.Trim()
            $addohs=$ohsComponents.Add($ohscomp)
        }
    }
    return $ohsComponents
}
<######################################################################################################################
.NAME
    getVirtualHostDetails
.DESCRIPTION
    Discovers Virtual host Oracle HTTP server from ssl.conf file
.PARAMETER
	This function gets the Parameter from Discover-Certificates Function
        sslconf : a string that containing the path of ssl.conf file from Oracle HTTP server configuration.
.NOTES
    Returns...
        hostDetails : Returns a string contains Virtal Host and Port information.
######################################################################################################################>
function getVirtualHostDetails([string] $sslconf,$newsession)
{
    $envType = Check-Environment($General)
	$hostDetails=''
    if($envType -notlike "Windows")
	{
        $cmdOutput = Invoke-SSHPRIV-Command "sudo egrep -i '<VirtualHost|ServerName|SSLWallet' $sslconf"
        $hostDetails = $cmdOutput
    }
	else
	{
        $hostDetails=Invoke-Command -Session $newsession -ScriptBlock {  findstr /c:<VirtualHost /c:ServerName /c:SSLWallet "$sslconf" }
    }
     
    return $hostDetails
}
<######################################################################################################################
.NAME
    getPEM
.DESCRIPTION
    Discovers Certificate in the text format
.PARAMETER
	This function gets the Parameter from Discover-Certificates Function
        walletloc	: a string that containing the path of remote Oracle HTTP server wallet location.
		comp		: a string containing the hostname or IP address		
		credentials	: a string contains the username and password in an encrypted format.
.NOTES
    Returns...
        result : Returns a string of certificate value in text format.
######################################################################################################################>
function getPEM([String] $walletloc,[String] $comp, $credentials)
{
    $envType = Check-Environment($General)
	$out = New-Object System.Collections.ArrayList
    $tmpfolder = $global:temp_dir
    $walletName = $walletloc.Split("/") | Select-Object -Last 1
    $tmp = $tmpfolder + "\" + $walletName
	$temp = "/tmp"
	$cpwallet2 = $temp + "/" + $walletName
    $output = New-Item -Path "$tmp" -type directory -Force
	if($envType -notlike "Windows")
	{
		$cpwallet = Invoke-SSHPRIV-Command "sudo cp -r $walletloc $temp"
		$permission = Invoke-SSHPRIV-Command "sudo chmod -R 777 $cpwallet2"
	}
	if($walletloc.Equals(""))
	{
        return "    "
    }
    $scpout=Get-SCPFolder -Computername $comp -credential $credentials -LocalFolder "$tmp" -RemoteFolder $cpwallet2 -Force
    $userCert = $tmp + "\$walletName.txt"
    $display = Invoke-Expression "$orapki wallet display -wallet '$tmp'"
    $dn = [RegEx]::match($display,"Subject:([^\)]+)[\s]*Trusted").Groups[1].Value.Trim()
    $cert = Invoke-Expression "$orapki wallet export -wallet '$tmp' -dn $dn -cert '$userCert'"
    "dn = $dn" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    "Cert $userCert" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$cert | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
    $content = [IO.File]::ReadAllText("$userCert") 
    $result = Process-PemFile $content
    "content $result" | % {if ($DEBUG_FILE) {$_ | Out-File $DEBUG_FILE -Append}}
	$remtepwallet = Invoke-SSHPRIV-Command "sudo rm -r $cpwallet2"
    return $result
}
<######################################################################################################################
.NAME
    Process-PemFile
.DESCRIPTION
    Convert the Certificate into PEM format
.PARAMETER
	This function gets the Parameter from Discover-Certificates Function
        Content	: a string that containing the certificate value in text format.
.NOTES
    Returns...
        pem : Returns the certificate value in PEM format.
######################################################################################################################>
function Process-PemFile ( [string] $content )
{
    $result = @{ EE=$null; CA=@() }
    while ( $content.Contains($pem_prefix) )
    {
        $idx_begin = $content.IndexOf($pem_prefix) + $pem_prefix.Length
        # throw away everything before and including the prefix
        $content = $content.Substring($idx_begin)
        $idx_end = $content.IndexOf($pem_suffix) - 1
        if ( $idx_end -lt 0 ) # we have a corrupt file, PEM prefix with no suffix
        {
            break
        }
        $pem = $content.Substring(0, $idx_end).Trim()
        $bytes = [Convert]::FromBase64String($pem)
        $pem = $pem_prefix + $pem.Replace("`r","").Replace("`n","") + $pem_suffix
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 @(,$bytes)
        if ( -not $cert.Extensions.CertificateAuthority )
        {
            $result.EE = $pem
        }
        else
        {
            $result.CA += $pem
        }
        # throw away everything before and including the suffix
        $content = $content.Substring($idx_end + $pem_suffix.Length + 1)
    }
    return $pem
}
<######################################################################################################################
.NAME
    Invoke-SSHPRIV-Command
.DESCRIPTION
    Creates the remote session on Linux machines and execute the command received.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
.NOTES
    Returns...
        finalOutput : Output of the command executed remotly.
######################################################################################################################>
function Invoke-SSHPRIV-Command([String] $command){
    $sUser = $General.UserName
    $Password = $General.UserPass
    $sHost = $General.HostAddress
    if ( $General.UserPrivKey )
    {
        # Posh-SSH requires the private key to be in a file :(
        $auth_key = $temp_dir + "\auth"
        $General.UserPrivKey | Out-File $auth_key
        # SSH key passed to function will never be password encrypted
        $sPassword = New-Object System.Security.SecureString
        $oCredential = New-Object System.Management.Automation.PSCredential($sUser, $sPassword)
        $oSessionSSH = New-SSHSession -ComputerName $comp -Credential $oCredential -KeyFile $auth_key -Force
    }
    else          # username/password auth
    {
        $sPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $oCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $sUser, $sPassword
        $oSessionSSH = New-SSHSession -ComputerName $sHost -credential $oCredential -Force
    }
    $stream = $oSessionSSH.Session.CreateShellStream("PS-SSH", 0, 0, 0, 0, 1000)
    $results=$stream.Read()
	if($command.Contains("inventory.xml") -or $command.Contains("stopComponent.sh") -or $command.Contains("startComponent.sh") -or $command.Contains("opmnctl"))
	{
		$stream.WriteLine("echo BEGIN_OUTPUT && $command && echo END_OUTPUT")
		sleep -s 60
	}
	else
	{
    $stream.WriteLine("echo BEGIN_OUTPUT && $command && echo END_OUTPUT")
    sleep -s 4
	}
    $results=$stream.Read()
    $pos1 = $results.LastIndexOf("BEGIN_OUTPUT")
    $pos2 = $results.LastIndexOf("END_OUTPUT")
	$finalOutput = ''
	if($pos2-$pos1 -ge 0)
	{
		$finalOutput = $results.Substring($pos1 ,$pos2-$pos1)
		$finalOutput = $finalOutput.Replace('BEGIN_OUTPUT','').Trim()
	}
    else
    {
        $finalOutput = $null
    }
    $stream.Close()
    $removessh = Remove-SshSession $oSessionSSH
    return $finalOutput
}
<######################################################################################################################
.NAME
    Check-Environment
.DESCRIPTION
    Dicovers the Environemt based on the Host.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
.NOTES
    Returns...
        envType : Returs the type of Environment
######################################################################################################################>
function Check-Environment(){
	$comp = $General.HostAddress
	$TimeToLive = Test-Connection $comp -Count 1 | select -exp ResponseTimeToLive
    $envType=''
    Switch($TimeToLive)
    {{$_ -le 64} {$envType="Linux"; break}
    {$_ -le 128} {$envType="Windows"; break}
    {$_ -le 255} {$envType="UNIX"; break}}
	return $envType
}
function Validate-CommandOutput($output, $success, $failure1, $failure2)
{
    if($output -like "*" + $success + "*"){
        return "S"
    }elseif($output -like "*" + $failure + "*"){
        return $failure
    }elseif($output -like "*" + $failure2 + "*"){
        return $failure2
    }
return "R"
}