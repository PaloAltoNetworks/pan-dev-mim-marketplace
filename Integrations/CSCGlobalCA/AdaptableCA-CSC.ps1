<#
//----------------------------------------------------------------------- 
// <COMPANY>.ps1
//
// Copyright (c) 2018 Venafi, Inc.  All rights reserved.
//
// This script and its contents are provided by Venafi to customers
// for purposes of integrating with services and platforms. Any sharing
// of this script or its contents without consent from Venafi is
// prohibited. Modifications are allowed for purposes of configuration 
// and customization only.
//----------------------------------------------------------------------- 
// Custom Fields
// '<COMPANY>: Product Name' : Name of the product for the order
// '<COMPANY>: Contract Name' : Contract Name with <COMPANY>
// '<COMPANY>: Validity In Years' : Number for which the Certificate required in years
// '<COMPANY>: Domain Approver Email' : Email of the person who wil approve the order
#>

$script_dir = (Get-ItemProperty "HKLM:\SOFTWARE\Venafi\Platform")."Base Path" + "Scripts\AdaptableCA\"
$config = Read-JsonConfigFile -FileName "AdaptableCA-CSC.json"
$prop_cfg = Read-PropertiesJsonFile -FileName "properties.json"



function Test-Settings {

@{ Result = "Success" }
}

function Get-ChainCertificates {
    return @{ Result = "NotUsed" }
}

function Prepare-ForRequest {
    return @{ Result = "NotUsed" }
}

function Submit-CsrAsNew {

Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
	Clear-Variable -name venafiToken

$cscToken = $General.UserPass;
$csctokenArray = $cscToken.Split("|")
$csr = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Specific.Pkcs10));
$certificateType=(@() + $($General.CustomFields["Certificate Type"] | ? {$_}))[0];
$methodType = (@() + $($General.CustomFields["Domain Control Validation"] | ? {$_}))[0];
$emailAddress = (@() + $($General.CustomFields["Email"] | ? {$_}))[0];
$sans_dns = @() + $($Specific.SubjAltNames.DNS | ? {$_});
$sans_emails =  (@() + $($General.CustomFields["SAN Validation Email List"] | ? {$_}))[0];
$sansEmailArray = $sans_emails.Split(",");

## customFields supported by TPP & config

$evCertificateDetails= @{
country=getCustomFieldValue 'country';
city=getCustomFieldValue 'city';
state=getCustomFieldValue 'state'; 
dateOfIncorporation=getCustomFieldValue 'dateOfIncorporation'; 
doingBusinessAs=  getCustomFieldValue 'doingBusinessAs';
businessCategory = getCustomFieldValue 'businessCategory';

};

 $additionalNotificationEmails = getCustomFieldValue 'additionalNotificationEmails'; 
$notificationEmails = @();
if($additionalNotificationEmails){
	 $notificationEmails +=$additionalNotificationEmails;
}
$notifications=@{
enabled=getCustomFieldValue 'notificationEnabled';
additionalNotificationEmails=@($notificationEmails);

};



$sans = @();
foreach($dnsSan in $sans_dns){
	$cf=@{
		domainName=$dnsSan;
			domainControlValidation =@{
				methodType="CNAME";
				emailAddress ="";
			} 
		}
	$sans +=$cf;
}

foreach($emailSan in $sansEmailArray){
	$cf=@{
		domainName=$emailSan.Split("|")[0];
			domainControlValidation =@{
				methodType="EMAIL";
				emailAddress =$emailSan.Split("|")[1];
			} 
		}
	$sans +=$cf;
}

