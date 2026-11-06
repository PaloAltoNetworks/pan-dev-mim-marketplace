<#
//-----------------------------------------------------------------------
// Radware_Cloud_WAAP_Connector_For_Venafi.ps1
//
// Copyright (c) 2024 Radware LTD.  All rights reserved.
//-----------------------------------------------------------------------
<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Policyable
Bit 3 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text1|Placeholder Cert Common Name|110
Text2|Not Used|000
Text3|Not Used|000
Text4|Not Used|000
Text5|Not Used|000
Option1|Self Signed|110
Option2|Not Used|000
Passwd|Not Used|000
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

    return @{ Result="NotUsed"}
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
    Install-certificate
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

function Install-certificate
{
Param(
        [Parameter(Mandatory=$false,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
	
	if ( $DEBUG_FILE ) { "Starting Install-certificate function" | Write-VenafiDebug }

	try
	{
		$TenantID = $General.HostAddress
		$Placeholder_CN = $General.VarText1
		
		if ( $DEBUG_FILE ) { "TenantID --> $TenantID" | Write-VenafiDebug }
		if ( $Placeholder_CN )
		{
			if ( $DEBUG_FILE ) { "Placeholder_CN --> $Placeholder_CN" | Write-VenafiDebug }
		} else {
			if ( $DEBUG_FILE ) { "Placeholder_CN is not configured, continuing" | Write-VenafiDebug }
		}
		
		
		# Gets common name from Venafi
		$venafi_public_cert = $Specific.CertPem

		# Remove the headers and footers and any whitespace
		$cleanedCertificate = $venafi_public_cert -replace '-----BEGIN CERTIFICATE-----', '' -replace '-----END CERTIFICATE-----', '' -replace '\s', ''
		
		$certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new([Convert]::FromBase64String($cleanedCertificate))

		$vcn = $certificate.Subject.Split(',') | ForEach-Object {
			if ($_ -match "CN=(.*)") {
				$matches[1]
			}
		}

		if ( $DEBUG_FILE ) { "Venafi common name is --> $vcn" | Write-VenafiDebug }

		$NewCertThumb = $certificate.thumbprint
		$body_to_extract_uploading_cert_status = "{`"order`":[{`"type`":`"Order`",`"order`":`"DESC`",`"field`":`"startDate`"}]
		,`"pagination`":{`"size`":1},`"criteria`":[{`"type`":`"fullTextSearchFilter`",`"inverseFilter`":false,`"fields`": 
		[`"processTypeText`"],`"searchText`":`"uploaded a new certificate bundle $NewCertThumb`"}]}"

		$authorization_token = get_auth $General.UserName $General.UserPass

		$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$headers.Add("Authorization", "Bearer $authorization_token")
		$headers.Add("requestEntityIds", "$TenantID")
		$headers.Add("Content-Type", "application/json;charset=UTF-8")
	
		$Tenantcerts = send_API_call "https://portal.radwarecloud.com/v1/configuration/sslcertificates/" 'GET' $headers "get tenant certs"
		if ( $DEBUG_FILE ) { "All Certs in Tenant" | Write-VenafiDebug }
		if ( $DEBUG_FILE ) { $Tenantcerts | Write-VenafiDebug }

		Validate-UniqueCommonName -vcn $vcn -NewCertThumb $NewCertThumb -Tenantcerts $Tenantcerts
		
		# If the certificate exists, making sure that the process is done successfuly or waiting until it finishes
		foreach ($Tcert in $Tenantcerts)
		{
			$Tcert_fingerprint = $Tcert.fingerprint	
			if ($NewCertThumb -eq $Tcert_fingerprint) 
			{
				if ( $DEBUG_FILE ) { "NOTICE: certificate already exists" | Write-VenafiDebug }
				$Activity_Status = get_status_from_activity_logs $headers $body_to_extract_uploading_cert_status
				if ($Activity_Status -eq "SUCCESS")
				{
					return @{ Result="Success"; AssetName=$NewCertThumb}
				}
				elseif ($Activity_Status -eq "IN_PROCESS")
				{
					return @{Result="ResumeLater"}
				}
				elseif ($Activity_Status -eq "FAIL")
				{
					if ( $DEBUG_FILE ) { "Uploading certificate status is FAIL" | Write-VenafiDebug }
					throw "Uploading certificate status is FAIL"
				}
			}
		} 
		
		
		<###############################
				Install New Cert
		###############################>
		$selfsigned = $General.VarBool1.ToString() -eq "True"
		if ( $DEBUG_FILE ) { "Certificate selfsigned --> $selfsigned" | Write-VenafiDebug }

		if ($selfsigned) # Checks if Private or Public CA
		{   
			$headers.Add("selfsigned", "true") 
		}
		$body = "{`"certificate`":`"$($Specific.CertPem)`",`"chain`":`"$($Specific.ChainPem)`",`"key`":`"$($Specific.PrivKeyPem)`",`"passphrase`":`"$($Specific.EncryptPass)`"}"
		
		# Print the headers
		if ( $DEBUG_FILE ) {
			"HEADERS:" | Write-VenafiDebug
			foreach ($header_name in $headers.Keys) {
				"$header_name --> $($headers[$header_name])" | Write-VenafiDebug
			}
		}

		if ( $DEBUG_FILE ) { "BODY:" | Write-VenafiDebug }
		if ( $DEBUG_FILE ) { $body | Write-VenafiDebug }

		$response = send_API_call "https://portal.radwarecloud.com/v1/configuration/sslcertificates/secret" 'POST' $headers "Install Certificate" $body
		if ($response -eq "ResumeLater")
		{
			if ( $DEBUG_FILE ) { "ResumeLater..." | Write-VenafiDebug }
			return @{Result="ResumeLater"}
		}

		if ($selfsigned) # Checks if Private or Public CA
		{   
			$headers.Remove("selfsigned")
			# Print the headers
			if ( $DEBUG_FILE ) {
				"HEADERS:" | Write-VenafiDebug
				foreach ($header_name in $headers.Keys) {
					"$header_name --> $($headers[$header_name])" | Write-VenafiDebug
				}
			}
		}

		$Activity_Status = get_status_from_activity_logs $headers $body_to_extract_uploading_cert_status
		
		if ($Activity_Status -eq "SUCCESS")
		{
			return @{ Result="Success"; AssetName=$NewCertThumb}
		}
		elseif ($Activity_Status -eq "IN_PROCESS")
		{
			return @{Result="ResumeLater"}
		}
		elseif ($Activity_Status -eq "FAIL")
		{
			if ( $DEBUG_FILE ) { "Uploading certificate status is FAIL" | Write-VenafiDebug }
			throw "Uploading certificate status is $Activity_Status"
		}
	
	} #end TRY
	
	catch
	{
		throw $_
	}
	return @{ Result="Success"; AssetName=$NewCertThumb }	
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

	if ( $DEBUG_FILE ) { "Starting Update-Binding function" | Write-VenafiDebug }
	
	try
	{
		$Start_function_time = Get-Date # Avoiding timeout of 2 minutes
		
		$TenantID = $General.HostAddress
		if ( $DEBUG_FILE ) { "TenantID --> $TenantID" | Write-VenafiDebug }
		$Placeholder_CN = $General.VarText1
		
		$NewCertThumb = $general.AssetName
		
		if ( $DEBUG_FILE ) { "NewCertThumb --> $NewCertThumb" | Write-VenafiDebug }

		$authorization_token = get_auth $General.UserName $General.UserPass
		
		$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$headers.Add("Authorization", "Bearer $authorization_token")
		$headers.Add("requestEntityIds", "$TenantID")
		$headers.Add("Content-Type", "application/json;charset=UTF-8")
		
		$Tenantcerts = send_API_call "https://portal.radwarecloud.com/v1/configuration/sslcertificates/" 'GET' $headers "get tenant certs"
		$NewCertID = get_id_from_thumb $NewCertThumb $Tenantcerts
		$OldCertID = get_old_cert_id $NewCertThumb $Tenantcerts
		
		$rcert = get_rcert $NewCertThumb $Tenantcerts
		
		if ($rcert) { 
			if ( $DEBUG_FILE ) { "Old cert is:" | Write-VenafiDebug }
			if ( $DEBUG_FILE ) { $rcert | Write-VenafiDebug }
			if ( $DEBUG_FILE ) { "App Count $($rcert.applications.count)" | Write-VenafiDebug }
			if ($rcert.applications.count -ne 0 ) {
				if ( $DEBUG_FILE ) { "Old cert apps:" | Write-VenafiDebug }
				if ( $DEBUG_FILE ) { $rcert.applications | Write-VenafiDebug }

				foreach ($appID in $rcert.applications.applicationUUID) {
					$certapp = send_API_call "https://portal.radwarecloud.com/v1/gms/applications/$appID" 'GET' $headers "Get certapp"
					
					$servicesID = $certapp.applicationServices | ConvertTo-Json -Compress
					$healthID = $certapp.healthChecks | ConvertTo-Json -Compress
					$redirect = $certapp.redirect | ConvertTo-Json -Compress
					
					$servicesID_count = $certapp.applicationServices.count
					$healthID_count = $certapp.healthChecks.count
					
					if ( $DEBUG_FILE ) { "certapp $certapp" | Write-VenafiDebug }
					if ( $DEBUG_FILE ) { "servicesID $servicesID" | Write-VenafiDebug }
					if ( $DEBUG_FILE ) { "healthID $healthID" | Write-VenafiDebug }
					if ( $DEBUG_FILE ) { "redirect $redirect" | Write-VenafiDebug }
					if ( $DEBUG_FILE ) { "servicesID count --> $servicesID_count" | Write-VenafiDebug }
					if ( $DEBUG_FILE ) { "healthID count --> $healthID_count" | Write-VenafiDebug }

					if ( $DEBUG_FILE ) { "servicesID $servicesID" | Write-VenafiDebug }
					if ( $DEBUG_FILE ) { "healthID $healthID" | Write-VenafiDebug }

					# Rebind Applications
					if ($redirect) {
						if ($servicesID_count -eq 1 -and $healthID_count -eq 1) {
							$body = "{`"applicationServices`":[$servicesID],`"certificateId`": `"$NewCertID`",`"redirect`":$redirect,`"healthChecks`":[$healthID]}"
						} elseif ($servicesID_count -gt 1 -and $healthID_count -eq 1) {
							$body = "{`"applicationServices`": $servicesID,`"certificateId`": `"$NewCertID`",`"redirect`":$redirect,`"healthChecks`":[$healthID]}"
						} elseif ($servicesID_count -gt 1 -and $healthID_count -gt 1) {
							$body = "{`"applicationServices`": $servicesID,`"certificateId`": `"$NewCertID`",`"redirect`"$redirect,`"healthChecks`":$healthID}"
						}
					} else {
						if ($servicesID_count -eq 1 -and $healthID_count -eq 1) {
							$body = "{`"applicationServices`":[$servicesID],`"certificateId`": `"$NewCertID`",`"redirect`":null,`"healthChecks`":[$healthID]}"
						} elseif ($servicesID_count -gt 1 -and $healthID_count -eq 1) {
							$body = "{`"applicationServices`": $servicesID,`"certificateId`": `"$NewCertID`",`"redirect`":null,`"healthChecks`":[$healthID]}"
						} elseif ($servicesID_count -gt 1 -and $healthID_count -gt 1) {
							$body = "{`"applicationServices`": $servicesID,`"certificateId`": `"$NewCertID`",`"redirect`":null,`"healthChecks`":$healthID}"
						}
					}
					if ( $DEBUG_FILE ) { "Rebind cert body:" | Write-VenafiDebug }
					
					if ( $DEBUG_FILE ) { $body | Write-VenafiDebug }

					$response = send_API_call "https://portal.radwarecloud.com/v1/configuration/applications/$appID/networkConfiguration" 'PUT' $headers "Rebind App" $body $Start_function_time
					if ($response -eq "ResumeLater")
					{
						if ( $DEBUG_FILE ) { "ResumeLater..." | Write-VenafiDebug }
						return @{Result="ResumeLater"}
					}
				} 
			}
		}

		# Migrating the applications from the "Placeholder" certificate to the new certificate (in case of the new certificate common name / SANs match the application domain name)
		if ($Placeholder_CN)
		{
			foreach ($Tcert_To_Get_Gcert in $Tenantcerts)
			{
				$PD_Gcert = $Tcert_To_Get_Gcert.protectedDomains 
				
				if ( $DEBUG_FILE ) { "PD_Gcert --> $PD_Gcert" | Write-VenafiDebug }
				
				if ($PD_Gcert -like '*;*') {
					$PD_Gcert = $PD_Gcert.Substring(0, $PD_Gcert.IndexOf(';'))
					if ( $DEBUG_FILE ) { "PD_Gcert contains ;" | Write-VenafiDebug }
					if ( $DEBUG_FILE ) { "PD_Gcert after substring --> $PD_Gcert" | Write-VenafiDebug }
				}
					
				if ($PD_Gcert -eq $Placeholder_CN){
					if ( $DEBUG_FILE ) { "Going over generic cert:" | Write-VenafiDebug }
					$AppNames = $Tcert_To_Get_Gcert.applications.applicationName
					if ( $DEBUG_FILE ) { "All App Names --> $AppNames" | Write-VenafiDebug }
					$appsUUID_IN_Generic_Cert = $Tcert_To_Get_Gcert.applications.applicationUUID
					if ( $DEBUG_FILE ) { "All App UUIDs $appsUUID_IN_Generic_Cert" | Write-VenafiDebug }
					break
				}
			}

			$AppMainDomains = @()
			$AppMainDomains_toUUID = @{}
			foreach ($appUUID_IN_Generic_Cert in $appsUUID_IN_Generic_Cert){
				if ( $DEBUG_FILE ) { "APP UUID --> $appUUID_IN_Generic_Cert" | Write-VenafiDebug }

				$APP_Details = send_API_call "https://portal.radwarecloud.com/v2/configuration/applications/$appUUID_IN_Generic_Cert" 'GET' $headers "Get APP_Details"
				
				$AppMainDomain = $APP_Details.featuresData.wafFeatureData.mainDomain.mainDomain
				if ( $DEBUG_FILE ) { "APP Main Domain -->  $AppMainDomain" | Write-VenafiDebug }
				$AppMainDomains += $AppMainDomain
				$AppMainDomains_toUUID.add($AppMainDomain, $appUUID_IN_Generic_Cert)
			}
			
			
			foreach ($MainDomain in $AppMainDomains) {
				if ( $DEBUG_FILE ) { "MainDomain --> $MainDomain" | Write-VenafiDebug }
			}

			foreach ($Tcert in $Tenantcerts){
				if ($Tcert.fingerprint -eq $NewCertThumb) {
					$PD = $Tcert.protectedDomains
					if ( $DEBUG_FILE ) { "protectedDomains --> $PD" | Write-VenafiDebug }
					$PD = $PD.Trim("CN=")
					if ($PD -like '*;*') {
						$PD = $PD -split ";"
						$PD = $PD | Select-Object -Unique
						$already_bound = @()
						foreach ($SinglePD in $PD) {
							if ( $DEBUG_FILE ) { "SinglePD --> $SinglePD" | Write-VenafiDebug }
							foreach ($MainDomain in $AppMainDomains) {
								if ($MainDomain -like $SinglePD -and $MainDomain -notin $already_bound) {
									if ( $DEBUG_FILE ) { "Single PD $SinglePD exists" | Write-VenafiDebug }
									$UUID_for_REST = $AppMainDomains_toUUID.$MainDomain
									if ( $DEBUG_FILE ) { "UUID_for_REST --> $UUID_for_REST" | Write-VenafiDebug }

									$certapp = send_API_call "https://portal.radwarecloud.com/v1/gms/applications/$UUID_for_REST" 'GET' $headers "Get certapp"

									$servicesID = $certapp.applicationServices | ConvertTo-Json -Compress
									$healthID = $certapp.healthChecks | ConvertTo-Json -Compress
									$redirect = $certapp.redirect | ConvertTo-Json -Compress
									
									$servicesID_count = $certapp.applicationServices.count
									$healthID_count = $certapp.healthChecks.count
									
									if ( $DEBUG_FILE ) { "certapp $certapp" | Write-VenafiDebug }
									if ( $DEBUG_FILE ) { "servicesID $servicesID" | Write-VenafiDebug }
									if ( $DEBUG_FILE ) { "healthID $healthID" | Write-VenafiDebug }
									if ( $DEBUG_FILE ) { "redirect $redirect" | Write-VenafiDebug }
									if ( $DEBUG_FILE ) { "servicesID count --> $servicesID_count" | Write-VenafiDebug }
									if ( $DEBUG_FILE ) { "healthID count --> $healthID_count" | Write-VenafiDebug }
									
									if ( $DEBUG_FILE ) { "servicesID $servicesID" | Write-VenafiDebug }
									if ( $DEBUG_FILE ) { "healthID $healthID" | Write-VenafiDebug }

									if ($redirect) {
										if ($servicesID_count -eq 1 -and $healthID_count -eq 1) {
											$body = "{`"applicationServices`":[$servicesID],`"certificateId`": `"$NewCertID`",`"redirect`":$redirect,`"healthChecks`":[$healthID]}"
										} elseif ($servicesID_count -gt 1 -and $healthID_count -eq 1) {
											$body = "{`"applicationServices`": $servicesID,`"certificateId`": `"$NewCertID`",`"redirect`":$redirect,`"healthChecks`":[$healthID]}"
										} elseif ($servicesID_count -gt 1 -and $healthID_count -gt 1) {
											$body = "{`"applicationServices`": $servicesID,`"certificateId`": `"$NewCertID`",`"redirect`"$redirect,`"healthChecks`":$healthID}"
										}
									} else {
										if ($servicesID_count -eq 1 -and $healthID_count -eq 1) {
											$body = "{`"applicationServices`":[$servicesID],`"certificateId`": `"$NewCertID`",`"redirect`":null,`"healthChecks`":[$healthID]}"
										} elseif ($servicesID_count -gt 1 -and $healthID_count -eq 1) {
											$body = "{`"applicationServices`": $servicesID,`"certificateId`": `"$NewCertID`",`"redirect`":null,`"healthChecks`":[$healthID]}"
										} elseif ($servicesID_count -gt 1 -and $healthID_count -gt 1) {
											$body = "{`"applicationServices`": $servicesID,`"certificateId`": `"$NewCertID`",`"redirect`":null,`"healthChecks`":$healthID}"
										}
									}
									if ( $DEBUG_FILE ) { "Rebind cert body:" | Write-VenafiDebug }
									if ( $DEBUG_FILE ) { $body | Write-VenafiDebug }

									$response = send_API_call "https://portal.radwarecloud.com/v1/configuration/applications/$UUID_for_REST/networkConfiguration" 'PUT' $headers "Rebind App" $body $Start_function_time
									if ($response -eq "ResumeLater")
									{
										if ( $DEBUG_FILE ) { "ResumeLater..." | Write-VenafiDebug }
										return @{Result="ResumeLater"}
									}
									$already_bound += $MainDomain
								}
							}
						}
					}
				}
			}
		}
		
		# Getting the new cert apps after rebinding them
		$Tenantcerts = send_API_call "https://portal.radwarecloud.com/v1/configuration/sslcertificates/" 'GET' $headers "get tenant certs"
		foreach ($Tcert in $Tenantcerts){
			
			$thumbprint = $Tcert.fingerprint 
			
			if ($thumbprint -eq $NewCertThumb){
				if ( $DEBUG_FILE ) { "Going over new cert:" | Write-VenafiDebug }
				$AppNames = $Tcert.applications.applicationName
				if ( $DEBUG_FILE ) { "All App Names --> $AppNames" | Write-VenafiDebug }
				$appsUUID_IN_NewCert = $Tcert.applications.applicationUUID
				if ( $DEBUG_FILE ) { "All App UUIDs $appsUUID_IN_NewCert" | Write-VenafiDebug }
				break
			}
		}
		

		foreach ($APPUUID in $appsUUID_IN_NewCert) {
			if ( $DEBUG_FILE ) { "APP UUID --> $APPUUID" | Write-VenafiDebug }

			$body = "{`"criteria`":[{`"type`":`"termFilter`",`"field`":`"referenceId`",`"value`":`"$APPUUID`"}]}"
			
			$Track = send_API_call "https://portal.radwarecloud.com/v1/userActivityLogs/reports/lastactivities/" 'POST' $headers "Get Tracking" $body
						
			$Activities = $Track.userActivityLogs
			foreach ($Activity in $Activities) {
				if ($Activity.userEmail -eq $General.UserName -and $Activity.activityType -eq "Origin server protocols"){
					if ( $DEBUG_FILE ) { $Activity.userEmail | Write-VenafiDebug }
					if ( $DEBUG_FILE ) { "The status of rebinding certificate is --> " + $Activity.status | Write-VenafiDebug }

					if ($Activity.status -eq "IN_PROCESS")
					{
						return @{result="ResumeLater"}
					} 
					elseif ($Activity.status -eq "FAIL") {
						throw "The status of rebinding certificate is FAIL"
					}
				}
			}
		}

		# Replacing cert in SNI groups

		$SNI_Groups = send_API_call "https://portal.radwarecloud.com/v2/configuration/sni/certificateGroups/" 'GET' $headers "get sni groups"
		if ( $DEBUG_FILE ) { "SNI:" | Write-VenafiDebug }
		if ( $DEBUG_FILE ) { $SNI_Groups | Write-VenafiDebug }
		
		foreach ($Group in $SNI_Groups)
		{
			if ( $DEBUG_FILE ) { "SNI Item:" | Write-VenafiDebug }
			$GNAME = $Group.groupName
			if ( $DEBUG_FILE ) { "name --> $GNAME" | Write-VenafiDebug }
			
			if ( $Group.hidden ) {
				if ( $DEBUG_FILE ) { "The group $GNAME is hidden, continuing" | Write-VenafiDebug }
				continue
			}
			
			$GID = $Group.id
			$group_certificateIds = $Group.certificateIds
			if ( $DEBUG_FILE ) { "all group properties --> $Group" | Write-VenafiDebug }
			
			if ( $DEBUG_FILE ) { "ID --> $GID" | Write-VenafiDebug }

			if ( $OldCertID -in $group_certificateIds)
			
			{
				$GET_locked_SNIs = send_API_call "https://portal.radwarecloud.com/v2/configuration/sni/certificateGroups/lockedGroups" 'GET' $headers "Gets SNI group status"
				if ( $DEBUG_FILE ) { "GET_locked_SNIs --> $GET_locked_SNIs" | Write-VenafiDebug }

				# Access the "inProgress" and the "failed" properties
				$inProgressValues = $GET_locked_SNIs.inProgress
				$failedValues = $GET_locked_SNIs.failed
				
				if ($failedValues)
				{
					if ( $DEBUG_FILE ) { "Failed SNI group IDs --> $failedValues" | Write-VenafiDebug }	
				}

				if ($GID -in $failedValues)
				{
					if ( $DEBUG_FILE ) { "SNI group $GNAME status is Failed" | Write-VenafiDebug }
				}

				if ($inProgressValues)
				{
					if ( $DEBUG_FILE ) { "In progress SNI group IDs --> $inProgressValues" | Write-VenafiDebug }	
				}

				if ($GID -in $inProgressValues)
				{
					if ( $DEBUG_FILE ) { "$GNAME ($GID) is in progress, resuming later..." | Write-VenafiDebug }
					return @{result="ResumeLater"}
				} else {
					if ( $DEBUG_FILE ) { "SNI group ID --> $GNAME ($GID) is not in locked" | Write-VenafiDebug }
				}
				
				
				# Check the status of previous rebinding certificate for SNI applicaion
				
				$SNI_AppUUID = $Group.application.applicationUUID
				$SNI_AppName = $Group.application.applicationName
				if ( $DEBUG_FILE ) { "SNI App Name --> $SNI_AppName" | Write-VenafiDebug }
				if ( $DEBUG_FILE ) { "SNI App UUID --> $SNI_AppUUID" | Write-VenafiDebug }
				
				$body = "{`"criteria`":[{`"type`":`"termFilter`",`"field`":`"referenceId`",`"value`":`"$SNI_AppUUID`"}]}"
				
				$Track = send_API_call "https://portal.radwarecloud.com/v1/userActivityLogs/reports/lastactivities/" 'POST' $headers "Get Tracking" $body
							
				$Activities = $Track.userActivityLogs
				foreach ($Activity in $Activities) {
					if ($Activity.userEmail -eq $General.UserName -and $Activity.activityType -eq "Origin server protocols"){
						if ( $DEBUG_FILE ) { $Activity.userEmail | Write-VenafiDebug }
						if ( $DEBUG_FILE ) { "Checking the application status before replacing the old certificate" | Write-VenafiDebug }
						if ( $DEBUG_FILE ) { "The status of previous rebinding certificate for SNI app is --> " + $Activity.status | Write-VenafiDebug }

						if ($Activity.status -eq "IN_PROCESS")
						{
							return @{result="ResumeLater"}
						} 
						elseif ($Activity.status -eq "FAIL") {
							throw "The status of previous rebinding certificate for SNI app is FAIL"
						}
					}
				}

				$New_group_IDs = @()
				foreach ($cert_ID in $group_certificateIds)
				{
					if ($cert_ID -eq $OldCertID)
					{
						$New_group_IDs += $NewCertID
						if ( $DEBUG_FILE ) { "New ID --> $NewCertID has been added to New_group_IDs" | Write-VenafiDebug }
					}
					else
					{
						$New_group_IDs += $cert_ID
					}
				}
				
				if ($Group.defaultCertificateId -eq $OldCertID)
				{
					$default_cert_ID = $NewCertID
				}
				else
				{
					$default_cert_ID = $Group.defaultCertificateId
				}
				$New_group_IDs_Type = $New_group_IDs.GetType()
				if ( $DEBUG_FILE ) { "New_group_IDs Type $New_group_IDs_Type" | Write-VenafiDebug }
				if ( $DEBUG_FILE ) { "New_group_IDs --> $New_group_IDs" | Write-VenafiDebug }

				$payload = @{
					certificateIds = $New_group_IDs
					defaultCertificateId = $default_cert_ID
					groupName = $Group.groupName
				}

				$Body = $payload | ConvertTo-Json
				if ( $DEBUG_FILE ) { "Update SNI group body --> $Body" | Write-VenafiDebug }
				$response = send_API_call "https://portal.radwarecloud.com/v2/configuration/sni/certificateGroups/$GID" 'PUT' $headers "Update SNI Group" $Body $Start_function_time
				if ($response -eq "ResumeLater")
				{
					if ( $DEBUG_FILE ) { "ResumeLater..." | Write-VenafiDebug }
					return @{Result="ResumeLater"}
				}
			}
		}

		$SNI_Groups = send_API_call "https://portal.radwarecloud.com/v2/configuration/sni/certificateGroups/" 'GET' $headers "get sni groups"
		if ( $DEBUG_FILE ) { "SNI:" | Write-VenafiDebug }
		if ( $DEBUG_FILE ) { $SNI_Groups | Write-VenafiDebug }
		
		# Making sure that the SNI tasks were finished successfully
		foreach ($Group in $SNI_Groups)
		{
			if ( $DEBUG_FILE ) { "SNI Item:" | Write-VenafiDebug }
			$GNAME = $Group.groupName
			$GID = $Group.id
			$group_certificateIds = $Group.certificateIds
			if ( $DEBUG_FILE ) { "all group properties --> $Group" | Write-VenafiDebug }
			if ( $DEBUG_FILE ) { "name --> $GNAME" | Write-VenafiDebug }
			if ( $DEBUG_FILE ) { "ID --> $GID" | Write-VenafiDebug }

			if ( $NewCertID -in $group_certificateIds)
			
			{	
				$GET_locked_SNIs = send_API_call "https://portal.radwarecloud.com/v2/configuration/sni/certificateGroups/lockedGroups" 'GET' $headers "Gets SNI group status"
				if ( $DEBUG_FILE ) { "GET_locked_SNIs --> $GET_locked_SNIs" | Write-VenafiDebug }

				# Access the "inProgress" and the "failed" properties
				$inProgressValues = $GET_locked_SNIs.inProgress
				$failedValues = $GET_locked_SNIs.failed

				if ($failedValues)
				{
					if ( $DEBUG_FILE ) { "Failed SNI group IDs --> $failedValues" | Write-VenafiDebug }	
				}

				if ($GID -in $failedValues)
				{
					if ( $DEBUG_FILE ) { "SNI group $GNAME status is Failed" | Write-VenafiDebug }
					throw "$GNAME status is Failed"
				}

				if ($inProgressValues)
				{
					if ( $DEBUG_FILE ) { "In progress SNI group IDs --> $inProgressValues" | Write-VenafiDebug }	
				}

				if ($GID -in $inProgressValues)
				{
					if ( $DEBUG_FILE ) { "$GNAME ($GID) is in progress, resuming later..." | Write-VenafiDebug }
					return @{result="ResumeLater"}
				}
				
				
				
				# Check the SNI applicaion
				
				$SNI_AppUUID = $Group.application.applicationUUID
				$SNI_AppName = $Group.application.applicationName
				if ( $DEBUG_FILE ) { "SNI App Name --> $SNI_AppName" | Write-VenafiDebug }
				if ( $DEBUG_FILE ) { "SNI App UUID --> $SNI_AppUUID" | Write-VenafiDebug }
				
				$body = "{`"criteria`":[{`"type`":`"termFilter`",`"field`":`"referenceId`",`"value`":`"$SNI_AppUUID`"}]}"
				
				$Track = send_API_call "https://portal.radwarecloud.com/v1/userActivityLogs/reports/lastactivities/" 'POST' $headers "Get Tracking" $body
							
				$Activities = $Track.userActivityLogs
				foreach ($Activity in $Activities) {
					if ($Activity.userEmail -eq $General.UserName -and $Activity.activityType -eq "Origin server protocols"){
						if ( $DEBUG_FILE ) { $Activity.userEmail | Write-VenafiDebug }
						if ( $DEBUG_FILE ) { "The status of rebinding certificate for SNI app is --> " + $Activity.status | Write-VenafiDebug }

						if ($Activity.status -eq "IN_PROCESS")
						{
							return @{result="ResumeLater"}
						} 
						elseif ($Activity.status -eq "FAIL") {
							throw "The status of rebinding certificate for SNI app is FAIL"
						}
					}
				}
			}
		}

		if ( $DEBUG_FILE ) { "Start deleting the old certificate if exists" | Write-VenafiDebug }

		$NewCertThumb = $general.AssetName
		$rcert = get_rcert $NewCertThumb $Tenantcerts
		$thumbprint_to_delete = $rcert.fingerprint

		if ($thumbprint_to_delete) {
			if ( $DEBUG_FILE ) { "thumbprint_to_delete: $thumbprint_to_delete" | Write-VenafiDebug }

			send_API_call "https://portal.radwarecloud.com/v1/configuration/sslcertificates/$thumbprint_to_delete" 'DELETE' $headers "Delete cert"
			
			$body_to_extract_deleting_cert_status = "{`"order`":[{`"type`":`"Order`",`"order`":`"DESC`",`"field`":`"startDate`"}]
			,`"pagination`":{`"size`":1},`"criteria`":[{`"type`":`"fullTextSearchFilter`",`"inverseFilter`":false,`"fields`": 
			[`"processTypeText`"],`"searchText`":`"deleted certificate bundle $thumbprint_to_delete`"}]}"

			$Activity_Status = get_status_from_activity_logs $headers $body_to_extract_deleting_cert_status
		
			if ($Activity_Status -eq "SUCCESS")
			{
				return @{ Result="Success"; AssetName=$NewCertThumb}
			}
			elseif ($Activity_Status -eq "IN_PROCESS")
			{
				return @{Result="ResumeLater"}
			}
			elseif ($Activity_Status -eq "FAIL")
			{
				if ( $DEBUG_FILE ) { "Deleting certificate status is FAIL" | Write-VenafiDebug }
				throw "Deleting certificate status is $Activity_Status"
			}
		} else {
			if ( $DEBUG_FILE ) { "There is no thumbprint to delete" | Write-VenafiDebug }
		}
	} # end try
	catch
		{
			throw $_
		}
    return @{Result="Success"; AssetName=$NewCertThumb}
}


