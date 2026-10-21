# Contributing

Thanks for helping improve this remediation kit.

## What is welcome

- Corrections to vendor-specific patch steps
- Additional distro/control-panel commands that are safe and read-only
- Improvements to the local audit scripts
- Translations of the checklist and executive briefing
- Clearer explanations for SMEs

## What is not welcome

- Exploit payloads, PoCs, or attack requests
- Internet-wide scanners, target lists, or Shodan/Censys queries
- Instructions for testing systems without authorization
- Customer data, credentials, or third-party host details
- Claims that a WAF or configuration change is a complete fix

## Pull requests

1. Keep changes focused.
2. Run `bash -n scripts/*.sh` and `bash tests/test-audit.sh`.
3. Update the relevant documentation.
4. Describe the environment you tested on.
5. Do not include real hostnames or IP addresses.

## Style

- Prefer plain language over jargon.
- State limitations and uncertainty honestly.
- Use official vendor links where possible.
- Keep scripts read-only unless a change is explicitly opt-in.
