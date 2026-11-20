<#
//---------------------------------------------------------------------------
// Adaptable App Loopback.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2023 Venafi, Inc. All rights reserved.
//
// This software is licensed by IDMWORKS LLC, in addition to Venafi.
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
 


<field name>|<label text>|<flags>

Bit 1 = Enabled
Bit 2 = Policyable
Bit 3 = Mandatory

-----BEGIN FIELD DEFINITIONS-----
Text2|Scope|110
Text3|SSL Validty Days|110
-----END FIELD DEFINITIONS-----
#>


add-type @"
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

# below are the different functions for enumerating and managing the certificates in the adaptable framework
<######################################################################################################################
.NAME
    Discover-Certificates
.DESCRIPTION
    remotely onboard and discover certificates in the target Ping Identity platform. This is usually used as part of onboarding
    and discovery jobs to enumerate certificates in the platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Discover-Certificates)
        scope (VarText2) : should be either ssl or signing so knows which cmdlet to use since are different keystores in Ping identity
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        Certificate(s) : list of certificates (with the below valies) to be returned as part of the application
            CertificateId: ping id for the certificate
            SerialNumber: serial number of the certificate
            SubjectDn: cert subject
            SubjectAlternativeNames: subject alternative names of the certificates
            IssuerDn: issuer dn of the cert
            ValidFrom: valid from date
            Expires: expiration date
            KeyAlgorithm: key algorith
            KeySize: size of the key
            SignatureAlgorith: 
            Version:
            Sha1Fingerprint: 
            Sha256Fingerprint:
            Status: should be valid or expired
            RotationSettings: 
######################################################################################################################
#>

function Discover-Certificates
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Function Specific Parameters")] #specific is not needed for the Discover-Certificate function so is set to optional
        [System.Collections.Hashtable]$Specific
    )

    #need to get variables out of $general so they can be used elsewhere in the script due to the PS7 checking / validation
    $env:HostAddress = $General.HostAddress
    $env:UserName = $General.UserName
    $env:UserPass = $General.UserPass
    $env:Scope = $General.VarText2

    
    #main runtime of the method
    try {
        
        Logger -Message "Running the certificate list command"

        #set the secure string for the password
        $SecurePass
        if ($env:UserPass) {
            $SecurePass = ConvertTo-SecureString $env:UserPass -AsPlainText -Force
        } else {
            throw "Missing user password"
        }

        $result
        switch ( $env:Scope )
        {
            "ssl" 
            {
                #is in the ssl scope, so run the ssl key enumeration
                Logger -Message "In the scope of the ssl key discovery"
                #$result = Get-SslKeyPairs -Server $env:HostAddress -Username $env:UserName -Password $SecurePass -AllowInsecureRequest
                $result = getCertIds -Username $env:Username -Passwd $env:UserPass -HostAddress $env:HostAddress -certScope $env:Scope
                Logger -Message "Successfully ran the search with the result size of $($result.length)"
            }
            "signing"
            {
                Logger -Message "In the scope of the signing cert discovery"
                #$result = Get-SigningKeyPairs -Server $env:HostAddress -Username $env:UserName -Password $SecurePass -AllowInsecureRequest
                $result = getCertIds -Username $env:Username -Passwd $env:UserPass -HostAddress $env:HostAddress -certScope $env:Scope
                Logger -Message "Successfully ran the search with the result size of $($result.length)"
            }
            default {
                Logger -Message "The scope $($env:Scope) is not a valid scope so no results will be returned" -Severity "WARN"
                throw "Incorrect scope for certificates specified.  Scope is $($env:Scope)"
            }
        }

        $appList = [System.Collections.ArrayList]@()

        if ($result) {
            # have values so parse and add to the return list so can be returned
            Logger -Message "have results, adding to the cert list object"

            #loop through each certiicate and add it to the list
            foreach ($cert in $result) {
                if ($cert.id) {
                    Logger -Message "Adding the certid $($cert.id) to the return list"
                    Logger -Message $cert
                    $certObject = @{}
                    $certObject["Text Field 2"] = $env:Scope

                    #get the cert details from ping so can be added to the PEM return object for reference
                    Logger -Message "Getting the certificate pem for $($cert.id)" -Severity "INFO"
                    [String]$certPem = getCertObject -Username $env:Username -Passwd $env:UserPass -HostAddress $env:HostAddress -certificateId $cert.id -certScope $env:Scope
                    
                    $appObject = @{}
                    $appObject["Name"] = $cert.id
                    $appObject["ApplicationClass"] = "Adaptable App"
                    $appObject["PEM"] = $certPem
                    $appObject["Attributes"] = $certObject

                    $appList.add($appObject) # add to the return
                    Logger -Message "Successfully added the cert with certID $($cert.id) to the return list"
                }
            }
            Logger -Message "Completed iterating over the cert list for the return object"

        } else {
            Logger -Message "No result returned, returning a success with an empty return set"
        }
    
        return @{ Result="Success"; Applications=$appList.ToArray() }
    }
    catch {
        Logger -Message "Was an exception in the discovery" -Severity "ERROR"
        Logger -Message $_.ToString() -Severity "ERROR"
        throw "Error with discovery, check logs"
        return @{ Result= $_.ToString() }
    }
    
    Logger -Message "Completed the discover certificates function, exiting the run of the program" -Severity "INFO"
    return $retValue
}

