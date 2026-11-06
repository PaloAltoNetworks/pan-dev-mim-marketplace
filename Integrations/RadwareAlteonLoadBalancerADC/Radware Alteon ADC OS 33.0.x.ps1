<#
//-----------------------------------------------------------------------
// Radware Alteon ADC.ps1
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
Text1|Virtual Server|111
Text2|Service Port|111
Text3|SSL Policy|110
Text4|Certificate Group|000
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
	$name = Fix-CertKeyName $General.AssetName
	$global:debug_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".log"
	$global:error_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".error.log"


    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection

    if ( $Specific.ChainPkcs7 )
    {
        $chain.Import( $Specific.ChainPkcs7 )
    }
    else # there is no chain for the certificate being provisioned
    {
        return @{ Result="Success"; }
    }

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)
	
	if ($DEBUG_FILE) {
        "Initiating session to $($General.HostAddress) on $($General.TcpPort)" | Out-File $global:debug_log -Append
    }
	
    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds -force
    if (!$?) {
		"Failed to create session: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create session: $($Error[0])"
    }
	
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    if (!$?) {
		"Failed to create stream: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create stream: $($Error[0])"
    }
	
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
		$stream.Read() #clears the buffer
		$stream.Write("y`n")
	}
	
	$Apply_status = Check_Apply $stream
	
	if ($DEBUG_FILE) { "Apply_status --> $Apply_status" | Out-File $global:debug_log -Append }
	
	if ($Apply_status -eq "ResumeLater")
	{
		exit_alteon $stream
		return @{ result="ResumeLater"}
	}
	elseif ($Apply_status -ne 1)
	{
		exit_alteon $stream
		"Apply_status is UNKNOWN --> $Apply_status"  | Out-File $global:error_log -Append
		throw $output
	}
	
	
    

    #Test stream functionality
    if ($DEBUG_FILE) {
        $stream.Write("/info/sys/time`n")
        Start-Sleep -Seconds 5
		
		$output = $stream.Read()
		if ($output -NotLike '*System#*')
		{
			"Time command error" | Out-File -Append $global:error_log
			throw "Time command error"
		}
		
		
        if ( $DEBUG_FILE ) { $stream.Read() | Out-File $global:debug_log -Append }
    }


	# Make sure that the virt is exist
	
    $execSuccess = Execute `
        -Stream $stream `
        -Command "/info/slb/virt $($General.VarText1)" `
        -SuccessTests @("*Virtual Services:*") `
        -Timeout 20 `
        -LogOutput

    if (-not $execSuccess) {
		$($General.VarText1) + " not exists" | Out-File -Append $global:error_log
        $stream.Read() | Out-Null
        $stream.Close()
        Remove-SSHSession -SSHSession $session | Out-Null
		throw "Virt " + $($General.VarText1) + " not exists"
    }

	
	
    # Creating hashed group name
	#if ( $DEBUG_FILE ) { "chain -->: " + $chain | Out-File $global:debug_log -Append }
	#if ( $DEBUG_FILE ) { "chain issuer -->: " + $chain[0].Issuer | Out-File $global:debug_log -Append }
    #$res = $($chain[0].Issuer) -match '(?<=O=")(.*)(?=")'
    $res = $chain[0].Issuer -split ','
	$res = ($res[0] -split '=')
	$res = $res[1]
	if ( $DEBUG_FILE ) { "res -->: " + $($res) | Out-File $global:debug_log -Append }
    #$issuerName = $res[0] -replace ' ', ''
    $issuerName = $res -replace ' ', ''
    $issuerName = $issuerName -replace '[\W]', ''
    if ( $DEBUG_FILE ) { "issuer name: " + $($issuerName) + $res | Out-File $global:debug_log -Append }
    if ( $DEBUG_FILE ) { "issuer original string: " + $chain[0].Issuer | Out-File $global:debug_log -Append }
    if ( $DEBUG_FILE ) { $($chain[0].Issuer) | Out-File $global:debug_log -Append }
    
    $serialNames = ''

    foreach ( $cert in $chain )
    {
        $serialNames = "$($serialNames)$($cert.SerialNumber)"
    }

    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($serialNames)
    $writer.Flush()
    $stringAsStream.Position = 0
    $hashedString = Get-FileHash -InputStream $stringAsStream -Algorithm MD5 | Select-Object Hash
    $groupName = $issuerName + "_" + $($hashedString.Hash)

    if ( $DEBUG_FILE ) { "serial names: " + $groupName | Out-File $global:debug_log -Append }

    # importing all certificates in the chain
    foreach ( $cert in $chain )
    {
        $execSuccess = Execute `
            -Stream $stream `
            -Command "/cfg/slb/ssl/certs/import intermca $($cert.SerialNumber) text" `
			-NotSuccess_ButValid "*Please paste intermediate ca certificate.*" `
            -SuccessTests @("*already exists*") `
            -Timeout 2

        if ($execSuccess) {
            $stream.Write("n`n") # don't overwrite the cert if it already exits
            Start-Sleep -Seconds 1
        }
		else
		{
			$b64 = [Convert]::ToBase64String($cert.RawData, [Base64FormattingOptions]::InsertLineBreaks)
			$b64 = "-----BEGIN CERTIFICATE-----`n" + $b64 + "`n-----END CERTIFICATE-----"
			$execSuccess = Execute `
				-Stream $stream `
				-Command "$b64`n" `
				-SuccessTests @("*intermca added*") `
				-Timeout 60 `
				-LogOutput
		}

        if ( $execSuccess)
        {
            $stream.Write("/cfg/slb/ssl/certs/group $($groupName)`n")
            $stream.Write("add`n")
            $stream.Write("$($cert.SerialNumber)`n")
            Start-Sleep -Seconds 3
        

            if ( $General.VarText3 ) # there is an ssl policy to create/update
            {
                $stream.Write("/cfg/slb/ssl/sslpol $($General.VarText3 -Replace ' ','_')`n")
                $stream.Write("ena`n")
                Start-Sleep -Seconds 2
            }

            $result = "Success"
        }
    }
    
	if ($stream)
	{
        exit_alteon $stream
    }
	
    if ( $result )
    {	
		return @{ Result=$result}
    }
    else
    {
        throw "Certificate chain installation failed. " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line} )
    }

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
        [System.Collections.Hashtable]$Specific
    )
	
	$name = Fix-CertKeyName $General.AssetName
	$global:debug_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".log"
	$global:error_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".error.log"

    $result = $null

    Assert-NotNullOrEmpty "Private Key Name" $General.AssetName
    Assert-NotNullOrEmpty "Private Key PEM" $Specific.PrivKeyPem

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds -force
    if (!$?) {
		"Failed to create session: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create session: $($Error[0])"
    }
	
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    if (!$?) {
		"Failed to create stream: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create stream: $($Error[0])"
    }
	
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
		$stream.Read() #clears the buffer
		$stream.Write("y`n")
	}

    $name = Fix-CertKeyName $General.AssetName

    $execSuccess = Execute -Stream $stream `
        -Command "/cfg/slb/ssl/certs/import key $name text" `
        -SuccessTests @("*already exists in the repository*") `
		-NotSuccess_ButValid "*Please paste key.*" `
        -Timeout 3

    if ($execSuccess)
    {
        # private key already exists so we're done
        $stream.Write("n`n")
        Start-Sleep -Seconds 1
        $result = "AlreadyInstalled"
    }
    else
    {
        $execSuccess = Execute -Stream $stream `
            -Command "$($Specific.PrivKeyPem)`n" `
            -SuccessTests @("*key added*") `
            -Timeout 60 `
            -LogOutput

        if ( $execSuccess )
        {
            $result = "Success"
        }
    }

	
	if ($stream)
	{
        exit_alteon $stream
    }
	
	
    if ( $result )
    {
		return @{ Result=$result; AssetName=$name }
    }
    else
    {
        $output | Out-File -Append $global:error_log
        throw "Private Key installation failed. " + $($output.Split("`n") | Select-String "Error" | Select -First 1 | % {$_.Line} )
    }
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
	$name = Fix-CertKeyName $General.AssetName
	$global:debug_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".log"
	$global:error_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".error.log"
    $result = $null

    Assert-NotNullOrEmpty "Certificate Name" $General.AssetName
    Assert-NotNullOrEmpty "Certificate PEM" $Specific.CertPem

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds -force
    if (!$?) {
		"Failed to create session: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create session: $($Error[0])"
    }
	
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    if (!$?) {
		"Failed to create stream: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create stream: $($Error[0])"
    }
	
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
		$stream.Read() #clears the buffer
		$stream.Write("y`n")
	}
	


    $execSuccess = Execute -Stream $stream `
        -Command "/cfg/slb/ssl/certs/import certificate $($General.AssetName) text" `
        -SuccessTests @("*already exists in the repository*") `
		-NotSuccess_ButValid "*Please paste certificate.*" `
        -Timeout 3 `
        -LogOutput

    if ($execSuccess)
    {
        if ( $DEBUG_FILE ) { "certificate already exists " | Out-File $global:debug_log -Append }
        # private key already exists so we're done
        $stream.Write("n`n")
        Start-Sleep -Seconds 1
        $result = "AlreadyInstalled"
    }
    else
    {

        if ( $DEBUG_FILE ) { "certificate does not exist. adding " | Out-File $global:debug_log -Append }

        $execSuccess = Execute -Stream $stream `
            -Command "$($Specific.CertPem)" `
            -SuccessTests @("*certificate added*") `
            -Timeout 60 `
            -LogOutput

        if ( $execSuccess )# modified '*srvrcrt added* to * added * as the string changed from srvrcrt to certificate ---RAJ
        {
            if ( $Specific.ChainPkcs7 )
            {
                # Creating hashed group name
                $chain = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
                $chain.Import( $Specific.ChainPkcs7 )

                #$res = $($chain[0].Issuer) -match '(?<=O=")(.*)(?=")'
				$res = $chain[0].Issuer -split ','
				$res = ($res[0] -split '=')
				$res = $res[1]
				if ( $DEBUG_FILE ) { "res: -->" + $res | Out-File $global:debug_log -Append }
                #$issuerName = $res[0] -replace ' ', ''
                $issuerName = $res -replace ' ', ''
                $issuerName = $issuerName -replace '[\W]', ''
                if ( $DEBUG_FILE ) { "issuer name: " + $($issuerName) + $res | Out-File $global:debug_log -Append }
                if ( $DEBUG_FILE ) { "issuer original string: " + $chain[0].Issuer | Out-File $global:debug_log -Append }
                if ( $DEBUG_FILE ) { $($chain[0].Issuer) | Out-File $global:debug_log -Append }

                foreach ( $cert in $chain )
                {
                    $serialNames = "$($serialNames)$($cert.SerialNumber)"
                }

                $stringAsStream = [System.IO.MemoryStream]::new()
                $writer = [System.IO.StreamWriter]::new($stringAsStream)
                $writer.write($serialNames)
                $writer.Flush()
                $stringAsStream.Position = 0
                $hashedString = Get-FileHash -InputStream $stringAsStream -Algorithm MD5 | Select-Object Hash
                $groupName = $issuerName + "_" + $($hashedString.Hash)

                
                $stream.Write("/cfg/slb/ssl/certs/cert $($General.AssetName)`n")
                $stream.Write("intermca group $($groupName)`n")
                Start-Sleep -Seconds 1
                $output = $stream.Read() # to delete
                if ( $DEBUG_FILE ) { "`ncertificate output: " + $output | Out-File $global:debug_log -Append }
            }
            $result = "Success"
        } else {
            if ($stream)
			{
				exit_alteon $stream
			}
            throw "Failed to import certificate"
        }
    }

    if ( $result )
    {
		if ($stream)
		{
            exit_alteon $stream
        }
        return @{ Result=$result; }
    }
    else
    {
		if ($stream)
		{
            exit_alteon $stream
        }
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

	$name = Fix-CertKeyName $General.AssetName
	$global:debug_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".log"
	$global:error_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".error.log"
	
    Assert-NotNullOrEmpty "Certificate Name" $General.AssetName
    Assert-NotNullOrEmpty "Virtual Server" $General.VarText1
    Assert-NotNullOrEmpty "Service Port" $General.VarText2

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds -force
    if (!$?) {
		"Failed to create session: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create session: $($Error[0])"
    }
	
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    if (!$?) {
		"Failed to create stream: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create stream: $($Error[0])"
    }
	
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
		$stream.Read() #clears the buffer
		$stream.Write("y`n")
	}
	
	# get current cert name:
	if ($DEBUG_FILE) { "Start of getting the current SSL" | Out-File $global:debug_log -Append }
	$stream.read()
	$stream.Write("/c/slb/virt $($General.VarText1)/service $($General.VarText2) https/ssl`n")
	Start-Sleep -Seconds 2
	$stream.Write("cur`n")
	Start-Sleep -Seconds 2
	$output = $stream.read()
	
	$pattern = "srvrcert\s+(.*?),"

	$match = [regex]::Match($output, $pattern)
	
	if ($DEBUG_FILE) { "$output" | Out-File $global:debug_log -Append }

	$CURRENT_SSL = ""
	if ($match.Success) {
		$CURRENT_SSL = $match.Groups[1].Value
		if ($DEBUG_FILE) { "CURRENT SSL IS --> $CURRENT_SSL" | Out-File $global:debug_log -Append }
	} else {
		if ($DEBUG_FILE) { "CANNOT GET SSL FROM OUTPUT --> $output" | Out-File $global:debug_log -Append }
	}
	if ($DEBUG_FILE) { "End of getting the current SSL" | Out-File $global:debug_log -Append }

	# end of getting current cert

    $stream.Write("/cfg/slb/virt $($General.VarText1)`n")
    $stream.Write("service $($General.VarText2) https`n`n")
    Start-Sleep -Seconds 2

    if ( $General.VarText3 ) # there is an ssl policy
    {
        $stream.Write("ssl/sslpol`n")
        $stream.Write("$($General.VarText3 -Replace ' ','_')`n")
        Start-Sleep -Seconds 2
        $stream.Write("/cfg/slb/virt $($General.VarText1)`n")
        Start-Sleep -Seconds 2
        $stream.Write("ena`n")
        $stream.Write("service $($General.VarText2) https`n`n")
        Start-Sleep -Seconds 2
    }

    $execSuccess = Execute -Stream $stream `
        -Command "ssl/srvrcert cert $($General.AssetName)" `
        -SuccessTests @("*For certificate*") `
        -Timeout 5
	
	
	
	if ($DEBUG_FILE) { "Applying configuration BEFORE deleting the old certificate" | Out-File $global:debug_log -Append }
	$Apply_status = Check_Apply $stream
	
	if ($DEBUG_FILE) { "Apply_status --> $Apply_status" | Out-File $global:debug_log -Append }
	
	if ($Apply_status -eq "ResumeLater")
	{
		exit_alteon $stream
		return @{ result="ResumeLater"}
	}
	elseif ($Apply_status -ne 1)
	{
		exit_alteon $stream
		"Apply_status is UNKNOWN --> $Apply_status"  | Out-File $global:error_log -Append
		throw $output
	}
	
	if ($Apply_status -eq 1)
	{
		Save $stream
	}	
	
	# Deleting the OLD SSL
	
	if ($CURRENT_SSL -ne "" -And $CURRENT_SSL -ne $General.AssetName)
	{
		$OLD_SSL = $CURRENT_SSL
		if ($DEBUG_FILE) { "======================= Start of deleting the OLD SSL =======================" | Out-File $global:debug_log -Append }
		$stream.Write("/cfg/slb/ssl/certs/key`n")
		Start-Sleep -Seconds 1
		$stream.Write("$OLD_SSL`n")
		
		$stream.Read() #clears the buffer
		
		$stream.Write("del`n")
		Start-Sleep -Seconds 1
		
		$output = $stream.Read()
		
		if ($output -like '*Specify delete action:*')
		{
			$stream.Write("2`n")
			Start-Sleep -Seconds 1
		}
		
		Start-Sleep -Seconds 5
		$output = $stream.Read()
		if ($DEBUG_FILE) { "======================= End of deleting the OLD SSL =======================" | Out-File $global:debug_log -Append }
	}
	
	
	if ($DEBUG_FILE) { "Applying configuration AFTER deleting the old certificate" | Out-File $global:debug_log -Append }
	$Apply_status = Check_Apply $stream
	
	if ($DEBUG_FILE) { "Apply_status --> $Apply_status" | Out-File $global:debug_log -Append }
	
	if ($Apply_status -eq "ResumeLater")
	{
		exit_alteon $stream
		return @{ result="ResumeLater"}
	}
	elseif ($Apply_status -eq "Configuration is reverted")
	{
		if ($DEBUG_FILE) { "The certificate deletion was not possible because this certificate is associated with multiple virts." | Out-File $global:debug_log -Append }
	}
	elseif ($Apply_status -ne 1)
	{
		exit_alteon $stream
		"Apply_status is UNKNOWN --> $Apply_status"  | Out-File $global:error_log -Append
		throw $output
	}
	
	if ($Apply_status -eq 1)
	{
		Save $stream
	}
	
    if ( $execSuccess )
    {
        if ($stream)
		{
            exit_alteon $stream
        }
        return @{ Result="Success"; }
    }
    else
    {
        $output | Out-File -Append $global:error_log
        if ($stream)
		{
            exit_alteon $stream
        }
        Remove-SSHSession -SSHSession $session | Out-Null
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
	$name = Fix-CertKeyName $General.AssetName
	$global:debug_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".log"
	$global:error_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".error.log"
	
    Assert-NotNullOrEmpty "Certificate Key Name" $General.AssetName

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds -force
    if (!$?) {
		"Failed to create session: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create session: $($Error[0])"
    }
	
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    if (!$?) {
		"Failed to create stream: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create stream: $($Error[0])"
    }
	
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
		$stream.Read() #clears the buffer
		$stream.Write("y`n")
	}
	
    $header = "-----BEGIN CERTIFICATE-----"
    $footer = "-----END CERTIFICATE-----"

    $execSuccess = Execute -Stream $stream `
        -Command "/cfg/slb/ssl/certs/export srvrcert $($General.AssetName) text`n" `
        -SuccessTests @("*$header*") `
        -Timeout 10
    
    if ( $execSuccess )
    {
        $CertPem = ($output -split $header,2)[1]
        $CertPem = ($CertPem -split $footer,2)[0]

        $CertPem = $header + "`n" + $CertPem.Trim() + "`n" + $footer

        if ($stream)
		{
            exit_alteon $stream
        }
        return @{ Result="Success"; CertPem=$CertPem }
    }
    else
    {
        if ($stream)
		{
            exit_alteon $stream
        }
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
	
	$name = Fix-CertKeyName $General.AssetName
	$global:debug_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".log"
	$global:error_log = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Logs\" + $($General.HostAddress) + "_" + $name  + ".error.log"
	
    Assert-NotNullOrEmpty "Private Key Name" $General.AssetName
    Assert-NotNullOrEmpty "Private Key Password" $Specific.EncryptPass

    $passwd = ConvertTo-SecureString -String $General.UserPass -AsPlainText -Force 
    $creds = New-Object System.Management.Automation.PSCredential($General.UserName, $passwd)

    $session = New-SSHSession -ComputerName $General.HostAddress -Port $General.TcpPort -AcceptKey -Credential $creds -force
    if (!$?) {
		"Failed to create session: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create session: $($Error[0])"
    }
	
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    if (!$?) {
		"Failed to create stream: $($Error[0])" | Out-File -Append $global:error_log
        throw "Failed to create stream: $($Error[0])"
    }
	
    Start-Sleep -Seconds 2
    $output = $stream.Read()
    if ($output -like '*Confirm seeing above note `[y`]:*')
    {
        # acknowledge that there are pending changes
		$stream.Read() #clears the buffer
		$stream.Write("y`n")
    }

    $header = "-----BEGIN RSA PRIVATE KEY-----"
    $footer = "-----END RSA PRIVATE KEY-----"

    $execSuccess = Execute -Stream $stream `
        -Command "/cfg/slb/ssl/certs/export key $($General.AssetName) `"$($Specific.EncryptPass)`" text`n" `
        -SuccessTests @("*$header*") `
        -Timeout 10
    

    if ( $execSuccess )
    {
        $KeyPem = ($output -split $header,2)[1]
        $KeyPem = ($KeyPem -split $footer,2)[0]

        $KeyPem = $header + "`n" + $KeyPem.Trim() + "`n" + $footer

        if ($stream)
		{
            exit_alteon $stream
        }
        return @{ Result="Success"; PrivKeyPem=$KeyPem }
    }
    else
    {
        $output | Out-File -Append $global:error_log
        if ($stream)
		{
            exit_alteon $stream
        }
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
	return @{ Result="NotUsed"; }
}


<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Assert-NotNullOrEmpty( [string]$name, [string]$value )
{
	if ( $DEBUG_FILE ) { "name is --> " + $name | Out-File -Append $global:debug_log }
	if ( $DEBUG_FILE ) { "value is --> " + $value | Out-File -Append $global:debug_log }
    if ( !$value )
    {
		"$($name) is required." | Out-File -Append $global:error_log
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


function Execute()
{
    param (
        $Stream,
        [String]$Command,
        [string[]]$SuccessTests,
		[String]$NotSuccess_ButValid,
        [int]$Timeout = 5,
        [Switch]$LogOutput
    )

    $execSuccess = $false

    if ( $DEBUG_FILE ) { "================ BEFORE EXECUTE ================" | Out-File $global:debug_log -Append }

    if ( $DEBUG_FILE ) { "COMMAND: $Command" | Out-File $global:debug_log -Append }

	$null = $stream.Read() # clears the buffer
	$stream.Write("$Command`n")

    $ExecuteStart = Get-Date
    $ExecuteTimeout = $ExecuteStart.AddSeconds($Timeout)

    if ( $DEBUG_FILE ) { "STARTED: $ExecuteStart " | Out-File $global:debug_log -Append }

    $allOutput = ""

    :loop
    while ((Get-Date) -lt $ExecuteTimeout) {
        $output = $stream.Read()

        $allOutput += $output

        foreach ($test in $SuccessTests) {
            if ($allOutput -ilike $test) {
                $execSuccess = $true
                break loop
            }
        }

        Start-Sleep -Seconds 1
    }

    if ( $DEBUG_FILE ) { "ENDED: $(Get-Date) " | Out-File $global:debug_log -Append }

    if ( $LogOutput ) { 
        if ( $DEBUG_FILE ) { "OUTPUT:" | Out-File $global:debug_log -Append }
        if ( $DEBUG_FILE ) { $allOutput | Out-File $global:debug_log -Append }
    }

    if (-not $execSuccess) 
	{
	    if ($allOutput -iLike $NotSuccess_ButValid)
		{
			if ( $DEBUG_FILE ) { "OUTPUT:" | Out-File $global:debug_log -Append }
			if ( $DEBUG_FILE ) { $allOutput | Out-File $global:debug_log -Append }
		}
		else
		{
			if ( $DEBUG_FILE ) { "OUTPUT:" | Out-File $global:error_log -Append }
			if ( $DEBUG_FILE ) { $allOutput | Out-File $global:error_log -Append }
		}
    }

    if ( $DEBUG_FILE ) { "RESULT: $execSuccess " | Out-File $global:debug_log -Append }

    if ( $DEBUG_FILE ) { "================ AFTER EXECUTE ================" | Out-File $global:debug_log -Append }

    $execSuccess

}


