#### Fixed
- Re-enabled redaction of sensitive fields (`UserPass`, `AuxPass`, `PfxPass`, `Certificate`, `PfxData`) in debug logs; these were previously being logged in plaintext.
- Trust chain PKCS7 output is now joined into a single PEM blob with proper line breaks, fixing malformed certificate chain downloads.
- Certificate submission and rekey now share a `Get-IdFromResponse` helper that throws a clear "Unexpected response from server." error instead of silently returning a blank certificate ID when the server response doesn't match the expected format.
- Fixed a bug where the pending-certificate response referenced an undefined `null` value instead of PowerShell's `$null`.
- `validity_not_after` parsing failures now throw a clear "Provided validity_not_after is not valid." error instead of an unhandled exception.

#### Changed
- Revocation reason codes renumbered: `cACompromise` (2) is explicitly marked unsupported, `affiliationChanged` moves to 3, `superseded` to 4, `cessationOfOperation` to 5.
- API request/response debug logging now always emits the request line; full JSON body logging remains gated by the driver's `Logging` flag.

#### Breaking Changes
- A date-only `validity_not_before` value is now rejected unless it equals today's date. Previously any future date was silently accepted.
