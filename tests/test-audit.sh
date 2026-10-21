#!/usr/bin/env bash
# test-audit.sh - deterministic tests for audit-local.sh using a stub PHP binary.
# No real PHP installation, network, or services required.

set -u

CDPATH=""
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
AUDIT="$SCRIPT_DIR/../scripts/audit-local.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/php" <<'STUB'
#!/usr/bin/env bash
set -u
case "${1:-}" in
    -r)
        expr="${2:-}"
        case "$expr" in
            *PHP_VERSION*) printf '%s' "${STUB_VERSION:-8.3.6}" ;;
            *PHP_SAPI*) printf '%s' "cli" ;;
            *memory_limit*) printf '%s' "${STUB_MEMORY_LIMIT:--1}" ;;
            *post_max_size*) printf '%s' "${STUB_POST_MAX_SIZE:-8M}" ;;
            *upload_max_filesize*) printf '%s' "${STUB_UPLOAD_MAX_FILESIZE:-2M}" ;;
            *session.upload_progress.enabled*) printf '%s' "${STUB_UPLOAD_PROGRESS:-}" ;;
            *fatal_error_backtraces*) printf '%s' "${STUB_FATAL_BACKTRACES:-}" ;;
            *max_file_uploads*) printf '%s' "${STUB_MAX_FILE_UPLOADS:-20}" ;;
            *max_input_vars*) printf '%s' "${STUB_MAX_INPUT_VARS:-1000}" ;;
            *max_execution_time*) printf '%s' "${STUB_MAX_EXECUTION_TIME:-30}" ;;
            *display_errors*) printf '%s' "${STUB_DISPLAY_ERRORS:-}" ;;
            *log_errors*) printf '%s' "${STUB_LOG_ERRORS:-1}" ;;
            *) printf '' ;;
        esac
        ;;
    --ini)
        printf 'Loaded Configuration File: %s\n' "${STUB_INI:-/tmp/php.ini}"
        ;;
    -v)
        printf 'PHP %s (cli) (built: test)\n' "${STUB_VERSION:-8.3.6}"
        ;;
esac
STUB
chmod +x "$TMP/php"

OUT=""
RC=0
FAILURES=0

run_audit() {
    local ver="$1"
    shift
    OUT="$(STUB_VERSION="$ver" bash "$AUDIT" --php "$TMP/php" --no-system --no-color "$@" 2>&1)"
    RC=$?
}

run_audit_env() {
    local ver="$1"
    shift
    OUT="$(STUB_VERSION="$ver" "$@" bash "$AUDIT" --php "$TMP/php" --no-system --no-color 2>&1)"
    RC=$?
}

check_rc() {
    local expected="$1" label="$2"
    if [ "$RC" -ne "$expected" ]; then
        printf 'FAIL: %s (expected rc %s, got %s)\n' "$label" "$expected" "$RC"
        printf '%s\n' "$OUT" | sed 's/^/    /'
        FAILURES=$((FAILURES + 1))
    else
        printf 'ok: %s (rc %s)\n' "$label" "$RC"
    fi
}

check_contains() {
    local needle="$1" label="$2"
    if printf '%s' "$OUT" | grep -Fq "$needle"; then
        printf 'ok: %s contains "%s"\n' "$label" "$needle"
    else
        printf 'FAIL: %s missing "%s"\n' "$label" "$needle"
        printf '%s\n' "$OUT" | sed 's/^/    /'
        FAILURES=$((FAILURES + 1))
    fi
}

run_audit 8.3.6
check_rc 2 "PHP 8.3.6 is potentially vulnerable"
check_contains "POTENTIALLY_VULNERABLE" "PHP 8.3.6"

run_audit 8.3.36
check_rc 0 "PHP 8.3.36 is patched upstream"
check_contains "PATCHED_UPSTREAM" "PHP 8.3.36"

run_audit 8.2.35
check_rc 0 "PHP 8.2.35 is patched upstream"

run_audit 8.4.26
check_rc 2 "PHP 8.4.26 is potentially vulnerable"

run_audit 8.4.27
check_rc 0 "PHP 8.4.27 is patched upstream"

run_audit 8.3.6 --verify
check_rc 2 "verify mode fails on unpatched PHP"
check_contains "VERIFICATION FAILED" "verify mode"

run_audit 8.3.36 --verify
check_rc 0 "verify mode passes on patched PHP"
check_contains "VERIFICATION PASSED" "verify mode"

run_audit 8.3.6 --vendor-patched --verify
check_rc 0 "vendor backport override passes verify mode"
check_contains "vendor backport confirmed" "vendor override"

run_audit 8.1.31
check_rc 2 "PHP 8.1 is unsupported and affected"
check_contains "unsupported branch" "PHP 8.1"

run_audit_env 8.3.6 env STUB_UPLOAD_PROGRESS=1
check_rc 2 "unpatched runtime with upload progress enabled"
check_contains "session.upload_progress.enabled=On" "config risk"

OUT="$(bash "$AUDIT" --php "$TMP/does-not-exist" --no-system --no-color 2>&1)"
RC=$?
check_rc 1 "nonexistent PHP path fails closed"
check_contains "not executable" "nonexistent PHP path"

if [ "$FAILURES" -ne 0 ]; then
    printf '\n%s test(s) failed\n' "$FAILURES"
    exit 1
fi

printf '\nAll audit tests passed\n'
