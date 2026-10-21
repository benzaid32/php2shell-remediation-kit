# PHP2Shell Remediation Kit

A vendor-neutral, **local-only** remediation kit for the October 2026 PHP remote code execution vulnerabilities:

- **CVE-2026-109618** — RCE via OOM corruption
- **CVE-2026-109619** — RCE via stale global state
- Both **CVSS v4.0 9.2**, unauthenticated, network-reachable

> **Not affiliated with the PHP project.** This is a community remediation kit. It contains **no exploit code** and performs **no scanning of third-party systems**. Use it only on hosts you own or are explicitly authorized to administer.

**Business page:** https://benzaid32.github.io/php2shell-remediation-kit/  
**Free kit:** this repository. **Paid verification:** see the page for scope and pricing.

---

## TL;DR

1. **Patch now** to one of:
   - PHP **8.5.12**
   - PHP **8.4.27**
   - PHP **8.3.36**
   - PHP **8.2.35**
2. **Inventory** the host: `scripts/collect-inventory.sh`
3. **Audit** the local runtime: `scripts/audit-local.sh`
4. **If you cannot patch immediately**, apply the interim mitigations in [`CHECKLIST.md`](CHECKLIST.md). There is **no complete mitigation** — updating is the only full fix.
5. **Verify** after patching: `scripts/verify-patch.sh`

Windows users can run `scripts/audit-local.ps1` in PowerShell.

---

## What is in this repo

| File | Purpose |
|---|---|
| [`CHECKLIST.md`](CHECKLIST.md) | Step-by-step remediation and verification checklist for sysadmins and MSPs |
| [`BRIEFING.md`](BRIEFING.md) | Executive/SME briefing: risk, decisions, timeline, FAQ |
| [`SOURCES.md`](SOURCES.md) | Official advisories and vendor references |
| [`scripts/collect-inventory.sh`](scripts/collect-inventory.sh) | Read-only local inventory of PHP runtimes, SAPIs, packages, and containers |
| [`scripts/audit-local.sh`](scripts/audit-local.sh) | Read-only local version and configuration audit |
| [`scripts/audit-local.ps1`](scripts/audit-local.ps1) | Windows PowerShell version of the local audit |
| [`scripts/verify-patch.sh`](scripts/verify-patch.sh) | Post-patch verification wrapper |
| [`templates/customer-notice.md`](templates/customer-notice.md) | Customer-facing notification template |
| [`templates/patch-record.md`](templates/patch-record.md) | Change/evidence record template |
| [`docs/index.html`](docs/index.html) | Business landing page for the paid verification/remediation offer |
| [`docs/privacy.html`](docs/privacy.html) | Privacy notice for the contact form and enquiries |
| [`docs/config.js`](docs/config.js) | Contact, booking, and form-endpoint settings for the page |
| [`docs/index.md`](docs/index.md) | Short documentation landing page |
| [`docs/launch-post.md`](docs/launch-post.md) | Launch post draft for a blog, newsletter, or LinkedIn |
| [`tests/check_site.py`](tests/check_site.py) | Static checks for the business page |
| [`outreach/README.md`](outreach/README.md) | Compliant outreach rules, cadence, and boundaries |
| [`outreach/lead-research.md`](outreach/lead-research.md) | Public-signal lead research and qualification |
| [`outreach/email-sequences.md`](outreach/email-sequences.md) | B2B email sequences for agencies, MSPs, and SMEs |
| [`outreach/proposal-and-scope.md`](outreach/proposal-and-scope.md) | Proposal, scope, authorisation, and change-order templates |
| [`outreach/discovery-questions.md`](outreach/discovery-questions.md) | Triage-call questions and red flags |
| [`outreach/leads-template.csv`](outreach/leads-template.csv) | CRM import template |

---

## Who this is for

- SMEs running WordPress, Laravel, Symfony, Drupal, Joomla, Moodle, or custom PHP apps
- MSPs and hosting providers managing many PHP versions
- Agencies that maintain client sites
- Sysadmins who need a defensible patch-verification record

It is **not** a penetration-testing toolkit and must not be used to probe systems without written authorization.

