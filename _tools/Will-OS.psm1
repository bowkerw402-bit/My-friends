# Will-OS.psm1 - short daily verbs for the two-agent operating system.
# Load once from your PowerShell profile:  Import-Module "$HOME\.claude\tools\Will-OS.psm1"

$script:Tools   = Join-Path $HOME '.claude\tools'
$script:Vault   = 'C:\Users\bowke\OneDrive\Documents\GitHub\My-friends'
$script:BizRoot = 'C:\Users\bowke\OneDrive\Desktop\CLAUDE\Business'

function today {
    # Open this morning's Mission Control report.
    Invoke-Item -LiteralPath (Join-Path $script:Vault 'mission-control\DAILY.md')
}

function board {
    # Refresh DAILY.md + BOARD.md (commit + push), then open DAILY.
    & (Join-Path $script:Tools 'Build-MissionControl.ps1') -Commit
    Invoke-Item -LiteralPath (Join-Path $script:Vault 'mission-control\DAILY.md')
}

function run {
    # run "<task>" [venture-slug] [-Rounds N] [-Solo]
    # A real two-agent step. Resolves the work dir from a venture slug (or uses the current dir),
    # demands a genuine two-agent run by default, and opens the Run Record when done.
    param(
        [Parameter(Mandatory=$true, Position=0)][string]$Task,
        [Parameter(Position=1)][string]$Venture,
        [int]$Rounds = 3,
        [switch]$Solo
    )
    $wd = if ($Venture) { Join-Path $script:BizRoot $Venture } else { (Get-Location).Path }
    if ($Venture -and -not (Test-Path -LiteralPath $wd)) {
        Write-Host "No venture folder: $wd" -ForegroundColor Yellow
        Write-Host "Ventures:" -ForegroundColor DarkGray
        Get-ChildItem -LiteralPath $script:BizRoot -Directory | Where-Object { $_.Name -notmatch '^_' } | ForEach-Object { Write-Host ("  " + $_.Name) }
        return
    }
    $oargs = @('-Task', $Task, '-WorkDir', $wd, '-Rounds', $Rounds, '-Open')
    if (-not $Solo) { $oargs += '-RequireBothAgents' }   # default: fail loud if Codex is down
    & (Join-Path $script:Tools 'orchestrate.ps1') @oargs
}

function capture {
    # capture "<idea>"  -> a timestamped note in the inbox (nothing rots in chat scrollback).
    param([Parameter(Mandatory=$true, Position=0)][string]$Idea)
    $dir = Join-Path $script:Vault '00-inbox'
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $f = Join-Path $dir ((Get-Date).ToString('yyyy-MM-dd--HHmmss') + '.md')
    $body = "# Inbox - " + (Get-Date).ToString('yyyy-MM-dd HH:mm') + "`n`n" + $Idea + "`n"
    [System.IO.File]::WriteAllText($f, $body, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Captured -> $f" -ForegroundColor Green
}

function handoff {
    # handoff <codex|claude> "<the ask>" [venture]  -> writes a visible handoff doc to the vault.
    param(
        [Parameter(Mandatory=$true, Position=0)][ValidateSet('codex','claude')][string]$To,
        [Parameter(Mandatory=$true, Position=1)][string]$Ask,
        [Parameter(Position=2)][string]$Venture = 'cross-cutting'
    )
    $from = if ($To -eq 'codex') { 'claude' } else { 'codex' }
    $dir  = Join-Path $script:Vault 'handoffs'
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $slug = ($Ask.ToLowerInvariant() -replace '[^a-z0-9]+','-').Trim('-')
    if ($slug.Length -gt 30) { $slug = $slug.Substring(0,30).Trim('-') }
    $f = Join-Path $dir ((Get-Date).ToString('yyyy-MM-dd') + "-$from-to-$To-$slug.md")
    $body = "---`nfrom: $from`nto: $To`nventure: $Venture`ndate: " + (Get-Date).ToString('yyyy-MM-dd') +
            "`nstatus: open`n---`n`n# Handoff: $Ask  ($from -> $To)`n`n## The ask`n$Ask`n`n" +
            "## Definition of done`n- [ ] `n`n## Boundaries`n- Draft-only unless Will says otherwise.`n- No client PII in the shared vault.`n`n## Reply ($To writes here)`n_(pending)_`n"
    [System.IO.File]::WriteAllText($f, $body, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Handoff written -> $f" -ForegroundColor Green
}

function standard {
    # standard <area> "<the rule>"  -> files a dated rule that BOTH agents read before producing anything.
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet('writing-style','ways-of-working','visual-design','email')][string]$Area,
        [Parameter(Mandatory=$true, Position=1)][string]$Rule
    )
    $f = Join-Path $script:Vault ("_reference\standards\" + $Area + ".md")
    if (-not (Test-Path -LiteralPath $f)) { Write-Host "No standards file: $f" -ForegroundColor Yellow; return }
    $enc  = [System.Text.UTF8Encoding]::new($false)
    $text = [System.IO.File]::ReadAllText($f, $enc)
    $entry = "`n## " + $Rule + "  (set " + (Get-Date).ToString('yyyy-MM-dd') + ")`n`n_Filed by Will._`n"
    $m = [regex]::Match($text, '(?m)^#\s.*$')      # newest sits directly under the title
    if ($m.Success) {
        $pos  = $m.Index + $m.Length
        $text = $text.Substring(0, $pos) + "`n" + $entry + $text.Substring($pos)
    } else { $text = $text + $entry }
    [System.IO.File]::WriteAllText($f, $text, $enc)
    Write-Host ("Standard filed -> " + $f) -ForegroundColor Green
}

Export-ModuleMember -Function today, board, run, capture, handoff, standard
