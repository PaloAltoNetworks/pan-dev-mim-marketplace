# Nokia NetGuard Certificate Manager (ncm-issuer)

## Prerequisites

- A Kubernetes cluster (AWS EKS, AWS EKS Anywhere, Azure AKS, Azure Arc, Google GKE or Google Anthos)
- cert-manager v1.0.0 or later
- Nokia NetGuard Certificate Manager v21 or later, with REST API credentials

## Installation

ncm-issuer is released as a Helm chart. From a clone of the [ncm-issuer repository](https://github.com/nokia-steward/ncm-issuer), run:

```bash
helm install -n ncm-issuer ncm-issuer ./helm/.
```

## Configuration

ncm-issuer authenticates to the NCM REST API, so you need valid NCM credentials before you create an Issuer or ClusterIssuer. See the [ncm-issuer README](https://github.com/nokia-steward/ncm-issuer) for credential, TLS and resource configuration.