<######################################################################################################################
.NAME
    Activate-Certificate
.DESCRIPTION
    This activates an installed certificate in the Ping platform.  This is only for sp / idp mappings of certifcate.  The
    Update-Binding function will handle the ssl runtime / administrator interfaces with the ssl key info.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Activate-Certificate)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
        
######################################################################################################################
#>
function Activate-Certificate 
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General

    )
	
	return @{ Result="NotUsed" }


}

<######################################################################################################################
.NAME
    Extract-Certificate
.DESCRIPTION
    This is used to get the certification information from ping once it has been loaded.  This is a final verification 
    step that is needed to complete / validate the certificate install operations.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Extract-Certificate)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Extract-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific

    )

    try {
        # this is the main logger / runtime to get the certificate from ping.

        # get the password / login information first from the parameters
        $SecurePass
        if ($General.UserPass) {
            $SecurePass = ConvertTo-SecureString $General.UserPass -AsPlainText -Force
        } else {
            throw "Missing user password"
        }

        #now go get the certificate information from ping and return the thumbprint / pem object in the return so can be validated
        # just need to get the certificate object based on the id from the input objects then can return the pem
        Logger -Message "Extracting the certificate to be returned with certid $($General.AssetName) from ping"
        [String]$certPEM = getCertObject -Username $General.UserName -Passwd $General.UserPass -HostAddress $General.HostAddress -certificateId $General.AssetName -certScope $General.VarText2

        Logger -Message "Completed getting the certificate information from Ping"
        Logger -Message "$($certPEM)"

        Logger -Message "Setting up the return object / success to be validated"

        return @{ Result="Success"; CertPEM=$certPEM }

        # all done processing at this point
        
    } catch {
        # is an exception in getting the certificate information from the store
        Logger -Message "Error extracting the certification from ping" -Severity "ERROR"
        throw "Exception in processing the extraction from ping, check the error for more details"
        return @{ Result=$_.ToString() }
    }
	
	# add logic here to get the current certificate info so can be used in the validate cert information
	
}

<######################################################################################################################
.NAME
    Extract-PrivateKey
.DESCRIPTION
    <not used> - here for general info
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Extract-PrivateKey)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Extract-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific

    )

    return @{ Result="NotUsed" }
}

<######################################################################################################################
.NAME
    Generate-Keypair
.DESCRIPTION
    <not used> - this is not used since the generate-csr method will do the same
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Generate-Keypair)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Generate-Keypair
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific

    )

    return @{ Result="NotUsed" }
}

<######################################################################################################################
.NAME
    Generate-CSR
.DESCRIPTION
    This is used to generate a new keypair in Ping and get a CSR for that keypair.
    
    doc-ref: https://docs.venafi.com/Docs/current/TopNav/Content/Drivers/r-drivers-AdaptableApp-function-Generate-CSR.php?tocpath=TLS%20Protect%7CCertificate%20Authority%20and%20Hosting%20Platform%20Integration%20Guide%7CProtecting%20server%20platforms%20and%20keystores%7CAdaptable%20Application%7CPowerShell%20script%20reference%20for%20Adaptable%20Application%7C_____8
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Generate-CSR)
        scope: this is the scope of the cert store to use.  This has to be either ssl or signing
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
    This will contain a list of certificate specific items that are required for the CSR.
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Generate-CSR
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific

    )

    #start the mainruntime of the generating the csr in the target ping environment
    #main runtime of the method
    try {
        #run the certificate command to get the data back
        Logger -Message "Running the certificate create / csr operations so can get it signed by Venafi platform"

        #set the secure string for the password
        $SecurePass
        if ($General.UserPass) {
            $SecurePass = ConvertTo-SecureString $General.UserPass -AsPlainText -Force
        } else {
            throw "Missing user password"
        }

        # have the setup done, time to start processing the request.
        Logger -Message "Starting the generation of the CSR in the Ping Identity platform."
		
		foreach ($h in $Specific.GetEnumerator()) {
            Logger -Message "$($h.Name) : $($h.Value)"
        }

        #first thing to do is to set the variables / values that are going to be used in generating the certifcate in Ping
        $certInfo = $Specific.SubjectDn # this is a hashtable of data that is applied for the cert
        if ($certInfo) {
            # have cert info so can proceed
            Logger -Message "valid certificate info is provided with values of $($certInfo)"
        } else {
            #cert info is blank so throw an exception
            throw "Certificate info is blank for the CSR"
        }

        #get any subject alternative names
        $certSANInfo = $Specific.SubjAltNames

        Logger -Message "Starting the cert operations"
        # have the info, the first thing that needs to happen is going to be generating the cert in Ping with the required values / get the cert Id back

        #first thing to do is to generate the new certificate and get the certificate id return object
        Logger -Message "Generating a new certificate in the $($General.VarText2) key store"
        [String]$certID = generateNewCert -SubjectDn $certInfo -SANInfo $certSANInfo -certScope $General.VarText2 -HostAddress $General.HostAddress `
            -Passwd $General.UserPass -certLifetime $General.VarText3 -Username $General.UserName
        Logger -Message "Successfully generated the new cert with ID of $($certID), now getting the CSR object"
        #clean up the ID since may contain whitespace
        $certID = $certID.Trim()
        #now get the csr object from ping
        [String]$retCSR = getCertCSR -Username $General.UserName -Passwd $General.UserPass -HostAddress $General.HostAddress -certScope $General.VarText2 `
            -certificateId $certID
			
		Logger -Message "retCSR from Generate-CSR function:$($retCSR)"
				

        #now, just generate the return object and complete the request
        return @{ Result="Success"; Pkcs10=$retCSR; AssetName=$certID }
        
    } catch {
        # was an exception in the processing so log it and throw an exception
        Logger -Message "Was an exception in processing the CSR in Ping." -Severity "ERROR"
        Logger -Message "Exception: $($_.ToString())" -Severity "ERROR"
        throw "Exception in processing the CSR generation, check logs for more details"
        return @{ Result= $_.ToString() }
    }

}

