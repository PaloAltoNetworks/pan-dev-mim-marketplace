<#
//---------------------------------------------------------------------------
// WinRM SSRS Workflow.ps1
//
// v1.0 - July 2021
//---------------------------------------------------------------------------
// This adaptable driver enables organizations to bind certificate into SSRS
// in MS SQL using WinRM.
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// Venafi hereby grants you a limited license to use and modify this
// software, including any Contributions, during only the period in which you
// hold a valid license from Venafi to use the Venafi Trust Protection
// Platform. For the purposes of this copyright notice, “Contributions”
// means any modifications of this software or derivative works based on
// this software. You have a responsibility to share any Contributions you
// may make with the Venafi community. To the extent you may create any,
// Contributions, Venafi will have an irrevocable license to use, modify or
// distribute those Contributions.
//
// THE SOFTWARE IS PROVIDED AS-IS AND WITHOUT ANY WARRANTY, EXPECTATION OF
// COMPATIBILITY, TECHNICAL SUPPORT, ASSISTANCE, UPDATES, OR OTHER SERVICES
// THAT MIGHT BE PROVIDED TO YOU OTHERWISE. YOU ACKNOWLEDGE AND AGREE THAT
// THIS SOFTWARE DOES NOT CONSTITUTE COMMERCIAL RELEASE OF VENAFI SOFTWARE
// AND MAY CONTAIN BUGS OR OTHER ERRORS OR CAUSE ERRORS IN OTHER SOFTWARE OR
// SYSTEMS WHEN USED IN CONJUNCTION THEREWITH. TO THE EXTENT VENAFI HAS MADE
// ANY WARRANTIES TO YOU REGARDING THE FITNESS OF SOFTWARE FOR ANY PURPOSE,
// OR THAT SOFTWARE MAY BE FREE FROM BUGS OR OTHER ERRORS, THIS SOFTWARE AND
// ANY PRODUCTS WHEN USED IN CONJUNCTION THEREWITH ARE EXPRESSLY EXCLUDED
// FROM ANY SUCH WARRANTIES. BY USING THIS SOFTWARE, YOU HEREBY AGREE TO
// FOREVER RELEASE AND HOLD HARMLESS VENAFI, ITS DIRECTORS, OFFICERS,
// EMPLOYEES, AGENTS, AND AFFILIATES FROM ANY LIABILITY OR DEMANDS ARISING
// THEREFROM OR RELATING THERETO, REGARDLESS OF THE THEORY OF LIABILITY.
//
// The software and its contents are provided by Venafi to customers for the
// purposes of integrating with services and platforms. Any sharing of the
// software outside your organization without consent from Venafi is
// strictly prohibited. Without limiting the foregoing, the above copyright
// notice, preceding paragraphs, this paragraph and the following paragraph
// must appear in all copies, modifications, reproductions, and
// distributions of this software.
//
// IN NO EVENT SHALL VENAFI, ITS DIRECTORS, OFFICERS, EMPLOYEES, AGENTS, OR
// AFFILIATES BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL,
// INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT
// OF THE USE OF THIS SOFTWARE OR ITS DOCUMENTATION, IF ANY, EVEN IF VENAFI
// HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. VENAFI SPECIFICALLY
// DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. THIS
// SOFTWARE, ALONG WITH ITS DOCUMENTATION, IF ANY, IS PROVIDED "AS IS".  
//---------------------------------------------------------------------------

Custom Fields column definition
-------------------------------
<field name>|<label text>|<flags>

<field name>: Do not change
<label text>: This text will show up in the UI 
<flags>: 
    Bit 1 = Enabled
    Bit 2 = Mandatory


-----BEGIN FIELD DEFINITIONS-----
Text1|Text Field #1|00
Text2|Text Field #2|00
Text3|Text Field #3|00
Text4|Text Field #4|00
Text5|Text Field #5|00
Text6|Text Field #6|00
Text7|Text Field #7|00
Text8|Text Field #8|00
Text9|Text Field #9|00
Text10|Text Field #10|00
Text11|Text Field #11|00
Text12|Text Field #12|00
-----END FIELD DEFINITIONS-----

#>
<######################################################################################################################
NAME
   Process
