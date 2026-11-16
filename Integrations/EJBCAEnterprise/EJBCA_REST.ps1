<#
//-----------------------------------------------------------------------
// EJBCA.ps1
//
// Copyright (c) 2021-2024 Venafi, Inc.  All rights reserved.
//
// This sample script and its contents are provided by Venafi to customers
// and authorized technology partners for the purposes of integrating with
// services and platforms that are not owned or supported by Venafi.  Any
// sharing of this script or its contents without consent from Venafi is
// prohibited.
//
// This sample is provided "as is" without warranty of any kind.
//-----------------------------------------------------------------------
#>

<#
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
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#>

#List of enabled security protocols
[System.Net.ServicePointManager]::SecurityProtocol = 
[System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

<##############################################################################
.NAME
	Test-Settings
.DESCRIPTION
	Verifies the ability to connect to and authenticate with the CA using the supplied credentials
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions
		UserName : the username for authenticating with the CA
		UserPass : the password for authenticating with the CA
		PfxData : PKCS#12 containing client certificate and private key for authenticating with the CA
		PfxPass : the password for access to the private key in the PKCS#12
		CustomFields : hashtable of Custom Fields; keys are field labels and values are strings (single valued) or string arrays (multi-valued)
.NOTES
	Returns a hashtable that includes the following variables
		Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##############################################################################>
function Test-Settings {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    Write-FunctionDetail $PSCmdlet.MyInvocation
    
    try {
        # to verify that there are active SSL certificate credits available
        $auth_cert = GetAuthCertificate $General
        $url = "{0}/v1/certificate/status" -f $General.ServiceAddress # $config.base_url 
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Testing endpoint '$url' with certificate authentication credential '$($auth_cert.SerialNumber) - '$($auth_cert.Thumbprint)' "
        
        $response = Invoke-RestMethod -Uri $url -Method Get -Certificate $auth_cert
        
        $has_active = $response | Where-Object { $_.status -eq "OK" }
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Got response '$($response.status)'"

        if ( -not $has_active ) {
            throw "There are no active SSL Certificate subscriptions in the specified EJBCA account."
            Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Error :: There are no active SSL Certificate subscriptions in the specified EJBCA account."
        }

        return @{ Result = "Success" }
    }
    catch {
        $_ | Write-VenafiDebug -ThrowException
    } 
}

<##############################################################################
.NAME
	Get-ChainCertificates
.DESCRIPTION
	Retrieves the chain of CA certificates applicable to certificates issued by the CA
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.NOTES
	Returns a hashtable that includes the following variables
		Result : 'Success' or 'NotUsed' to indicate the non-error completion state
		Pkcs7 : a collection that includes all of the CA certificates in the issuing chain
##############################################################################>
function Get-ChainCertificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result = "NotUsed" }
}

<##################################################################################################
.NAME
    Submit-CsrAsNew
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a new, first time certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        Pkcs10: the Base64-encoded PKCS#10-formatted certificate signing request (CSR) to be enrolled
        SubjectDN: the requested subject distiguished name as a hash table. OU is a string array and all others are strings.
        SubjAltNames: hash table keyed by SAN type. Values are string arrays.
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' to indicate the non-error completion state. NOTE: this function is required.
        TransId: the identifier used to subsequently approve and/or retrieve the certificate from the CA
        Pkcs7: a collection that includes the issued certificate and (optionally) includes all of the CA certificates in the chain