<######################################################################################################################
.NAME
    Install-Chain
.DESCRIPTION
    <not used> - this is not used since the CSR should have the cert chain already assigned.  FYI, this might be a future enhancement
    if needed to install the root cert in Ping / update it.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Install-Chain)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Install-Chain
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific

    )

    return @{ Result="NotUsed" }
}

<######################################################################################################################
.NAME
    Install-PrivateKey
.DESCRIPTION
    <not used> - this is not used since the generate-csr generates a private key in the platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Install-PrivateKey)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Install-PrivateKey
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific

    )

    return @{ Result="NotUsed" }
}

<######################################################################################################################
.NAME
    Install-Certificate
.DESCRIPTION
    This will take the CSR response and reply to / install the certificate once it has been assigned / completed.  Additionally,
    this could be used to generate / overwrite an existing certificate if it is just being resigned / renewed instead of rotating
    it thoruhg normal processes
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Install-Certificate)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Install-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific

    )

    #start adding the csr / certificate response that was generated operations
    try {
        
        #run the certificate command to install the csr response
        Logger -Message "Running the certificate install from the csr operation that was completed"

        #set the secure string for the password
        $SecurePass
        if ($General.UserPass) {
            $SecurePass = ConvertTo-SecureString $General.UserPass -AsPlainText -Force
        } else {
            throw "Missing user password"
        }

        #first thing that needs to be done is to get a base64 encoded value for the PEM to pass into the command
        #need to combine the actual cert and the chain into a single pem object for the response
        $certChain = "$($Specific.CertPem)`n$($Specific.ChainPem)"
        $encodedPem = b64EncodeCert -certPEM $certChain

        #start the main processing operations
        Logger -Message "Starting the certificate / CSR response import process to mark the certificate signed"

        switch ($General.VarText2) {
            "ssl" {
                Logger -Message "Importing the certificate response to the ssl keystore"

                $importCertResponse = importCSRResponse -Username $General.UserName -Passwd $General.UserPass -HostAddress $General.HostAddress -certificateId $General.AssetName -certScope $General.VarText2 -encodedCertPEM $encodedPem

                if ($importCertResponse.responseCode -eq 200) {
                    Logger -Message "Successfully imported the CSR response with certificate ID $($General.AssetName)"
                    return @{ Result="Success" }
                } else {
                    Logger -Message "Was not a success import response and has a status code of $($importCertResponse.responseCode)"
                    return @{ Result="ERROR" }
                }
                
            }
            "signing" {
                Logger -Message "Importing the certificate response to the signing keystore"

                $importCertResponse = importCSRResponse -Username $General.UserName -Passwd $General.UserPass -HostAddress $General.HostAddress -certificateId $General.AssetName -certScope $General.VarText2 -encodedCertPEM $encodedPem

                if ($importCertResponse.responseCode -eq 200) {
                    Logger -Message "Successfully imported the CSR response with certificate ID $($General.AssetName)"
                    return @{ Result="Success" }
                } else {
                    Logger -Message "Was not a success import response and has a status code of $($importCertResponse)"
                    return @{ Result="ERROR" }
                }

            }
            default {
                Logger -Message "The scope value of $($General.VarText2) is not a valid ssl/signing scope, please check the operations" -Severity "ERROR"
                throw "Incorrect cert scope provided"
            }
        }

    } catch {
        Logger -Message "Was an exception in the install certificate processing" -Severity "ERROR"
        Logger -Message "Exception Message: $($_.ToString())"
        throw "Exception in install certificate"
    }
    
}

