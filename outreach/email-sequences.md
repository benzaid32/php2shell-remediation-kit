# Email sequences

These are B2B templates, not a licence to spam. Read `README.md` before sending.

Replace every `{{placeholder}}`. Keep the first line specific to a real public signal. If you cannot fill `{{sourceUrl}}`, do not send the email.

---

## Rules

- Plain text. No images, tracking pixels, or attachments on first contact.
- One primary link in the first email. The footer may include a privacy link.
- 80–140 words. If it is longer, cut it.
- No “you are vulnerable”, “urgent”, “final notice”, or fake “Re:”.
- Send Tuesday–Thursday, 08:00–10:00 in the recipient’s timezone, if you can.
- 20–40 first-touch emails per day per sending domain while warming up.
- Stop after three touches. Honour opt-outs immediately.
- Use a separate sending domain or subdomain with SPF, DKIM, and DMARC.
- Keep a suppression list and a record of the public source for every contact.

---

## Sequence A — agencies and MSPs

### A1 — first touch (day 1)

**Subject options**

- `PHP patch evidence for your client sites`
- `A free PHP audit kit for {{company}}`
- `PHP2Shell proof for client work`

```text
Hi {{firstName}},

I saw that {{company}} works on {{publicSignal}} projects ({{sourceUrl}}). With CVE-2026-109618 and CVE-2026-109619 public, clients are starting to ask for proof that PHP was patched — not just that WordPress or a plugin was updated.

We published a free, read-only audit kit that checks the PHP runtime, web SAPI, and effective config:
{{pageUrl}}

If it is useful, we also run independent verification for client hosts and produce a white-label evidence report. Worth a 20-minute look?

{{senderName}}
{{businessName}}

No scanning. The kit runs only on hosts you own or administer.

--
You received this because {{reason}} ({{sourceUrl}}). Reply "unsubscribe" to be removed.
{{businessName}} · {{physicalAddress}} · {{privacyUrl}}
```

### A2 — follow-up (day 4)

**Subject:** `Re: PHP patch evidence for your client sites`

```text
Hi {{firstName}},

Quick follow-up. The kit takes about five minutes on a Linux host and produces a pass/fail summary with the exact PHP version, web SAPI, and effective config. It does not scan or send data anywhere.

If you want, I can send the one-page scope for a white-label verification. It starts at $1,500 for up to five hosts.

{{senderName}}
{{businessName}}
{{pageUrl}}

--
Reply "unsubscribe" to be removed. {{businessName}} · {{physicalAddress}} · {{privacyUrl}}
```

### A3 — close the loop (day 10)

**Subject:** `Closing the loop on PHP patch evidence`

```text
Hi {{firstName}},

I'll close the loop. If {{company}} needs independent evidence that PHP was patched — for a client, insurer, or board — our verification starts at $1,500 for up to five hosts. If the free kit is enough, keep it; no strings.

Reply "scope" and I'll send the one-page scope.

{{senderName}}
{{businessName}}
{{pageUrl}}

--
Reply "unsubscribe" to be removed. {{businessName}} · {{physicalAddress}} · {{privacyUrl}}
```

---

## Sequence B — SMEs, e-commerce, and membership sites

### B1 — first touch (day 1)

**Subject options**

- `Free PHP security self-audit for {{company}}`
- `PHP patch check for {{company}}`
- `A read-only PHP audit you can run yourself`

```text
Hi {{firstName}},

CVE-2026-109618 and CVE-2026-109619 are critical PHP flaws fixed in 8.5.12, 8.4.27, 8.3.36, and 8.2.35. If {{company}} runs WordPress, WooCommerce, Laravel, or a custom PHP app, the PHP runtime may need a separate patch from the CMS.

We published a free, read-only kit that checks the local runtime and web configuration:
{{pageUrl}}

If you want a second pair of eyes, we offer a fixed-scope verification with an evidence report. Happy to send the one-page scope.

{{senderName}}
{{businessName}}

No scanning. The kit runs only on hosts you own or administer.

--
You received this because {{reason}} ({{sourceUrl}}). Reply "unsubscribe" to be removed.
{{businessName}} · {{physicalAddress}} · {{privacyUrl}}
```

