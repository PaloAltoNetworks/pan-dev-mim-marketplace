<#
//---------------------------------------------------------------------------
// Check Point Adaptable App Driver.ps1
//
// v1.0
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by Check Point, in addition to Venafi.
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
Text1|Domain Name|100
Text2|Gateway Name|101
Text3|NotUsed|000
Text4|NotUsed|000
Text5|NotUsed|000
Option1|Ignore Warnings|100
Option2|NotUsed|000
Passwd|NotUsed|000
-----END FIELD DEFINITIONS-----
#>

$base_path = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path"

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

$global:logs_dir = $base_path + "\Logs"

If ( !(Test-Path $global:logs_dir) )
{
   New-Item $global:logs_dir -Type Directory
}

$global:chkp_log = $global:logs_dir + "\chkp-aad.log"

<##################################################################################################
.NAME
    Get-TimeStamp
##################################################################################################>
function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

<##################################################################################################
.NAME
    Write-Log
##################################################################################################>
Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",
    [Parameter(Mandatory=$True)]
    [string]
    $Message
    )

    $Line = "$(Get-TimeStamp) [$Level] $Message"

    Add-Content $global:chkp_log -Value $Line
}

<##################################################################################################
.NAME
    Extract-Common-Name
##################################################################################################>
function Extract-Common-Name {
    Param(
        [parameter(mandatory=$true)]
        [string]$AssetName
    )

    if ([string]::IsNullOrEmpty($AssetName)) {
        throw "Input AssetName is null or empty" 
    }

    <# Try to extract common name by splitting the AssetName on the '_' delimiter.
     # If there are exactly 3 parts, we can safely assume that the first part is the common name since the expected format is <Common Name>_<ValidTo as YYmmmDD>_<Last 4 of SerialNum> #>
    $split_asset_name = $AssetName.Split('_')
    if ($split_asset_name.Count -lt 3) {
        throw "AssetName contains less than 3 groups after split and isn't in the excepted format" 
    }
    elseif ($split_asset_name.Count -eq 3) {
        return $split_asset_name[0]
    }
    <# If there are more than 3 groups, than the common name itself contains '_' characters. 
     # We extract the common name by trimming the length last 13 characters - the assumed _<ValidTo as YYmmmDD>_<Last 4 of SerialNum> part of the input AssetName #>
    else {
        $length_to_trim = 13
        return $AssetName.Substring(0, $AssetName.length - $length_to_trim)
    }
    
}

<##################################################################################################
.NAME
    Make-Api-Call
.DESCRIPTION
    Makes an API call to the CheckPoint Security Management API server
.PARAMETER ManagementIp
    The Check Point Security Management IP address
.PARAMETER ApiPort
    The Management WebAPI port. Default: 443
.PARAMETER Sid
    The API session token, required for all commands but login
.PARAMETER Command
    The API command to call
.PARAMETER Payload
    The input command payload
##################################################################################################>
function Make-Api-Call 
{
     Param(
        [parameter(mandatory=$true)]
        [string]$ManagementIp,
        [parameter(mandatory=$false)]
        [string]$ApiPort = "443",
		[parameter(mandatory=$false)]
        [string]$Sid,
		[parameter(mandatory=$true)]
        [string]$Command,
		[parameter(mandatory=$false)]
        [System.Collections.Hashtable]$Payload
    )
	
	$web_api_url = "https://{0}:{1}/web_api/{2}" -f $ManagementIp,$ApiPort,$Command
	Write-Log -Level DEBUG -Message "url : ($web_api_url)"
    
	$headers = @{"User-Agent" = "Venafi"}
	if ($Command -ne "login")
	{
	    if ( ! $Sid)
		{
		    throw "API Call without session ID" 
		}
		else 
		{
		    $headers += @{"X-chkp-sid" = $Sid}
		}
	}
	if ( $Payload )
	{
	    $postParams = $Payload | ConvertTo-Json
		Write-Log -Level DEBUG -Message "post params: ($postParams)"
	}
	else 
	{
	    $postParams = "{}"
	}
    Try 
	{	
        $response = Invoke-WebRequest -Uri $web_api_url -UseBasicParsing -Method POST -ContentType "application/json" -Body $postParams  -Headers $headers 
    }
    Catch {
        Write-Log -Level DEBUG -Message "While making API call, Invoke-WebRequest throw exception: $($_.Exception)"
        # API URL is Forbidden
        if ( $_.Exception.Response.StatusCode -eq 403 ) {
            $failure_response = "The Management API URL is forbidden. Make sure the API server is configured to accept calls from this machine."
        }
        # There is a reponse body to the failure (the API server returned error message)
        elseif ( $_.Exception.Response ) {
            $failure_response = Extract-WebRequest-Failure-Response -WebResponse $_.Exception.Response
        }
        # There is no failure response (e.g. the API server is not accessbile), throw the full exception
        else {
            $e = $_.Exception
            $failure_response = $e.Message
            if ($e.InnerException) {
                $failure_response = "{0} --> {1}" -f $failure_response,$e.InnerException.Message
            }
        }

        Write-Log -Level ERROR -Message "Failed to make API call - URL: $($web_api_url), failure response: $($failure_response)"
        throw $failure_response
    }
    return $response.Content | ConvertFrom-Json
}