$domainControlValidation= @{
	methodType=$methodType;
	emailAddress=$emailAddress;
};
     
    $url = $config.base_url + "registration";

    $body = @{
		 csr              =  $csr;
		 certificateType  = (@() + $($General.CustomFields["Certificate Type"] | ? {$_}))[0];
		 businessUnit  	= getCustomFieldValue 'businessUnit';
		 term = getCustomFieldValue 'term';
		 serverSoftware = getCustomFieldValue 'serverSoftware';
		 domainControlValidation = $domainControlValidation;
         organizationContact=getCustomFieldValue 'organizationContact';
		 customFields = @(loadUDFs);
		 notifications = $notifications;
		 evCertificateDetails = $evCertificateDetails;
		 showPrice=getCustomFieldValue 'showPrice';
		 subjectAlternativeNames = $sans;
		 applicantFirstName=getCustomFieldValue 'applicantFirstName';
		 applicantLastName=getCustomFieldValue 'applicantLastName';
		 applicantEmailAddress=getCustomFieldValue 'applicantEmailAddress';
		 applicantPhoneNumber =getCustomFieldValue 'applicantPhoneNumber';
		 
		
    } | ConvertTo-Json -Depth 3 -Compress
	
	$venafiToken = $General.AuxPass;
	
	try{

    $response = Invoke-RestMethod -Uri $url -Method Post -Headers @{ 'Authorization' = "Bearer "+$csctokenArray[0];'apikey' = $csctokenArray[1]} -Body $body -ContentType "application/json"
	
	 if ($response.OrderResponseHeader.SuccessCode -gt -1) {
        $transaction_id = $response.result.status.uuid;
		$result = "Success";
		
		update-cnamedetails $response $venafiToken
    }
    else {
            
        if ($response.OrderResponseHeader.Errors -ne $null) {
            throw $response.OrderResponseHeader.Errors[0].ErrorMessage;
        }
        throw "Error processing the order request";
    }
	
	}
	catch{
$_.Exception.code
 
        throw $_.ErrorDetails.Message;
}

    return @{ Result = $result; TransId = $transaction_id}
}

function Import-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
	
	$cscToken = $General.UserPass;
	$csctokenArray = $cscToken.Split("|")
    $url = $config.base_url+"certificate";
    
	if($Specific.IncludeExpired -or $Specific.IncludeRevoked){
       # $url = $config.base_url+"certificate?filter=status=in=(PENDING,ACTIVE,IMPORTED" + $(if ($Specific.IncludeExpired) {',EXPIRED' }) +  $(if ($Specific.IncludeRevoked) { ",REVOKED" }) +")";
      # $url = $config.base_url+"certificate?filter=uuid==a02120d6-597f-4c3d-8535-c178e74e7fb2";
	}
    
	$url = $config.base_url+"certificate?filter=name==cscdbs-test-domain-26032023-1.com;status=in=(ACTIVE,EXPIRED)"; 
	$header = @{ 'Authorization' = "Bearer $token"}
	$last_processed_id = 0;
	 $certificates = @()
	
	if ($DEBUG_FILE) {
        "$(Get-Date) - Import certificate job started" | Out-File $DEBUG_FILE
        
    }


try{

 $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ 'Authorization' = "Bearer "+$csctokenArray[0];'apikey' = $csctokenArray[1]} -Body $body -ContentType "application/json"

	 if ($response.QueryResponseHeader.SuccessCode -gt -1) {
	           
	    foreach ( $order in $response.results) {	
			
			if ($DEBUG_FILE) {
				"Order Id -" + $order.uuid | Out-File $DEBUG_FILE -Append
			}
			
			if (![string]::IsNullOrEmpty($order.certificate)){
				 $bytes1 = [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String($order.certificate)|?{$_}));
				 $begin = "-----BEGIN CERTIFICATE-----";
				 $end = "-----END CERTIFICATE-----";
	
					if( -Not ($bytes1.Contains($begin))){
						$bytes1 = [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String($bytes1)|?{$_}));
					}
	
				$certificates += @{
                            PEM=$bytes1;
                            TransactionId=$order.uuid;
                            Name=$order.commonName;
                            RevocationDate=$null;
                         }
						
				$last_processed_id = $order.uuid
				if ($DEBUG_FILE) {
				"Certificate imported -" +  $order.commonName | Out-File $DEBUG_FILE -Append
			}
		
			}
	    }
         	if ($DEBUG_FILE) {
				foreach ($certificate in $certificates) {
   							 "Certificates -" | Out-File $DEBUG_FILE -Append
    						$certificate | Format-List | Out-File $DEBUG_FILE -Append
				}
			}        
    }
    else {
        if ($response.QueryResponseHeader.Errors -ne $null) {
         if ($DEBUG_FILE) {
            $response.QueryResponseHeader.Errors[0].ErrorMessage | Out-File $DEBUG_FILE -Append
          }
		}
        
    }
	
}

