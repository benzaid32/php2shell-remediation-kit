# Lead research: public signals only

## Target profile

Prioritise organisations that:

1. **Publicly provide PHP services** (Laravel, Symfony, WordPress, Magento, WooCommerce, custom PHP).
2. Have **customer-facing functionality**: logins, accounts, checkout, uploads, forms, APIs, or member areas.
3. Manage **multiple hosts** (agencies, MSPs, hosting providers) or have a **patch deadline**.
4. Can give **written authorisation** for the hosts in scope.
5. Have a **business reason** for evidence: client request, insurer, board, procurement, or compliance.

## Public signals you may use

- The company’s own service pages (“Laravel development”, “WordPress agency”, “managed PHP hosting”).
- Public job postings for PHP, Laravel, Symfony, WordPress, or Magento roles.
- Public case studies and portfolios that name the stack.
- Public agency directories (Clutch, DesignRush, GoodFirms, The Manifest).
- Public GitHub organisations with PHP repositories.
- Public conference sponsor lists (Laravel, PHP, WordCamp).
- Public hosting documentation that lists PHP versions.
- Public status pages or security pages that mention PHP.

Record the **source URL** for every signal. If you cannot link to it, do not use it.

## What you must not do

- Do not port-scan, fuzz, brute-force, or run vulnerability scanners against a third-party host.
- Do not force-browse admin panels, upload directories, or backup files.
- Do not probe PHP versions through crafted requests, headers, or error messages.
- Do not use Shodan/Censys/FOFA queries to build a “vulnerable” list.
- Do not buy or use leaked databases.
- Do not scrape LinkedIn or ignore robots/terms of service.
- Do not guess personal email addresses.
- Do not send a claim that a company is vulnerable.

The free kit exists so the company can check its own host. That is the legal and ethical boundary.

## Search queries

Use these manually in a normal search engine or public directory. Adapt to your region and language.

### Agencies and MSPs

```text
"Laravel development agency" "case study"
"WordPress agency" "managed hosting" "clients"
"PHP development company" "ecommerce"
"Magento agency" "support" "clients"
"managed WordPress hosting" "PHP 8.3"
"PHP agency" "security" "clients"
```

### Job-posting signals

```text
"PHP developer" "agency" "remote"
"Laravel developer" "client sites"
"WordPress developer" "managed hosting"
"Symfony developer" "agency"
```

Use job boards manually and respect their terms. A job post is a public signal, not permission to contact a personal address.

### Public code and community signals

```text
site:github.com "laravel" "agency"
site:github.com "wordpress" "agency"
"Laravel Partner" directory
"WordPress VIP partner" directory
"PHP UK" sponsors
"Laravel Live" sponsors
```

### Local SMEs

```text
"WordPress" "booking" "<?php" "city name"
"WooCommerce" "customer account" "city name"
"membership site" "WordPress" "city name"
```

Do not use the `<?php` query to probe; it is only a public search hint. Never send crafted requests to a site.

## Qualification score

Score each lead 1–5:

| Score | Profile | Action |
|---:|---|---|
| 5 | Agency/MSP, 10+ client sites, public PHP signal, named ops/security contact | Personalised outreach + call |
| 4 | E-commerce/membership, 5+ hosts, customer accounts/uploads | Personalised outreach |
| 3 | SME with a public PHP app, 1–5 hosts | Free kit + light follow-up |
| 2 | Unclear stack, no public signal, or no budget | Nurture only |
| 1 | Consumer, no authority, or no business use case | Do not contact |

Only 4s and 5s get a personalised first line. Everyone else gets the free kit at most.

## Manual research workflow

1. Pick one segment and one region (for example, Laravel agencies in the UK).
2. Open a public directory or search results page.
3. Open the company’s own website. Confirm the PHP signal on a service or case-study page.
4. Find a **role-based** contact or public contact form. Do not guess personal emails.
5. Record the company, source URL, public signal, segment, and estimated host count.
6. Score the lead.
7. Write the first line using the actual public signal.
8. Add to the CRM and check the suppression list.
9. Send only if the compliance checklist in `README.md` is complete.

## CRM fields

Use `leads-template.csv`:

- `company`
- `website`
- `segment`
- `contact_name`
- `contact_role`
- `contact_email`
- `public_php_signal`
- `source_url`
- `hosts_estimate`
- `priority`
- `status`
- `last_touch`
- `next_step`
- `notes`

Do not store passwords, tokens, customer data, or unnecessary personal information.

## Example first lines

Good:

> “I saw that {{company}} lists Laravel development and managed client hosting on your services page ({{sourceUrl}}).”

> “Your public case study for {{client}} mentions a Laravel backend ({{sourceUrl}}).”

Bad:

> “We scanned your website and found you are vulnerable.”

> “Your PHP version is out of date.”

> “I found your personal email in a database.”

The first two are unauthorised claims. The third is a privacy and compliance problem.