DESCRIPTION
    Processes a workflow in Trust Protection Platform (TPP). It is the author's responsbility to write custom logic and create/skip ticket creation.
    This script reads the desired 'Key Size' of the certificate object passed and depending on the key size returns either 'Rejected' (no ticket issued), 
    'TicketRequested' (asking TPP to issue a workflow ticket) or 'Approved' (no ticket issued). When the 'TicketRequested' status is sent, it is accompanied 
    with a list of approvers except the one that requested the renewal.
PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions.
        ServiceAddress : a string identifying the service endpoint (URL, host, port, etc) of the calling Adaptable Workflow object.
        UserName : a string containing the username portion of the credential assigned to the Adaptable Workflow object.
        UserPass : a string containing the password portion of the credential assigned to the Adaptable Workflow object.
        AuxUser : a string containing username portion of the secondary credential assigned to the Adaptable Workflow object.
        AuxPass : a string containing password portion of the secondary credential assigned to the Adaptable Worklfow object.
        AuxPfxData: a string containing pfx data of the secondary credential assigned to the Adaptable Workflow object.
PARAMETER Fields
    A hashtable containing the values specfic to conditions and actions related to Adaptable Workflow object.
        WorkflowDn : string representing the DN of the Adaptable Workflow object in TPP.
        ObjectDn  : string representing the DN of the object being processed.
        ObjectClassName : string representing the class type of the 'ObjectDn' being passed. 
        RequestedBy : string representing the prefixed universal (universal name of an identity prefixed by the name) of the person who clicked 'Renew' on the cert or 'Push' on the application. 
        CertificateVaultId : If the object type is certificate then this parameter will contain the certificate VaultID. 
        TppWebSdkUrl : string representing the complete URL for the TPP WebSDK.  
        WorkflowStage : The stage assigned to the Adaptable Workflow object.
        WorkflowApprovers : List of identities allowed to approve the ticket.
        WorkflowReason : The reason description assigned to the Adaptable Workflow object.
        ReferenceId : The Id sent by the script to TPP which TPP sends back in the subsequent go around. 
PARAMETER CustomFields
    A hashtable containing all of the custom fields defined over Adaptable Workflow object. These fields are configured via the script.

NOTES
    Returns...
        Result : See Section 1 for possible status values.
        Details : Information about why a particular result status is being sent. 
        WorkflowApprovers : If the Result is "TicketRequested", it is accompanied with list of workflow approvers. 
######################################################################################################################>

