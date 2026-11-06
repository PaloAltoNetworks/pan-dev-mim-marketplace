################################################################################
# File         FuturexCreateCustomFields.ps1                                   #
# Author:      Futurex <support@futurex.com>                                   #
#                                                                              #
# THIS SOFTWARE IS PROVIDED BY FUTUREX ''AS IS'' AND ANY EXPRESS OR IMPLIED    #
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF         #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO   #
# EVENT SHALL FUTUREX BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, #
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,          #
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;  #
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,     #
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR      #
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF       #
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                                   #
#                                                                              #
# Copyright by:  Futurex, LP. 2019                                             #
#                                                                              #
################################################################################

# "Configuration"
$SdkUri = "https://123456789.dev.lab.venafi.com"
$SdkUser = "local:Tppadmin"
$SdkPass = "S4f3st_P4ssw0rd"

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

# Authenticate
$Uri = "{0}/vedsdk/authorize/" -f $SdkUri

$Body = @{
    Username=$SdkUser;
    Password=$SdkPass
} | ConvertTo-Json;

$AuthParams = @{
    Uri = $Uri;
    Body = $Body;
    Method = "Post";
    ContentType = "application/json";
};

$ApiKey = (Invoke-RestMethod @AuthParams).APIKey

$Headers = @{
    "X-Venafi-Api-Key" = $ApiKey;
    "Content-Type" = "application/json"
};

# Create Custom Fields
$Items = @(
    @{
        Label = "Futurex: X.509 Extension Profile";
        Name = "Futurex: X.509 Extension Profile";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $true;
        Policyable = $true;
        RegularExpression = "^[A-Za-z0-9\s]*$";
        Help = "Name of the X.509 extension profile used for issuance";
    },
    @{
        Label = "Futurex: Approval Group";
        Name = "Futurex: Approval Group";
        Classes = @( "X509 Certificate" );
        Type = 1; # String
        Mandatory = $true;
        Policyable = $true;
        RegularExpression = "^[A-Za-z0-9\s]*$";
        Help = "Name of the approval group to place approvables into";
    }
);

$Uri = "{0}/vedsdk/metadata/defineitem" -f $SdkUri

foreach ($Item in $Items)
{
    $Body = @{
        Item = $Item
    } | ConvertTo-Json -Depth 4;

    Invoke-RestMethod `
        -Method Post `
        -Uri $Uri `
        -Headers $Headers `
        -Body $Body `
        -ContentType "application/json";
}