# Entrust Certificate Services

Teams that buy public TLS certificates from Entrust often request and renew them by hand in the Entrust portal, which makes it hard to see who is using certificates and to enforce policy. The Entrust connector in Next-Gen Trust Security lets you request and renew Entrust certificates from the same place you manage the rest of your certificate inventory.

Once the Entrust account is connected, certificate requests follow your Next-Gen Trust Security request policies, and issuance and renewal run without logging in to Entrust.

**Value Highlights**

- **Gain visibility** into demand for and use of Entrust certificates across the organization.
- **Enforce policy** by routing every Entrust request through Next-Gen Trust Security request policies.
- **Automate renewal** so Entrust certificates are replaced before they expire.
- **Support your Entrust contract** with both Pooling/Non-pooling and FLEX pricing models.
- **Reduce manual work** by removing logins to the Entrust portal for routine requests.

**How it Works**

You add Entrust as a certificate authority in Next-Gen Trust Security using an Entrust API user, its API key and an API client certificate with the Client Authentication EKU. After the account validates, you select it in one or more request policies, and certificates requested under those policies are issued by Entrust. Entrust Custom Fields are not supported, so they must not be required for the API user. See the Documentation tab for setup steps.

**Solution Components**

- Next-Gen Trust Security
- Entrust Certificate Services account with API access
