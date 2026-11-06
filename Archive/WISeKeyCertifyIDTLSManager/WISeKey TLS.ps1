<#
//-----------------------------------------------------------------------
// WISeKey TLS.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2024 Venafi, Inc. All rights reserved.
//
// This software is licensed by WISeKey, in addition to Venafi.
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
#>

<##################################################################################################
.NAME
    Test-Settings
.DESCRIPTION
    Verifies the ability to connect to and authenticate with the URA using the supplied credentials
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserName: the username required to authenticate with the CA
        UserPass: the password required to authenticate with the CA
        PfxData: a PKCS#12 containing a client certificate and private key required to authenticate with the CA
        PfxPass: the password required to access the private key in the PKCS#12
        AuxUser: a username paired with AuxPass for secondary authentication purposes
        AuxPass: the password for the AuxUser (username credential), AuxPfxData (certificate credential), or independent (password credential)
        AuxPfxData: a PKCS#12 containing client certificate and private key for secondary authentication purposes
        CertObjDN: the Venafi distinguished name of the certificate object in the policy tree
        CustomFields: the hash table of Custom Fields. Keys are field labels and values are either strings (single valued) or string arrays (multi-valued)
        ServiceAddress: URI, IP address or FQDN of the service you want to connect to
        ProfileString: String, can be delimited, which identifies product or profile associated with the service
.NOTES
    Returns a hashtable that includes the following variables
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Test-Settings {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    $null = Get-AccessToken -General $General

    return @{Result = "Success" }
}

<##################################################################################################
.NAME
    Submit-CsrAsNew
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a new, first time certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
    CustomFields:
        'ProductID': <required> ID of the WISeKey TLS product
        'SubscriberID': <required> ID of WISeKey TLS subscriber
        'ContactID': <required> ID of WISeKey TLS subscriber's organization contact
        'CertificateValidityPeriod': <required> Validity period of certificate in days
        'DomainValidations': <optional> Setting-up validations for each DNS Name in certificate's SAN. If DNS Names are pre-validated, then this should be ignored. 
            Format: 'domain1:method;domain2:method;...'
            Example: 'domain1.com:txt_http_file;domain2.com:txt_dns_record;domain3.com:whois_email:myemailaddress@mydomain.com'
            WISeKey TLS currently supports the following validation methods: 
                    txt_dns_record: DNS TXT Record
                    txt_http_file: Http File Auth
                    constructed_email: Constructed Email
                    txt_dns_email: DNS TXT email contact
                    whois_email: DNS WHOIS-based Email
                    dns_cname: DNS CNAME Record
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        Pkcs10: the Base64-encoded PKCS#10-formatted certificate signing request (CSR) to be enrolled
        SubjectDN: the requested subject distiguished name as a hash table. OU is a string array and all others are strings
        SubjAltNames: hash table keyed by SAN type. Values are string arrays.
        KeySize: the integer key size to be used if the CA creates the key pair
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' to indicate the non-error completion state. NOTE: this function is required.
        TransId: the identifier used to subsequently approve and/or retrieve the certificate from the CA
##################################################################################################>
function Submit-CsrAsNew {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $token = Get-AccessToken -General $General
    $headers = @{
        Authorization = "Bearer $token"
    }

    $productId = $General.CustomFields["ProductID"];
    $subscriberId = $General.CustomFields["SubscriberID"];
    $contactId = $General.CustomFields["ContactID"];
    $validityInDays = $General.CustomFields["CertificateValidityPeriod"];
    
    $domainValidations = @()

    foreach ($part in  $General.CustomFields["DomainValidations"].Split(';')) {
        $name, $method, $email = $part.Split(':')
        $object = New-Object -TypeName PSObject -Property @{
            name   = $name
            method = $method
            email  = $email
        }
        $domainValidations += $object
    }

    $DNS = $Specific.SubjAltNames.DNS;
    $csr = $Specific.Pkcs10;

    $url = Combine-UrlWithPath -url $General.ServiceAddress -path "v1/orders"

    try {
        $body = @{
            product_id         = $productId
            signing_ca_type    = "automatic"
            subscriber         = @{
                existing_subscriber_id = $subscriberId
                contact                = @{
                    existing_contact_id = $contactId
                }
            }
            certificate        = @{
                csr       = $csr
                dns_names = $DNS
                validity  = @{
                    length_in_days = $validityInDays
                }
            }
            domain_validations = $domainValidations
        } | ConvertTo-Json
    
        $response = Invoke-WebAPI -RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"

        return Done-Normal @{ Result = "Success"; TransId = $response.order_code }
    }
    catch {
        throw Decode-Error((Done-Abnormal $_).Exception)
    }
}

