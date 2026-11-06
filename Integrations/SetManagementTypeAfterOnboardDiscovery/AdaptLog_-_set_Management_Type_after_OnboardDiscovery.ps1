<#
//------------------------------------------------------------------------
// Adaptable Log Channel Driver PowerShell Script
//
// Copyright (c) 2020 Venafi, Inc.  All rights reserved.
//
// This code is provided as a proof-of-concept or sample demonstrating the use of one or more
// specific functions of the Venafi WebSDK. Please carefully review and make necessary
// changes for your specific environment as needed. 
//
// Author: Saad Humayun (Saad.Humayun@venafi.com)
// Venafi Professional Services
//------------------------------------------------------------------------

<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text1|Created By|11
Text2|Certificate Object GUID|11
Text3|Associated Applications|11
Text4|Application Types in scope|10
Text5|Management Type to set|11
-----END FIELD DEFINITIONS-----

Definition for fields used are as follows:
Service Address: <Static URI of TPP WebSDK or https://$WebSdkFQDN$/Vedsdk>
Credential: A 'Username' credential object having credentials for auth with TPP WebSDK to obtain API Key (for legacy TPP servers)
Secondary Credential: A 'Password' credential object having valid OAuth access token used to connect with TPP's WebSDK (recommended)
PowerShell Script: <THIS SCRIPT>
Associated Applications: $Config[$Event.Text2$,"Consumers", ",\"]$
Certificate Object GUID: $GUID[$Event.Text2$]$
Created By: $Config[$Event.Text2$,Created By]$
Application Types in scope: <An optional filter of comma separated Application object's class names that are matched before the Management Type of associated certificate is updated, e.g. appf5ltmadvanced>
Management Type to set: ONE of (Provisioning, Enrollment, Monitoring, Unassigned)

#>

<# Uncomment this line to execute directly with PowerShell with simulated TPP input. 
# Note: Before running with simulated values, please add/update required values appropriate for your environment 

$General = @{
             AuxUser = ''
             AuxPass = ''
             UserName = ''
             UserPass = ''
             ServiceAddress = 'https://tls.bigsur.local/vedsdk'
            }
# Sample ONBOARD DISCOVERY Event and Fields
$Fields = @{
            Text1 = 'Onboard Discovery'
            Text2 = '{874a12c2-4d34-4c6f-8406-8b38fb58aa30}'
            Text3 = '\VED\Policy\Certificates\McQuarie\192.168.66.10\Assets'          
            Text4 = 'appf5ltmadvanced,appcapi'
            Text5 = 'Provisioned'            
            }
$Event = @{ 
            Value2 = '0'
            Description = '1A00002775C0B8573F65366145000000002775 was created from Onboard Discovery Qualys API discovery as \VED\Policy\Certificates\McQuarie\ava4'
            Name = 'Onboard Discovery - New Certificate'
            ID = '2555925'
            Component = '\VED\Discovery\Qualys API discovery'
            Grouping = '0'
            Data = ''
            ClientDate = '03/11/2019 10:00:30'
            ServerDate = '03/11/2019 10:00:30'
            Severity = '7'
            Text2 = '\VED\Policy\Certificates\McQuarie\ava4'
            SourceIP = '192.168.50.136'
            Value1 = '0'
            Text1 = '1A00002775C0B8573F65366145000000002775'
            }


Perform-Action -General $General -Event $Event -Fields $Fields
#>


##################################################################################################################################################
                                #----------------- USER SETTABLE OPTIONS ----------------------#
##################################################################################################################################################


#--------------------------------------------------- SCRIPT RUNTIME SETTINGS --------------------------------------------------- 

# For versions 19.3 and later, debug output is controlled from Webadmin UI. To enable debug logging on TPP versions prior to 19.3 set below to $true 
# $global:EnableDebug = $true

# Default logging location is <TPP_Home>\Logs. To set another logging location (folder only), enable and set a writeable location below. 
# $global:CustomLogFolder = 'C:\temp'

# Set the log filename to use. A name is generated when not defined or is less than 6 characters.
$global:LogFileName = 'AdaptLog-set Management Type after Onboard Discovery'

# Enable or disable server SSL certificate checks when communicating with API gateways. Do NOT disable in Production.
$global:IgnoreSSLWarnings = $false

# Seconds to wait for server response before closing a connection. A value of 0 (not recommended) waits indefinately.      
$global:APIgwTimeout = 60

##################################################################################################################################################
                                #!!!!!!!!!!!!!!!!!! DO NOT MODIFY BELOW !!!!!!!!!!!!!!!!!!!!!!#
##################################################################################################################################################



# Requires and complies with PowerShell v5.1 programming rules
Set-StrictMode -Version 'Latest'

$global:scriptVersion = '0.6'

# These values for global PS session variables eliminate error messages logged in Venafi Support Console when monitoring VPlatform.exe 
# NOTE: If unset, the script still executes properly  
$ConfirmPreference = "None"
$OutputEncoding = [console]::OutputEncoding

# Enable Debug logging or not? 
if ((Test-Path variable:global:DEBUG_FILE) -or ((Test-Path variable:global:EnableDebug) -and ($global:EnableDebug))) {
    # Enable PS Verbose and Debug info. These also control custom debug messages sent to logs.
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"     
}

# Stringbuilder is used when logging is directed to memory before writing to disk in a single operation
$global:LogStringBuilder = New-Object -TypeName System.Text.StringBuilder


<######################################################################################################################
.NAME
    Perform-Action
.DESCRIPTION
    This AdaptableLog script generates the Certificate CI and Change Request in Service Now. In case of failures, it generates Incidents instead.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        ServiceAddress : a string identifying the service endpoint (URL, host, port, etc) of the calling Adaptable Log Channel object
        UserName : a string containing the username portion of the credential assigned to the Adaptable Log Channel object
        UserPass : a string containing the password portion of the credential assigned to the Adaptable Log Channel object
.PARAMETER Event
    A hashtable containing the standard set of values captured when events are logged by Trust Protection Platform 
        ID : integer that uniquely identifies the event
        Name : string that briefly describes the meaning of the event
        Description : string that translates raw event data into meaningful human readable text
        Severity : 1 (Emergency), 2 (Alert), 3 (Critical), 4 (Error), 5 (Warning), 6 (Notice), 7 (Info), 8 (Debug)
        ServerDate : the date/time that the event was recorded by the log server
        ClientDate : the date/time that the event occurred
        SourceIP : the IP address of the TPP server where the event occurred
        Component : distiguished name of the TPP object responsible for logging the event
        Grouping : a numeric identifier that can be used to group related events
        Text1 : string variable whose meaning varies by event definition (255 character maximum)
        Text2 : string variable whose meaning varies by event definition (255 character maximum)
        Value1 : integer variable whose meaning varies by event definition (32-bit)
        Value2 : integer variable whose meaning varies by event definition (32-bit)
        Data : byte array variable generally used to capture larger amounts of data (1536 byte maximum)
.PARAMETER Fields
    A hashtable containing all of the extra field values specified on the Adaptable Log Channel object.
        Text1 : a string value for the first text extra field defined by the header at the top of this script
        Text2 : a string value for the second text extra field defined by the header at the top of this script
        ...
        Text12 : a string value for the twelfth text extra field defined by the header at the top of this script
.NOTES
    Returns...
        Result : 'Success' to indicate the non-error completion state
        Updates : (optional) hashtable of attribute name-value pairs pertaining to the Event.Component that
            specify what the driver will update when the Result is 'Success'
######################################################################################################################>

function Perform-Action
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Event Detail Parameters")]
        [System.Collections.Hashtable]$Event,
        [Parameter(Mandatory=$true,HelpMessage="Extra Field Parameters")]
        [System.Collections.Hashtable]$Fields
    )

    <#************************************ CUSTOM INTERNAL ERROR STATES ***********************************************
    All custom error states use negative integers between -100 to -199. Description as follows:
    -100 : A required value could not be resolved by a Macro
    -101 : Script was triggered by the wrong event (Event ID) in TPP
    -102 : Missing critical value from Event or General hashtable
    -103 : Effective policy setting for Management Type could not be changed 
    -109 : Supplied token or credentials for TPP WebSDK are invalid
    -199 : An uncaught exception
    #************************************ END of CUSTOM INTERNAL ERROR STATES ****************************************#>

    Initialize-Logging -Fixedlog

    "[Adaptable Log - v$global:scriptVersion] =============================== Starting Up ==============================" | Write-Log

    # Written only when debugging is enabled
    'Debug logging is enabled' | Write-DebugLog
    #if (Test-Path variable:global:DEBUG_FILE) { "Ignoring location passed by TPP is $($Global:DEBUG_FILE)" | Write-DebugLog }

    # Useful details to return in case of error
    $commonErrInfo = "$global:logFile on $env:computername has more details."

    "PowerShell version is $($PSVersionTable.PSVersion)" | Write-DebugLog

    if ("$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" -lt 5.1) {
        $global:errorMessage = 'PowerShell v5.1 or above is required.'
        'PowerShell version 5.1 or above is required!' | Write-ErrorLog
        'Exiting with error' | Write-ErrorLog
        Close-Logging # writes logs in memory to disk
        Return @{ Result = "Failure. $global:errorMessage $commonErrInfo" }   
    }

    'Event values are below:' | Write-DebugLog
    $Event.getenumerator() | Sort-Object -Property value -descending | format-table | out-string | Write-DebugLog 

    'General Parameters are below. Passwords are omitted:' | Write-DebugLog
    $General.getenumerator() | Where-Object -Property Name -NotMatch 'pass' | Sort-Object -Property value -descending | format-table | out-string | Write-DebugLog

    'Fields used are below. Passwords are omitted:' | Write-DebugLog
    $Fields.getenumerator() | Where-Object -Property Name -NotMatch 'pass' | Sort-Object -Property value -descending | format-table | out-string | Write-DebugLog 

    # Values from input hashtables
    $CertCreatedBy = $Fields.Text1 -replace '\\' -replace "`r`n"
    $CertObjectGUID = $Fields.Text2 -replace '\\' -replace "`r`n"
    $CertConsumers = $Fields.Text3 -replace "`r`n"
    $ConsumerTypesInScope = $Fields.Text4 -replace "`r`n" -replace '\\' -replace ' '
    $ManagementType = $Fields.Text5 -replace "`r`n" -replace '\\'
    $TPPWebSDK = $General.ServiceAddress -replace '\\' -replace "`r`n"
    $TPPaccessToken = $General.AuxPass
    $TPPWebSDKUser = $General.UserName
    $TPPWebSDKPass = $General.UserPass # assumes password to use for auth when username is present otherwise its a valid token
    
    # When cert was added by onboard discovery job use Event.Text2 otherwise assume an event directly related to the cert trigerred this Adaptable Log 
    if ($CertCreatedBy -eq 'Onboard Discovery') {
        $CertDN = $Event.Text2 -replace '\\','\'
        $CertObjName = $CertDN.SubString($CertDN.LastIndexOf('\')+1)
    } else {
        $CertDN = $Event.Component -replace '\\','\'
        $CertObjName = $CertDN.SubString($CertDN.LastIndexOf('\')+1)
    } 

    "Component in TPP is $($Event.Component)" | Write-Log 
    "Trigering Event name is $($Event.Name)" | Write-Log
    "Event description in TPP is $($Event.Description)" | Write-Log

    #--------------------- Check resolved Macros and user provided values ------------------------#
    # Fatal error when following are missing or invalid
    If ([string]::IsNullOrWhiteSpace($CertObjectGUID)) {
        "Certificate object GUID could not be resolved!" | Write-ErrorLog
        Close-Logging
        return @{ Result = "-100: Certificate object GUID could not be resolved. $commonErrInfo"}
    }
    If ([string]::IsNullOrWhiteSpace($TPPaccessToken)) {
        "TPP WebSDK OAuth token was not supplied. API Key based auth will be used instead" | Write-Log
        If ( ([string]::IsNullOrWhiteSpace($TPPWebSDKUser)) -or ([string]::IsNullOrWhiteSpace($TPPWebSDKPass)) ) {
            "Username credential to obtain API Key from TPP Web SDK are missing!" | Write-ErrorLog
            Close-Logging
            return @{ Result = "-109: TPP WedSDK token was not found. $commonErrInfo"}
        }
    }
    If ([string]::IsNullOrWhiteSpace($General.ServiceAddress)) {
        "TPP WebSDK address is missing!" | Write-ErrorLog
        Close-Logging
        return @{ Result = "-102: TPP WebSDK address is missing. $commonErrInfo"}
    }
    # Non-fatal warnings
    If ($CertConsumers -notmatch "^\\VED\\Policy.+$") {
        "No consumers (associated Applications) were found for $CertDN" | Write-WarningLog
    }

    If ([string]::IsNullOrWhiteSpace($TPPWebSDK)) {
        "TPP Web SDK URI was not provided! Constructing one using this server's FQDN..." | Write-WarningLog
        $TPPWebSDK = 'https://'+(Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain+'/VEDSDK'
        $TPPWebSDK | Write-Log
    } 
    # Debug info only
    If ([string]::IsNullOrWhiteSpace($ConsumerTypesInScope)) {
        "No filter for consumer application type was provided. Management Type will be set for this certificate to $ManagementType regardless of the associated application(s)" | Write-DebugLog
    }
    

    # Remove trailling slashes from URI if present 
    If ($TPPWebSDK -imatch '^.+\/$') { $TPPWebSDK = $TPPWebSDK -replace ".$" }

    # Array of consuming application object DNs 
    [array]$CertConsumers = $CertConsumers -split ","
    # Array of in-scope application object types 
    [array]$ConsumerTypesInScope = $ConsumerTypesInScope -split ","



    #--------------------- Connection Parameters for TPP WebSDK ------------------------#  
    # TLS server certificate check and force TLS 1.2
    if ($global:IgnoreSSLWarnings) { 
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $false } 
    }
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    # Build auth header and test TPP WebSDK auth token
    $TPPAuthHeader = New-Object -TypeName 'System.Collections.Generic.Dictionary[[String],[String]]'

    # Assumes new API Key should be fetched when Username credential are supplied OR the (preferred) OAuth is available token when Password credential is supplied
    If ([string]::IsNullOrWhiteSpace($TPPaccessToken)) {
        "Using supplied credentials to obtain a short-lived APIKey to authenticate with TPP Web SDK" | Write-Log
        $APIKey = Get-TPPAPIKey -UserName $TPPWebSDKUser -Password $TPPWebSDKPass -AuthURI "$TPPWebSDK/Authorize"
        $TPPAuthHeader.Add('X-Venafi-Api-Key', "$APIKey")
    } else {
        "Using supplied OAuth token to authenticate with TPP Web SDK" | Write-Log
        $TPPAuthHeader.Add('Authorization', "Bearer $TPPaccessToken")
    } 

    if (-not (Test-TPPAccessToken)) { 
        "Supplied token or credentials for TPP WebSDK are invalid. A valid access token for TPP WebSDK or credentials to obtain one is required!" | Write-ErrorLog
        return @{ Result = "-109: Supplied token or credentials for TPP WebSDK are invalid. A valid access token for TPP WebSDK or credentials to obtain one is required!. $commonErrInfo"} 
    }


    #------------------------ Test Event ID matches expected values ------------------------# 
    # 786483 = Admin UI - Valide Now (useful for testing)
    # 2555925 = Onboard Discovery - New Certificate
    # 2555928 = Onboard Discovery - Managed Certificate
    if ($Event.ID -notin @('786483','2555925','2555928')) {
        # Called by wrong event
        "Invalid EventID '$($Event.ID)'. Expected IDs are: `n2555928 : Onboard Discovery - Managed Certificate`n2555925 : Onboard Discovery - New Certificate`n786483 : Admin UI - Valide Now" | Write-ErrorLog
        Close-Logging # writes logs in memory to disk
        return @{ Result = "-107: Invalid EventID '$($Event.ID)'. Expected IDs are 786483, 2555925, 2555928. $commonErrInfo" }
    }

    If ($Event.ID -eq '786483') { "Functionality when testing with 'Validate Now' button is limited since required macros will not resolve properly. Unsuccessful outcome below is expected! " | Write-Log }

    # Get the associated application(s) types
    $consumerTypes = @()
    foreach ($app in $CertConsumers){
        [string]$appType = (Get-TPPConfigAttribute -ObjectDN $app -AttributeName "Driver Name")
        $consumerTypes += $appType
    }

    $intersectedApps = $null
    $intersectedApps = $ConsumerTypesInScope | ?{$consumerTypes -contains $_}  #intersect expected app types with the ones found

    if ($intersectedApps) { 
        "This certificate will be set to $ManagementType as it is associated with $intersectedApps" | Write-Log
    } elseIf ([string]::IsNullOrWhiteSpace($ConsumerTypesInScope)) {
        "This certificate will be set to $ManagementType by defaullt since no filter for consuming application(s) was provided" | Write-Log
    } else {
        "No Application class associated with $CertDN matched any Application class specified in the filter. This certificate is not considered to be in-scope for changes to its' Management Type." | Write-Log
        "Application classes associated with this certificate are: $consumerTypes" | Write-DebugLog
        "Application classes in scope (set in the filter) are: $ConsumerTypesInScope" | Write-DebugLog
        return @{ Result = "Success" }
    }

    
    #---------------------- Set Management Type based on certificate's origin ------------------------# 
    # The switch statement branches code to satisfy different origins for certificate
    Switch ($CertCreatedBy) {
        'Onboard Discovery'{
            # Evaluate and set management type
            "Evaluating and setting effective Management Type policy for $CertDN..." | Write-Log
            if (Set-CertificateManagementType -ObjectDN $CertDN -NewType $ManagementType) { 
                "Success!" | Write-Log 
                Close-Logging # writes logs in memory to disk when logging to memory is enabled
                return @{ Result = "Success" }
            } else {
                "-103: Effective policy setting for Management Type could not be changed" | Write-ErrorLog
                "Failure!" | Write-Log 
                Close-Logging # writes logs in memory to disk when logging to memory is enabled
                return @{ Result = "-103: Failure! $commonErrInfo" }
            }
        }
        'CA Import'{
            # Evaluate and set management type
            "Evaluating and setting effective Management Type policy for $CertDN..." | Write-Log
            if (Set-CertificateManagementType -ObjectDN $CertDN -NewType $ManagementType) { 
                "Success!" | Write-Log 
                Close-Logging # writes logs in memory to disk when logging to memory is enabled
                return @{ Result = "Success" }
            } else {
                "-103: Effective policy setting for Management Type could not be changed" | Write-ErrorLog
                "Failure!" | Write-Log 
                Close-Logging # writes logs in memory to disk when logging to memory is enabled
                return @{ Result = "-103: Failure! $commonErrInfo" }
            }
        }
        'Network Discovery'{
            # Evaluate and set management type
            "Evaluating and setting effective Management Type policy for $CertDN..." | Write-Log
            if (Set-CertificateManagementType -ObjectDN $CertDN -NewType $ManagementType) { 
                "Success!" | Write-Log 
                Close-Logging # writes logs in memory to disk when logging to memory is enabled
                return @{ Result = "Success" }
            } else {
                "-103: Effective policy setting for Management Type could not be changed" | Write-ErrorLog
                "Failure!" | Write-Log 
                Close-Logging # writes logs in memory to disk when logging to memory is enabled
                return @{ Result = "-103: Failure! $commonErrInfo" }
            }
        }

        # Add additional conditions here when required...

        # Default catch-all condition
        Default { 
            "Nothing to do because the certificate was added to TPP by an unrecognised system $CertCreatedBy" | Write-ErrorLog
            return @{ Result = "Nothing to do because the certificate was added to TPP by an unrecognised system $CertCreatedBy. $commonErrInfo" }
        break 
        }
    }


}


########################################################################################################################################
#################################################### - FUNCTIONS - #####################################################################
########################################################################################################################################


#################################################### - TPP WebSDK Related Functions - #####################################################################

Function Test-TPPAccessToken {
    Param()

    $URI = $TPPWebSDK+'/Authorize/CheckValid'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "GET" -Headers $TPPAuthHeader -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while testing access token from $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while testing access token from $URI" | Write-ErrorLog
        return $false
    }
    
    if (Test-AnyProperty -Name 'APIKey' -Obj $response) {
        # Check for expiry
        if ($response.ValidUntil -lt (Get-Date).ToUniversalTime()) {
            "TPP WebSDK access token $($response.APIKey) expired on $($response.ValidUntil)" | Write-ErrorLog
            return $false 
        } else {
            "TPP WebSDK access token is valid" | Write-Log
            return $true
        }
    }

}

Function Get-TPPAPIKey {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [Parameter(Mandatory=$true)]
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [string]$AuthURI
    )

    $response = $null

    $jsonBody = @{
        Username = $Username
        Password = $Password
    } | ConvertTo-Json

    try {
        $($response = Invoke-RestMethod -Uri $AuthURI -Method "POST" -ContentType 'application/json' -Body $jsonBody -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while getting API Key from $AuthURI. $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while getting API Key from $AuthURI" | Write-ErrorLog
        return $false
    }
    
    if (Test-AnyProperty -Name 'APIKey' -Obj $response) {
        # Return API token
        return $response.APIKey
    } else {
        return $null
    }

}


Function Get-OAuthtokenFromTPP {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [Parameter(Mandatory=$true)]
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [string]$AuthURI,
        [Parameter(Mandatory=$true)]
        [string]$ClientID,
        [Parameter(Mandatory=$true)]
        [string]$Scope
    )

    $response = $null

    $jsonBody = @{
        client_id = $ClientID
        username = $Username
        password = $Password
        scope = $Scope
    } | ConvertTo-Json

    try {
        $($response = Invoke-RestMethod -Uri $AuthURI -Method "POST" -ContentType 'application/json' -Body $jsonBody -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while getting OAuth access token from $AuthURI. $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while getting OAuth access token from $AuthURI" | Write-ErrorLog
        return $false
    }
    
    if (Test-AnyProperty -Name 'access_token' -Obj $response) {
        # Return Bearer token
        return $response.access_token
    } else {
        return $null
    }

}

Function Set-CertificateManagementType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ObjectDN,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Provisioning','Enrollment','Monitoring','Unassigned')]$NewType,
        [Parameter(Mandatory = $false)]
        [Switch]$Force
    )

    # Get current effective policy
    $currMgmtType = Get-TPPEffectivePolicy -ObjectDN $ObjectDN -AttributeName 'Management Type'

    if ($currMgmtType -eq $NewType) {
        "Effective policy on $ObjectDN is already $NewType" | Write-Log
            if ($Force) {
                "Setting Management Type directly on $ObjectDN anyway because force option was used" | Write-Log
                $setConfigAttr = Set-TPPConfigAttribute -ObjectDN $ObjectDN -AttributeName 'Management Type' -Values $NewType
                return $setConfigAttr
            }
        return $true
    } else {
        "Setting Management Type directly on $ObjectDN to $NewType" | Write-Log
        $setConfigAttr = Set-TPPConfigAttribute -ObjectDN $ObjectDN -AttributeName 'Management Type' -Values $NewType
        # Get new effective policy to ensure a locked policy on parent does not over-ride policy set on object
        $currMgmtType = Get-TPPEffectivePolicy -ObjectDN $ObjectDN -AttributeName 'Management Type'
        if ($currMgmtType -eq $NewType) {
            "Effective Management Type on $ObjectDN has been successfully set to $NewType" | Write-Log 
            return $true 
        }       
    } 

}


