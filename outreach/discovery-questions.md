# Triage call questions

Use these in the 20-minute call. The goal is to qualify, not to pressure. If the client cannot authorise the work, stop and explain what they need to do first.

## Situation

1. What does the application do, and who depends on it?
2. Which PHP versions, SAPIs, and control panels do you know about?
3. Is PHP managed by your team, a hosting provider, an agency, or a control panel?
4. How many production, staging, and internal hosts are in scope?
5. Do you have containers, CI images, or bundled runtimes (XAMPP, Laragon, cPanel, Plesk)?
6. Do users upload files, log in, check out, or submit forms?

## Patch status

7. What exactly was updated, and when?
8. Do you have the vendor package version and advisory link?
9. Did you verify the web SAPI, or only the CLI?
10. Did you restart PHP-FPM/Apache and clear OPcache?
11. What does your change record show?

## Risk and urgency

12. Is there a client, insurer, board, or procurement deadline?
13. Have you seen unusual errors, uploads, outbound connections, or new files?
14. Who would need to approve a verification or remediation window?
15. What would a successful outcome look like?

## Scope and commercials

16. Can you provide written authorisation for each host?
17. Do you have backups and a rollback plan?
18. What is the change window and the application owner's availability?
19. What budget range is already approved?
20. Who else needs to be in the decision?

## Red flags

- Wants you to test a host they do not own.
- Wants a “scan” of a competitor or a third party.
- Refuses to sign a scope or name the authorised hosts.
- Wants exploit proof against production.
- Wants a guarantee that they cannot be hacked.
- Pushes for immediate access before backups or approval.

Say no to these. They are legal and reputational risks, not sales opportunities.

## Close

If qualified:

> “The next step is a one-page scope. I will list the hosts, the read-only actions, the deliverables, the window, and the fee. You confirm the authorised signatory, and we schedule the evidence collection.”

If not qualified:

> “You do not need a paid engagement yet. Run the free kit, fix the pass/fail items, and come back if you need independent evidence. I will send the link.”