<######################################################################################################################
.NAME
    Activate-certificate
.DESCRIPTION
    Performs any post-installation operations necessary to make the certificate active (such as restarting a service)
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################>
function Activate-certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )
    return @{ Result="NotUsed" }
}


<######################################################################################################################
.NAME
    Extract-certificate
.DESCRIPTION
    Extracts the active certificate from the hosting platform.  if the platform does not provide a method for exporting the
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
function Extract-certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result="NotUsed" }
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
function get_auth
{
	param (
        [string] $api_user,
        [string] $api_pass
    )

	#$certCN = $Specific.SubjectDN.CN
	$url = 'https://radware-public.okta.com/api/v1/authn'

	#Set up API credentials"
	$api_user = $General.UserName
	$api_pass = $General.UserPass
	$body = "{`"username`":`"$api_user`",`"password`":`"$api_pass`",`"options`": {`"multiOptionalFactorEnroll`": true,`"warnBeforePasswordExpired`": true}}"


	<##########################
	  Authentication request 
	##########################>

	$API_result = Invoke-RestMethod -Uri $url -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
	
	if ( $DEBUG_FILE ) { Write-VenafiDebug "Authentication status --> $($API_result.status)" }
	if ($API_result.status -eq 'SUCCESS') {
		$SessionToken = $API_result.sessionToken #Required to get client authorization token
		
		$url = ( 
		"https://radware-public.okta.com/oauth2/aus7ky2d5wXwflK5N1t7/v1/authorize?client_id=M1Bx6MXpRXqsv3M1JKa6" +
		"&nonce=n-0S6_WzA2M&"+
		"prompt=none&" +
		"redirect_uri=https%3A%2F%2Fportal.radwarecloud.com%2F&" + 
		"response_mode=okta_post_message&"+
		"response_type=token&"+
		"scope=api_scope&"+
		"sessionToken=$SessionToken&" +
		"state=af0ifjsldkj"
		)
		if ( $DEBUG_FILE ) { "URL $url" | Write-VenafiDebug }
		$API_result = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json" -UseBasicParsing
		
		if ( $DEBUG_FILE ) { "API_result $API_result" | Write-VenafiDebug }
		$authorization_token = $null
		$authorization_token0 = $null
		if ($API_result.html.head.script.'#text' -match "data.access_token = '(?<ACCESS_TOKEN>.*)'") {
			$authorization_token0 = $matches["ACCESS_TOKEN"]
			$authorization_token = $authorization_token0.replace("\x2D","-")
		} 
		else 
		{
			return @{ Result= "API Token failure:  $($API_result.status)"}
		}
		if ( $DEBUG_FILE ) { "API_result first $authorization_token" | Write-VenafiDebug }
	}
	if ( $DEBUG_FILE ) { "End of Auth" | Write-VenafiDebug }
	return $authorization_token
}


function get_rcert
{
	param (
        [string] $NewCertThumb,
		$Tenantcerts
    )

	$Placeholder_CN = $General.VarText1
    $vcn = get_vcn $NewCertThumb $Tenantcerts
    if ( $DEBUG_FILE ) { "VCN $vcn" | Write-VenafiDebug }

	# Gets common name from the old certificate
    foreach ($Tcert in $Tenantcerts)
	{
        $PD = $Tcert.protectedDomains 
             
        if ($PD -ne $Placeholder_CN -and $PD -ne "")
		{
            $rsub = $Tcert.protectedDomains
            if ( $DEBUG_FILE ) { "rsub --> $rsub" | Write-VenafiDebug }

            if ( $DEBUG_FILE ) { $Tcert.protectedDomains | Write-VenafiDebug }
            if ( $DEBUG_FILE ) { $PD | Write-VenafiDebug }
            if ($rsub -like '*;*') {
                $r = $rsub.Substring(0, $rsub.IndexOf(';'))
            }
            else {
				$r = $rsub
			}
            $cn = $r.Trim("CN=")
 
			if ($vcn -eq $cn -and $Tcert.fingerprint -ne $NewCertThumb) { # Gets Cert data from Radware (if common name from Venafi matches the common name in Radware tenant)
				$rcert = $Tcert
				if ( $DEBUG_FILE ) { "RCert: $rcert" | Write-VenafiDebug }
				break
			}
        }
    }
	return ($rcert)
}


function send_API_call {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Url,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Method,
        
        [Parameter(Mandatory = $true, Position = 2)]
        [hashtable] $Headers,
        
        [Parameter(Mandatory = $true, Position = 3)]
        [string] $Event,
        
        [Parameter(Mandatory = $false, Position = 4)]
        [string] $Body,
        
        [Parameter(Mandatory = $false, Position = 5)]
        [DateTime] $Start_function_time
    )
	
	if ($Start_function_time)
	{
		# Store the current time
		$Current_time = Get-Date

		# Calculate the time difference in seconds
		$timeDifference = ($Current_time - $Start_function_time).TotalSeconds

		if ( $DEBUG_FILE ) { "Function operation time is --> $timeDifference" | Write-VenafiDebug }
		
		# Check if the time difference is more than 90 seconds
		if ($timeDifference -gt 90) {
			if ( $DEBUG_FILE ) { "The operation time is more than 90 seconds." | Write-VenafiDebug }
			return "ResumeLater"
		} else {
			if ( $DEBUG_FILE ) { "The operation time is less than 90 seconds." | Write-VenafiDebug }
		}
	}
	
	for ($i = 1; $i -le 3; $i++) {
    try {
        if ($Body) {
            $response = Invoke-WebRequest -UseBasicParsing -Uri $Url -Method $Method -Headers $headers -Body $Body -TimeoutSec 30 -ContentType "application/json"
        } else {
            $response = Invoke-WebRequest -UseBasicParsing -Uri $Url -Method $Method -Headers $headers -TimeoutSec 30
        }

        $StatusCode = $response.StatusCode
        if ($DEBUG_FILE) { "$Event --> $StatusCode" | Write-VenafiDebug }

        if ($response.Content) {
            $response = $response.Content | ConvertFrom-Json
        }
        return $response
    } catch {
        $StatusCode = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "Unknown" }
        if ($DEBUG_FILE) { "$Event --> $StatusCode" | Write-VenafiDebug }

        if ($StatusCode -eq 423 -or $StatusCode -eq 429) {
            return "ResumeLater"
        }

        $ErrorMessage = $_.Exception.Message
        if ($DEBUG_FILE) { "$Event --> $ErrorMessage" | Write-VenafiDebug }

        try {
            $streamReader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorContent = $streamReader.ReadToEnd()
            $streamReader.Close()
        } catch {
            $errorContent = "Failed to read error response content."
        }

        if ($DEBUG_FILE) { "Error Content: $errorContent" | Write-VenafiDebug }

        if ($errorContent -match "^{.*}$") {
            try {
                $jsonError = $errorContent | ConvertFrom-Json
                if ($DEBUG_FILE) { "Parsed JSON Error: $($jsonError | ConvertTo-Json -Depth 10)" | Write-VenafiDebug }
            } catch {
                if ($DEBUG_FILE) { "Raw error response: $errorContent" | Write-VenafiDebug }
            }
        }

        if ($i -eq 3) {
            if ($DEBUG_FILE) { "Error: After 3 attempts, API returned status code --> $StatusCode." | Write-VenafiDebug }
            throw "After attempting the API call 3 times, the status code returned by the API is --> $StatusCode. Raw error response: $errorContent"
        }

        Start-Sleep -Seconds 10
    }
}

}


function get_vcn
{
	param (
        [string] $NewCertThumb,
        $Tenantcerts
    )

	$new_cert_CN = ""
	foreach ($Tcert in $Tenantcerts)
	{            
		if ($Tcert.fingerprint -eq $NewCertThumb)
		{
			$new_cert_CNs = $Tcert.protectedDomains
			if ($new_cert_CNs -like '*;*')
			{
				$new_cert_CN = $new_cert_CNs.Substring(0, $new_cert_CNs.IndexOf(';'))
			}
		}
	}
	
	if ($new_cert_CN -ne "")
	{
		return ($new_cert_CN)
	}
	else
	{
		if ( $DEBUG_FILE ) { "Error: new_cert_CN is empty" | Write-VenafiDebug }
		throw "new_cert_CN is empty"
	}
}


function get_id_from_thumb
{
	param (
        [string] $NewCertThumb,
        $Tenantcerts
    )

	foreach ($Tcert in $Tenantcerts)
	{
		$Tcert_thumbprint = $Tcert.fingerprint
		if ($Tcert_thumbprint -eq $NewCertThumb)
		{
			$NewCertID = $Tcert.id
			return ($NewCertID)
		}
	}
	if ( $DEBUG_FILE ) { "Error: ID not found for thumbprint: $NewCertThumb" | Write-VenafiDebug }
	throw "ID not found for thumbprint: $NewCertThumb"
}


function get_old_cert_id
{
	param (
        [string] $NewCertThumb,
        $Tenantcerts
    )

	$vcn = get_vcn $NewCertThumb $Tenantcerts

	$OldCertID = ""
    foreach ($Tcert in $Tenantcerts)
	{
        $PD = $Tcert.protectedDomains 
             
        if ($PD -ne $Placeholder_CN -and $PD -ne "")
		{
            $rsub = $Tcert.protectedDomains
            if ( $DEBUG_FILE ) { "rsub --> $rsub" | Write-VenafiDebug }

            if ($rsub -like '*;*')
			{
                $rsub = $rsub.Substring(0, $rsub.IndexOf(';'))
            }
            $cn = $rsub.Trim("CN=")
 
			if ($vcn -eq $cn -and $Tcert.fingerprint -ne $NewCertThumb)
			{
				$OldCertID = $Tcert.id
			}
        }
    }
	return ($OldCertID)
}


function Validate-UniqueCommonName
{
	param (
        [string] $vcn,
		[string] $NewCertThumb,
        $Tenantcerts
    )

	$common_name_counter = 0
	foreach ($Tcert in $Tenantcerts)
	{
		$other_cert_CN = $Tcert.protectedDomains
		if ( $DEBUG_FILE ) { "other_cert_CN --> $other_cert_CN" | Write-VenafiDebug }
		if ($other_cert_CN -like '*;*')
		{
			$other_cert_CN = $other_cert_CN.Substring(0, $other_cert_CN.IndexOf(';'))
			if ( $DEBUG_FILE ) { "other_cert_CN after substring --> $other_cert_CN" | Write-VenafiDebug }
		}

		if ($other_cert_CN -eq $vcn -and $Tcert.fingerprint -ne $NewCertThumb)
		{	
			$common_name_counter += 1
			if ( $DEBUG_FILE ) { "New Venafi cert equals to common_name, common_name_counter is:" | Write-VenafiDebug }
			if ( $DEBUG_FILE ) { $common_name_counter | Write-VenafiDebug }
			if ($common_name_counter -gt 1)
			{
				if ( $DEBUG_FILE ) { "Error: there are more than 1 certificate with common name $vcn" | Write-VenafiDebug }
				throw "there are more than 1 certificate with common name $vcn"
			}
		}
	}
}


function get_status_from_activity_logs
{
	param (
		[hashtable] $headers,
		[string] $body
    )
	
	$TrackContent = send_API_call "https://portal.radwarecloud.com/v1/userActivityLogs/reports/" 'POST' $headers "Get Tracking" $body
	$Activities = $TrackContent.userActivityLogs

	$Relevant_Activity = $Activities[0]
	$Activity_Status = $Relevant_Activity.status
	if ( $DEBUG_FILE ) { "Activity_Status --> $Activity_Status" | Write-VenafiDebug }
	return ($Activity_Status)
}


function Write-VenafiDebug
{
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Message
    )

    if ( $global:DEBUG_FILE ) {
        ('{0} : {1}' -f (Get-Date), $message) | Out-File -FilePath $global:DEBUG_FILE -encoding 'UTF8' -append
    }
}