Function Get-TPPEffectivePolicy {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ObjectDN,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AttributeName
    )

    $jsonBody = @{
        ObjectDN      = $ObjectDN
        AttributeName = $AttributeName
    } | ConvertTo-Json

    $URI = $TPPWebSDK + '/Config/ReadEffectivePolicy'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -Body $jsonBody -ContentType 'application/json' -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while reading a TPP config attribute using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while reading a TPP config attribute using $URI" | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $false
    }

    [string[]]$arrReturn = @()

    # If we got response, or the attribute doesn't exist, return values. (In the case of the latter, values will be null)
    if (($response.Result -eq 1) -or ($response.Result -eq 102)) {   
        foreach ($val in $response.Values) { $arrReturn += $val }
    }
    elseif ($response.Error -ne $null) {
        $response.Error | Write-WarningLog
    }

    return $arrReturn

}


Function Set-TPPConfigAttribute {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ObjectDN,
        [Parameter(Mandatory = $true)]
        [string]$AttributeName,
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $false)]
        [Switch]$AppendToExisting
    )
    
    if ($AppendToExisting) {
        # Read current values and add to List when present
        $results = Get-TPPConfigAttribute -ObjectDN $ObjectDN -AttributeName $AttributeName
        if ($results.Count -gt 0) { $List += $results }
    }

    # Remove any duplicates
    $Values = $Values | select -Unique

    $jsonBody = @{
        ObjectDN      = $ObjectDN
        AttributeData = @(@{ Name = $AttributeName; Value = $Values})
    } | ConvertTo-Json -Depth 4

    $URI = $TPPWebSDK + '/Config/Write'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -ContentType "application/json" -Body $jsonBody -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while setting a config attribute in TPP using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while setting a config attribute in TPP from $URI" | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $false
    }

    if ($response.Result -ne 1) {
        "$($MyInvocation.InvocationName) : Error occured while setting an attribute $AttributeName for $ObjectDN" | Write-ErrorLog
        $results.Error | Write-ErrorLog
        return $false
    } else { return $true }

}

