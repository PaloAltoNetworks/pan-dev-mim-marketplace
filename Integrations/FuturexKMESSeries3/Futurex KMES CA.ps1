<#
//---------------------------------------------------------------------------
// Futurex KMES CA.ps1
//
// Version 2.1.0
//---------------------------------------------------------------------------
// This software is licensed by Futurex, in addition to Venafi.
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

##################
# Version: 2.1.0 #
##################

#################
# Configuration #
#################

# Address of the KMES Host API
$global:ServerHost = "us01ca01.virtucrypt.com";

# Port of the KMES Host API
$global:ServerPort = "2001";

# Container name associated with issuing certificate
$global:ContainerName = "Venafi Test Container";

# Name of the issuing certificate
$global:IssuingCertificate = "Venafi Test Intermediate SubCA";

##########################
# Optional Configuration #
##########################
$global:AllowNameMismatch = $false;

###################################
# Utility / Support Functionality #
###################################

# [\x20-\x3A\x3D\x3F-\x5A\x5C\x5E-\x7E]
# is all printable ASCII characters except "[]<>;".
$TagPattern = [Regex]::New("^[\x20-\x3A\x3D\x3F-\x5A\x5C\x5E-\x7E]{2}");
$TagDataPattern = [Regex]::New("^[\x20-\x3A\x3D\x3F-\x5A\x5C\x5E-\x7E]+");

# .SYNOPSIS
#   Wrapper function that accepts a Venafi General parameter in order to login.
#
# .PARAMETER General - The General parameter given to Venafi callback functions.
#
# .OUTPUTS [PSTypeName("RASession")]
#   A session object to be passed to all other functions.
function Utility-VenafiLoginWrapper
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$General,

        [Parameter()]
        [bool]$UseAux = $false
    );

    try
    {
        $SessionParams = @{
            CertData = $General.PfxData;
            CertPass = $General.PfxPass;
            Port = $global:ServerPort;
            Server = $global:ServerHost;
            Custom = @{
                Container = $global:ContainerName;
                IssuingCertificate = $global:IssuingCertificate;
            }
        };

        # Custom Fields aren't defined if only testing connection.
        if ($General.CustomFields)
        {
            $SessionParams.Custom["ApprovalGroup"] = $General.CustomFields["Futurex: Approval Group"];
            $SessionParams.Custom["ExtensionProfile"] = $General.CustomFields["Futurex: X.509 Extension Profile"];
        }

        $Session = RA-CreateSession @SessionParams;
    }
    catch
    {
        throw "Failed to create session: " + $_;
    }

    try
    {
        if ($UseAux)
        {
            $LoginParams = @{
                Session = $Session;
                UserName = $General.AuxUser;
                UserPass = $General.AuxPass;
            };
        }
        else
        {
            $LoginParams = @{
                Session = $Session;
                UserName = $General.UserName;
                UserPass = $General.UserPass;
            };
        }

        RA-LoginWithPass @LoginParams;
    }
    catch
    {
        throw;
    }

    $Session;
}

# .SYNOPSIS
#   Create an OID value in a specific format to RA.
#
# .PARAMETER OID
#   The OID of the subject field
#
# .PARAMETER Value
#   Value of the subject field. If not provided, will be empty.
#   The value will be implicitly hex-encoded.
#
# .OUTPUTS [string]
#   A string in the format `{<OID>,12,<hexEncodedValue>}`
#
# .NOTES
#   The output should look like `{<oid>,<asn1type>,<hexValue>}`.
#   asn1type will always be 12 in this function for UTF8String.
#   FIXME This is broken for IP addresses!
function Utility-CreateFxSubject()
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$OID=$(throw "Invalid OID"),

        [Parameter()]
        [string]$Value
    );

    $ValueBytes = [System.Text.Encoding]::UTF8.GetBytes($Value);
    $ValueHex = ConvertTo-HexFromByteArray $ValueBytes;

    "{$OID,12,$ValueHex}";
}

# .SYNOPSIS
#   Create an OID extension value in a specific format to RA.
#
# .PARAMETER OID
#   The OID of the subject field
#
# .PARAMETER Value
#   Value of the subject field. If not provided, will be empty.
#   The value will be implicitly hex-encoded.
#
# .PARAMETER Critical
#  If the extension is critical, true. Otherwise, false.
#
# .OUTPUTS [string]
#   A string in the format `{<oid>,<asn1type>,<hexEncodedValue>}`
#
# .NOTES
#   asn1type will always be 12 in this function for UTF8String.
function Utility-CreateFxExtension()
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$OID=$(throw "Invalid OID"),

        [Parameter()]
        [byte[]]$Value=@(),

        [Parameter()]
        [bool]$Critical=$false
    );

    $ValueHex = ConvertTo-HexFromByteArray $Value;
    $CriticalDigit = $(if ($Critical) { 1 } else { 0 });

    "{$OID,$ValueHex,$CriticalDigit}"
}

# .SYNOPSIS
#   Converts a hashtable of DNs to a format RA understands.
#
# .PARAMETER SubjectDN
#   The hashtable provided by Venafi in the General named parameter.
#
# .NOTES
#   Uses a table specific to what Venafi provides. See Venafi
#   documentation on what's provided in the SubjectDN table.
#
# .OUTPUTS string
#   String containing a comma delimited list of subject fields.
#   Should pass this directly to RA web.
function Utility-CreateSubjectList()
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$SubjectDN=$(throw "Missing Venafi SubjectDN variable")
    );

    $Result = [System.Collections.ArrayList]::New();

    $OIDTable = @{
        CN = "2.5.4.3"; # Common Name
        OU = "2.5.4.11";# Organizational Unit
        O  = "2.5.4.10";# Organization
        L  = "2.5.4.7"; # Locality / City
        ST = "2.5.4.8"; # State / Province
        C  = "2.5.4.6"  # Country
    };

    # Common Name is required
    if (-not $SubjectDN.CN)
    {
        throw "Common Name is required in DN."
    }

    foreach ($Key in $OIDTable.Keys)
    {
        if (-not $SubjectDN[$Key])
        {
            continue;
        }

        if ($SubjectDN[$Key].GetType() -ne [array])
        {
            foreach ($Value in $SubjectDN[$Key])
            {
                $OID = Utility-CreateFxSubject $OIDTable[$Key] $Value;
                $null = $Result.Add($OID);
            }
        }
        else
        {
            $OID = Utility-CreateFxSubject $OIDTable[$Key] $SubjectDN[$Key];
            $null = $Result.Add($OID);
        }
    }

    $Result -Join ",";
}