##################################################################################################>
function Submit-CsrAsNew {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Write-FunctionDetail $PSCmdlet.MyInvocation

    try {
        # to request a new certificate
        $auth_cert = GetAuthCertificate $General
        $body = @{
            certificate_request        = $Specific.Pkcs10;
            certificate_profile_name   = SetFrom $General.CustomFields "EJBCA Certificate Profile Name" $true;
            end_entity_profile_name    = SetFrom $General.CustomFields "EJBCA End Entity Profile Name" $true;
            certificate_authority_name = SetFrom $General.CustomFields "EJBCA CA Name" $true;
            username                   = SetFrom $General.CustomFields "EJBCA User Name" $true;
            email                      = SetFrom $General.CustomFields "EJBCA Email" $true;
        }

        $body = $body | ConvertTo-Json

        $url = "{0}/v1/certificate/pkcs10enroll" -f $General.ServiceAddress # $config.base_url
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Submit CSR to endpoint '$url' with body :: `n$($body | ConvertTo-Json)"

        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -Certificate $auth_cert
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Got response '$response'"


        if ($response.serial_number) {

            $collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection

            $certificate_bytes = [System.Convert]::FromBase64String($response.certificate)

            $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(, $certificate_bytes)
            Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Added certificate '$($certificate.SerialNumber)' to collection"

            $collection.Add($certificate)

            $bytes = $collection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
            
            return @{ Result = "Success"; TransId = $certificate.serial_number; Pkcs7 = $bytes }
        }

        return @{ Result = "Error" }

    }
    catch {   
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Error :: Unexpected Error occured - $($_.Exception.Message)"
        return @{ Result = $_.Exception.Message }
    }
}

<##################################################################################################
.NAME
    Import-Certificates
.DESCRIPTION
    Imports PEM formatted certificates and private keys into Trust Protection Platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserName: the username required to authenticate with the CA
        UserPass: the password required to authenticate with the CA
        PfxData: a PKCS#12 containing a client certificate and private key required to authenticate with the CA
        PfxPass: the password required to access the private key in the PKCS#12
        AuxUser: a username paired with AuxPass for secondary authentication purposes
        AuxPass: the password for the AuxUser (username credential), AuxPfxData (certificate credential), or independent (password credential)
        AuxPfxData: a PKCS#12 containing client certificate and private key for secondary authentication purposes
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        IncludeRevoked : whether to include revoked certificates
        IncludeExpired : whether to include expired certificates
        LastJobStarted : datetime value that indicates when the previous import job started
        LastProcessedId : string value with the ID of the last certificate that was previously imported by the job
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Certificates: A hashtable containing certificate/key data
            CustomName: Sets the name of certificate object in Policy tree
            ContactEmail: Contact email address; resolve to identity and assigned as the Contact if possible, otherwise value is assigned to Internet Email Address attribute
            TransactionId: Unique ID of the CA transaction needed for renewal/replacement/revocation
            Name: PEM file name (required)
            PEM: PEM file content (required)
            RevocationDate: Certificate revocation date
            Attributes: A hashtable of Config attribute values to assign to the Certificate object
            CustomFields: A hashtable of Custom Fields values to assign to the Certificate object
        LastProcessedId : string value with the ID of the last certificate in the Certificates hash table
        RunAfter : Number of hours after which script will be executed again
##################################################################################################>
function Import-Certificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Write-FunctionDetail $PSCmdlet.MyInvocation

    try {
        
        $idx = if ( $Specific.LastProcessedId ) { [int]$Specific.LastProcessedId } else { 1 }           

        $auth_cert = GetAuthCertificate $General
        
        $certs = @()
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Using certificate authentication credential '$($auth_cert.SerialNumber) - '$($auth_cert.Thumbprint)'"
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Constructed last processed id '$idx'"

        do {
                       
            $url = "{0}/v2/certificate/search" -f $General.ServiceAddress # $config.base_url
        
            $pagination = New-Object System.Collections.Hashtable
            $pagination.Add("page_size", 500)
            $pagination.Add("current_page", $idx)

            $sort = New-Object System.Collections.Hashtable
            $sort.Add("property", "UPDATE_TIME")
            $sort.Add("operation", "ASC")
        
            $current_date = Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%SZ'
            $searchCriteria = New-Object System.Collections.ArrayList
            $searchCriteria.Add(@{
                    property  = 'STATUS';
                    value     = 'CERT_ACTIVE';
                    operation = 'EQUAL'
                })
            if ( $Specific.IncludeRevoked ) {
                $searchCriteria.Add(@{
                        property  = 'STATUS';
                        value     = 'CERT_REVOKED';
                        operation = 'EQUAL'
                    })
            }

            if ( $Specific.IncludeExpired ) {
                $searchCriteria.Add(@{
                        property  = 'REVOCATION_DATE';
                        value     = $current_date;
                        operation = 'BEFORE'
                    })
            }
            $body = @{
                pagination = $pagination
                sort       = $sort
                criteria   = $searchCriteria
            }

            $body = $body | ConvertTo-Json -Depth 4
            Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Constructed search payload :: '`n$($body | ConvertFrom-JSON)'"

            $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -Certificate $auth_cert
            Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Got response count '$($response.count)'"
                
            foreach ($certificate in $response.certificates) {

                $cert_bytes = [System.Convert]::FromBase64String($certificate.base64Cert)
                $collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
                $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(, $cert_bytes)
                
                Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Found certificate '$($cert.SerialNumber)' in response collection"
                $collection.Add($cert)
                $bytes = $collection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)

                $pem = '-----BEGIN CERTIFICATE-----' + [System.Convert]::ToBase64String($bytes) + '-----END CERTIFICATE-----'
            
                $certs += @{
                    Name          = $cert.GetName()
                    TransactionId = $cert.GetSerialNumberString()
                    PEM           = $pem #.ToString()
                }
            }


            $idx = $idx + 1

        } until ($response.certificates.Count -eq 0)
        
        
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info End :: Collected '$($certs.Count)' certificates"
        return @{ Result = "Success"; Certificates = $certs; LastProcessedId = $idx - 2 }
    }
    catch {
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Error End :: Unexpected error importing certificates - '$($_.Exception.Message)'"
        return @{ Result = $_.Exception.Message }
    }

}

