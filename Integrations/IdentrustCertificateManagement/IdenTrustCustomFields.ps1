$websdk_url = "https://tpp-alpha.venafi.example"

$websdk_adm_user = "local:admin"
$websdk_adm_pass = "newPassw0rd!"

###############################################################################

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

##### CREATE 'IdenTrust: Account Type' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "IdenTrust: Account Type";
        Name = "IdenTrust_Account_Type";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Policyable = $true;
        RegularExpression = "^[0-9]*$";
        ErrorMessage = "Valid Account Types consist only of numeric characters";
        Help = "Contact your IdenTrust Delivery Team Representative";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'IdenTrust: Certificate Type' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "IdenTrust: Certificate Type";
        Name = "IdenTrust_Certificate_Type";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Policyable = $true;
        RegularExpression = "^[0-9]*$";
        ErrorMessage = "Valid Certificate Types consist only of numeric characters";
        Help = "Contact your IdenTrust Delivery Team Representative";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'IdenTrust: Account Number' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "IdenTrust: Account Number";
        Name = "IdenTrust_Account_Number";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Policyable = $true;
        RegularExpression = "^[0-9]*$";
        ErrorMessage = "Valid Account Numbers consist only of numeric characters";
        Help = "Contact your IdenTrust Delivery Team Representative";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'IdenTrust: Contact First Name' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "IdenTrust: Contact First Name";
        Name = "IdenTrust_Contact_First_Name";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Policyable = $true;
        RegularExpression = "^[A-Za-z0-9\.-']*$";
        ErrorMessage = "Valid First Names consist only of alphanumeric characters and .-'";
        Help = "The first name of the domain contact in US ASCII.";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'IdenTrust: Contact Last Name' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "IdenTrust: Contact Last Name";
        Name = "IdenTrust_Contact_Last_Name";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Policyable = $true;
        RegularExpression = "^[A-Za-z0-9\.-']*$";
        ErrorMessage = "Valid Last Names consist only of alphanumeric characters and .-'";
        Help = "The last name of the domain contact in US ASCII.";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'IdenTrust: Contact Email Address' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "IdenTrust: Contact Email Address";
        Name = "IdenTrust_Contact_Email_Address";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Policyable = $true;
        RegularExpression = "^[a-zA-Z0-9_\.\+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-\.]+$";
        ErrorMessage = "Must be a valid email address (user@domain)";
        Help = "The email address of the domain contact";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'IdenTrust: Contact Phone Number' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "IdenTrust: Contact Phone Number";
        Name = "IdenTrust_Contact_Phone_Number";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Policyable = $true;
        RegularExpression = "^[\(\)-\+ 0-9a-zA-Z]";
        ErrorMessage = "Must be a valid phone number";
        Help = "The phone number of the domain contact";
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"
