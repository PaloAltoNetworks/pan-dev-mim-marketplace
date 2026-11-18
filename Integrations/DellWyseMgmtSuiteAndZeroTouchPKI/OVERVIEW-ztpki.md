# Dell Wyse Mgmt Suite and Zero Touch PKI

Thin clients need unique, trusted certificates for network access such as 802.1X, and issuing them by hand does not scale across a fleet. Pairing Dell Wyse Management Suite with Zero Touch PKI lets each managed device enroll for its own certificate automatically, issued by a hosted CA that you do not have to build or run.

**Value Highlights**

- **Automate enrollment**: Devices request and receive certificates without manual provisioning on each thin client.
- **Issue unique device identities**: Each thin client gets its own certificate, for example named from its serial number.
- **Secure network access**: Use the certificates for 802.1X authentication on wired and wireless networks.
- **Skip running your own CA**: Zero Touch PKI provides the certificate authority as a managed service.
- **Manage from one console**: Certificate settings are delivered through the Wyse Management Suite policies you already use.

**How it Works**

Wyse Management Suite supports the Simple Certificate Enrollment Protocol (SCEP) in its device policy groups. Administrators point the SCEP configuration at a Zero Touch PKI SCEP endpoint and define the certificate attributes, and Wyse Management Suite publishes the policy to the thin client group. Each thin client then enrolls with Zero Touch PKI and installs the issued certificate.

**Solution Components**

- Zero Touch PKI
- Dell Wyse Management Suite and the managed Wyse thin clients