<##############################################################################
.NAME
	Submit-CsrAsRenewal
.DESCRIPTION
	Submits a CSR to a CA for enrollment as a renewal of an existing certificate
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
	A hashtable containing the specific set of variables needed by this function (see Submit-CsrAsNew plus the following)
		CertPem : the raw, Base64-encoded X509 certificate to be renewed
.NOTES
	Returns a hashtable that includes the same variables detailed in Submit-CsrAsNew
##############################################################################>
function Submit-CsrAsRenewal {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return Submit-CsrAsNew $General $Specific
}

<##############################################################################
.NAME
	Submit-CsrAsReplacement
.DESCRIPTION
	Submits a CSR to a CA for enrollment as a replacement for an existing certificate
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
	A hashtable containing the specific set of variables needed by this function (see Submit-CsrAsNew plus the following)
		CertPem : the raw, Base64-encoded X509 certificate to be replaced
.NOTES
	Returns a hashtable that includes the same variables detailed in Submit-CsrAsNew
##############################################################################>
function Submit-CsrAsReplacement {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return Submit-CsrAsNew $General $Specific
}

<##############################################################################
.NAME
	Approve-Request
.DESCRIPTION
	Approves a previously submitted CSR
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
	A hashtable containing the specific set of variables needed by this function
		RequestId : a string that uniquely identifies the certificate issued by the CA
.NOTES
	Returns a hashtable that includes the following variables
		Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##############################################################################>
function Approve-Request {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed" }
}

<##############################################################################
.NAME
	Retrieve-Certificate
.DESCRIPTION
	Retrieves a signed certificate from the CA
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
	A hashtable containing the specific set of variables needed by this function
		CertId : a string that uniquely identifies the certificate issued by the CA
.NOTES
	Returns a hashtable that includes the following variables
		Result : 'Success' or 'NotUsed' to indicate the non-error completion state
		Status : 'Pending' or 'Issued' to indicate whether the certificate has been issued by the CA
		Pkcs7 : a collection that includes the issued certificate and optionally includes all of the CA certificates in the chain