# .SYNOPSIS
#   Encode an ASN.1 value based on the type given.
#
# .PARAMETER Type
#   Context-specific integer containing ASN.1 type.
#
# .PARAMETER Value
#   String containing unencoded value to encode.
#
# .OUTPUTS [byte[]]
#   Byte array containing ASN.1 encoded value.
#
# .NOTES
#   Will throw if type isn't supported, such as 0x80 for otherName.
#   Actual format of data depends on type given.
function Encode-SANValue
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [byte]$Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Value
    );

    switch ($Type)
    {
        { 0x81, 0x82, 0x86 -contains $_ } # DNS, URI, Email
        {
            # A simple IA5 byte string
            $Result = [System.Text.Encoding]::UTF8.GetBytes($Value);
            break;
        }

        0x87 # IP
        {
            # IP is encoded in a 4-byte OCTET STRING
            $AddressBytes = [System.Net.IPAddress]::Parse($Value);

            $Result = Create-ASN1OctetString $AddressBytes.GetAddressBytes();
            break;
        }

        # MAYBE TODO
        # Implement:
        #   0x80 (Other)
        #   0x83 (X400Address)
        #   0x84 (Directory Name)
        #   0x85 (EDI Party Name)
        #   0x88 (Registered ID)

        default
        {
            throw "Invalid type provided";
        }
    }

    $Result;
}

# .SYNOPSIS
#   Converts a hashtable of alternative DNs to a format RA understands.
#
# .PARAMETER SubjAltNames
#   The hashtable provided by Venafi in the General named parameter.
#
# .OUTPUTS [string]
#   A string containing a comma separated list of extensions.
function Utility-CreateExtensionList
{
    Param(
        [Parameter()]
        [hashtable]$SubjAltNames=$(throw "Missing Venafi SubjAltNames variable")
    );

    # https://www.alvestrand.no/objectid/2.5.29.17.html
    $SubjectAltNameOID = "2.5.29.17";

    # These are also documented in the above link.
    # Note that the notation of [0] is offset from 0x80.
    # So [2] for dNSNames would have a type of 0x82.
    # UPN is treated specially since it must be placed
    # in as an instance of otherName.
    $ASN1TypeTable = @{
        DNS = 0x82;
        Email = 0x81;
        IP = 0x87;
        URI = 0x86;
    };

    # Size here is one for each type of support alternative name.
    # The four above and UPN which is handled specially.
    $AltNameSequenceData = [System.Collections.ArrayList]::New();

    foreach ($Key in $ASN1TypeTable.Keys)
    {
        # Not all keys may be defined. If a UPN isn't given for example,
        # it's simply not defined. We need to check for existance.
        if (-not $SubjAltNames[$Key])
        {
            continue;
        }

        # Venafi provides both arrays of strings and single strings.
        # We need to test the variable for type and proceed based on that.
        if ($SubjAltNames[$Key] -is [array])
        {
            foreach ($Value in $SubjAltNames[$Key])
            {
                $ValueBytes = Encode-SANValue $ASN1TypeTable[$Key] $Value;
                $ASN1Value = Create-ASN1Value $ASN1TypeTable[$Key] $ValueBytes;
                $null = $AltNameSequenceData.Add($ASN1Value);
            }
        }
        else
        {
            $ValueBytes = [System.Text.Encoding]::UTF8.GetBytes($SubjAltNames[$Key]);
            $ASN1Value = Create-ASN1Value $ASN1TypeTable[$Key] $ValueBytes;
            $null = $AltNameSequenceData.Add($ASN1Value);
        }
    }

    # In the case of UPN, it looks like this:
    #
    # 0xA0 <size>
    #   0x06(OBJECT IDENTIFIER) <size> <oid>
    #   0xA0 <size>
    #     0x0C(UTF8String) <size> <value>
    #
    # 0xA0 as far as I can understand means that
    # the value is context specific and is allowed
    # to be a constructed/compound type. In this case,
    # otherName requires 0xA0 since its value isn't a
    # primitive type and another 0xA0 simply because
    # the grammar explicitly requires an explicit tag.
    #
    # See Encode-SANValue for a potentially better way
    # of dealing with this if you're looking to improve.

    try
    {
        [byte[]]$UPNOID = @(0x2B,0x06,0x01,0x04,0x01,0x82,0x37,0x14,0x02,0x03);

        if ($SubjAltNames.UPN)
        {
            # >>0x0C(UTF8String) <size> <value>
            $UPNValue = [System.Text.Encoding]::UTF8.GetBytes($SubjAltNames.UPN);
            $UPN = Create-ASN1Value 0x0C $UPNValue

            # >0xA0 <size>
            $OtherNameValue = Create-ASN1Value 0xA0 $UPN;

            # >0x06(OBJECT IDENTIFIER) <size> <oid>
            $OtherNameType = Create-ASN1Value 0x06 $UPNOID;

            # 0xA0 <size>
            $OtherName = Create-ASN1Value 0XA0 ($OtherNameType + $OtherNameValue);

            # Add to our alt name sequence
            $null = $AltNameSequenceData.Add($OtherName);
        }
    }
    catch
    {
        throw "Failed to encode UPN otherName value: " + $_;
    }

    $AltNameSequence = Create-ASN1Sequence $AltNameSequenceData;

    Utility-CreateFxExtension $SubjectAltNameOID $AltNameSequence 0;
}

