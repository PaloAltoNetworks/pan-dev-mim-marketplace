$global:ScriptVersion = "1.0.7"

<#
//---------------------------------------------------------------------------
// Venafi Zero Touch PKI-Import Only.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2024 Venafi, Inc. All rights reserved.
//
// This software is licensed by Venafi.
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

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12


$global:CertLimit = 30000 # max limit on detailed cert calls to ZTPKI -will return incomplete if under the limit to avoid too many detailed cert calls
$global:MaxLimit = 100000 # max limit on  cert results from ZTPKI - if this is set too low may not pull all results
$Global:Offset = 30 # Future functionality
$global:SleepSeconds = 1 #Future functionality
$global:IgnoreLastJobImport = $false # set to true to query all certs from ZTPKI API
$global:Timeout = 3500 # 3500 seconds is 58.33333 minutes (have to be less than 1hr or the platform will not return)
$Global:DateValue = Get-Date -Format "MM-dd-yyyy-HH-mm" # Log timestamp format

# This is used to skip passed orders and set at a specific order and will be ignored if the $global:IgnoreLastProcessedID is set to $true
$global:StartAtOrder = $false  # Set to $false to not start at specified order
#$global:StartAtOrder = "00c5aa25-cb04-4cb7-aa77-5fceb344c7e0" # example of certificate id for startatOrder

<#
#################################################################################################
.NAME
    Import-Certificates
.DESCRIPTION
    Imports certificates issued by a ztPKI account into Trust Protection Platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        AuxPass : string value of the password credential that holds the DigiCert API Key
        ServiceAddress: URI, IP address or FQDN of the service you want to connect to
        ProfileString: String, can be delimited, which identifies product or profile associated with the service
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        IncludeRevoked : boolean value indicating whether the job says to include revoked certificates
        IncludeExpired : boolean value indicating whether the job says to include expired certificates
        LastJobStarted : datetime value that indicates when the previous import job started
        LastProcessedId : string value with the ID of the last certificate that was previously imported by the job
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state. 'Incomplete' to re-run method later
        Certificates: A hashtable containing certificate data
            Name : (required) identifier that will appear in log event if certificate fails to import
            PEM : (required) the raw certificate in PEM format
            ContactEmail : the email address of the certificate contact
            TransactionId : the unique DigiCert ID of the certificate
            Attributes : A hashtable of additional attributes to set when importing the certificate
        LastProcessedId : string value with the ID of the last certificate in the Certificates hash table
		RunAfter : Number of hours after which script will be executed again
#################################################################################################
#>

