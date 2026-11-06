#### Changed
- Default proxy configuration changed: `proxy_url` now defaults to empty (no proxy) instead of the placeholder `http://proxy:port`.

#### Breaking Changes
- Proxy support no longer requires `AuxUser`/`AuxPass` credentials on the CA definition. Setting `proxy_url` now routes requests through that proxy using the system's default credentials; the previous explicit username/password proxy authentication path has been removed.