catch{

$_.Exception.code
 $respStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($respStream)
        $respBody = $reader.ReadToEnd() | ConvertFrom-Json
        $errorCode = $respBody.code
        $errorMessage = $respBody.description
        $causeDetails = $respBody.value
        
		$errorCode
		$errorMessage
		$causeDetails
		if ($DEBUG_FILE) {
        
         "$(Get-Date) - Error processing the order request $errorMessage" | Out-File $DEBUG_FILE -Append
        }
    }
	
	 if ($DEBUG_FILE)
    {
        $global:LOG_FILE = $DEBUG_FILE
    }
	 if ($DEBUG_FILE) {
        "$(Get-Date) - Job Completed" | Out-File $DEBUG_FILE -Append
         
        }
return @{ Result="Success"; Certificates=$certificates; LastProcessedId=$last_processed_id }

}

function update-cnamedetails($response,$venafiToken) {
Clear-Variable -name newToken
Clear-Variable -name statusCode
 $statusCode = set-customField $response $venafiToken
	if ($statusCode -eq 401) {
		$newToken = Refresh-auth-token $venafiToken
		set-customField $response $newToken
		
	}
}

function Refresh-auth-token($venafiToken) {

$venafiTokenArra = $venafiToken.Split("|");
 $refreshurl = $config:venafi_auth_url;
 $body=@{
    client_id=$config.client_id
    refresh_token = $venafiTokenArra[1]
  } | ConvertTo-Json 
  
 try{
	$authresponse = Invoke-WebRequest  -Uri $refreshurl -Method Post  -Body $body -ContentType "application/json"
	Update-Credentials $authresponse
   }catch{
    $_.Exception.code
    $authresponse = $_.Exception.code
	throw 'Error occured while calling refresh auth url'
   }
   
   $authResString =$authresponse | ConvertFrom-Json
   $newToken = $authResString.access_token+"|" + $authResString.refresh_token;
   return $newToken;
}

function set-customField($response,$venafiToken) {

 $customVenafiTokenArray = $venafiToken.Split("|");
 $customurl = $config.venafi_update_url;
 
 $value = @();

foreach ($element in $response.result.dcvDetails ) {
	$str = $element | ConvertTo-Json;
	$value +=$str;
}

	$guiddata=@{
		Name="Notes"
		Value = $value
	}
 $dn1 =$General.CertObjDN;
 $GuidData =@($guiddata);

 $cbody = @{
	ObjectDN = $dn1;
	AttributeData = $GuidData;
	
 } | ConvertTo-Json -Depth 4
   try {
		$headers = @{ "Authorization"="Bearer "+$customVenafiTokenArray[0] ; "Content-Type"="application/json" }
		$customFieldresponse = Invoke-WebRequest -Uri $customurl -Headers $headers -Method Post  -Body $cbody -ContentType "application/json"
		$statusCode = $customFieldresponse.StatusCode
		
	}catch{
		$_.Exception.code
			$statusCode = $_.Exception.Response.StatusCode.value__;
			
						
	}
return $statusCode;

}

