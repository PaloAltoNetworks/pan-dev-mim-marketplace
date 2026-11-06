# Export from Venafi Cloud into TPP

Command line utility that exports certificates from the inventory of a Venafi Cloud OutagePREDICT
account and imports them into Trust Protection Platform. This project was created to help TPP
customers who are seeking a TrustNet-like solution. Certificates are imported into TPP using the
`POST discovery/import` WebSDK method (the same API endpoint used by the Scanafi discovery utility
to upload its results).

> **NOTE:** The full source is provided as a single downloadable archive
> (`export-from-venafi-cloud-into-tpp.zip`). Build it with the included `Makefile` (Go toolchain
> required) to produce the `vcloud2tpp` command line utility.

## Parameters

| Parameter              | Description                                                                   |
| ---------------------- | ----------------------------------------------------------------------------- |
| `-t`, `--access-token` | Access Token for TPP that has 'certificate:discover' scope (required)         |
| `-k`, `--api-key`      | API Key for Venafi Cloud (required)                                           |
| `--batch-size`         | Batch size for Venafi Cloud export pagination (default 100)                   |
| `--cloud-addr`         | Network address of Venafi Cloud API (default "api.venafi.cloud")              |
| `--days`               | Export only certificates added within the specified number of days            |
| `--debug`              | Create files showing POST discovery/import JSON, skipped certificates, etc.   |
| `-f`, `--folder-dn`    | TPP policy folder DN to target for imported certificates (required)           |
| `--insecure`           | Connect to network addresses without any TLS verification                     |
| `-a`, `--tpp-addr`     | Network address of Trust Protection Platform WebSDK API (required)            |

## Example

To export all of the certificates added to the Venafi Cloud inventory in the last 30 days and import
them into a top level policy folder called "From Venafi Cloud" you would run the following:

```bash
vcloud2tpp -k "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" \
           -a "tpp.venafi.example" -t "Ab01Cd23Ef45Uv67Wx89Yz==" \
           -f "\VED\Policy\From Venafi Cloud" --batch-size 25 --days 30
```
