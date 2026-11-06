# IMPORTANT - Before running this script please contact your Acmetek 
# account representative to get the accurate list of the certificate
# products that apply to you.

$cert_products = @( 
    "True BusinessID",
    "True BusinessID Wildcard",
    "True BusinessID EV",
    "True BusinessID Multi Domain",
    "True BusinessID Multi Domain EV"
)

$websdk_url = "https://tpp.venafi.example"
$websdk_adm_user = "local:admin"
$websdk_adm_pass = "password"

###################################################################################################

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls -bor `
    [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls12

##### AUTHENTICATE #####

$uri = "{0}/vedsdk/authorize/" -f $websdk_url
$body = @{ Username=$websdk_adm_user; Password=$websdk_adm_pass } | ConvertTo-Json
$apikey = (Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType "application/json").APIKey

$headers = @{ "X-Venafi-Api-Key"=$apikey; "Content-Type"="application/json" }

##### CREATE 'Acmetek: Product Name' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "Acmetek: Product Name";
        Name = "Acmetek_Product_Name";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        AllowedValues = $cert_products;
        Single = $true;
        Mandatory = $true;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'Acmetek: Contract Name' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "Acmetek: Contract Name";
        Name = "Acmetek_Contract_Name";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $true;
        Policyable = $true;
        RegularExpression = "^[A-Za-z0-9]*$";
        ErrorMessage = "Valid contract names consist only of alphanumeric characters";
        Help = "Name of the contract with Acmetek";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'Acmetek: Validity In Years' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "Acmetek: Validity In Years";
        Name = "Acmetek_Validity_In_Years";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        Single = $true;
        AllowedValues = @( "1", "2" );
        Mandatory = $true;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'Acmetek: Domain Approver Email' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "Acmetek: Domain Approver Email";
        Name = "Acmetek_Domain_Approver_Email";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $true;
        Policyable = $true;
        RegularExpression = "^[a-zA-Z0-9_\.\+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-\.]+$";
        ErrorMessage = "Must be a valid email address (user@domain)";
        Help = "The email address of the person who will approve the order";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"