function Update-Credentials($authresponse) {

$authResString =$authresponse | ConvertFrom-Json
$credentialurl = $config.venafi_credentials_update_url;
$newToken = $authResString.access_token+"|" + $authResString.refresh_token;

$values = @();
$usernameValue=@{
     Name="Username"
     Type="string"
     Value= "null"
 }
 $values +=$usernameValue;
$pwdValue=@{
     Name="Password"
     Type="string"
     Value= $newToken
 }
 $values +=$pwdValue;

 
 $body=@{
    Shared="true"
	FriendlyName="UsernamePassword"
	Expiration="/Date(1934085600000-0600)/"
    Values=$values
	CredentialPath=$config.credentails_path
 } | ConvertTo-Json 

 try{

  $headers = @{ "Authorization"="Bearer "+$authResString.access_token; "Content-Type"="application/json" }
  $authresponse = Invoke-WebRequest  -Uri $credentialurl -Method Post -Headers $headers  -Body $body -ContentType "application/json"
  }catch{
    $_.Exception.code
         
 }
 
}

function loadUDFs() {


$customFields = @();

for($i=0;$i -le 13;$i++){
	$udfKey=(@() + $($General.CustomFields["name"+$i] | ? {$_}))[0];
	$udfValue=(@() + $($General.CustomFields["value"+$i] | ? {$_}))[0];
		if($udfKey -and $udfValue){
			$cf=@{
				name=$udfKey;
				value=$udfValue;
			}
		  $customFields +=$cf;
		}
}
if($customFields.Length -eq 0) {
 foreach($customField in $prop_cfg.customFields){
	$udfKey=(@() + $($customField.name  | ? {$_}))[0];
	$udfValue=(@() + $($customField.value | ? {$_}))[0];
		if($udfKey -and $udfValue){
			$cf=@{
				name=$udfKey;
				value=$udfValue;
			}
		  $customFields +=$cf;
		}
  }
}
return $customFields;
}
function getCustomFieldValue($name) {
$value =(@() + $($General.CustomFields[$name] | ? {$_}))[0];
   
    if([string]::IsNullOrEmpty($value)) {
	  $value = (@() + $($prop_cfg.$name | ? {$_}))[0];
    }
	return $value;
}



function Submit-CsrAsRenewal {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )


$cscToken = $General.UserPass;
$csctokenArray = $cscToken.Split("|")
 
	$csr = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Specific.Pkcs10));
	$methodType = (@() + $($General.CustomFields["Domain Control Validation"] | ? {$_}))[0];
	$emailAddress = (@() + $($General.CustomFields["Email"] | ? {$_}))[0];
	$sans_dns = @() + $($Specific.SubjAltNames.DNS | ? {$_});
	$sans_emails =  (@() + $($General.CustomFields["SAN Validation Email List"] | ? {$_}))[0];
	$sansEmailArray = $sans_emails.Split(",")
 
	$domainControlValidation= @{
		methodType=$methodType;
		emailAddress=$emailAddress;
	};
	
	$evCertificateDetails= @{
country=getCustomFieldValue 'country';
city=getCustomFieldValue 'city';
state=getCustomFieldValue 'state'; 
dateOfIncorporation=getCustomFieldValue 'dateOfIncorporation'; 
doingBusinessAs=  getCustomFieldValue 'doingBusinessAs';
businessCategory = getCustomFieldValue 'businessCategory';

};
 
 
 $additionalNotificationEmails = getCustomFieldValue 'additionalNotificationEmails'; 
$notificationEmails = @();
if($additionalNotificationEmails){
	 $notificationEmails +=$additionalNotificationEmails;
}
$notifications=@{
enabled=getCustomFieldValue 'notificationEnabled';
additionalNotificationEmails=@($notificationEmails);

};
	
$sans = @();
foreach($dnsSan in $sans_dns){
	$cf=@{
		domainName=$dnsSan;
			domainControlValidation =@{
				methodType="CNAME";
				emailAddress ="";
			} 
		}
	$sans +=$cf;
}

