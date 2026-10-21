#!/usr/bin/env bash
# collect-inventory.sh - read-only local PHP inventory for remediation planning.
#
# No network access. No exploitation. Use only on hosts you own or administer.
# The report may contain hostnames and local paths; review before sharing.

set -u

SCRIPT_VERSION="1.0.0"
OUTPUT=""
QUIET=0

usage() {
    cat <<'EOF'
Usage: collect-inventory.sh [options]

Read-only local inventory of PHP runtimes, packages, web servers, services,
configs, and containers.

Options:
  --output FILE   Write the report to FILE instead of stdout
  --quiet         Suppress the progress line on stderr
  -h, --help      Show this help
  -V, --version   Show script version

Examples:
  bash scripts/collect-inventory.sh
  sudo bash scripts/collect-inventory.sh --output /tmp/php-inventory.txt
EOF
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --output)
                shift
                if [ "$#" -eq 0 ]; then
                    printf '[ERROR] --output requires a path\n' >&2
                    exit 1
                fi
                OUTPUT="$1"
                ;;
            --output=*)
                OUTPUT="${1#*=}"
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
                printf '[ERROR] Unknown option: %s\n' "$1" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
}

heading() {
    printf '\n===== %s =====\n' "$*"
}

run() {
    printf '\n$ %s\n' "$*"
    # The caller controls the command; this is a read-only inventory helper.
    "$@" 2>&1 || printf '[command exited nonzero]\n'
}

os_name() {
    sed -n 's/^PRETTY_NAME="\(.*\)"/\1/p' /etc/os-release 2>/dev/null | head -n 1
}

collect_header() {
    heading "Host"
    printf 'hostname: %s\n' "$(hostname 2>/dev/null || uname -n 2>/dev/null || printf 'unknown')"
    printf 'date_utc: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || printf 'unknown')"
    printf 'os: %s\n' "$(os_name)"
    printf 'kernel: %s\n' "$(uname -srm 2>/dev/null || printf 'unknown')"
    printf 'user: %s\n' "$(id -un 2>/dev/null || printf 'unknown')"
    printf 'script_version: %s\n' "$SCRIPT_VERSION"
}

collect_php_bins() {
    heading "PHP binaries"
    local -a bins=()
    local p
    p="$(command -v php 2>/dev/null || true)"
    [ -n "$p" ] && bins+=("$p")
    for p in \
        /usr/bin/php \
        /usr/local/bin/php \
        /opt/*/bin/php \
        /usr/local/php*/bin/php \
        /usr/local/cpanel/3rdparty/bin/php \
        /opt/cpanel/ea-php*/root/usr/bin/php \
        /usr/local/lsws/lsphp*/bin/lsphp; do
        [ -x "$p" ] && bins+=("$p")
    done
    if [ "${#bins[@]}" -eq 0 ]; then
        printf 'No PHP CLI binary found.\n'
        return 0
    fi
    local bin
    while IFS= read -r bin; do
        printf '\n--- %s ---\n' "$bin"
        printf 'version: %s\n' "$("$bin" -r 'echo PHP_VERSION;' 2>/dev/null || printf 'unknown')"
        printf 'sapi: %s\n' "$("$bin" -r 'echo PHP_SAPI;' 2>/dev/null || printf 'unknown')"
        printf 'ini: %s\n' "$("$bin" --ini 2>/dev/null | sed -n 's/^Loaded Configuration File:[[:space:]]*//p' | head -n 1)"
        printf 'modules: %s\n' "$("$bin" -m 2>/dev/null | tr '\n' ' ' || printf 'unknown')"
    done < <(printf '%s\n' "${bins[@]}" | awk 'NF && !seen[$0]++')
}

collect_php_packages() {
    heading "PHP packages"
    if command -v dpkg-query >/dev/null 2>&1; then
        printf '\n$ dpkg-query -W php*\n'
        dpkg-query -W -f='${Package}\t${Version}\n' 'php*' 2>&1 | awk -F '\t' 'NF > 1 && $2 != ""' || printf '[command exited nonzero]\n'
    fi
    if command -v rpm >/dev/null 2>&1; then
        run rpm -qa 'php*'
    fi
    if command -v apk >/dev/null 2>&1; then
        printf '\n$ apk info -v | grep ^php\n'
        apk info -v 2>&1 | grep -E '^php' || printf 'no php packages found\n'
    fi
    if command -v composer >/dev/null 2>&1; then
        run composer --version
    fi
}

