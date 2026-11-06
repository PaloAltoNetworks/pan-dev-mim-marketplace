<#
//---------------------------------------------------------------------------
// TheSSLStore-PositiveSSLMulti-DomainWildcard.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by The SSL Store, in addition to Venafi.
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

$global:tss_base_live_url = "https://api.thesslstore.com/rest" 
$global:tss_base_sandbox_url = "https://sandbox-wbapi.thesslstore.com/rest" 
$global:tss_mode = "LIVE" ##Can be LIVE OR TEST
$global:tss_UserAgent = 'TSS-VenafiAdaptableCA-v0.6'
$global:tss_ProductCode = 'positivemdcwildcard'
$global:ResultSuccess = 'Success'
$global:MinorStatusArr = @('ACTIVE','VALID','COMPLETED','START','ISSUED','COMPLETE')
$global:MajorStatusArr  = @('ACTIVE')
$global:PendingState  = 'Pending'
$global:IssuedState  = 'Issued'
$global:AdminEmail = "admin@yourdomain.com"   # REPLACE with your organization's admin contact email
$global:AdminPhone = "5555550100"   # REPLACE with your organization's admin contact phone

function Test-Settings
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )

    return @{ Result=Get-TSSStatus}
}


function Get-ChainCertificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )    
    return @{ Result="NotUsed" }
}


function Prepare-ForRequest
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    $result =   Get-TSSStatus     
    return @{ Result=$result}    
}



