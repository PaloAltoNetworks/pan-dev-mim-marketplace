# Google CAS Import

Certificates issued from Google Cloud Certificate Authority Service (CAS) are easy to lose track of when they live only in the Google Cloud console. Google CAS Import brings those certificates into Certificate Manager, Self-Hosted, so you get one inventory that covers certificates issued by your Google CAS CA pools alongside the rest of your certificates.

**Value Highlights**

- **Consolidate inventory**: Import certificates from every Google CAS CA pool in a project, across all locations.
- **Keep the inventory current**: Run the import on a schedule as a Certificate Import job.
- **Control scope**: Choose whether the job imports revoked and expired certificates.
- **Use least privilege**: Connect with a Google service account that has only viewer and auditor roles.

**How it Works**

Google CAS Import is an Adaptable CA PowerShell script for Certificate Manager, Self-Hosted. You copy the script to your engine servers and create a Certificate Import job that uses it. On each run, the script authenticates to Google Cloud with a service account key, lists the CA pools in the project, and imports the certificates it finds into the placement folder you choose. Only Enterprise-tier CA pools support certificate listing, so certificates from DevOps-tier pools are not imported. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted with the Adaptable framework
- Google Cloud Certificate Authority Service
- `Google CAS Import.ps1` (included in this listing)

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