<######################################################################################################################
.NAME
    Prepare-Keystore
.DESCRIPTION
    <not used> - this is not used since the discovery gets this info and the keystore is already placed / running inside 
    of the ping platform
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Prepare-Keystore)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Prepare-Keystore
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$false,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific

    )

    return @{ Result="NotUsed" }
}

<######################################################################################################################
.NAME
    Remove-Certificate
.DESCRIPTION
    This function will review the certificate based on the certificateId or serial number.  Be sure that the certificate
    is not referenced by anything before trying to remove it or will fail.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Remove-Certificate)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Remove-Certificate
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    )

    # delete the certificate from the appropriate store
    try {
        #module is imported, start the main run of the program

        #run the certificate command to delete te certificate
        Logger -Message "Running the certificate delete operation"

        #set the secure string for the password
        $SecurePass
        if ($General.UserPass) {
            $SecurePass = ConvertTo-SecureString $General.UserPass -AsPlainText -Force
        } else {
            throw "Missing user password"
        }

        # have the info, start the main run
        Logger -Message "Issuing the delete cert comamnd for Id $($General.AssetName) for the scope $($General.VarText2)"
        $deleteResponse = deleteCertificate -Username $General.UserName -Passwd $General.UserPass -HostAddress $General.HostAddress -certificateId $General.AssetName -certScope $General.VarText2
        Logger -Message "Successfully issued the delete command"
        if ($deleteResponse.responseCode -eq 204) {
            Logger -Message "The delete was success for cert id $($General.AssetName)"
            return @{ Result="Success" }
        } else {
            Logger -Message "Did not get a success message for the delete with response code of $($deleteResponse.responseCode)" -Severity "ERROR"
            return @{ Result="ERROR" }
        }

    } catch {
        Logger -Message "Was an exception in the delete certificate processing" -Severity "ERROR"
        Logger -Message "Exception Message: $($_.ToString())"
        throw "Exception in delete certificate"
    }

    
}

<######################################################################################################################
.NAME
    Update-Binding
.DESCRIPTION
    This function is used to update certificate runtime assignments in ssl (runtime / administrator interfaces)
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Update-Binding)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        
.NOTES
    Returns...
        Result : 'Success' or 'NotUsed' to indicate the non-error completion state
######################################################################################################################
#>

function Update-Binding
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General

    )

    return @{ Result="NotUsed" }
}




#####################################FUNCTIONS BLOCK TO BE SHARED########################################################
<#
    This is a shared functions file to support the adaptable framework functions.  This is helpful tools to be reused in the different functions

#>
# this is a general logger function to help / make things pretty
function Logger {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$Severity="INFO" #default level is INFO for all logging if not set
    )

        $CurrentTimeStamp = Get-Date -f s
        $OutMessage = "$CurrentTimeStamp|$Severity|$Message"
        
        #do a switch for the severities for highlighting of the output
        switch ($Severity) {
            'INFO' {
                Write-host $OutMessage
            }
            'WARN' {
                Write-Host $OutMessage -ForegroundColor Yellow
            }
            'ERROR' {
                Write-host $OutMessage -ForegroundColor Red
            }
        }

        # check if debug file is specified, if so, then will dump to the file for debug purposes
        if ($DEBUG_FILE) {
            $OutMessage | Out-File -Append -FilePath $DEBUG_FILE
        }

}

# this is an encoding function to encode logins for additional calls that may be needed to ping federate
function b64Encode {
    Param(
        [Parameter(Mandatory=$true,HelpMessage="username to encode")]
        [string]$Username,
        [Parameter(Mandatory=$true,HelpMessage="password to encode")]
        [string]$Passwd
    )

    #encode the string and return it
    $Text = $Username + ":" + $Passwd
    $EncodedText = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($Text))
    return $EncodedText

}

# this will base64 encode the certificate pem data
function b64EncodeCert {
    Param(
        [Parameter(Mandatory=$true,HelpMessage="the cert pem / response data to encode")]
        [string]$certPEM
    )

    #encode the string and return it
    Logger -Message "Encoding the certificate data to post back to Ping"
    $EncodedText = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($certPEM))
    return $EncodedText

}