<##################################################################################################
.NAME
    Check-Certificate-Exists
.DESCRIPTION
    Makes an API call to the CheckPoint Security Management API server
.PARAMETER CertificateName
    The name of the certificate to check it's existence
.PARAMETER ManagementIp
    The Check Point Security Management IP address
.PARAMETER ApiPort
    The Management WebAPI port. Default: 443
.PARAMETER Sid
    The API session token, required for all commands but login
##################################################################################################>
function Check-Certificate-Exists 
{
     Param(
        [parameter(mandatory=$true)]
        [string]$CertificateName,
        [parameter(mandatory=$true)]
        [string]$ManagementIp,
        [parameter(mandatory=$false)]
        [string]$ApiPort = "443",
		[parameter(mandatory=$false)]
        [string]$Sid
    )

    $exists = $true
	
    Try {
        $response = Make-Api-Call -ManagementIp $ManagementIp -ApiPort $ApiPort -Command "show-server-certificate" -Payload @{"name" = $CertificateName; } -Sid $Sid
    }
    Catch {
        $exists = $false
    }

    return $exists
}

<##################################################################################################
.NAME
    Extract-WebRequest-Failure-Response 
##################################################################################################>
function Extract-WebRequest-Failure-Response {
    Param(
        [parameter(mandatory=$true)]
        [System.Net.HttpWebResponse]$WebResponse
    ) 
    Write-Log -Level DEBUG -Message "Entered [Extract-WebRequest-Failure-Response], WebResponse: $($WebResponse)"
    Try {
        $response_stream = $WebResponse.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($response_stream)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $reponse = $reader.ReadToEnd()
    }
    Catch {
        Write-Log -Level DEBUG -Message "Failed to extract web request failure response: $($WebResponse)"
        $reponse = null
    }

    return $reponse
}

<##################################################################################################
.NAME
    Wait-Publish-Completion
.DESCRIPTION
    Waits until the task with input TaskID is completed. Returns true if the task result is success,
    False otherwise.