function  TSS-PlaceOrder(){
    
    param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific,
        [Parameter(Mandatory = $true, HelpMessage = "For New or Renew Order")]
        [System.Boolean]$IsRenew

    )
     $username = $General['UserName']
     $userpass = $General['UserPass']
    $stat = 'NotUsed'
     $transID = '{notset}'
    if($Specific['SubjectDN']['CN'].IndexOf("*.") -eq 0)
     {
         throw 'Error: OPPS! Primary domain should not allowed as wildcard domain.'
        #return @{ Result = 'Error: OPPS! Wildcard Domain name not allowed.'; TransId = $transID}
        break
     }

    $custdomain = ''
    if($Specific['SubjAltNames']['DNS'].Length -gt 0)
    {
           $tmvr1 = $Specific['SubjAltNames']['DNS'] -join ""           
           $lstComma1 = $tmvr1.ToString().Substring($tmvr1.ToString().Length - 1,1)                      
           $custdomain = @{$true = $tmvr1.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries); $false =  $Specific['SubjAltNames']['DNS'].Split(",",[System.StringSplitOptions]::RemoveEmptyEntries) }[($lstComma1 -eq ',')]
    }

    
    $dmList = @()
    $dmList += $Specific['SubjectDN']['CN'].ToString()
    if($custdomain.Length -gt 0)
    {
        $dmList += $custdomain
    }
    
    #throw  $dmList + " " + $dmList.Count

    $custApproveremail = ''
    if($Specific['SubjAltNames']['Email'].Length -gt 0)
    {
           $tmvr = $Specific['SubjAltNames']['Email'] -join ""
           $lstComma = $tmvr.ToString().Substring($tmvr.ToString().Length - 1,1)      
           $custApproveremail = @{$true = $tmvr.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries); $false =  $Specific['SubjAltNames']['Email'].Split(",",[System.StringSplitOptions]::RemoveEmptyEntries) }[($lstComma -eq ',')]           
    }
    
    #throw ($custApproveremail -join "|")  + " " +  $custApproveremail.Count 

    $dmApproverEmaillst = @()
    $dmApproverEmaillst += $General['CustomFields']['Approver Email'].ToString()
    if($custApproveremail.Length -gt 0)
    {
        $dmApproverEmaillst += $custApproveremail
    }

    #throw $dmApproverEmaillst.Count

    $tmpActualApproverEml = @()
    $ApproverResult = GetApproverList  $username $userpass $global:tss_ProductCode $dmList $dmApproverEmaillst ([REF]$tmpActualApproverEml)
    #throw "verasdf " +  $tmpActualApproverEml + " ---- " +$ApproverResult
    $ActualApproverEml = ($tmpActualApproverEml) -join ","
    #throw $ActualApproverEml
    
     if ($ApproverResult -eq $global:ResultSuccess) {
        
        #TSS Order Params
        $orderparam = Get-OrderParams
        $orderparam.AuthRequest.PartnerCode = $username
        $orderparam.AuthRequest.AuthToken = $userpass
        $orderparam.AuthRequest.ReplayToken = [System.Guid]::NewGuid().ToString()
        $orderparam.AuthRequest.UserAgent = $global:tss_UserAgent
        $orderparam.CustomOrderID = [System.Guid]::NewGuid().ToString()
        $orderparam.ProductCode = $global:tss_ProductCode
        $orderparam.OrganizationInfo.OrganizationName = $Specific['SubjectDN']['O']
        $orderparam.OrganizationInfo.DUNS = '' ##NEED TO GET INFO
        $orderparam.OrganizationInfo.Division =  @{$true = $Specific['SubjectDN']['OU'][0]; $false = ''}[$Specific['SubjectDN']['OU'].Length -gt 0]
        $orderparam.OrganizationInfo.IncorporatingAgency = '' ##NEED TO GET INFO
        $orderparam.OrganizationInfo.RegistrationNumber = '' ##NEED TO GET INFO
        $orderparam.OrganizationInfo.JurisdictionCity = $Specific['SubjectDN']['L']
        $orderparam.OrganizationInfo.JurisdictionRegion = $Specific['SubjectDN']['ST']
        $orderparam.OrganizationInfo.JurisdictionCountry = $Specific['SubjectDN']['C']
        $orderparam.OrganizationInfo.OrganizationAddress.AddressLine1 = $Specific['SubjectDN']['L']
        $orderparam.OrganizationInfo.OrganizationAddress.AddressLine2 = '' ##NEED TO GET INFO
        $orderparam.OrganizationInfo.OrganizationAddress.AddressLine3 = '' ##NEED TO GET INFO
        $orderparam.OrganizationInfo.OrganizationAddress.City = $Specific['SubjectDN']['L'] ##NEED TO GET INFO
        $orderparam.OrganizationInfo.OrganizationAddress.Region = $Specific['SubjectDN']['ST'] ##NEED TO GET INFO
      $orderparam.OrganizationInfo.OrganizationAddress.Country = $Specific['SubjectDN']['C']
        $orderparam.OrganizationInfo.OrganizationAddress.Phone = @{$true = $General['CustomFields']['Phone']; $false = $global:AdminPhone}[$General['CustomFields']['Phone'].Length -gt 0]        
        $orderparam.OrganizationInfo.OrganizationAddress.Fax = ''
        $orderparam.OrganizationInfo.OrganizationAddress.LocalityName = $Specific['SubjectDN']['L']
        $orderparam.ValidityPeriod = $General['CustomFields']['Validity Period'] 
        $orderparam.ServerCount = 1
	
        $CSR = $Specific['Pkcs10']
        $CSR = $CSR.replace("`n", "").replace("`r", "")	
        $orderparam.CSR = $CSR 
	
        $orderparam.DomainName = $Specific['SubjectDN']['CN']
        $orderparam.WebServerType = 'OTHER'
        if($dmList.Length -gt 0)
        {
            $orderparam.DNSNames = $dmList
        }
        $orderparam.ApproverEmail = $ActualApproverEml 
            
        
        $orderparam.isCUOrder = $false
        $orderparam.isRenewalOrder = $IsRenew

        $fullname = $General['CustomFields']['Full Name'].ToString()
        $f = ($fullname -split " ",2)       

        $orderparam.AdminContact.Title = "Mr"
        $orderparam.AdminContact.FirstName = $f[0]
        $orderparam.AdminContact.LastName = $f[1]
        $orderparam.AdminContact.Email = $global:AdminEmail
        $orderparam.AdminContact.Phone = $global:AdminPhone 
        $orderparam.AdminContact.Fax = '' ##NEED TO GET INFO	      

        $orderparam.AdminContact.OrganizationName = $Specific['SubjectDN']['O']
        $orderparam.AdminContact.AddressLine1 = $Specific['SubjectDN']['L']
        $orderparam.AdminContact.AddressLine2 = '' ##NEED TO GET INFO
        $orderparam.AdminContact.City = $Specific['SubjectDN']['L']
        $orderparam.AdminContact.Region = $Specific['SubjectDN']['ST']
        $orderparam.AdminContact.PostalCode =  $General['CustomFields']['Postal Code'].ToString() 
        $orderparam.AdminContact.Country = $Specific['SubjectDN']['C']
	
        $orderparam.TechnicalContact.Title = $orderparam.AdminContact.Title
        $orderparam.TechnicalContact.FirstName = $orderparam.AdminContact.FirstName
        $orderparam.TechnicalContact.LastName = $orderparam.AdminContact.LastName
        $orderparam.TechnicalContact.Email = $orderparam.AdminContact.Email
        $orderparam.TechnicalContact.Phone = $orderparam.AdminContact.Phone
        $orderparam.TechnicalContact.Fax = '' ##NEED TO GET INFO
	
        $orderparam.TechnicalContact.OrganizationName = '' ##NEED TO GET INFO
        $orderparam.TechnicalContact.AddressLine1 = '' ##NEED TO GET INFO
        $orderparam.TechnicalContact.AddressLine2 = '' ##NEED TO GET INFO
        $orderparam.TechnicalContact.City = '' ##NEED TO GET INFO
        $orderparam.TechnicalContact.Region = '' ##NEED TO GET INFO
        $orderparam.TechnicalContact.PostalCode = '' ##NEED TO GET INFO
        $orderparam.TechnicalContact.Country = '' ##NEED TO GET INFO
            
        $orderparam.ReserveSANCount = 0 ## NEED TO GET INFO
        $orderparam.AddInstallationSupport = $false
        $orderparam.EmailLanguageCode = 'en'
        $orderparam.FileAuthDVIndicator = $false ##NEED TO GET INFO
        $orderparam.CNAMEAuthDVIndicator = $false ##NEED TO GET INFO
        $orderparam.HTTPSFileAuthDVIndicator = $false ##NEED TO GET INFO
        $orderparam.SignatureHashAlgorithm = '' # API will decide automatically best mode
        $orderparam.CertTransparencyIndicator = $true
        $orderparam.RenewalDays = 30

        $body = (ConvertTo-Json $orderparam) 	
    
        # TSS Ordering
        $uri = BaseURL 
        $uri += '/order/neworder'
       

        try {
            $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType 'application/json; charset=utf-8' 
        } 
        catch {
            Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        }

        if ($response -eq $null) {
            $state = 'Not Valid HTTP'
			throw $state
        }
        else {
            if ($response.AuthResponse.isError -eq $true) {
                $stat= $response.AuthResponse.Message
                #$body | Out-File ($MyInvocation.MyCommand.Path +  "log.txt")
                throw $stat                
            }
            else {
                $stat = $global:ResultSuccess
                $transID = $response.TheSSLStoreOrderID
            }
        }
        return @{ Result = $stat; TransId = $transID}
    }
    else {
        throw $ApproverResult
        
        return @{ Result = $ApproverResult; TransId = $transID}                  
    }
}

