#!/usr/bin/env bash
# verify-patch.sh - convenience wrapper for post-patch verification.
#
# Runs the read-only local audit in --verify mode. No network access.

set -u

CDPATH=""
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
exec bash "$SCRIPT_DIR/audit-local.sh" --verify "$@"