---

## Business playbook

The landing page is the front door. The outreach pack is the go-to-market system:

1. Read [`outreach/README.md`](outreach/README.md) for the rules and weekly cadence.
2. Build a list from **public PHP signals** using [`outreach/lead-research.md`](outreach/lead-research.md).
3. Use the B2B sequences in [`outreach/email-sequences.md`](outreach/email-sequences.md).
4. Qualify on the triage call with [`outreach/discovery-questions.md`](outreach/discovery-questions.md).
5. Send a one-page scope from [`outreach/proposal-and-scope.md`](outreach/proposal-and-scope.md).

**Boundary:** we do **not** scan, probe, fuzz, or exploit third-party systems, and we do **not** tell a company it is vulnerable without written authorization and evidence. The free kit lets a company check its own host. Paid work starts after a signed scope.

---

## Quick start (Linux)

```bash
git clone https://github.com/benzaid32/php2shell-remediation-kit.git
cd php2shell-remediation-kit

# 1. Inventory the host (read-only)
bash scripts/collect-inventory.sh

# 2. Audit the local PHP runtime and configuration
bash scripts/audit-local.sh

# 3. After patching, verify
bash scripts/verify-patch.sh
```

The scripts make **no network requests**. They read local files, invoke the local PHP binary, and inspect local service configuration.

### Exit codes

| Code | Meaning |
|---:|---|
| `0` | No potential exposure found by the local checks |
| `2` | Potential exposure or high-risk configuration; action required |
| `1` | Audit could not run (for example, PHP not found) |

### Important limitation

A version string alone cannot prove a distro package is patched. Distributions often backport fixes without changing the upstream version. Always verify the **vendor security advisory and package changelog** for your OS or control panel. The audit script prints the vendor package version when it can detect it.

---

## Risk snapshot

| Deployment | Relative risk | Why |
|---|---|---|
| Internet-facing Apache **mod_php** | **Highest** | Request shutdown runs even when startup fails; exploit demonstrated over HTTP |
| Internet-facing **FrankenPHP** | High | Request shutdown model is similar to mod_php |
| **PHP-FPM** with uploads or attacker-reachable fatal errors | High / conditional | Stale-state RCE validated; OOM path depends on app and pool behavior |
| **LSAPI / LiteSpeed** | Conditional | Models FPM; application-specific paths likely |
| CLI-only PHP | Low for this CVE | Not remotely reachable through HTTP, but still patch |
| PHP 8.1 and older | Unsupported | No upstream updates; minimal backport branches exist |

The highest-risk combination is: **internet-facing + mod_php + file uploads enabled + `session.upload_progress` enabled**.

---

## Interim mitigations (only if patching is delayed)

These reduce specific attack paths. They do **not** make an installation safe.

- Set `memory_limit=-1` administratively and restart every worker.
- Keep `post_max_size` conservative: **8M** without uploads, **32M** with uploads.
- Keep `upload_max_filesize` below `post_max_size`.
- Bound request size, header count, multipart part count, and nesting depth at the web server or proxy.
- Set `session.upload_progress.enabled=0` and restart workers.
- On PHP 8.5, set `fatal_error_backtraces=0` and restart workers.
- Consider `pm.max_requests=1` for FPM.
- Use container/cgroup memory limits, **not** `RLIMIT_AS` or `RLIMIT_DATA`.
- Remove invalid or deprecated per-request INI settings that emit diagnostics before initialization.

Full details and commands are in [`CHECKLIST.md`](CHECKLIST.md).

---

## What this kit deliberately does not include

- Exploit payloads or proof-of-concept attack requests
- Internet-wide scanners, Shodan/Censys queries, or target lists
- Instructions for testing systems without authorization
- A claim that a WAF or configuration change is a complete fix

If you need to validate exploitability, do it only in a controlled lab you own, or under a signed engagement or bug bounty scope that explicitly permits it.

---

## Contributing

Corrections and additional vendor-specific patch steps are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md). Please do not open issues containing exploit code or third-party host details.

## License

MIT. See [`LICENSE`](LICENSE).

---

**Patch first. Verify second. Communicate third.**