function Submit-CsrAsNew
{
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )   
    return TSS-PlaceOrder  $General $Specific $false
}



function Submit-CsrAsRenewal
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )   
    return TSS-PlaceOrder  $General $Specific $true
}



function Submit-CsrAsReplacement {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
  
    $username = $General['UserName']
    $userpass = $General['UserPass']   
   
    
    $response = Get-OrderDetail $username $userpass $Specific['CertId'].ToString()
    if ($response.OrderStatus.MajorStatus.ToString().ToUpper() -contains $global:MajorStatusArr) {

        $custdomain 
        if ($Specific['SubjAltNames']['DNS'].Length -gt 0) {
            $tmvr1 = $Specific['SubjAltNames']['DNS'] -join ""           
            $lstComma1 = $tmvr1.ToString().Substring($tmvr1.ToString().Length - 1, 1)           
            #$custdomain = @{$true = $tmvr1.ToString().Substring(0,$tmvr1.ToString().Length - 1) -split ","; $false =  $Specific['SubjAltNames']['DNS'] -split "," }[($lstComma1 -eq ',')]          
            $custdomain = @{$true = $tmvr1.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries); $false = $Specific['SubjAltNames']['DNS'].Split(",", [System.StringSplitOptions]::RemoveEmptyEntries) }[($lstComma1 -eq ',')]
        }
               
        $dmList = @()
        $dmList += $Specific['SubjectDN']['CN'].ToString()
        if ($custdomain.Length -gt 0) {
            $dmList += $custdomain
        }
        $delSan = @()
        $addsan = @()
        $temadd = @()
        $temDel = @()
        #if ($response.DNSNames.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries).Length -gt 0) {
            $temadd = ($custdomain | where {$response.DNSNames.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries) -notcontains $_})
            $temDel = ($response.DNSNames.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries) | where {$custdomain -notcontains $_})        

            if ($temDel.Count -gt 0) {
                for ($i = 0; $i -lt $temDel.Count; $i++) {

                    $tmphs = @{}
                    $tmphs.Add("OldValue","$((@{$true = $temDel[$i]; $false = $temDel}[$temDel.Count -gt 1]))")
                    $tmphs.Add("NewValue","")
                    $delSan += $tmphs                   
                }
            }
            
            if ($temadd.Count -gt 0) {
                for ($i = 0; $i -lt $temadd.Count; $i++) {                                        
                    $tmphs = @{}
                    $tmphs.Add("OldValue","")
                    $tmphs.Add("NewValue","$((@{$true = $temadd[$i]; $false = $temadd}[$temadd.Count -gt 1]))")
                    $addsan += $tmphs                   
                } 
            }
        #}
    
       
        #throw  $dmList + " " + $dmList.Count

        $custApproveremail         
        if ($Specific['SubjAltNames']['Email'].Length -gt 0) {
            $tmvr = $Specific['SubjAltNames']['Email'] -join ""
            $lstComma = $tmvr.ToString().Substring($tmvr.ToString().Length - 1, 1)      
            $custApproveremail = @{$true = $tmvr.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries); $false = $Specific['SubjAltNames']['Email'].Split(",", [System.StringSplitOptions]::RemoveEmptyEntries) }[($lstComma -eq ',')]           
        }
    
        #throw ($custApproveremail -join "|")  + " " +  $custApproveremail.Count 

        $dmApproverEmaillst = @()
        $dmApproverEmaillst += $General['CustomFields']['Approver Email'].ToString()
        if ($custApproveremail.Length -gt 0) {
            $dmApproverEmaillst += $custApproveremail
        }
    
        $tmpActualApproverEml = @()

        if($custdomain.Count -ne $custApproveremail.Count)
        {
            throw "Error: OPPS! Number of approver email(s) should be same as additional SAN."
            break
        }
        #throw $custdomain +" -- " + ($custdomain.Count).ToString() + " == " + $custApproveremail+" -- " + ($custApproveremail.Count).ToString()

        $ApproverResult = GetApproverList  $username $userpass $global:tss_ProductCode $dmList $dmApproverEmaillst ([REF]$tmpActualApproverEml)
        
        $ActualApproverEml = $tmpActualApproverEml -join "," #($tmpActualApproverEml |  ? { $_ } | sort -Unique) -join ","
        #THROW $ApproverResult
        $transID = "Not Set"
        if ($ApproverResult -eq $global:ResultSuccess) {
    
            $reissueParam = Get-ReissueParam
        
            $reissueParam.AuthRequest.PartnerCode = $username
            $reissueParam.AuthRequest.AuthToken = $userpass
            $reissueParam.AuthRequest.ReplayToken = [System.Guid]::NewGuid().ToString()
            $reissueParam.AuthRequest.UserAgent = $global:tss_UserAgent	    
     
            $reissueParam.TheSSLStoreOrderID = $Specific['CertId'].ToString()
            $CSR = $Specific['Pkcs10']
            $CSR = $CSR.replace("`n", "").replace("`r", "")	
            $reissueParam.CSR = $CSR 
        
            $reissueParam.WebServerType = 'OTHER'
            #$reissueParam.DNSNames =$Specific['SubjectDN']['CN'].ToString()
            $reissueParam.isRenewalOrder = $false
            $reissueParam.SpecialInstructions = ""
            $reissueParam.isWildCard = $false
            $reissueParam.ReissueEmail = $General['CustomFields']['Approver Email'].ToString()
            $reissueParam.PreferEnrollmentLink = $false
            $reissueParam.SignatureHashAlgorithm = ""
            $reissueParam.FileAuthDVIndicator = $false
            $reissueParam.HTTPSFileAuthDVIndicator = $false
            $reissueParam.CNAMEAuthDVIndicator = $false
            $reissueParam.ApproverEmails = $ActualApproverEml
            $reissueParam.DateTimeCulture = "en-US"
        
            <# For multidomain $reissueParam.EditSAN = @()#>

            if($delSan.Length -gt 0){
            $reissueParam.DeleteSAN = $delSan
            }
            if($addsan.Length -gt 0){
            $reissueParam.AddSAN = $addsan
            }
                
            $body = (ConvertTo-Json $reissueParam) 	            
            
           # throw $body
            
            # TSS Reissue
            $uri = BaseURL 
            $uri += '/order/reissue'
       

            try {
                $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType 'application/json; charset=utf-8' 
            } 
            catch {
                Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
                Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
            }
            
            if ($response -eq $null) {
                $state = 'Not Valid HTTP' 
            }
            else {
                if ( $response.AuthResponse.isError -eq $true) {
                    $body | Out-File ($MyInvocation.MyCommand.Path +  "log.txt")
                    $state = $response.AuthResponse.Message
					throw $state                    
                }                
                else {
                    $state = $global:ResultSuccess
                    $transID = $response.TheSSLStoreOrderID
                }
            }
            return @{ Result = $state; TransId = $transID}
        }
        else {
            return @{ Result = $ApproverResult; TransId = $transID}
        }
    
    }else
    {
        throw "Error: OPPS! Certificate status is not active."
        return @{ Result = "NotSuccess"; TransId = "" }
    }        
    return @{ Result = "NotSuccess"; TransId = "" }
}



