<#
//---------------------------------------------------------------------------
// Barracuda-Waf.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// This software is licensed by Barracuda Networks, in addition to Venafi.
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


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

$base_path = (Get-Location).Path

if ( (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" )
{
    $base_path = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Scripts"
}

$global:temp_dir = $base_path + "\Temp"

If ( !(Test-Path $global:temp_dir) )
{
   New-Item $global:temp_dir -Type Directory
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

    return @{ Result="Success"; }
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
    # Not in use for WAF
    # for signed certificates, Install certificate API call itself has the private key as part of
    # "certificate-key" : ""
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

    try
    {
        $sessiontoken = Get-BarracudaWAFSession $General.HostAddress $General.TcpPort $General.UserName $General.UserPass
        Install-BarracudaWAFSignedCertificate $sessiontoken $General.HostAddress $General.TcpPort $General.AssetName $Specific
    }
    catch
    {
        throw Decode-Error($_.Exception)
    }
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
    
    try
    {
        $app_obj_dn = $General.AppObjectDN
        $debug_msg = "Update-Binding AppObjectDN " + $app_obj_dn
        Write-BarracudaWAFLog $debug_msg
        $app_obj_arr = $app_obj_dn -split "\\"
        $waf_app_name = $app_obj_arr[$app_obj_arr.Length-1]
        $debug_msg = "Update-Binding Service Name derived from  AppObjectDN" + $waf_app_name
        Write-BarracudaWAFLog $debug_msg

        $CertificateHash = @{ "certificate" = $General.AssetName }
        for ($retry=0; $retry -le 1; $retry++)
        {
            Start-Sleep -Seconds 5
            $sessiontoken = Get-BarracudaWAFSession $General.HostAddress $General.TcpPort $General.UserName $General.UserPass
            $ecdsa_type = Extract-Certificate-Type $sessiontoken $General.HostAddress $General.TcpPort $General.AssetName
            if($ecdsa_type -eq -1)
            {
                continue
            }
            if($ecdsa_type -eq 1)
            {
                $CertificateHash = @{ "ecdsa-certificate" = $General.AssetName }
            }
            break
        }
        Update-BarracudaWAFBinding $sessiontoken $General.HostAddress $General.TcpPort $waf_app_name $CertificateHash

    }
    catch
    {
        throw Decode-Error($_.Exception)
    }
    return @{ Result="Success"; }

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
    

    #call Barrauda function to Extract the certificate with name $General.AssetName
    try
    {
        $sessiontoken = Get-BarracudaWAFSession $General.HostAddress $General.TcpPort $General.UserName $General.UserPass
       $pem = Extract-Certificate-BarracudaWAF $sessiontoken $General.HostAddress $General.TcpPort $General.AssetName
    }
    catch
    {
        Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
        throw Decode-Error($_.Exception)
    }

    return @{ Result="Success"; CertPem="$pem"; Serial=""; Thumprint="" }

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
        
    try
    {
        $sessiontoken = Get-BarracudaWAFSession $General.HostAddress $General.TcpPort $General.UserName $General.UserPass
        Remove-Certificate-BarracudaWAF $sessiontoken $General.HostAddress $General.TcpPort $Specific.AssetNameOld
    }
    catch
    {
        Out-Log -nm_func $MyInvocation.MyCommand.Name -ht_gen $General -ht_spec $Specific
        throw Decode-Error($_.Exception)
    }

    return @{ Result="Success"; }
}



<##################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    Gets a list of all of the Client SSL Certificates belonging to the authenticated account. 
.NOTES
    Returns...
        Result : IEnumerable<ClientSsl>
##################################################################################################>
function Discover-Certificates()
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    [string] $debug_msg = "Starting function Discover-Certificates"
    Write-BarracudaWAFLog $debug_msg
    $apps = @()
    try
    {
        $sessiontoken = Get-BarracudaWAFSession $General.HostAddress $General.TcpPort $General.UserName $General.UserPass
        $apps = Discover-BarracudaWAFCertificates $sessiontoken $General.HostAddress $General.TcpPort $General.UserName $General.UserPass

    }
    catch [System.Net.WebException] {
        $err_msg = Decode-Error($_.Exception)
        Write-BarracudaWAFLog "System.Net.WebException"
        Write-BarracudaWAFLog $err_msg
        throw "Certificate discovery failed. Error: " + $err_msg  
    }
    catch
    {
        $err_msg = Decode-Error($_.Exception)
        throw "Certificate discovery failed. Error: " + $err_msg  
    }

    return @{ Result="Success"; Applications=$apps }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Write-BarracudaWAFLog([string] $msg)
{
	Write-Host "[$(Get-Date)] - [$((Get-PSCallStack)[1].Command)] - $msg" -ForegroundColor Green
    if($DEBUG_FILE) {Add-Content -Path $DEBUG_FILE -Value "[$(Get-Date)] - [$((Get-PSCallStack)[1].Command)] - $msg"}
}


function Decode-Error( [Exception] $ex )
{
    try
    {
        $result = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $json = $reader.ReadToEnd() | ConvertFrom-Json
        
        if ( $json.error )
        {
            return $json.error
        }
        else
        {
            return $ex.Message
        }
    }
    catch # the response is either not xml or not in the expected format
    {
        return $ex.Message
    }
}

#This functions Decodes the Exception and returns the Error 
#response json message received from WAF device
function Decode-Error-Response( [Exception] $ex )
 {
     try
     {
         $result = $ex.Response.GetResponseStream()
         $reader = New-Object System.IO.StreamReader($result)
         $reader.BaseStream.Position = 0
         $reader.DiscardBufferedData()
         $json = $reader.ReadToEnd() | ConvertFrom-Json
         if ( $json.error )
         {
             return $json.error
         }
         else
         {
             return $json #WAF API response message
         }
     }
     catch
     {
         return $ex.Message
     }
 }


<##################################################################################################
.NAME
    Invoke-BarracudaWAFRestMethod
.DESCRIPTION
    This function calls corresponding WAF API. 
.PARAMETERS
    Url , Methos , Bosy , Content-Type, Headers
.NOTES
    Returns
        Result : Returns API response or Throws error
##################################################################################################>



function Invoke-BarracudaWAFRestMethod
{
	Param(
		[Uri] $Uri,
		[Microsoft.PowerShell.Commands.WebRequestMethod] $Method,
		[System.Object] $Body,
		[string] $ContentType,
        [System.Collections.IDictionary] $Headers
	)
	try
	{
       
        add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

    $AllProtocols = [System.Net.SecurityProtocolType]'Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


        $debug_msg = "Invoke-BarracudaWAFRestMethod API $Uri Method: $Method"
        Write-BarracudaWAFLog $debug_msg

        #$response = Invoke-RestMethod -SkipCertificateCheck -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType
        $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType

        return @{
            response=$response;
        }
	}
	catch [System.Net.WebException]{
		[string] $debug_msg = "REST call FAILED  {0}" -f $Uri.AbsoluteUri
		Write-BarracudaWAFLog $debug_msg
        Write-BarracudaWAFLog $_ 
		if($_.Exception.Response){
			[string] $debug_msg = "Status Code of response : {0}" -f $_.Exception.Response.StatusCode.value__.ToString()
            if($_.Exception.Response.StatusCode.value__.ToString() -eq '406')
            {
                $err_response = Decode-Error-Response $_.Exception
                Write-BarracudaWAFLog $err_response
                #if Duplicate Certificate , create custom Exception
                if( $err_response.msg -contains "Duplicate certificate name is not allowed.")
                {
                    throw [System.Net.WebException]::New($err_response.msg)
                }
                if( $err_response.msg -like "*Certificate is bound to at least one of the Services*")
                {
                    throw [System.Net.WebException]::New($err_response.msg)
                }
            }
		}
		else{
			$debug_msg = Decode-Error $_.Exception
			Write-BarracudaWAFLog $debug_msg
		}
		throw $_
	}
    catch
    {
        
        $err_msg = $_.Exception | Out-String
        $debug_msg = "REST call failed to  " + $Uri + " Method: "+ $Method + " Error : " + $err_msg
        Write-BarracudaWAFLog $debug_msg
        throw $_
    }
}
<##################################################################################################
.NAME
    Get-BarracudaWAFSession
.DESCRIPTION
    This function calls WAF Login api to fetch Authorization token which is used for in rest of API calls. 
.PARAMETERS
    Host IP , Host Port , User Name , password
.NOTES
    Returns
        Result : Returns Authorization Token
##################################################################################################>

function Get-BarracudaWAFSession( [string] $addr, [string] $port,[string] $user, [string] $pass )
{
    [string] $url = "https://{0}:{1}/restapi/v3.1/login" -f $addr,$port
    [string] $debug_msg = "Login URL: {0}" -f $url
    Write-BarracudaWAFLog $debug_msg
    
    $body = @{
        "username"=$user;
        "password"=$pass
    } | ConvertTo-Json
    

    [string] $debug_msg = "Doing REST call (POST) for " + $url + " Port :" + $General.TcpPort
    Write-BarracudaWAFLog $debug_msg
	try {

        $resp_obj = Invoke-BarracudaWAFRestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
        $response = $resp_obj.response
        $token    = $response.token
        return $token
    }
    catch [System.Net.WebException] {
        $err_msg = Decode-Error($_.Exception)
        Write-BarracudaWAFLog "Get-BarracudaWAFSession System.Net.WebException"
        Write-BarracudaWAFLog $err_msg
        throw "Get-BarracudaWAFSession. Error: " + $err_msg  
    }
    catch
    {
        $err_msg = Decode-Error($_.Exception)
        throw "Certificate discovery failed. Error: " + $err_msg  
    }
      
}

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

<##################################################################################################
.NAME
    Install-BarracudaWAFSignedCertificate
.DESCRIPTION
    This function calls WAF api to bind the certificate to an Application. 
.PARAMETERS
    Login Token, Host IP , Host Port , Certificate Name , $Specific Hash( Venafi Object)
.NOTES
    Returns
        Result : Returns Success / Failure
##################################################################################################>
function Install-BarracudaWAFSignedCertificate 
{
    Param(
		[string] $sessiontoken,
		[string] $addr,
        [string] $port,
        [string] $waf_cacert_name,
        [System.Collections.Hashtable]$Specific
	)

    [string] $url = "https://{0}:{1}/restapi/v3.1/certificates/signed-certificate" -f $addr,$port

    $auth_str = $sessiontoken + ":"
    $EncodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($auth_str))
    $Headers = @{ 'Authorization' = "Basic $EncodedCredential" }
    
    #$private_key = $Specific.PrivKeyPem | convert to non rsa 

    ##########################################################################################
    # To keep it simple, Using PKCS12 format to upload to Certificate on WAF so that we dont 
    # have to upload the private key 
    ##########################################################################################
    $enc_passwd = $Specific.EncryptPass
    $InsertLineBreaks = 1
    $EncodedCert = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Specific.CertPem),$InsertLineBreaks)
    $Encodedkey =  [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Specific.PrivKeyPem),$InsertLineBreaks)

    $key_type = "rsa"
    if ($Specific.PrivKeyPem -imatch '^---*BEGIN EC PRIVATE KEY*')
    {
        $key_type = "ecdsa"
    } 
    # “assign-associated-key” = “Yes” , if there is no private key is sent
    # if “assign-associated-key” = No, “certificate-key” = $certificate_key;
    $CertificateHashWithKey = @{
        "key-type" = $key_type ;
        "signed-certificate" = $EncodedCert ;
        "name" = $waf_cacert_name ; 
        "certificate-type" = "PEM Certificate"; 
        “certificate-key” = $Encodedkey;
        "allow-private-key-export" = "Yes";
        “assign-associated-key” = "No"
    } | ConvertTo-Json
    
    try
    {
        $resp_obj = Invoke-BarracudaWAFRestMethod -Uri $url -Method Post -Body $CertificateHashWithKey -ContentType "application/json" -Headers $Headers
    }
    catch [System.Net.WebException]{
		Write-BarracudaWAFLog "Exception in Installing Cert"
        Write-BarracudaWAFLog $_
        if($_ -match "Duplicate certificate name")
        {
            return
        }
        else {
            throw $_
        }
    }
    catch {
        throw $_
    }
}
<##################################################################################################
.NAME
    Extract-Certificate-Type
