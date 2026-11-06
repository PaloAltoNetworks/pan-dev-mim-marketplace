<#
//---------------------------------------------------------------------------
// ThycoticAdaptableCredential.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2021 Venafi, Inc. (“Venafi”). All rights reserved.
//
// Venafi hereby grants you a limited license to use and modify this
// software, including any Contributions, during only the period in which you
// hold a valid license from Venafi to use the Venafi Trust Protection
// Platform. For the purposes of this copyright notice, “Contributions” means
// any modifications of this software or derivative works based on this
// software. You have a responsibility to share any Contributions you may
// make with the Venafi community. To the extent you may create any
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
// software outside your organization without consent from Venafi is strictly
// prohibited. Without limiting the foregoing, the above copyright notice,
// preceding paragraphs, this paragraph and the following paragraph must
// appear in all copies, modifications, reproductions, and distributions of
// this software.
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

<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text1|Secret Identifier|11
Text2|Text Field #2|00
Text3|Text Field #3|00
Text4|Text Field #4|00
Text5|Text Field #5|00
Option1|Yes/No Option #1
Option2|Yes/No Option #2
Passwd|Password Field|00
-----END FIELD DEFINITIONS-----
#>

Set-StrictMode -Version 'Latest'

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
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

<######################################################################################################################
.NAME
    Test-Connector
.DESCRIPTION
    Validate connection to the Vault
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        VaultUrl : the Vault endpoint URL
        Username: the username required to authenticate with the Vault
        Password: the password or Token required to authenticate with the Vault
        PfxData: a PKCS#12 containing a client certificate and private key required to authenticate with the Vault
        PfxPass: the password required to access the private key in the PKCS#12
.NOTES
    Returns...
        Result : 'Success' to indicate the non-error completion state
######################################################################################################################>
function Test-Connector
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General
    )
    try
	{

        $creds = @{
            username = $General["Username"]
            password = $General["Password"]
            grant_type = "password"
        };

        $headers = $null
        $url = $General["VaultUrl"] + "oauth2/token"
        $response = Invoke-RestMethod  $url -Method Post -Body $creds -Headers $headers
        $token = $response.access_token;
        If ($token -ne $null)
        {
            return @{ Result="Success"; }
        }
    } catch {
        return @{ Result=$_.Exception.Message }
    }

}

<#
#####################################################################################################################
.NAME
    Retrieve-Credential
.DESCRIPTION
    Retrieve credential/secret data
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Connector)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
		ConnectorDN: the Adaptable credential connector DN
		CredentialDN: the Adaptable credential DN
		CredentialType: a credential type (string) that the Adaptable Credential object will represent ("Password Credential", 
						"Username Password Credential", "Certificate Credential", "Private Key Credential", "Amazon Credential")
        VarText1: a string value for the text custom field defined by the header at the top of this script
        VarText2: a string value for the text custom field defined by the header at the top of this script
        VarText3: a string value for the text custom field defined by the header at the top of this script
        VarText4: a string value for the text custom field defined by the header at the top of this script
        VarText5: a string value for the text custom field defined by the header at the top of this script
        VarBool1: a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarBool2: a boolean value for the yes/no custom field defined by the header at the top of this script (true|false)
        VarPass: a string value for the password custom field defined by the header at the top of this script
.NOTES
    Returns...
        Result: 'Success' to indicate the non-error completion state
        Username: the retrieved credential username
        Password: the retrieved credential password
#####################################################################################################################
#>
function Retrieve-Credential
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )
    try
	{

	    # Do credential/secret retrieval based on the CredentialType from the Specific hashtable
	    $creds = @{
            username = $General.Username
            password = $General.Password
            grant_type = "password"
        };
       
        $headers = $null
        $url = $General.VaultUrl + "/oauth2/token"
        $response = Invoke-RestMethod  $url -Method Post -Body $creds -Headers $headers
        $token = $response.access_token;

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $token")
        $apiurl = $General.VaultUrl + "/api/v1/secrets/" + $Specific.VarText1
        $result = Invoke-RestMethod $apiurl -Headers $headers
        
        ForEach($field in $Result.Items)
        {
            if ($field.FieldName -eq "UserName")
            {
                $Username = $field.itemvalue
            }
            if ($field.FieldName -eq "Password")
            {
                $Password = $field.itemvalue
            }
        }
        
        return @{ Result="Success"; Username=$Username; Password=$Password }
    } catch {
        return @{ Result=$_.Exception.Message }
    }
}
