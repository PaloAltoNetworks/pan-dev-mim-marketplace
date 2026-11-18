# Federated Authentication Service (FAS)

FAS is configured as a use case of the Zero Touch PKI Auto-Enrollment Connector (AEC). There is no separate FAS connector. See the [Auto-Enrollment Connector documentation](https://docs.cyberark.com/mis-saas/ztpki/connectors/aec-overview/) for connector setup.

## Prerequisites

- A Zero Touch PKI account with an issuance policy suitable for smart-card logon or client authentication certificates.
- A deployed Zero Touch PKI Auto-Enrollment Connector. See the AEC overview for its Windows Server, Active Directory and network prerequisites.
- Citrix Federated Authentication Service, with permission to configure its certificate authority and Remote Host settings.

## Configuration

1. Deploy and configure the AEC so it fronts Active Directory for Zero Touch PKI. Install the connector, import the Zero Touch PKI CA chain, and map the logon certificate template to a Zero Touch PKI issuance policy.
2. In the FAS configuration, add the AEC as the certificate authority using a Remote Host configuration.
3. Validate federated logon by signing in through Citrix with a FAS-issued certificate and confirming it was issued by Zero Touch PKI.