function exit_alteon($stream)
{
	$stream.Read()
	$stream.Write("exit`n")
	Start-Sleep -Seconds 1

	$output = $stream.Read()
	if ($output -like '*changes (leave them pending) `[y/n`]:*') # for apply changes
	{
		$stream.Write("y`n")
	}
	
	$stream.Read() #clears the buffer
	Start-Sleep -Seconds 1

	$output = $stream.Read()
	if ($output -like '*changes (leave them pending) `[y/n`]:*') # for save changes
	{
		$stream.Write("y`n")
	}
	$stream.Close()
	Remove-SSHSession -SSHSession $session | Out-Null
}


function Check_Apply($stream)
{
	$Apply_status = 0
	if ( $DEBUG_FILE ) { "================ BEFORE APPLY ================" | Out-File $global:debug_log -Append }
	
	$stream.Read() # clears the buffer
	$stream.Write("apply`n")
	
	$counter = 0
	while($counter -ne 10)
	{
		$counter++
		Start-Sleep -Seconds 3
		$output = $stream.Read()
		if ( $DEBUG_FILE ) { "OUTPUT IS: " + $output | Out-File $global:debug_log -Append }
		if ($output -like '*Apply complete;*' -or $output -like '*No apply needed.*')
		{
			$Apply_status = 1
			break
		}
		elseif ($output -like '*Synchronize configuration changes?*' -or $output -like '*Confirm synchronizing the configuration to*')
		{
			$stream.Read() # clears the buffer
			$stream.Write("y`n")
			Start-Sleep -Seconds 2
			if ( $DEBUG_FILE ) { "waiting for sync.. " | Out-File $global:debug_log -Append }
			$Apply_status = "ResumeLater"
			continue
		}
		elseif ($output -like '*Apply is issued by another user. Try later.*')
		{
			$Apply_status = "ResumeLater"
			break
		}
		elseif ($output -like '*Applying Configuration*')
		{
			$Apply_status = "ResumeLater"
			continue
		}
		elseif ($output -like '*Error: *Certificate/Group must be defined.*')
		{
			$stream.Write("revert`n")
			Start-Sleep -Seconds 2
			$stream.Write("y`n")
			Start-Sleep -Seconds 8
			$Apply_status = "Configuration is reverted"
			break
		}
		elseif ($output -like '*Error: Apply not done.*')
		{
			exit_alteon($stream)
			$output | Out-File $global:error_log -Append
			throw $output
		}
	}
	if ( $DEBUG_FILE ) { "================ AFTER APPLY ================" | Out-File $global:debug_log -Append }
	return $Apply_status
}

