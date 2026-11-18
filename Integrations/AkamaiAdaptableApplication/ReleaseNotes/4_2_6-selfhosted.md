#### Fixed
- Fixed new certificate enrollment failing with an authorization error when not using the Adaptable Workflow for Dual-Stack Certificates. The driver now requests only the `certificate:manage` OAuth scope for plain enrollment, and only requests `certificate:approve` when a Dual-Stack workflow ticket is actually being approved — previously it requested the approve scope unconditionally, which required granting approval rights even for standard enrollment.

#### Changed
- Updated the setup instructions: the base API Integration now requires `configuration:manage` and `certificate:manage` scopes, and the Dual-Stack workflow's API Integration update now requires only `certificate:approve` (not `certificate:approve,manage`).
