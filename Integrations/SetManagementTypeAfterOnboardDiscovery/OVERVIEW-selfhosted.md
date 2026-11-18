# Set Management Type After Onboard Discovery

Certificates found by Onboard Discovery in Certificate Manager, Self-Hosted arrive with whatever Management Type their policy gives them, which is often not the posture you want. This Adaptable Log sets the **Management Type** attribute of those certificates to a desired state as soon as the Onboard Discovery event occurs, so newly discovered (or already managed) certificates are brought under the right level of management without manual follow-up.

**Value Highlights**

- **Set posture automatically**: Apply Provisioning, Enrollment, Monitoring or Unassigned right after discovery.
- **Target the right certificates**: Optionally limit updates to certificates whose associated applications match a list of application class names.
- **Respect policy**: Effective and locked policy values are checked, and no change is made when the certificate already matches.
- **Report precisely**: Success or failure is reported back to the engine, with a distinct `-103` code for locked policy values that other Notification Rules can act on.
- **Authenticate securely**: Use an OAuth token (recommended) or legacy username and password authentication to WebSDK.

**How it Works**

A Notification Rule triggers the Adaptable Log on the Onboard Discovery event. The script calls WebSDK to compare the certificate's effective Management Type with the desired value, updates it if needed, and then verifies the new effective setting before reporting the result. See the Documentation tab for field definitions and setup.

**Solution Components**

- Certificate Manager, Self-Hosted (Adaptable Log driver, Notification Rules, WebSDK)
- The `AdaptLog_-_set_Management_Type_after_OnboardDiscovery.ps1` PowerShell script

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
