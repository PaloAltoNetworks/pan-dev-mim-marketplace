# Ansible Collection

Infrastructure automation teams provision servers and applications with Ansible, but certificates are often requested by hand or with ad hoc scripts. That slows delivery and leaves certificates outside the policies and visibility the security team relies on.

The `venafi.machine_identity` collection is a Red Hat certified Ansible collection that brings Certificate Manager, Self-Hosted into Ansible workflows. Teams enroll and deploy certificates as part of provisioning, while every certificate follows enterprise policy and stays visible to the security team.

**Value Highlights**

- **Build security in from the start** by enrolling certificates during infrastructure provisioning.
- **Enforce enterprise policy** on every certificate that automation requests.
- **Deploy certificates to managed hosts** as part of the same playbook.
- **Issue SSH certificates** and retrieve SSH CA public keys from Certificate Manager, Self-Hosted.
- **Manage policy as code** by creating or updating certificate policy from a specification file.
- **Use certified content** available in Ansible Automation Hub, with support through Ansible Automation Platform.

**How it Works**

The collection uses the VCert Python library to call Certificate Manager, Self-Hosted. Playbooks use these roles:

- [`venafi.machine_identity.certificate`](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/certificate/README.md): enrolls a certificate and optionally deploys it to a remote location.
- [`venafi.machine_identity.policy`](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/policy/README.md): creates or updates certificate policy in Certificate Manager, Self-Hosted from a specification file.
- [`venafi.machine_identity.ssh_certificate`](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/ssh_certificate/README.md): enrolls an SSH certificate.
- [`venafi.machine_identity.ssh_ca`](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/ssh_ca/README.md): retrieves the public keys of SSH certificate authorities hosted by Certificate Manager, Self-Hosted.

By default, credentials stay on the Ansible controller and only certificate files are copied to managed hosts. See the Documentation tab for installation and examples.

**Solution Components**

- Certificate Manager, Self-Hosted
- Ansible Automation Platform or Ansible with Ansible Galaxy
- The `venafi.machine_identity` collection, licensed under Apache 2.0

**About Red Hat**

[Red Hat](https://www.redhat.com/) provides enterprise open source solutions, including Linux, cloud, container and Kubernetes technologies, and the Ansible Automation Platform.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
