<#
//---------------------------------------------------------------------------
// Google CAS Import.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2022 Venafi, Inc. All rights reserved.
//
// This software is licensed by Venafi.
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

# api reference
# https://cloud.google.com/certificate-authority-service/docs/reference/rest/v1/projects.locations.caPools.certificates/list

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# TODO:
# determine a better value for TransactionId and implement checking

<#
#################################################################################################
.NAME
    Import-Certificates
.DESCRIPTION
    Imports certificates from Google Cloud Certificate Authority Service
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        AuxPass : string value of the password credential that holds the DigiCert API Key
        ServiceAddress: URI, IP address or FQDN of the service you want to connect to
        ProfileString: String, can be delimited, which identifies product or profile associated with the service
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        IncludeRevoked : boolean value indicating whether the job says to include revoked certificates
        IncludeExpired : boolean value indicating whether the job says to include expired certificates
        LastJobStarted : datetime value that indicates when the previous import job started
        LastProcessedId : string value with the ID of the last certificate that was previously imported by the job
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
#################################################################################################
#>

function Import-Certificates {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory = $true, HelpMessage = "Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    Invoke-FunctionInit -Name $PSCmdlet.MyInvocation.InvocationName -BoundParameter $PSBoundParameters
    $allCerts = [System.Collections.Generic.List[object]]::new()

    try {

        # username has the key json with a placeholder for the private key
        # password is the private key itself
        $authJson = $General.UserName -replace '{{PRIVATE_KEY}}', $General.UserPass
        $auth = $authJson | ConvertFrom-Json

        # use google .net libraries to get an access token
        @(
            'Newtonsoft.Json',
            'Google.Apis.Core'
            'Google.Apis'
            'Google.Apis.Auth'
        ) | ForEach-Object { [System.Reflection.Assembly]::LoadWithPartialName($_) }

        $gCred = [Google.Apis.Auth.OAuth2.GoogleCredential]::FromJson(($authJson))
        $gScopedCred = $gcred.CreateScoped('https://www.googleapis.com/auth/cloud-platform')
        $accessToken = $gScopedCred.UnderlyingCredential.GetAccessTokenForRequestAsync().Result

        $projectName = $auth.project_id

        # get all ca pools in this project
        # a location of '-' represents all locations
        $caPools = Invoke-AdaptableRestMethod -UriLeaf "projects/$projectName/locations/-/caPools" -AccessToken $accessToken | Select-Object -ExpandProperty caPools

        foreach ($caPool in $caPools) {
            do {

                $uriLeaf = '{0}/certificates' -f $caPool.name

                # nextPageToken is only returned if there are more certs
                if ( $certs.nextPageToken ) {
                    $uriLeaf += '?pageToken={0}' -f $certs.nextPageToken
                }

                $certs = Invoke-AdaptableRestMethod -UriLeaf $uriLeaf -AccessToken $accessToken

                foreach ($cert in $certs.certificates) {

                    $addMe = $true

                    if ( -not $Specific.IncludeRevoked -and $cert.revocationDetails ) {
                        $addMe = $false
                    }

                    if ( -not $Specific.IncludeExpired -and $cert.certificateDescription.subjectDescription.notAfterTime -lt (Get-Date) ) {
                        $addMe = $false
                    }

                    if ( $addMe ) {
                        $allCerts.Add(
                            @{
                                PEM           = $cert.pemCertificate
                                Name          = $cert.name.split('/')[-1]
                                TransactionId = $cert.name.split('/')[-1]
                            }
                        )
                    }
                }
            } until (
                -not $certs.nextPageToken
            )
        }

        return @{
            Result          = 'Success'
            Certificates    = $allCerts.ToArray()
            LastProcessedId = $allCerts[$allCerts.Count - 1].TransactionId
        }

    } catch {
        $_ | Write-VenafiDebug
        throw $_
    }
}

<########## THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ##########>

function Invoke-AdaptableRestMethod {
    <#
        .SYNOPSIS
        Generic rest method function

        .DESCRIPTION
        Generic rest method function

        .PARAMETER Method
        API method, either get, post, patch, put or delete.

        .PARAMETER UriLeaf
        Path to the api endpoint excluding the base url and site, eg. certificates/import

        .PARAMETER Header
        Optional additional headers.

        .PARAMETER Body
        Optional body to pass to the endpoint

        .INPUTS
        None

        .OUTPUTS
        PSCustomObject
        #>

    [CmdletBinding()]

    param (

        [Parameter()]
        [ValidateSet("Get", "Post", "Put", "Delete")]
        [String] $Method = 'Get',

        [Parameter()]
        [String] $UriRoot = 'v1',

        [Parameter(Mandatory)]
        [String] $AccessToken,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $UriLeaf,

        [Parameter()]
        [Hashtable] $Body
    )

    $params = @{
        Method          = $Method
        Uri             = 'https://privateca.googleapis.com/{0}/{1}' -f $UriRoot, $UriLeaf
        ContentType     = 'application/json'
        UseBasicParsing = $true
        Headers         = @{
            'Authorization' = "Bearer $AccessToken"
        }
    }

    if ( $Body ) {
        $restBody = $Body
        switch ($Method.ToLower()) {

            'get' {
                $params.Body = $restBody
            }

            Default {
                $restBody = ConvertTo-Json $Body -Depth 20 -Compress
                $params.Body = $restBody
            }
        }
    }

    $params | Write-VenafiDebug

    $response = Invoke-WebRequest @params | Select-Object -ExpandProperty Content | ConvertFrom-Json

    Write-VenafiDebug -Message ($response | Format-List)

    $response

}

function Write-VenafiDebug {

    # write info to the debug log excluding any secret info

    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject] $Message
    )

    $newMessage = $Message
    if ( $newMessage.GetType().Name -eq 'Hashtable' ) {
        $newMessage = $Message.Clone()
        'UserPass', 'AuxPass', 'PfxPass', 'Certificate', 'PfxData', 'Headers' | ForEach-Object {
            if ( $newMessage[$_] ) {
                $newMessage[$_] = '***hidden***'
            }
        }
        $newMessage = $newMessage | ConvertTo-Json -Depth 5
    }

    if ( $global:DEBUG_FILE ) {
        ('{0} : {1}' -f (Get-Date), ($newMessage | Out-String)) | Out-File -FilePath $global:DEBUG_FILE -Encoding 'UTF8' -Append
    }
}

function Invoke-FunctionInit {

    # write debug logging info and set the General details for the current function to be used in other functions

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter()]
        [hashtable] $BoundParameter
    )

    process {
        $Name | Write-VenafiDebug

        $BoundParameter.General | Write-VenafiDebug

        if ( $BoundParameter.Specific ) {
            $BoundParameter.Specific | Write-VenafiDebug
        }

    }
}