function Process
{
    # Define parameter - Do not change.
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Workflow Detail Parameters")]
        [System.Collections.Hashtable]$Fields,
        [Parameter(Mandatory=$true,HelpMessage="Custom Field Parameters, if defined")]
        [System.Collections.Hashtable]$CustomFields
    )

	# Section 1 - Return Variables - Do not change.
    Set-Variable -Name Rejected -Value Rejected -Option Constant
    Set-Variable -Name Approved -Value Approved -Option Constant
    Set-Variable -Name Pause -Value Pause -Option Constant
    Set-Variable -Name TicketRequested  -Value TicketRequested  -Option Constant

	# Section 2 - Write Custom Logic. 
    $result = @{}
    $server = $General.ServiceAddress
    $username = $General.UserName
    $password = $General.UserPass
    $objectDN = $Fields.ObjectDn -replace '\\', '\\'
    $objectClassName = $Fields.ObjectClassName
    $requestedBy = $Fields.RequestedBy
    [int]$certVaultID = $Fields.CertificateVauldId
    $workflowDN = $Fields.WorkflowDn -replace '\\', '\\'
    $tppWebSdkUrl = $Fields.TppWebSdkUrl
    [string[]]$apps = $Fields.WorkflowApprovers -split ","

    if([string]::IsNullOrWhiteSpace($username)) {
        throw [System.ArgumentNullException] "Mandatory Field 'UserName' is missing from parameter General."
    }

    if([string]::IsNullOrWhiteSpace($password)) {
        throw [System.ArgumentNullException] "Mandatory Field 'UserPass' is missing from parameter General."
    }

    if([string]::IsNullOrWhiteSpace($objectDN)) {
        throw [System.ArgumentNullException] "Mandatory Field 'ObjectDn' is missing from parameter Fields."
    }

    if([string]::IsNullOrWhiteSpace($objectClassName)) {
        throw [System.ArgumentNullException] "Mandatory Field 'ObjectClassName' is missing from parameter Fields."
    }

    if([string]::IsNullOrWhiteSpace($workflowDN)) {
        throw [System.ArgumntNullException] "Mandatory Field 'WorkflowDn' is missing from parameter Fields."
    }

    if([string]::IsNullOrWhiteSpace($tppWebSdkUrl)) {
        throw [System.ArgumntNullException] "Mandatory Field 'TPPWebSdkUrl' is missing from parameter Fields."
    }

   # if($apps -eq $null) {
    #    throw [System.ArgumentNullException] "Mandatory Field 'WorkflowApprovers' is missing from parameter Fields."
    #}
        
    try {
        # Connect to TPP
        $callResponse = Connect-TPP -webSdkURL $tppWebSdkUrl -Username $username -Password $password -IgnoreSSLWarnings 

        # Get all individual users except the one that requested the renewal
     #   if ($apps.Count -gt 0) {
      #      $apps = Get-Users -Approvers $apps -UserToExclude $requestedBy  -ConnectionInfo $callResponse                
       # }

        # Certificate the certficate DN 
      $CertDN = Get-CertificateAttributeValue -ObjectDN $objectDN -Attribute "Certificate" -ConnectionInfo $callResponse

      #ObjectDN SSL Listen Port
      $SSL_Listen_Port = Get-SSLListenPort -ObjectDN $objectDN -ConnectionInfo $callResponse  
                
        # Get the certificate Guid given the CertificateDN
       $CertGuid = Get-Guid -ObjectDN $CertDN -ConnectionInfo $callResponse 

        # Get the certificate thumbprint given the Certificate Guid
       $CertThumprint = Get-CertificateThumbPrint -Guid $CertGuid -ConnectionInfo $callResponse 

       #Get the certificate CN given the Certificate Guid.

       $CertCN = Get-CertificateCN -Guid $CertGuid -ConnectionInfo $callResponse


         # Set the current location to where this script is expected to be located at.
        Set-Location "\Program Files\Venafi\Scripts\AdaptableWorkflow"

        $DeviceDN = $ObjectDN  -replace "\\\\([^\\]+$)", ""

        $CredDN = Get-CertificateAttributeValue -ObjectDN $DeviceDN -Attribute "Credential" -ConnectionInfo $callResponse 

        $Hostname = Get-CertificateAttributeValue -ObjectDN $DeviceDN -Attribute "Host" -ConnectionInfo $callResponse

        $CredValues = Get-Credential -CredDN $CredDN -ConnectionInfo $callResponse 

        $CertCN | Out-File .\CertCN.txt 

        $securePassword = ConvertTo-SecureString "$($CredValues[1].Value)" -AsPlainText -force
        $cred = New-Object System.Management.Automation.PsCredential("$($CredValues[0].Value)",$securePassword)

        Invoke-Command -ComputerName $Hostname -ScriptBlock  {
        
        

        $SSRS_Name = Get-WmiObject -Namespace root\microsoft\sqlserver\ReportServer -Class __Namespace -ComputerName localhost | Select Name
        
        $SSRS_version = Get-WmiObject -Namespace root\microsoft\sqlserver\Reportserver\$($SSRS_Name.Name) -Class __Namespace -ComputerName localhost|Select Name
  
        $SSRS_Object = Get-WmiObject -Namespace root\microsoft\sqlserver\Reportserver\$($SSRS_Name.Name)\$($SSRS_version.Name)\admin -Class "MSReportServer_ConfigurationSetting" -ComputerName localhost
        
        
        $xml = [xml] (Get-Content $SSRS_Object.PathName )
        $applications =  $xml.Configuration.URLReservations.Application.Name

        
        
        $SSRS_Urls =$SSRS_Object.ListReservedUrls().UrlString 

        $SSRS_Application_urls = $SSRS_Object.ListReservedUrls().Application
        
        $SSRS_certsHash =$SSRS_Object.ListSSLCertificateBindings(4105).CertificateHash
       
        $SSRS_Port = $SSRS_Object.ListSSLCertificateBindings(4105).Port 
  
        $SSRS_IPAddresses = $SSRS_Object.ListSSLCertificateBindings(4105).IPAddress
  
        $SSRS_Application = $SSRS_Object.ListSSLCertificateBindings(4105).Application
        
        $urls_length = $SSRS_Object.ListReservedUrls().Length
        $bind_length = $SSRS_Object.ListSSLCertificateBindings(4105).Length

        $SSRS_IP_Port =@{}
        $Port = @()

        if($($SSRS_Port | select -Unique).Length -gt 1 ){

        for ($i=0;$i -lt $bind_length ;$i++){
        if ($($SSRS_Application)[$i] -eq "ReportServerWebApp"){
        $SSRS_IP_Port.Add($($SSRS_IPAddresses)[$i],$($SSRS_Port)[$i])
        $Port = $($SSRS_Port)[$i]
        }

        }
       
       }elseif($($SSRS_Port | select -Unique).Length -eq 1){
       
       $Port = $($SSRS_Port | select -Unique)
        $SSRS_IP_Port.Add("::",$($Port))
        $SSRS_IP_Port.Add("0.0.0.0",$($Port))
        }
       
        if ($($SSRS_certsHash) -ne $null){
        
         
        for($i=0;$i -lt $urls_length ;$i++){
   
        
        $SSRS_Object.RemoveURL($($SSRS_Application_urls)[$i],$($SSRS_Urls)[$i],4105)
          start-sleep -Seconds 2
        }
        
        for($i=0;$i -lt  $bind_length  ;$i++){
       
        $SSRS_Object.RemoveSSLCertificateBindings($($SSRS_Application)[$i],$($SSRS_certsHash)[$i],$($SSRS_IPAddresses)[$i],$($SSRS_Port)[$i],4105)
         start-sleep -Seconds 2
         
         }

        for ($i=0;$i -lt $Port.Count ;$i++){
        $SSRS_Object.ReserveURL("$($applications[0])","https://$($($Using:CertCN).ToString()):$($($Port)[$i])",4105)
        }
        
       
        $SSRS_Object.ReserveURL("$($applications[0])","http://+:80",4105)
        
        
        for($i=0; $i -lt $SSRS_IP_Port.Count ; $i++){
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[0])","$($($Using:CertThumprint).ToLower())",$($SSRS_IP_Port.Keys)[$i],$($SSRS_IP_Port.Values)[$i],4105)
     }
       
       ###################################################################
       
        for ($i=0;$i -lt $Port.Count ;$i++){
        $SSRS_Object.ReserveURL("$($applications[1])","https://$($($Using:CertCN).ToString()):$($($Port)[$i])",4105)
        }
        
       
        $SSRS_Object.ReserveURL("$($applications[1])","http://+:80",4105)
        
        
        for($i=0; $i -lt $SSRS_IP_Port.Count ; $i++){
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[1])","$($($Using:CertThumprint).ToLower())",$($SSRS_IP_Port.Keys)[$i],$($SSRS_IP_Port.Values)[$i],4105)
     }
       
              
        }else{
         $($Using:CertCN) | Out-File certCN111.txt
        if($Using:SSL_Listen_Port -ne $null){
       

        $SSRS_Object.ReserveURL("$($applications[0])","https://$($($Using:CertCN).ToString()):$($Using:SSL_Listen_Port)",4105)
        $SSRS_Object.ReserveURL("$($applications[0])","http://+:80",4105)
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[0])","$($($Using:CertThumprint).ToLower())","0.0.0.0",$Using:SSL_Listen_Port,4105)
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[0])","$($($Using:CertThumprint).ToLower())","::",$Using:SSL_Listen_Port,4105)
           
        $SSRS_Object.ReserveURL("$($applications[1])","https://$($($Using:CertCN).ToString()):$($Using:SSL_Listen_Port)",4105)
        $SSRS_Object.ReserveURL("$($applications[1])","http://+:80",4105)
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[1])","$($($Using:CertThumprint).ToLower())","0.0.0.0",$Using:SSL_Listen_Port,4105)
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[1])","$($($Using:CertThumprint).ToLower())","::",$Using:SSL_Listen_Port,4105)
         }else{
         
        $SSRS_Object.ReserveURL("$($applications[0])","https://$($($Using:CertCN).ToString()):443",4105)
        $SSRS_Object.ReserveURL("$($applications[0])","http://+:80",4105)
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[0])","$($($Using:CertThumprint).ToLower())","0.0.0.0","443",4105)
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[0])","$($($Using:CertThumprint).ToLower())","::","443",4105)
           
        $SSRS_Object.ReserveURL("$($applications[1])","https://$($($Using:CertCN).ToString()):443",4105)
        $SSRS_Object.ReserveURL("$($applications[1])","http://+:80",4105)
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[1])","$($($Using:CertThumprint).ToLower())","0.0.0.0","443",4105)
        $SSRS_Object.CreateSSLCertificateBinding("$($applications[1])","$($($Using:CertThumprint).ToLower())","::","443",4105)
        
         
         
         
         
         } 
        }
       
        Stop-Service -Name sqlServerReportingServices

        Start-Service -Name sqlServerReportingServices 


        }  -Credential $cred 
      
        $result = @{Result = "$Approved"; Details = "Approved"}
      
    } catch {
        throw $_.Exception
    }    
	
    # Section 3 - Return Result. Strictly use values from Section 1.
 	
    return $result
}


