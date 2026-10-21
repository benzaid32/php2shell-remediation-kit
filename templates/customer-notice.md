# Customer notice template
# Replace bracketed fields. Do not send until the facts are verified.

**Subject:** Security update completed for [service/website] — action not required

Hello [customer name],

We are writing to let you know about a critical security update we completed for [service/website].

## What happened

On [date], the PHP project published fixes for two critical vulnerabilities (CVE-2026-109618 and CVE-2026-109619) in the PHP runtime. PHP is the software that runs [service/website]. The issues could allow an unauthenticated attacker to run code on an affected server.

## What we did

- Updated PHP on [affected systems] from [old version] to [fixed version].
- Restarted the web and PHP services.
- Verified the running version and completed application smoke tests.
- Reviewed logs for signs of exploitation.
- [Any additional action: WAF rule, credential rotation, monitoring, etc.]

## What you need to do

[Choose one:]

- **No action is required.** We have completed the update and verification.
- **Please reset your password** if you reuse the password for [service] elsewhere.
- **Please review [specific account activity]** and contact us if anything looks unusual.

## What we are monitoring

We are watching for unusual errors, uploads, outbound connections, and signs of unauthorized access through [date]. If we find anything that affects your data, we will contact you directly.

## Questions

Contact [name/team] at [email/phone] with any questions.

Thank you,

[Name]
[Role]
[Organization]

---

## Internal notes (remove before sending)

- Do not claim "no data was accessed" unless the investigation supports it.
- Do not claim the issue is "fully mitigated" if you only applied configuration changes.
- Record the vendor advisory URL and package version in the patch record.
- If compromise is suspected, involve legal/privacy before sending customer communications.
