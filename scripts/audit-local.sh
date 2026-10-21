#!/usr/bin/env bash
# audit-local.sh - read-only local audit for CVE-2026-109618 / CVE-2026-109619.
#
# This script does NOT exploit anything and does NOT make network requests.
# It reads local PHP versions, local INI values, and local service config.
# Use only on hosts you own or are explicitly authorized to administer.
#
# Exit codes:
#   0  no potential exposure found by these local checks
#   2  potential exposure or high-risk configuration; action required
#   1  audit could not run (for example, PHP not found)

set -u

SCRIPT_VERSION="1.0.0"
FIXED_82="8.2.35"
FIXED_83="8.3.36"
FIXED_84="8.4.27"
FIXED_85="8.5.12"

MODE="audit"
VENDOR_PATCHED=0
QUIET=0
SKIP_SYSTEM=0
COLOR="auto"
PHP_PATHS=()

C_RESET=""
C_RED=""
C_GREEN=""
C_YELLOW=""
C_BLUE=""
C_BOLD=""

FOUND_ANY=0
CVE_RISK=0
CONFIG_WARN=0
LAST_STATUS="UNKNOWN"

usage() {
    cat <<'EOF'
Usage: audit-local.sh [options]

Read-only local audit for CVE-2026-109618 / CVE-2026-109619.
No network access. No exploitation.

Options:
  --php PATH          Audit a specific PHP binary (repeatable)
  --verify            Post-patch verification mode
  --vendor-patched    Operator confirms a vendor backport; treat upstream
                      versions below the fixed release as patched
  --no-system         Audit only explicit --php binaries; skip FPM binary,
                      web server, pool, and container discovery
  --no-color          Disable ANSI color
  --color=WHEN        auto (default), always, or never
  --quiet             Suppress detail lines; print the summary
  -h, --help          Show this help
  -V, --version       Show script version

Examples:
  bash scripts/audit-local.sh
  bash scripts/audit-local.sh --php /usr/bin/php --php /usr/sbin/php-fpm8.3
  sudo bash scripts/audit-local.sh --verify
  bash scripts/audit-local.sh --verify --vendor-patched
EOF
}

setup_colors() {
    case "$COLOR" in
        never) return 0 ;;
        always) ;;
        auto) [ -t 1 ] || return 0 ;;
        *) return 0 ;;
    esac
    C_RESET=$'\033[0m'
    C_RED=$'\033[31m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_BLUE=$'\033[34m'
    C_BOLD=$'\033[1m'
}

error() {
    printf '%s[ERROR]%s %s\n' "$C_RED" "$C_RESET" "$*" >&2
}

fail() {
    printf '%s[FAIL]%s %s\n' "$C_RED" "$C_RESET" "$*"
}

pass() {
    [ "$QUIET" -eq 1 ] && return 0
    printf '%s[PASS]%s %s\n' "$C_GREEN" "$C_RESET" "$*"
}

warn() {
    [ "$QUIET" -eq 1 ] && return 0
    printf '%s[WARN]%s %s\n' "$C_YELLOW" "$C_RESET" "$*"
}

note() {
    [ "$QUIET" -eq 1 ] && return 0
    printf '%s[INFO]%s %s\n' "$C_BLUE" "$C_RESET" "$*"
}

section() {
    [ "$QUIET" -eq 1 ] && return 0
    printf '\n%s== %s ==%s\n' "$C_BOLD" "$*" "$C_RESET"
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --php)
                shift
                if [ "$#" -eq 0 ]; then
                    error "--php requires a path"
                    exit 1
                fi
                PHP_PATHS+=("$1")
                ;;
            --php=*)
                PHP_PATHS+=("${1#*=}")
                ;;
            --verify)
                MODE="verify"
                ;;
            --vendor-patched)
                VENDOR_PATCHED=1
                ;;
            --no-system)
                SKIP_SYSTEM=1
                ;;
            --no-color)
                COLOR="never"
                ;;
            --color=*)
                COLOR="${1#*=}"
                ;;
            --quiet)
                QUIET=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                printf '%s\n' "$SCRIPT_VERSION"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
}

core_version() {
    printf '%s\n' "$1" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
}

