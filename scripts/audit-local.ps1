<#
.SYNOPSIS
  Read-only local audit for CVE-2026-109618 / CVE-2026-109619 on Windows.

.DESCRIPTION
  Checks local PHP binaries, versions, INI values, and common Windows web
  server exposure. Makes no network requests and does not exploit anything.
  Use only on hosts you own or are explicitly authorized to administer.

.PARAMETER PhpPath
  One or more explicit paths to php.exe. If omitted, common locations are
  searched and PATH is checked.

.PARAMETER Verify
  Post-patch verification mode.

.PARAMETER VendorPatched
  Operator confirms a vendor backport. Treat upstream versions below the
  fixed release as patched.

.PARAMETER NoColor
  Disable colored output.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\audit-local.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\audit-local.ps1 -Verify
#>

[CmdletBinding()]
param(
    [string[]]$PhpPath = @(),
    [switch]$Verify,
    [switch]$VendorPatched,
    [switch]$NoColor
)

$ErrorActionPreference = 'Continue'

$script:Fixed82 = '8.2.35'
$script:Fixed83 = '8.3.36'
$script:Fixed84 = '8.4.27'
$script:Fixed85 = '8.5.12'
$script:FoundAny = 0
$script:CveRisk = $false
$script:ConfigWarn = $false
$script:UseColor = -not $NoColor

function Write-Section {
    param([string]$Title)
    Write-Host ''
    if ($script:UseColor) {
        Write-Host "== $Title ==" -ForegroundColor Cyan
    } else {
        Write-Host "== $Title =="
    }
}

function Write-Pass {
    param([string]$Message)
    if ($script:UseColor) { Write-Host "[PASS] $Message" -ForegroundColor Green }
    else { Write-Host "[PASS] $Message" }
}

function Write-Warn {
    param([string]$Message)
    if ($script:UseColor) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
    else { Write-Host "[WARN] $Message" }
}

function Write-Fail {
    param([string]$Message)
    if ($script:UseColor) { Write-Host "[FAIL] $Message" -ForegroundColor Red }
    else { Write-Host "[FAIL] $Message" }
}

function Write-Note {
    param([string]$Message)
    if ($script:UseColor) { Write-Host "[INFO] $Message" -ForegroundColor DarkCyan }
    else { Write-Host "[INFO] $Message" }
}

function Get-PhpVersion {
    param([string]$Php)
    try {
        $out = & $Php -r 'echo PHP_VERSION;' 2>$null
        return (($out | Out-String).Trim())
    } catch {
        return ''
    }
}

function Get-PhpSapi {
    param([string]$Php)
    try {
        $out = & $Php -r 'echo PHP_SAPI;' 2>$null
        return (($out | Out-String).Trim())
    } catch {
        return ''
    }
}

function Get-PhpIniFile {
    param([string]$Php)
    try {
        $lines = & $Php --ini 2>$null
        foreach ($line in $lines) {
            if ($line -match '^Loaded Configuration File:\s*(.+)$') {
                return $Matches[1].Trim()
            }
        }
    } catch {
        return 'unknown'
    }
    return 'unknown'
}

function Get-IniValue {
    param([string]$Php, [string]$Key)
    try {
        $out = & $Php -r "echo ini_get('$Key');" 2>$null
        return (($out | Out-String).Trim())
    } catch {
        return ''
    }
}

function Test-BoolOn {
    param([string]$Value)
    return @('1', 'On', 'on', 'ON', 'true', 'TRUE', 'yes', 'YES') -contains $Value
}

function ConvertTo-Mb {
    param([string]$Value)
    $v = ($Value -replace '\s', '').ToUpperInvariant()
    if ($v -eq '-1') { return -1 }
    if ($v -match '^(\d+)G$') { return ([int]$Matches[1] * 1024) }
    if ($v -match '^(\d+)M$') { return [int]$Matches[1] }
    if ($v -match '^(\d+)K$') { return [int]([int]$Matches[1] / 1024) }
    if ($v -match '^\d+$') { return [int]$v }
    return 0
}

