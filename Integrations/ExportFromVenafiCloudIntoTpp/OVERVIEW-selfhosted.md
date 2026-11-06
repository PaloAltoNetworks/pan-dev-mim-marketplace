# Export from Venafi Cloud into TPP

## Overview

Export from Venafi Cloud into TPP is a command line utility that exports certificates from a Venafi
Cloud (OutagePREDICT) account inventory and imports them into Certificate Manager, Self-Hosted. It
was created to help self-hosted customers seeking a TrustNet-like solution, using the same
`POST discovery/import` WebSDK method that the Scanafi discovery utility uses to upload results.

**SOLUTION HIGHLIGHTS**

- Migrate/consolidate certificate inventory from Venafi Cloud into Certificate Manager, Self-Hosted
- Uses the standard WebSDK `discovery/import` endpoint, targeting a policy folder you choose
- Configurable export batch size and a "last N days" filter for incremental syncs
- Optional debug output showing the import JSON and any skipped certificates

## Prerequisites

- Go toolchain to build the `vcloud2tpp` binary from the included source archive (a `Makefile` is provided)
- A Venafi Cloud API key
- A TPP WebSDK access token with the `certificate:discover` scope
- Network access to both the Venafi Cloud API and the TPP WebSDK API

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
