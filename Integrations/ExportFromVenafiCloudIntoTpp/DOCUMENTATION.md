# Export from Certificate Manager, SaaS into Self-Hosted

## Prerequisites

- Go toolchain to build the `vcloud2tpp` binary from the included source archive.
- A Certificate Manager, SaaS API key.
- A Certificate Manager, Self-Hosted WebSDK access token with the `certificate:discover` scope.
- Network access to both the Certificate Manager, SaaS API and the Certificate Manager, Self-Hosted WebSDK API.

## Installation

1. Download and extract `export-from-venafi-cloud-into-tpp.zip`.
2. Run `make build` in the extracted folder. Binaries for Linux, macOS and Windows are written to `bin/<os>/vcloud2tpp`.

## Configuration

| Parameter | Description |
| --- | --- |
| `-t`, `--access-token` | Certificate Manager, Self-Hosted access token with the `certificate:discover` scope (required) |
| `-k`, `--api-key` | Certificate Manager, SaaS API key (required) |
| `--batch-size` | Batch size for Certificate Manager, SaaS export pagination (default 100) |
| `--cloud-addr` | Network address of the Certificate Manager, SaaS API (default `api.venafi.cloud`) |
| `--days` | Export only certificates added within the specified number of days |
| `--debug` | Create files showing the `POST discovery/import` JSON, skipped certificates and similar detail |
| `-f`, `--folder-dn` | Certificate Manager, Self-Hosted policy folder DN to target for imported certificates (required) |
| `--insecure` | Connect to network addresses without any TLS verification |
| `-a`, `--tpp-addr` | Network address of the Certificate Manager, Self-Hosted WebSDK API (required) |

## Usage

To export all certificates added to the Certificate Manager, SaaS inventory in the last 30 days and import them into a top-level policy folder called "From SaaS", run:

```bash
vcloud2tpp -k "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" \
           -a "tpp.venafi.example" -t "Ab01Cd23Ef45Uv67Wx89Yz==" \
           -f "\VED\Policy\From SaaS" --batch-size 25 --days 30
```
