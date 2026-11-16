$websdk_url = "https://tpp.venafidemo.com/"
$websdk_adm_user = "local:tppadmin"
$websdk_adm_pass = "Password123!"

###################################################################################################

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
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

##### AUTHENTICATE #####

$uri = "{0}/vedsdk/authorize/" -f $websdk_url
$body = @{ Username=$websdk_adm_user; Password=$websdk_adm_pass } | ConvertTo-Json
$apikey = (Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType "application/json").APIKey

$headers = @{ "X-Venafi-Api-Key"=$apikey; "Content-Type"="application/json" }

##### CREATE 'AffirmTrustDV:ContractID' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "AffirmTrustDV:ContractID";
        Name = "AffirmTrustDV_ContractID";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $false;
        Policyable = $true;
        RegularExpression = "^[0-9]*$";
        ErrorMessage = "Valid contract IDs consist only of numeric characters";
        Help = "ID of the contract with AffirmTrust";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"


##### CREATE 'AffirmTrustDV:ValidityYears' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "AffirmTrustDV:ValidityYears";
        Name = "AffirmTrustDV_ValidityYears";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        Single = $true;
        AllowedValues = @( "1" );
        Mandatory = $true;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"


##### CREATE 'AffirmTrustDV:ContactName' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "AffirmTrustDV:ContactName";
        Name = "AffirmTrustDV_ContactName";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $true;
        Policyable = $true;
        RegularExpression = "[' a-zA-Z0-9-]*$";
        ErrorMessage = "Should be a full name such as John O'Reilly";
        Help = "The full name of the person who can be contacted regarding the order, either someone at the domain/site for which the cert is being issued, or someone at this Venafi installation.";
    }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'AffirmTrustDV:ContactEmail' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "AffirmTrustDV:ContactEmail";
        Name = "AffirmTrustDV_ContactEmail";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $true;
        Policyable = $true;
        RegularExpression = "^[a-zA-Z0-9_\.\+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-\.]+$";
        ErrorMessage = "Must be a valid email address (user@domain)";
        Help = "The email address of the person who can be contacted regarding the order, either someone at the domain/site for which the cert is being issued, or someone at this Venafi installation.";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'AffirmTrustDV:VerificationFolder' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "AffirmTrustDV:VerificationFolder";
        Name = "AffirmTrustDV_VerificationFolder";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $true;
        Policyable = $true;
        RegularExpression = "^[:.\/\\a-zA-Z0-9-_]*$";
        ErrorMessage = "Must be a valid full path name to a local directory/folder";
        Help = "Local folder into which a file containing necessary domain validation information to be acted upon so that the certificate will be approved and made available to the customer. See the Driver documentation for details";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'AffirmTrustDV:VerificationMethod' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "AffirmTrustDV:VerificationMethod";
        Name = "AffirmTrustDV_VerificationMethod";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        Single = $true;
        AllowedValues = @( "FILE", "DNS" );
        Mandatory = $true;
        Policyable = $true;
        Help = "The method by which the certificate requester's systems will prove domain control. See the Driver documentation for details.";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"