.DESCRIPTION
    This function calls WAF api to get the uploaded certificate from WAF and depending on paramaters
    returns Certificate type.
.PARAMETERS
    Login Token, Host IP , Host Port , Certificate Name
.NOTES
    Returns
        Result : Returns 0 or 1. 1=Certificate type is ECDSA
##################################################################################################>

function Extract-Certificate-Type
{
    Param(
		[string] $sessiontoken,
		[string] $addr,
        [string] $port,
        [string] $certificate_name
	)
    [string] $url = "https://{0}:{1}/restapi/v3.1/certificates/signed-certificate/$certificate_name" -f $addr,$port
    $auth_str = $sessiontoken + ":"
    $EncodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($auth_str))
    $Headers = @{ 'Authorization' = "Basic $EncodedCredential" }
    try {
        $resp_json = Invoke-BarracudaWAFRestMethod -Uri $url -Method GET -ContentType "application/json" -Headers $Headers
        $cert_data = $($resp_json.response)
        $data_hash = $cert_data.data | ConvertTo-Json | ConvertFrom-Json
        $debug_msg = " Extracted certificate details : " + $data_hash.$certificate_name
        Write-BarracudaWAFLog $debug_msg
        $ecdsa_type = 0
        if( $($data_hash.$certificate_name)."key-type" -eq "ECDSA")
        {
            $ecdsa_type = 1;
        }
        $debug_msg = "Successfully Extracted Certificate " + $certificate_name + " CERT " + $cert + " ECDSA type " + $ecdsa_type
        Write-BarracudaWAFLog $debug_msg
        return $ecdsa_type
    }
    catch {

        throw Decode-Error($_.Exception)
    }
}

 <##################################################################################################
