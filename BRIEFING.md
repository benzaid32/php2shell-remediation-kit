# Executive Briefing: PHP2Shell (CVE-2026-109618 / CVE-2026-109619)

**For:** business owners, executives, and SME decision-makers  
**Date:** 21 October 2026  
**Status:** patch available; urgent action required

---

## The short version

Two critical security flaws in **PHP** — the software that runs most of the world's websites — allow an unauthenticated attacker to run their own code on a vulnerable server.

- **CVE-2026-109618** — remote code execution through out-of-memory handling
- **CVE-2026-109619** — remote code execution through stale internal state
- Both are rated **CVSS v4.0 9.2** (critical)
- Fixed versions are available: **PHP 8.5.12, 8.4.27, 8.3.36, 8.2.35**

This is not a WordPress plugin bug, a theme bug, or a single-vendor product bug. It is in **PHP itself**. Any PHP application can be exposed if the runtime is unpatched.

---

## Why it matters

If exploited, an attacker can:

- run commands as the web-server user;
- read or modify application data;
- install a webshell for persistence;
- pivot to databases, internal services, or other hosts;
- disrupt service.

The highest-risk configuration is **internet-facing Apache with mod_php**. PHP-FPM, FrankenPHP, and LiteSpeed deployments are also exposed depending on configuration and application behavior.

---

## What to do

### 1. Patch

Update every PHP runtime to a fixed version. This includes CLI, FPM, Apache module, containers, and bundled runtimes.

If your host uses a Linux distribution or control panel, install the **vendor's patched package**, not just an upstream tarball. Distribution backports may keep the version number unchanged; confirm the vendor advisory.

### 2. Verify

After patching:

- restart PHP-FPM/Apache/FrankenPHP/IIS;
- confirm the **web SAPI** version, not only the terminal version;
- run the application's smoke tests;
- check uploads, logins, checkout, and background jobs.

### 3. If you cannot patch today

Apply the interim controls in [`CHECKLIST.md`](CHECKLIST.md):

- set `memory_limit=-1` administratively;
- reduce `post_max_size` to 8M (or 32M with uploads);
- disable `session.upload_progress`;
- on PHP 8.5, disable `fatal_error_backtraces`;
- add request-size and multipart limits at the proxy;
- consider `pm.max_requests=1`.

These reduce risk. They are **not** a complete fix.

### 4. Monitor

Watch for:

- repeated out-of-memory or fatal errors;
- abnormal multipart requests;
- new files in web roots or upload directories;
- unexpected outbound connections from the web user;
- webshell indicators.

---

## Decision table

| Your situation | Priority | Action |
|---|---|---|
| Public website, mod_php, uploads enabled | **P0** | Patch within hours; interim controls until then |
| Public website, PHP-FPM, uploads or user input | **P1** | Patch within 24 hours |
| Public API or customer portal | **P1** | Patch within 24 hours |
| Internal app with untrusted users | **P2** | Patch within 72 hours |
| CLI-only or isolated dev host | **P3** | Patch at the next maintenance window |
| PHP 8.1 or older, internet-facing | **P0/P1** | Upgrade or apply vendor backport immediately |

---

## Business risks

- **Data breach:** customer, payment, or health data could be accessed.
- **Downtime:** the OOM path can crash workers during exploitation attempts.
- **Persistence:** attackers can install webshells and remain after patching.
- **Regulatory exposure:** breach notification and privacy obligations may apply.
- **Reputation:** public exploitation of an unpatched critical flaw is difficult to explain.

---

## FAQ

**Is WordPress affected?**  
Yes, if it runs on a vulnerable PHP runtime. The bug is in PHP, not WordPress.

**Does a WAF fix it?**  
No. A WAF can reduce some attack paths but is not a complete fix.

**Is PHP 8.1 safe?**  
No. PHP 8.1 is unsupported. Minimal backport branches exist, but upgrading to a supported branch is strongly preferred.

**Do we need to rotate passwords?**  
Only if you suspect compromise. If you do, rotate application, database, API, and infrastructure credentials and rebuild the host.

**Can we test our own site with an exploit?**  
Only in a controlled lab or with explicit authorization. Do not run exploit attempts against production; the OOM path can cause outages.

**How long does patching take?**  
The package update is usually minutes. Verification, rollback planning, and application testing typically take 1–4 hours per platform.

---

## Recommended timeline

| Time | Action |
|---|---|
| **0–4 hours** | Inventory PHP runtimes; patch internet-facing mod_php and FrankenPHP |
| **4–24 hours** | Patch remaining public PHP-FPM/API/portal assets; verify |
| **24–72 hours** | Patch internal assets; review logs for exploitation |
| **7 days** | Close change records; update inventory and monitoring |

---

## What good looks like

- A complete PHP inventory, including containers and bundled runtimes.
- Every public runtime on a fixed version or a vendor-confirmed backport.
- A patch record with version evidence and vendor advisory links.
- Restarted workers and a successful application smoke test.
- Monitoring for OOM, malformed multipart, webshells, and outbound anomalies.
- A documented decision for any residual risk.

---

## Need help?

Open an issue in this repository with your **environment only** — never include credentials, customer data, or third-party host details.

For paid remediation, incident response, or verification, engage a qualified consultant or MSP and require a written scope before any testing.