branch_of() {
    core_version "$1" | awk -F. '{print $1 "." $2}'
}

version_ge() {
    # Returns 0 when $1 >= $2 using version sort.
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n 1)" = "$2" ]
}

fixed_for_branch() {
    case "$1" in
        8.5) printf '%s' "$FIXED_85" ;;
        8.4) printf '%s' "$FIXED_84" ;;
        8.3) printf '%s' "$FIXED_83" ;;
        8.2) printf '%s' "$FIXED_82" ;;
        *) printf 'n/a' ;;
    esac
}

cve_status() {
    local ver="$1"
    local core branch fixed
    core="$(core_version "$ver")"
    branch="$(branch_of "$core")"
    case "$branch" in
        8.5) fixed="$FIXED_85" ;;
        8.4) fixed="$FIXED_84" ;;
        8.3) fixed="$FIXED_83" ;;
        8.2) fixed="$FIXED_82" ;;
        8.1|8.0|7.*|5.*)
            printf 'UNSUPPORTED_AFFECTED'
            return 0
            ;;
        8.*)
            printf 'CHECK_ADVISORY'
            return 0
            ;;
        *)
            printf 'UNKNOWN'
            return 0
            ;;
    esac
    if version_ge "$core" "$fixed"; then
        printf 'PATCHED_UPSTREAM'
    else
        printf 'POTENTIALLY_VULNERABLE'
    fi
}

php_version() {
    "$1" -r 'echo PHP_VERSION;' 2>/dev/null | tr -d '\r'
}

php_sapi() {
    "$1" -r 'echo PHP_SAPI;' 2>/dev/null | tr -d '\r'
}

ini_val() {
    local bin="$1" key="$2"
    "$bin" -r "echo ini_get('$key');" 2>/dev/null | tr -d '\r'
}

ini_file_value() {
    local f="$1" key="$2" key_re
    key_re="${key//./[.]}"
    sed -nE "s/^[[:space:]]*${key_re}[[:space:]]*=[[:space:]]*([^;[:space:]]+).*/\\1/p" "$f" | head -n 1
}

ini_file() {
    local bin="$1" line
    while IFS= read -r line; do
        case "$line" in
            "Loaded Configuration File:"*)
                printf '%s\n' "${line#*: }" | sed 's/^[[:space:]]*//'
                return 0
                ;;
        esac
    done < <("$bin" --ini 2>/dev/null)
    printf '%s\n' "unknown"
}

fpm_version() {
    "$1" -v 2>&1 | sed -nE 's/^PHP ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1 | tr -d '\r'
}

vendor_pkg_version() {
    local branch="$1" v pkg
    if command -v dpkg-query >/dev/null 2>&1; then
        for pkg in "php${branch}-cli" "php${branch}-common" "php-cli" "php"; do
            v="$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || true)"
            if [ -n "$v" ]; then
                printf '%s (%s)' "$v" "$pkg"
                return 0
            fi
        done
    fi
    if command -v rpm >/dev/null 2>&1; then
        v="$(rpm -q --qf '%{VERSION}-%{RELEASE}' php 2>/dev/null || true)"
        if [ -n "$v" ] && [ "$v" != "package php is not installed" ]; then
            printf '%s (php)' "$v"
            return 0
        fi
    fi
    if command -v apk >/dev/null 2>&1; then
        v="$(apk info -v 2>/dev/null | grep -E "^php${branch//./}" | head -n 1 || true)"
        if [ -n "$v" ]; then
            printf '%s' "$v"
            return 0
        fi
    fi
    printf 'unknown'
}

bool_on() {
    case "${1:-}" in
        1|On|on|ON|true|TRUE|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

size_to_mb() {
    local v="${1:-0}" n
    v="${v//[[:space:]]/}"
    case "$v" in
        -1) printf '%s' "-1" ;;
        *[gG]) n="${v%[gG]}"; printf '%s' "$((n * 1024))" ;;
        *[mM]) n="${v%[mM]}"; printf '%s' "$n" ;;
        *[kK]) n="${v%[kK]}"; printf '%s' "$((n / 1024))" ;;
        *) printf '%s' "$v" ;;
    esac
}

