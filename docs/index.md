# PHP2Shell Remediation Kit

A free, vendor-neutral remediation kit for the October 2026 critical PHP vulnerabilities:

- **CVE-2026-109618** — RCE via OOM corruption
- **CVE-2026-109619** — RCE via stale global state

Both are rated **CVSS v4.0 9.2**. Fixed versions: **PHP 8.5.12, 8.4.27, 8.3.36, 8.2.35**.

## Start here

1. **[Remediation checklist](https://github.com/benzaid32/php2shell-remediation-kit/blob/main/CHECKLIST.md)** — inventory, patch, verify, monitor.
2. **[Executive briefing](https://github.com/benzaid32/php2shell-remediation-kit/blob/main/BRIEFING.md)** — one-page risk and decision guide for SMEs.
3. **[Local audit scripts](https://github.com/benzaid32/php2shell-remediation-kit/tree/main/scripts)** — read-only checks for Linux and Windows.
4. **[Sources](https://github.com/benzaid32/php2shell-remediation-kit/blob/main/SOURCES.md)** — official advisories and vendor links.

## Quick commands

```bash
git clone https://github.com/benzaid32/php2shell-remediation-kit.git
cd php2shell-remediation-kit

bash scripts/collect-inventory.sh
bash scripts/audit-local.sh
bash scripts/verify-patch.sh
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\audit-local.ps1
```

## What this is not

- Not a scanner. The scripts only inspect the local host.
- Not an exploit kit. There is no exploit code here.
- Not a complete mitigation. Patching PHP is the only full fix.
- Not affiliated with the PHP project.

## For MSPs and agencies

You may use, adapt, and distribute this kit commercially under the MIT license. Attribution is appreciated but not required. If you use it with clients, replace the placeholders in the templates with your own contact details and scope language.

## Need help?

Open an issue in the repository with your **environment only**. Never post credentials, customer data, or third-party host details.

For paid remediation, incident response, or independent verification, engage a qualified consultant or MSP and require a written scope before any testing.

---

**Patch first. Verify second. Communicate third.**
