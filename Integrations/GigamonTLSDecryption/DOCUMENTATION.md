# Gigamon TLS Decryption

This guide covers bulk certificate provisioning from Certificate Manager, Self-Hosted to GigaVUE nodes through GigaVUE-FM. It is based on the Gigamon GigaVUE-FM integration guide (GigaVUE-FM 5.x, September 2020).

Certificate and private key pairs are stored in the key store on GigaVUE nodes, where decryption happens. Certificate Manager, Self-Hosted does not connect to the nodes directly. It connects over HTTPS to the GigaVUE-FM API, and each provisioning operation names the GigaVUE node that receives the data. Every node must be managed by that GigaVUE-FM instance.

## Prerequisites

- GigaVUE-FM hostname or address and port.
- GigaVUE-FM logon credentials.
- The list of GigaVUE node or cluster names to provision.
- A mapping of which certificates go to which GigaVUE nodes.

## GigaVUE-FM Configuration

Adding a certificate and key pair to the key store does not enable decryption by default. For each GigaVUE HC Series appliance to be provisioned:

1. Unlock the key store with the keychain password.
2. Set **Auto Enable New Certificates** to `true` so new pairs are associated with decryption automatically.
3. Set **Auto Delete Certificates with Same Entity** to `true` so a renewed pair replaces the old one.
4. Set **Auto Delete Expired Certificates** to `true`.

## Installation

1. Copy `GigamonGigaVUE-FM.ps1` to the `Scripts\AdaptableBulk` folder under the Certificate Manager, Self-Hosted installation folder, for example `C:\Program Files\Venafi\Scripts\AdaptableBulk`.
2. `GigamonGigaVUE-FM-root.ps1` is an alternative version that retrieves the certificate with its full chain from the WebSDK on the local server before provisioning. It uses an extra **Venafi OAuth Token** field for that call.

## Configuration

Most configuration is done in the Web Admin console. Bulk provisioning jobs are configured in Aperture. The policy layout below is an example.

1. In the Policy Tree, under **Policy > TLS > Certificates**, add a policy named `Gigamon`.
2. In the `Gigamon` policy, add a device for GigaVUE-FM with a meaningful name and the GigaVUE-FM IP address.
3. Add a username credential with the GigaVUE-FM admin account and assign it to the device.
4. Add a policy to hold the bulk provisioning job objects, or reuse an existing one.
5. Create the certificates to provision, or use existing ones. Set **Management Type** to **Provisioning** and click **Renew Now** to issue new certificates.

## Usage

1. In Aperture, click **Jobs > Create New Job**, select **Bulk Provisioning** and click **Start**.
2. Select the jobs policy and click **Next**.
3. Set **Target** to the GigaVUE-FM device and **Source** to the policy folder that contains the certificates.
4. Select the options and schedule for your environment.
5. Set **PowerShell Script** to the Gigamon GigaVUE-FM driver and **Cluster ID** to the hostname or IP address of the GigaVUE node to provision.
6. Click **Create Job**, then wait for the schedule or click **Run Now**. Check **Results** for the outcome.

A single job provisions one GigaVUE node. Create a separate job for each node.

## Verification

1. In GigaVUE-FM, open **Physical Device** and select the GigaVUE node.
2. Go to **GigaSMART > Inline SSL > Key Store**.
3. Check that the certificate is listed. The **Key Alias** is built from the certificate common name and thumbprint, so several certificates with the same common name can coexist.
4. **Type** shows a check mark for both the certificate and the private key. **Health Status** shows whether the certificate is used in a flow, depending on **Auto Enable New Certificates**.