# this function will get the list of certificates from the keystore so they can be discovered / sent back as part of a discovery operation
function getCertIds {
    param (
        [Parameter(Mandatory=$true,HelpMessage="username to ping")]
        [string]$Username,
        [Parameter(Mandatory=$true,HelpMessage="password to ping")]
        [string]$Passwd,
        [Parameter(Mandatory=$true,HelpMessage="Host address for the ping in the format https://<hostname>:<port>")]
        [string]$HostAddress,
        [Parameter(Mandatory=$true,HelpMessage="Should be signing or ssl for the scope")]
        [ValidateSet('ssl', 'signing')]
        [string]$certScope
    )

    # set the scope of the URL to use based on ssl or signing cert path to do the discovery in
    $signingCertPath = '/pf-admin-api/v1/keyPairs/signing'
    $sslCertPath = '/pf-admin-api/v1/keyPairs/sslServer'


    #set the credential object to use in the header
    $encodedString = b64Encode -Username $Username -Passwd $Passwd
    $bearerToken = "Basic " + $encodedString

    #setup the header object to be passed in the invoke web-request method
    $headers = @{}
    $headers['Authorization'] = $bearerToken
    $headers['X-XSRF-Header'] = 'PingFederate'
    $headers['accept'] = 'application/json'

    #this is the list of return certificates for the scope from Ping Federate
    $retCerts = @()
    try {
        $uri
        switch ($certScope) 
        {
            "ssl" {
                Logger -Message "Using the ssl server scope for the certificate id scope of the discovery" -Severity "INFO"
                $uri = $HostAddress + $sslCertPath
                continue
            }
            "signing" {
                Logger -Message "Using the signing server scope for the certificate id scope of the discovery" -Severity "INFO"
                $uri = $HostAddress + $signingCertPath
                continue
            }
            default {
                Logger -Message "Invalid scope was defined with a value of $($certScope) which is not ssl or signing scope" -Severity "ERROR"
                throw "Invalid scope specified in the discovery settings for the cert discovery"
            }
        }

        #have the settings setup, now time to run the discovery and return each of the certificate objects
        Logger -Message "all setup, running the discovery of certificates in Ping" -Severity "INFO"
        $result = Invoke-WebRequest -URI $uri -Headers $headers
        if ($result.StatusCode -eq 200) {
            Logger -Message "Successfully pulled list of certificates from Ping" -Severity "INFO"

            #parse the json response so can start going through them
            $certList = ConvertFrom-Json $result.Content

            #have the list parsed, now time to go through each item in the list and get the data
            foreach ($cert in $certList.items) {
                $retCert = @{}
                $retCert['id'] = $cert.id
                $retCert['serialNumber'] = $cert.serialNumber
                $retCert['subjectDN'] = $cert.subjectDN

                $retCerts += $retCert
                Logger -Message "Added the cert with ID $($cert.id) to the list of return certs for the parsing" -Severity "INFO"
                
            }

            Logger -Message "All done with processing all the returned results for the certificate listing / discovery" -Severity "INFO"

        } else {
            Logger -Message "Did not get a success response from ping.  The return status code is $($result.StatusCode)" -Severity "WARN"
            Logger -Message "returning and empty result set" -Severity "WARN"
        }

    } catch {
        Logger -Message "Was an exception getting the certificate list of ping federate" -Severity "Error"
        Logger -Message $_.ToString() -Severity "ERROR"
        throw "Error getting certificate list from ping federate"
    }

    Logger -Message "All done with the certificate discovery / listing, returning the list of certificate objects" -Severity "INFO"
    return $retCerts

}