Function Find-TPPCustomFieldGuidByLabel {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $jsonBody = @{ Name = $Label } | ConvertTo-Json

    $URI = $TPPWebSDK + '/Metadata/FindItem'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -Body $jsonBody -ContentType 'application/json' -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while finding custom field GUID for $Label using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while finding custom field GUID for $Label using $URI" | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $false
    }

    if ($response.Result -eq 0) {
        if (Test-AnyProperty -Obj $response -Name 'ItemGuid') { return $response.ItemGuid } else { return $false }
    } else { return $false }

}


Function Get-TPPConfigAttribute {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectDN,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AttributeName
    )

    $jsonBody = @{
        ObjectDN      = $ObjectDN
        AttributeName = $AttributeName
    } | ConvertTo-Json

    $URI = $TPPWebSDK + '/Config/Read'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -Body $jsonBody -ContentType 'application/json' -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while reading a TPP config attribute using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while reading a TPP config attribute using $URI" | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $false
    }

    [string[]]$arrReturn = @()

    # If we got response, or the attribute doesn't exist, return values. (In the case of the latter, values will be null)
    if (($response.Result -eq 1) -or ($response.Result -eq 102)) {   
        foreach ($val in $response.Values) { $arrReturn += $val }
    }
    elseif ($response.Error -ne $null) {
        $response.Error | Write-WarningLog
    }

    return $arrReturn
}

