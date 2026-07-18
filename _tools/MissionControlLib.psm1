# MissionControlLib.psm1 - v1.0.0
# Generates the human-facing "window": BOARD.md (funnel/portfolio state from the
# ledger) and DAILY.md (morning digest from run manifests + ledger). Source ASCII-only.
#
# Reuses the ledger row format + stage mapping from Business/_ops/Build-BoardState.ps1
# so BOARD counts stay consistent with the Monday mirror.

# Self-contained UTF-8 helpers, kept private. This module must NOT force-reimport
# OrchestratorLib - doing so (Import-Module -Force) removes that module and detaches
# its functions from whatever script imported both.
function _ReadUtf8 {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) { return '' }
    return [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
}
function _WriteUtf8 {
    param([string]$Path, [string]$Text = '')
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Resolve-LedgerStage {
    param([string]$Status)
    switch -Regex ($Status.Trim()) {
        '^ignited'  { return @{ group = 'In Flight'; status = 'Ignited' } }
        '^revenue'  { return @{ group = 'Revenue';   status = 'Revenue' } }
        '^stalled'  { return @{ group = 'Stalled';   status = $Status } }
        '^killed'   { return @{ group = 'Killed';    status = 'Killed' } }
        '^parked'   { return @{ group = 'Parked';    status = 'Parked' } }
        '^recurred' { return @{ group = 'Backlog';   status = "Open ($Status)" } }
        default     { return @{ group = 'Backlog';   status = 'Open' } }
    }
}

function Read-Ledger {
    param([Parameter(Mandatory=$true)][string]$LedgerPath)
    $items = @()
    if (-not (Test-Path -LiteralPath $LedgerPath)) { return $items }
    $lines = (_ReadUtf8 $LedgerPath) -split "`r?`n"
    foreach ($line in $lines) {
        $t = $line.Trim()
        if ($t -notmatch '\|') { continue }
        if ($t.StartsWith('#') -or $t.StartsWith('<!--')) { continue }
        $parts = $t -split '\s*\|\s*'
        if ($parts.Count -lt 4) { continue }
        if ($parts[0] -notmatch '^\d{4}-\d{2}-\d{2}') { continue }   # real rows start with a dated id
        $stage = Resolve-LedgerStage $parts[2]
        $items += [pscustomobject]@{
            id = $parts[0]; name = $parts[1]; rawStatus = $parts[2]
            status = $stage.status; group = $stage.group; lesson = $parts[3]
        }
    }
    return $items
}

function Get-RunManifests {
    param([Parameter(Mandatory=$true)][string]$Vault, [int]$SinceHours = 24)
    $runsDir = Join-Path $Vault 'runs'
    $out = @()
    if (-not (Test-Path -LiteralPath $runsDir)) { return $out }
    $cutoff = if ($SinceHours -gt 0) { (Get-Date).AddHours(-1 * $SinceHours) } else { [datetime]::MinValue }
    foreach ($mf in Get-ChildItem -LiteralPath $runsDir -Recurse -Filter 'manifest.json' -ErrorAction SilentlyContinue) {
        $obj = $null
        try { $obj = (_ReadUtf8 $mf.FullName) | ConvertFrom-Json } catch { continue }
        if (-not $obj) { continue }
        $ended = $mf.LastWriteTime
        if ($obj.ended_at) { try { $ended = ([datetimeoffset]::Parse($obj.ended_at)).LocalDateTime } catch { } }
        if ($ended -lt $cutoff) { continue }
        $out += [pscustomobject]@{ manifest = $obj; endedAt = $ended; path = $mf.FullName }
    }
    return @($out | Sort-Object endedAt -Descending)
}

function Get-OpenHandoffs {
    # Handoffs were being written and never read. Surface any still marked open.
    param([Parameter(Mandatory=$true)][string]$Vault)
    $dir = Join-Path $Vault 'handoffs'
    $out = @()
    if (-not (Test-Path -LiteralPath $dir)) { return $out }
    foreach ($f in Get-ChildItem -LiteralPath $dir -File -Filter *.md -ErrorAction SilentlyContinue) {
        if ($f.Name -eq 'README.md') { continue }
        $t = _ReadUtf8 $f.FullName
        if ($t -match '(?im)^status:\s*open\s*$') {
            $to = 'someone'
            $m = [regex]::Match($t, '(?im)^to:\s*(\w+)')
            if ($m.Success) { $to = $m.Groups[1].Value }
            $title = $f.BaseName
            $tm = [regex]::Match($t, '(?m)^#\s*Handoff:\s*(.+?)\s*\(')
            if ($tm.Success) { $title = $tm.Groups[1].Value.Trim() }
            $out += [pscustomobject]@{ to = $to; title = $title; file = $f.Name }
        }
    }
    return @($out)
}

function Get-OpenGates {
    # Ventures with unchecked approval items awaiting Will (willsideas ops/approvals-queue.md).
    param([Parameter(Mandatory=$true)][string]$BusinessRoot)
    $gates = @()
    if (-not (Test-Path -LiteralPath $BusinessRoot)) { return $gates }
    foreach ($q in Get-ChildItem -LiteralPath $BusinessRoot -Recurse -Filter 'approvals-queue.md' -ErrorAction SilentlyContinue) {
        if ($q.FullName -match '[\\/]_graveyard[\\/]') { continue }   # dead ventures don't nag
        $txt = _ReadUtf8 $q.FullName
        $open = @([regex]::Matches($txt, '(?m)^\s*[-*]\s*\[\s\]')).Count
        if ($open -gt 0) {
            $venture = Split-Path (Split-Path $q.FullName -Parent) -Parent | Split-Path -Leaf
            $gates += [pscustomobject]@{ venture = $venture; open = $open; path = $q.FullName }
        }
    }
    return $gates
}

function Get-RecentlyTouched {
    # Recent work is the priority signal: the most recently updated active files, newest first.
    param([Parameter(Mandatory=$true)][string]$Vault, [int]$Top = 5)
    $files = @()
    foreach ($r in @('10-active','handoffs','00-inbox')) {
        $p = Join-Path $Vault $r
        if (Test-Path -LiteralPath $p) {
            $files += Get-ChildItem -LiteralPath $p -Recurse -File -Filter *.md -ErrorAction SilentlyContinue
        }
    }
    $out = @()
    foreach ($f in (@($files) | Sort-Object LastWriteTime -Descending | Select-Object -First $Top)) {
        $age = (Get-Date) - $f.LastWriteTime
        $ago = if ($age.TotalHours -lt 1)   { ([int]$age.TotalMinutes).ToString() + 'm ago' }
               elseif ($age.TotalDays -lt 1) { ([int]$age.TotalHours).ToString()   + 'h ago' }
               else                          { ([int]$age.TotalDays).ToString()    + 'd ago' }
        $out += [pscustomobject]@{
            rel = $f.FullName.Substring($Vault.Length).TrimStart('\')
            ago = $ago
            when = $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        }
    }
    return @($out)
}

function ConvertTo-BoardMarkdown {
    param([Parameter(Mandatory=$true)]$Items)
    $groupOrder = 'In Flight','Revenue','Stalled','Backlog','Parked','Killed'
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.Append("# BOARD - Venture funnel state`n`n")
    [void]$sb.Append("_Generated ").Append((Get-Date).ToString('yyyy-MM-dd HH:mm')).Append(" from Business/_ideas/LEDGER.md. Read-only view - edit state in the ledger._`n`n")
    $total = @($Items).Count
    $inflight = @($Items | Where-Object group -eq 'In Flight').Count
    [void]$sb.Append("**").Append($total).Append(" ventures** | In Flight: ").Append($inflight)
    [void]$sb.Append(" | Backlog: ").Append(@($Items | Where-Object group -eq 'Backlog').Count)
    [void]$sb.Append(" | Parked: ").Append(@($Items | Where-Object group -eq 'Parked').Count)
    [void]$sb.Append(" | Killed: ").Append(@($Items | Where-Object group -eq 'Killed').Count).Append("`n")
    foreach ($g in $groupOrder) {
        $rows = @($Items | Where-Object group -eq $g)
        if ($rows.Count -eq 0) { continue }
        [void]$sb.Append("`n## ").Append($g).Append("  (").Append($rows.Count).Append(")`n`n")
        foreach ($r in $rows) {
            [void]$sb.Append("- **").Append($r.name).Append("** - ").Append($r.status)
            [void]$sb.Append("  (").Append($r.id).Append(")")
            if ($r.lesson) { [void]$sb.Append(" - ").Append($r.lesson) }
            [void]$sb.Append("`n")
        }
    }
    return $sb.ToString()
}

function ConvertTo-DailyMarkdown {
    param([Parameter(Mandatory=$true)]$Items, $Manifests = @(), $Gates = @(), [int]$SinceHours = 24, [double]$HoursSinceLast = 0, $Recent = @(), $Handoffs = @())
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.Append("# DAILY - ").Append((Get-Date).ToString('dddd, yyyy-MM-dd')).Append("`n`n")
    [void]$sb.Append("_Mission Control morning digest. Generated ").Append((Get-Date).ToString('HH:mm')).Append("._`n")
    if ($HoursSinceLast -gt 26) {
        $days = [math]::Floor($HoursSinceLast / 24)
        [void]$sb.Append("`n> **STALE ALARM** - previous report was ").Append($HoursSinceLast).Append("h ago (~").Append($days).Append("d). The morning routine missed a run (app closed, git push blocked, or a script error). Check the **morning-report** routine in the Scheduled section of the sidebar.`n")
    }

    # --- Runs ---
    $mans = @($Manifests)
    [void]$sb.Append("`n## Runs (last ").Append($SinceHours).Append("h)  -  ").Append($mans.Count).Append("`n`n")
    if ($mans.Count -eq 0) {
        [void]$sb.Append("_No orchestrated runs in the window._`n")
    } else {
        foreach ($m in $mans) {
            $o = $m.manifest
            $flag = if ($o.mode -ne 'two-agent') { "  **[" + $o.mode + "]**" } else { "" }
            $hm = if ($m.endedAt) { $m.endedAt.ToString('HH:mm') } else { '--:--' }
            $tShort = ($o.task -replace '\s+', ' ')
            if ($tShort.Length -gt 100) { $tShort = $tShort.Substring(0, 100).Trim() + '...' }
            [void]$sb.Append("- ").Append($hm).Append(" - ")
            [void]$sb.Append($tShort).Append($flag)
            [void]$sb.Append("  -> runs/").Append($o.run_id).Append("/`n")
        }
    }

    # --- Recently touched (recency is the priority signal) ---
    $rec = @($Recent)
    [void]$sb.Append("`n## Recently touched  -  newest first`n`n")
    if ($rec.Count -eq 0) {
        [void]$sb.Append("_Nothing updated yet._`n")
    } else {
        foreach ($x in $rec) {
            [void]$sb.Append("- **").Append($x.rel).Append("**  (").Append($x.ago).Append(", ").Append($x.when).Append(")`n")
        }
    }

    # --- Needs attention ---
    $bad = @($mans | Where-Object { $_.manifest.mode -ne 'two-agent' -or $_.manifest.review_verdict -eq 'FAIL' -or $_.manifest.outcome -eq 'incomplete' })
    [void]$sb.Append("`n## Needs attention  -  ").Append($bad.Count).Append("`n`n")
    if ($bad.Count -eq 0) {
        [void]$sb.Append("_Nothing flagged._`n")
    } else {
        foreach ($m in $bad) {
            $o = $m.manifest
            $why = if ($o.mode -ne 'two-agent') { "ran " + $o.mode + " (codex: " + $o.codex_status + "), consider re-running" }
                   elseif ($o.outcome -eq 'incomplete') { "did not finish, it ran out of rounds without the agents agreeing" }
                   else { "review verdict was FAIL" }
            [void]$sb.Append("- ").Append($o.task).Append(" - ").Append($why).Append("`n")
        }
    }

    # --- Gates awaiting Will ---
    $g = @($Gates)
    [void]$sb.Append("`n## Open gates awaiting you  -  ").Append($g.Count).Append("`n`n")
    if ($g.Count -eq 0) {
        [void]$sb.Append("_No unchecked approval items found._`n")
    } else {
        foreach ($x in $g) {
            [void]$sb.Append("- **").Append($x.venture).Append("**: ").Append($x.open).Append(" item(s) in approvals-queue`n")
        }
    }

    # --- Open handoffs between the agents ---
    $ho = @($Handoffs)
    [void]$sb.Append("`n## Open handoffs  -  ").Append($ho.Count).Append("`n`n")
    if ($ho.Count -eq 0) {
        [void]$sb.Append("_None waiting._`n")
    } else {
        foreach ($x in $ho) {
            [void]$sb.Append("- to **").Append($x.to).Append("**: ").Append($x.title).Append("  (handoffs/").Append($x.file).Append(")`n")
        }
    }

    # --- Portfolio snapshot ---
    $inflight = @($Items | Where-Object group -eq 'In Flight')
    [void]$sb.Append("`n## Portfolio  -  ").Append(@($Items).Count).Append(" ventures`n`n")
    [void]$sb.Append("In Flight (").Append($inflight.Count).Append("): ")
    if ($inflight.Count -gt 0) { [void]$sb.Append(($inflight | ForEach-Object { $_.name }) -join '; ') } else { [void]$sb.Append("none") }
    [void]$sb.Append("`n`n_Full board: mission-control/BOARD.md_`n")

    return $sb.ToString()
}

function Update-MissionControl {
    # Regenerate BOARD.md + DAILY.md into the vault's mission-control/ folder.
    param(
        [Parameter(Mandatory=$true)][string]$Vault,
        [Parameter(Mandatory=$true)][string]$LedgerPath,
        [string]$BusinessRoot = '',
        [int]$SinceHours = 24
    )
    $mcDir = Join-Path $Vault 'mission-control'
    New-Item -ItemType Directory -Force -Path $mcDir | Out-Null

    # Staleness: hours since the last successful generation (heartbeat stamped on success).
    $hbPath = Join-Path $mcDir '.heartbeat'
    $hoursSince = 0
    if (Test-Path -LiteralPath $hbPath) {
        try { $prev = [datetimeoffset]::Parse((_ReadUtf8 $hbPath).Trim()); $hoursSince = [math]::Round(((Get-Date) - $prev.LocalDateTime).TotalHours, 1) } catch { }
    }

    $items = Read-Ledger -LedgerPath $LedgerPath
    $mans  = Get-RunManifests -Vault $Vault -SinceHours $SinceHours
    $gates = if ($BusinessRoot) { Get-OpenGates -BusinessRoot $BusinessRoot } else { @() }

    _WriteUtf8 (Join-Path $mcDir 'BOARD.md') (ConvertTo-BoardMarkdown -Items $items)
    $recent   = Get-RecentlyTouched -Vault $Vault -Top 5
    $handoffs = Get-OpenHandoffs -Vault $Vault
    _WriteUtf8 (Join-Path $mcDir 'DAILY.md') (ConvertTo-DailyMarkdown -Items $items -Manifests $mans -Gates $gates -SinceHours $SinceHours -HoursSinceLast $hoursSince -Recent $recent -Handoffs $handoffs)
    _WriteUtf8 $hbPath ((Get-Date).ToString('o'))
    return [pscustomobject]@{
        board = (Join-Path $mcDir 'BOARD.md'); daily = (Join-Path $mcDir 'DAILY.md')
        ventures = @($items).Count; runs = @($mans).Count; gates = @($gates).Count; hoursSinceLast = $hoursSince
    }
}

Export-ModuleMember -Function `
    Resolve-LedgerStage, Read-Ledger, Get-RunManifests, Get-OpenGates, Get-OpenHandoffs, Get-RecentlyTouched, `
    ConvertTo-BoardMarkdown, ConvertTo-DailyMarkdown, Update-MissionControl
