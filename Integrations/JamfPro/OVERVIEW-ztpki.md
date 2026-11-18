# Jamf Pro

Apple devices managed by Jamf Pro need trusted device and user certificates, and issuing and renewing them by hand does not scale. This integration connects Zero Touch PKI with Jamf Pro to deliver certificates to Apple devices over SCEP, automating trusted identities for macOS, iOS and iPadOS fleets.

**Value Highlights**

- **Automate enrollment**: Issue device and user certificates to managed Apple devices through Jamf Pro SCEP payloads.
- **Renew automatically**: Profile redistribution settings renew certificates before they expire.
- **Establish trust**: Distribute the Zero Touch PKI root and issuing CA certificates with Jamf configuration profiles.
- **Target the right devices**: Scope device and user profiles to the groups that need them.

**How it Works**

Zero Touch PKI provides a standard SCEP endpoint authenticated by a static challenge password. Jamf Pro configuration profiles distribute the trust chain and request device and user certificates through SCEP payloads, and renewal is driven by each profile's redistribution setting. See the Documentation tab for setup.

**Solution Components**

- Zero Touch PKI with a SCEP-enabled certificate policy
- Jamf Pro and enrolled Apple devices (macOS, iOS and iPadOS)

**About Jamf**

[Jamf](https://www.jamf.com/) builds Apple device management and security software for organizations.