# this function will get the cert raw public object from ping from the api
function getCertObject {
    param (
        [Parameter(Mandatory=$true,HelpMessage="username to ping")]
        [string]$Username,
        [Parameter(Mandatory=$true,HelpMessage="password to ping")]
        [string]$Passwd,
        [Parameter(Mandatory=$true,HelpMessage="Host address for the ping in the format https://<hostname>:<port>")]
        [string]$HostAddress,
        [Parameter(Mandatory=$true,HelpMessage="certificate ID to get from Ping")]
        [string]$certificateId,
        [Parameter(Mandatory=$true,HelpMessage="Should be signing or ssl for the scope")]
        [ValidateSet('ssl', 'signing')]
        [string]$certScope
    )

    #set some basic variables for the call to ping
    $signingCertPath = "/pf-admin-api/v1/keyPairs/signing/$($certificateId)/certificate"
    $sslCertPath = "/pf-admin-api/v1/keyPairs/sslServer/$($certificateId)/certificate"

    #set the credential object to use in the header
    $encodedString = b64Encode -Username $Username -Passwd $Passwd
    $bearerToken = "Basic " + $encodedString

    #setup the header object to be passed in the invoke web-request method
    $headers = @{}
    $headers['Authorization'] = $bearerToken
    $headers['X-XSRF-Header'] = 'PingFederate'
    $headers['accept'] = 'application/json'

    $retCert
    #get the cert object
    try {
        switch ($certScope)
        {
            "ssl" {
                Logger -Message "Getting the certificate $($certificateId) from the ssl keystore"
                $uri = $HostAddress + $sslCertPath

                #invoke the web request
                # this dumps a temporary cert into the file system which gets remove when done
                #$request = Invoke-WebRequest -Passthru -UseBasicParsing -URI $uri -Headers $headers -OutFile 'tempcert.cer'
                $request = Invoke-WebRequest -UseBasicParsing -URI $uri -Headers $headers
                if ($request.StatusCode -eq 200) {
                    $pem = $request.RawContent
                    $index = $pem.IndexOf("-----BEGIN CERTIFICATE-----")
                    $pem = $pem.Substring($index)
                    $indexstop = $pem.IndexOf("-----END CERTIFICATE-----") + 26
                    $pem = $pem.Substring(0,$indexstop)
                    $retCert = $pem
                    Logger -Message "Successfully pulled the ssl cert object from Ping and set the return object"
                } else {
                    #did ot get a valid response
                    Logger -Message "Did not get a valid response from the server when trying to get the certificate.  The status code is $($request.StatusCode)" -Severity "WARN"
                }

                #clean up / remove file if is present so is not left around
                if (Test-Path -Path .\tempcert.cer) {
                    Remove-Item .\tempcert.cer
                }

                Logger -Message "completed getting the detailed ssl cert from ping"
                return $retCert

            }
            "signing" {

                Logger -Message "Getting the certificate $($certificateId) from the signing keystore"
                $uri = $HostAddress + $signingCertPath

                #invoke the web request
                # this dumps a temporary cert into the file system which gets remove when done
                $request = Invoke-WebRequest -UseBasicParsing -URI $uri -Headers $headers
                if ($request.StatusCode -eq 200) {
                    $pem = $request.RawContent
                    $index = $pem.IndexOf("-----BEGIN CERTIFICATE-----")
                    $pem = $pem.Substring($index)
                    $indexstop = $pem.IndexOf("-----END CERTIFICATE-----") + 26
                    $pem = $pem.Substring(0,$indexstop)
                    $retCert = $pem
                    Logger -Message "Successfully pulled the signing cert object from Ping and set the return object"
                } else {
                    #did ot get a valid response
                    Logger -Message "Did not get a valid response from the server when trying to get the certificate.  The status code is $($request.StatusCode)" -Severity "WARN"
                }

                #clean up / remove file if is present so is not left around
                if (Test-Path -Path .\tempcert.crt) {
                    Remove-Item .\tempcert.crt
                }

                Logger -Message "completed getting the detailed ssl cert from ping"
                return $retCert
            }
        }
    } catch {
        Logger -Message "Was an exception getting the certificate object from Ping" -Severity "Error"
        Logger -Message $_.ToString() -Severity "ERROR"
        throw "Error getting cert object from ping"
    }

    #all done the function at this point

}

# this function imports the signing / ssl csr response
function importCSRResponse {
    param (
        [Parameter(Mandatory=$true,HelpMessage="username to ping")]
        [string]$Username,
        [Parameter(Mandatory=$true,HelpMessage="password to ping")]
        [string]$Passwd,
        [Parameter(Mandatory=$true,HelpMessage="Host address for the ping in the format https://<hostname>:<port>")]
        [string]$HostAddress,
        [Parameter(Mandatory=$true,HelpMessage="certificate ID to get from Ping")]
        [string]$certificateId,
        [Parameter(Mandatory=$true,HelpMessage="Should be signing or ssl for the scope")]
        [ValidateSet('ssl', 'signing')]
        [string]$certScope,
        [Parameter(Mandatory=$true,HelpMessage="this is the encoded certificate response so can be added to the cert response body")]
        [string]$encodedCertPEM
    )

    #setup the paths to use
    $sslImportPath = "/pf-admin-api/v1/keyPairs/sslServer/$($certificateId)/csr"
    $signingImportPath = "/pf-admin-api/v1/keyPairs/signing/$($certificateId)/csr"

    # the json body is the same for both so can set that up here
    $body = @{
        "fileData" = $encodedPEM
    }

    $bodyJson = $body | ConvertTo-JSON

    #set the credential object to use in the header
    $encodedString = b64Encode -Username $Username -Passwd $Passwd
    $bearerToken = "Basic " + $encodedString

    #setup the header object to be passed in the invoke web-request method
    $headers = @{}
    $headers['Authorization'] = $bearerToken
    $headers['X-XSRF-Header'] = 'PingFederate'
    $headers['accept'] = 'application/json'

    Logger -Message "Startign the CSR import / response"

    try {
        $uri
        switch ($certScope) {
            "ssl" {
                $uri = $HostAddress + $sslImportPath
            }
            "signing" {
                $uri = $HostAddress + $signingImportPath
            }
            default {
                Logger -Message "Incorrect scope of $($certScope) specified for the import" -Severity "ERROR"
                throw "Incorrect cert scope specified"
            }
        }

        Logger -Message "importing the $($certScope) csr response with id $($certificateId)"

        #post the response to the endpoint
        $importResponse = Invoke-WebRequest -URI $uri -Headers $headers -ContentType "application/json" -Method POST -Body $bodyJson

        if ($importResponse.StatusCode -eq 200) {
            Logger -Message "Successfully imported the response with a status code of $($importResponse.StatusCode)"
        } else {
            Logger -Message "did not successfully import with a status code of $($importResponse.StatusCode)" -Severity ERROR
        }

        return @{ responseCode=$importResponse.StatusCode }
    } catch {
        Logger -Message "Was an exception in the csr response import" -Severity "ERROR"
        Logger -Message "Excpeption: $($_.ToString())" -Severity "ERROR"
        throw "Expception posting csr response"
    }
}