# .SYNOPSIS
#   Create a byte array representing an ASN.1 encoded value (TLV basically).
#
# .PARAMETER Type Byte representing type of the value.
# .PARAMETER Value The actual value.
#
# .OUTPUTS byte[]
#   A byte array holding the ASN.1 encoded binary data.
function Create-ASN1Value
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [byte]$Type=$(throw "Invalid type"),

        [Parameter()]
        [byte[]]$Value=@()
    )

    # Length values greater than 255 must be encoded
    # in multiple bytes which this function doesn't handle yet.
    if ($Value.Length -gt 255)
    {
        throw "Unable to handle length values greater than 255";
    }

    # Size of value plus type and length of value.
    $Result = [byte[]]::New($Value.Length + 2);

    $Result[0] = $Type;
    $Result[1] = $Value.Length;

    [Array]::Copy($Value, 0, $Result, 2, $Value.Length);

    $Result;
}

# .SYNOPSIS
#   Create a sequence encoded in ASN.1
#
# .PARAMETER Values An array of byte arrays that are part of the sequence.
#
# .OUTPUTS byte[]
#   A byte array holding the ASN.1 encoded binary data.
function Create-ASN1Sequence
{
    Param(
        [Parameter()]
        [byte[][]]$Values
    );

    $Length = 0;

    foreach ($Value in $Values)
    {
        $Length += $Value.Length;
    }

    $Result = [byte[]]::New($Length + 2);

    # 0x30 is the ASN.1 type for SEQUENCE
    $Result[0] = 0x30;
    $Result[1] = $Length;

    $Offset = 2;

    foreach ($Value in $Values)
    {
        [Array]::Copy($Value, 0, $Result, $Offset, $Value.Length);
        $Offset += $Value.Length;
    }

    $Result;
}

# .SYNOPSIS
#   Create a sequence encoded in ASN.1
#
# .PARAMETER Value A byte array as the value of the OCTET STRING
#
# .OUTPUTS byte[]
#   A byte array holding the ASN.1 encoded binary data.
function Create-ASN1OctetString
{
    Param(
        [Parameter()]
        [byte[]]$Value
    );

    Create-ASN1Value 0x04 $Value;
}

# .SYNOPSIS
#   Utility function to convert hex strings to byte array.
# 
# .PARAMETER Data
#   Hex string to convert to byte array.
# 
# .OUTPUTS byte[]
#   Byte array of data representing the given hex string.
function ConvertTo-ByteArrayFromHex
{
    Param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]$Data=$(throw "Invalid data")
    )

    if ($Data.Length % 2 -ne 0)
    {
        throw "Invalid hex data provided, not divisible by 2";
    }

    $Length = $Data.Length / 2;
    $Result = [byte[]]::New($Length);

    for ($Index = 0; $Index -lt $Data.Length; $Index += 2)
    {
        $Result[$Index / 2] = [Convert]::ToByte($Data.Substring($Index, 2), 16);
    }

    Write-Output -NoEnumerate $Result;
}

# .SYNOPSIS
#   Utility function to convert a byte array to hex strings
# 
# .PARAMETER Data
#   Byte array to convert to hex
# 
# .OUTPUTS string
#   String representing the given byte array encoded in hex.
# 
function ConvertTo-HexFromByteArray
{
    Param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Byte[]]$Data=$(throw "Invalid data")
    )

    $Result = [System.Text.StringBuilder]::new($Data.Length * 2)

    foreach ($Byte in $Data)
    {
        $null = $Result.AppendFormat("{0:X2}", $Byte)
    }

    $Result.ToString()
}

# .SYNOPSIS
#   Though unlikely, it appears to be possible for a readable chunk to be
#   too small for a full excrypt message. So we need to make sure we read
#   enough chunks to hold a full Excrypt string.
#
# .PARAMETER Stream Practically any stream supporting Read().
# .PARAMETER Delim The delimiter to read until.
#
# .OUTPUTS [hashtable]
#   A hashtable where:
#      'Result' - Holds the full response message.
#      'LeftOver' - Holds any left-over data.
#
# .NOTES
#   In the case of Excrypt, there should not be any
#   left-over data since a write ends at the end of
#   an Excrypt message afaik. This means we can have
#   chunks that are too small but the last chunk
#   should always stop at the end of an Excrypt
#   message.
function Utility-ReadUntil
{
    Param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.IO.Stream]$Stream,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Delim
    );

    $MoreLeft = $true;
    $Out = [System.Text.StringBuilder]::New(1024);
    $Buffer = [Byte[]]::New(1024);

    while ($MoreLeft)
    {
        $ReadAmount = $Stream.Read($Buffer, 0, 1024);
        $Content = [System.Text.Encoding]::ASCII.GetString($Buffer, 0, $ReadAmount);
        $DelimIdx = $Content.IndexOf($Delim);

        if ($DelimIdx -ne -1)
        {
            # Add only up to (and including) the delimiter
            $null = $Out.Append($Content, 0, $DelimIdx + $Delim.Length);
            $MoreLeft = $false;
        }
        else
        {
            # Add all of it and begin reading again.
            $null = $Out.Append($Content);
        }
    }

    @{
        Result = $Out.ToString();
        LeftOver = $Content.Substring($DelimIdx + $Delim.Length);
    };
}

# .SYNOPSIS
#   Read a full Excrypt message.
#
# .PARAMETER Session RASession object from RA-CreateSession.
#
# .OUTPUTS [hashtable]
#   Same as Utility-ReadUntil
#
# .NOTES
#   Is a wrapper over Utility-ReadUntil that just passes ']' as delimiter.
function Utility-ReadExcrypt
{
    Param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.IO.Stream]$Stream
    );

    Utility-ReadUntil $Stream "]";
}

