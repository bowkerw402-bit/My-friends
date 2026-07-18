param(
    [Parameter(Mandatory=$true)]
    [string]$Task,
    [string]$WorkDir = (Get-Location).Path,
    [int]$Rounds = 3,
    [string]$Vault = 'C:\Users\bowke\OneDrive\Documents\GitHub\My-friends',
    [switch]$RequireBothAgents,  # abort (exit 2) if Codex isn't genuinely answering
    [switch]$Open                # open the Run Record folder when done
)

# Two-agent orchestrator v2: Claude Code <-> Codex hold a real back-and-forth, each
# turn seeing the transcript so far, until one ends a message with [DONE]. Everything is
# captured UTF-8-clean, Codex output is health-checked (never faked), and the whole run
# is logged to the shared vault. The heavy lifting lives in OrchestratorLib.psm1.

Import-Module (Join-Path $PSScriptRoot 'OrchestratorLib.psm1') -Force -DisableNameChecking
Set-Utf8Console

$vault   = $Vault
$scratch = Join-Path $env:TEMP 'orchestrate'
New-Item -ItemType Directory -Force -Path $scratch | Out-Null

# --- Resolve CLIs ---------------------------------------------------------
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
$claudeExe = if ($claudeCmd) { $claudeCmd.Source } else { "$env:APPDATA\npm\claude.ps1" }
$codexCmd  = Get-Command codex  -ErrorAction SilentlyContinue

# --- Health guards (fail loudly, not silently) ----------------------------
$authStatus = & $claudeExe auth status 2>&1 | Out-String
if ($authStatus -notmatch '"loggedIn":\s*true') {
    Write-Host "`n[ERROR] Claude Code CLI is not authenticated. Run 'claude auth login', then re-run." -ForegroundColor Red
    exit 1
}
if (-not $codexCmd) {
    Write-Host "`n[ERROR] Codex CLI not found. Install it with: npm i -g @openai/codex" -ForegroundColor Red
    exit 1
}
# Use the .cmd shim, not codex.ps1 (which HANGS forwarding exec args from PowerShell).
$codexExe = Join-Path $env:APPDATA 'npm\codex.cmd'
if (-not (Test-Path $codexExe)) { $codexExe = $codexCmd.Source }

Write-Host "`n=== ORCHESTRATOR v2 - Claude <-> Codex ===" -ForegroundColor Cyan
Write-Host "Goal:    $Task"    -ForegroundColor White
Write-Host "WorkDir: $WorkDir" -ForegroundColor White
Write-Host "Rounds:  $Rounds"  -ForegroundColor White

Set-Location -LiteralPath $WorkDir

# --- Preflight: is Codex genuinely answering? -----------------------------
Write-Host "`nPreflight: probing Codex channel..." -ForegroundColor DarkCyan
$pre = Test-CodexChannel -CodexExe $codexExe -WorkDir $WorkDir -Scratch $scratch
if ($pre.ok) {
    Write-Host "Codex channel: READY" -ForegroundColor Green
} else {
    Write-Host "Codex channel: DEGRADED ($($pre.reason))" -ForegroundColor Yellow
    if ($RequireBothAgents) {
        Write-Host "[ABORT] -RequireBothAgents was set and the Codex probe failed. Nothing run." -ForegroundColor Red
        exit 2
    }
    Write-Host "Continuing as a SINGLE-AGENT run - it will be marked honestly, not faked." -ForegroundColor Yellow
}

# --- Injectable invokers (closures capture the resolved exes) -------------
$runTag = [guid]::NewGuid().ToString('N').Substring(0,8)   # unique per run: no collision between concurrent runs
$claudeInvoker = { param($p) Invoke-ClaudeTurn -ClaudeExe $claudeExe -Prompt $p }
$codexInvoker  = { param($p) Invoke-CodexTurn  -CodexExe  $codexExe  -Prompt $p -WorkDir $WorkDir -OutFile (Join-Path $scratch "codex-out-$runTag.txt") }

# --- Run ------------------------------------------------------------------
$result = Invoke-Orchestration -Task $Task -WorkDir $WorkDir -Rounds $Rounds `
            -ClaudeInvoker $claudeInvoker -CodexInvoker $codexInvoker -CodexPreflight $pre

# Echo the transcript to the console
foreach ($t in $result.turns) {
    $color = if ($t.agent -eq 'claude') { 'Blue' } else { 'Magenta' }
    Write-Host "`n[$($t.agent) - round $($t.round)]" -ForegroundColor $color
    Write-Host $t.reply -ForegroundColor Gray
}

# --- Write the Run Record + index, then commit ----------------------------
$rr = New-RunRecord -Vault $vault -Result $result -Station 'BUILD'
# Never write the raw task into the committed index if the run was PII-flagged (redirect only redacts the record).
$indexResult = $result
if ($rr.pii) { $indexResult = $result.PSObject.Copy(); $indexResult.task = '(redacted - PII run)' }
Add-RunIndexLine -Vault $vault -Result $indexResult -RunId $rr.runId | Out-Null
Start-Sleep -Seconds 2  # let OneDrive settle before git touches the tree
$short = New-Slug $result.task
Invoke-VaultCommit -Vault $vault -Paths @($rr.vaultRelPath, 'log/sessions.md') -Message "run: $short ($($result.mode))"

Write-Host "`n=== DONE - mode=$($result.mode), rounds=$($result.roundsRun), codex=$($result.codexStatus) ===" -ForegroundColor Cyan
Write-Host ("Run Record: My-friends/" + $rr.vaultRelPath + "/  (pii=" + $rr.pii + ")") -ForegroundColor DarkGray
if ($Open) { try { Invoke-Item -LiteralPath $rr.runDir } catch { } }
