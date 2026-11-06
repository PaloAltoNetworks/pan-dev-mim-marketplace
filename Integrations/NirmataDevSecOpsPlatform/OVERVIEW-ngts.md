# Nirmata DevSecOps Platform

Nirmata and Venafi automate machine identity management for Kubernetes clusters independent of how and where the clusters are deployed. This integration enables secure self-service for developers and simplifies certificate management.

  

**SOLUTION HIGHLIGHTS**

- **Enable Secure Self-Service** for Developers
- **Eliminate overhead** in managing machine identities
- **Ensure compliance** with corporate standards
- **Prevent downtime **related to certificate expiration
- **Availability of cert-manager **as an add-on
- **Ability to configure** cluster issuers
- **Use policies to ensure **valid certificates are genera

  

**SOLUTION OVERVIEW**

Machine identity management is a critical requirement for Kubernetes clusters and workloads. Automating the self-service creation and renewal of certificates is necessary to enable secure self-service for developers deploying applications on Kubernetes clusters. This improves developer agility without compromising on security.

  

Cert-manager from Jetstack is a popular open-source tool that automates issuing certificates on-demand using Kubernetes APIs, as well as renewing the certificates before they expire. Cert-manager comes with support for commonly-used certificate issuers and can be extended to support others as needed. cert-manager allows you to restrict who can use each issuer, allowing you to apply policy within your organization.

  

The Nirmata DevSecOps Platform (NDP) enables secure self-service for developers. It allows various critical add-ons such as Kyverno for policy management, to be automatically be deployed when a new cluster is created. Now, cert-manager support has been added as well. In addition to cert-manager deployment, users can also create cluster issuers directly from NDP. 

  

**HOW IT WORKS**

- Cert-manager is already in the catalog and is now available to be deployed as an add-on to any cluster. Cert-manager can be selected when creating a cluster type so cert-manager is deployed to any cluster created with that cluster type. 
- Once cert-manager is deployed, it can be automatically upgraded whenever a new commit is made to the git repository or if a new branch is selected in the Git settings for cert-manager. This process can be used to upgrade cert-managers deployed on multiple clusters at the same time.
- The following cluster issuers can be created on any cluster that has cert-manager deployed:

- Self Signed
- CA
- Vault
- Venafi

  

**About Nirmata**

Nirmata is the creator of Kyverno, now a CNCF incubating project with over 1 billion downloads. Kyverno has become the de facto solution for Kubernetes policy enforcement and management. Nirmata provides Nirmata Enterprise for Kyverno. It is an enterprise-grade distribution of Kyverno with long-term support, designed to save time and costs for production users.