# .SYNOPSIS
#   The server certificate validation callback.
$ServerCertValidation = [System.Net.Security.RemoteCertificateValidationCallback] {
    Param(
        [object]$Sender,
        [System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate,
        [System.Security.Cryptography.X509Certificates.X509Chain]$Chain,
        [System.Net.Security.SslPolicyErrors]$Errors
    );

    # If no errors, accept it.
    if ($Errors -eq [System.Net.Security.SslPolicyErrors]::None)
    {
        return true;
    }

    # Otherwise, figure out the error and throw.
    switch ($Errors)
    {
        default
        {
            $ErrorString = "Unknown error.";
            break;
        }

        { $_ -eq [System.Net.Security.SslPolicyErrors]::None }
        {
            $ErrorString = "Success";
            break;
        }

        { $_ -eq [System.Net.Security.SslPolicyErrors]::RemoteCertificateNotAvailable }
        {
            $ErrorString = "Certificate not provided."
            break;
        }

        { $_ -eq [System.Net.Security.SslPolicyErrors]::RemoteCertificateNameMismatch }
        {
            $ErrorString = "Certificate name mismatch.";
            break;
        }

        { $_ -eq [System.Net.Security.SslPolicyErrors]::RemoteCertificateChainErrors }
        {
            $ErrorString = "CA certificate chain failed validation.";
            break;
        }
    }

    $Exception = [System.Security.Authentication.AuthenticationException]::New($ErrorString);

    if ($Errors -ne [System.Net.Security.SslPolicyErrors]::RemoteCertificateNameMismatch)
    {
        throw $Exception
    }
    elseif (-not $global:AllowNameMismatch)
    {
        throw $Exception
    }

    return $true;
}

############################
# RA Excrypt Functionality #
############################

# .SYNOPSIS
#   Create a new session.
#
# .PARAMETER Server
#    The hostname or IP address of the CA server.
#
# .PARAMETER Port
#    The port of the server in-case unconventional port.
#
# .PARAMETER CertPath
#    The TLS client certificate to use for PKI exchange.
#    Must be signed by servers trusted authority.
#    Must have a private key available.
#
# .PARAMETER CertPass
#   The password, if one is required, for the certificate file.
#
# .OUTPUTS RASession
#    A (mostly) opaque object to be passed to other RA functions.
#
# .NOTES
#   Essentially just manages TLS connection for now and makes it
#   easier to keep all of the connection and TLS information in 
#   a single location.
#
#   By default, server certificate validation is done by searching
#   the Trusted Certificate Store. Currently, specifying custom
#   trusted certificates isn't supported (but should be). TODO
function RA-CreateSession
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Server=$(throw "Invalid host"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$Port=2001,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [byte[]]$CertData=$(throw "Invalid certificate path"),

        [Parameter()]
        [SecureString]$CertPass,

        [Parameter()]
        $Custom
    );

    $Cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::New($CertData, $CertPass);
    $CertCol = [System.Security.Cryptography.X509Certificates.X509CertificateCollection]::New($Cert);
    $Client = [Net.Sockets.TcpClient]::New($Server, $Port);
    $TlsStream = [System.Net.Security.SslStream]::New($Client.GetStream(), $false, $ServerCertValidation);

    $TlsStream.AuthenticateAsClient($Server, $CertCol, [System.Net.SecurityProtocolType]::Tls12, $true);

    [PSCustomObject]@{
        PSTypeName = "RASession"
        Client = $Client;
        Stream = $TlsStream;
        Certificates = $CertCol;
        Custom = $Custom;
    };
}

# .SYNOPSIS
#   Closes a session.
#
# .PARAMETER Session RASession object to close
function RA-CloseSession
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session
    );

    $Session.Client.Close();
}

# .SYNOPSIS
#   Checks an Excrypt object for failure.
#
# .PARAMETER Excrypt RAExcrypt object to check
#
# .NOTES
#    Throws on failure in response.
#    Checks response by checking for AN.
#    If AN doesn't exist, simply returns.
function RA-CheckResponseForFail
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RAExcrypt")]$Excrypt
    );

    if ($Excrypt.Arguments["AO"] -eq "ERRO")
    {
        throw ($Excrypt.Arguments | Out-String);
    }
    if ($Excrypt.Arguments["AN"] -and $Excrypt.Arguments["AN"] -ne "Y")
    {
        throw ($Excrypt.Arguments | Out-String);

        # if (-not $Excrypt.Arguments["BB"])
        # {
        #     throw ($Excrypt.Arguments | Out-String)
        # }
        # else
        # {
        #     throw $Excrypt.Arguments["BB"];
        # }
    }
}

# .SYNOPSIS
#   Login to a HostAPI instance via PKI
#
# .PARAMETER Session RASession object from RA-CreateSession
# .PARAMETER UserPfx File path containing client certificate and private key
# .PARAMETER UserPfxPass Password for UserPfx
#
# .NOTES
#    Currently doesn't work. Will throw unconditionally if used to indicate as such.
function RA-LoginWithPKI
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$UserPfx,

        [Parameter()]
        [string]$UserPfxPass
    );

    throw "Not implemented.";
}

# .SYNOPSIS
#   Login to a HostAPI instance via username and password
#
# .PARAMETER Session RASession object from RA-CreateSession
# .PARAMETER UserName Username for login.
# .PARAMETER UserPass Userpass associate with username for login.
#
# .NOTES
#    Returns excrypt object with response on success. Throws otherwise.
function RA-LoginWithPass
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$UserName,

        [Parameter()]
        [string]$UserPass
    );

    $Excrypt = RA-CreateExcrypt;

    $Excrypt.Arguments.Add("AO", "RKLO");
    $Excrypt.Arguments.Add("DA", $UserName);
    $Excrypt.Arguments.Add("CH", $UserPass);

    try
    {
        $Response = (RA-ProcessMessage $Session $Excrypt).Result | RA-ParseExcrypt;

        RA-CheckResponseForFail $Response;
    }
    catch
    {
        throw "Failed to process login message: " + $_;
    }

    # Make sure we're fully logged in.
    [int]$Remaining = $Response.Arguments["RL"]

    if ($Remaining -ne 0)
    {
        throw "Credentials given aren't usable for single-user sign-on."
    }
}

