# PHP2Shell Remediation Checklist

**CVE-2026-109618 / CVE-2026-109619**  
**Audience:** sysadmins, MSPs, hosting providers, agencies  
**Use on:** hosts you own or are explicitly authorized to administer

> There is **no complete configuration mitigation**. Updating PHP is the only full fix. The interim controls below only reduce specific attack paths.

---

## 0. Before you start

- [ ] Confirm you have authorization to change the host.
- [ ] Open a change record using [`templates/patch-record.md`](templates/patch-record.md).
- [ ] Identify the application owner and a rollback plan.
- [ ] Do **not** run exploit attempts against production. Use a staging copy if validation is required.

---

## 1. Inventory every PHP runtime

Run:

```bash
bash scripts/collect-inventory.sh
bash scripts/audit-local.sh
```

Then verify manually:

- [ ] CLI PHP: `php -v`
- [ ] Web SAPI: check `phpinfo()` or the FPM pool / Apache module version
- [ ] PHP-FPM: `php-fpm -v`, `systemctl status php*-fpm`
- [ ] Apache module: `apache2ctl -M | grep php` or `httpd -M | grep php`
- [ ] LiteSpeed: `lsphp -v` or the panel's PHP selector
- [ ] Containers: `docker ps`, `docker images`, `docker compose config`
- [ ] Bundled runtimes: XAMPP, Laragon, WAMP, MAMP, cPanel/WHM, Plesk, CloudLinux, Bitnami images
- [ ] CI/CD images and build agents
- [ ] Serverless/container base images that include PHP
- [ ] Old versions still installed but not active

Record every **major.minor** branch in use: 7.4, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5.

> Multiple PHP versions commonly coexist. Patching one does not patch the others.

---

## 2. Triage by exposure

Prioritize in this order:

| Priority | Asset |
|---|---|
| **P0** | Internet-facing, Apache **mod_php**, file uploads enabled, `session.upload_progress` enabled |
| **P0** | Internet-facing **FrankenPHP** |
| **P0** | PHP 8.1 or older, internet-facing, no vendor backport |
| **P1** | Internet-facing PHP-FPM with uploads or attacker-reachable fatal errors |
| **P1** | Admin panels, customer portals, APIs, webhooks |
| **P2** | Internal PHP apps with untrusted users or upload features |
| **P3** | CLI-only, build-only, or isolated development hosts |

Also flag:

- [ ] `fatal_error_backtraces` enabled on PHP 8.5
- [ ] `session.upload_progress.enabled=On`
- [ ] Finite `memory_limit` on mod_php
- [ ] Large `post_max_size` or unrestricted request bodies
- [ ] High `max_file_uploads`, `max_input_vars`, or multipart part limits
- [ ] Attacker-reachable fatal errors, timeouts, or import/upload failures
- [ ] Invalid or deprecated INI settings applied per request

---

## 3. Patch

### 3.1 Upstream PHP

Update to:

| Branch | Fixed version |
|---|---|
| 8.5 | **8.5.12** |
| 8.4 | **8.4.27** |
| 8.3 | **8.3.36** |
| 8.2 | **8.2.35** |

PHP 8.1 and older are unsupported. Minimal backport branches exist for 7.4, 8.0, and 8.1, but upgrading to a supported branch is strongly preferred. PHP 8.2 reaches end of life on **31 December 2026**.

### 3.2 Distribution packages

Use the vendor's patched package, not a generic upstream tarball, unless you manage PHP yourself.

**Debian / Ubuntu**

```bash
sudo apt update
sudo apt install --only-upgrade 'php*'
# Then confirm the vendor changelog mentions CVE-2026-109618 / CVE-2026-109619
```

**RHEL / AlmaLinux / Rocky Linux**

```bash
sudo dnf upgrade 'php*'
sudo dnf history info last
```

**Alpine Linux**

```bash
sudo apk update
sudo apk upgrade 'php*'
```

**cPanel / WHM / CloudLinux**

- Use the vendor's `ea-php` / `alt-php` packages.
- Follow the CloudLinux status page and do not rely on `remi` for same-day fixes.
- Rebuild or restart PHP-FPM pools after the package update.

**Plesk**

- Update PHP handlers through the Plesk installer or vendor packages.
- Verify each handler version, not just the default.

**Windows**

- Replace the PHP binaries with the patched Windows build from the official PHP downloads page.
- Update the `php.ini` used by IIS/Apache.
- Restart IIS or the Apache service.
- Confirm the web SAPI version, not just `php -v` in a terminal.

### 3.3 Containers

- [ ] Rebuild images from a patched base image. Restarting an old container does not patch it.
- [ ] `docker compose build --pull`
- [ ] Scan the final image for the PHP version.
- [ ] Update CI runners and build caches.
- [ ] Remove dangling old images from production hosts.

### 3.4 Bundled and embedded runtimes

- [ ] WordPress managed hosts: confirm the host's PHP version in the panel, not the WordPress dashboard alone.
- [ ] XAMPP / Laragon / WAMP / MAMP: replace the bundled PHP directory and update the active config.
- [ ] Bitnami/cloud images: rebuild from the vendor's updated image.
- [ ] Static binaries and custom builds: rebuild from patched source with the vendor's flags.

---

## 4. Restart and verify

- [ ] Restart PHP-FPM workers: `sudo systemctl restart php8.3-fpm`
- [ ] Restart Apache: `sudo systemctl restart apache2` or `httpd`
- [ ] Restart FrankenPHP / LiteSpeed / IIS as applicable
- [ ] Clear OPcache if it is file-based or shared
- [ ] Confirm the running web SAPI version, not just the CLI version
- [ ] Run `bash scripts/verify-patch.sh`
- [ ] Re-run the application's smoke tests
- [ ] Confirm uploads, logins, checkout, and background jobs still work
- [ ] Check the error log for new fatals or warnings

