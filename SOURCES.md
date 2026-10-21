# Sources

Accessed 21 October 2026. Prefer the official PHP advisory and your vendor's security notice for final decisions.

## Official PHP

- PHP security advisory: **Critical remote code execution vulnerabilities, update now**  
  https://www.php.net/archive/2026.php#2026-10-21-5
- PHP 8.5.12 release: https://www.php.net/archive/2026.php#2026-10-21-4
- PHP 8.4.27 release: https://www.php.net/archive/2026.php#2026-10-21-3
- PHP 8.3.36 release: https://www.php.net/archive/2026.php#2026-10-21-2
- PHP 8.2.35 release: https://www.php.net/archive/2026.php#2026-10-21-1
- Upcoming release notice: https://www.php.net/archive/2026.php#2026-10-20-1

## GitHub security advisories

- **CVE-2026-109618** — RCE via OOM corruption  
  https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w
- **CVE-2026-109619** — RCE via stale global state  
  https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp

## Independent analysis

- watchTowr FAQ (tracking and status):  
  https://watchtowr.com/intelligence/php-cve-2026-109618-faq/
- CloudLinux package availability:  
  https://cloudlinux.zendesk.com/hc/en-us/articles/31194180517916-PHP-CVE-2026-109618-CVE-2026-109619-reported-pre-disclosure-RCEs-updated-package-availability
- CERT-EU advisory:  
  https://cert.europa.eu/publications/security-advisories/2026-018

## Vulnerability databases

- NVD CVE-2026-109618: https://nvd.nist.gov/vuln/detail/CVE-2026-109618
- NVD CVE-2026-109619: https://nvd.nist.gov/vuln/detail/CVE-2026-109619
- CISA KEV catalog: https://www.cisa.gov/known-exploited-vulnerabilities-catalog

## Vendor and distro checks

Check these before declaring a host patched:

- Ubuntu security notices: https://ubuntu.com/security/notices
- Debian security tracker: https://security-tracker.debian.org/tracker/
- Red Hat security advisories: https://access.redhat.com/security/security-updates/
- SUSE security advisories: https://www.suse.com/support/security/
- Alpine secdb: https://security.alpinelinux.org/
- CloudLinux status: https://cloudlinux.statuspage.io/
- cPanel security: https://support.cpanel.net/hc/en-us
- Plesk security: https://support.plesk.com/hc/en-us

## Notes

- The nickname "PHP2Shell" is used by watchTowr and others; it is not an official PHP project name.
- Fixed versions: PHP 8.5.12, 8.4.27, 8.3.36, 8.2.35.
- PHP 8.1 and older are unsupported upstream. Minimal backport branches exist for 7.4, 8.0, and 8.1.
- PHP 8.2 reaches end of life on 31 December 2026.