<##################################################################################################
.NAME
    Submit-CsrAsRenewal
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a renewal of an existing certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings), as well as the following:
        CustomFields
            'ContactID': <required> ID of WISeKey TLS subscriber's organization contact
            'CertificateValidityPeriod': <required> Validity period of certificate in days
            'DomainValidations': <optional> Setting-up validations for each DNS Name in certificate's SAN. If DNS Names are pre-validated, then this should be ignored. 
                Format: 'domain1:method;domain2:method;...'
                Example: 'domain1.com:txt_http_file;domain2.com:txt_dns_record;domain3.com:whois_email:myemailaddress@mydomain.com'
                WISeKey TLS currently supports the following validation methods: 
                        txt_dns_record: DNS TXT Record
                        txt_http_file: Http File Auth
                        constructed_email: Constructed Email
                        txt_dns_email: DNS TXT email contact
                        whois_email: DNS WHOIS-based Email
                        dns_cname: DNS CNAME Record
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
        CertId: a string that uniquely identifies the certificate issued by the CA to be renewed
        CertPem: the raw, Base64-encoded X509 certificate to be renewed
.NOTES
    Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsRenewal {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $token = Get-AccessToken -General $General
    $headers = @{
        Authorization = "Bearer $token"
    }

    $contactId = $General.CustomFields["ContactID"];
    $validityInDays = $General.CustomFields["CertificateValidityPeriod"];
    
    $domainValidations = @()

    foreach ($part in  $General.CustomFields["DomainValidations"].Split(';')) {
        $name, $method, $email = $part.Split(':')
        $object = New-Object -TypeName PSObject -Property @{
            name   = $name
            method = $method
            email  = $email
        }
        $domainValidations += $object
    }

    $csr = $Specific.Pkcs10;

    $orderCode = $Specific.CertId
    if (-not $orderCode) {
        throw "Cert Id is missing"
    }

    $url = Combine-UrlWithPath -url $General.ServiceAddress -path ("v1/orders/{0}/renew" -f $orderCode)

    try {
        $body = @{
            signing_ca_type    = "automatic"
            contact            = @{
                existing_contact_id = $contactId
            }
            certificate        = @{
                csr      = $csr
                validity = @{
                    length_in_days = $validityInDays
                }
            }
            domain_validations = $domainValidations
        } | ConvertTo-Json
    
        $response = Invoke-WebAPI -RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"

        return Done-Normal @{ Result = "Success"; TransId = $response.order_code }
    }
    catch {
        throw Decode-Error((Done-Abnormal $_).Exception)
    }
}

<##################################################################################################
.NAME
    Submit-CsrAsReplacement
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a replacement for an existing certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings), as well as the following:
    CustomFields:
        'ProductID': <required> ID of the WISeKey TLS product
        'ContactID': <required> ID of WISeKey TLS subscriber's organization contact
        'DomainValidations': <optional> Setting-up validations for each DNS Name in certificate's SAN. If DNS Names are pre-validated, then this should be ignored. 
            Format: 'domain1:method;domain2:method;...'
            Example: 'domain1.com:txt_http_file;domain2.com:txt_dns_record;domain3.com:whois_email:myemailaddress@mydomain.com'
            WISeKey TLS currently supports the following validation methods: 
                    txt_dns_record: DNS TXT Record
                    txt_http_file: Http File Auth
                    constructed_email: Constructed Email
                    txt_dns_email: DNS TXT email contact
                    whois_email: DNS WHOIS-based Email
                    dns_cname: DNS CNAME Record
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
        CertId: a string that uniquely identifies the certificate issued by the CA to be replaced
        CertPem: the raw, Base64-encoded X509 certificate to be replaced