.NAME
    Update-BarracudaWAFBinding
.DESCRIPTION
    This function calls WAF api to bind the certificate to an Application. 
.PARAMETERS
    Login Token, Host IP , Host Port , Application Name , Certificate Object
.NOTES
    Returns
        Result : Returns Success / Failure
##################################################################################################>
function Update-BarracudaWAFBinding
{
    Param(
		[string] $sessiontoken,
		[string] $addr,
        [string] $port,
        [string] $service_name,
		[System.Object] $CertificateHash
	)

    #if Service Names are comma seperated, Call update binding for Each application.
    $service_list = @()
    $debug_msg = "Service List :" + $service_name
    Write-BarracudaWAFLog $debug_msg
    $service_list  = $service_name -split ","
    
    for($i= 0 ; $i -lt $service_list.Length; $i++)
    {
        [string] $url = "https://{0}:{1}/restapi/v3.1/services/{2}/ssl-security" -f $addr,$port,$service_list[$i]
        $auth_str = $sessiontoken + ":"
        $EncodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($auth_str))
        $Headers = @{ 'Authorization' = "Basic $EncodedCredential" }

        $Body = $CertificateHash | ConvertTo-Json
        $resp_obj = Invoke-BarracudaWAFRestMethod -Uri $url -Method PUT -Body $Body -ContentType "application/json" -Headers $Headers
        $resp_data = $resp_obj | ConvertTo-Json
        $debug_msg = "Response for Bind Signed cert: " + $resp_data
        Write-BarracudaWAFLog $debug_msg
        return @{ Result="Success"; }
    }
}


 <##################################################################################################
