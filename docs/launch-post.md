# Launch post draft: PHP2Shell remediation for SMEs

> Draft for a blog, LinkedIn post, or client newsletter. Edit the voice and add your own contact details. Do not include exploit details or third-party host information.

---

## A critical PHP bug is not a WordPress problem. It is a business continuity problem.

On 21 October 2026, the PHP project published fixes for two critical vulnerabilities:

- **CVE-2026-109618** — remote code execution through out-of-memory handling
- **CVE-2026-109619** — remote code execution through stale internal state

Both are rated **CVSS v4.0 9.2**. An unauthenticated attacker may be able to run code on an affected server.

If your website, customer portal, API, or internal tool runs on PHP, this applies to you. That includes WordPress, Laravel, Symfony, Drupal, Joomla, Moodle, custom applications, and the managed hosting behind them.

### The part most SMEs miss

The bug is in **PHP itself**, not in a plugin or theme. Updating WordPress does not update PHP. Updating a plugin does not update PHP. Restarting a container does not update the PHP inside it.

You need to find every PHP runtime you operate:

- the CLI binary;
- the web SAPI (Apache mod_php, PHP-FPM, FrankenPHP, LiteSpeed);
- containers and build images;
- bundled runtimes such as XAMPP, Laragon, WAMP, cPanel, Plesk, and CloudLinux;
- old versions still installed but not active.

Then patch to a fixed release: **PHP 8.5.12, 8.4.27, 8.3.36, or 8.2.35**. If your host uses a Linux distribution or control panel, install the vendor's patched package and confirm the vendor advisory. The upstream version number may not change when a distribution backports a fix.

### If you cannot patch today

There is no complete configuration mitigation, but you can reduce specific attack paths:

- set `memory_limit=-1` administratively and restart every worker;
- reduce `post_max_size` to 8M, or 32M if uploads are required;
- disable `session.upload_progress`;
- on PHP 8.5, disable `fatal_error_backtraces`;
- add request-size and multipart limits at the proxy;
- consider `pm.max_requests=1` for FPM.

These buy time. They are not a fix.

### Verify, don't assume

After patching, restart the web and PHP services. Confirm the **web SAPI** version, not just the terminal version. Run the application's smoke tests. Check uploads, logins, checkout, and background jobs. Review logs for out-of-memory errors, fatal errors, abnormal multipart requests, new files in web roots, and unexpected outbound connections.

### A free kit you can use today

We published a free, MIT-licensed remediation kit with:

- a step-by-step checklist for sysadmins and MSPs;
- a read-only local audit for Linux and Windows;
- a post-patch verification script;
- an executive briefing;
- customer notice and patch-record templates.

It contains no exploit code and performs no scanning of third-party systems.

**Repository:** https://github.com/benzaid32/php2shell-remediation-kit

### The bottom line

Patch PHP this week. If you cannot, apply the interim controls and document the residual risk. If you suspect compromise, treat it as an incident: preserve evidence, rotate credentials, and rebuild from a known-good image.

If you need a second pair of eyes on your inventory or patch verification, [add your contact/CTA here].

---

## Suggested social post

> Two critical PHP RCEs (CVSS 9.2) were fixed this week. The bug is in PHP, not WordPress — so updating plugins is not enough.
>
> I published a free remediation kit for SMEs and MSPs: inventory commands, patch checklist, local audit scripts, verification steps, and an executive briefing. No exploit code. No scanning.
>
> Patch to PHP 8.5.12 / 8.4.27 / 8.3.36 / 8.2.35, then verify the web SAPI.
>
> https://github.com/benzaid32/php2shell-remediation-kit