##############################################################################>
function Retrieve-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed" }
}

<##############################################################################
.NAME
	Revoke-Certificate
.DESCRIPTION
	Revokes a certificate issued by the CA
.PARAMETER General
	A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
	A hashtable containing the specific set of variables needed by this function
		issuer_dn : a string that identifies Subject DN of the issuing CA
		certificate_serial_number : the raw, Base64-encoded X509 certificate to be revoked
		reason (not required) : Must be valid RFC5280 reason. One of UNSPECIFIED ,KEY_COMPROMISE, CA_COMPROMISE, AFFILIATION_CHANGED, SUPERSEDED, CESSATION_OF_OPERATION, CERTIFICATE_HOLD, REMOVE_FROM_CRL, PRIVILEGES_WITHDRAWN, AA_COMPROMISE
.NOTES
	Returns a hashtable that includes the following variables
		Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##############################################################################>
function Revoke-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Write-FunctionDetail $PSCmdlet.MyInvocation

    try {
        $auth_cert = GetAuthCertificate $General
        $existing_cert_pem = ([string]$Specific.CertPem).Replace("-----BEGIN CERTIFICATE-----", "").Replace("-----END CERTIFICATE-----", "")
        $existing_cert_bytes = [Convert]::FromBase64String($existing_cert_pem)
        $existing_cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(, $existing_cert_bytes)

        $issuer = $existing_cert.Issuer
        $serial_number = $existing_cert.SerialNumber
        $reason = Get-Reason $Specific.ReasonCode

        $revokeUrl = [string]::Format("{0}/v1/certificate/{1}/{2}/revoke?reason={3}", $General.ServiceAddress, $issuer, $serial_number, $reason)
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Constructed revoke URL '$revokeUrl'"


        # $file = "body.txt"
        # New-Item -Path $file
        # Add-Content -Path $file -Value $revokeUrl

        $revokeCertificate = Invoke-RestMethod -Uri $revokeUrl -Method Put -ContentType "application/json" -Certificate $auth_cert

        $status_url = [string]::Format("{0}/v1/certificate/{1}/{2}/revocationstatus", $General.ServiceAddress, $issuer, $serial_number)
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info :: Constructed Revoke status URL'$status_url'"

        $revocationStatus = Invoke-RestMethod -Uri $status_url -Method Get -ContentType "application/json" -Certificate $auth_cert
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Info End :: Returned current Revoke status '$revocationStatus'"

        if ($revocationStatus.revoked) {
            return @{Result = "Success" }
        }
        else {
            return @{Result = "Revocation in progress" }
        }
    }
    catch {
        Write-VenafiDebug -Message "Function $($MyInvocation.InvocationName) :: Error End :: Unexpected error occured - $($_.Exception.Message)"
        return @{Result = $_.Exception.Message }
    }
}

<##################################################################################################
.NAME
    Prepare-ForRequest
.DESCRIPTION
    Performs any tasks that are necessary to prior to submitting a certificate signing request to the CA
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        SubjectDN : the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames : hashtable keyed by SAN type; values are string arrays
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Prepare-ForRequest {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    return @{ Result = "NotUsed" }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function GetAuthCertificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    try {	
        if ( $General.PfxData -ne $null ) {
            $auth_cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($General.PfxData, $General.PfxPass)
        }
        else {
            throw "A client certificate credential is required."
        }
        
        return $auth_cert
    }
    catch {
        return @{ Result = $_.Exception.Message }
    }
}

function Get-Reason([int] $reasonCode) {
    switch ( $reasonCode ) {
        0 { $reason = "UNSPECIFIED"; break }
        1 { $reason = "KEY_COMPROMISE"; break } # keyCompromise (RFC 5280)
        2 { $reason = "CA_COMPROMISE"; break } # keyCompromise (RFC 5280)
        3 { $reason = "AFFILIATION_CHANGED"; break } # affiliationChanged
        4 { $reason = "SUPERSEDED"; break } # superseded
        5 { $reason = "CESSATION_OF_OPERATION"; break } # cessationOfOperation
        default { throw "Revocation reason code {0} is not supported by EJBCA" -f $_ } # certificateHold, aACompromise 
    }
    return $reason
}

