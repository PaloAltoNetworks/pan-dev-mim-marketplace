# Oracle Cloud Load Balancer

Oracle Cloud Infrastructure (OCI) load balancers terminate TLS with certificate bundles attached to HTTPS and SSL listeners. OCI doesn't let you change a bundle after upload, so renewing a certificate means uploading a new bundle, moving each listener to it, and deleting the old one.

Next-Gen Trust Security discovers the certificate bundles on your OCI load balancers and runs that renewal sequence for you.

**Value Highlights**

- **Discover bundles and listeners**: Find each certificate bundle on the active load balancers in a region, with one installation for each listener that uses it.
- **Move every listener**: Upload a new bundle and move each listener that used the old bundle to it, keeping protocols, cipher suites, and hostnames.
- **Remove old bundles**: Delete the previous bundle once no listener or backend set uses it.
- **Use least privilege**: Grant `use load-balancers`, or `read load-balancers` for discovery only. Next-Gen Trust Security never creates or deletes load balancers.
- **Filter discovery**: Limit discovery to one compartment or to load balancers whose name contains a given text.

**How it Works**

Each machine covers one region and connects directly to OCI as a dedicated user with an API signing key. Next-Gen Trust Security applies each change as an OCI work request and waits for it to finish before starting the next.

It doesn't change backend sets, and listeners that use certificates from the OCI Certificates service aren't supported. This machine type is currently a preview feature. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Oracle Cloud Infrastructure Load Balancer
- OCI user with an API signing key and a load balancer policy
