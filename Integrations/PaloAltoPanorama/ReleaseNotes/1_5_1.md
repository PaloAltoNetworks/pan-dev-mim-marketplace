#### Added
- Downloadable driver package (`.vupkg`) containing the Panorama Adaptable Application driver and a full installation and usage guide.

#### Fixed
- Fixed wildcard certificates (e.g. `*.example.com`) failing to import because PAN-OS object names don't permit `*`; the character is now replaced with `WILDCARD`, with the name truncated as needed to stay within Panorama's 31-character object name limit.
