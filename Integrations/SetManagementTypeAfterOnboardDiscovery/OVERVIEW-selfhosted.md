# Set Management Type After Onboard Discovery

## Overview

This Adaptable Log integration sets the **Management Type** attribute for certificates to a desired
state after an Onboard Discovery event in Certificate Manager, Self-Hosted. Triggered by a
Notification Rule, it lets you automatically bring newly discovered (or already managed) certificates
into the correct management posture, with optional filtering by application object class.

**SOLUTION HIGHLIGHTS**

- Automatically set Management Type (Provisioning, Enrollment, Monitoring, or Unassigned) post-discovery
- Optionally filter which certificates are updated by associated application class names
- Respects locked/effective policy values and reports precise success/failure codes back to the engine
- Supports both OAuth token (recommended) and legacy username/password authentication

## Prerequisites

- WebSDK access via an OAuth token with `configuration:manage` and `certificate:manage` scope
  (or a legacy Username credential with equivalent rights)
- A Notification Rule targeting this Adaptable Log for the Onboard Discovery events

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