# .SYNOPSIS
#   Fetch a certificate by container name and certificate common name.
#
# .PARAMETER Session RASession object from RA-CreateSession.
# .PARAMETER Container Name of CA container containing the certificate.
# .PARAMETER Certificate Common name of certificate to search for.
#
# .OUTPUTS [System.Security.Cryptography.X509Certificates.X509Certificate2]
#   The certificate requested, throws otherwise.
function RA-GetCertificate
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Container,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Certificate
    );

    try
    {
        $Excrypt = RA-CreateExcrypt;

        $Excrypt.Arguments.Add("AO", "RKRK");
        $Excrypt.Arguments.Add("CA", $Container);
        $Excrypt.Arguments.Add("RT", $Certificate);

        $Response = RA-ProcessMessage $Session $Excrypt;
        $ExcryptResponse = RA-ParseExcrypt $Response.Result;
    }
    catch
    {
        throw "Failed to prepare certificate query: " + $_;
    }

    try
    {
        RA-CheckResponseForFail $ExcryptResponse;
    }
    catch
    {
        throw "Request failed: " + $_;
    }

    if (-not $ExcryptResponse.Arguments["RV"])
    {
        throw "Certificate data missing from response.`n" + ($ExcryptResponse.Arguments | Out-String);
    }
 
    try
    {
        $IssuingCertData = ConvertTo-ByteArrayFromHex $ExcryptResponse.Arguments["RV"];

        [System.Security.Cryptography.X509Certificates.X509Certificate2]::New($IssuingCertData);
    }
    catch
    {
        throw "Failed to create X.509 certificate object: " + $_;
    }
}

# .SYNOPSIS
#   Fetch a certificate chain by container name and certificate common name.
#
# .PARAMETER Session RASession object from RA-CreateSession.
# .PARAMETER Container Name of CA container containing the certificate.
# .PARAMETER Certificate Common name of certificate to search for.
#
# .OUTPUTS [System.Security.Cryptography.X509Certificates.X509Certificate2Collection]
#   The certificate chain of the certificate passed, throws otherwise.
function RA-GetCertificateChain
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Container,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Certificate
    );

    try
    {
        $Collection = [System.Security.Cryptography.X509Certificates.X509Certificate2Collection]::New();
        $CertName = $Certificate;

        do
        {
            # If we haven't defined IssuerName yet, it's the first iteration.
            # Just a way to reduce code duplication.
            if ($IssuerName)
            {
                $CertName = $IssuerName;
            }

            $CertQuery = @{
                Session = $Session;
                Container = $Container;
                Certificate = $CertName;
            };

            $X509 = RA-GetCertificate @CertQuery;

            # 0 is for simple name (common name).
            $IssuerName = $X509.GetNameInfo(0, $true);

            if (-not $IssuerName -or $IssuerName.Empty)
            {
                throw "Invalid issuer name.";
            }

            $null = $Collection.Add($X509);
        }
        while($IssuerName -ne $CertName);
    }
    catch
    {
        throw "Failed to create certificate chain: " + $_;
    }

    Write-Output -NoEnumerate $Collection;
}