foreach($emailSan in $sansEmailArray){
	$cf=@{
		domainName=$emailSan.Split("|")[0];
			domainControlValidation =@{
				methodType="EMAIL";
				emailAddress =$emailSan.Split("|")[1];
			} 
		}
	$sans +=$cf;
}

       
 $url = $config.base_url + "renewal";

    $body = @{
       	
		 csr = $csr;
		 uuid  = $Specific.CertId;
		 
		 term = getCustomFieldValue 'term';
		 serverSoftware = getCustomFieldValue 'serverSoftware';
		 domainControlValidation = $domainControlValidation;
         organizationContact=getCustomFieldValue 'organizationContact';
		 customFields = @(loadUDFs);
		 notifications = $notifications;
		 evCertificateDetails = $evCertificateDetails;
		 showPrice=getCustomFieldValue 'showPrice';
		 subjectAlternativeNames = $sans;
		 applicantFirstName=getCustomFieldValue 'applicantFirstName';
		 applicantLastName=getCustomFieldValue 'applicantLastName';
		 applicantEmailAddress=getCustomFieldValue 'applicantEmailAddress';
		 applicantPhoneNumber =getCustomFieldValue 'applicantPhoneNumber';
		 
		
    } | ConvertTo-Json -Depth 3 -Compress
	$venafiToken = $General.AuxPass;
	
	try{
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers @{ 'Authorization' = "Bearer "+$csctokenArray[0];'apikey' = $csctokenArray[1]} -Body $body -ContentType "application/json"
	
	 if ($response.OrderResponseHeader.SuccessCode -gt -1) {
        $renewal_id = $response.result.status.uuid;
        $result = "Success";
		update-cnamedetails $response $venafiToken
    }
    else {
            
        if ($response.OrderResponseHeader.Errors -ne $null) {
            throw $response.OrderResponseHeader.Errors[0].ErrorMessage;
        }
        throw "Error processing the order request";
    }
    return @{ Result = $result; TransId = $renewal_id }
	}
	catch{
$_.Exception.code
 $respStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($respStream)
        $respBody = $reader.ReadToEnd() | ConvertFrom-Json
        
       throw $_.ErrorDetails.Message;
}
}

function Submit-CsrAsReplacement {
     Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

	$cscToken = $General.UserPass;
	$csctokenArray = $cscToken.Split("|")

	$csr = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Specific.Pkcs10));
	$methodType = (@() + $($General.CustomFields["Domain Control Validation"] | ? {$_}))[0];
	$emailAddress = (@() + $($General.CustomFields["Email"] | ? {$_}))[0];
	$sans_dns = @() + $($Specific.SubjAltNames.DNS | ? {$_});
	$sans_emails =  (@() + $($General.CustomFields["SAN Validation Email List"] | ? {$_}))[0];
	$sansEmailArray = $sans_emails.Split(",")
	
	$domainControlValidation= @{
		methodType=$methodType;
		emailAddress=$emailAddress;
	};

	
$sans = @();


 $evCertificateDetails= @{
	country=getCustomFieldValue 'country';
	city=getCustomFieldValue 'city';
	state=getCustomFieldValue 'state'; 
	dateOfIncorporation=getCustomFieldValue 'dateOfIncorporation'; 
	doingBusinessAs=  getCustomFieldValue 'doingBusinessAs';
	businessCategory = getCustomFieldValue 'businessCategory';

};
 
 
$additionalNotificationEmails = getCustomFieldValue 'additionalNotificationEmails'; 
$notificationEmails = @();
if($additionalNotificationEmails){
	 $notificationEmails +=$additionalNotificationEmails;
}
$notifications=@{
	enabled=getCustomFieldValue 'notificationEnabled';
	additionalNotificationEmails=@($notificationEmails);
};


foreach($dnsSan in $sans_dns){
	$cf=@{
		domainName=$dnsSan;
			domainControlValidation =@{
				methodType="CNAME";
				emailAddress ="";
			} 
		}
	$sans +=$cf;
}