Function Find-ObjectsInTPP {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchPattern,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Class,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchLocation,
        [Parameter(Mandatory=$false)]
        [switch]$Recursive
    )

    "Searching TPP for objects matching $SearchPattern" | Write-DebugLog

    $jsonBody = @{ Pattern = $SearchPattern }

    if (-not [string]::IsNullOrWhiteSpace($Class)) { $jsonBody.Add('Class',$Class) }
    if (-not [string]::IsNullOrWhiteSpace($SearchLocation)) { $jsonBody.Add('ObjectDN',$SearchLocation) }
    if ($Recursive) { $jsonBody.Add('Recursive',1) }

    $jsonBody = $jsonBody | ConvertTo-Json

    $URI = $TPPWebSDK + '/Config/FindObjectsOfClass'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -Body $jsonBody -ContentType 'application/json' -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while searching for a TPP object using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while searching for a TPP object using $URI" | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $null
    }

    # return result set when something was found
    if ($response.Result -eq 1 -and $response.PSObject.Properties.name -match 'Objects') {
        if ($response.objects.Count -gt 0) { return $response.Objects } else { return $null } 
    } else{
        # The search params are invalid or something went wrong
        "$($MyInvocation.InvocationName) : An error occured while searching TPP! $($response.Error)" | Write-ErrorLog
        return $null
    }

}