.NOTES
    Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsReplacement {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $token = Get-AccessToken -General $General
    $headers = @{
        Authorization = "Bearer $token"
    }

    $productId = $General.CustomFields["ProductID"];
    $contactId = $General.CustomFields["ContactID"];
    
    $domainValidations = @()

    foreach ($part in  $General.CustomFields["DomainValidations"].Split(';')) {
        $name, $method, $email = $part.Split(':')
        $object = New-Object -TypeName PSObject -Property @{
            name   = $name
            method = $method
            email  = $email
        }
        $domainValidations += $object
    }

    $DNS = $Specific.SubjAltNames.DNS;
    $csr = $Specific.Pkcs10;

    $orderCode = $Specific.CertId
    if (-not $orderCode) {
        throw "Cert Id is missing"
    }

    $url = Combine-UrlWithPath -url $General.ServiceAddress -path ("v1/orders/{0}/replace" -f $orderCode)

    try {
        $body = @{
            product_id         = $productId
            signing_ca_type    = "automatic"
            contact            = @{
                existing_contact_id = $contactId
            }
            certificate        = @{
                csr       = $csr
                dns_names = $DNS
            }
            domain_validations = $domainValidations
        } | ConvertTo-Json
    
        $response = Invoke-WebAPI -RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"

        return Done-Normal @{ Result = "Success"; TransId = $response.order_code }
    }
    catch {
        throw Decode-Error((Done-Abnormal $_).Exception)
    }
}

<##################################################################################################
.NAME
    Retrieve-Certificate
.DESCRIPTION
    Retrieves a signed certificate from the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId: a string that uniquely identifies the certificate issued by the CA
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Status: 'Pending' or 'Issued' to indicate whether the certificate has been issued by the CA
        Pkcs7: a collection that includes the issued certificate and (optionally) all of the CA certificates in the chain
        Pkcs12: a collection that includes the issued certificate, its private key, and optionally all of the CA certificates in the chain
        PrivKeyPem: an OpenSSL or PKCS#8 private key in PEM format
        EncryptPass: the password used to encrypt the private key or PKCS#12
        DiscardPrivateKeyAndCsr: boolean that when $true tells the driver to discard stored assets that will not match the certificate being returned
##################################################################################################>
function Retrieve-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $token = Get-AccessToken -General $General
    $headers = @{
        Authorization = "Bearer $token"
    }

    $orderCode = $Specific.CertId # as return of TransId from Submit-CsrAsNew, Submit-CsrAsRenewal,  Submit-CsrAsReplacement

    try {
        $url = Combine-UrlWithPath -url $General.ServiceAddress -path ("v1/orders/{0}/certificate/download" -f $orderCode)

        $response = Invoke-WebAPI -Uri $url -Headers $headers -Method Get
        $zipContent = $response.Content
       
        # Create a memory stream for the ZIP file content
        $zipFileStream = New-Object System.IO.MemoryStream
        $zipFileStream.Write($zipContent, 0, $zipContent.Length)
        $zipFileStream.Position = 0

        # Load necessary assemblies for ZIP file handling
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        # Create a ZipArchive object from the memory stream
        $zipArchive = New-Object System.IO.Compression.ZipArchive($zipFileStream, [System.IO.Compression.ZipArchiveMode]::Read)

        # Extract the specific file from the ZIP archive
        $entry = $zipArchive.Entries | Where-Object { $_.FullName -eq "nginx/certificate.pem" }

        if (-not $entry) {
            throw "The specified file 'nginx/certificate.pem' was not found in the ZIP archive."
        }

        # Create a memory stream for the extracted file content
        $fileStream = New-Object System.IO.MemoryStream
        $entry.Open().CopyTo($fileStream)
        $fileStream.Position = 0

        # Convert the certificate content to a string
        $certContent = [System.Text.Encoding]::UTF8.GetString($fileStream.ToArray())

        $bytes = [System.Text.Encoding]::ASCII.GetBytes($certContent)

        # Cleanup memory streams
        $zipFileStream.Dispose()
        $fileStream.Dispose()

        return Done-Normal @{ Result = "Success"; Status = "Issued"; Pkcs7 = $bytes; }
    }
    catch {
        $errorResponse = Decode-Error((Done-Abnormal $_).Exception)
        if ($errorResponse.Contains("Certificate not found")) {
            return @{ Result = "Success"; Status = "Pending" }
        }
        throw $errorResponse
    }
}