.NAME
    Extract-Certificate-BarracudaWAF
.DESCRIPTION
    This function calls WAF api to downloads the certificate from WAF and depending on paramaters 
    extracts-private-key as well.
.PARAMETERS
    Login Token, Host IP , Host Port , Certificate Name
.NOTES
    Returns
        Result : Returns Certificate Object
        /restapi/v3.1/certificates/signed-certificate/<certificate name> does not return certificate. Hence not using it
##################################################################################################>
function Extract-Certificate-BarracudaWAF
{
    Param(
		[string] $sessiontoken,
		[string] $addr,
        [string] $port,
        [string] $certificate_name
	)
    [string] $url = "https://{0}:{1}/restapi/v3.1/certificates/$certificate_name" -f $addr,$port
    $auth_str = $sessiontoken + ":"
    $EncodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($auth_str))
    $Headers = @{ 'Authorization' = "Basic $EncodedCredential" }

    try {
        $resp_json = Invoke-BarracudaWAFRestMethod -Uri $url -Method GET -ContentType "application/json" -Headers $Headers
        #$resp_hash =  $resp_json | ConvertFrom-Json
        #$cert_data = $resp_hash.details
        $cert_data = $($resp_json.response).details
        $cert_str = $cert_data | Out-String
        $index = $cert_str.IndexOf("-----BEGIN CERTIFICATE-----")
        $cert = $cert_str.Substring($index)
        $debug_msg = "Successfully Extracted Certificate" + $certificate_name
        Write-BarracudaWAFLog $debug_msg
        return $cert
    }
    catch {

        throw Decode-Error($_.Exception)
        
    }     
}