Function Invoke-TPPIsValid {
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ObjectDN,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ObjectGUID
    )
    if ($ObjectDN -ne $null) {
        $jsonBody = @{
            ObjectDN = $ObjectDN
        } | ConvertTo-Json
    } elseif ($ObjectGUID -ne $null) {
        $jsonBody = @{
            ObjectGUID = $ObjectGUID
        } | ConvertTo-Json
    }

    $URI = $TPPWebSDK + '/Config/IsValid'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -Body $jsonBody -ContentType 'application/json' -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while validating a TPP object using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while validating a TPP object using $URI" | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $false
    }

    # If we query was successful, return result set
    if ($response.Result -eq 1 -and $response.PSObject.Properties.name -match 'Object') {
        return $response.Object
    } else{
        # The object does not exist or something else is weird
        return $null
    }

}

Function New-TPPConfigObject {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Parent,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Class,
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Attributes
    )

    "Attempting to create object in $($Parent)" | Write-DebugLog

    if ((Invoke-TPPIsValid -ObjectDN $Parent) -eq $null) {
        "New-TPPConfigObject: specified Parent folder does not exist $($Parent)!" | Write-ErrorLog
        return $false
    }

    $newObjDN = $Parent + "\" + $Name
        $iteration = 0
        $existingObject = Invoke-TPPIsValid -ObjectDN $newObjDN
        while ($existingObject -ne $null) {
            $iteration++
            $newObjDN = $Parent + "\" + $Name + " - " + $iteration
            $existingObject = Invoke-TPPIsValid -ObjectDN $newObjDN
        }

    $arrAttributeNVPair = @()
    ForEach($key in $Attributes.keys) {
        foreach ($value in $Attributes[$key]) {
            $arrAttributeNVPair += @{ "Name" = $key; "Value" = $value }
        }
    }

    $jsonBody = @{ObjectDN=$newObjDN; Class=$Class; NameAttributeList=$arrAttributeNVPair} | ConvertTo-JSON -Compress

    $URI = $TPPWebSDK + '/Config/Create'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -Body $jsonBody -ContentType 'application/json' -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while validating a TPP object using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while validating a TPP object using $URI" | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $false
    }
    
    if ($response.Result -eq 1) {
        # Success
        return $response.Object
    } else {
        # Failure
        "Failed to create object $newObjDN in TPP!" | Write-ErrorLog
        "$($response.Error)" | Write-ErrorLog
        return $false
    } 
    
    return $false
}