<###################### THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ######################>

# Gets all the individual users from the Approvers list except for the one that last renewed the certificate
function Get-Users {
    param(
    [Parameter(Mandatory=$true, Position = 0)]
    [String[]]
    $Approvers,        
    [Parameter(Mandatory=$false, Position = 1)]
    [string]
    $UserToExclude,
    [Parameter(Mandatory=$true, Position = 2)]
    $ConnectionInfo    
    )

    $finalApprovers = New-Object System.Collections.Generic.HashSet[String]

    foreach ($approver in $Approvers) {
        $getMembersData = @{ 
        "ID" = @{
            "PrefixedUniversal" = "$approver"
        } 
        "ResolveNested" = 1 
        } | ConvertTo-Json -Compress
        $response = Invoke-RestMethod -Uri "$($ConnectionInfo.WebSdkURL)/Identity/GetMembers" -Headers $ConnectionInfo.Headers -ContentType "application/json" -Method Post -Body $getMembersData
        if ($response -eq $null) {
            throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Identity/GetMembers WebSDK call failed."
        }

        if ($response.Identities) {
            # If it's a group then iterate over the members
            foreach ($identiy in $response.Identities) {
                if ($identiy.PrefixedUniversal -ne $UserToExclude) {
                    $finalApprovers.Add($identiy.PrefixedUniversal) > $null
                }
            }
        } else {
            if ($approver -ne $UserToExclude) {
                $finalApprovers.Add($approver) > $null
            }
        }
    }

    return $finalApprovers
}