function Check-SNI-Certificate
{
    Param(
		[string] $sessiontoken,
		[string] $addr,
        [string] $port,
        [string] $service_name,
        [string] $certificate_name
	)
    $debug_msg = " Parameters Service Name" + $service_name + " Certificate " + $certificate_name
    Write-BarracudaWAFLog $debug_msg
    [string] $url = "https://{0}:{1}/restapi/v3.1/services/{2}/ssl-security" -f $addr,$port,$service_name
    $auth_str = $sessiontoken + ":"
    $EncodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($auth_str))
    $Headers = @{ 'Authorization' = "Basic $EncodedCredential" }
    $sni_flag = 1
    try
    {
        $resp_json = Invoke-BarracudaWAFRestMethod -Uri $url -Method GET -ContentType "application/json" -Headers $Headers
        $cert_data = $($resp_json.response)
        $ssl_data = $($($cert_data.data).$service_name)."SSL Security"
        if($ssl_data.certificate -eq $certificate_name -or $ssl_data."ecdsa-certificate" -eq $certificate_name)
        {
            $sni_flag = 0
        }
        $debug_msg = "SSL Security Name:" + $ssl_data.certificate + " SSL ECDSA:" + $ssl_data."ecdsa-certificate" + " Curr Cert Name:" + $certificate_name + " SNI FLAG=" + $sni_flag
        Write-BarracudaWAFLog $debug_msg
        return $sni_flag
    }
    catch {
        Decode-Error($_.Exception)
        return 401
    }
    return $sni_flag
}

<##################################################################################################
.NAME
    Discover-BarracudaWAFCertificates
.DESCRIPTION
    On board Discovery of Barracuda WAF Certificates. Venaafi Adaptable Framework supports only Server 
    certificate Management. Trusted CA Certificate management is not yet supported in Venafi Adaptable 
    framework. Hence on board discovery of WAF devies, calls restapi/v3.1/certificates/signed-certificate
    api to fetch all the certificates created and associated with WAF applications.
.PARAMETERS
    Login Token, Host IP , Host Port, Login User name, Login Password
.NOTES
    Returns
        Result : Array of Hashes containing Certificate in PEM format, Application Name