Function Set-TPPCustomFieldValue{
        param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ObjectDN,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemGuid,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Array]$List,
        [Parameter(Mandatory = $false)]
        [Switch]$AppendToExisting
    )
    
    if ($AppendToExisting) {
        # Read current values and add to List when present
        $results = Get-TPPConfigAttribute -ObjectDN $ObjectDN -AttributeName $ItemGuid
        if ($results.Count -gt 0) { $List += $results }
    }

    # Remove any duplicates
    $List = $List | select -Unique

    $GuidData = @{
        ItemGuid = $ItemGuid
        List = $List
    }
    
    [Array]$GuidDataArray = $GuidData
    
    $jsonBody = @{
        DN      = $ObjectDN
        GuidData = $GuidDataArray
        KeepExisting = $true
    } | ConvertTo-Json -Depth 4

    $URI = $TPPWebSDK + '/Metadata/Set'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -Body $jsonBody -ContentType 'application/json' -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while setting custom field value using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error while setting custom field value using $URI" | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $false
    }

    # Success when result is 0 and field is unlocked
    if ($response.Result -eq 0 -and $response.Locked -eq $false) {
        return $true
    } elseif ($response.Result -eq 0 -and $response.Locked -eq $true) {
        "Failed to set custom field with guid $ItemGuid because the field is locked in TPP!" | Write-ErrorLog
        return $false
    } else {
        "Failed to set custom field with guid $ItemGuid. Error code is $($response.Result)" | Write-ErrorLog
        try { $response.Error | Write-ErrorLog } catch [Exception]{ $error.clear() }
        "HINT: Ensure the account used to generate OAuth access token has (at minimum) Read, Write & Create access to $ObjectDN" | Write-ErrorLog
        "HINT: The permissions should be set on the folder containing this certificate object or one of its' parent folders. Then fetch a new token and retry" | Write-ErrorLog
        return $false
    }

}