# .SYNOPSIS
#   Upload a CSR to the CA.
#
# .PARAMETER Subject Subject list in non-standard format.
# .PARAMETER Extensions Extensions list in non-standard format.
# .PARAMETER Request PKCS10 request encoded in hex.
# .PARAMETER Session RASession object from RA-CreateSession.
# .PARAMETER CA Name of CA container containing the issuing certificate.
# .PARAMETER Certificate Common name of the issuing certificate.
# .PARAMETER PKCS10 Byte array of the PKCS10 binary data.
# .PARAMETER HashType Hash type to sign the CSR with.
# .PARAMETER ApprovalGroup Approval group to use for approval
# .PARAMETER ExtensionProfile Extension profile name to handle V3 extensions.
#
# .OUTPUTS
#   The unique identifier of the submitted certificate.
#   Should be given to Venafi so it may be later approved.
function RA-UploadCSR
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session=$(throw "Invalid session"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Container=$(throw "Invalid container name"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Certificate=$(throw "Invalid certificate name"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name=$(throw "Invalid CSR name"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Subject=$(throw "Missing subject list"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Extensions=$(throw "Missing extension list"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [byte[]]$PKCS10=$(throw "Missing PKCS#10 binary data"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$HashType=$(throw "Missing hash type string"),

        # [Parameter()]
        # [ValidateNotNullOrEmpty()]
        # [string]$Hash=$(throw "Missing public key hash"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ApprovalGroup=$(throw "Missing approval group name"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ExtensionProfile=$(throw "Missing extension profile")
    );

    try
    {
        $Excrypt = RA-CreateExcrypt;
        $Excrypt.Arguments.Add("AO", "RAUX");
        $Excrypt.Arguments.Add("CA", $Container);
        $Excrypt.Arguments.Add("RT", $Certificate);
        $Excrypt.Arguments.Add("NA", $Name);
        $Excrypt.Arguments.Add("HA", $HashType);
        $Excrypt.Arguments.Add("GN", $ApprovalGroup);
        $Excrypt.Arguments.Add("EN", $ExtensionProfile);
        $Excrypt.Arguments.Add("CR", (ConvertTo-HexFromByteArray $PKCS10));
        $Excrypt.Arguments.Add("SN", $Subject);

        $Response = RA-ProcessMessage $Session $Excrypt;
        $ExcryptResponse = RA-ParseExcrypt $Response.Result;

        RA-CheckResponseForFail $ExcryptResponse;

        $ExcryptResponse.Arguments["ID"];
    }
    catch
    {
        throw "Request failed: " + $_;
    }
}

# .SYNOPSIS
#   Approve a CSR
#
# .PARAMETER Session RASession object given from RA-CreateSession.
# .PARAMETER UUID The unique ID of the CSR request, given from RA-UploadCSR.
#
# .NOTES
#   Throws on failure.
#   FIXME Needs a second login since uploading and approving group may not be the same.
function RA-ApproveCSR
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session=$(throw "Invalid session"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$UUID=$(throw "Invalid identifier")
    );

    try
    {
        $Excrypt = RA-CreateExcrypt;

        $Excrypt.Arguments.Add("AO", "RAYX");
        $Excrypt.Arguments.Add("ID", $UUID);
        $Excrypt.Arguments.Add("AP", "1");
        $Excrypt.Arguments.Add("NT", "Created by Adaptable CA driver");

        $Response = RA-ProcessMessage $Session $Excrypt;
        $ExcryptResponse = RA-ParseExcrypt $Response.Result;

        RA-CheckResponseForFail $ExcryptResponse;
    }
    catch
    {
        throw "Request failed: " + $_;
    }
}

# .SYNOPSIS
#   Fetch a CSR by UUID.
#
# .PARAMETER Session RASession object given from RA-CreateSession.
# .PARAMETER UUID The unique ID of the CSR request, given from RA-UploadCSR.
#
# .OUTPUTS hashtable
#    'Status' - Either "Pending" if not approved yet or "Issued" if signed.
#    'Certificate' - The X509Certificate2 object if CSR is signed.
#
# .NOTES
#   This function is specifically for fetching
#   a signed X.509 certificate from an approved
#   certificate request. If you need to fetch
#   an X.509 certificate by name, use RA-GetCertificate.
function RA-GetSignedCSR
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session=$(throw "Invalid session"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$UUID=$(throw "Invalid identifier")
    );

    $Result = @{};

    try
    {
        $Excrypt = RA-CreateExcrypt;

        $Excrypt.Arguments.Add("AO", "RAGX");
        $Excrypt.Arguments.Add("ID", $UUID);

        $Response = RA-ProcessMessage $Session $Excrypt;
        $ExcryptResponse = RA-ParseExcrypt $Response.Result;

        RA-CheckResponseForFail $ExcryptResponse;
    }
    catch
    {
        throw "Request failed: " + $_;
    }

    try
    {
        $ApprovalsRemaining = [int]$ExcryptResponse.Arguments["AP"];

        if ($ApprovalsRemaining -eq 0 -and -not $ExcryptResponse.Arguments["CE"])
        {
            throw "X.509 certificate missing from response.";
        }

        if ($ApprovalsRemaining -ne 0)
        {
            $Result["Status"] = "Pending";
        }
        else
        {
            $Result["Status"] = "Issued";

            $CertData = (ConvertTo-ByteArrayFromHex $ExcryptResponse.Arguments["CE"]);

            $Result["Certificate"] = [System.Security.Cryptography.X509Certificates.X509Certificate2]::New($CertData);
        }
    }
    catch
    {
        throw "Failed to parse response: " + $_;
    }

    $Result;
}

# .SYNOPSIS
#   Revoke a signed certificate by CSR ID.
#
# .PARAMETER Session RASession object given from RA-CreateSession.
# .PARAMETER UUID The unique ID of the CSR request, given from RA-UploadCSR.
#
# .NOTES
#   Throws on failure.
function RA-RevokeSignedCSR
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session=$(throw "Invalid session"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$UUID=$(throw "Invalid identifier"),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Reason=$(throw "Revocation reason is required"),

        [Parameter()]
        [string]$Details=""
    );

    try
    {
        $Excrypt = RA-CreateExcrypt;

        $Excrypt.Arguments.Add("AO", "RASX");
        $Excrypt.Arguments.Add("ID", $UUID);
        $Excrypt.Arguments.Add("RT", $Reason);
        $Excrypt.Arguments.Add("RR", $Details);

        $Response = RA-ProcessMessage $Session $Excrypt;
        $ExcryptResponse = RA-ParseExcrypt $Response.Result;

        RA-CheckResponseForFail $ExcryptResponse;
    }
    catch
    {
        throw "Request failed: " + $_;
    }
}

# .SYNOPSIS
#   Creates empty RAExcrypt object.
#
# .OUTPUTS
#   An empty RAExcrypt object.
function RA-CreateExcrypt
{
    [PSCustomObject]@{
        PSTypeName = "RAExcrypt"
        Arguments = @{};
    };
}

# .SYNOPSIS
#   Creates an RAExcrypt object from Excrypt string.
#
# .PARAMETER Message Excrypt message to parse into an RAExcrypt object.
#
# .OUTPUTS
#   An RAExcrypt object corresponding to the given string.
#   Throws on invalid Excrypt.
function RA-ParseExcrypt
{
    Param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    );

    $Result = RA-CreateExcrypt;

    $Offset = 0;
    $First = $true;

    # Check for [
    if ($Message[$Offset] -ne 0x5B)
    {
        throw [System.ArgumentException]::New("Missing starting bracket.");
    }

    $Offset++;

    do
    {
        if ($First -eq $true)
        {
            $First = $false;
        }
        else
        {
            # Check for ;
            if ($Message[$Offset] -ne 0x3B)
            {
                throw [System.ArgumentException]::New("Missing semi-colon at $Offset");
            }
            
            $Offset++;
        }

        $TagMatch = $TagPattern.Match($Message, $Offset, $Message.Length - $Offset);

        if (-not $TagMatch.Success)
        {
            if ($Message.Length - $Offset -gt 1)
            {
                throw [System.ArgumentException]::New("Invalid tag at $Offset");
            }

            break;
        }

        # We have one group and one capture.
        $Tag = $TagMatch.Value;
        $Offset += $Tag.Length;

        $TagDataMatch = $TagDataPattern.Match($Message, $Offset, $Message.Length - $Offset);

        if ($TagDataMatch.Success)
        {
            $TagData = $TagDataMatch.Value;
            $Result.Arguments["$Tag"] = $TagData;
            $Offset += $TagData.Length;

            if ($Message[$Offset] -ne 0x3B)
            {
                throw [System.ArgumentException]::New("Invalid tag data found at ${Offset}: Found invalid character $($Message[$Offset])");
            }
        }
        else
        {
            $Result.Arguments["$Tag"] = "";
        }
    }
    while ($true);

    # Test for ]
    if ($Message[$Offset] -ne ']')
    {
        throw [System.ArgumentException]::New("Missing ending bracket at ${Offset}");
    }

    $Result;
}

# .SYNOPSIS
#   Generate an Excrypt string from RAExcrypt object.
#
# .PARAMETER Excrypt RAExcrypt object to format into a string.
#
# .OUTPUTS string
#   String containing all arguments from the RAExcrypt object given.
function RA-GenerateExcrypt
{
    Param(
        [CmdletBinding()]
        [Parameter(ValueFromPipeline)]
        [PSTypeName("RAExcrypt")]$Excrypt
    );

    # 64 is just a good number
    $Result = [System.Text.StringBuilder]::New(64);

    $null = $Result.Append('[');

    foreach ($Tag in $Excrypt.Arguments.Keys)
    {
        $null = $Result.Append("${Tag}$($Excrypt.Arguments[$Tag]);");
    }

    $null = $Result.Append(']');

    $Result.ToString();
}

# .SYNOPSIS
#   Convenience function to write an excrypt message and read a response in one function.
#
# .PARAMETER Session RASession object given from RA-CreateSession.
# .PARAMETER Excrypt Excrypt message to write to given session.
#
# .OUTPUTS HashTable
#   See Utility-ReadUntil
function RA-ProcessMessage
{
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RASession")]$Session,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PSTypeName("RAExcrypt")]$Excrypt
    );

    $Message = RA-GenerateExcrypt $Excrypt;
    $OutBuffer = [System.Text.Encoding]::ASCII.GetBytes($Message);
    $Session.Stream.Write($OutBuffer, 0, $OutBuffer.Length);

    $Result = Utility-ReadExcrypt $Session.Stream;

    $Result;
}