<##################################################################################################
.NAME
    Revoke-Certificate
.DESCRIPTION
    Revokes a certificate issued by the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId: a string that uniquely identifies the certificate issued by the CA
        CertPem: the raw, Base64-encoded X509 certificate to be revoked
        ReasonCode: One of the following RFC 5280 Revocation Reason Codes:
                    0=Unspecified
                    1=Key Compromised
                    3=Affiliation Changed
                    4=Superseded
                    5=Cessation of Operation
        Comment: a comment provided by the revocation requester
.NOTES
    Returns a hashtable that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Revoke-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $token = Get-AccessToken -General $General
    $headers = @{
        Authorization = "Bearer $token"
    }

    $orderCode = $Specific.CertId # as return TransId from Submit-CsrAsNew, Submit-CsrAsRenewal,  Submit-CsrAsReplacement

    $url = Combine-UrlWithPath -url $General.ServiceAddress -path ("v1/orders/{0}/certificate/revoke" -f $orderCode)

    try {
        $body = @{
            revocation_reason  = $Specific.ReasonCode
            revocation_comment = $Specific.Comment
        } | ConvertTo-Json
    
        $null = Invoke-WebAPI -RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"

        return Done-Normal @{ Result = "Success" }
    }
    catch {
        throw Decode-Error((Done-Abnormal $_).Exception)
    }
}

function Get-AccessToken( [System.Collections.Hashtable]$General ) {
    $url = Combine-UrlWithPath -url $General.ServiceAddress -path "/v1/auth/login"
    
    try {
        $body = @{
            "app_id" = $General.UserName;
            "secret" = $General.UserPass;
        } | ConvertTo-Json

        $response = Invoke-WebAPI -RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
        return $response.access_token
    }
    catch {
        throw Decode-Error((Done-Abnormal $_).Exception)
    }
}

# Unused

function Approve-Request {
    return @{ Result = "NotUsed" }
}

function Get-ChainCertificates {
    return @{ Result = "NotUsed" }
}

function Prepare-ForRequest {
    return @{ Result = "NotUsed" }
}

function Combine-UrlWithPath {
    param (
        [string]$url,
        [string]$path
    )

    # Remove leading and trailing spaces from URL and path
    $url = $url.Trim()
    $path = $path.Trim()

    # Remove trailing slash from URL if present
    $url = $url.TrimEnd('/')

    # Remove leading slash from path if present
    $path = $path.TrimStart('/')

    # Combine URL with Path
    $combinedUrl = "$url/$path"

    # Use regex to handle protocols and avoid replacing slashes in protocol part
    if ($combinedUrl -match '^(https?:\/\/)(.*)$') {
        $protocol = $matches[1]
        $restOfUrl = $matches[2]
        $restOfUrl = $restOfUrl -replace '/+', '/'
        $combinedUrl = "$protocol$restOfUrl"
    }
    else {
        $combinedUrl = $combinedUrl -replace '/+', '/'
    }

    return $combinedUrl
}