function Approve-Request
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )    
    return @{ Result="Success" }
}

function Retrieve-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    $username = $General['UserName']
    $userpass = $General['UserPass']  
   
    $stat = $global:PendingState
    if ( $Specific.CertId -gt 0) {

        $stat = Get-OrderStatus $username $userpass $Specific.CertId
        if ($stat -eq $global:IssuedState) {
            return $(GetCertificate $username $userpass $Specific.CertId)
        }
        else {           
        $enc = [system.Text.Encoding]::UTF8        
        $bytes = $enc.GetBytes("Opps! Certiticate status is pending...")
		Return @{ Result="NotSuccess";Status=$global:PendingState;Pkcs7=$bytes; }		   
        }      
    }
    else {
        throw "NotSuccess: Opps! the required CertId was not provided."
        #return @{ Result = "NorSuccess: Opps! the required CertId was not provided"; Status = $global:PendingState; }        
        break
    }
    if ($stat -ne $global:IssuedState) {
        return @{ Result = "NotSuccess"; Status = $global:PendingState; }
    }   
   
}

function Revoke-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $username = $General['UserName']
    $userpass = $General['UserPass']  
    
    if ($Specific.CertId -gt 0)
    {
          $stat =  Get-RevokeCertificate $username $userpass $Specific.CertId
          if($stat -eq $global:ResultSuccess)
          {
              return @{ Result=$global:ResultSuccess }
          }
          else {              
              return @{ Result=$stat }
          }
    }    
    return @{ Result="Success" }
}


