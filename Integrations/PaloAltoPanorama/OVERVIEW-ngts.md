# Palo Alto Panorama

Palo Alto Networks Panorama stores the certificates that your firewalls use for GlobalProtect portals and gateways, management interfaces and SSL Inbound Inspection, and pushes them out through templates. Next-Gen Trust Security discovers those certificates and provisions renewed ones through Panorama, so firewalls get new certificates without manual imports, bindings and commits.

**Value Highlights**

- **Prevent outages**: provision renewed certificates to Panorama and push them to your firewalls before the old ones expire.
- **Gain visibility**: discover certificates across Panorama's own configuration, templates, template stacks and virtual systems, with their bindings.
- **Automate bindings**: bind certificates to SSL/TLS Service Profiles or SSL Inbound Inspection Decryption Policy Rules.
- **Keep changes isolated**: Next-Gen Trust Security commits and pushes only the changes made by its own Panorama administrator.
- **Save rule capacity**: optionally replace the previous version of a certificate in a decryption rule instead of adding next to it.

**How it Works**

Next-Gen Trust Security connects to Panorama through a VSatellite, using a dedicated Panorama administrator with XML API privileges. Discovery reads the certificates in every Panorama location and reports each binding as an installation. Provisioning imports the certificate into the template, template stack or Panorama configuration you choose, binds it to the target, commits the change and pushes it to the firewalls. It works with a Panorama appliance in Panorama or Management Only mode. See the Documentation tab for setup.

**Solution Components**

- Next-Gen Trust Security
- VSatellite
- Palo Alto Networks Panorama