find_php_bins() {
    local -a candidates=()
    local p
    if [ "${#PHP_PATHS[@]}" -gt 0 ]; then
        for p in "${PHP_PATHS[@]}"; do
            candidates+=("$p")
        done
    else
        p="$(command -v php 2>/dev/null || true)"
        [ -n "$p" ] && candidates+=("$p")
        for p in \
            /usr/bin/php \
            /usr/local/bin/php \
            /opt/*/bin/php \
            /usr/local/php*/bin/php \
            /usr/local/cpanel/3rdparty/bin/php \
            /opt/cpanel/ea-php*/root/usr/bin/php \
            /usr/local/lsws/lsphp*/bin/lsphp; do
            [ -x "$p" ] && candidates+=("$p")
        done
    fi
    if [ "${#candidates[@]}" -eq 0 ]; then
        return 0
    fi
    printf '%s\n' "${candidates[@]}" | awk 'NF && !seen[$0]++'
}

find_fpm_bins() {
    local -a candidates=()
    local p
    for p in \
        /usr/sbin/php-fpm* \
        /usr/local/sbin/php-fpm* \
        /opt/*/sbin/php-fpm \
        /usr/local/php*/sbin/php-fpm; do
        [ -x "$p" ] && candidates+=("$p")
    done
    p="$(command -v php-fpm 2>/dev/null || true)"
    [ -n "$p" ] && candidates+=("$p")
    if [ "${#candidates[@]}" -eq 0 ]; then
        return 0
    fi
    printf '%s\n' "${candidates[@]}" | awk 'NF && !seen[$0]++'
}

evaluate_status() {
    local ver="$1" fixed
    LAST_STATUS="$(cve_status "$ver")"
    fixed="$(fixed_for_branch "$(branch_of "$ver")")"
    case "$LAST_STATUS" in
        PATCHED_UPSTREAM)
            pass "CVE status: patched upstream (>= $fixed)"
            ;;
        POTENTIALLY_VULNERABLE)
            if [ "$VENDOR_PATCHED" -eq 1 ]; then
                pass "CVE status: vendor backport confirmed by operator (upstream $ver < $fixed)"
                LAST_STATUS="PATCHED_VENDOR"
            else
                warn "CVE status: potentially vulnerable (upstream $ver < $fixed); verify vendor backport"
                CVE_RISK=1
            fi
            ;;
        UNSUPPORTED_AFFECTED)
            fail "CVE status: unsupported branch (< 8.2); affected. Upgrade."
            CVE_RISK=1
            ;;
        CHECK_ADVISORY)
            warn "CVE status: branch not in fixed map; check the advisory"
            CVE_RISK=1
            ;;
        *)
            warn "CVE status: unknown"
            CVE_RISK=1
            ;;
    esac
}