function BaseURL()
{
	if($global:tss_mode -eq "TEST")
	{return $global:tss_base_sandbox_url}
	else {return $global:tss_base_live_url}
}


function Get-TSSStatus()
{
	$uri = BaseURL 
    $uri += "/health/status"    
    
	$response = Invoke-RestMethod -Uri $uri -Method Get  -ContentType 'application/json; charset=utf-8' 
	$state = ""
	if($response.isError -eq $true)
	{
		$state = "NotUsed"
	}
	else
	{
		$state = "Success"
	}
	return $state
}



function Get-OrderParams()
{

$orderinput = @"
{
	"AuthRequest":{
		"PartnerCode":"",
		"AuthToken":"",
		"ReplayToken":"",
		"UserAgent":"",
                "IPAddress":"",
		"IsUsedForTokenSystem":false,
                "Token":""
	},
	"CustomOrderID":"",
	"ProductCode":"",
	"ExtraProductCodes":"",
	"OrganizationInfo":{
		"OrganizationName":"",
		"DUNS":"",
		"Division":"",
		"IncorporatingAgency":"",
		"RegistrationNumber":"",
		"JurisdictionCity":"",
		"JurisdictionRegion":"",
		"JurisdictionCountry":"",
		"OrganizationAddress":{
			"AddressLine1":"",
			"AddressLine2":"",
			"AddressLine3":"",
			"City":"",
			"Region":"",
			"PostalCode":"",
			"Country":"",
			"Phone":"",
			"Fax":"",
			"LocalityName":""
		}
	},
	"ValidityPeriod":0,
	"ServerCount":0,
	"CSR":"",
	"DomainName":"",
	"WebServerType":"",
	"DNSNames":[""],
	"isCUOrder":false,
	"isRenewalOrder":false,
	"SpecialInstructions":"",
	"RelatedTheSSLStoreOrderID":"",
	"isTrialOrder":false,
	"AdminContact":{
		"FirstName":"",
		"LastName":"",
		"Phone":"",
		"Fax":"",
		"Email":"",
		"Title":"",
		"OrganizationName":"",
		"AddressLine1":"",
		"AddressLine2":"",
		"City":"",
		"Region":"",
		"PostalCode":"",
		"Country":""
	},
	"TechnicalContact":{
		"FirstName":"",
		"LastName":"",
		"Phone":"",
		"Fax":"",
		"Email":"",
		"Title":"",
		"OrganizationName":"",
		"AddressLine1":"",
		"AddressLine2":"",
		"City":"",
		"Region":"",
		"PostalCode":"",
		"Country":""
	},
	"ApproverEmail":"",
	"ReserveSANCount":0,
	"AddInstallationSupport":false,
	"EmailLanguageCode":"",
	"FileAuthDVIndicator":false,
	"CNAMEAuthDVIndicator":false,
    "HTTPSFileAuthDVIndicator":false,	
	"SignatureHashAlgorithm":"",
    "CertTransparencyIndicator":true,
	"RenewalDays":0,
	"DateTimeCulture":""
}


"@ |  ConvertFrom-Json 


 return $orderinput

}