Function Invoke-TPPAssociateCertToApp {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationDN,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CertificateDN,
        [Parameter(Mandatory = $false)]
        [switch]$Push
    )

    if ($Push) {
        $jsonBody = @{
            ApplicationDN = @($ApplicationDN)
            CertificateDN = $CertificateDN
            PushToNew = "true"
        } | ConvertTo-Json
    } else {
        $jsonBody = @{
            ApplicationDN = @($ApplicationDN)
            CertificateDN = $CertificateDN
            PushToNew = "false"
        } | ConvertTo-Json
    }

    $URI = $TPPWebSDK + '/Certificates/Associate'

    try {
        $($response = Invoke-RestMethod -Uri $URI -Method "POST" -Headers $TPPAuthHeader -Body $jsonBody -ContentType 'application/json' -TimeoutSec $global:APIgwTimeout) 4>&1 | Write-DebugLog
    } catch [Exception] {
        $_.Exception.Message | Write-ErrorLog
        try { $_.Exception.Response.StatusDescription | Write-ErrorLog } catch { }
        try { $_.Exception.Response.PSObject.Properties | ForEach-Object { $_.Name + ' : ' + $_.Value | Write-DebugLog }  } catch { $error.clear() }
        $global:errorMessage = "Error occured while Associating Cert $CertificateDN to App $ApplicationDN using $URI $($_.Exception.Message)"
        "$($MyInvocation.InvocationName) : Error occured while Associating Cert $CertificateDN to App $ApplicationDN using $URI " | Write-ErrorLog
        try { $response.error | Write-ErrorLog } catch { $error.clear() }
        $jsonBody | Write-DebugLog
        return $false
    }

    if (Test-AnyProperty -Obj $response -Name 'Success') {
        if ($response.Success) { 
            return $true 
        } else { 
            "Error occured while Associating Cert $CertificateDN to App $ApplicationDN. $($response.Error)" | Write-ErrorLog
            return $false 
        }
    } else{
        "Error occured while Associating Cert $CertificateDN to App $ApplicationDN. $($response.Error)" | Write-ErrorLog
        return $false
    }

}


#################################################### - Helper Functions - #####################################################################
    