function Decode-Error( [Exception] $ex ) {
    try {
        $result = $ex.Response.GetResponseStream()

        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $response = $reader.ReadToEnd() | ConvertFrom-Json
        $reader.Close();

        $errors = ""

        foreach ($errorProperty in $response.errors.psobject.properties) {
            $propertyName = $errorProperty.Name
            $errorDescriptions = $errorProperty.Value
            $errors += "Errors for property '$propertyName':`n"
            foreach ($description in $errorDescriptions) {
                $errors += "  $description`n"
            }
        }

        $errcode = $response.response_code
        $errmsg = $response.detail

        return $("{0} ({1}) `r`n{2}" -f $errmsg, $errcode, $errors)
    }
    catch {
        # the response is either not xml or not in the expected format
        return $ex.Message
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE SUPPORT DEBUG LOGGING ##########>

function Invoke-WebAPI {
    param(
        [parameter(position = 0, mandatory = $false)]
        [switch] $RestMethod,
        [parameter(position = 1, mandatory = $true)]
        [string] $Method,
        [parameter(position = 2, mandatory = $true)]
        [string] $Uri,
        [parameter(position = 3, mandatory = $false)]
        [Collections.Hashtable] $Headers,
        [parameter(position = 4, mandatory = $false)]
        [string] $Body,
        [parameter(position = 5, mandatory = $false)]
        [string] $ContentType,
        [parameter(position = 6, mandatory = $false)]
        [Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
    )

    $params = @{ Method = $Method; Uri = $Uri; UseBasicParsing = $true }

    if ( $DEBUG_FILE ) {
        "".PadLeft(80, "_") | Out-File $DEBUG_FILE -Append
        "$(Get-Date) - $Method $Uri" | Out-File $DEBUG_FILE -Append
    }

    if ( $Headers ) {
        if ( $DEBUG_FILE ) {
            "[Headers]" | Out-File $DEBUG_FILE -Append
            $headers.GetEnumerator() | ForEach-Object { "{0}: {1}" -f $_.Name, $_.Value } | Out-File $DEBUG_FILE -Append
        }
        $params.Add( "Headers", $Headers )
    }

    if ( $ContentType ) {
        if ( $DEBUG_FILE ) { "Content-Type: {0}" -f $ContentType | Out-File $DEBUG_FILE -Append }
        $params.Add( "ContentType", $ContentType )
    }

    if ( $Certificate ) {
        if ( $DEBUG_FILE ) {
            "[Client Certificate]" | Out-File $DEBUG_FILE -Append
            "Subject: $($Certificate.Subject)" | Out-File $DEBUG_FILE -Append
            "Issuer: $($Certificate.Issuer)" | Out-File $DEBUG_FILE -Append
            "SerialNumber: $($Certificate.SerialNumber)" | Out-File $DEBUG_FILE -Append
            "Thumbprint: $($Certificate.Thumbprint)" | Out-File $DEBUG_FILE -Append
            "NotBefore: $($Certificate.NotBefore)" | Out-File $DEBUG_FILE -Append
            "NotAfter: $($Certificate.NotAfter)" | Out-File $DEBUG_FILE -Append
        }
        $params.Add( "Certificate", $Certificate )
    }

    if ( $Body ) {
        if ( $DEBUG_FILE ) { "[Body]`r`n$Body" | Out-File $DEBUG_FILE -Append }
        $params.Add( "Body", $body )
    }

    $response = Invoke-WebRequest @params

    if ( $DEBUG_FILE ) {
        "[Response]`r`n$($response.RawContent)" | Out-File $DEBUG_FILE -Append
    }

    if ( $RestMethod ) { return ($response.Content | ConvertFrom-Json) }

    return $response
}

function Done-Normal {
    param(
        [parameter(position = 0, mandatory = $true)]
        [Collections.Hashtable] $Data
    )

    if ( $DEBUG_FILE ) {
        "".PadLeft(80, "_") | Out-File $DEBUG_FILE -Append
        $caller = (Get-PSCallStack)[1].FunctionName
        "$(Get-Date) - Data Returned by $caller" | Out-File $DEBUG_FILE -Append

        $Data | ConvertTo-Json -Depth 10 | Out-File $DEBUG_FILE -Append
    }

    return $Data
}

function Done-Abnormal {
    param(
        [parameter(position = 0, mandatory = $true)]
        [Management.Automation.ErrorRecord] $Data
    )

    if ( $DEBUG_FILE ) {
        "".PadLeft(80, "_") | Out-File $DEBUG_FILE -Append
        "$(Get-Date) - Fatal Error Details" | Out-File $DEBUG_FILE -Append
        $Data.Exception.GetType().FullName | Out-File $DEBUG_FILE -Append
        $Data.Exception.Message | Out-File $DEBUG_FILE -Append
        $Data.ScriptStackTrace | Out-File $DEBUG_FILE -Append

        if ( $Data.Exception -is [System.Net.WebException] -and $Data.Exception.Response) {
            $resp = $Data.Exception.Response

            "[Response]" | Out-File $DEBUG_FILE -Append
            "HTTP/{0} {1} {2}`r`n" -f $resp.ProtocolVersion.ToString(), `
                [int]$resp.StatusCode, $resp.StatusDescription | Out-File $DEBUG_FILE -Append

            if ( $Data.Exception.Response.ContentLength -gt 0 ) {
                $result = $Data.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $reader.ReadToEnd() | Out-File $DEBUG_FILE -Append
            }
        }
    }

    return $Data
}