function GetApproverListAllDomain ($username1,$userpass1,$productcode1,$domain1) {

  $orderparam1 = Get-ApprovarParams    
	$orderparam1.AuthRequest.PartnerCode  = $username1
	$orderparam1.AuthRequest.AuthToken = $userpass1
	$orderparam1.AuthRequest.ReplayToken = [System.Guid]::NewGuid().ToString()
	$orderparam1.AuthRequest.UserAgent = $global:tss_UserAgent
	$orderparam1.ProductCode = $productcode1
	$orderparam1.DomainName = $domain1

	$apbody = (ConvertTo-Json $orderparam1) 	
    
    $uri = BaseURL 
    $uri += '/order/approverlist'
	$state = 'NotUsed'
	
 
	try 
	{
		$response = Invoke-RestMethod -Uri $uri -Method Post -Body $apbody -ContentType 'application/json; charset=utf-8' 
	} 
	catch 
	{
		Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
		Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
	}

	if($response -eq $null)
	{
		$ApprovarList = 'Not Valid HTTP'       
	}
	else
	{
		if($response.AuthResponse.isError -eq $true)
		{
            #$apbody | Out-File ($MyInvocation.MyCommand.Path +  "log_2.txt")
			throw $ApprovarList = $response.AuthResponse.Message            
            break
		}
		else
		{
			
            if($response.ApproverEmailList.Length -gt 0)
            {

                return $response.ApproverEmailList
            <#

                for ($i = 0; $i -lt $response.ApproverEmailList.Length - 1; $i++) {
                      $ApprovarList += " `n => "+ $response.ApproverEmailList[$i]
                }

              if($response.ApproverEmailList -contains  $userApproverEmail)
              {
                    return  $global:ResultSuccess
              }
              else {            
                    return "OPPS! Approver email does not match. Please insert one of the below `n" + $ApprovarList
                    #break
              }
              #>                           
            }			            
		}
	}
    
    return $ApprovarList 

}


