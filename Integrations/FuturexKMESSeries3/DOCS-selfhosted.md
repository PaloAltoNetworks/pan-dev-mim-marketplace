# Futurex KMES Series 3 Integration Guide

This guide summarizes how to connect Certificate Manager, Self-Hosted to a Futurex KMES Series 3 through the Adaptable CA framework. The full Futurex integration guide (`FX_IG-Venafi_Adaptable_CA-KMES_Series_3.pdf`, with screenshots) is maintained by Futurex and contains the complete procedure. For KMES Series 3 setup, see the [Futurex documentation](https://docs.futurex.com).

## Prerequisites

- Certificate Manager, Self-Hosted installed and configured.
- Futurex KMES Series 3, application version 6.3.1.3 or later, with the Registration Authority license enabled and initial setup completed.
- The two PowerShell scripts from this listing: `Futurex KMES CA.ps1` and `FuturexCreateCustomFields.ps1`.

## KMES Series 3 Configuration

1. In **Administration > Configuration > Host API Options**, enable the Host API commands `RAGX`, `RASX`, `RAUX`, `RAYX`, `RKLO` and `RKRK`.
2. In **Identity Management**, create a role (Host API authentication only) and a Client Application identity with Password authentication for Certificate Manager, Self-Hosted. Grant **Certificate Authority > Export, Upload**, and grant **Signing Approval > Approve** either to the same role (single user) or to a second role and identity (dual user, recommended by Futurex).
3. In **PKI > Signing Workflow**, add an approval group and give the role the **Use** permission. Note the group name.
4. In **PKI > Certificate Authorities**, create a certificate container owned by the role, then a root CA and an issuing CA certificate using the **Certificate Authority** profile.
5. On the issuing CA, add an issuance policy: set the number of approvals and allowed hashes, select **Allow CSR uploads**, set the default approval group, and add at least one extension profile. If approvals are set to 0, select **Allow self approval** and set **Anonymous Signing** security usage on the issuing CA.
6. Optional: to allow SANs or other custom extensions, select **Allow User-Defined Extensions** on the X.509 extension profile, or add a Subject Alternate Name extension to it.

## TLS Between Certificate Manager, Self-Hosted and the KMES

1. Create a CA on the KMES for the System/Host API connection pair.
2. In **Administration > Configuration > Network Options > TLS/SSL Settings**, clear **Use Futurex certificates** for the System/Host API pair, generate an RSA 2048 key pair and a CSR with the **TLS Server Certificate** profile.
3. Sign the CSR with the CA, export the root CA and the signed certificate, and load both into the System/Host API connection pair.
4. Issue a client certificate for Certificate Manager, Self-Hosted and export it as a PKCS #12 file.
5. Install the System TLS CA root certificate in the Windows **Trusted Root Certification Authorities** store on each Certificate Manager, Self-Hosted server.

## Installation

1. Copy `Futurex KMES CA.ps1` to the Adaptable CA scripts folder, typically `C:\Program Files\Venafi\Scripts\AdaptableCA`.
2. Edit the configuration block in the script: `$global:ServerHost`, `$global:ServerPort`, `$global:ContainerName` and `$global:IssuingCertificate`. For multiple KMES servers or issuing certificates, make additional copies of the script with different file names.
3. Edit `$SdkUri`, `$SdkUser` and `$SdkPass` in `FuturexCreateCustomFields.ps1` and run it once per server. Do not place it in the Adaptable CA folder. It creates the optional custom fields for the KMES approval group and X.509 extension profiles.

## Configuration

1. In the Policy Tree, add a **Username Credential** for each KMES identity and a **Certificate Credential** from the exported PKCS #12 file.
2. Add a **CA Template > Adaptable** with the CA name, the username and certificate credentials, and **PowerShell Script** set to `Futurex KMES CA`. Set the custom fields if needed, then click **Validate** and **Save**.
3. Create a policy and select the CA template on its **Certificate** tab.

## Usage

1. Create a certificate in the policy with **Management Type** set to **Enrollment**.
2. If approvals are required, approve the request on the KMES under **Signing Workflow**.
3. In Certificate Manager, Self-Hosted, click **Retry** on the certificate if it is waiting for approval. Its status changes to **OK** once issued.

## Troubleshooting

Errors from the KMES Host API are shown in Certificate Manager, Self-Hosted. Include the full message when contacting Futurex support.

- `X509 SIGNING NOT ALLOWED`: the issuance policy does not allow uploads.
- `NO PERMISSIONS`: the identity lacks permission for the task.
- `INSUFFICIENT APPROVAL GROUP PERMISSION`: the role can view but not use the approval group.
- `INVALID REQUEST IDS`: the approving group cannot view the requests.
- `NOT ALLOWED TO APPROVE YOUR OWN UPLOAD`: the same user uploads and approves. Use separate users or enable **Allow single group for upload and approval** in the issuance policy.
- `BAD LOGIN ATTEMPT`: the username, password or permissions are wrong.