# Gets the specified object attribute value given the ObjectDN and Attribute name by making the TPP WebSDK API call
function Get-CertificateAttributeValue {
    param(    
    [Parameter(Mandatory=$true, Position = 0)]
    [string]
    $ObjectDN,
    [Parameter(Mandatory=$true, Position = 1)]
    [string]
    $Attribute,
    [Parameter(Mandatory=$true, Position = 2)]
    $ConnectionInfo    
    )

    # Make a Config Read call to get the certificate attribute value
    $data = @{
        "ObjectDN" = $ObjectDN
        "AttributeName" = "$Attribute"
    } | ConvertTo-Json -Compress

    $response = Invoke-RestMethod -Uri "$($ConnectionInfo.WebSdkURL)/Config/Read" -Headers $ConnectionInfo.Headers -ContentType "application/json" -Method Post -Body $data
    if ($response -eq $null -or $response.Values -eq $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/Read WebSDK call failed to return value for attribute '$Attribute' on certificate object '$ObjectDN'."
    }

    if ($response.Error -ne $null -and $response.Error.Contains("ObjectDoesNotExist")) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/Read WebSDK call failed to return value for attribute '$Attribute' on certificate object '$ObjectDN' because the object does not exist."
    }

    if ($response.Error -and $response.Error.Contains("AttributeNotFound")) {
        return $null
    }

    if ($response.Error -ne $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/Read WebSDK call failed with an error: $($response.Error)."
    }

    return $response.Values
}

