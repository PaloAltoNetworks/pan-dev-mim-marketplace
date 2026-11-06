# Set Management Type After Onboard Discovery

An Adaptable Log that sets the 'Management Type' attribute for certificates to desired state after an Onboard Discovery event.

Definition for fields used are as follows:
* **Service Address**: <Static URI of TPP WebSDK or https://$WebSdkFQDN$/Vedsdk>
* **Credential**: Optional *Username* credential object having username and password to obtain API Key from WebSDK (**legacy auth method**). The API user should be a master admin OR have manage rights on all certificates found by Onboard Discovery 
* **Secondary Credential**: A *Password* credential object having valid OAuth token for WebSDK (**recommended auth method**). Scope associated with the OAuth token should be *configuration:manage* and *certificate:manage*
* **PowerShell Script**: < This Script >
* **Associated Applications**: $Config[$Event.Text2$,"Consumers", ",\"]$
* **Certificate Object GUID**: $GUID[$Event.Text2$]$
* **Created By**: $Config[$Event.Text2$,Created By]$
* **Application Types in scope**: <An optional filter of comma separated Application object's class names that will be matched before the Management Type of associated certificate is updated>
* **Management Type to set**: ONE of (Provisioning, Enrollment, Monitoring, Unassigned)


## Setup Instructions

1.  Create a new Adaptable Log object with the script.
2.  Set the parameters in GUI as per your requirements.
3.  Create a new Notification Rule that targets this Adaptable Log, having a rule of *Event ID* matches *Onboard Discovery - New Certificate*.
4.  If you would like to include discovered certificates already managed by TPP then add an *or* rule to above *Event ID* matches *Onboard Discovery - Managed Certificate*

## Internal Logic

* If the optional filter (of app object class names) is set in the Adaptable Log object then app object class names associated with the certificate are cross-referenced with the filter. No match assumes this certificate is not in-scope so no change is made and success is reported back to the TPP engine. 
* If the optional filter is **not** set then we always attempt to update **Management Type** of the certificate.
* Verify currently inherited/effective setting that applies to this certificate. If the effective policy already matches desired state then no change is made.
* Where **Management Type** is changed for the certificate object, verify the new inherited/effective setting applying on this certificate object.
* If the inherited/effective **Management Type** after the change matches the desired state then *Success* is reported otherwise *Failure* is reported back to TPP engine.
* Failure due to locked policy value is prepended with **-103:** for e.g. -103: Failure! < *more info* >. This specifc error code returned to TPP engine can be used in other Notification Rules. 
* Logging is always enabled in TPP_HOME\Logs folder.
* Debug logging can be optionally enabled by checking the *Enable Debug Logging* in the Adaptable Log object's setting.