### B2 — follow-up (day 4)

**Subject:** `Re: Free PHP security self-audit for {{company}}`

```text
Hi {{firstName}},

Quick follow-up. The kit is read-only, takes about five minutes, and gives you a pass/fail summary plus the exact versions and config values. If it flags something, I can help you interpret the output without touching the host.

Happy to walk through it if that is useful.

{{senderName}}
{{businessName}}
{{pageUrl}}

--
Reply "unsubscribe" to be removed. {{businessName}} · {{physicalAddress}} · {{privacyUrl}}
```

### B3 — close the loop (day 10)

**Subject:** `Closing the loop on PHP patch evidence`

```text
Hi {{firstName}},

I'll close the loop. If {{company}} needs proof that PHP was patched, our verification starts at $1,500 for up to five hosts. If the free kit is enough, keep it.

Reply "scope" for the one-page scope.

{{senderName}}
{{businessName}}
{{pageUrl}}

--
Reply "unsubscribe" to be removed. {{businessName}} · {{physicalAddress}} · {{privacyUrl}}
```

---

## Sequence C — after a kit download or opt-in

Only send this if the person actually downloaded the kit or asked for follow-up. Do not pretend.

**Subject:** `Did the PHP audit flag anything?`

```text
Hi {{firstName}},

You downloaded the PHP2Shell kit. Did it flag a version, web SAPI, or config issue you want a second pair of eyes on?

Send the redacted summary (no credentials or customer data) and I'll tell you what it means and whether a paid verification is worth it.

{{senderName}}
{{businessName}}
{{pageUrl}}

--
Reply "unsubscribe" to be removed. {{businessName}} · {{physicalAddress}} · {{privacyUrl}}
```

---

## Reply handling

### Positive reply

```text
Thanks {{firstName}} — happy to help.

Here is a one-page scope template so we can confirm the hosts, access, and deliverables before anything starts:
{{scopeLink}}

If you send the host list and the PHP versions/SAPIs you know about, I can come back with a fixed quote and a proposed window.

{{senderName}}
```

### “We already patched”

```text
Great. The free kit is still worth running because it checks the web SAPI and effective config, not just the CLI version. If it passes, you have evidence for your change record. If it flags a mismatch, we can verify it without guessing.

No scan, no access without a signed scope.
```

### “We use a managed host”

```text
That helps, but ask them for three things: the PHP package version, the web SAPI in use, and the effective INI values for the pool or vhost. A patched control panel does not always mean every handler was updated.

We can independently verify the evidence they provide.
```

### “Is this a scam?”

```text
Fair question. We do not scan or claim your site is vulnerable. The free kit is public, MIT-licensed, and read-only:
{{repoUrl}}

Run it yourself, read the code, and decide. If it is useful, the paid work is a fixed-scope verification with a written authorisation.
```

### “Too expensive”

```text
Start with the free kit. If it passes, you may not need us. If it flags a gap, verification is fixed-scope and starts at $1,500 for up to five hosts. Compare that with the cost of an incident, a customer notification, or a failed client audit.
```

### Unsubscribe

Reply once:

```text
Removed. You will not hear from us again on this topic. Sorry for the interruption.
```

Then add the address and domain to the suppression list immediately.

---

## Subject-line rules

Good:

- `PHP patch evidence for your client sites`
- `Free PHP security self-audit for {{company}}`
- `A read-only PHP audit you can run yourself`
- `Closing the loop on PHP patch evidence`

Avoid:

- `URGENT: your site is vulnerable`
- `You have been hacked`
- `Final notice`
- `Re: our conversation` when there was no conversation
- Emoji, ALL CAPS, and more than one exclamation mark
- Anything that claims a vulnerability you have not verified with authorisation