# Gets the specified Certificate SSL Listen Port attribute value given the Certificate DN  by making the TPP WebSDK API call
function Get-SSLListenPort {
    param(    
    [Parameter(Mandatory=$true, Position = 0)]
    [string]
    $ObjectDN,
    [Parameter(Mandatory=$true, Position = 1)]
    $ConnectionInfo    
    )

    # Make a Config Read call to get the certificate attribute value
    $data = @{
        "ObjectDN" = $ObjectDN
        "AttributeName" = "SSL Listen Port"
    } | ConvertTo-Json -Compress

    $response = Invoke-RestMethod -Uri "$($ConnectionInfo.WebSdkURL)/Config/Read" -Headers $ConnectionInfo.Headers -ContentType "application/json" -Method Post -Body $data
    if ($response -eq $null -or $response.Values -eq $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/Read WebSDK call failed to return value for attribute 'SSL Listen Port' on certificate object '$ObjectDN'."
    }

    if ($response.Error -ne $null -and $response.Error.Contains("ObjectDoesNotExist")) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/Read WebSDK call failed to return value for attribute 'SSL Listen Port' on certificate object '$ObjectDN' because the object does not exist."
    }

    if ($response.Error -and $response.Error.Contains("AttributeNotFound")) {
        return $null
    }

    if ($response.Error -ne $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/Read WebSDK call failed with an error: $($response.Error)."
    }

    return $response.Values
}

# Gets the specified object Guid given the ObjectDN by making the TPP WebSDK API call
function Get-Guid {
    param(    
    [Parameter(Mandatory=$true, Position = 0)]
    [string]
    $ObjectDN,
    [Parameter(Mandatory=$true, Position = 2)]
    $ConnectionInfo    
    )

    # Make a Config Read call to get the certificate attribute value
    $data = @{
        "ObjectDN" = $ObjectDN
     
    } | ConvertTo-Json -Compress

    $response = Invoke-RestMethod -Uri "$($ConnectionInfo.WebSdkURL)/Config/DnToGuid" -Headers $ConnectionInfo.Headers -ContentType "application/json" -Method Post -Body $data
    if ($response -eq $null -or $response.GUID -eq $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/DnToGuid WebSDK call failed to return value for object '$ObjectDN'."
    }

    if ($response.Error -ne $null -and $response.Error.Contains("ObjectDoesNotExist")) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/DnToGuid WebSDK call failed to return value for object '$ObjectDN' because the object does not exist."
    }

    
    if ($response.Error -ne $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Config/DnToGuid WebSDK call failed with an error: $($response.Error)."
    }

    return $response.GUID
}


# Gets the Certificate ThumbPrint given the Guid by making the TPP WebSDK API call
function Get-CertificateThumbPrint {
    param(    
    [Parameter(Mandatory=$true, Position = 0)]
    [string]
    $Guid,
    [Parameter(Mandatory=$true, Position = 1)]
    $ConnectionInfo    
    )


    $response = Invoke-RestMethod -Uri "$($ConnectionInfo.WebSdkURL)/certificates/$($Guid)" -Headers $ConnectionInfo.Headers -ContentType "application/json" -Method Get 
    if ($response -eq $null -or $response.CertificateDetails -eq $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/certificates WebSDK call failed to return value for Guid '$Guid'."
    }

    if ($response.Error -ne $null -and $response.Error.Contains("ObjectDoesNotExist")) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/certificates WebSDK call failed to return value for value for Guid '$Guid'."
    }

    if ($response.Error -and $response.Error.Contains("AttributeNotFound")) {
        return $null
    }

    if ($response.Error -ne $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/certificates WebSDK call failed with an error: $($response.Error)."
    }

    return $response.CertificateDetails.Thumbprint
}

