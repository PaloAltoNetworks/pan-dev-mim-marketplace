<#
//---------------------------------------------------------------------------
// HID_PKIaaS_Create_Custom_Fields.ps1
//
// IMPORTANT - Before running this script please contact your HydrantID
// account representative to get the list of custom fields that are
// needed for your account.
//---------------------------------------------------------------------------
// Copyright (c) 2020 Venafi, Inc. All rights reserved.
//
// This software is licensed by HydrantID, in addition to Venafi.
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

$websdk_url = "https://tpp.venafi.example"
$websdk_adm_user = "local:admin"
$websdk_adm_pass = "password"

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

##### CREATE 'HydrantID ACM: Validity Days' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "HydrantID ACM: Validity Days";
        Name = "HydrantID_ACM_Validity_Days";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        AllowedValues = @( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 );
        Single = $true;
        Mandatory = $false;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'HydrantID ACM: Validity Months' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "HydrantID ACM: Validity Months";
        Name = "HydrantID_ACM_Validity_Months";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        AllowedValues = @( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 );
        Single = $true;
        Mandatory = $false;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'HydrantID ACM: Validity Years' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "HydrantID ACM: Validity Years";
        Name = "HydrantID_ACM_Validity_Years";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        AllowedValues = @( 1, 2, 3, 4, 5 );
        Single = $true;
        Mandatory = $false;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'AEP: Application Policies' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "AEP: Application Policies";
        Name = "AEP_Application_Policies";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $false;
        Policyable = $true;
        RegularExpression = "^[0-9A-Fa-f]*$"
        ErrorMessage = "Valid application policies value will be hex encoded DER strings";
        Help = "Hex encoded DER string for application policies extension"
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"

##### CREATE 'AEP: Certificate Template' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "AEP: Certificate Template";
        Name = "AEP_Certificate_Template";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $false;
        Policyable = $true;
        RegularExpression = "^[0-9A-Fa-f]*$"
        ErrorMessage = "Valid certificate template value will be hex encoded DER strings";
        Help = "Hex encoded DER string for certificate template extension"
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json"