function Import-Certificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    $global:StartProcessing = ""
    Write-DebugLog("ZTPKI Import Script Version: " + $global:ScriptVersion)

    # Test that Service Address complies with URI formats and also sanitize URL

    [uri]$URL = $General.ServiceAddress

    if (![uri]::IsWellFormedUriString($URL, 'Absolute')) {
        write-debugLog("Url is not well formed. must contain https:// in service address. Service Address Value " + $General.ServiceAddress)
        throw Format-Error("Url is not well formed. must contain https:// in service address. Service Address Value " + $General.ServiceAddress)
    }

    $Global:ZTPKIURL = ([System.Uri]$URL).Host
    $Global:ZTPKIURL = "https://" + $Global:ZTPKIURL
    $Specs = $Specific | out-string
    Write-DebugLog("Starting Cert Import for Profile: " + $General.ProfileString + " ZTPKI address: " + $ZTPKIURL)
    Write-DebugLog("values of specific: " + $Specs)

    if ($Specific.IncludeRevoked) { $status = "" } else { $status = "VALID" }
    if ($Specific.IncludeExpired) { $expired = "true" } else { $expired = "false" }
    Write-DebugLog("IncludeExpired " + $expired )
    if ($status -eq "VALID") { Write-DebugLog("Include only non-revoked certs: yes") } else {
        Write-DebugLog("Include only non-revoked certs: no")
    }

    # Set LastProcessedID if it exists
    $LastProcessedId = -1
    if ($Specific.LastProcessedId ) {
        $LastProcessedId = $Specific.LastProcessedId 
        Write-DebugLog("Set the LastProcessedId to from TPP: " + $LastProcessedId )  
    } 

    # Manually set lastprocessedID and overwrite value if startatorder set
   
    if ($LastProcessedId -lt 0 -and $global:StartAtOrder -ne $false) {
        $LastProcessedId = $global:StartAtOrder
        Write-DebugLog("Set the LastProcessedId to stop at - order: " + $global:StartAtOrder)         
    } 

    $LastImport = ""
    $LastProcessedCert = GetZTPKICertDetails -certitem $LastProcessedId
    if ($LastProcessedCert -and -not $global:IgnoreLastJobImport) {
        $LastImport = $LastProcessedCert.notBefore
        Write-DebugLog("LastCert date:  " + $LastImport) 
    }
    else { Write-DebugLog("LastCert date is empty New job or value of $IgnoreLastJobsImport not false value: " + $global:IgnoreLastJobImport) }


    $timer = [Diagnostics.Stopwatch]::StartNew() # Start timer so TPP doesn't think we have a runaway import
    $StartProcessing = $false

    if ($LastImport) {

            $body = @{
            limit          = $global:MaxLimit
            policy         = $General.ProfileString
            status         = $status
            expired        = $expired
            #created_since  = $LastImport
            updated_since  = $LastImport
            sort_direction = $global:sortDirection

        } | ConvertTo-Json -Depth 5
        } else {

            $body = @{
            limit          = $global:MaxLimit
            policy         = $General.ProfileString
            status         = $status
            expired        = $expired
            sort_direction = $global:sortDirection

        } | ConvertTo-Json -Depth 5

        }

    try {
                
        # look up the certRequest status
        $Parameters = @{
            Method  = "POST"
            Uri     = $Global:ZTPKIURL + "/api/v2/certificates"
            HawkID  = $General.UserName
            HawkKey = $General.UserPass
            Body    = $body
        }
        $certresponse = Invoke-RestMethodWithHawk @Parameters

        $certificates = @()
        $certCount = 0
        $processed_id = 0
        #Write-DebugLog("Found response: " +  $response)
        ## Because we can't sort based on numeric id iterations, we want to make sure oldest entries are first in the array
        $ArrayCount = $certresponse.count - 1
        $CertList = @()

        while ($ArrayCount -ge 0) {
            $CertList += $CertResponse.items[$ArrayCount]
            $ArrayCount = $ArrayCount - 1
        }
        
        if ($CertList.count -eq 0) {
            throw Format-Error("No certs found for profile: " + $General.ProfileString)
        }
        $TotalCertCount = $CertResponse.count
        write-debugLog("number of certificates found: " + $TotalCertCount)
        write-debugLog("Max limit on certificate results: " + $Global:MaxLimit)
        if ($TotalCertCount -ge $Global:Maxlimit) {
            write-debugLog("Warning: number of certificates found: " + $TotalCertCount + "greater than or equal to max limit: " + $Global:Maxlimit )
            write-debugLog("Full list of certificates may not be imported correctly on new jobs or with ignoreLastProcessedID set. Recommend Increasing max limit settings by updating Maxlimit variable")        
        }


        write-debugLog("Max limit on certificate details: " + $Global:CertLimit)
        # write-debugLog("CertList info " + $CertList)

        foreach ($item in $CertList) {
            

            if ($timer.Elapsed.TotalSeconds -gt $global:Timeout) {
                $executionResult = "Incomplete"            
                write-debugLog("Elapsed " + $($timer.Elapsed.TotalSeconds) + "is greater than Timeout: " + $global:Timeout)
                break 
            }
            
            if (!$global:StartAtOrder -or $StartProcessing) {
                $certcount++
                $response = GetZTPKICertDetails -certitem $item.id
                $processed_id = $response.id
                Write-DebugLog("Found Cert ID: " + $response.ID + " Name: " + $response.commonName)
                $certificates += @{
                    PEM            = $response.pem
                    TransactionId  = $response.id
                    Name           = $response.commonName
                    RevocationDate = $response.revocationDate
                }

            }
            elseif ($Item.id -eq $LastProcessedId) {
                $certcount++
                $StartProcessing = $true
                write-debugLog("Current order " + $item.id + " equals last processed id. StartProcesing on next order- last processed id: " + $LastProcessedID)
                $response = GetZTPKICertDetails -certitem $item.id
                $processed_id = $response.id
                Write-DebugLog("Found Cert ID: " + $response.ID + " Name: " + $response.commonName)
                $certificates += @{
                    PEM            = $response.pem
                    TransactionId  = $response.id
                    Name           = $response.commonName
                    RevocationDate = $response.revocationDate
                }
            }
            else {
                write-debugLog("Current order " + $item.id + " has not met start processing order yet-last processed id: " + $LastProcessedID)
            }


            if ($CertCount -gt $Global:CertLimit) { 
                $executionResult = "Incomplete"            
                write-debugLog("Current cert count " + $CertCount + " greater than limit on cert details API calls : " + $Global:CertLimit)
                write-debugLog("Last Processed id:  " + $processed_id )
                break 
            }
        
            # end of item loop 


        }

        #    if ($null -ne $DEBUG_FILE) {
        #       foreach ($cert in $Certificates) {
        #Write-DebugLog("Found Cert ID: " +  $cert.TransactionID + " Cert Name: " + $cert.Name + " revocation date: " + $cert.RevocationDate)
        #       }
        #     }

        if (!$executionResult) { $executionResult = "Success" }    
        #note even if we don't find a new cert, we will always send the last ID and a result of success back to prevent a CA Import failure with NotUsed
        Write-DebugLog("Certificate import complete. Latest Processed: " + $processed_id + " Result: " + $executionResult)
        Write-DebugLog("Certificate Count for this import: " + $CertCount)
        return @{ Result = $executionResult; Certificates = $certificates; LastProcessedId = $processed_id; RunAfter = 1; }
        

 
    }
    catch {
        $ResponseError = $_
        Write-DebugLog("Error encountered: " + $_.Exception)
        Write-DebugLog("Error details: " + $_)
        Write-DebugLog("Error Response Stack: " + $ResponseError.Exception.Response)

        throw Format-Error($_.Exception)

    }




}



