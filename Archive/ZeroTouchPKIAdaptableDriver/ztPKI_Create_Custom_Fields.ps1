 <#
//---------------------------------------------------------------------------
// Venafi Zero Touch PKI.ps1
// v2.0
//
// IMPORTANT - Before running this script please contact your Venafi
// account representative to get the list of custom fields that are
// needed for your account.
//---------------------------------------------------------------------------
// Copyright (c) 2022 Venafi, Inc.  All rights reserved.
//
// Venafi, Inc. hereby grants you limited permission to use and modify this software during only the period in which you
// hold a valid license from Venafi, Inc. to use the Venafi Trust Protection Platform, on condition that (a) such use or
// modification is for your sole internal business use, and (b) you hereby assign to Venafi, Inc. all rights in any
// modifications of this software that you may create (and agree to take all such actions as may be necessary and desirable
// to perfect such assignment), except that you (i) shall retain any Background Intellectual Property that you may
// incorporate into any such modifications and (ii) hereby agree to grant Venafi, Inc., a perpetual, worldwide, royalty
// free license to use, copy, modify, reproduce, distribute such modifications, including, without limitation, any
// Background Intellectual Property incorporated into such modifications. For the purposes of this paragraph, “Background
// Intellectual Property” means any intellectual property developed by you independently of this software (or any
// modifications thereof). You may not copy, reproduce or distribute this software (or any modifications thereof) without
// the prior written consent of Venafi, Inc. (which may be by email). Without limiting the foregoing, the above copyright
// notice, this paragraph and the following paragraph must appear in all copies, modifications, reproductions, and
// distributions of this software.
// IN NO EVENT SHALL VENAFI, INC., ITS DIRECTORS, OFFICERS, EMPLOYEES, AGENTS, OR AFFILIATES BE LIABLE TO ANY PARTY FOR
// DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS
// SOFTWARE OR ITS DOCUMENTATION, IF ANY, EVEN IF VENAFI, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
// VENAFI, INC. SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OF
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. THIS SOFTWARE, ALONG WITH ITS DOCUMENTATION, IF ANY, IS PROVIDED
// "AS IS". VENAFI, INC. HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, OR UPDATES FOR THE SOFTWARE OR ITS
// DOCUMENTATION, IF ANY.
//---------------------------------------------------------------------------
#>

param (
    [Parameter(Mandatory=$false)]$TPPServer = $(Read-Host -Prompt "Enter TPP URL (Example: exampletpp.venafi.com)"),
    [Parameter(Mandatory=$false)]$OauthToken = $(Read-Host -Prompt "Enter API OAuth Token with Assigned Scope of Configuration:Manage (Example: Pn08xCdtn4pfZhdVtNpUlQ==)")
)


###############################################################################

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

##### AUTHENTICATE #####

# Setup url's for VEDAuth and VEDSDK
    $websdk_url = "https://$($TPPServer)/"

# Setup Headers for our calls
    $headers = @{
        "Content-Type"  = "application/json";
        "Authorization" = "Bearer $($OauthToken)"
    }

##### CREATE 'ZTPKI: Validity Days' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "ZTPKI: Validity Days";
        Name = "ZTPKI_Validity_Days";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        AllowedValues = @( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 );
        Single = $true;
        Mandatory = $false;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json" -Verbose

##### CREATE 'ZTPKI: Validity Months' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "ZTPKI: Validity Months";
        Name = "ZTPKI_Validity_Months";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        AllowedValues = @( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 );
        Single = $true;
        Mandatory = $false;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json" -Verbose

##### CREATE 'ZTPKI: Validity Years' CUSTOM FIELD #####

$uri = "{0}/vedsdk/metadata/defineitem" -f $websdk_url
$body = @{
    Item = @{
        Label = "ZTPKI: Validity Years";
        Name = "ZTPKI_Validity_Years";
        Classes = @( "X509 Certificate" );
        Type = 2; # List
        AllowedValues = @( 1, 2, 3, 4, 5 );
        Single = $true;
        Mandatory = $false;
        Policyable = $true;
   }
} | ConvertTo-Json -Depth 4
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json" -Verbose

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
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json" -Verbose

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
Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType "application/json" -Verbose
