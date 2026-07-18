param(
    [Parameter(Mandatory=$true)]
    [string]$Task,
    [string]$WorkDir = (Get-Location).Path,
    [int]$Rounds = 3
)

# Two-agent orchestrator: Claude Code <-> Codex hold an actual back-and-forth
# conversation. Each turn, an agent sees the full transcript so far and replies,
# doing real work in $WorkDir. They alternate for $Rounds rounds or until either
# ends a message with [DONE]. The whole conversation is logged to the shared vault.

$vault   = "C:\Users\bowke\OneDrive\Documents\GitHub\My-friends"
$scratch = Join-Path $env:TEMP "orchestrate"
New-Item -ItemType Directory -Force -Path $scratch | Out-Null

# --- Resolve CLIs ---------------------------------------------------------
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
$claudeExe = if ($claudeCmd) { $claudeCmd.Source } else { "$env:APPDATA\npm\claude.ps1" }
$codexCmd  = Get-Command codex -ErrorAction SilentlyContinue

# --- Health guards (fail loudly, not silently) ----------------------------
$authStatus = & $claudeExe auth status 2>&1 | Out-String
if ($authStatus -notmatch '"loggedIn":\s*true') {
    Write-Host "`n[ERROR] Claude Code CLI is not authenticated. Run 'claude auth login' in a terminal, then re-run." -ForegroundColor Red
    exit 1
}
if (-not $codexCmd) {
    Write-Host "`n[ERROR] Codex CLI not found. Install it with: npm i -g @openai/codex" -ForegroundColor Red
    exit 1
}
# IMPORTANT: use the .cmd shim, not the .ps1 shim. Get-Command resolves 'codex' to
# codex.ps1, which HANGS when forwarding exec args from PowerShell. codex.cmd works.
$codexExe = Join-Path $env:APPDATA "npm\codex.cmd"
if (-not (Test-Path $codexExe)) { $codexExe = $codexCmd.Source }

Write-Host "`n=== ORCHESTRATOR - Claude <-> Codex ===" -ForegroundColor Cyan
Write-Host "Goal:    $Task"    -ForegroundColor White
Write-Host "WorkDir: $WorkDir" -ForegroundColor White
Write-Host "Rounds:  $Rounds`n" -ForegroundColor White

Set-Location -LiteralPath $WorkDir

$transcript = ""

function Build-Prompt([string]$name, [string]$other) {
    # keep the transcript from overflowing the command line on long runs
    $convo = if ($transcript -eq "") { "(nothing yet - you speak first)" }
             elseif ($transcript.Length -gt 12000) { "...(earlier trimmed)..." + $transcript.Substring($transcript.Length - 12000) }
             else { $transcript }
    return @"
You are $name, one of two AI coding agents working as a team (the other is $other).
You share ONE goal and ONE working directory: $WorkDir

GOAL:
$Task

CONVERSATION SO FAR (most recent last):
$convo

Your turn. Move the work forward AND talk directly to ${other} - share what you did or found,
ask questions, answer theirs, divide the work, or verify/critique their output. Be concrete
and concise (aim under ~250 words). Do real work in the directory when it helps. Do NOT use
[DONE] on your opening turn before ${other} has replied. Only once ${other} has responded
AND you both actually agree the GOAL is complete should you end a message with [DONE].
"@
}

function Invoke-Claude([string]$prompt) {
    $out = & $claudeExe --print --dangerously-skip-permissions -p $prompt 2>$null
    return (($out -join "`n").Trim())
}

function Invoke-Codex([string]$prompt) {
    $of = Join-Path $scratch "codex-out.txt"
    Remove-Item -LiteralPath $of -ErrorAction SilentlyContinue
    # --ignore-user-config skips ~25 plugins + 4 MCP servers (one with a 120s startup
    # timeout) that otherwise boot on EVERY turn and make Codex take minutes/hang.
    # We re-supply just the model so turns run lean (~10-15s). Auth still uses CODEX_HOME.
    & $codexExe exec --ignore-user-config -c 'model=gpt-5.6-sol' -c 'model_reasoning_effort=low' `
        --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -C $WorkDir -o $of $prompt 2>$null | Out-Null
    if (Test-Path -LiteralPath $of) { return ((Get-Content -LiteralPath $of -Raw).Trim()) }
    return "(Codex produced no output - run 'codex exec ...' manually to see the error)"
}

$done = $false
$codexSpoke = $false
for ($r = 1; $r -le $Rounds -and -not $done; $r++) {
    Write-Host "---------- Round $r / $Rounds ----------" -ForegroundColor DarkCyan

    Write-Host "`n[Claude]" -ForegroundColor Blue
    $c = Invoke-Claude (Build-Prompt "Claude Code" "Codex")
    Write-Host $c -ForegroundColor Gray
    $transcript += "`n`n### Claude (round $r)`n$c"
    # only let Claude end the exchange AFTER Codex has actually replied at least once
    if ($codexSpoke -and ($c -match '\[DONE\]')) { $done = $true; break }

    Write-Host "`n[Codex]" -ForegroundColor Magenta
    $x = Invoke-Codex (Build-Prompt "Codex" "Claude Code")
    Write-Host $x -ForegroundColor Gray
    $transcript += "`n`n### Codex (round $r)`n$x"
    $codexSpoke = $true
    if ($x -match '\[DONE\]') { $done = $true }
}

# --- Log the whole conversation to the shared vault -----------------------
$date = Get-Date -Format 'yyyy-MM-dd HH:mm'
$log  = "`n## $date | $WorkDir`n**Goal:** $Task`n**Conversation:**$transcript`n`n---"
$logFile = Join-Path $vault "log\sessions.md"
if (-not (Test-Path $logFile)) { New-Item -ItemType File -Force -Path $logFile | Out-Null; Set-Content $logFile "# Session Log" }
Add-Content $logFile $log
Push-Location $vault
git pull --rebase -q 2>$null | Out-Null
git add log/sessions.md 2>$null | Out-Null
$short = $Task.Substring(0, [Math]::Min(60, $Task.Length))
git commit -q -m "Orchestrate: $short" 2>$null | Out-Null
git push -q 2>$null | Out-Null
Pop-Location

Write-Host "`n=== DONE - full conversation logged to My-friends/log/sessions.md ===" -ForegroundColor Cyan
