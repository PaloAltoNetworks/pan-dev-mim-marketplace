<#
//---------------------------------------------------------------------------
// Avi Vantage.ps1
//
// Version 3.0
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by INSERT DEVELOPER NAME, in addition to Venafi.
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
Text1|Virtual Service|100
Text2|Tenant|100
Text3|Not Used|000
Text4|Not Used|000
Text5|Not Used|000
Option1|Not Used|000
Option2|Not Used|000
Passwd|Not Used|000
-----END FIELD DEFINITIONS-----
#>

# need the following to interface with an untrusted certificate
Add-Type -TypeDefinition @"
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
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

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
##################################################################################################>
function Generate-CSR
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
	[string] $debug_msg = "Starting function"
	Write-AviLog $debug_msg
	if ( -not $($Specific.SubjectDn.CN) )
    {
        throw "Common Name is required by Avi Vantage for remotely generated CSRs."
    }
    else
    {
        $subject = @{ "common_name"=$($Specific.SubjectDn.CN) }
    }

    if ( $Specific.SubjectDn.OU )
    {
        # only one OU is currently supported so we always use the first if there are many
        $subject.Add( "organization_unit", $Specific.SubjectDn.OU[0] )
    }

    if ( $Specific.SubjectDn.O )
    {
        $subject.Add( "organization", $Specific.SubjectDn.O )
    }

    if ( $Specific.SubjectDn.L )
    {
        $subject.Add( "locality", $Specific.SubjectDn.L )
    }

    if ( $Specific.SubjectDn.ST )
    {
        $subject.Add( "state", $Specific.SubjectDn.ST )
    }

    if ( $Specific.SubjectDn.C )
    {
        $subject.Add( "country", $Specific.SubjectDn.C )
    }

    $sans_dns = @() + $($Specific.SubjAltNames.DNS | ? {$_})  # an array of DNS Subject Alternative Names, possibly empty

    try
    {
        $session = Get-AviSession $General.HostAddress $General.UserName $General.UserPass

        $headers = @{
			"content-type"="application/json";
			"referer"="https://$($General.HostAddress)";
			"X-Avi-Tenant"=$General.VarText2;
			"x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
        }

        [string] $url = "https://$($General.HostAddress)/api/sslkeyandcertificate"

        $body = @{
        	"name"=$General.AssetName;
	        "certificate"=@{
		        "self_signed"=$false;
		        "subject"=$subject;
                "subject_alt_names"=$sans_dns;
	        };
            "type"="SSL_CERTIFICATE_TYPE_VIRTUALSERVICE";
            "key_params"=@{
                "algorithm"="SSL_KEY_ALGORITHM_RSA";
                "rsa_params"=@{
                    "key_size"=$("SSL_KEY_" + $Specific.KeySize + "_BITS")
                }
            }
        } | ConvertTo-Json

		[string] $debug_msg = "Doing REST call (POST) for {0}" -f $url
		Write-AviLog $debug_msg
        $resp_obj = Invoke-AviRestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json" -WebSession $session
		$csr_uuid = $resp_obj.response.uuid
		[string] $debug_msg = "New CSR UUID: {0}" -f $csr_uuid
		Write-AviLog $debug_msg
		[string] $url = "https://$($General.HostAddress)/api/sslkeyandcertificate/$csr_uuid"
		[string] $debug_msg = "Doing REST call (GET) for {0}" -f $url
		Write-AviLog $debug_msg
		$resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json" -WebSession $session
        $csr = $resp_obj.response.certificate.certificate_signing_request

        return @{ Result="Success"; Pkcs10=$csr }
    }
    catch
    {
        throw Decode-Error($_.Exception)
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
	[string] $debug_msg = "Starting function"
	Write-AviLog $debug_msg
    try
    {
        $session = Get-AviSession $General.HostAddress $General.UserName $General.UserPass
		[string] $debug_msg = "Got login session"
		Write-AviLog $debug_msg
        $headers = @{
			"content-type"="application/json";
			"referer"="https://$($General.HostAddress)";
			"X-Avi-Tenant"=$General.VarText2;
			"x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
        }
        if ( $Specific.ChainPkcs7 )
        {
            $chain = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
            $chain.Import( $Specific.ChainPkcs7 )
            foreach ( $cert in $chain )
            {
                $is_installed = $false
                $cacert_name = $cacert_basename = Get-CACertName $cert
				for ( $i=0; $i -lt 10; $i++ ) 
                {
                    [string] $debug_msg = "Will be uploading CA certificate with name: {0}" -f $cacert_name
					Write-AviLog $debug_msg
					# check to see if a certificate already exists by the name
                    $url = "https://$($General.HostAddress)/api/sslkeyandcertificate?name=$cacert_name&export_key=false"
                    [string] $debug_msg = "Doing REST call (GET) for {0}" -f $url
					Write-AviLog $debug_msg
					$resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json" -WebSession $session
                    $response = $resp_obj.response
					if ( $response.Count -ne 0 ) # name collision, is it the same cert?
                    {
						[string] $debug_msg = "Certificate with name {0} exists" -f $cacert_name
                        Write-AviLog $debug_msg
						$pem = $response.results.certificate.certificate
                        $pem = $pem.Replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----","")
                        $cert_existing = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                        $cert_existing.Import([Convert]::FromBase64String($pem))
                        if ( $cert_existing.Equals($cert) ) # this certificate is already installed
                        {
							[string] $debug_msg = "Certificate {0} already exists. No need to install again." -f $cacert_name
							Write-AviLog $debug_msg
                            $is_installed = $true
							break
                        }
                        else # append an integer and test that name for uniqueness
                        {
							[string] $debug_msg = "Different certificate with name {0} exists" -f $cacert_name
							Write-AviLog $debug_msg
                            $cacert_name = $cacert_basename + "_" + $idx
                        }
                    }
                    else # install the CA certificate
                    {
                        $pem = [Convert]::ToBase64String($cert.RawData, [System.Base64FormattingOptions]::InsertLineBreaks)
                        $url = "https://$($General.HostAddress)/api/sslkeyandcertificate"
                        $body = @{
                            "certificate"=@{
                                "certificate"="-----BEGIN CERTIFICATE-----`n$pem`n-----END CERTIFICATE-----"
                            };
                            "name"=$cacert_name;
                            "type"="SSL_CERTIFICATE_TYPE_CA"
                        } | ConvertTo-Json
						[string] $debug_msg = "Doing REST call (POST) for {0}" -f $url
						Write-AviLog $debug_msg
                        Invoke-AviRestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json" -WebSession $session
                        $is_installed = $true
                        break
                    }
                }
                if ( -not $is_installed )
                {
                    throw "Automatic name conflict resolution threshold was exceeded for '" + $cacert_basename + "'"
                }
            }
        }
		[string] $debug_msg = "Installed CA chain"
		Write-AviLog $debug_msg
        return @{ Result="Success"; }
    }
    catch
    {
        throw Decode-Error($_.Exception)
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

    return @{ Result="NotUsed" }
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
    [string] $debug_msg = "Starting function"
	Write-AviLog $debug_msg
    try
    {
        $session = Get-AviSession $General.HostAddress $General.UserName $General.UserPass
        [string] $debug_msg = "Got login session"
		Write-AviLog $debug_msg
        $cert = $Specific.CertPem
        $key = $Specific.PrivKeyPem
        $headers = @{
			"content-type"="application/json";
			"referer"="https://$($General.HostAddress)";
            "X-Avi-Tenant"=$General.VarText2;
			"x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
        }
		[string] $debug_msg = "AssetName given by Venafi: {0}" -f $General.AssetName
		Write-AviLog $debug_msg
        if ( $key ) # this is central generation
        {
            # check to see if a certificate already exists by the name
            $url = "https://$($General.HostAddress)/api/sslkeyandcertificate?name=$($General.AssetName)&export_key=false"
            [string] $debug_msg = "Doing REST call (GET) for {0}" -f $url
			Write-AviLog $debug_msg
			$resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json" -WebSession $session
			$response = $resp_obj.response
            if ( $response.Count -ne 0 ) # name collision, is it the same cert?
            {
				[string] $debug_msg = "Found existing certificate with name {0}" -f $General.AssetName
				Write-AviLog $debug_msg
                $pem = $cert.Replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----","")
                $cert_installing = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                $cert_installing.Import([Convert]::FromBase64String($pem))
                $pem = $response.results.certificate.certificate
                $pem = $pem.Replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----","")
                $cert_existing = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                $cert_existing.Import([Convert]::FromBase64String($pem))
                if ( $cert_existing.Equals($cert_installing) ) # this certificate is already installed
                {
					[string] $debug_msg = "Certificate is already installed"
					Write-AviLog $debug_msg
                    return @{ Result="AlreadyInstalled"; }
                }
                else
                {
					[string] $debug_msg = "Different certificate exists with name {0}" -f $General.AssetName
					Write-AviLog $debug_msg
                    throw "A different certificate already exists with the name '" + $General.AssetName + "'"
                }
            }
            $url = "https://$($General.HostAddress)/api/sslkeyandcertificate"            
            $body = @{
	            "certificate"=@{
		            "certificate"=$cert;
	            };
                "key"=$key;
	            "name"=$General.AssetName;
                "type"="SSL_CERTIFICATE_TYPE_VIRTUALSERVICE"
            } | ConvertTo-Json
			[string] $debug_msg = "Doing REST call (POST) for {0}" -f $url
			Write-AviLog $debug_msg
            # Note: this call requires the x-csrftoken HTTP header to avoid (401) Unauthorized
            Invoke-AviRestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json" -WebSession $session
            return @{ Result="Success"; }
        }
        else # this is remote generation
        {
            # lookup the CSR
            $url = "https://$($General.HostAddress)/api/sslkeyandcertificate?name=$($General.AssetName)&export_key=false"
            [string] $debug_msg = "Doing REST call (GET) for {0}" -f $url
			Write-AviLog $debug_msg
			$resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json" -WebSession $session
			$response = $resp_obj.response
            if ( $response.Count -ne 0 ) # found it
            {
                if ( -not $response.results.certificate.certificate )
                {
                    # install the certificate
                    $url = $response.results.url
					#$response.results.certificate.certificate = $cert
					$response.results.certificate | Add-Member -MemberType NoteProperty -Name 'certificate' -Value $cert
                    $body = $response.results | ConvertTo-Json

                    # Note: this call requires the x-csrftoken HTTP header to avoid (401) Unauthorized
					[string] $debug_msg = "Doing REST call (PUT) for {0}" -f $url
					Write-AviLog $debug_msg
                    Invoke-AviRestMethod -Uri $url -Method Put -Headers $headers -Body $body -ContentType "application/json" -WebSession $session
                    return @{ Result="Success"; }
                }
                else
                {
                    throw "A certificate is unexpectedly already installed on '" + $General.AssetName + "'"
                }
            }
            else
            {
                throw "Remotely generated CSR was not found with name '" + $General.AssetName + "'"
            }
        }
    }
    catch
    {
        throw Decode-Error($_.Exception)
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
	[string] $debug_msg = "Starting function"
	Write-AviLog $debug_msg
    $session = Get-AviSession $General.HostAddress $General.UserName $General.UserPass
	[string] $debug_msg = "Got login session"
	Write-AviLog $debug_msg
	$tenant_name = $General.VarText2
    $headers = @{
		"content-type"="application/json";
		"referer"="https://$($General.HostAddress)";
		"X-Avi-Tenant"=$tenant_name;
		"x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
    }
	$vs_name = $General.VarText1
    # Get Virtual Service UUID
    $url = "https://$($General.HostAddress)/api/virtualservice?name={0}" -f $vs_name
	[string] $debug_msg = "Doing REST Call (GET) for {0}" -f $url
	Write-AviLog $debug_msg
	$resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -WebSession $session
	$resp_vs = $resp_obj.response
	if($resp_vs.count -eq 0)
	{
		[string] $debug_msg = "No VS with name {0} found" -f $vs_name
		Write-AviLog $debug_msg
		throw $debug_msg
	}
	$vs_uuid = $resp_vs.results[0].uuid
   
    # Get Certificate UUID
	$cert_avi_name = $General.AssetName
    $url = "https://$($General.HostAddress)/api/sslkeyandcertificate?name={0}" -f $cert_avi_name
    [string] $debug_msg = "Doing REST Call (GET) for {0}" -f $url
	Write-AviLog $debug_msg
	$resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -WebSession $session
	$resp = $resp_obj.response
	if($resp.count -eq 0)
	{
		[string] $debug_msg = "No Certificate with name {0} found" -f $cert_avi_name
		Write-AviLog $debug_msg
		throw $debug_msg
	}
    $cert_uuid = $resp.results[0].url
 
    # Associate certificate with virtual service instance
    $url = "https://$($General.HostAddress)/api/virtualservice/" + $vs_uuid
   
    $body = $resp_vs.results[0]
    $body.ssl_key_and_certificate_refs=@( $cert_uuid ) 
    $body = $body | ConvertTo-Json -depth 100

    # Note: this call requires the x-csrftoken HTTP header to avoid (401) Unauthorized
	[string] $debug_msg = "Doing REST Call (POST) for {0}" -f $url
    Write-AviLog $debug_msg
	Invoke-AviRestMethod -Uri $url -Method Put -Headers $headers -Body $body -ContentType "application/json" -WebSession $session
	$debug_msg = "Updated {0} with new certificate" -f $vs_name
	Write-AviLog $debug_msg
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
    [string] $debug_msg = "Starting function"
	Write-AviLog $debug_msg
    try
    {
		$session = Get-AviSession $General.HostAddress $General.UserName $General.UserPass
		[string] $debug_msg = "Got login session"
		Write-AviLog $debug_msg
		$headers = @{
			"content-type"="application/json";
			"referer"="https://$($General.HostAddress)";
			"X-Avi-Tenant"=$General.VarText2;
			"x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
		}
        $url = "https://$($General.HostAddress)/api/sslkeyandcertificate?name=$($General.AssetName)&export_key=false"
		[string] $debug_msg = "Doing REST call (GET) for {0}" -f $url
		Write-AviLog $debug_msg
        $resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json" -WebSession $session
		$response = $resp_obj.response
        if ( $response.Count -ne 0 ) # certificate exists
        {
			[string] $debug_msg = "Found certificate with name: {0}" -f $General.AssetName
            Write-AviLog $debug_msg
			$pem = $response.results.certificate.certificate
            $idx = $response.results.certificate.fingerprint.IndexOf('=')
            $thumbprint = $response.results.certificate.fingerprint.Remove(0,$idx+1).Replace(":","").ToLower().Trim()
            $serial = "{0:x}" -f [bigint]$($response.results.certificate.serial_number)
            return @{Result="Success"; CertPem="$pem"; Serial="$serial"; Thumprint="$thumbprint"}
        }
        else
        {
			[string] $debug_msg = "No certificate named {0} was found" -f $General.AssetName
			Write-AviLog $debug_msg
            throw "No certificate named '" + $General.AssetName + "' was found."
        }
    }
    catch
    {
        throw Decode-Error($_.Exception)
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
	[string] $debug_msg = "Starting function"
	Write-AviLog $debug_msg
    try
    {
		$session = Get-AviSession $General.HostAddress $General.UserName $General.UserPass
		[string] $debug_msg = "Got login session"
		Write-AviLog $debug_msg
		$tenant_name = $General.VarText2
		$headers = @{
			"content-type"="application/json";
			"referer"="https://$($General.HostAddress)";
			"X-Avi-Tenant"=$tenant_name;
			"x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
		}
        $url = "https://$($General.HostAddress)/api/sslkeyandcertificate?name=$($General.AssetName)&export_key=true"
		[string] $debug_msg = "Doing REST call (GET) for {0}" -f $url
		Write-AviLog $debug_msg
        $resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json" -WebSession $session
		$response = $resp_obj.response
        if ( $response.Count -ne 0 ) # certificate and private key exist
        {
			[string] $debug_msg = "Key found"
			Write-AviLog $debug_msg
            $pem = $response.results.key
            return @{ Result="Success"; PrivKeyPem="$pem" }
        }
        else
        {
			[string] $debug_msg = "No certificate named {0} was found to export private key" -f $General.AssetName
			Write-AviLog $debug_msg
            throw "No certificate named '" + $General.AssetName + "' was found to export private key."
        }
    }
    catch
    {
        throw Decode-Error($_.Exception)
    }
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
	[string] $debug_msg = "Starting function"
	Write-AviLog $debug_msg
	$cert_avi_name = $Specific.AssetNameOld
	[string] $debug_msg = "Certificate with name: {0} in AVI Controller will be deleted" -f $cert_avi_name
    Write-AviLog $debug_msg
	$session = Get-AviSession $General.HostAddress $General.UserName $General.UserPass
	[string] $debug_msg = "Got login session"
	Write-AviLog $debug_msg
	$tenant_name = $General.VarText2
    $headers = @{
		"content-type"="application/json";
		"referer"="https://$($General.HostAddress)";
		"X-Avi-Tenant"=$tenant_name;
		"x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
    }
    $url = "https://$($General.HostAddress)/api/sslkeyandcertificate?name=$($Specific.AssetNameOld)&export_key=false"
    [string] $debug_msg = "Doing REST call (GET) for {0}" -f $url
	Write-AviLog $debug_msg
	$resp_obj = Invoke-AviRestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json" -WebSession $session
	$response = $resp_obj.response
    if ( $response.Count -ne 0 ) # certificate exists so try to delete it
    {
		[string] $debug_msg = "Found certificate with name: {0}. Trying to delete it" -f $cert_avi_name
        Write-AviLog $debug_msg
		$url = $response.results.url
		[string] $debug_msg = "Doing REST call (DELETE) for {0}" -f $url
		Write-AviLog $debug_msg
        Invoke-AviRestMethod -Uri $url -Method Delete -Headers $headers -WebSession $session
		[string] $debug_msg = "Deleted certificate {0}" -f $cert_avi_name
		Write-AviLog $debug_msg
    }
	else
	{
		[string] $debug_msg = "No certificate found with name: {0}" -f $cert_avi_name
		Write-AviLog $debug_msg
	}
    return @{ Result="Success"; }
}


<##################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    Used for Onboard Discovery. Returns a list of applications with certificates which are added under
	corresponding device.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
		Applications : An array of hashtables with discovered application data
##################################################################################################>
function Discover-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )
	[string] $debug_msg = "Starting function"
    Write-AviLog $debug_msg
    [string] $debug_msg = "Powershell Version (Major): {0}" -f $PSVersionTable.PSVersion.Major
	Write-AviLog $debug_msg
	[string] $debug_msg = "PowerShell Edition: {0}" -f $PSVersionTable.PSEdition
	Write-AviLog $debug_msg
	$login_session = Get-AviSession $General.HostAddress $General.UserName $General.UserPass
    [string] $debug_msg = "Got login session"
	Write-AviLog $debug_msg
	$all_vs = Get-AllVS $General $login_session
    $ref_content_map = @{}
    $results = @()
    [int] $count = 1
    foreach($vs in $all_vs){
		[string] $debug_msg = "Processing VS with name: {0}" -f $vs.name
		Write-AviLog $debug_msg
        if($vs.ssl_key_and_certificate_refs){
            $temp = @{}
            $temp["Name"] = "AdaptableApp for {0}" -f $vs.name
            $temp["ApplicationClass"] = "Adaptable App"
            $temp["PEM"] = Get-Certificate-By-Ref $General $vs.ssl_key_and_certificate_refs[0] $ref_content_map $login_session
            $temp["ValidationAddress"] = Get-IPv4-VIP $vs
            $temp["ValidationPort"] = Get-SSL-Service-Port $vs
            $temp["Attributes"] = @{
                "Text Field 1"= $vs.name;
                "Text Field 2"= Get-Tenant-Name-By-Ref $General $vs.tenant_ref $ref_content_map $login_session
            }
            $results += $temp
			$debug_msg = "Saved details for {0} as Adaptable App" -f $vs.name
			Write-AviLog $debug_msg
        }
		else{
			$debug_msg = "{0} does not have any SSL certificate" -f $vs.name
			Write-AviLog $debug_msg
		}
    }
    $debug_msg = "Total no of Applications: {0}" -f $results.Length
    Write-AviLog $debug_msg
    return @{
        Result="Success";
        Applications = $results
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Write-AviLog([string] $msg)
{
	Write-Host "[$(Get-Date)] - [$((Get-PSCallStack)[1].Command)] - $msg" -ForegroundColor Green
    if($DEBUG_FILE) {Add-Content -Path $DEBUG_FILE -Value "[$(Get-Date)] - [$((Get-PSCallStack)[1].Command)] - $msg"}
}

function Invoke-AviRestMethod
{
	Param(
		[Uri] $Uri,
		[Microsoft.PowerShell.Commands.WebRequestMethod] $Method,
		[System.Object] $Body,
		[string] $ContentType,
		[string] $SessionVariable,
		[int] $TimeoutSec,
		[System.Collections.IDictionary] $Headers,
		[Microsoft.PowerShell.Commands.WebRequestSession] $WebSession
	)
	try
	{
		if($WebSession){
			$response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType -WebSession $WebSession -TimeoutSec $TimeoutSec
			return @{
				response=$response;
				session=$WebSession;
			}
		}
		if($SessionVariable){
			$response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType -SessionVariable new_session -TimeoutSec $TimeoutSec
			return @{
				response=$response;
				session=$new_session
			}
		}
	}
	catch [System.Net.WebException]{
		[string] $debug_msg = "REST call failed to {0}" -f $Uri.AbsoluteUri
		Write-AviLog $debug_msg
		if($_.Exception.Response){
			[string] $debug_msg = "Status Code of response : {0}" -f $_.Exception.Response.StatusCode.value__.ToString()
			Write-AviLog $debug_msg
			$debug_msg = Decode-Error $_.Exception
			Write-AviLog $debug_msg
		}
		else{
			$debug_msg = Decode-Error $_.Exception
			Write-AviLog $debug_msg
		}
		throw $_
	}
}

function Get-AviSession( [string] $addr, [string] $user, [string] $pass )
{
    [string] $url = "https://{0}/login" -f $addr
    [string] $debug_msg = "Login URL: {0}" -f $url
    Write-AviLog $debug_msg
    $body = @{
        "username"=$user;
        "password"=$pass
    } | ConvertTo-Json
    [string] $debug_msg = "Doing REST call (POST) for " + $url
    Write-AviLog $debug_msg
	$resp_obj = Invoke-AviRestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -SessionVariable session -TimeoutSec 300
	$response = $resp_obj.response
	$session = $resp_obj.session
	$debug_msg = "Login to controller at $addr successful"
	Write-AviLog $debug_msg
	$x_avi_version = $response.version.Version
	[string] $debug_msg = "AVI controller version: {0}" -f $x_avi_version
	Write-AviLog $debug_msg
	$session.Headers.Add([string] "X-Avi-Version", $x_avi_version)
	$session.Headers.Add([string] "content-type", [string] "application/json")
	$session.Headers.Add([string] "referer", [string] "https://$addr)")
	$session.Headers.Add([string] "x-csrftoken", $($session.Cookies.GetCookies("https://$addr")["csrftoken"].Value))
	return $session
}

function Get-AllVs([System.Collections.Hashtable] $General, [Microsoft.PowerShell.Commands.WebRequestSession] $session)
{
    [string] $all_vs_request_url = "https://{0}/api/virtualservice" -f $General.HostAddress
    $headers = @{
        "X-Avi-Tenant"="*";
    }
    $next_link = $all_vs_request_url
    $all_vs = @()
    $page_no = 0

    do {
        $page_no += 1
        [string] $debug_msg = "Doing REST call (GET) for {0} - Page: {1}" -f $next_link, $page_no
        Write-AviLog $debug_msg
        $resp_obj = Invoke-AviRestMethod -Uri $next_link -Method Get -Headers $headers -ContentType "application/json" -WebSession $session -TimeoutSec 300
	    $response = $resp_obj.response
        $all_vs += $response.results
        $next_link = $response.next
    }
    while($next_link -ne $null)

	[string] $debug_msg = "Total VS count: {0}" -f $all_vs.Count
	Write-AviLog $debug_msg
	return $all_vs     
}

function Get-Tenant-Name-By-Ref([System.Collections.Hashtable] $General, [string] $tref, [System.Collections.Hashtable] $ref_content_map, [Microsoft.PowerShell.Commands.WebRequestSession] $session)
{
    if(-Not $ref_content_map.$tref){
        [string] $debug_msg = "Doing REST call (GET) for {0}" -f $tref
        Write-AviLog $debug_msg
        $headers = @{
            "content-type"="application/json";
            "referer"="https://$($General.HostAddress)";
            "x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
        }
		$resp_obj = Invoke-AviRestMethod -Uri $tref -Method Get -Headers $headers -ContentType "application/json" -WebSession $session -TimeoutSec 300
		$response = $resp_obj.response
		$ref_content_map.$tref = $response.name
		[string] $debug_msg = "Saved tenant details for tenant: {0}" -f $response.name
		Write-AviLog $debug_msg
    }
    return $ref_content_map.$tref
}

function Get-Certificate-By-Ref([System.Collections.Hashtable] $General, [string] $ssl_ref, [System.Collections.Hashtable] $ref_content_map, [Microsoft.PowerShell.Commands.WebRequestSession] $session)
{
    if(-Not $ref_content_map.$ssl_ref){
        [string] $debug_msg = "Doing REST call (GET) for {0}" -f $ssl_ref
        Write-AviLog $debug_msg
        $headers = @{
            "content-type"="application/json";
            "referer"="https://$($General.HostAddress)";
            "x-csrftoken"=$($session.Cookies.GetCookies("https://$($General.HostAddress)")["csrftoken"].Value)
        }
		$resp_obj = Invoke-AviRestMethod -Uri $ssl_ref -Method Get -Headers $headers -ContentType "application/json" -WebSession $session -TimeoutSec 300
		$response = $resp_obj.response
		$ref_content_map.$ssl_ref = $response.certificate.certificate
		[string] $debug_msg = "Saved certificate found at {0}" -f $ssl_ref
		Write-AviLog $debug_msg
    }
    return $ref_content_map.$ssl_ref
}

function Get-IPv4-VIP($vs_json)
{
    foreach($vip_def in $vs_json.vip){
        if($vip_def.floating_ip){
            if($vip_def.floating_ip.type -eq "V4"){
				[string] $debug_msg = "Found floating IPv4 IP for {0}" -f $vs_json.name
				Write-AviLog $debug_msg
                return $vip_def.floating_ip.addr
            }
        }
        elseif($vip_def.ip_address.type -eq "V4"){
			[string] $debug_msg = "No Floating IP found. Picking private IPv4 IP for {0}" -f $vs_json.name
			Write-AviLog $debug_msg
            return $vip_def.ip_address.addr
        }
    }
}

function Get-SSL-Service-Port($vs_json){
    foreach($port in $vs_json.services){
        if($port.enable_ssl -eq $True){
            [string] $debug_msg = "Found SSL port for {0}" -f $vs_json.name
			Write-AviLog $debug_msg
			return $port.port
        }
    }
}

function Get-CACertName( [System.Security.Cryptography.X509Certificates.X509Certificate2] $cert )
{
    # name should not have any non-alphanumeric characters including whitespace
    $alphanumeric = '[^a-zA-Z0-9]'
    
    # use GetNameInfo to be consistent with Microsoft's naming
    $name = $cert.GetNameInfo([System.Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false)
    $name = $name -replace $alphanumeric
    
    # append the last 4 characters of the serial number in case there has been reissuance of the CA certificate
    return $name + "_" + $cert.SerialNumber.Substring($cert.SerialNumber.Length-4)
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