check_config() {
    local bin="$1" status="$2" ver="$3" sapi="$4"
    local mem post upload progress backtraces maxfiles maxvars display logerr
    local post_mb upload_mb branch risky

    mem="$(ini_val "$bin" memory_limit)"
    post="$(ini_val "$bin" post_max_size)"
    upload="$(ini_val "$bin" upload_max_filesize)"
    progress="$(ini_val "$bin" session.upload_progress.enabled)"
    backtraces="$(ini_val "$bin" fatal_error_backtraces)"
    maxfiles="$(ini_val "$bin" max_file_uploads)"
    maxvars="$(ini_val "$bin" max_input_vars)"
    display="$(ini_val "$bin" display_errors)"
    logerr="$(ini_val "$bin" log_errors)"
    branch="$(branch_of "$ver")"

    printf '    config: memory_limit=%s post_max_size=%s upload_max_filesize=%s session.upload_progress=%s\n' \
        "${mem:-?}" "${post:-?}" "${upload:-?}" "${progress:-Off}"
    if [ "$sapi" = "cli" ]; then
        note "CLI INI values may differ from the web SAPI; see the web INI snapshot"
    fi

    case "$status" in
        POTENTIALLY_VULNERABLE|UNSUPPORTED_AFFECTED|CHECK_ADVISORY) risky=1 ;;
        *) risky=0 ;;
    esac

    if [ "$risky" -eq 0 ]; then
        note "runtime is patched; hardening checks are informational"
        return 0
    fi

    if [ "$mem" = "-1" ]; then
        pass "memory_limit=-1 (CLI; verify web SAPI)"
    else
        warn "memory_limit=${mem:-unknown} (CLI; OOM path not mitigated)"
        CONFIG_WARN=1
    fi

    post_mb="$(size_to_mb "${post:-0}")"
    if [ "$post_mb" = "-1" ] || [ "$post_mb" = "0" ]; then
        warn "post_max_size=${post:-unknown} (CLI; unlimited request body)"
        CONFIG_WARN=1
    elif [ "$post_mb" -gt 32 ] 2>/dev/null; then
        warn "post_max_size=${post} (CLI; >32M; reduce or enforce proxy limits)"
        CONFIG_WARN=1
    elif [ "$post_mb" -gt 8 ] 2>/dev/null; then
        note "post_max_size=${post} (CLI; large; ensure uploads are intended)"
    else
        pass "post_max_size=${post} (CLI; reduced)"
    fi

    upload_mb="$(size_to_mb "${upload:-0}")"
    if [ "$post_mb" != "-1" ] && [ "$upload_mb" != "-1" ] && [ "$upload_mb" -gt "$post_mb" ] 2>/dev/null; then
        warn "upload_max_filesize=${upload} exceeds post_max_size=${post}"
        CONFIG_WARN=1
    fi

    if bool_on "$progress"; then
        warn "session.upload_progress.enabled=On (CLI; stale-state path)"
        CONFIG_WARN=1
    else
        pass "session.upload_progress.enabled=Off (CLI; verify web SAPI)"
    fi

    if [ "$branch" = "8.5" ]; then
        if bool_on "$backtraces"; then
            warn "fatal_error_backtraces=On (CLI; PHP 8.5 path)"
            CONFIG_WARN=1
        else
            pass "fatal_error_backtraces=Off (CLI; verify web SAPI)"
        fi
    fi

    if [ "${maxfiles:-0}" -gt 20 ] 2>/dev/null; then
        warn "max_file_uploads=${maxfiles} (CLI; >20)"
        CONFIG_WARN=1
    fi
    if [ "${maxvars:-0}" -gt 1000 ] 2>/dev/null; then
        warn "max_input_vars=${maxvars} (CLI; >1000)"
        CONFIG_WARN=1
    fi
    if bool_on "$display"; then
        note "display_errors=On (information disclosure; not the CVE path)"
    fi
    if ! bool_on "$logerr"; then
        note "log_errors=Off (enable during the audit window)"
    fi
}

check_binary() {
    local bin="$1" ver sapi ini pkg
    if [ ! -x "$bin" ]; then
        fail "not executable: $bin"
        return 0
    fi
    ver="$(php_version "$bin")"
    if [ -z "$ver" ]; then
        fail "could not execute or read version: $bin"
        return 0
    fi
    sapi="$(php_sapi "$bin")"
    ini="$(ini_file "$bin")"
    pkg="$(vendor_pkg_version "$(branch_of "$ver")")"

    FOUND_ANY=$((FOUND_ANY + 1))
    printf '  %s\n' "$bin"
    printf '    version: %s\n' "$ver"
    printf '    SAPI: %s\n' "${sapi:-unknown}"
    printf '    ini: %s\n' "${ini:-unknown}"
    printf '    vendor package: %s\n' "$pkg"
    evaluate_status "$ver"
    printf '    status: %s\n' "$LAST_STATUS"
    check_config "$bin" "$LAST_STATUS" "$ver" "$sapi"
}

check_fpm_binary() {
    local bin="$1" ver
    if [ ! -x "$bin" ]; then
        fail "not executable: $bin"
        return 0
    fi
    ver="$(fpm_version "$bin")"
    if [ -z "$ver" ]; then
        fail "could not read FPM version: $bin"
        return 0
    fi
    FOUND_ANY=$((FOUND_ANY + 1))
    printf '  %s\n' "$bin"
    printf '    version: %s\n' "$ver"
    printf '    SAPI: fpm-fcgi\n'
    evaluate_status "$ver"
    printf '    status: %s\n' "$LAST_STATUS"
}