##################################################################################################>
function Wait-Publish-Completion {
    Param(
        [parameter(mandatory=$true)]
        [string]$ManagementIp,
        [parameter(mandatory=$false)]
        [string]$ApiPort,
        [parameter(mandatory=$true)]
        [string]$Sid,
        [parameter(mandatory=$true)]
        [string]$TaskId
    )

    $sleep_time_secs = 3

    # Poll the task status every $sleep_time_secs seconds until it is completed
    Do {
        Start-Sleep -s $sleep_time_secs
        $show_task_response = Make-Api-Call -ManagementIp $ManagementIp -ApiPort $ApiPort -Command "show-task" -Payload @{"task-id" = $TaskId;} -Sid $Sid
    } While ( $show_task_response.tasks[0].status -eq "in progress")

    return $show_task_response.tasks[0]
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
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
        AppObjectDN : a string containing the TPP distiguished name of the calling application object
        AssetName : a string containing a Venafi standard auto-generated name that can be used for provisioning (<Common Name>-<ValidTo as YYMMDD>-<Last 4 of SerialNum>)
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
    
    return @{ Result="NotUsed"; }
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
	$MgmtIp = $General.HostAddress
	$MgmtUser = $General.UserName
	$MgmtPass = $General.UserPass
    $MgmtApiPort = $General.TcpPort

    Write-Log -Level INFO -Message "Beginning certificate addition process to $($General.HostAddress)"
	
	$cert_common_name = Extract-Common-Name -AssetName $General.AssetName
	Write-Log -Level INFO -Message "Extracted certificate common name: ${cert_common_name}"

    # Encoding the Pkcs12 byte-array string to base64
    $certPayload = [Convert]::ToBase64String($Specific.Pkcs12)

    # Encoding the certificate password to byte64
    $pass_byte_arr = [System.Text.Encoding]::UTF8.GetBytes($Specific.EncryptPass)
    $encoded_pass = [Convert]::ToBase64String($pass_byte_arr)
	
    # Logging into the Management server
    Write-Log -Level INFO -Message "Logging into the management server at $($MgmtIp)"
    $login_payload = @{"user" = $MgmtUser; "password" = $MgmtPass; }

    # For MDS environments, add the input domain name parameter to the login request
    if ( $General.VarText1 ) {
        $login_payload."domain" = $General.VarText1
    }
    $login_response = Make-Api-Call -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Command "login" -Payload $login_payload
    if ( ! $login_response.sid )
    {
        Write-Log -Level ERROR -Message "Failed to login to the management server at $($MgmtIp): $($login_response)"
        throw "Login to Management ${MgmtIp} failed. $($login_response)"
    }
	    Write-Log -Level INFO -Message "Login succeeded"

    $session_id = $login_response.sid
    Try {
        # Check if the certificate object already exists (for certificate renewal)
     #   $certificate_exists = Check-Certificate-Exists -CertificateName $cert_common_name -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Sid $session_id 

        # If the certificate object already exists, update the existing object
      #  if ( $certificate_exists ) {
       #     $set_certificate_call_res = Make-Api-Call -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Command "set-server-certificate" -Payload @{"name" = $cert_common_name; "base64-certificate" = $certPayload; "base64-password" = $encoded_pass; } -Sid $session_id
        #    Write-Log -Level INFO -Message "Certificate ${cert_common_name} already exists, content was updated on $($MgmtIp) - Response: $($set_certificate_call_res)"
        #}
        # Otherwise, add a new certificate object to the Security Management Server
        #else {
         #   $add_certificate_call_res = Make-Api-Call -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Command "add-server-certificate" -Payload @{"name" = $cert_common_name; "base64-certificate" = $certPayload; "base64-password" = $encoded_pass; } -Sid $session_id
          #  Write-Log -Level INFO -Message "Certificate ${cert_common_name} was added to $($MgmtIp) - Response: $($add_certificate_call_res)"
		    
		  	   $gateway_name = $General.VarText2
			   if( -Not ($gateway_name)){
					throw "Gateway name cannot be empty."
			   }
			   $ignore_warnings = $General.VarBool1
			   $certificate_settings_payload = @{"base64-certificate" = $certPayload; "base64-password" = $encoded_pass;  }
			   $portal_cert_setting_payload = @{"certificate-settings" = $certificate_settings_payload;  }
		       $set_certificate_call_res = Make-Api-Call -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Command "set-simple-gateway" -Payload @{"name" = $gateway_name; "platform-portal-settings" = $portal_cert_setting_payload; "ignore-warnings" = $ignore_warnings; } -Sid $session_id
			   Write-Log -Level INFO -Message "Platform portal certificate for gateway named '${gateway_name}' was changed - Response: $($set_certificate_call_res)"

       # }	    
        # Publishing the changes
        Write-Log -Level INFO -Message "Publishing..."
        $publish_response = Make-Api-Call -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Command "publish" -Sid $session_id
        $publish_task_id = $publish_response."task-id"

        # Waiting for publish task to finish
        $publish_task_ended_res = Wait-Publish-Completion -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Sid $session_id -TaskId $publish_task_id
        Write-Log -Level INFO -Message "Publish operation completed - Status: $($publish_task_ended_res.status)"

        if ( $publish_task_ended_res.status -ne "succeeded" ) {
            
            throw "Publish operation did not succeed $($publish_task_ended_res."task-details")!"
        }
	}
    Catch {
        # Discard changes after failure
        Write-Log -Level INFO -Message "Discarding changes after failure..."
        $discard_response = Make-Api-Call -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Command "discard" -Sid $session_id
        Write-Log -Level INFO -Message "Changes discarded successfully. $($discard_response)"
        
        # Log out after failure
        Write-Log -Level INFO -Message "Logging out after failure..."
        $logout_response = Make-Api-Call -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Command "logout" -Sid $session_id
        Write-Log -Level INFO -Message "Logged out successfully. $($logout_response)"
        throw $_.Exception
    }
    Write-Log -Level INFO -Message "Logging out..."
    Make-Api-Call -ManagementIp $MgmtIp -ApiPort $MgmtApiPort -Command "logout" -Sid $session_id

    Write-Log -Level INFO -Message "Certificate ${cert_common_name} addition process to ${MgmtIp} finished succesfully!"
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
    
    return @{ Result="NotUsed"; }
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
    
    return @{ Result="NotUsed"; }
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
        
    return @{ Result="NotUsed"; }
}
