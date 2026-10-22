# Outreach playbook

## The rule that protects the business

**We do not scan, probe, fuzz, brute-force, or exploit third-party systems.** We do not tell a company it is vulnerable unless we have written authorisation and evidence. A version header, CMS fingerprint, or a guess is not evidence.

Instead:

1. Find companies with a **public PHP signal**.
2. Offer the **free, read-only kit**.
3. Let them self-check or book a scoping call.
4. Review only hosts they authorise in writing.

Unauthorised testing can violate computer-misuse laws, breach hosting terms, and destroy the reputation this offer depends on. It is also a bad sales strategy: “we secretly checked you” is a threat, not a professional service.

---

## Ideal first customers

| Segment | Why they buy | Entry offer |
|---|---|---|
| PHP / Laravel / WordPress agencies | One relationship covers many client sites; clients ask them for patch evidence | White-label verification |
| MSPs and managed hosting providers | Recurring patch evidence across a portfolio | Monthly retainer |
| E-commerce and membership sites | Customer accounts, uploads, checkout, and uptime risk | Verification or remediation sprint |
| SaaS and internal PHP apps | Board/customer assurance after a critical advisory | Verification |
| SMEs with public PHP sites | Need a clear checklist and a second pair of eyes | Free kit, then verification |

The fastest path to revenue is **agencies and MSPs**, not cold-emailing thousands of individual shops. One agency can bring 10–100 hosts.

---

## Offer ladder

1. **Free kit** — the lead magnet. No call required.
2. **Paid verification** — fixed scope, evidence report, 2 business days.
3. **Remediation sprint** — inventory, patch coordination, verification, hardening.
4. **MSP/agency retainer** — monthly verification and priority triage.

Do not lead with a scary claim. Lead with the free kit and the evidence gap.

---

## Weekly cadence

| Day | Activity |
|---|---|
| Monday | Build 20–30 qualified leads from public signals; verify source URLs |
| Tuesday | Send first-touch emails (20–40 max per sending domain) |
| Wednesday | Follow up with engaged leads; book triage calls |
| Thursday | Send second-touch emails; publish one useful post or checklist |
| Friday | Review replies, update CRM, remove opt-outs, plan next week |

Stop after **three touches**. If there is no reply, mark closed-lost for 90 days. Do not keep “just following up” forever.

---

## Compliance checklist

Before sending anything, fill these in:

- [ ] Full legal name (or registered entity, if you have one)
- [ ] Physical postal address or PO box (required for CAN-SPAM)
- [ ] Privacy notice URL
- [ ] Working reply-to mailbox
- [ ] Opt-out process and suppression list
- [ ] Sending domain with SPF, DKIM, and DMARC
- [ ] CRM or spreadsheet with source URL and opt-out status

Rules:

- **B2B only.** Do not email consumers or personal addresses.
- **Use public business information only.** Company website, public job postings, public agency directories, public case studies, public GitHub organisations.
- **Do not scrape LinkedIn** or ignore platform terms. Manual research only.
- **Do not buy email lists.** They are usually stale, non-compliant, and bad for deliverability.
- **Use role-based addresses** (`hello@`, `info@`, `security@`), your published business inbox, or a public contact form. Do not guess personal addresses.
- **Include a real opt-out** and honour it immediately. Keep a suppression list.
- **Identify the message as commercial.** Include the business name and a clear solicitation line in the footer.
- **No deceptive subject lines**, fake “Re:”/“Fwd:”, fake urgency, or false vulnerability claims.
- **No attachments** on first contact.
- **Use a separate sending domain or subdomain** (for example `outreach.yourdomain.com`), warmed up slowly. Do not risk your primary domain.
- **Follow CAN-SPAM, GDPR/PECR, and local law.** This is not legal advice; have counsel review your campaign.

---

## What to say if asked “how did you find me?”

Be specific and honest:

> “I found your company through [public source URL], where you list [PHP/Laravel/WordPress] services. I’m reaching out because we publish a free PHP patch-audit kit and offer independent verification for agencies. No scan was run against your systems.”

If you cannot name the public source, do not send the email.

---

## Metrics that matter

Track weekly:

- Leads researched
- Emails sent
- Replies (positive / neutral / negative)
- Triage calls booked
- Paid pilots
- Opt-outs and complaints

A reasonable early target is **100 well-researched contacts → 8–15 replies → 3–5 calls → 1 paid pilot**. Volume without research will underperform and increase compliance risk.

---

## Before you send

- [ ] The first line references a real public signal and source URL.
- [ ] The email contains no vulnerability claim.
- [ ] The CTA is the free kit or a 20-minute triage, not “buy now.”
- [ ] The footer identifies the message as a commercial solicitation and has your full name, address, privacy link, and opt-out.
- [ ] The lead is not on the suppression list.
- [ ] The sending domain has SPF, DKIM, and DMARC.
- [ ] You can answer “where did you get my email?” in one sentence.