check_fpm_pools() {
    local f found=0
    for f in \
        /etc/php/*/fpm/pool.d/*.conf \
        /usr/local/etc/php-fpm.d/*.conf \
        /opt/*/etc/php-fpm.d/*.conf; do
        [ -f "$f" ] || continue
        found=1
        printf '  %s\n' "$f"
        grep -nE '^[[:space:]]*(php_admin_value|php_value|php_admin_flag|php_flag)\[(memory_limit|post_max_size|session\.upload_progress\.enabled|fatal_error_backtraces)\]' "$f" 2>/dev/null || true
    done
    [ "$found" -eq 0 ] && note "no FPM pool configs found in common paths"
}

check_apache_config() {
    local f found=0
    for f in \
        /etc/apache2/mods-enabled/php*.conf \
        /etc/apache2/conf-enabled/*.conf \
        /etc/httpd/conf.d/*.conf \
        /etc/httpd/conf.modules.d/*.conf; do
        [ -f "$f" ] || continue
        if grep -qE 'php_(admin_)?(value|flag)' "$f" 2>/dev/null; then
            found=1
            printf '  %s\n' "$f"
            grep -nE 'php_(admin_)?(value|flag)' "$f" 2>/dev/null | head -n 20 || true
        fi
    done
    [ "$found" -eq 0 ] && note "no Apache PHP settings found in common config paths"
}

check_web_ini_files() {
    local f found=0
    for f in \
        /etc/php/*/apache2/php.ini \
        /etc/php/*/fpm/php.ini \
        /etc/php/*/cli/php.ini \
        /etc/php.ini \
        /usr/local/etc/php.ini \
        /usr/local/etc/php/*/php.ini; do
        [ -f "$f" ] || continue
        found=1
        printf '  %s\n' "$f"
        grep -nE '^[[:space:]]*(memory_limit|post_max_size|upload_max_filesize|session\.upload_progress\.enabled|fatal_error_backtraces|max_file_uploads|max_input_vars)[[:space:]]*=' "$f" 2>/dev/null | sed 's/^/    /' || true
        case "$f" in
            */cli/php.ini) ;;
            *) evaluate_web_ini "$f" ;;
        esac
    done
    [ "$found" -eq 0 ] && note "no php.ini found in common web SAPI paths"
}

evaluate_web_ini() {
    local f="$1" mem post progress backtraces maxfiles maxvars branch post_mb
    [ "$CVE_RISK" -eq 1 ] || return 0

    mem="$(ini_file_value "$f" memory_limit)"
    post="$(ini_file_value "$f" post_max_size)"
    progress="$(ini_file_value "$f" session.upload_progress.enabled)"
    backtraces="$(ini_file_value "$f" fatal_error_backtraces)"
    maxfiles="$(ini_file_value "$f" max_file_uploads)"
    maxvars="$(ini_file_value "$f" max_input_vars)"
    branch="$(printf '%s' "$f" | sed -nE 's#.*/php/([0-9]+\.[0-9]+)/.*#\1#p')"

    if [ -z "$mem" ]; then
        warn "web INI memory_limit not set; PHP default is finite (128M)"
        CONFIG_WARN=1
    elif [ "$mem" = "-1" ]; then
        pass "web INI memory_limit=-1"
    else
        warn "web INI memory_limit=$mem (OOM path not mitigated)"
        CONFIG_WARN=1
    fi

    post_mb="$(size_to_mb "${post:-8M}")"
    if [ -z "$post" ]; then
        note "web INI post_max_size not set; PHP default is 8M"
    elif [ "$post_mb" = "-1" ] || [ "$post_mb" = "0" ]; then
        warn "web INI post_max_size=$post (unlimited request body)"
        CONFIG_WARN=1
    elif [ "$post_mb" -gt 32 ] 2>/dev/null; then
        warn "web INI post_max_size=$post (>32M; reduce or enforce proxy limits)"
        CONFIG_WARN=1
    elif [ "$post_mb" -gt 8 ] 2>/dev/null; then
        note "web INI post_max_size=$post (large; ensure uploads are intended)"
    else
        pass "web INI post_max_size=$post (reduced)"
    fi

    if [ -z "$progress" ]; then
        warn "web INI session.upload_progress not set; PHP default is On"
        CONFIG_WARN=1
    elif bool_on "$progress"; then
        warn "web INI session.upload_progress=On (stale-state path)"
        CONFIG_WARN=1
    else
        pass "web INI session.upload_progress=Off"
    fi

    if [ "$branch" = "8.5" ] && bool_on "$backtraces"; then
        warn "web INI fatal_error_backtraces=On (PHP 8.5 path)"
        CONFIG_WARN=1
    fi

    if [ -n "$maxfiles" ] && [ "$maxfiles" -gt 20 ] 2>/dev/null; then
        warn "web INI max_file_uploads=$maxfiles (>20)"
        CONFIG_WARN=1
    fi
    if [ -n "$maxvars" ] && [ "$maxvars" -gt 1000 ] 2>/dev/null; then
        warn "web INI max_input_vars=$maxvars (>1000)"
        CONFIG_WARN=1
    fi
}