function SetFrom {
    Param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$fields,
        [Parameter(Mandatory = $true)]
        [System.String]$parameter_name,
        [Parameter(Mandatory = $true)]
        [bool]$mandatory
    )
    if (!(IsNullOrEmpty($fields.Get_Item($parameter_name)))) {
        return $fields.Get_Item($parameter_name)
    }
    else {
        if ($mandatory) {
            throw "Mandatory parameter '" + $parameter_name + "' is not specified"            
        }
    }
    return $null
}

function GetUserName {
    Param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$fields,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$subject
    )
    $cn_as_username = $fields.Get_Item("EJBCA CN as User Name")
    if (!(IsNUllOrEmpty($cn_as_username))) {
        if ($cn_as_username -eq "true") {
            $subject_cn = $subject.Get_Item("CN")
            if (!(IsNullOrEmpty($subject_cn))) {
                return $subject_cn
            }
        }
    }
    return SetFrom $fields "EJBCA User Name" $true
}

function IsNullOrEmpty($inputString) {
    if ($inputString -eq $null) {
        return $true
    }

    if ($inputString -is [String] -and $objectToCheck -eq [String]::Empty) {
        return $true
    }

    return $false
}

function ComposeSubjectDN($ht) {
    foreach ($pair in $ht.GetEnumerator()) {
        if ($pair.key -eq "OU") {
            $output += 'OU=' + [string]::Join(', OU=', $pair.Value) + ','
        }
        else {
            #Escape commas in value.
            $output += $pair.key + "=" + ([string]$pair.Value).Replace(',', '\,') + ","
        }
    }

    $output = $output.TrimEnd(',')
    $output
}

function ComposeSubjectAltNames($altNames) {
    if ($altNames -eq $null) {
        return $null
    }

    $output = ""

    if ($altNames.DNS -ne $null) {
        foreach ($item in $altNames.DNS) {
            $output += "dNSName=" + $item + ","
        }
    }
    if ($altNames.IP -ne $null) {
        foreach ($item in $altNames.IP) {
            $output += "ipaddress=" + $item + ","
        }
    }
    if ($altNames.UPN -ne $null) {
        foreach ($item in $altNames.UPN) {
            $output += "upn=" + $item + ","
        }
    }
    if ($altNames.URI -ne $null) {
        foreach ($item in $altNames.URI) {
            $output += "uri=" + $item + ","
        }
    }
    if ($altNames.Email -ne $null) {
        foreach ($item in $altNames.Email) {
            $output += "rfc822Name=" + $item + ","
        }
    }
    
    $output = $output.TrimEnd(',')
    return $output
}
 
Function Write-FunctionDetail {

    <#
    .SYNOPSIS
        Log function details
    .DESCRIPTION
        Log function details including the function name and any bound parameters

        *****
        ** NOTE ** this function also sets the proxy and proxy credentials if they are bound parameters
        *****

    .NOTES
        Must be an advanced function otherwise $PSCmdlet.MyInvocation will not be available.
        Set $script:scriptVersion to include the script version in the log.
    .EXAMPLE
        Write-FunctionDetail $PSCmdlet.MyInvocation

        Put this at the start of every function
    .EXAMPLE
        Write-FunctionDetail $PSCmdlet.MyInvocation -NoBoundParams

        Do not output the bound parameters
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Management.Automation.InvocationInfo] $InvocationInfo,

        [Parameter()]
        [switch] $NoBoundParams
    )

    $header = 'Function: {0}' -f $InvocationInfo.InvocationName
    $header += if ($script:scriptVersion) { ', script version: {0}' -f $script:scriptVersion } else { '' }
    $header | Write-VenafiDebug

    if ( $null -ne $InvocationInfo.BoundParameters ) {

        # look for proxy details and set if available
        $general = $InvocationInfo.BoundParameters.General
        if ( $general.ProfileString ) {
            # set the proxy
            $PSDefaultParameterValues.Add('Invoke-RestMethod:Proxy', $general.ProfileString)
            ('Using proxy {0}' -f $PSDefaultParameterValues.'Invoke-RestMethod:Proxy') | Write-VenafiDebug

            if ( $General.AuxUser -and $General.AuxPass ) {
                # set the proxy credential
                $proxyCredential = New-Object System.Management.Automation.PSCredential($General.AuxUser, ($General.AuxPass | ConvertTo-SecureString -AsPlainText -Force))
                $PSDefaultParameterValues.Add('Invoke-RestMethod:ProxyCredential', $proxyCredential)
                'Using proxy credential {0}' -f $proxyCredential.UserName | Write-VenafiDebug
            }
        }
        if ( -not $NoBoundParams ) {
            [hashtable]$InvocationInfo.BoundParameters | Write-VenafiDebug
        }
    }
}