##################################################################################################>
function Discover-BarracudaWAFCertificates ( [string] $sessiontoken, [string] $addr , [string] $port , [string] $user_name , [string] $password)
{
    #/restapi/v3.1/certificates/signed-certificate --> does not return certificate content so using /restapi/v3.1/certificates end point
    [string] $url = "https://{0}:{1}/restapi/v3.1/certificates" -f $addr,$port

    $secureString = convertto-securestring $sessiontoken -asplaintext -force
    $auth_str = $sessiontoken + ":"
    $EncodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($auth_str))
    $header = @{ 'Authorization' = "Basic $EncodedCredential" }

    try {

        $resp_obj = Invoke-BarracudaWAFRestMethod -Uri $url -Method GET -ContentType "application/json" -Headers $header
        $cert_count = $($resp_obj["response"])  | ConvertTo-Json | ConvertFrom-Json

        $cert_count.data.psobject.properties | foreach -begin {$h=@{}} -process { $h."$($_.Name)" = $_.Value }  -End {$h}
        $arr_json = $h["SyncRoot"] | ConvertTo-Json | ConvertFrom-Json
        $debug_msg = "Total Certificates Discovered :" + $h.length
        Write-BarracudaWAFLog $debug_msg  
        $apps = @()
        for($i = 0; $i –lt $h.length; $i++)
        {
            $cert_obj = $arr_json[$i]
            $app_name = $cert_obj[0].services
            $cert_type = $cert_obj[0].type
            $certificate_name = $cert_obj[0].Name
            if($cert_type -eq "trusted_certificates" -or $cert_type -eq "trusted_server_certificates")
            {
                continue
            }
            if( $app_name -eq "No Service" -or $app_name -eq "N/A" -or $app_name -eq "Admin Login SSO")
            {
                continue
            }
            $pem_data = $cert_obj[0].details
            $pem_str = $pem_data | Out-String
            $index = $pem_str.IndexOf("-----BEGIN CERTIFICATE-----")
            $pem = $pem_str.Substring($index)
            # if the service name has comma, generate multiple apps splitting service name by comma
            $service_list = @()
            $debug_msg = "Service List In Discovery:" + $app_name
            Write-BarracudaWAFLog $debug_msg
            $service_list  = $app_name -split ","
            Write-BarracudaWAFLog "Service names"
            Write-BarracudaWAFLog $service_list
            for($j= 0 ; $j -lt $service_list.Length; $j++)
            {
                $apps += @{
                    Name = $service_list[$j].Trim();
                    CertificateName = $certificate_name;
                    ApplicationClass = "Adaptable App";
                    PEM = $pem;
                }
            }
        }
        # Above is an array of hashes with service name, certificate name and certificate object
        # For each hash in above array call <service name>/ssl-security api
        # Compare the certificate name in above hash object for the service against the response.certificate value
        # If it matches, then its a valid certificate to be added to Venafi TPP
        # Similary Compare the certificate name in above hash object for the service against the response.ecdsa-certificate value
        # If it matches, then its a valid cetificate to be added to Venafi TPP
        # Note if one service is associated with one RSA and another ECDSA certificate
        # then one <service name>-obsolete app will get created on Venafi TPP as Venafi does not support
        # multiple certificate association with one application

        $return_apps = @()
        $count=0
        foreach($app_index in $apps )
        {
            $count++
            $sni_test = Check-SNI-Certificate $sessiontoken $addr $port $app_index.Name $app_index.CertificateName
            $debug_msg = " Check-SNI-Certificate return value = " + $sni_test + " For App:" + $app_index.Name + " And Certificate:" + $app_index.CertificateName + " Counter = " + $count
            Write-BarracudaWAFLog $debug_msg
            if($sni_test -eq 401)
            {
                $sessiontoken = Get-BarracudaWAFSession $addr $port $user_name $password
                $sni_test = Check-SNI-Certificate $sessiontoken $addr $port $app_idex.Name $app_idex.CertificateName
                $debug_msg = "Check-SNI-Certificate return value after relogin = " + $sni_test +" Counter = " + $count
                Write-BarracudaWAFLog $debug_msg
            }
            if( $sni_test -eq 0)
            {
                $return_apps += @{
                    Name = $app_index.Name;
                    ApplicationClass = "Adaptable App";
                    PEM = $app_index.PEM;
                }

            }
        }
        return $return_apps
    }
    catch {
        $debug_msg = Decode-Error $_.Exception
        Write-BarracudaWAFLog "Discover-BarracudaWAFCertificates Failed with Error"
        Write-BarracudaWAFLog $debug_msg
        throw $_
    }
}



function Remove-Certificate-BarracudaWAF
{
    Param(
		[string] $sessiontoken,
		[string] $addr,
        [string] $port,
        [string] $certificate_name
	)
    [string] $debug_msg = "Remove-Certificate-BarracudaWAF Parameters Cert name " + $certificate_name
    Write-BarracudaWAFLog $debug_msg

    [string] $url = "https://{0}:{1}/restapi/v3.1/certificates/signed-certificate/$certificate_name" -f $addr,$port
    $auth_str = $sessiontoken + ":"
    $EncodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($auth_str))
    $Headers = @{ 'Authorization' = "Basic $EncodedCredential" }
    try {
        $resp_obj = Invoke-BarracudaWAFRestMethod -Uri $url -Method DELETE  -Headers $Headers
        $resp_data = $resp_obj | ConvertTo-Json
        $debug_msg = "Response for Remove-Certificate-BarracudaWAF: " + $resp_data
        Write-BarracudaWAFLog $debug_msg
        return @{ Result="Success"; }
    }
    catch [System.Net.WebException]
    {
        Write-BarracudaWAFLog "Exception in Removing Cert"
        Write-BarracudaWAFLog $_
        if($_ -like "*Certificate is bound to at least one of the Services*")
        {
            return @{ Result="Success"; }
        }
        if($_ -like "*(404) Not Found*")
        {
            return @{ Result="Success"; }
        }
        else {
            throw $_
        }
    }
    catch {
        throw $_
    }

}