function Write-DebugLog {
    [cmdletbinding()]
    Param(
        [parameter(ValueFromPipeline)]
        [string]$message
    )

    if ($null -ne $DEBUG_FILE) {
        #Write-Output "[$(Get-Date -Format FileDateTimeUniversal)] - $message" | Out-File $DEBUG_FILE -append
        $FilenameValues = $global:DEBUG_FILE.split("_")
        $AdaptableName = $FilenameValues[0]
        #write-host new value is $AdaptableName
        $file = $AdaptableName + "-" + $Global:DateValue + "_debug.log"
        if (!(Test-Path $file)) {
            New-Item $file -Force -ItemType File | Out-Null
        }

try {
            # use a mutex to ensure multiple executions of this script don't cause 'file in use' errors
            $mutex = New-Object System.Threading.Mutex($false, [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName))
            if ( -not $mutex.WaitOne(0) ) {
                $mutex.WaitOne()
            }
            ('{0} : {1}' -f (Get-Date), ($Message | Out-String)) | Out-File -FilePath $global:DEBUG_FILE -Encoding 'UTF8' -Append
        } catch {
            throw $_
        } finally {
            $null = $mutex.ReleaseMutex()
        }

     
    }
}

Function Get-HawkHeader {
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String]$Uri,
        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet("Delete", "Get", "Head", "Options", "Post", "Patch")]
        [String]$Method = "Get",
        [Parameter(Mandatory = $True, Position = 2)]
        [String]$HawkID,
        [Parameter(Mandatory = $True, Position = 3)]
        [String]$HawkKey,
        [String]$ContentType = "application/json",
        [String]$Body
    )
    $uriParse = [System.Uri]::new($Uri)
    $now = [int]((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date).ToUniversalTime()).TotalSeconds)
    $method = $Method.ToUpper()
    $path = $uriParse.PathAndQuery  # "/api/path/to/resource";
    $hostUri = $uriParse.Host       # "example.com";
    $port = $uriParse.Port          # 80;

    $chars = $(48..57; 65..90; 97..122)
    $nonce = (1..6 | ForEach-Object { Get-Random -InputObject $chars } | ForEach-Object { [char]$_ }) -join ""

    $payloadHash = $null
    if ($null -ne $Body) {
        # set payload hash here
        $payload = "hawk.1.payload" + "`n"
        $payload += $ContentType.split(",")[0].ToLower() + "`n"
        $payload += $Body + "`n"
        $hash = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256") 
        $payloadHash = $hash.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payload))
        $payloadHash = [Convert]::ToBase64String($payloadHash)
    }
    $artifacts = "hawk.1.header" + "`n" + 
    $now + "`n" +
    $nonce + "`n" +
    $method + "`n" +
    $path + "`n" +
    $hostUri + "`n" +
    $port + "`n" +
    $payloadhash + "`n"

    $artifacts += "`n"

    $hmac = [System.Security.Cryptography.HMAC]::Create("HMACSHA256")
    $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($HawkKey)
    $signature = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($artifacts))
    $signature = [Convert]::ToBase64String($signature)

    $header = "Hawk id=`"$HawkID`", ts=`"$now`", nonce=`"$nonce`""
    if ($payloadhash) {
        $header += ", hash=`"$payloadhash`""
    }

    $header += ", mac=`"$signature`""
    # commented out 4/6/2023 as logs get chatty-uncomment if needed to troubleshoot with ztPKI support
    #Write-DebugLog "Hawk Header = $header"
    return $header
}

