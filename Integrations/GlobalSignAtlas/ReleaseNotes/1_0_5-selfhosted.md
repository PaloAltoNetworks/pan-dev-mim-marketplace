#### Added
- `proxy_required` configuration flag — set to `$true` to require a proxy URL to be configured (requests fail fast with a clear error instead of silently connecting without a proxy).
- Proxy authentication again supports explicit `AuxUser`/`AuxPass` credentials on the CA definition (reinstating the path removed in 1.0.4), falling back to the system's default credentials when they're not both set.
- Connection failures during login are now classified and reported with a specific, actionable message: DNS resolution, TLS/certificate, proxy connectivity, or generic network errors are each distinguished instead of being reported as a generic authentication failure.
- A malformed `proxy_url` is validated up front and reported as a proxy configuration error, rather than surfacing later as a confusing authentication failure.

#### Fixed
- The `Authorization` header could be silently omitted when `AuthToken` was an empty string rather than `$null` (PowerShell string parameters are never actually `$null`); the check now correctly tests for an empty string too.
- Corrected a typo in the missing-password error message ("in teh Password field" → "in the Password field").