function Write-VenafiDebug {

    <#
    .SYNOPSIS
    Write info to the adaptable debug log

    .DESCRIPTION
    Assuming the option has been selected, write info to the adaptable debug log.
    Hashtables are supported and secret info will not be logged, eg. $General.

    .PARAMETER Message
    The info to be logged

    .PARAMETER ThrowException
    After logging the message, throw an exception to terminate the script

    .EXAMPLE
    Write-VenafiDebug -Message 'connected to server'

    Write info to the log

    .EXAMPLE
    $General | Write-VenafiDebug

    Write input parameter values to the log

    .EXAMPLE
    Write-VenafiDebug -Message 'this was not good' -ThrowException

    Write to the log and throw an exception
    #>

    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject] $Message,

        [Parameter()]
        [switch] $ThrowException
    )

    process {

        if ( -not $global:DEBUG_FILE ) {
            return
        }

        $newMessage = if ( $Message -is [hashtable] ) {
            Set-SecretsToHidden $Message | ConvertTo-Json -Depth 5
        }
        else {
            $Message
        }

        try {
            # use a mutex to ensure multiple executions of this script don't cause 'file in use' errors
            $mutex = New-Object System.Threading.Mutex($false, [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName))
            if ( -not $mutex.WaitOne(0) ) {
                $mutex.WaitOne()
            }
            ('{0} : {1}' -f (Get-Date), ($newMessage | Out-String)) | Out-File -FilePath $global:DEBUG_FILE -Encoding 'UTF8' -Append
        }
        catch {
            throw $_
        }
        finally {
            $null = $mutex.ReleaseMutex()
        }
    }

    end {
        if ( $ThrowException ) {
            # since we're in the end block this is only intended for a string, not array or anything that needs the pipeline
            throw $Message
        }
    }
}

function Set-SecretsToHidden {

    <#
    .SYNOPSIS
        Blank out sensitive information
    .DESCRIPTION
        Blank out sensitive information in a message, typically in a hashtable.
        Meant for adaptable framework scripts.
        Will automatically clone hashtable to ensure original object isn't affected.
    #>


    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )

    process {

        $secrets = @('UserPass', 'AuxPass', 'PfxPass', 'Certificate', 'PfxData', 'Password', 'AuxPfxData', 'PrivKeyPem', 'Pkcs12', 'EncryptPass', 'ChainPkcs7', 'PrivKeyPemEncrypted', 'VarPass')

        if ($InputObject -is [hashtable]) {
            $clone = @{}
            foreach ($key in $InputObject.keys) {
                if ($key -in $secrets -and $null -ne $InputObject[$key] ) {
                    $clone[$key] = '***hidden***'
                }
                else {
                    $clone[$key] = Set-SecretsToHidden $InputObject[$key]
                }
            }
            return $clone
        }
        else {
            return $InputObject
        }
    }
}
