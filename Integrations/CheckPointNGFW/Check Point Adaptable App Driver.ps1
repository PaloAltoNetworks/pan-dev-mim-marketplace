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
Text2|NotUsed|000
Text3|NotUsed|000
Text4|NotUsed|000
Text5|NotUsed|000
Option1|NotUsed|000
Option2|NotUsed|000
Passwd|NotUsed|000
-----END FIELD DEFINITIONS-----
#>

if ( -not [System.Reflection.Assembly]::LoadWithPartialName("Venafi.Core") )
{
    # this should only apply when NOT run from a Venafi server
    $dll = [System.IO.File]::ReadAllBytes("$PSScriptRoot\Venafi.Core.dll")
    [System.Reflection.Assembly]::Load($dll) | Out-Null
}

<##################################################################################################
.NAME
    Install-Certificates
.DESCRIPTION
    Installs the multiple certificates and their private keys on the target device or application.
    Implementing logic for this function is REQUIRED.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        HostAddress : a string containing the hostname or IP address specified by the device object
        TcpPort : an integer value containing the TCP port specified by the application object
        UserName : a string containing the username portion of the credential assigned to the device or application object
        UserPass : a string containing the password portion of the credential assigned to the device or application object
        UserPrivKey : the non-encrypted PEM of the private key credential assigned to the device or application object
        VarText1 : a string value for the text custom field defined by the header at the top of this script
        VarText2 : a string value for the text custom field defined by the header at the top of this script
        VarText3 : a string value for the text custom field defined by the header at the top of this script
        VarText4 : a string value for the text custom field defined by the header at the top of this script
        VarText5 : a string value for the text custom field defined by the header at the top of this script
        VarBool1 : a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarBool2 : a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarPass : a string value for the password custom field defined by the header at the top of this script
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        Certificates : an array of hashtables, one for each certificate to be provisioned to the device 
            Name : the certificate Common Name (if exists) or a DNS SAN (if exists) or an OU (if exists), otherwise the serial number
            Certificate : the Base64-encoded X509 certificate PEM
            PrivateKey : the Base64-encoded, non-encrypted private key PEM
            Serial : the serial number of the certificate
            Thumbprint : the SHA1 thumbprint of the certificate
            ValidTo : the expiration date of the certificate as 'YYYYMMDD' string
.NOTES
    Returns...
        Result : 'Success' indicates the non-error completion state
        RejectedCertificates : an array of SHA1 thumbprints for certificates that could not be imported for expected reasons
        FailedCertificates : an array of SHA1 thumbprints for certificates that could not be imported for unexpected reasons
##################################################################################################>
function Install-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    $ManagementIp = $General.HostAddress
    $MgmtUser = $General.UserName
    $MgmtPass = $General.UserPass
    $ApiPort = $General.TcpPort
    $passEncryptP12File = [Guid]::NewGuid().ToString()
    
    # Logging into the Management server
    $login_payload = @{"user" = $MgmtUser; "password" = $MgmtPass; }

    # For MDS environments, add the input domain name parameter to the login request
    if ( $General.VarText1 ) {
        $login_payload."domain" = $General.VarText1
    }

    $login_response = Make-Api-Call -ManagementIp $ManagementIp -ApiPort $ApiPort -Command "login" -Payload $login_payload
    if ( ! $login_response.sid )
    {
        throw "Login to Management ${ManagementIp} failed. $($login_response)"
    }
    $Sid = $login_response.sid

    $FailedCertificates = @()
    $counter_for_publish = $Specific.Certificates.Count
    foreach ( $cert in $Specific.Certificates ) {
        try {
            $cert_common_name = Extract-Common-Name -Name $cert.Name

            Handle-Certificate -cert $cert -passEncryptP12File $passEncryptP12File -cert_common_name $cert_common_name -ManagementIp $ManagementIp -ApiPort $ApiPort -Sid $Sid
            
        } catch {
            Start-Sleep -s 5
            $FailedCertificates += $cert.Thumbprint
            if ( $DEBUG_FILE ) { "Certificate ${cert_common_name} addition process to ${ManagementIp} has FAILED: $($_.Exception.Message)" | Out-File $DEBUG_FILE -Append }
        }

        --$counter_for_publish
        if ($counter_for_publish % 20 -eq 0) {
            Publish-Or-Discard -ManagementIp $ManagementIp -ApiPort $ApiPort -Sid $Sid
        }
    }
    
    Make-Api-Call -ManagementIp $ManagementIp -ApiPort $ApiPort -Command "logout" -Sid $Sid
    
    if ( $FailedCertificates.Count -gt 0 )
    {
        return @{ Result="Success"; FailedCertificates=$FailedCertificates }
    }

    if ( $DEBUG_FILE ) { "All certificates were added succesfully to ${ManagementIp}" | Out-File $DEBUG_FILE -Append }
    return @{ Result="Success"; }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

