<#
//-----------------------------------------------------------------------
// CSCGlobal_Certificate_Import.ps1
//
// Copyright (c) 2019 Venafi, Inc.  All rights reserved.
// Venafi,  Inc.  hereby grants  you  limited permission  to  use and  modify  this
// software during only the period in  which you hold a valid license  from Venafi,
// Inc. to use the Venafi Trust Protection Platform, on condition that (a) such use
// or modification  is for  your sole  internal business  use, and  (b) you  hereby
// assign to Venafi, Inc. all rights in any modifications of this software that you
// may create (and agree to take all such actions as may be necessary and desirable
// to perfect  such assignment),  except that  you (i)  shall retain any Background
// Intellectual Property that you may  incorporate into any such modifications  and
// (ii) hereby agree  to grant Venafi,  Inc., a perpetual,  worldwide, royalty free
// license  to  use,  copy,  modify,  reproduce,  distribute  such   modifications,
// including, without limitation, any Background Intellectual Property incorporated
// into  such  modifications.  For  the  purposes  of  this  paragraph, “Background
// Intellectual  Property”  means  any  intellectual  property  developed  by   you
// independently of this software (or any modifications thereof). You may not copy,
// reproduce or distribute this software (or any modifications thereof) without the
// prior written consent of Venafi, Inc. (which may be by email). Without  limiting
// the foregoing,  the above  copyright notice,  this paragraph  and the  following
// paragraph  must  appear  in   all  copies,  modifications,  reproductions,   and
// distributions of this software.
//
// IN  NO EVENT  SHALL VENAFI, INC.,   ITS DIRECTORS, OFFICERS,  EMPLOYEES, AGENTS,
// OR  AFFILIATES  BE   LIABLE  TO  ANY   PARTY  FOR  DIRECT,  INDIRECT,   SPECIAL,
// INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE
// USE OF THIS SOFTWARE   OR ITS DOCUMENTATION, IF   ANY, EVEN IF VENAFI,  INC. HAS
// BEEN ADVISED  OF  THE  POSSIBILITY OF  SUCH DAMAGES.  VENAFI,  INC. SPECIFICALLY
// DISCLAIMS   ANY   WARRANTIES, INCLUDING,   BUT   NOT  LIMITED  TO,   ANY IMPLIED
// WARRANTIES  OF  MERCHANTABILITY  OR  FITNESS  FOR  A  PARTICULAR  PURPOSE.  THIS
// SOFTWARE, ALONG  WITH ITS  DOCUMENTATION, IF  ANY, IS  PROVIDED "AS IS". VENAFI,
// INC.  HAS NO  OBLIGATION TO  PROVIDE MAINTENANCE,  SUPPORT, OR  UPDATES FOR  THE
// SOFTWARE OR ITS DOCUMENTATION, IF ANY.
//-----------------------------------------------------------------------
#> 

<##################################################################################################
.NAME
    Import-Certificates
.DESCRIPTION
    Imports certificates from CSC Global into the Trust Protection Platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserName: the username required to authenticate with the CA
        UserPass: the password required to authenticate with the CA
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state. 'Incomplete' to re-run method later
        Certificates: A hashtable containing certificate data
            Name : (required) identifier that will appear in log event if certificate fails to import
            PEM : (required) the raw certificate in PEM format
            ContactEmail : the email address of the certificate contact
            TransactionId : the unique DigiCert ID of the certificate
            Attributes : A hashtable of additional attributes to set when importing the certificate
        LastProcessedId : string value with the ID of the last certificate in the Certificates hash table
		RunAfter : Number of hours after which script will be executed again
    
    Version:        2.0
    Author:         Nelson Buya (nelson.buya@venafi.com
    Creation Date:  24 September 2021
    Purpose/Change: Support CSC Global API changes to certificate response format
##################################################################################################>

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "STOP"

$global:apiUrl = "https://apis.cscglobal.com/dbs/api/v2/tls/certificate?filter=status==ACTIVE"

function Import-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    if ($DEBUG_FILE) {
        "".PadLeft(80,"_") | Out-File $DEBUG_FILE
        "$(Get-Date) - CSC Global Certificate Import" | Out-File $DEBUG_FILE -Append
    }

    # Iterate through passed arguments
    if ($DEBUG_FILE) {
        "$(Get-Date) - General Parameters" | Out-File $DEBUG_FILE -Append
        $General.GetEnumerator() |
        Where-Object -Property Name -NotMatch 'pass' |
        Sort-Object -Property Value -Descending |
        Format-Table |
        Out-String |
        Out-File $DEBUG_FILE -Append

        "$(Get-Date) - Specific Parameters" | Out-File $DEBUG_FILE -Append
        $Specific.GetEnumerator() |
        Sort-Object -Property Value -Descending |
        Format-Table |
        Out-String |
        Out-File $DEBUG_FILE -Append
    }

    $headers = @{
        'apikey' = $General.UserName;
        'Authorization' = "Bearer $($General.UserPass)";
    }

    $response = Invoke-RestMethod -Uri $global:apiUrl -Headers $headers -Method GET -ContentType "application/json"

    $responseJson = $response | ConvertTo-Json

    if($DEBUG_FILE){
        "$(Get-Date) - Response: $($responseJson)" | Out-File $DEBUG_FILE -Append
    }

    $certificates = @()
    foreach ($cert in $response.results)
    {
        if ([String]::IsNullOrEmpty($cert.certificate)) {
            if($DEBUG_FILE){
                "$(Get-Date) - Certificate value is missing for $($cert.commonName): UUID: $($cert.uuid)" | Out-File $DEBUG_FILE -Append
            }
            continue
        } else {
            $chain = [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String($cert.certificate)));
            $begin = "-----BEGIN CERTIFICATE-----";
            $end = "-----END CERTIFICATE-----";
            $subStr = $chain.Substring($chain.LastIndexOf($begin),$chain.LastIndexOf($end)-$chain.LastIndexOf($begin))
            $pem = $subStr + $end

            $certificates += @{
                Name=$cert.commonName;
                PEM=[String]$pem;
                TransactionId=$cert.uuid;
                Attributes=@{};
                CustomFields=[System.Collections.Hashtable]$certCustomFields;
            }
        }
    }

    $certificatesJson = $certificates | ConvertTo-Json

    if ($DEBUG_FILE){
        "$(Get-Date) - Certificates to import: $($certificatesJson)" | Out-File $DEBUG_FILE -Append
    }

    return @{Result="Success"; Certificates=$certificates}
}