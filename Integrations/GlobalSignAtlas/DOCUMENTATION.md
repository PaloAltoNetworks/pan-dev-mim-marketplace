# Venafi TPP-GlobalSign-Atlas-integration v1.0.1 README

The purpose of this README file is to provide information for the configuration of your GlobalSign Atlas service for integration with Venafi Trust Protection Platform (TPP).

Terms of Use will be governed by an applicable agreement with GMO GlobalSign to use Atlas services, together with an applicable agreement with Venafi, Inc. to use Trust Protection Platform.

## Integration 
GMO GlobalSign Atlas services integrate with Venafi’s Trust Protection Platform for the purpose of life cycle management of GlobalSign certificates. The integration enables the user to automate issuance, revocation and deployment of certificates for public and private CA use cases including:
-	Public Trust TLS/SSL
-	Private Dedicated TLS/SSL (issued from your dedicated private custom CA hierarchy Service provided by GlobalSign)
-	Machine/Device authentication certificates ((issued from your dedicated private custom CA hierarchy Service provided by GlobalSign)
-	Public Trust SMIME certificates for secure email 

## Prerequisites
-	GlobalSign Atlas Service(s) – See: https://www.globalsign.com/en/atlas#atlasform 
-	Venafi Trust Protection Platform 

This file (GlobalSign_Adaptable_Script.ps1) has the basic functions supported by adaptable CA template:
- Available Settings:
-	/login POST: 
	o	api_key
	o	api_secret
	Credentials are created in your Atlas account. Log in to Atlas with your credentials. The response will contain a token, which you must use when making other requests to the API. 	The token is valid for 10 minutes. 

-	/certificates POST
	Submit a request for a new certificate. The fields that must be supplied with this request are listed below under “Certificate Fields”.

-	/certificates/{certificate} GET | PATCH
	o	GET 	Retrieve a certificate. Place the certificate serial number in the {certificate} object.
	o	PATCH		Revoke a certificate. Place the certificate serial number in the {certificate} object.

-	/certificates/{certificate}/rekey POST
	/rekey	Submit a rekey request for an existing ISSUED certificate. The fields that must be supplied with this request are listed below under “Rekey Fields”

-	/trustchain GET
	Retrieve the chain of trust for the certificates in your account, starting with the issuing CA and ending with the root CA.

## Input Fields
	Certificate Fields:
	o	CSR
	o	validity not after (custom field - default NOW)
	o	validity not before (custom field)
	o	hash algorithm (custom field – default SHA-256)
	o	SAN domain
	o	email
    o	URI
	o	other names 
	o	common name
	o	OU (not allowed for public TLS)

Rekey Fields:
	o	CSR
	o	hash algorithm (custom field – default SHA-256)

## Usage and Support
For information or assistance in setting up a GlobalSign Atlas service for use with Venafi TPP please contact:
	 - Your Sales Account Manager and/or ‘solutions@globalsign.com’ 

For Support for using this Adaptable CA template with Venafi TPP, please contact Venafi

For general queries, please contact ‘technology-alliance@globalsign.com’ FOA Mike Boyle

Thank you

GlobalSign Technology Alliances and Integrations
www.globalsign.com 