function GetApproverList ($username1,$userpass1,$productcode1,$domainlst,$userApproverEmaillst,[REF]$ActualApproverEml) {
    
    $msg = ""
    $tmpApprovarList = ""
    $tmpmsg = ""
     
    foreach($domain in $domainlst)
    {
         $lstArroverEmail =  GetApproverListAllDomain $username1 $userpass1 $productcode1 $domain

         if($lstArroverEmail -contains "Not Valid HTTP")
         {
                throw $lstArroverEmail
         }
         
        if(($lstArroverEmail | where {$userApproverEmaillst -contains $_}).Count -lt 1)
        {
			$tmpmsg = " `n  `n Approver email does not match of `n " + $domain
            $tmpApprovarList = ""            
                for ($i = 0; $i -lt $lstArroverEmail.Length ; $i++) {
                      $tmpApprovarList += " `n => "+ $lstArroverEmail[$i]
                }                            
           $tm = $tmpmsg +=  $tmpApprovarList                     
           $msg += $tm
        }
        else
        {
            $tmpvar = ($lstArroverEmail | where {$userApproverEmaillst -contains $_})            
            if($tmpvar -ne ''){
            $ActualApproverEml.Value += $tmpvar
            }
        }
    }    
    if($msg -ne "")
    {
        throw $msg 
    }
    else {
    return $global:ResultSuccess
    }            
}

function Get-ApprovarParams()
{

$Approvarinput = @"
{ 
	 "AuthRequest":{
        "PartnerCode":"",
        "AuthToken":"",
        "ReplayToken":"",
        "UserAgent":""
    },
    "DomainName":"",
    "ProductCode":""
}


"@ |  ConvertFrom-Json 
 return $Approvarinput

}


function Get-ReissueParam () {

$reissueInputs = @"
{

    "AuthRequest":
	{
	    "PartnerCode":"",
	    "AuthToken":"",
	    "ReplayToken":"",
	    "UserAgent":""	  
	},
	"TheSSLStoreOrderID":"",
	"CSR":"",
	"WebServerType":"",
	"DNSNames":[""],
	"isRenewalOrder":true,
	"SpecialInstructions":"",
	"EditSAN":[{
		"OldValue":"",
		"NewValue":""
	}],
	"DeleteSAN":[{
		"OldValue":"",
		"NewValue":""
	}],
	"AddSAN":[{
		"OldValue":"",
		"NewValue":""
	}],
	"isWildCard":false,
	"ReissueEmail":"",
	"PreferEnrollmentLink":false,
	"SignatureHashAlgorithm":"",
	"FileAuthDVIndicator":false,
	"HTTPSFileAuthDVIndicator":false,
	"CNAMEAuthDVIndicator":false,
	"ApproverEmails":"",
	"DateTimeCulture":""

}

"@ | ConvertFrom-Json

return $reissueInputs

}


function  Get-DownloadCertParam () {
    

$Approvarinput = @"
{ 
	 "AuthRequest":{
        "PartnerCode":"",
        "AuthToken":"",
        "ReplayToken":"",
        "UserAgent":""
    },
    "TheSSLStoreOrderID":"",
    "ReturnPKCS7Cert":""
}


"@ |  ConvertFrom-Json 
 return $Approvarinput

}

function  GetCertificate ($username1,$userpass1,$TheSSLStoreID) {
    
    $DownloadPara = Get-DownloadCertParam    
	$DownloadPara.AuthRequest.PartnerCode  = $username1
	$DownloadPara.AuthRequest.AuthToken = $userpass1
	$DownloadPara.AuthRequest.ReplayToken = [System.Guid]::NewGuid().ToString()
	$DownloadPara.AuthRequest.UserAgent = $global:tss_UserAgent
	$DownloadPara.TheSSLStoreOrderID = $TheSSLStoreID
	$DownloadPara.ReturnPKCS7Cert = $true

    $apbody = (ConvertTo-Json $DownloadPara) 	
    
    $uri = BaseURL 
    $uri += '/order/download'
	
       
    try 
	{
		$response = Invoke-RestMethod -Uri $uri -Method Post -Body $apbody -ContentType 'application/json; charset=utf-8' 
	} 
	catch 
	{
		Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
		Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
	}
    $stat = ""
    
	if($response -eq $null)
	{
		$stat = 'Not Valid HTTP'
	}
	else
	{
		if($response.AuthResponse.isError -eq $true)
		{
			$stat = $response.AuthResponse.Message    
            Return @{ Result="NotSuccess" + $stat;Status="Pending" }
            break
		}
		else
		{

             foreach($k in $response.Certificates)
                {
                    if($k.FileName -eq "PKCS7Certificate.p7b")
                    {
                        $cdata = $k.FileContent
                        break
                    }
                }
        <#throw $bytes
        $vrld =  [System.Text.Encoding]::UTF8.GetString($bytes)        
        $vrld | Out-File ($MyInvocation.MyCommand.Path +  "PKCS7Certificate_v.p7b")
        $cdata | Out-File ($MyInvocation.MyCommand.Path +  "PKCS7Certificate.p7b") #>
        $enc = [system.Text.Encoding]::UTF8        
        $bytes = $enc.GetBytes($cdata)             
        #Return @{ Result="Success";Status="Issued";Pkcs7=$bytes;DiscardPrivateKeyAndCsr=$true }
		Return @{ Result="Success";Status="Issued";Pkcs7=$bytes; }
        
		}
	}

}