detect_web() {
    local apache_out="" f fpm_out="" out

    if command -v apache2ctl >/dev/null 2>&1; then
        apache_out="$(apache2ctl -M 2>/dev/null || true)"
    elif command -v httpd >/dev/null 2>&1; then
        apache_out="$(httpd -M 2>/dev/null || true)"
    fi

    if printf '%s\n' "$apache_out" | grep -qi 'php'; then
        printf '  Apache mod_php: DETECTED\n'
        printf '%s\n' "$apache_out" | grep -i 'php' | sed 's/^/    /'
    else
        for f in /etc/apache2/mods-enabled/php*.load /etc/httpd/conf.modules.d/*php*.conf; do
            [ -e "$f" ] || continue
            printf '  Apache mod_php: DETECTED (%s)\n' "$f"
            break
        done
    fi

    if command -v systemctl >/dev/null 2>&1; then
        fpm_out="$(systemctl list-units --type=service --state=running --no-legend 2>/dev/null | grep -i 'php.*fpm' || true)"
    fi
    if [ -z "$fpm_out" ] && command -v pgrep >/dev/null 2>&1; then
        fpm_out="$(pgrep -a php-fpm 2>/dev/null || true)"
    fi
    if [ -n "$fpm_out" ]; then
        printf '  PHP-FPM: RUNNING\n'
        printf '%s\n' "$fpm_out" | sed 's/^/    /'
    else
        printf '  PHP-FPM: not detected as running\n'
    fi

    if command -v pgrep >/dev/null 2>&1; then
        out="$(pgrep -a frankenphp 2>/dev/null || true)"
        if [ -n "$out" ]; then
            printf '  FrankenPHP: RUNNING\n'
            printf '%s\n' "$out" | sed 's/^/    /'
        fi
        out="$(pgrep -a lsphp 2>/dev/null || true)"
        if [ -n "$out" ]; then
            printf '  LiteSpeed PHP: RUNNING\n'
            printf '%s\n' "$out" | sed 's/^/    /'
        fi
    fi
}

detect_containers() {
    local out
    if command -v docker >/dev/null 2>&1; then
        if command -v timeout >/dev/null 2>&1; then
            out="$(timeout 5 docker ps --format '{{.Names}}\t{{.Image}}' 2>/dev/null | grep -iE 'php|wordpress|laravel|symfony|drupal|joomla|moodle' || true)"
        else
            out="$(docker ps --format '{{.Names}}\t{{.Image}}' 2>/dev/null | grep -iE 'php|wordpress|laravel|symfony|drupal|joomla|moodle' || true)"
        fi
        if [ -n "$out" ]; then
            printf '  Docker:\n'
            printf '%s\n' "$out" | sed 's/^/    /'
        else
            note "no PHP-related running Docker containers detected"
        fi
    fi
    if command -v podman >/dev/null 2>&1; then
        out="$(podman ps --format '{{.Names}}\t{{.Image}}' 2>/dev/null | grep -iE 'php|wordpress|laravel|symfony|drupal|joomla|moodle' || true)"
        if [ -n "$out" ]; then
            printf '  Podman:\n'
            printf '%s\n' "$out" | sed 's/^/    /'
        fi
    fi
}

summary() {
    local host os_name
    host="$(hostname 2>/dev/null || uname -n 2>/dev/null || printf 'unknown')"
    os_name="$(sed -n 's/^PRETTY_NAME="\(.*\)"/\1/p' /etc/os-release 2>/dev/null | head -n 1)"
    [ -n "$os_name" ] || os_name="$(uname -srm 2>/dev/null || printf 'unknown')"

    printf '\n%s== Summary ==%s\n' "$C_BOLD" "$C_RESET"
    printf '  Host: %s\n' "$host"
    printf '  OS: %s\n' "$os_name"
    printf '  Date: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || printf 'unknown')"
    printf '  Mode: %s\n' "$MODE"
    printf '  PHP runtimes checked: %s\n' "$FOUND_ANY"
    if [ "$VENDOR_PATCHED" -eq 1 ]; then
        printf '  Vendor backport override: yes (operator-confirmed)\n'
    fi

    if [ "$CVE_RISK" -eq 1 ]; then
        printf '%s[FAIL]%s Potential CVE exposure detected.\n' "$C_RED" "$C_RESET"
        printf '  Patch to a fixed release or verify a vendor backport, then re-run.\n'
    else
        printf '%s[PASS]%s No potential CVE exposure detected by the local version checks.\n' "$C_GREEN" "$C_RESET"
    fi

    if [ "$CONFIG_WARN" -eq 1 ]; then
        printf '%s[WARN]%s High-risk configuration detected on an unpatched runtime.\n' "$C_YELLOW" "$C_RESET"
    fi

    if [ "$MODE" = "verify" ]; then
        if [ "$CVE_RISK" -eq 1 ]; then
            printf '%s[FAIL]%s VERIFICATION FAILED: at least one runtime is not confirmed patched.\n' "$C_RED" "$C_RESET"
        else
            printf '%s[PASS]%s VERIFICATION PASSED: detected runtimes are patched upstream or operator-confirmed vendor backports.\n' "$C_GREEN" "$C_RESET"
        fi
    fi

    printf '  Note: distro backports may not change the upstream version. Verify the vendor advisory.\n'
    printf '  This audit is read-only and does not test exploitability.\n'
}

main() {
    parse_args "$@"
    setup_colors

    section "PHP2Shell local audit v$SCRIPT_VERSION"
    printf '  Read-only. No network access. No exploitation.\n'
    if [ "$MODE" = "verify" ]; then
        printf '  Verification mode: a nonzero result means do not close the change yet.\n'
    fi

    local -a bins=() fpm_bins=()
    while IFS= read -r line; do
        [ -n "$line" ] && bins+=("$line")
    done < <(find_php_bins)
    if [ "$SKIP_SYSTEM" -eq 0 ]; then
        while IFS= read -r line; do
            [ -n "$line" ] && fpm_bins+=("$line")
        done < <(find_fpm_bins)
    fi

    if [ "${#bins[@]}" -eq 0 ] && [ "${#fpm_bins[@]}" -eq 0 ]; then
        error "No PHP binary found. Use --php /path/to/php."
        exit 1
    fi

    if [ "${#bins[@]}" -gt 0 ]; then
        section "PHP CLI / generic runtimes"
        local bin
        for bin in "${bins[@]}"; do
            check_binary "$bin"
        done
    fi

    if [ "${#fpm_bins[@]}" -gt 0 ]; then
        section "PHP-FPM binaries"
        local fpm
        for fpm in "${fpm_bins[@]}"; do
            check_fpm_binary "$fpm"
        done
    fi

    if [ "$FOUND_ANY" -eq 0 ]; then
        error "No PHP runtime could be audited successfully."
        exit 1
    fi

    if [ "$SKIP_SYSTEM" -eq 0 ]; then
        section "Web SAPI exposure"
        detect_web

        section "FPM pool overrides"
        check_fpm_pools

        section "Apache PHP settings"
        check_apache_config

        section "Web SAPI INI snapshot"
        check_web_ini_files

        section "Containers"
        detect_containers
    else
        note "system service, pool, and container discovery skipped (--no-system)"
    fi

    summary

    if [ "$CVE_RISK" -eq 1 ]; then
        exit 2
    fi
    exit 0
}

main "$@"
