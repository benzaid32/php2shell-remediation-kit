# Patch record: CVE-2026-109618 / CVE-2026-109619

Copy this file per host or per platform. Keep it with the change ticket.
Do not include passwords, tokens, customer data, or private keys.

## Asset

| Field | Value |
|---|---|
| Host / service | |
| Owner | |
| Environment | production / staging / internal |
| Internet-facing? | yes / no |
| Application(s) | |
| SAPI | mod_php / FPM / FrankenPHP / LSAPI / CGI / CLI |
| OS / distro | |
| Control panel | none / cPanel / Plesk / CloudLinux / other |

## Before

| Field | Value |
|---|---|
| PHP version (CLI) | |
| PHP version (web SAPI) | |
| Vendor package version | |
| PHP-FPM pool config(s) | |
| Relevant INI overrides | |
| `memory_limit` | |
| `post_max_size` | |
| `upload_max_filesize` | |
| `session.upload_progress.enabled` | |
| `fatal_error_backtraces` (8.5) | |
| Container image / digest | |

## Change

| Field | Value |
|---|---|
| Change ticket | |
| Approved by | |
| Patch window (UTC) | |
| Target version | 8.5.12 / 8.4.27 / 8.3.36 / 8.2.35 / vendor backport |
| Package source | |
| Vendor advisory URL | |
| Commands run | |
| Config changes | |
| Rollback plan | |
| Rollback tested? | yes / no / not applicable |

## After

| Field | Value |
|---|---|
| PHP version (CLI) | |
| PHP version (web SAPI) | |
| Vendor package version | |
| Services restarted | |
| OPcache cleared? | yes / no / not applicable |
| Smoke test result | pass / fail |
| `scripts/verify-patch.sh` result | pass / fail / vendor-patched |
| Error log review | |
| Monitoring enabled | |
| Residual risk accepted by | |

## Evidence

Attach or paste:

```text
$ php -v
$ php -i | grep -E 'Server API|Loaded Configuration File|memory_limit|post_max_size|session.upload_progress|fatal_error_backtraces'
$ php-fpm -t
$ apache2ctl configtest
$ bash scripts/verify-patch.sh
```

Also attach:

- vendor advisory screenshot or URL;
- package manager output showing the patched version;
- application smoke-test output;
- relevant log excerpts (redact sensitive data).

## Post-patch checks

| When | Check | Result | Owner |
|---|---|---|---|
| +1 hour | Web SAPI version and smoke test | | |
| +24 hours | Error logs, uploads, unusual requests | | |
| +72 hours | Exploitation indicators, outbound connections | | |
| +7 days | Close record; update asset inventory | | |

## Sign-off

| Role | Name | Date |
|---|---|---|
| Implementer | | |
| Reviewer | | |
| Application owner | | |
| Security owner | | |
