<#
//---------------------------------------------------------------------------
// CAAutoApproval.ps1
//---------------------------------------------------------------------------
// Copyright (c) 2020 Venafi, Inc. (“Venafi”). All rights reserved.
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
#>

<######################################################################################################################
DESCRIPTION
    CAAutoApproval is an Adaptaptable Workflow script created by Venafi Professional Services for Trust Protection Platform.

    This script enables TPP to evaluate the ObjectDN of a CA template to determine if a review of the certificate request
	(enrollment/renewal) is required.
	
######################################################################################################################

Custom Fields column definition
-------------------------------
<field name>|<label text>|<flags>

<field name>: Do not change
<label text>: This text will show up in the UI
<flags>:
    Bit 1 = Enabled
    Bit 2 = Mandatory


-----BEGIN FIELD DEFINITIONS-----
Text1|Certificate Template Macro ($Policy[$selfdn$, 'Certificate Authority']$)|11
Text2|Policy Folder DN for Auto-Approved CA Templates|11
Text3|Text Field #3|00
Text4|Text Field #4|00
Text5|Text Field #5|00
Text6|Text Field #6|00
Text7|Text Field #7|00
Text8|Text Field #8|00
Text9|Text Field #9|00
Text10|Text Field #10|00
Text11|Text Field #11|00
Text12|Text Field #12|00
-----END FIELD DEFINITIONS-----
#>

<######################################################################################################################
NAME
   Process
PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions.
        ServiceAddress : a string identifying the service endpoint (URL, host, port, etc) of the calling Adaptable Workflow object.
        UserName : a string containing the username portion of the credential assigned to the Adaptable Workflow object.
        UserPass : a string containing the password portion of the credential assigned to the Adaptable Workflow object.
        AuxUser : a string containing username portion of the secondary credential assigned to the Adaptable Workflow object.
        AuxPass : a string containing password portion of the secondary credential assigned to the Adaptable Worklfow object.
        AuxPfxData: a string containing pfx data of the secondary credential assigned to the Adaptable Workflow object.
PARAMETER Fields
    A hashtable containing the values specfic to conditions and actions related to Adaptable Workflow object.
        WorkflowDn : string representing the DN of the Adaptable Workflow object in TPP.
        ObjectDn  : string representing the DN of the object being processed.
        ObjectClassName : string representing the class type of the 'ObjectDn' being passed.
        RequestedBy : string representing the prefixed universal (universal name of an identity prefixed by the name) of the person who clicked 'Renew' on the cert or 'Push' on the application.
        CertificateVaultId : If the object type is certificate then this parameter will contain the certificate VaultID.
        TppWebSdkUrl : string representing the complete URL for the TPP WebSDK.
        WorkflowStage : The stage assigned to the Adaptable Workflow object.
        WorkflowApprovers : List of identities allowed to approve the ticket.
        WorkflowReason : The reason description assigned to the Adaptable Workflow object.
        ReferenceId : The Id sent by the script to TPP which TPP sends back in the subsequent go around.
PARAMETER CustomFields
    A hashtable containing all of the custom fields defined over Adaptable Workflow object. These fields are confifgured via the script.

NOTES
    Returns...
        Result : See Section 1 for possible status values.
        ReferenceID : ReferenceID sent by the enternal ticketing system only sent with 'Pause' status.
        SecondsToPause : Number of seconds to pause before calling the script again, again only sent with 'Pause' status.
        Details : Information about why a particular result status is being sent.
######################################################################################################################>

# Written only when debugging is enabled
'Debug logging is enabled' | Write-DebugLog

function Process
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Workflow Detail Parameters")]
        [System.Collections.Hashtable]$Fields,
        [Parameter(Mandatory=$true,HelpMessage="Custom Field Parameters, if defined")]
        [System.Collections.Hashtable]$CustomFields
    )
	
	"Process Started" | Write-DebugLog

    "Custom Field Parameters" | Write-DebugLog
    $CustomFields.getenumerator() |
      Sort-Object value -descending |
      format-table |
      out-string |
      Write-Log

   	# Section 1 - Return Variables - Do not change.
    Set-Variable -Name Rejected -Value Rejected -Option Constant
    Set-Variable -Name Approved -Value Approved -Option Constant
    Set-Variable -Name Pause -Value Pause -Option Constant
    Set-Variable -Name TicketRequested  -Value TicketRequested  -Option Constant

    # Section 2 - Write Custom Logic.
    $Result = @{}
	
    try {

		# Get Certificate Certificate Authority Template 
        $certAuth = $CustomFields.'Text 1'
        "Certificate Authority: $certAuth" | Write-DebugLog

        # Policy DN of Auto-Approved CA Templates
        $policyDN = $CustomFields.'Text 2'
        "Policy DN of Auto-Approved CA Templates: $policyDN" | Write-DebugLog
        		
		if ( $certAuth -eq $policyDN )
		{
			$details = "The CA template in the $policyDN folder does not require approval."
			$result = @{Result = "$Approved"; Details = $details}
		}
		else
		{
			$details = "The CA template is not in the $policyDN folder which requires approval."
			$result = @{Result = "$TicketRequested"; Details = $details}
		}

    } catch {
        throw $_.Exception
    }

    "Result: $details" | Write-DebugLog

    # Section 3 - Return Result. Strictly use values from Section 1.
    Return $result
}



<###################### THE FUNCTIONS AND CODE BELOW THIS LINE ARE NOT CALLED DIRECTLY BY VENAFI ######################>

function Write-DebugLog {
    [cmdletbinding()]
    Param(
        [parameter(ValueFromPipeline)]
        [string]$message
    )

    Process {
        if ($DEBUG_FILE) {
            "$(Get-Date): $_" | Out-File $DEBUG_FILE -Append
        }
    }
}
