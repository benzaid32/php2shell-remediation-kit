# Business page

Static, dependency-free landing page for the paid verification/remediation offer.

## Before promoting

Edit `config.js`:

- `contactEmail` — a mailbox you monitor. The current value is a placeholder.
- `bookingUrl` — optional Calendly/Cal.com link. Leave empty to use the form.
- `formEndpoint` — optional JSON form endpoint. If empty, the form opens a prefilled email.
- `githubUrl` — the free remediation kit.

Replace the sample prices in `index.html` with your real scope. The current figures are starting points, not a quote.

## Local preview

From the repository root:

```bash
python -m http.server 8080 --directory docs
```

Open `http://localhost:8080/`.

## Deployment

The page is designed for GitHub Pages from the `/docs` folder.

1. Push `main`.
2. Repository **Settings → Pages → Build and deployment**.
3. Source: **Deploy from a branch**.
4. Branch: **main**, folder: **/docs**.
5. Save. The URL is usually `https://<user>.github.io/<repo>/`.

A `.nojekyll` file is included so static assets are served as-is.

## Privacy and compliance

- The page includes `privacy.html`; review it with counsel and update the processor/retention details before collecting submissions.
- If you enable `formEndpoint`, add a privacy notice that names the processor and retention period.
- Do not collect passwords, tokens, customer data, or third-party host details.
- Keep the “written scope before access” statement visible.
- Do not add claims that a visitor’s site is vulnerable unless you have authorised evidence.
- If you send outreach email, follow the rules in `../outreach/README.md`.
