#### Fixed
- Removed the restriction that rejected certificate requests containing more than one type of Subject Alternative Name.
- Corrected a typo in the revocation reason mapping (`superseeded` → `superseded`).
- API error handling now falls back to the underlying exception message when the CA's error response has no `description` field, instead of returning an empty string.