# this function will delete a certificate in Ping based on the cert ID
function deleteCertificate {
    param (
        [Parameter(Mandatory=$true,HelpMessage="username to ping")]
        [string]$Username,
        [Parameter(Mandatory=$true,HelpMessage="password to ping")]
        [string]$Passwd,
        [Parameter(Mandatory=$true,HelpMessage="Host address for the ping in the format https://<hostname>:<port>")]
        [string]$HostAddress,
        [Parameter(Mandatory=$true,HelpMessage="certificate ID to get from Ping")]
        [string]$certificateId,
        [Parameter(Mandatory=$true,HelpMessage="Should be signing or ssl for the scope")]
        [ValidateSet('ssl', 'signing')]
        [string]$certScope
    )

    #setup the paths to use
    $sslDeletePath = "/pf-admin-api/v1/keyPairs/sslServer/$($certificateId)"
    $signingDeletePath = "/pf-admin-api/v1/keyPairs/signing/$($certificateId)"

    #set the credential object to use in the header
    $encodedString = b64Encode -Username $Username -Passwd $Passwd
    $bearerToken = "Basic " + $encodedString

    #setup the header object to be passed in the invoke web-request method
    $headers = @{}
    $headers['Authorization'] = $bearerToken
    $headers['X-XSRF-Header'] = 'PingFederate'
    $headers['accept'] = 'application/json'

    Logger -Message "Starting the delete process for $($certScope) with id $($certificateId)"

    $uri
    switch ($certScope) {
        "ssl" {
            $uri = $HostAddress + $sslDeletePath
            Logger -Message "Setting the path for the ssl delete operation"
        }
        "signing" {
            $uri = $HostAddress + $signingDeletePath
            Logger -Message "Setting the path for the signing delete operation"
        }
        default {
            Logger -Message "The scope $($certScope) is not a valid ssl/signing scope"
            throw "Incorrent certificate scope"
        }
    }

    try {
        Logger -Message "Delete the certificate with ID $($certificateId)"
        $deleteResponse = Invoke-WebRequest -URI $uri -Headers $headers -SkipCertificateCheck -Method "DELETE"
        Logger -Message "Successfully sent the delete request"
        if ($deleteResponse.StatusCode -eq 204) {
            Logger -Message "Successfully deleted the certificate with id $($certificateId)"
        } else {
            Logger -Message "Certificate with id $($certificateId) was not deleted with the the status code $($deleteResponse.StatusCode)" -Severity "ERROR"
        }

        return @{ responseCode=$deleteResponse.StatusCode }
    } catch {
        Logger -Message "Was an exception in the delete operation" -Severity "ERROR"
        Logger -Message "Exception: $($_.ToString())" -Severity "ERROR"
        throw "Exception in delete operation"
    }
}

