# Ansible Collection

## Prerequisites

- Next-Gen Trust Security and an account that can request certificates in the zone you use.
- Python 3.6 or later.
- Ansible 2.15 or later.
- VCert-Python v0.18.0 or later.

## Installation

1. If you use Ansible Automation Platform, get the collection from Ansible Automation Hub and follow the instructions there. Then install VCert-Python:

   ```bash
   pip install vcert --upgrade
   ```

2. If you use Ansible Galaxy, install Ansible and VCert-Python, then install the collection:

   ```bash
   pip install ansible vcert --upgrade
   ansible-galaxy collection install venafi.machine_identity
   ```

You can also list `venafi.machine_identity` in a `requirements.yml` file, or download the tarball from [Ansible Galaxy](https://galaxy.ansible.com/ui/repo/published/venafi/machine_identity/).

## Usage

Each role includes examples:

- [`venafi.machine_identity.certificate` examples](https://github.com/Venafi/ansible-collection-venafi/tree/main/roles/certificate)

## Security Considerations

The `*_remote_execution` options are disabled by default. When enabled, Ansible sends your Next-Gen Trust Security credentials to every managed host. Keep the default local execution mode unless every managed host is secured to the same level as the Ansible controller.

## Additional Resources

- [Collection repository](https://github.com/Venafi/ansible-collection-venafi)
- [Using Ansible collections](https://docs.ansible.com/ansible/latest/collections_guide/index.html)
- [Red Hat Ansible Automation Platform certified content](https://access.redhat.com/support/articles/ansible-automation-platform-certified-content)
