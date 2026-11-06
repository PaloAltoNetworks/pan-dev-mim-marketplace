# Ansible Collection

This **Red Hat-certified **solution is an Ansible collection with a set of Venafi machine identity management roles. Customers of Red Hat can access it in Ansible Automation Hub.

These roles enable infrastructure automation teams to leverage core machine identity management operations supported by Next-Gen Trust Security in Ansible based automation workflows. This not only simplifies and streamlines the certificate enrollment process in infrastructure provisioning workflows and enabling security from the beginning of application delivery process but also ensures compliance with enterprise security policies managed by InfoSec team by providing them a 360-degree visibility to all machine identities used in infrastructure.

**Applicability**

Any organization that is automating the provisioning of infrastructure and have Next-Gen Trust Security deployed as the single pane of glass for all machine identities would find this valuable.

**Limitations and special notes**

This collection of Ansible roles is licensed under Apache 2.0.

This set of Ansible collection includes four specific roles:

- [venafi.machine_identity.certificate](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/certificate/README.md): Enrolls a certificate and optionally deploys it to a remote location.
- [venafi.machine_identity.policy](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/policy/README.md): Creates or updates certificate policy on Next-Gen Trust Security using a specification file.
- [venafi.machine_identity.ssh_certificate](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/ssh_certificate/README.md): Enrolls an SSH certificate using Certificate Manager, Self-Hosted.
- [venafi.machine_identity.ssh_ca](https://github.com/Venafi/ansible-collection-venafi/blob/main/roles/ssh_ca/README.md): Retrieves public keys of SSH certificate authorities hosted by Certificate Manager, Self-Hosted.

**ADDITIONAL RESOURCES**

- Red Hat certified: [https://access.redhat.com/support/articles/ansible-automation-platform-certified-content](https://access.redhat.com/support/articles/ansible-automation-platform-certified-content)
- Using Ansible collections: [https://docs.ansible.com/ansible/latest/collections_guide/index.html](https://docs.ansible.com/ansible/latest/collections_guide/index.html)
- Galaxy User Guide: [https://docs.ansible.com/ansible/latest/galaxy/user_guide.html](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html)
- Github repo: [https://github.com/Venafi/ansible-collection-venafi](https://github.com/Venafi/ansible-collection-venafi)

**Get it to work **

This Ansible Collection is certified by Red Hat, if you have access the content in Ansible Automation Hub, it is recommend that you access the content there and follow the provided instructions.

Alternatively, to install, you can run the following command (assuming ansible-galaxy is properly installed and available in your environment):

*ansible-galaxy collection install venafi.machine_identity*

Thirdly, you can download the tarball file on [Ansible Galaxy](https://galaxy.ansible.com/venafi/machine_identity).

**Example usage**

This collection provides four Ansible roles, each role is accompanied with specific examples.

Role: *venafi.machine_identity.certificate*

Link to examples: [https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/certificate/examples](https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/certificate/examples)



Role:* venafi.machine_identity.policy*

Link to example: [https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/policy](https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/policy)



Role: *venafi.machine_identity.ssh_certificate*

Link to example: [https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/ssh_certificate](https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/ssh_certificate)



Role: *venafi.machine_identity.ssh_ca*

Link to example: [https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/ssh_ca](https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/ssh_ca)

**ABOUT Red Hat**

Red hat is the world’s leading provider of enterprise open source solutions—including Linux, cloud, container, and Kubernetes. We deliver hardened solutions that make it easier for enterprises to work across platforms and environments, from the core datacenter to the network edge.
