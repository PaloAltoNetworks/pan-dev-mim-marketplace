<#
//----------------------------------------------------------------------- 
// Acmetek.ps1
//----------------------------------------------------------------------- 
// Copyright (c) 2021 Venafi, Inc. All rights reserved.
//
// This software is licensed by INSERT DEVELOPER NAME, in addition to Venafi.
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
//----------------------------------------------------------------------- 
// Custom Fields
// 'Acmetek: Product Name' : Name of the product for the order
// 'Acmetek: Contract Name' : Contract Name with Acmetek
// 'Acmetek: Validity In Years' : Number for which the Certificate required in years
// 'Acmetek: Domain Approver Email' : Email of the person who wil approve the order
#>

$global:base_url = "https://www.acmetekapi.com/"

function Submit-CsrAsNew {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $uname = $General.UserName;
    $pass = $General.UserPass;

    $DNS = $Specific.SubjAltNames.DNS -join ",";
    $DomainName = $Specific.SubjectDN.CN;
    $csr = $Specific.Pkcs10;

    $prodName = (@() + $($General.CustomFields["Acmetek: Product Name"] | ? {$_}))[0];
    $contractName = $General.CustomFields["Acmetek: Contract Name"];
    $validityPeriod = (@() + $($General.CustomFields["Acmetek: Validity In Years"] | ? {$_}))[0];
    $approverEmail = $General.CustomFields["Acmetek: Domain Approver Email"];
        
    $url = $global:base_url + "api/Venafi/ProcessOrderRequest";

    $body = @{
        UserName         = $uname;
        Password         = $pass;
        ProductName      = $prodName;
        ContractName     = $contractName;
        ValidityPeriod   = $validityPeriod;
        CSR              = $csr;
        ApproverEmail    = $approverEmail;
        DNSNames         = $DNS;
        DomainName       = $DomainName;
        RenewalIndicator = "false";
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
 
    if ($response.OrderResponseHeader.SuccessCode -gt -1) {
        $transaction_id = $response.GeoTrustOrderID.toString();
        $result = "Success";
    }
    else {
            
        if ($response.OrderResponseHeader.Errors -ne $null) {
            throw $response.OrderResponseHeader.Errors[0].ErrorMessage;
        }


        throw "Error processing the order request";
    }
    return @{ Result = $result; TransId = $transaction_id }
}

function Submit-CsrAsReplacement {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $uname = $General.UserName;
    $pass = $General.UserPass;

    $DomainName = $Specific.SubjectDN.CN;
    $csr = $Specific.Pkcs10;

    $prodName = (@() + $($General.CustomFields["Acmetek: Product Name"] | ? {$_}))[0];
    $contractName = $General.CustomFields["Acmetek: Contract Name"];
    $validityPeriod = (@() + $($General.CustomFields["Acmetek: Validity In Years"] | ? {$_}))[0];
    $approverEmail = $General.CustomFields["Acmetek: Domain Approver Email"];
        
    $url = $global:base_url + "api/Venafi/ReissueExactOrder";

    $body = @{
        UserName       = $uname;
        Password       = $pass;
        OrderID        = $Specific.CertId;
        ProductName    = $prodName;
        ContractName   = $contractName;
        ValidityPeriod = $validityPeriod;
        CSR            = $csr;
        ApproverEmail  = $approverEmail;
        DomainName     = $DomainName;
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
 
    if ($response.OrderResponseHeader.SuccessCode -gt -1) {
        $transaction_id = $response.GeoTrustOrderID.toString();
        $result = "Success";
    }
    else {
            
        if ($response.OrderResponseHeader.Errors -ne $null) {
            throw $response.OrderResponseHeader.Errors[0].ErrorMessage;
        }


        throw "Error processing the order request";
    }
    return @{ Result = $result; TransId = $transaction_id }
}

function Retrieve-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $url = $global:base_url + "api/Venafi/GetOrderDetailsbyPartnerOrderID";

    $body = @{
        "OrderID"  = $Specific.CertId;
        "UserName" = $General.UserName;
        "Password" = $General.UserPass;
    }| ConvertTo-Json

    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
 
    if ($response.QueryResponseHeader.SuccessCode -gt -1) {
        $pkcs7 = $response.OrderDetail.Fulfillment.PKCS7;

        if ($pkcs7 -ne $null) {
            if ($response.OrderDetail.CertificateInfo.CertificateStatus -ne "Active") {
                $status = "Pending";
            }
            else {
                $certs = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
                $certs.Import( [Convert]::FromBase64String($pkcs7) )

                foreach ( $cert in $certs )
                {
                    if ( -not $cert.Extensions.CertificateAuthority )
                    {
                        $certs.Clear()
                        $certs.Add($cert)
                        $bytes = $certs.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7)
                        $status = "Issued";
                        break
                    }
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
    return @{ Status = $status; Result = "Success"; Pkcs7 = $bytes }
}

function Revoke-Certificate {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    $url = $global:base_url + "api/Venafi/CancelOrder";

    $body = @{
        "OrderID"       = $Specific.CertId;
        "UserName"      = $General.UserName;
        "Password"      = $General.UserPass;
        "ProductName"   = (@() + $($General.CustomFields["Acmetek: Product Name"] | ? {$_}))[0];
        "ApproverEmail" = $General.CustomFields["Acmetek: Domain Approver Email"];
    }| ConvertTo-Json

    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
 
    if ($response.OrderResponseHeader.SuccessCode -gt -1) {
        $result = "Success";
    }
    else {
            
        if ($response.OrderResponseHeader.Errors -ne $null) {
            throw $response.OrderResponseHeader.Errors[0].ErrorMessage;
        }


        throw "Error processing the order request";
    }
    return @{ Result = $result; }
}

function Test-Settings {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General
    )

    $url = $global:base_url + "api/Venafi/TestSettings";

    $body = @{
        "UserName"      = $General.UserName;
        "Password"      = $General.UserPass;
    }| ConvertTo-Json

    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
 
    if ($response.OrderResponseHeader.SuccessCode -gt -1) {
        $result = "Success";
    }
    else {
            
        if ($response.OrderResponseHeader.Errors -ne $null) {
            throw $response.OrderResponseHeader.Errors[0].ErrorMessage;
        }

        throw "Error processing the order request";
    }
    return @{ Result = $result; }
}

# Unused
function Submit-CsrAsRenewal {
    return Submit-CsrAsNew -general $General -specific $Specific
}

function Approve-Request {
    return @{ Result = "NotUsed" }
}

function Get-ChainCertificates {
    return @{ Result = "NotUsed" }
}

function Prepare-ForRequest {
    return @{ Result = "NotUsed" }
}