# Proposal and scope templates

These are commercial templates, not legal advice. Have counsel review them for your jurisdiction, entity, and risk tolerance. Replace every bracket.

---

## One-page proposal

```text
PHP2Shell verification proposal

Prepared for: [Client legal name]
Prepared by: [Your legal name / trading name]
Date: [Date]
Valid until: [Date + 14 days]

1. Objective

Independent verification that the PHP runtimes serving [hosts/applications] are on a
fixed release (or a vendor-confirmed backport) and that the effective web configuration
does not leave the known attack paths open.

This is a verification engagement, not a penetration test.

2. Scope

| Host / application | Environment | PHP SAPI | Access method |
|---|---|---|---|
| [host] | production | Apache mod_php | read-only commands |
| [host] | production | PHP-FPM | read-only commands + pool config |
| [host] | staging | CLI / container | image and package inspection |

3. Deliverables

- Asset inventory: PHP branches, SAPIs, packages, containers, and control panels.
- Patch matrix: installed version vs fixed release vs vendor advisory.
- Effective configuration review: CLI, web SAPI, FPM pools, Apache overrides.
- Verification evidence: commands, outputs, timestamps, reviewer notes.
- Executive summary and technical appendix.
- 45-minute review call.
- 30-day recheck reminder.

4. Out of scope

- Exploitation, fuzzing, brute force, vulnerability scanning, or lateral movement.
- Source-code audit, application penetration testing, or red-team activity.
- Remediation of application code unless separately scoped.
- A guarantee that the application or business is secure.
- Legal, regulatory, or insurance advice.

5. Timeline

Kick-off: [date]
Evidence collection: [date]
Draft report: [date]
Review call: [date]
Final report: [date]

6. Fees

Verification: [USD 1,500] for up to five hosts.
Remediation sprint: [from USD 4,500] for up to fifteen hosts.
Retainer: [from USD 2,500/month] for up to twenty-five client hosts.

Payment: 50% on signature, 50% on delivery. Invoices are due within seven days.
Travel and third-party fees are pre-approved in writing.

7. Client responsibilities

- Provide written authorisation for every host in scope.
- Confirm backups and a rollback plan before any restart or change.
- Name an application owner for smoke tests and sign-off.
- Provide a change window and notify affected teams.
- Do not ask us to test systems outside the authorised scope.

8. Assumptions

- The client can provide read-only access or run the supplied scripts.
- The hosts are reachable during the agreed window.
- The client has the right to authorise the review.
- Any vendor backport is confirmed by the vendor's advisory or package changelog.

9. Acceptance

Signed by: ______________________  Name: ______________________
Title: _________________________  Date: ______________________

Client: _______________________  Name: ______________________
Title: _________________________  Date: ______________________
```

---

## Scope and authorisation

```text
PHP2Shell verification — scope and authorisation

This document authorises [Provider legal name] ("Provider") to perform the services
below for [Client legal name] ("Client"). No work begins until both parties sign.

1. Authorised systems

| # | Hostname / asset | IP / environment | PHP SAPI | Allowed actions |
|---|---|---|---|---|
| 1 | [host] | [prod] | [mod_php/FPM] | read-only commands, config review |
| 2 | [host] | [prod] | [FPM] | read-only commands, config review, restart with approval |

2. Services

- Inventory PHP binaries, packages, SAPIs, FPM pools, containers, and control panels.
- Compare installed versions with fixed releases and vendor advisories.
- Review effective configuration for the known risk paths.
- Verify the runtime that serves traffic after patching.
- Produce an evidence report and hold a review call.

3. Allowed actions

- Run read-only commands such as `php -v`, `php --ini`, `php -i`, package queries, and config reads.
- Inspect local configuration files and service definitions.
- Restart PHP-FPM/Apache/other services only with the Client's written approval and a change window.
- Collect command output and configuration excerpts for the report.

4. Prohibited actions

- Exploitation, fuzzing, brute force, password attacks, or lateral movement.
- Port scanning, vulnerability scanning, or forced browsing.
- Access to customer data, secrets, private keys, or payment data.
- Changes outside the agreed scope.
- Testing any host not listed in section 1.

5. Client responsibilities

- Confirm it owns or is authorised to permit the review of every host.
- Provide backups, rollback, and a change window.
- Name an application owner for smoke tests.
- Ensure the environment is monitored during the window.
- Notify Provider of any sensitive data that must not be collected.

6. Data handling

- Provider collects the minimum evidence needed for the report.
- Credentials are not requested through the website and should be shared only through an agreed secret channel.
- Evidence is stored in an access-controlled location and deleted [30/60/90] days after final delivery, unless retention is required by law.
- The report is confidential to the Client and may be shared with its advisers under confidentiality.

7. Fees and payment

- Fee: [amount] for the scope above.
- Payment terms: [50% on signature, 50% on delivery / net 7].
- Work outside the scope requires a written change order.

8. Limitations

- This is a verification engagement, not a penetration test or a guarantee of security.
- Findings are based on the evidence available during the window.
- Provider is not liable for application downtime, data loss, or third-party actions except as required by law or a separate agreement.
- Nothing in this document is legal, regulatory, or insurance advice.

9. Confidentiality

Each party will protect the other's confidential information and use it only for this engagement.

10. Acceptance

Provider: ______________________  Name: ______________________
Title: _________________________  Date: ______________________

Client: _______________________  Name: ______________________
Title: _________________________  Date: ______________________

Authorised signatory confirms: "I am authorised to permit the actions described above
on the systems listed in section 1."
```

---

## Change-order template

Use when the client adds hosts, asks for application remediation, or requests incident response.

```text
Change order #[number]

Original scope: [reference]
New request: [describe]
Additional hosts / work: [list]
Impact on timeline: [days]
Additional fee: [amount]
New total: [amount]

Approved by Client: ______________________  Date: __________
Approved by Provider: ____________________  Date: __________
```

---

## Invoice notes

- Invoice the legal entity named in the scope.
- Reference the signed scope and change orders.
- Do not invoice “security audit” if the work was only patch verification; be precise.
- Keep evidence and timesheets with the invoice record.