function Get-Branch {
    param([string]$Version)
    $core = ($Version -replace '^([0-9]+\.[0-9]+\.[0-9]+).*', '$1')
    if ($core -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') { return 'unknown' }
    $v = [version]$core
    return "$($v.Major).$($v.Minor)"
}

function Get-FixedForBranch {
    param([string]$Branch)
    switch ($Branch) {
        '8.5' { return $script:Fixed85 }
        '8.4' { return $script:Fixed84 }
        '8.3' { return $script:Fixed83 }
        '8.2' { return $script:Fixed82 }
        default { return 'n/a' }
    }
}

function Get-CveStatus {
    param([string]$Version)
    $core = ($Version -replace '^([0-9]+\.[0-9]+\.[0-9]+).*', '$1')
    if ($core -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') { return 'UNKNOWN' }
    $v = [version]$core
    $branch = "$($v.Major).$($v.Minor)"

    switch ($branch) {
        '8.5' { $fixed = $script:Fixed85 }
        '8.4' { $fixed = $script:Fixed84 }
        '8.3' { $fixed = $script:Fixed83 }
        '8.2' { $fixed = $script:Fixed82 }
        '8.1' { return 'UNSUPPORTED_AFFECTED' }
        '8.0' { return 'UNSUPPORTED_AFFECTED' }
        '7.4' { return 'UNSUPPORTED_AFFECTED' }
        default {
            if ($v.Major -eq 8) { return 'CHECK_ADVISORY' }
            return 'UNKNOWN'
        }
    }

    if ($v -ge [version]$fixed) { return 'PATCHED_UPSTREAM' }
    return 'POTENTIALLY_VULNERABLE'
}

function Test-PhpBinary {
    param([string]$Php)

    if (-not (Test-Path -LiteralPath $Php -PathType Leaf)) {
        Write-Fail "not found: $Php"
        return
    }

    $version = Get-PhpVersion $Php
    if ([string]::IsNullOrWhiteSpace($version)) {
        Write-Fail "could not execute or read version: $Php"
        return
    }

    $script:FoundAny++
    $sapi = Get-PhpSapi $Php
    $ini = Get-PhpIniFile $Php
    $fileVersion = ''
    try {
        $fileVersion = (Get-Item -LiteralPath $Php).VersionInfo.ProductVersion
        if ([string]::IsNullOrWhiteSpace($fileVersion)) {
            $fileVersion = (Get-Item -LiteralPath $Php).VersionInfo.FileVersion
        }
    } catch {
        $fileVersion = 'unknown'
    }

    Write-Host "  $Php"
    Write-Host "    version: $version"
    Write-Host "    SAPI: $sapi"
    Write-Host "    ini: $ini"
    Write-Host "    file version: $fileVersion"

    $status = Get-CveStatus $version
    $branch = Get-Branch $version
    $fixed = Get-FixedForBranch $branch

    switch ($status) {
        'PATCHED_UPSTREAM' {
            Write-Pass "CVE status: patched upstream (>= $fixed)"
        }
        'POTENTIALLY_VULNERABLE' {
            if ($VendorPatched) {
                Write-Pass "CVE status: vendor backport confirmed by operator (upstream $version < $fixed)"
                $status = 'PATCHED_VENDOR'
            } else {
                Write-Warn "CVE status: potentially vulnerable (upstream $version < $fixed); verify vendor backport"
                $script:CveRisk = $true
            }
        }
        'UNSUPPORTED_AFFECTED' {
            Write-Fail "CVE status: unsupported branch (< 8.2); affected. Upgrade."
            $script:CveRisk = $true
        }
        'CHECK_ADVISORY' {
            Write-Warn "CVE status: branch not in fixed map; check the advisory"
            $script:CveRisk = $true
        }
        default {
            Write-Warn "CVE status: unknown"
            $script:CveRisk = $true
        }
    }

    $mem = Get-IniValue $Php 'memory_limit'
    $post = Get-IniValue $Php 'post_max_size'
    $upload = Get-IniValue $Php 'upload_max_filesize'
    $progress = Get-IniValue $Php 'session.upload_progress.enabled'
    $backtraces = Get-IniValue $Php 'fatal_error_backtraces'
    $maxFiles = Get-IniValue $Php 'max_file_uploads'
    $maxVars = Get-IniValue $Php 'max_input_vars'
    $maxExec = Get-IniValue $Php 'max_execution_time'
    $display = Get-IniValue $Php 'display_errors'
    $logErrors = Get-IniValue $Php 'log_errors'

    Write-Host "    config: memory_limit=$mem post_max_size=$post upload_max_filesize=$upload session.upload_progress=$progress"

    if ($status -eq 'PATCHED_UPSTREAM' -or $status -eq 'PATCHED_VENDOR') {
        Write-Note 'runtime is patched; hardening checks are informational'
        return
    }

    if ($mem -eq '-1') {
        Write-Pass 'memory_limit=-1 (OOM mitigation present)'
    } else {
        Write-Warn "memory_limit=$mem (OOM path not mitigated)"
        $script:ConfigWarn = $true
    }

    $postMb = ConvertTo-Mb $post
    if ($postMb -eq -1 -or $postMb -eq 0) {
        Write-Warn "post_max_size=$post (unlimited request body)"
        $script:ConfigWarn = $true
    } elseif ($postMb -gt 32) {
        Write-Warn "post_max_size=$post (>32M; reduce or enforce proxy limits)"
        $script:ConfigWarn = $true
    } elseif ($postMb -gt 8) {
        Write-Note "post_max_size=$post (large; ensure uploads are intended)"
    } else {
        Write-Pass "post_max_size=$post (reduced)"
    }

    $uploadMb = ConvertTo-Mb $upload
    if ($postMb -ne -1 -and $uploadMb -ne -1 -and $uploadMb -gt $postMb) {
        Write-Warn "upload_max_filesize=$upload exceeds post_max_size=$post"
        $script:ConfigWarn = $true
    }

    if (Test-BoolOn $progress) {
        Write-Warn 'session.upload_progress.enabled=On (stale-state path)'
        $script:ConfigWarn = $true
    } else {
        Write-Pass 'session.upload_progress.enabled=Off'
    }

    if ($branch -eq '8.5') {
        if (Test-BoolOn $backtraces) {
            Write-Warn 'fatal_error_backtraces=On (PHP 8.5 path)'
            $script:ConfigWarn = $true
        } else {
            Write-Pass 'fatal_error_backtraces=Off'
        }
    }

    if ($maxFiles -match '^\d+$' -and [int]$maxFiles -gt 20) {
        Write-Warn "max_file_uploads=$maxFiles (>20)"
        $script:ConfigWarn = $true
    }
    if ($maxVars -match '^\d+$' -and [int]$maxVars -gt 1000) {
        Write-Warn "max_input_vars=$maxVars (>1000)"
        $script:ConfigWarn = $true
    }
    if ($maxExec -eq '0') {
        Write-Warn 'max_execution_time=0 (no timeout)'
        $script:ConfigWarn = $true
    }
    if (Test-BoolOn $display) {
        Write-Note 'display_errors=On (information disclosure; not the CVE path)'
    }
    if (-not (Test-BoolOn $logErrors)) {
        Write-Note 'log_errors=Off (enable during the audit window)'
    }
}

function Get-PhpCandidates {
    $bins = @()

    if ($PhpPath.Count -gt 0) {
        return $PhpPath
    }

    $cmd = Get-Command php -ErrorAction SilentlyContinue
    if ($null -ne $cmd -and $null -ne $cmd.Source) {
        $bins += $cmd.Source
    }

    $patterns = @(
        'C:\php\php.exe',
        'C:\php*\php.exe',
        'C:\Program Files\PHP\php.exe',
        'C:\Program Files (x86)\PHP\php.exe',
        'C:\xampp\php\php.exe',
        'C:\wamp64\bin\php\php*\php.exe',
        'C:\laragon\bin\php\php*\php.exe',
        'C:\tools\php*\php.exe',
        'C:\ProgramData\chocolatey\bin\php.exe'
    )

    foreach ($pattern in $patterns) {
        $items = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            $bins += $item.FullName
        }
    }

    return ($bins | Select-Object -Unique)
}

Write-Section "PHP2Shell local audit (Windows)"
Write-Host '  Read-only. No network access. No exploitation.'

$bins = @(Get-PhpCandidates)
if ($bins.Count -eq 0) {
    Write-Fail 'No PHP binary found. Use -PhpPath C:\path\to\php.exe.'
    exit 1
}

Write-Section 'PHP runtimes'
foreach ($php in $bins) {
    Test-PhpBinary $php
}

Write-Section 'Web server / SAPI exposure'
$iis = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
if ($null -ne $iis) {
    Write-Host "  IIS (W3SVC): $($iis.Status)"
} else {
    Write-Host '  IIS: not detected'
}

$procs = Get-Process -Name httpd, nginx, php-cgi, php-fpm -ErrorAction SilentlyContinue
if ($null -ne $procs -and $procs.Count -gt 0) {
    foreach ($p in $procs) {
        Write-Host "  process: $($p.ProcessName) (PID $($p.Id))"
    }
} else {
    Write-Host '  no httpd/nginx/php-cgi/php-fpm processes detected'
}

$services = Get-Service -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match 'php|apache|nginx' -or $_.DisplayName -match 'PHP|Apache|nginx'
}
if ($null -ne $services -and $services.Count -gt 0) {
    foreach ($s in $services) {
        Write-Host "  service: $($s.Name) [$($s.Status)] - $($s.DisplayName)"
    }
} else {
    Write-Host '  no PHP/Apache/nginx services detected'
}