collect_fpm() {
    heading "PHP-FPM"
    local p
    for p in /usr/sbin/php-fpm* /usr/local/sbin/php-fpm* /opt/*/sbin/php-fpm /usr/local/php*/sbin/php-fpm; do
        [ -x "$p" ] || continue
        printf '\n--- %s ---\n' "$p"
        "$p" -v 2>&1 | head -n 2 || true
    done
    if command -v systemctl >/dev/null 2>&1; then
        printf '\n-- systemd PHP units --\n'
        systemctl list-units --type=service --all --no-legend 2>/dev/null | grep -i 'php' || printf 'none found\n'
    fi
    if command -v pgrep >/dev/null 2>&1; then
        printf '\n-- running php-fpm processes --\n'
        pgrep -a php-fpm 2>/dev/null || printf 'none found\n'
    fi
}

collect_pools() {
    heading "FPM pool files"
    local f found=0
    for f in /etc/php/*/fpm/pool.d/*.conf /usr/local/etc/php-fpm.d/*.conf /opt/*/etc/php-fpm.d/*.conf; do
        [ -f "$f" ] || continue
        found=1
        printf '\n--- %s ---\n' "$f"
        grep -nE '^[[:space:]]*(user|group|listen|pm|pm\.max_children|pm\.max_requests|php_admin_value|php_value|php_admin_flag|php_flag)' "$f" 2>/dev/null || true
    done
    [ "$found" -eq 0 ] && printf 'No FPM pool files found in common paths.\n'
}

collect_web() {
    heading "Web servers"
    if command -v apache2ctl >/dev/null 2>&1; then
        printf '\n-- apache2ctl -M (PHP lines) --\n'
        apache2ctl -M 2>/dev/null | grep -i 'php' || printf 'no PHP module lines\n'
    elif command -v httpd >/dev/null 2>&1; then
        printf '\n-- httpd -M (PHP lines) --\n'
        httpd -M 2>/dev/null | grep -i 'php' || printf 'no PHP module lines\n'
    fi
    if command -v nginx >/dev/null 2>&1; then
        printf '\n-- nginx --\n'
        nginx -v 2>&1 || true
    fi
    if command -v systemctl >/dev/null 2>&1; then
        printf '\n-- running web services --\n'
        systemctl list-units --type=service --state=running --no-legend 2>/dev/null \
            | grep -iE 'apache|httpd|nginx|php|franken|lsws|litespeed' || printf 'none found\n'
    fi
    if command -v pgrep >/dev/null 2>&1; then
        printf '\n-- web processes --\n'
        pgrep -a -f 'apache2|httpd|nginx|frankenphp|lsphp|lsws' 2>/dev/null | head -n 50 || printf 'none found\n'
    fi
}

collect_apache_configs() {
    heading "Apache PHP settings"
    local f found=0
    for f in \
        /etc/apache2/mods-enabled/php*.conf \
        /etc/apache2/conf-enabled/*.conf \
        /etc/httpd/conf.d/*.conf \
        /etc/httpd/conf.modules.d/*.conf; do
        [ -f "$f" ] || continue
        if grep -qE 'php_(admin_)?(value|flag)' "$f" 2>/dev/null; then
            found=1
            printf '\n--- %s ---\n' "$f"
            grep -nE 'php_(admin_)?(value|flag)' "$f" 2>/dev/null || true
        fi
    done
    [ "$found" -eq 0 ] && printf 'No Apache PHP settings found in common paths.\n'
}

collect_ini_files() {
    heading "PHP INI files"
    local f found=0
    for f in /etc/php/*/*/php.ini /etc/php.ini /usr/local/etc/php.ini /usr/local/lib/php.ini /opt/*/etc/php.ini; do
        [ -f "$f" ] || continue
        found=1
        printf '%s\n' "$f"
    done
    [ "$found" -eq 0 ] && printf 'No php.ini found in common paths.\n'
}

collect_containers() {
    heading "Containers"
    if command -v docker >/dev/null 2>&1; then
        printf '\n-- docker ps --\n'
        docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null | grep -iE 'php|wordpress|laravel|symfony|drupal|joomla|moodle' || printf 'no matching running containers\n'
        printf '\n-- docker images --\n'
        docker images --format '{{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}' 2>/dev/null | grep -iE 'php|wordpress|laravel|symfony|drupal|joomla|moodle' || printf 'no matching images\n'
    else
        printf 'docker not found\n'
    fi
    if command -v podman >/dev/null 2>&1; then
        printf '\n-- podman ps --\n'
        podman ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null | grep -iE 'php|wordpress|laravel|symfony|drupal|joomla|moodle' || printf 'no matching running containers\n'
    fi
}

main() {
    parse_args "$@"
    if [ -n "$OUTPUT" ]; then
        exec > "$OUTPUT"
    fi
    if [ "$QUIET" -eq 0 ]; then
        printf 'Collecting local PHP inventory (read-only, no network)...\n' >&2
    fi
    collect_header
    collect_php_bins
    collect_php_packages
    collect_fpm
    collect_pools
    collect_web
    collect_apache_configs
    collect_ini_files
    collect_containers
    heading "End of report"
}

main "$@"