Function Invoke-RestMethodWithHawk {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String]$Uri,
        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet("Delete", "Get", "Head", "Options", "Post", "Patch")]
        [String]$Method = "Get",
        [Parameter(Mandatory = $True, Position = 2)]
        [String]$HawkID,
        [Parameter(Mandatory = $True, Position = 3)]
        [String]$HawkKey,
        [String]$ContentType = "application/json",
        [String]$Body
    )

    $HawkParams = @{
        Uri         = $Uri
        Method      = $Method
        HawkID      = $HawkID
        HawkKey     = $HawkKey
        ContentType = $ContentType
        Body        = $Body
    }

    $hawkHeader = Get-HawkHeader @HawkParams

    $invokeParams = @{
        Uri         = $Uri
        Method      = $Method
        ContentTYpe = $ContentType
        Headers     = @{ Authorization = $hawkHeader }
    }

    if (($null -ne $Body) -and ($Body -ne "")) {
        $invokeParams.Add("Body", $Body)
    }
    return Invoke-RestMethod @invokeParams
}


Function GetZTPKICertDetails {

    Param
    (
        [parameter(Mandatory = $true)]
        [String]
        $CertItem
    )

    $Parameters = @{
        Method  = "GET"
        Uri     = $Global:ZTPKIURL + "/api/v2/certificates/" + $Certitem
        HawkID  = $General.UserName
        HawkKey = $General.UserPass
               
    }
    $details = Invoke-RestMethodWithHawk @Parameters
    return $details

}

Function Invoke-WebRequestWithHawk {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String]$Uri,
        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet("Delete", "Get", "Head", "Options", "Post", "Patch")]
        [String]$Method = "Get",
        [Parameter(Mandatory = $True, Position = 2)]
        [String]$HawkID,
        [Parameter(Mandatory = $True, Position = 3)]
        [String]$HawkKey,
        [String]$ContentType = "application/json",
        [String]$Body
    )

    $HawkParams = @{
        Uri         = $Uri
        Method      = $Method
        HawkID      = $HawkID
        HawkKey     = $HawkKey
        ContentType = $ContentType
        Body        = $Body
    }

    $hawkHeader = Get-HawkHeader @HawkParams

    $invokeParams = @{
        Uri             = $Uri
        Method          = $Method
        ContentTYpe     = $ContentType
        Headers         = @{ Authorization = $hawkHeader }
        UseBasicParsing = $True
    }

    if (($null -ne $Body) -and ($Body -ne "")) {
        $invokeParams.Add("Body", $Body)
    }
    return (Invoke-WebRequest @invokeParams).Content
}

function Format-Error( [Exception] $ex ) {
    try {
        $result = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        return $reader.ReadToEnd()
        #$json = $reader.ReadToEnd() | ConvertFrom-Json
        #return $json.errors.message
    }
    catch {
        # the response is either not xml or not in the expected format
        return $ex.Message
    }
}