Function Initialize-Logging {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [switch]$Fixedlog,
        [Parameter(Mandatory=$false)]
        [switch]$SingleCommitToDisk
    )

    If ($SingleCommitToDisk) {
        $global:LogToVariable = $true
    } else {
        $global:LogToVariable = $false
    }      

    if ((Test-Path variable:global:LogFileName) -and (-not [string]::IsNullOrWhiteSpace($global:LogFileName)) -and ($global:LogFileName.Length -ge 6)) {
        $localLogFileName = $Global:LogFileName.Trim()
    } else {
        $tmpStr = $MyInvocation.PSCommandPath
        $localLogFileName = $tmpStr.SubString($tmpStr.LastIndexOf('\')+1,$tmpStr.Length-$tmpStr.LastIndexOf('\')-1)
    }

    # Determine if the passed log name is suitable
    $localLogFileName = $localLogFileName -replace "[\\/:*?""<>|]",""

    If ($localLogFileName.Length -lt 6) {
        $tmpStr = ([char[]]([char]'a'..[char]'z')| sort {get-random})[0..6] -join ''
        $localLogFileName = "generated-logname-$tmpStr"
    } ElseIf ($localLogFileName -imatch '^.{2,}(\.[A-Za-zps1]{3})$') {
        $localLogFileName = $($localLogFileName.Remove($localLogFileName.Length-4,4)).Trim()
    }
    # Set the logging location
    $global:LogFile = $null
    if ((Test-Path variable:global:CustomLogFolder) -and (-not [string]::IsNullOrWhiteSpace($global:CustomLogFolder)) -and ((Test-Path $global:CustomLogFolder))) {
        # Log to custom folder when set
        if ($Fixedlog) { 
            $global:LogFile = Join-Path -Path $global:CustomLogFolder -ChildPath "$localLogFileName.log" 
        } else { 
            $global:LogFile = Join-Path -Path $global:CustomLogFolder -ChildPath "$localLogFileName $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd hhmmss')).log" 
        }
    } else {
        if ($Fixedlog) { 
            $global:LogFile = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform").'Base Path' + "Logs\$localLogFileName.log" 
        } else { 
            $global:LogFile = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform").'Base Path' + "Logs\$localLogFileName $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd hhmmss')).log" 
        }
    }

}


Function Write-Log {
    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [string]$message
    )

    Process {
        if ($LogToVariable) {
            $LogStringBuilder.AppendLine("$(Get-Date) INFO $_")
            return
        } 
        if (Test-Path $global:LogFile) {
            "$(Get-Date) INFO $_" | Out-File -LiteralPath $global:LogFile -Append
        } else {
            "$(Get-Date) INFO $_" | Out-File -LiteralPath $global:LogFile -Force
        } 
    }
}

Function Write-DebugLog {
    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [string]$message
    )

    Process {
        # When debug is enabled
        if (($DebugPreference -eq "Continue") -and ($VerbosePreference -eq "Continue")) {
            if ($LogToVariable) {
                $LogStringBuilder.AppendLine("$(Get-Date) DEBUG $_")
            return
            } 
            if (Test-Path $global:LogFile) {
                "$(Get-Date) DEBUG $_" | Out-File -LiteralPath $global:LogFile -Append
            } else {
                "$(Get-Date) DEBUG $_" | Out-File -LiteralPath $global:LogFile -Force
            }
        } 
    }
}

Function Write-ErrorLog {
    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [string]$message
    )

    Process {
        if ($LogToVariable) {
            $LogStringBuilder.AppendLine("$(Get-Date) ERROR $_")
            return
        } 
        if (Test-Path $global:LogFile) {
            "$(Get-Date) ERROR $_" | Out-File -LiteralPath $global:LogFile -Append
        } else {
            "$(Get-Date) ERROR $_" | Out-File -LiteralPath $global:LogFile -Force
        } 
    }
}

Function Write-WarningLog {
    [cmdletbinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [string]$message
    )

    Process {
        if ($LogToVariable) {
            $LogStringBuilder.AppendLine("$(Get-Date) WARN $_")
            return
        } 
        if (Test-Path $global:LogFile) {
            "$(Get-Date) WARN $_" | Out-File -LiteralPath $global:LogFile -Append
        } else {
            "$(Get-Date) WARN $_" | Out-File -LiteralPath $global:LogFile -Force
        } 
    }
}

Function Close-Logging {
    Param()
    if ($LogToVariable) {
        $LogStringBuilder.AppendLine("")
        if (Test-Path $global:LogFile) {
            $global:LogStringBuilder.ToString() | Out-File -LiteralPath $global:LogFile -NoNewline -Append
        } else {
            $global:LogStringBuilder.ToString() | Out-File -LiteralPath $global:LogFile -NoNewline -Force
        } 
    }
}

Function Test-AnyProperty {
    param(
    [Parameter(mandatory=$true)][string]$Name,
    [Parameter(mandatory=$true)][object]$Obj
    )

    Try {
        $Obj.$Name > $null
        return $true
    } Catch {
        $Error.Clear()
        return $false
    }
}