function Save($stream)
{
	$Save_status = 0
	if ( $DEBUG_FILE ) { "================ BEFORE Save ================" | Out-File $global:debug_log -Append }
	
	$stream.Read() # clears the buffer
	$output = $stream.Write("save`n")
	Start-Sleep -Seconds 1

	$stream.Write("y`n")
	$counter = 0
	while($counter -ne 60)
	{
		$counter++

		if ( $DEBUG_FILE ) { "SAVE COUNTER IS: " + $counter | Out-File $global:debug_log -Append }
		$output = $stream.Read()
		if ( $DEBUG_FILE ) { "OUTPUT IS: " + $output | Out-File $global:debug_log -Append }
		if ($output -like '*New config successfully saved to FLASH.*' -or $output -like '*No Save needed.*')
		{
			$Save_status = 1
			break
		}
		elseif ($output -like '*Error: Save not done.*')
		{
			"Save output is --> " + $output | Out-File $global:error_log -Append
            $stream.Read() | Out-Null
            exit_alteon $stream
			throw $output
		}
		else
		{
			Start-Sleep -Seconds 1
		}
		if ($counter -eq 60)
		{
			"Save operation takes more than 60 seconds , output is --> " + $output | Out-File $global:error_log -Append
			exit_alteon "Save operation takes more than 60 seconds , output is --> " $stream
			throw $output
		}
	}
	if ( $DEBUG_FILE ) { "Save output is --> " + $output | Out-File $global:debug_log -Append }
	if ( $DEBUG_FILE ) { "================ AFTER Save ================" | Out-File $global:debug_log -Append }
}