<##################################################################################################
.NAME
    Get-TimeStamp
##################################################################################################>
function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

<##################################################################################################
.NAME
    Extract-Common-Name
##################################################################################################>
function Extract-Common-Name {
    Param(
        [parameter(mandatory=$true)]
        [string]$Name
    )
    $Name = $Name.replace("-", "")
    $firatChar = $Name[0]
    $isFirstCharLetter = ($firatChar -ge 'A' -and $firatChar -le 'Z') -or ($firatChar -ge 'a' -and $firatChar -le 'z')
    if (!$isFirstCharLetter) {
        $Name = "CERT.." + $Name
    }
    return $Name
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
    
    Start-Sleep -s 1
    $web_api_url = "https://{0}:{1}/web_api/{2}" -f $ManagementIp,$ApiPort,$Command
    
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
    }
    else 
    {
        $postParams = "{}"
    }
    Try {
        $response = Invoke-WebRequest -Uri $web_api_url -UseBasicParsing -Method POST -ContentType "application/json" -Body $postParams  -Headers $headers
    }
    Catch {
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

        throw $failure_response
    }
    return $response.Content | ConvertFrom-Json
}

<##################################################################################################
.NAME
    Handle-Certificate
.DESCRIPTION
    Handle the certificate
.PARAMETER cert
    The certificate
.PARAMETER passEncryptP12File
    The password to encrypt the certificate p12 file
.PARAMETER cert_common_name
    The certificate name
.PARAMETER ManagementIp
    The Check Point Security Management IP address
.PARAMETER ApiPort
    The Management WebAPI port. Default: 443
.PARAMETER Sid
    The API session token