foreach($emailSan in $sansEmailArray){
	$cf=@{
		domainName=$emailSan.Split("|")[0];
			domainControlValidation =@{
				methodType="EMAIL";
				emailAddress =$emailSan.Split("|")[1];
			} 
		}
	$sans +=$cf;
}
       
    $url = $config.base_url + "reissue";
    $body = @{
       	
		 csr   =  $csr;
		 uuid  = $Specific.CertId;
		 term = getCustomFieldValue 'term';
		 serverSoftware = getCustomFieldValue 'serverSoftware';
		 domainControlValidation = $domainControlValidation;
		 organizationContact=getCustomFieldValue 'organizationContact';
		 customFields = @(loadUDFs);
		 notifications = $notifications;
		 evCertificateDetails = $evCertificateDetails;
		 showPrice=getCustomFieldValue 'showPrice';
		 subjectAlternativeNames = $sans;
		 applicantFirstName=getCustomFieldValue 'applicantFirstName';
		 applicantLastName=getCustomFieldValue 'applicantLastName';
		 applicantEmailAddress=getCustomFieldValue 'applicantEmailAddress';
		 applicantPhoneNumber =getCustomFieldValue 'applicantPhoneNumber';
		 
		
    } | ConvertTo-Json -Depth 3 -Compress
	
	$venafiToken = $General.AuxPass;
	
	
try{
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers @{ 'Authorization' = "Bearer "+$csctokenArray[0];'apikey' = $csctokenArray[1]} -Body $body -ContentType "application/json"
	
	 if ($response.OrderResponseHeader.SuccessCode -gt -1) {
        $reissue_id = $response.result.status.uuid;
        $result = "Success";
		update-cnamedetails $response $venafiToken
    }
    else {
            
        if ($response.OrderResponseHeader.Errors -ne $null) {
            throw $response.OrderResponseHeader.Errors[0].ErrorMessage;
        }

        throw "Error processing the order request";
    }
    return @{ Result = $result; TransId = $reissue_id }
	}
	catch{
$_.Exception.code
 $respStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($respStream)
        $respBody = $reader.ReadToEnd() | ConvertFrom-Json
        
       throw $_.ErrorDetails.Message;
}
}

function Approve-Request {
    return @{ Result = "NotUsed" }
}

function Retrieve-Certificate {

Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
	
	
	$cscToken = $General.UserPass;
	$csctokenArray = $cscToken.Split("|")
    $url = $config.base_url+"certificate/"+$Specific.CertId;
	

$header = @{ 'Authorization' = "Bearer $token"}

try{

 $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ 'Authorization' = "Bearer "+$csctokenArray[0];'apikey' = $csctokenArray[1]} -Body $body -ContentType "application/json"

	 if ($response.QueryResponseHeader.SuccessCode -gt -1) {
	  
        $pkcs7 = $response.certificate;
		
		$status = "Pending";
        if ($pkcs7 -ne $null) {
            if ($response.status -eq "ACTIVE") {
                $status = "Issued";
            }
            else {
                $certs = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
                $certs.Import( [Convert]::FromBase64String($pkcs7) )

                foreach ( $cert in $certs )
                {
                 
                        $certs.Add($cert)
                        $pkcs7 = $certs.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
                        $status = "Issued";
                        break
                    
                }
            }
        }
        else {
            $status = "Pending";
        }
    }
    else {
        if ($response.QueryResponseHeader.Errors -ne $null) {
            throw $response.QueryResponseHeader.Errors[0].ErrorMessage;
        }
		
        throw "Error processing the order request";
    }
	
}

catch{

$_.Exception.code
 $respStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($respStream)
        $respBody = $reader.ReadToEnd() | ConvertFrom-Json
        $errorCode = $respBody.code
        $errorMessage = $respBody.description
        $causeDetails = $respBody.value
        Write-Host "Exception in processing request :`r`n$expMessage`r`n$($errorCode): $errorMessage`n`r $causeDetails" ForegroundColor Red
		$errorCode
		$errorMessage
		$causeDetails
       throw "Error processing from catch the order request $errorMessage";
}


