# HashiCorp Vault Adaptable CA

## Overview

This Adaptable CA integration enables Certificate Manager, Self-Hosted to enroll and manage
certificates issued by the HashiCorp Vault PKI secrets engine. It lets you use Vault as a
certificate authority while retaining centralized lifecycle management, policy, and visibility in
Certificate Manager.

**SOLUTION HIGHLIGHTS**

- Issue and manage certificates from a HashiCorp Vault PKI intermediate CA
- Bring Vault-issued certificates under centralized lifecycle management
- Configurable Vault URL, root path, issuer path, and issuer role

## Prerequisites

- A reachable HashiCorp Vault instance with the PKI secrets engine enabled and an issuer role configured
- Vault connection details (URL, root path, issuer path, issuer role) available for the script

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