Useful checks:

```bash
php -v
php -i | grep -E 'Server API|Loaded Configuration File|memory_limit|post_max_size|session.upload_progress|fatal_error_backtraces'
php-fpm -t
apache2ctl configtest
```

If your distribution backported the fix without changing the upstream version, record the **vendor package version** and the advisory URL in the patch record. Do not rely on `php -v` alone.

---

## 5. Interim mitigations if patching is delayed

Apply these only as temporary risk reduction. They do not replace the patch.

### 5.1 OOM path (CVE-2026-109618)

- [ ] Set `memory_limit=-1` administratively in the FPM pool, Apache config, or `php.ini`.
- [ ] Confirm no pool, directory, `.user.ini`, or application setting restores a finite limit.
- [ ] Restart every worker.
- [ ] Do **not** use `RLIMIT_AS` or `RLIMIT_DATA`; they can trigger the vulnerable allocation-failure path.
- [ ] Use a container/cgroup memory boundary if available, preferably one that kills only the worker.

### 5.2 Request-size limits

- [ ] Set `post_max_size=8M` if the app does not need uploads.
- [ ] Set `post_max_size=32M` if uploads are required, and keep `upload_max_filesize` below it.
- [ ] Reduce `max_file_uploads` to the minimum the app needs.
- [ ] Reduce `max_input_vars` and `max_input_nesting_level`.
- [ ] Set `max_multipart_body_parts` if your PHP version supports it.
- [ ] Enforce decoded request size, header count, field count, multipart part count, and nesting depth at nginx/Apache/the proxy.
- [ ] Cover requests without a usable `Content-Length`.

### 5.3 Stale-state path (CVE-2026-109619)

- [ ] Set `session.upload_progress.enabled=0` in startup configuration and restart workers.
- [ ] On PHP 8.5, set `fatal_error_backtraces=0` and restart workers.
- [ ] Remove invalid or deprecated per-request INI settings that emit diagnostics before initialization.
- [ ] Fix attacker-reachable fatal errors and execution timeouts.
- [ ] Consider `pm.max_requests=1` for FPM if performance allows.

### 5.4 WAF and proxy

- [ ] Add virtual-patch rules for malformed multipart bodies, excessive headers, and oversized requests.
- [ ] Rate-limit upload and multipart endpoints.
- [ ] Do not treat WAF coverage as a complete fix.

### 5.5 What not to do

- Do not rely on hiding the PHP version.
- Do not rely on `error_reporting`, `display_errors=Off`, or `@` to suppress the stale-state path.
- Do not assume `RLIMIT_AS`/`RLIMIT_DATA` is a safe memory boundary.
- Do not run the exploit against production to "prove" exposure.

---

## 6. Monitor for exploitation

- [ ] Enable `log_errors=On`, a working `error_log`, and `error_reporting=E_ALL` in startup configuration during the audit window.
- [ ] Alert on repeated OOM, fatal, parse, and "Maximum execution time exceeded" events.
- [ ] Alert on multipart requests with abnormal part/header counts.
- [ ] Alert on new files in web roots, upload directories, temp directories, and cron.
- [ ] Alert on unexpected outbound connections from the web user.
- [ ] Review WAF and proxy logs for scanners and repeated malformed requests.
- [ ] Check for unexpected PHP processes, workers, or scheduled tasks.

If you suspect compromise, treat it as an incident: isolate, preserve evidence, rotate secrets, and rebuild from a known-good image.

---

## 7. Post-incident checks if compromise is suspected

- [ ] Preserve logs before cleanup.
- [ ] Snapshot the host or container.
- [ ] Search for webshells and recently modified PHP files.
- [ ] Review scheduled tasks, cron, systemd units, and startup scripts.
- [ ] Review SSH keys, API tokens, database credentials, and application secrets.
- [ ] Rotate credentials for the web app, database, payment provider, and email.
- [ ] Rebuild rather than clean if the host handled sensitive data.
- [ ] Notify according to your legal/regulatory obligations.

---

## 8. Communication

- [ ] Send the executive briefing: [`BRIEFING.md`](BRIEFING.md)
- [ ] Send customer notice if service impact or data exposure is possible: [`templates/customer-notice.md`](templates/customer-notice.md)
- [ ] Record the patch in [`templates/patch-record.md`](templates/patch-record.md)
- [ ] Update the status page if maintenance is user-visible
- [ ] Set a 24–72 hour recheck

---

## 9. Final verification gate

The host is not considered remediated until all of these are true:

- [ ] Every reachable PHP branch is on a fixed version **or** the vendor confirms the backport.
- [ ] The running web SAPI is restarted and reports the patched runtime.
- [ ] No high-risk configuration remains unless intentionally accepted and documented.
- [ ] The application smoke test passes.
- [ ] The patch record contains evidence and the vendor advisory link.
- [ ] Monitoring is active for post-patch exploitation attempts.

---

## 10. Recheck schedule

| When | Action |
|---|---|
| Immediately | Patch and restart |
| +1 hour | Verify web SAPI and smoke test |
| +24 hours | Review logs, errors, and upload behavior |
| +72 hours | Confirm no exploitation indicators |
| +7 days | Close the change record and update the asset inventory |

---

**Remember:** the only complete fix is the patched PHP release. Everything else buys time.