##################################################################################################>
function Handle-Certificate
{
     Param(
        [parameter(mandatory=$true)]
        [System.Collections.Hashtable]$cert,
        [parameter(mandatory=$true)]
        [string]$passEncryptP12File,
        [parameter(mandatory=$true)]
        [string]$cert_common_name,
        [parameter(mandatory=$true)]
        [string]$ManagementIp,
        [parameter(mandatory=$false)]
        [string]$ApiPort = "443",
        [parameter(mandatory=$true)]
        [string]$Sid
    )

    $cert_byte_arr = Convert-PemToP12 -Certificate $cert.Certificate -PrivateKey $cert.PrivateKey `
                            -FriendlyName $null -Password $passEncryptP12File           
    
    # Encoding the Pkcs12 byte-array string to base64
    $certPayload = [Convert]::ToBase64String($cert_byte_arr)

    # Encoding the certificate password to byte64
    $pass_byte_arr = [System.Text.Encoding]::UTF8.GetBytes($passEncryptP12File)
    $encoded_pass = [Convert]::ToBase64String($pass_byte_arr)
    
    # Check if the certificate object already exists (for certificate renewal)
    $certificate_exists = Check-Certificate-Exists -CertificateName $cert_common_name -ManagementIp $ManagementIp -ApiPort $ApiPort -Sid $Sid 

    # If the certificate object already exists, update the existing object
    if ( $certificate_exists ) {
        $set_certificate_call_res = Make-Api-Call -ManagementIp $ManagementIp -ApiPort $ApiPort -Command "set-server-certificate" -Payload @{"name" = $cert_common_name; "base64-certificate" = $certPayload; "base64-password" = $encoded_pass; } -Sid $Sid
    }
    # Otherwise, add a new certificate object to the Security Management Server
    else {
        $add_certificate_call_res = Make-Api-Call -ManagementIp $ManagementIp -ApiPort $ApiPort -Command "add-server-certificate" -Payload @{"name" = $cert_common_name; "base64-certificate" = $certPayload; "base64-password" = $encoded_pass; } -Sid $Sid
    }
    
    if ( $DEBUG_FILE ) { "Certificate ${cert_common_name} addition process to ${ManagementIp} finished succesfully!" | Out-File $DEBUG_FILE -Append }
}

<##################################################################################################
.NAME
    Publish-Or-Discard
.DESCRIPTION
    Publish the changes, and if failed - discard the changes
.PARAMETER ManagementIp
    The Check Point Security Management IP address
.PARAMETER ApiPort
    The Management WebAPI port. Default: 443
.PARAMETER Sid
    The API session token
##################################################################################################>
function Publish-Or-Discard
{
     Param(
        [parameter(mandatory=$true)]
        [string]$ManagementIp,
        [parameter(mandatory=$false)]
        [string]$ApiPort = "443",
        [parameter(mandatory=$true)]
        [string]$Sid
    )
    
    try {
        Handle-Publish -ManagementIp $ManagementIp -ApiPort $ApiPort -Sid $Sid
    } catch {
        try {
            Start-Sleep -s 5
            if ( $DEBUG_FILE ) { "PUBLISH operation has FAILED" | Out-File $DEBUG_FILE -Append }
            Handle-Discard -ManagementIp $ManagementIp -ApiPort $ApiPort -Sid $Sid
        } catch {
            Start-Sleep -s 5
            if ( $DEBUG_FILE ) { "DISCARD operation has FAILED" | Out-File $DEBUG_FILE -Append }
        }
    }
}

<##################################################################################################
.NAME
    Handle-Discard
.DESCRIPTION
    Discard the changes
.PARAMETER ManagementIp
    The Check Point Security Management IP address
.PARAMETER ApiPort
    The Management WebAPI port. Default: 443
.PARAMETER Sid
    The API session token
##################################################################################################>
function Handle-Discard
{
     Param(
        [parameter(mandatory=$true)]
        [string]$ManagementIp,
        [parameter(mandatory=$false)]
        [string]$ApiPort = "443",
        [parameter(mandatory=$true)]
        [string]$Sid
    )
    
    $discard_response = Make-Api-Call -ManagementIp $ManagementIp -ApiPort $ApiPort -Command "discard" -Sid $Sid
    if ($discard_response.message -ne "OK") {
        throw "Changes discarded successfully. $($discard_response)"
    }

    if ( $DEBUG_FILE ) { "DISCARD operation to ${ManagementIp} finished succesfully!" | Out-File $DEBUG_FILE -Append }
    Start-Sleep -s 5
}

<##################################################################################################
.NAME
    Handle-Publish
.DESCRIPTION
    Publish the changes
.PARAMETER ManagementIp
    The Check Point Security Management IP address
.PARAMETER ApiPort
    The Management WebAPI port. Default: 443
.PARAMETER Sid
    The API session token
##################################################################################################>
function Handle-Publish
{
     Param(
        [parameter(mandatory=$true)]
        [string]$ManagementIp,
        [parameter(mandatory=$false)]
        [string]$ApiPort = "443",
        [parameter(mandatory=$true)]
        [string]$Sid
    )
    
    # Publishing the changes
    $publish_response = Make-Api-Call -ManagementIp $ManagementIp -ApiPort $ApiPort -Command "publish" -Sid $Sid
    $publish_task_id = $publish_response."task-id"

    # Waiting for publish task to finish
    $publish_task_ended_res = Wait-Publish-Completion -ManagementIp $ManagementIp -ApiPort $ApiPort -Sid $Sid -TaskId $publish_task_id

    if ( $publish_task_ended_res.status -ne "succeeded" ) {
        
        throw "Publish operation did not succeed $($publish_task_ended_res."task-details")!"
    }
    
    if ( $DEBUG_FILE ) { "PUBLISH operation to ${ManagementIp} finished successfully!" | Out-File $DEBUG_FILE -Append }
    # Sleep for 5 seconds after publish
    Start-Sleep -s 5
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

    Try {
        $response_stream = $WebResponse.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($response_stream)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $reponse = $reader.ReadToEnd()
    }
    Catch {
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


<########## THE FUNCTION IS NOT CALLED DIRECTLY BY VENAFI ##########>
function Convert-PemToP12( [string] $Certificate, [string] $PrivateKey, [string] $FriendlyName, [string] $Password )
{
    $cert = $Certificate -replace "(-----|BEGIN CERTIFICATE|END CERTIFICATE|\r|\n)"

    $x509 = New-Object Security.Cryptography.X509Certificates.X509Certificate2
    $x509.Import([Convert]::FromBase64String($cert))

    $p12_bytes = [Venafi.Core.Cryptography.Pkcs12]::GetBytes($x509, $PrivateKey, $null, $FriendlyName, $Password)

    $x509.Import([byte[]]$p12_bytes, $Password, [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
    $p12_bytes = $x509.Export([Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $Password)

    return $p12_bytes
} 