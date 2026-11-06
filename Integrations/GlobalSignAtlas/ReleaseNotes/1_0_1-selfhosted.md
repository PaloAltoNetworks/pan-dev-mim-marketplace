#### Fixed
- `validity_not_before` custom field now also accepts a date-only value (`yyyy-MM-dd`) in addition to a full timestamp (`yyyy-MM-dd HH:mm:ss`).
- Corrected the trust chain error message (removed a stray "xxx" prefix).

#### Changed
- Certificate validity timestamps (`not_before`/`not_after`) are now converted to Unix time using `DateTimeOffset`, removing a locale-dependent conversion that could produce incorrect values on non-US locales.
