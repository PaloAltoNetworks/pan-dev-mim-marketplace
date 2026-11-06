# Google CAS Import

## Overview

Google CAS Import is an Adaptable CA integration that imports certificates from Google Certificate
Authority Service (CAS) into Certificate Manager, Self-Hosted. It runs as a Certificate Import job,
giving you a consolidated inventory of certificates issued by your Google CAS CA pools.

**SOLUTION HIGHLIGHTS**

- Automatically import Enterprise-tier certificates from Google CAS CA pools
- Runs as a scheduled Certificate Import job using the Adaptable framework
- Uses a Google service account with least-privilege viewer/auditor roles
- Centralizes visibility of cloud-issued certificates alongside the rest of your inventory

## Prerequisites

- A Google Cloud project with the Certificate Authority API enabled and at least one populated CA pool
- A Google service account with the `CA Service Auditor` and `Certificate Manager Viewer` roles
- The service account JSON key for credential configuration

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