$bytes1 = [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String($response.certificate)|?{$_}));
$begin = "-----BEGIN CERTIFICATE-----";
$end = "-----END CERTIFICATE-----";
$encodeLevel1;
if($bytes1.Contains($begin)){
$encodeLevel2 = $bytes1;
}else{
$encodeLevel2 = [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String($bytes1)|?{$_}));
}
$subStr = $encodeLevel2.Substring($encodeLevel2.LastIndexOf($begin),$encodeLevel2.LastIndexOf("-----END CERTIFICATE-----")-$encodeLevel2.LastIndexOf($begin)).Replace("-----END CERTIFICATE-----","").Replace("-----BEGIN CERTIFICATE-----","");

$enc = [system.Text.Encoding]::UTF8
$data1 = $enc.GetBytes($subStr) 

$EncodedText =[Convert]::ToBase64String($data1);  

 $enc = [system.Text.Encoding]::UTF8
 
$bytes3 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncodedText));

	$data1 = $enc.GetBytes($bytes3) 
    return @{ Status = $status; Result = "Success";pkcs7 = $data1}
		  

}

function Revoke-Certificate {
Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
	
	$cscToken = $General.UserPass;
   $csctokenArray = $cscToken.Split("|")
	
    $url=$config.base_url+"revoke/"+$Specific.CertId;

try{

 $response = Invoke-RestMethod -Uri $url -Method Put -Headers @{ 'Authorization' = "Bearer "+$csctokenArray[0];'apikey' = $csctokenArray[1]} -Body $body -ContentType "application/json"
	
    return @{ Result = "Success" }
	}

catch{
$_.Exception.code
 $respStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($respStream)
        $respBody = $reader.ReadToEnd() | ConvertFrom-Json
        
       throw $_.ErrorDetails.Message;
}
    
}

function Read-JsonConfigFile( [string] $FileName )
{
    
    $config_file = $script_dir + ($FileName -replace "\.ps1$",".json")

    if ( -not $(Test-Path $config_file) )
    {
        throw "PowerShell script configuration file not found ({0})." -f $config_file
    }
    
    try { $cfg = Get-Content -Path $config_file -Raw | ConvertFrom-Json }
    catch { throw "PowerShell script configuration file is malformed or not JSON." }
	
    if ( -not $cfg.base_url )
    {
        throw "Configuration value 'base_url' is invalid ({0})" -f $cfg.base_url 
    }
	
	if ( -not $cfg.venafi_auth_url )
    {
        throw "Configuration value 'venafi_auth_url' is invalid ({0})" -f $cfg.venafi_auth_url 
    }
	
	if ( -not $cfg.venafi_update_url )
    {
        throw "Configuration value 'venafi_update_url' is invalid ({0})" -f $cfg.venafi_update_url 
    }
	
	if ( -not $cfg.venafi_credentials_update_url )
    {
        throw "Configuration value 'venafi_credentials_update_url' is invalid ({0})" -f $cfg.venafi_credentials_update_url 
    }
	
	if ( -not $cfg.credentails_path )
    {
        throw "Configuration value 'credentails_path' is invalid ({0})" -f $cfg.credentails_path 
    }
	
	if ( -not $cfg.client_id )
    {
        throw "Configuration value 'client_id' is invalid ({0})" -f $cfg.client_id 
    }
  
    return $cfg
}

function Read-PropertiesJsonFile([string] $FileName )
{
    
   $propr_config_file = $script_dir + ($FileName -replace "\.ps1$",".json")
  
    if ( -not $(Test-Path $propr_config_file) )
    {
        throw "PowerShell script properties file not found."
    }
    try { 
	$prop_cfg = Get-Content -Path $propr_config_file -Raw | ConvertFrom-Json 
	 
	}
    catch { throw "PowerShell script properties file is malformed or not JSON." 
	}
	return $prop_cfg
	
}