# this function will generate a new keycair and return the CSR to be signed by the venafi platform
function generateNewCert {
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Subject / cert info")]
        [System.Collections.Hashtable]$SubjectDn,
        [Parameter(Mandatory=$true,HelpMessage="SAN Info")]
        [System.Collections.Hashtable]$SANInfo,
        [Parameter(Mandatory=$true,HelpMessage="Scope")]
        [string]$certScope,
        [Parameter(Mandatory=$true,HelpMessage="username to ping")]
        [string]$Username,
        [Parameter(Mandatory=$true,HelpMessage="password to ping")]
        [string]$Passwd,
        [Parameter(Mandatory=$true,HelpMessage="Host address for the ping in the format https://<hostname>:<port>")]
        [string]$HostAddress,
        [Parameter(Mandatory=$true,HelpMessage="Cert lifetime in days")]
        [string]$certLifetime
    )

    # set the basic info for the request
    #set the credential object to use in the header
    $encodedString = b64Encode -Username $Username -Passwd $Passwd
    $bearerToken = "Basic " + $encodedString

    #setup the header object to be passed in the invoke web-request method
    $headers = @{}
    $headers['Authorization'] = $bearerToken
    $headers['X-XSRF-Header'] = 'PingFederate'
    $headers['accept'] = 'application/json'

    #set the URI / path of the request
    $uri
    $sslPath = "/pf-admin-api/v1/keyPairs/sslServer/generate"
    $signingPath = "/pf-admin-api/v1/keyPairs/signing/generate"

    switch ($certScope) {
        "ssl" {
            $uri = $HostAddress + $sslPath
            Logger -Message "Setting the path for the ssl cert generation operation"
        }
        "signing" {
            $uri = $HostAddress + $signingPath
            Logger -Message "Setting the path for the signing cert generation operation"
        }
        default {
            Logger -Message "The scope $($certScope) is not a valid ssl/signing scope"
            throw "Incorrect certificate scope"
        }
    }

    #set the request body
    $body = @{
        commonName=$SubjectDn.CN;
        subjectAlternativeNames=$SANInfo.DNS;
        organization=$SubjectDn.O;
        organizationUnit=$SubjectDn.OU;
        city=$SubjectDn.L;
        state=$SubjectDn.ST;
        country=$SubjectDn.C;
        validDays=$certLifetime;
        keyAlgorithm="RSA";
        keySize="2048";
        signatureAlgorithm="SHA256withRSA";
    }

    $bodyJson = $body | ConvertTo-Json
    Logger -Message "The body of the CSR request is:"
    Logger -Message "$($bodyJson)"

    #have things setup, now submitting the request to the service
    $retCert
    $request = Invoke-WebRequest -UseBasicParsing -URI $uri -Headers $headers -Body $bodyJson -ContentType "application/json" -Method POST
    if ($request.StatusCode -eq 201) {
        $certInfo = ConvertFrom-Json $request.Content
        $retCert = $certInfo.id
        Logger -Message "Successfully generated the new certificate request and returning to the function with an ID of $($retCert)"
    } else {
        #did ot get a valid response
        Logger -Message "Did not get a valid response from the server when trying to generate the cert.  The status code is $($request.StatusCode)" -Severity "WARN"
    }

    return $retCert
}

#this function gets the CSR for a certificate that was generated
function getCertCSR {
    param (
        [Parameter(Mandatory=$true,HelpMessage="username to ping")]
        [string]$Username,
        [Parameter(Mandatory=$true,HelpMessage="password to ping")]
        [string]$Passwd,
        [Parameter(Mandatory=$true,HelpMessage="Host address for the ping in the format https://<hostname>:<port>")]
        [string]$HostAddress,
        [Parameter(Mandatory=$true,HelpMessage="certificate ID to get from Ping")]
        [string]$certificateId,
        [Parameter(Mandatory=$true,HelpMessage="Should be signing or ssl for the scope")]
        [ValidateSet('ssl', 'signing')]
        [string]$certScope
    )


    # set the basic info for the request
    #set the credential object to use in the header
    $encodedString = b64Encode -Username $Username -Passwd $Passwd
    $bearerToken = "Basic " + $encodedString

    #setup the header object to be passed in the invoke web-request method
    $headers = @{}
    $headers['Authorization'] = $bearerToken
    $headers['X-XSRF-Header'] = 'PingFederate'
    $headers['accept'] = 'application/json'

    #set the URI / path of the request
    $uri
    $sslPath = "/pf-admin-api/v1/keyPairs/sslServer/$($certificateId)/csr"
    $signingPath = "/pf-admin-api/v1/keyPairs/signing/$($certificateId)/csr"

    switch ($certScope) {
        "ssl" {
            $uri = $HostAddress + $sslPath
            Logger -Message "Setting the path for the ssl cert csr operation"
        }
        "signing" {
            $uri = $HostAddress + $signingPath
            Logger -Message "Setting the path for the signing cert csr operation"
        }
        default {
            Logger -Message "The scope $($certScope) is not a valid ssl/signing scope"
            throw "Incorrent certificate scope"
        }
    }

    # have the info, now time to get the cert object back
    [string]$retCSR

    $request = Invoke-WebRequest -UseBasicParsing -URI $uri -Headers $headers
    if ($request.StatusCode -eq 200) {
        #need to get the csr object from the body of the response
        $csr = $request.RawContent
        $index = $csr.IndexOf("-----BEGIN NEW CERTIFICATE REQUEST-----")
        $csr = $csr.Substring($index)
        $indexstop = $csr.IndexOf("-----END NEW CERTIFICATE REQUEST-----") + 37
        $csr = $csr.Substring(0,$indexstop)
        $retCSR = $csr
		# remove "NEW" from the headers
        $retCSR = $retCSR.Replace("-----BEGIN NEW CERTIFICATE REQUEST-----", "-----BEGIN CERTIFICATE REQUEST-----")
        $retCSR = $retCSR.Replace("-----END NEW CERTIFICATE REQUEST-----", "-----END CERTIFICATE REQUEST-----")
		$retCSR = $retCSR.trim()
    } else {
        #did ot get a valid response
        Logger -Message "Did not get a valid response from the server when trying to generate the csr.  The status code is $($request.StatusCode)" -Severity "WARN"
    }

    Logger -Message "All done, returning the CSR back to the function"
    Logger -Message "retCSR from GetCertCSR function (bottom):$($retCSR)"
    return $retCSR
}