# Ansible Collection

Infrastructure automation teams provision servers and applications with Ansible, but certificates are often requested by hand or with ad hoc scripts. That slows delivery and leaves certificates outside the policies and visibility the security team relies on.

The `venafi.machine_identity` collection is a Red Hat certified Ansible collection that brings Certificate Manager, SaaS into Ansible workflows. Teams enroll and deploy certificates as part of provisioning, while every certificate follows enterprise policy and stays visible to the security team.

**Value Highlights**

- **Build security in from the start** by enrolling certificates during infrastructure provisioning.
- **Enforce enterprise policy** on every certificate that automation requests.
- **Deploy certificates to managed hosts** as part of the same playbook.
- **Manage policy as code** by creating or updating certificate policy from a specification file.
- **Use certified content** available in Ansible Automation Hub, with support through Ansible Automation Platform.

**How it Works**

The collection uses the VCert Python library to call Certificate Manager, SaaS. Playbooks use these roles:

- [`venafi.machine_identity.certificate`](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/certificate/README.md): enrolls a certificate and optionally deploys it to a remote location.
- [`venafi.machine_identity.policy`](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/policy/README.md): creates or updates certificate policy in Certificate Manager, SaaS from a specification file.

By default, credentials stay on the Ansible controller and only certificate files are copied to managed hosts. See the Documentation tab for installation and examples.

**Solution Components**

- Certificate Manager, SaaS
- Ansible Automation Platform or Ansible with Ansible Galaxy
- The `venafi.machine_identity` collection, licensed under Apache 2.0

**About Red Hat**

[Red Hat](https://www.redhat.com/) provides enterprise open source solutions, including Linux, cloud, container and Kubernetes technologies, and the Ansible Automation Platform.

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