##########################################
# Futurex Adaptable CA Driver for Venafi #
##########################################

<##################################################################################################
.NAME
    Test-Settings
.DESCRIPTION
    Verifies that Trust Protection Platform can authenticate with the CA using the supplied credentials.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        UserName: the username required to authenticate with the CA
        UserPass: the password required to authenticate with the CA
        PfxData: a PKCS#12 containing a client certificate and private key required to authenticate with the CA
        PfxPass: the password required to access the private key in the PKCS#12
        AuxUser: a username paired with AuxPass for secondary authentication purposes
        AuxPass: the password for the AuxUser (username credential), AuxPfxData (certificate credential), or independent (password credential)
        AuxPfxData: a PKCS#12 containing client certificate and private key for secondary authentication purposes
        CertObjDN: the Venafi distinguished name of the certificate object in the policy tree
        CustomFields: the hash table of Custom Fields. Keys are field labels and values are either strings (single valued) or string arrays (multi-valued)
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Test-Settings
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General
    )

    try
    {
        $Session = Utility-VenafiLoginWrapper $General;
    }
    catch
    {
        throw "Failed to login: " + $_;
    }
    finally
    {
        RA-CloseSession $Session;
    }

    @{ Result="Success"; };
}

<##################################################################################################
.NAME
    Get-ChainCertificates
.DESCRIPTION
    Retrieves the chain of CA certificates that are applicable to certificates issued by the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.NOTES
    Returns a hashtable that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Pkcs7: a collection that includes all of the CA certificates in the issuing chain
##################################################################################################>
function Get-ChainCertificates
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General
    )

    try
    {
        $Session = Utility-VenafiLoginWrapper $General;
    }
    catch
    {
        throw "Failed to create session: " + $_;
    }

    try
    {
        $GetChainParams = @{
            Session = $Session;
            Container = $Session.Custom.Container;
            Certificate = $Session.Custom.IssuingCertificate;
        };

        $Collection = RA-GetCertificateChain @GetChainParams;
    }
    catch
    {
        throw "Failed to get certificate chain: " + $_;
    }
    finally
    {
        RA-CloseSession $Session;
    }

    @{
        Pkcs7 = $Collection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7);
        Result = "Success";
    };
}

<##################################################################################################
.NAME
    Prepare-ForRequest
.DESCRIPTION
    Performs any tasks that are necessary to prior to submitting a certificate signing request to the CA
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions (see Test-Settings)
.PARAMETER Specific
    A hashtable containing the specific set of variables needed by this function
        SubjectDN: the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames: hashtable keyed by SAN type; values are string arrays
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Prepare-ForRequest
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Specific
    );

    return @{ Result="NotUsed" };
}

<##################################################################################################
.NAME
    Submit-CsrAsNew
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a new, first time certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        Pkcs10: the Base64-encoded PKCS#10-formatted certificate signing request (CSR) to be enrolled
        SubjectDN: the requested subject distiguished name as a hash table. OU is a string array and all others are strings
        SubjAltNames: hash table keyed by SAN type. Values are string arrays.
        KeySize: the integer key size to be used if the CA creates the key pair
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' to indicate the non-error completion state. NOTE: this function is required.
        TransId: the identifier used to subsequently approve and/or retrieve the certificate from the CA 
        Pkcs7: a collection that includes the issued certificate and (optionally) includes all of the CA certificates in the chain
        Pkcs12: a collection that includes the issued certificate, its private key, and optionally all of the CA certificates in the chain
        PrivKeyPem: an OpenSSL or PKCS#8 private key in PEM format
        EncryptPass: the password used to encrypt the private key or PKCS#12
##################################################################################################>
function Submit-CsrAsNew
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Specific
    );

    try
    {
        $Session = Utility-VenafiLoginWrapper $General;
    }
    catch
    {
        throw "Failed to create session: " + $_;
    }

    try
    {
        try
        {
            $Subject = Utility-CreateSubjectList $Specific.SubjectDN;
        }
        catch
        {
            throw "Failed to create subject lists: " + $_;
        }

        try
        {
            # If none are specified, it simply doesn't define SubjAltNames.
            if ($Specific.SubjAltNames)
            {
                $Extensions = Utility-CreateExtensionList $Specific.SubjAltNames;
            }
        }
        catch
        {
            throw "Failed to create extension lists: " + $_;
        }

        try
        {
            # This is a bit overkill... but it's suprisingly flexible.
            # Create a new Certificate Request object to parse and validate our request.
            $Request = New-Object -ComObject X509Enrollment.CX509CertificateRequestPkcs10;

            # 0x06 is EncodingType Base64 any. It works with any headers.
            $Request.InitializeDecode($Specific.Pkcs10, 0x06);
            $Request.CheckSignature();

            $UploadParams = @{
                Session = $Session;
                HashType = "SHA256";
                ExtensionProfile = $Session.Custom.ExtensionProfile;
                ApprovalGroup = $Session.Custom.ApprovalGroup;
                Subject = $Subject;
                Extensions = $Extensions;
                PKCS10 = [Convert]::FromBase64String($Request.RawData(0x01)); # 0x02 is binary representation.
                Container = $Session.Custom.Container;
                Certificate = $Session.Custom.IssuingCertificate;
                Name = "Venafi - {0}" -f $General.CertObjDN;
            };
        }
        catch
        {
            throw "Failed to prepare CSR: " + $_;
        }

        try
        {
            $TransID = RA-UploadCSR @UploadParams;
        }
        catch
        {
            throw "Failed to upload CSR: " + $_;
        }
    }
    catch
    {
        throw;
    }
    finally
    {
        RA-CloseSession $Session;
    }

    @{
        Result = "Success";
        TransId = $TransID;
    };
}