function  Get-OrderStatusParam () {
    

$OrderStatusinput = @"
{ 
	 "AuthRequest":{
        "PartnerCode":"",
        "AuthToken":"",
        "ReplayToken":"",
        "UserAgent":""
    },
    "TheSSLStoreOrderID":""    
}


"@ |  ConvertFrom-Json 
 return $OrderStatusinput

}



function Get-OrderStatus($username1,$userpass1,$TheSSLStoreOrderID) {
    
    $OrderStatusinput = Get-OrderStatusParam    
	$OrderStatusinput.AuthRequest.PartnerCode  = $username1
	$OrderStatusinput.AuthRequest.AuthToken = $userpass1
	$OrderStatusinput.AuthRequest.ReplayToken = [System.Guid]::NewGuid().ToString()
	$OrderStatusinput.AuthRequest.UserAgent = $global:tss_UserAgent
	$OrderStatusinput.TheSSLStoreOrderID = $TheSSLStoreOrderID
	

    $apbody = (ConvertTo-Json $OrderStatusinput) 	
    
    $uri = BaseURL 
    $uri += '/order/status'	
       
    try 
	{
		$response = Invoke-RestMethod -Uri $uri -Method Post -Body $apbody -ContentType 'application/json; charset=utf-8' 
	} 
	catch 
	{
		Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
		Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
	}
    $stat = ""
    
	if($response -eq $null)
	{
		$stat = 'Not Valid HTTP'
	}
	else
	{
		if($response.AuthResponse.isError -eq $true)
		{
			$stat = $response.AuthResponse.Message            
			throw $stat            
		}
		else
		{
    
        if($global:MinorStatusArr -contains ($response.OrderStatus.MinorStatus.ToString().ToUpper()) -and $global:MajorStatusArr -contains $response.OrderStatus.MajorStatus.ToString().ToUpper())
        {
            return $global:IssuedState
        }
        else        
        {
            return $response.OrderStatus.MinorStatus.ToString()
        }
		}
	}
}


function  Get-RevokeOrderParam () {
    

$OrderStatusinput = @"
{ 
	 "AuthRequest":{
        "PartnerCode":"",
        "AuthToken":"",
        "ReplayToken":"",
        "UserAgent":""
    },
    "TheSSLStoreOrderID":"",
    "RefundReason":""
}


"@ |  ConvertFrom-Json 
 return $OrderStatusinput

}

function Get-RevokeCertificate ($username1,$userpass1,$TheSSLStoreOrderID) {
     $OrderRevokeinput = Get-RevokeOrderParam    
	$OrderRevokeinput.AuthRequest.PartnerCode  = $username1
	$OrderRevokeinput.AuthRequest.AuthToken = $userpass1
	$OrderRevokeinput.AuthRequest.ReplayToken = [System.Guid]::NewGuid().ToString()
	$OrderRevokeinput.AuthRequest.UserAgent = $global:tss_UserAgent
	$OrderRevokeinput.TheSSLStoreOrderID = $TheSSLStoreOrderID
	$OrderRevokeinput.RefundReason = ""

    $apbody = (ConvertTo-Json $OrderRevokeinput) 	
    
    $uri = BaseURL 
    $uri += '/order/refundrequest'
	$state = 'NotUsed'
       
    try 
	{
		$response = Invoke-RestMethod -Uri $uri -Method Post -Body $apbody -ContentType 'application/json; charset=utf-8' 
	} 
	catch 
	{
		Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
		Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
	}
    $stat = ""
    
	if($response -eq $null)
	{
		$stat = 'Not Valid HTTP'
		return $stat
	}
	else
	{
		if($response.AuthResponse.isError -eq $true)
		{
			return $response.AuthResponse.Message
		}
		else
		{    
            return $global:ResultSuccess
		}
	}
}