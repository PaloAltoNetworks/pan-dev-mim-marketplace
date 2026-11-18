# BMC Enterprise Connector for Venafi

Certificates used by RACF, TSS and ACF2 on IBM z/OS are often managed separately from the rest of the enterprise, which makes them hard to track and easy to miss at renewal time. This listing brings those mainframe certificates under Certificate Manager, Self-Hosted through BMC Enterprise Connector for Venafi.

**Value Highlights**

- **Manage mainframe certificates centrally**: Handle RACF, TSS and ACF2 certificates on z/OS alongside the rest of your certificate inventory.
- **Automate renewals**: Use Certificate Manager, Self-Hosted to renew certificates on the mainframe before they expire.
- **Apply consistent policy**: Enforce the same certificate policies on z/OS as on distributed systems.
- **Match your connector version**: Pick the driver script built for your Enterprise Connector for Venafi release, from SPE2304 through SPE2507.

**How it Works**

Each Adaptable Driver script runs on Certificate Manager, Self-Hosted and communicates with BMC Enterprise Connector for Venafi, which applies the certificate operations to RACF, TSS or ACF2 on z/OS. Enterprise Connector for Venafi is under continuous development, and new versions add features that need matching driver changes, so each connector version has its own script and its own set of BMC-supplied DLLs. A mismatched script and DLL pair is not supported. See the Documentation tab to choose the right script and install it.

**Solution Components**

- Certificate Manager, Self-Hosted
- BMC Enterprise Connector for Venafi
- RACF, TSS or ACF2 on IBM z/OS

**About BMC Software**

[BMC Software](https://www.bmc.com/) provides IT operations and mainframe management software. Contact BMC Software for support requests regarding Enterprise Connector for Venafi or these scripts.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