<##################################################################################################
.NAME
    Submit-CsrAsRenewal
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a renewal of an existing certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
        CertId: a string that uniquely identifies the certificate issued by the CA to be renewed
        CertPem: the raw, Base64-encoded X509 certificate to be renewed
.NOTES
    Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsRenewal
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General,

        [Parameter(Mandatory=$true,HelpMessage="Function Specific Parameters")]
        [System.Collections.Hashtable]$Specific
    );

    #FIXME RA can do this better than just submitting a new CSR altogether.
    Submit-CsrAsNew -General $General -Specific $Specific;
}

<##################################################################################################
.NAME
    Submit-CsrAsReplacement
.DESCRIPTION
    Submits a CSR to a CA for enrollment as a replacement for an existing certificate
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function. See Submit-CsrAsNew, as well as the following:
        CertId: a string that uniquely identifies the certificate issued by the CA to be replaced
        CertPem: the raw, Base64-encoded X509 certificate to be replaced
.NOTES
    Returns a hash table that includes the same variables detailed in Submit-CsrAsNew
##################################################################################################>
function Submit-CsrAsReplacement
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Specific
    );

    Submit-CsrAsNew -General $General -Specific $Specific;
}

<##################################################################################################
.NAME
    Approve-Request
.DESCRIPTION
    Approves a previously submitted CSR
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        TransId: a string that uniquely identifies the certificate request submitted to the CA
        SubjectDN: the requested subject distiguished name as a hashtable; OU is a string array; all others are strings
        SubjAltNames: hashtable keyed by SAN type; values are string arrays
.NOTES
    Returns a hashtable that includes the following variables
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Approve-Request
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Specific
    );

    try
    {
        $UseAuxCred = $false;

        if ($General.AuxUser -and $General.AuxPass)
        {
            $UseAuxCred = $true;
        }

        $Session = Utility-VenafiLoginWrapper $General $UseAuxCred;

        RA-ApproveCSR $Session $Specific.TransId;
    }
    catch
    {
        throw "Failed to approve request: " + $_;
    }
    finally
    {
        RA-CloseSession $Session;
    }

    @{ Result="Success" };
}

<##################################################################################################
.NAME
    Retrieve-Certificate
.DESCRIPTION
    Retrieves a signed certificate from the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId: a string that uniquely identifies the certificate issued by the CA
.NOTES
    Returns a hash table that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
        Status: 'Pending' or 'Issued' to indicate whether the certificate has been issued by the CA
        Pkcs7: a collection that includes the issued certificate and (optionally) all of the CA certificates in the chain
        Pkcs12: a collection that includes the issued certificate, its private key, and optionally all of the CA certificates in the chain
        PrivKeyPem: an OpenSSL or PKCS#8 private key in PEM format
        EncryptPass: the password used to encrypt the private key or PKCS#12
        DiscardPrivateKeyAndCsr: boolean that when $true tells the driver to discard stored assets that will not match the certificate being returned
##################################################################################################>
function Retrieve-Certificate
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Specific
    );

    try
    {
        $Session = Utility-VenafiLoginWrapper $General;
    }
    catch
    {
        throw "Failed to create session: " + $_;
    }

    try
    {
        $RetrievedData = RA-GetSignedCSR $Session $Specific.CertId;

        $Result = @{
            Result = "Success";
            Status = $RetrievedData.Status;
        };

        if ($RetrievedData.Status -eq "Issued")
        {
            $GetChainParams = @{
                Session = $Session;
                Container = $Session.Custom.Container;
                Certificate = $Session.Custom.IssuingCertificate;
            };

            $Collection = RA-GetCertificateChain @GetChainParams;
            $null = $Collection.Add($RetrievedData.Certificate);
            $Result["PKCS7"] = $Collection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs7);
        }

    }
    catch
    {
        throw "Failed to build certificate chain: " + $_;
    }
    finally
    {
        RA-CloseSession $Session;
    }

    $Result;
}

<##################################################################################################
.NAME
    Revoke-Certificate
.DESCRIPTION
    Revokes a certificate issued by the CA
.PARAMETER General
    A hash table containing the general set of variables needed by most (or all) functions (see Test-Settings)
.PARAMETER Specific
    A hash table containing the specific set of variables needed by this function
        CertId: a string that uniquely identifies the certificate issued by the CA
        CertPem: the raw, Base64-encoded X509 certificate to be revoked
        ReasonCode: 1 (User Key Compromised), 2 (CA Key Compromised), 3 (User Changed Affiliation), 4 (Certificate Superseded), 5 (Original Use No Longer Valid)
        Comment: a comment provided by the revocation requester
.NOTES
    Returns a hashtable that includes the following variables:
        Result: 'Success' or 'NotUsed' to indicate the non-error completion state
##################################################################################################>
function Revoke-Certificate
{
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$General,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$Specific
    );

    $ReasonMap = @{
        0 = "Unspecified"
        1 = "Key Compromised";
        2 = "CA Compromise";
        3 = "Affiliation Changed";
        4 = "Superseded";
        5 = "Cessation of Operation";
        6 = "Certificate Hold";
        7 = "Privilege Withdrawn";
        8 = "AA Compromise";
    };

    if ($Specific.ReasonCode -lt 0 -or $Specifc.ReasonCode -gt 8)
    {
        $ReasonCode = 0;
    }
    else
    {
        $ReasonCode = $Specific.ReasonCode;
    }

    try
    {
        $Session = Utility-VenafiLoginWrapper $General;
    }
    catch
    {
        throw "Failed to create session: " + $_;
    }

    try
    {
        $RevokeParams = @{
            Session = $Session;
            UUID = $Specific.CertId;
            Reason = $ReasonMap[$ReasonCode];
            Details = $Specific.Comment;
        };

        RA-RevokeSignedCSR @RevokeParams;
    }
    catch
    {
        throw "Failed to revoke certificate: " + $_;
    }
    finally
    {
        RA-CloseSession $Session;
    }

    @{ Result = "Success"; };
}