$appHost = Join-Path $env:windir 'System32\inetsrv\config\applicationHost.config'
if (Test-Path -LiteralPath $appHost) {
    Write-Host "  IIS config: $appHost"
    $hits = Select-String -Path $appHost -Pattern 'php' -SimpleMatch -ErrorAction SilentlyContinue | Select-Object -First 20
    if ($null -ne $hits) {
        foreach ($hit in $hits) {
            Write-Host "    line $($hit.LineNumber): $($hit.Line.Trim())"
        }
    } else {
        Write-Host '    no PHP handler lines found'
    }
}

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Section 'Containers'
    try {
        $containers = docker ps --format '{{.Names}}`t{{.Image}}' 2>$null
        $matching = $containers | Where-Object { $_ -match '(?i)php|wordpress|laravel|symfony|drupal|joomla|moodle' }
        if ($null -ne $matching) {
            foreach ($c in $matching) { Write-Host "  $c" }
        } else {
            Write-Note 'no PHP-related running Docker containers detected'
        }
    } catch {
        Write-Note 'Docker is installed but not reachable'
    }
}

Write-Section 'Summary'
Write-Host "  Host: $env:COMPUTERNAME"
Write-Host "  Date: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
Write-Host "  Mode: $(if ($Verify) { 'verify' } else { 'audit' })"
Write-Host "  PHP runtimes checked: $($script:FoundAny)"
if ($VendorPatched) {
    Write-Host '  Vendor backport override: yes (operator-confirmed)'
}

if ($script:CveRisk) {
    Write-Fail 'Potential CVE exposure detected.'
    Write-Host '  Patch to a fixed release or verify a vendor backport, then re-run.'
} else {
    Write-Pass 'No potential CVE exposure detected by the local version checks.'
}

if ($script:ConfigWarn) {
    Write-Warn 'High-risk configuration detected on an unpatched runtime.'
}

if ($Verify) {
    if ($script:CveRisk) {
        Write-Fail 'VERIFICATION FAILED: at least one runtime is not confirmed patched.'
    } else {
        Write-Pass 'VERIFICATION PASSED: detected runtimes are patched upstream or operator-confirmed vendor backports.'
    }
}

Write-Host '  Note: this audit is read-only and does not test exploitability.'
Write-Host '  Check the vendor advisory for the exact package version, not only the file version.'

if ($script:CveRisk) { exit 2 }
exit 0
