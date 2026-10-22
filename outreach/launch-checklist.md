# Launch checklist

Use this before you send a single outreach email. The page can be live without every item, but the outreach cannot.

## 1. Business identity

- [ ] Choose the trading name you will use on invoices and email.
- [ ] Register the domain (or decide to use a subdomain you already own).
- [ ] Create a monitored mailbox: `hello@`, `security@`, or `contact@`.
- [ ] Add the legal entity name and physical postal address to the email footer. CAN-SPAM requires a real address.
- [ ] Publish the privacy notice and name any form/email processors.
- [ ] Decide the booking link (Calendly, Cal.com, or the form).
- [ ] Confirm the starting prices and what is included.
- [ ] Set up a payment method and invoice template.
- [ ] Have counsel review the scope, limitation-of-liability, and privacy documents.

## 2. Page

- [ ] Replace the placeholder `contactEmail` in `docs/config.js`.
- [ ] Set `bookingUrl` if you use a scheduler.
- [ ] Replace the sample prices in `docs/index.html` with your real prices.
- [ ] Test the form on desktop and mobile.
- [ ] Test the email link and the privacy link.
- [ ] Confirm the page does **not** claim a visitor is vulnerable.
- [ ] Confirm the "written scope before access" statement is visible.

## 3. Deliverability and compliance

- [ ] Use a separate sending domain or subdomain (for example `outreach.yourdomain.com`).
- [ ] Configure SPF, DKIM, and DMARC.
- [ ] Warm up the domain slowly. Start with 10–20 emails per day.
- [ ] Use plain text, one primary link, and no attachments on first contact.
- [ ] Keep a suppression list and honour opt-outs immediately.
- [ ] Include the legal entity, postal address, privacy link, and opt-out in every email.
- [ ] Do not buy lists, scrape LinkedIn, or guess personal addresses.
- [ ] Keep the public source URL for every lead.
- [ ] Check the laws in your target country. This checklist is not legal advice.

## 4. First pipeline (week 1)

- [ ] Pick one region and one segment (for example, Laravel agencies in the UK).
- [ ] Build 20 agency/MSP leads with a public PHP signal.
- [ ] Build 10 e-commerce/membership/SME leads with a public PHP signal.
- [ ] Score each lead 1–5 using `lead-research.md`.
- [ ] Find a role-based contact or public contact form.
- [ ] Record the source URL and the exact public signal.
- [ ] Send 10–20 personalised first-touch emails.
- [ ] Follow up on day 4 and day 10, then stop.
- [ ] Aim for 3–5 triage calls, not 100 replies.

## 5. Sales assets

- [ ] One-page proposal ready (`proposal-and-scope.md`).
- [ ] Scope and authorisation ready for signature.
- [ ] Patch-record and customer-notice templates ready.
- [ ] Invoice and payment terms ready.
- [ ] Incident-response escalation path ready.
- [ ] Testimonial consent process ready.

## 6. Delivery capacity

- [ ] Linux audit tested on a host you own.
- [ ] Windows audit tested on a host you own.
- [ ] Report template ready.
- [ ] Review-call agenda ready.
- [ ] Backup, change-window, and rollback expectations documented.
- [ ] Data-handling and deletion process documented.
- [ ] Insurance and contract review completed.

## 7. Weekly scorecard

Track these numbers every Friday:

| Metric | Target |
|---|---|
| Qualified leads researched | 20–30 |
| First-touch emails sent | 40–80 |
| Positive replies | 5–10 |
| Triage calls booked | 3–5 |
| Paid pilots | 1 |
| Opt-outs / complaints | 0 |

## 8. Stop signs

Do not send if:

- You cannot name the public source for the contact.
- The email claims or implies the recipient is vulnerable.
- The footer lacks a real address or opt-out.
- The lead is a consumer or a personal address you guessed.
- The prospect wants you to test a host they do not own.
- You have not tested the form or the email link.
- You cannot deliver the paid work within the promised window.

The first sale is a test of the whole system. Keep the first scope small, deliver it cleanly, and ask for a testimonial and a referral before you scale.