# Gets the Certificate ThumbPrint given the Guid by making the TPP WebSDK API call
function Get-CertificateCN {
    param(    
    [Parameter(Mandatory=$true, Position = 0)]
    [string]
    $Guid,
    [Parameter(Mandatory=$true, Position = 1)]
    $ConnectionInfo    
    )


    $response = Invoke-RestMethod -Uri "$($ConnectionInfo.WebSdkURL)/certificates/$($Guid)" -Headers $ConnectionInfo.Headers -ContentType "application/json" -Method Get 
    if ($response -eq $null -or $response.CertificateDetails -eq $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/certificates WebSDK call failed to return value for Guid '$Guid'."
    }

    if ($response.Error -ne $null -and $response.Error.Contains("ObjectDoesNotExist")) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/certificates WebSDK call failed to return value for value for Guid '$Guid'."
    }

    if ($response.Error -and $response.Error.Contains("AttributeNotFound")) {
        return $null
    }

    if ($response.Error -ne $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/certificates WebSDK call failed with an error: $($response.Error)."
    }

    return $response.CertificateDetails.CN
}
  
# Retrieve the Credential given the credential ObjectDN  by making the TPP WebSDK API call
function Get-Credential {
    param(    
    [Parameter(Mandatory=$true, Position = 0)]
    [string]
    $CredDN,
    [Parameter(Mandatory=$true, Position = 1)]
    $ConnectionInfo    
    )

    # Make a Config Read call to get the certificate attribute value
    $data = @{
        "CredentialPath" = $CredDN
      } | ConvertTo-Json -Compress

    $response = Invoke-RestMethod -Uri "$($ConnectionInfo.WebSdkURL)/Credentials/Retrieve" -Headers $ConnectionInfo.Headers -ContentType "application/json" -Method Post -Body $data
    if ($response -eq $null -or $response.Values -eq $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Credentials/Retrieve WebSDK call failed to return value for Credentials object '$ObjectDN'."
    }

    if ($response.Error -ne $null -and $response.Error.Contains("ObjectDoesNotExist")) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Credentials/Retrieve WebSDK call failed to return value for Credentials object '$ObjectDN'."
    }

    if ($response.Error -and $response.Error.Contains("AttributeNotFound")) {
        return $null
    }

    if ($response.Error -ne $null) {
        throw "[Function:$($MyInvocation.MyCommand)] $($ConnectionInfo.WebSdkURL)/Credentials/Retrieve WebSDK call failed with an error: $($response.Error)."
    }

    return $response.Values
}

# Gets the TPP WebSDK connection
function Connect-TPP {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $webSdkURL,
        [Parameter(Mandatory = $true, ParameterSetName='Supplied UserPass')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,
        [Parameter(Mandatory = $true, ParameterSetName='Supplied UserPass')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Password,
        [switch]
        $IgnoreSSLWarnings
    )

    $war = [string]::Empty
    $error = [string]::Empty
    if ($IgnoreSSLWarnings) {
        $war = "[Function:$($MyInvocation.MyCommand)] Ignoring any TLS/SSL warnings on connection."
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $true
        }
    }

    $json = @{
        Username = $Username
        Password = $Password
    } | ConvertTo-Json -Compress

    # Try to call the WebSDK Authorize method
    try {
        # This will throw an error if unable to connect for any reason!
        $response = Invoke-RestMethod -Uri "$($webSdkURL)/Authorize" -Body $json -Method POST -ContentType 'application/json' -Verbose:$false

        if ($response -eq $null -or [System.String]::IsNullOrEmpty($response.APIKey) -or [System.String]::IsNullOrEmpty($response.ValidUntil)) {
            throw "[Function:$($MyInvocation.MyCommand)] Unable to connect to WebSDK. Response was: '$($response)'."
        }
    } catch {
        throw "[Function:$($MyInvocation.MyCommand)] Unable to connect to WebSDK: $($_.Exception.Message)."
    }

    $headers = New-Object -TypeName 'System.Collections.Generic.Dictionary[[String], [String]]'
    $headers.Add('X-Venafi-Api-Key', $response.APIKey)

    #Create a brand-new object to hold the connection information for reuse
    $objConnection = [PSCustomObject]@{
        Headers           = $headers
        APIKey            = $response.APIKey
        ValidUntil        = $response.ValidUntil
        Username          = $Username
        WebSdkURL         = $webSdkURL
        IgnoreSSLWarnings = $IgnoreSSLWarnings
        Issues= $war
    }

    return $objConnection
}