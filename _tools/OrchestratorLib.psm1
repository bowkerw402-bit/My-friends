# OrchestratorLib.psm1 - v2.0.0
# Shared library for the two-agent orchestrator (Claude Code <-> Codex).
#
# Design rules that matter:
#  - Every file write is UTF-8 *no BOM* via [IO.File]::WriteAllText/AppendAllText.
#    (Add-Content / Out-File -Append in PS 5.1 default to ANSI and write a BOM on
#     every append -> that is the source of the "-" -> U+FFFD corruption and stray BOMs.)
#  - Agent-captured text is only ever concatenated / StringBuilder-appended, never
#    embedded into a NEW expandable "..." at write time -> no $-subexpression surprises.
#  - Codex output is READ from its -o file as UTF-8, not via console capture.
#  - This module keeps its SOURCE ASCII-only; non-ASCII only flows through as DATA.

$script:OrchestratorVersion = '2.0.0'

# --------------------------------------------------------------------------
# Encoding-safe console + IO
# --------------------------------------------------------------------------
function Set-Utf8Console {
    # Make PowerShell decode native-command stdout as UTF-8 (fixes Claude capture)
    # and encode what we send as UTF-8. Safe no-op if the host disallows it.
    try {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        $global:OutputEncoding    = [System.Text.UTF8Encoding]::new($false)
    } catch { }
}

function Write-Utf8NoBom {
    param([Parameter(Mandatory=$true)][string]$Path, [string]$Text = '')
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Add-Utf8NoBom {
    param([Parameter(Mandatory=$true)][string]$Path, [string]$Text = '')
    [System.IO.File]::AppendAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Read-Utf8 {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return '' }
    return [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
}

# --------------------------------------------------------------------------
# Small helpers
# --------------------------------------------------------------------------
function New-Slug {
    param([string]$Text, [int]$MaxLen = 40)
    if ($null -eq $Text) { $Text = '' }
    $s = $Text.ToLowerInvariant()
    $s = [System.Text.RegularExpressions.Regex]::Replace($s, '[^a-z0-9]+', '-')
    $s = $s.Trim('-')
    if ($s.Length -gt $MaxLen) { $s = $s.Substring(0, $MaxLen).Trim('-') }
    if ([string]::IsNullOrWhiteSpace($s)) { $s = 'run' }
    return $s
}

function Build-Convo {
    # Render the running conversation from turn objects, by concatenation (no expansion).
    param($Turns, [int]$MaxChars = 12000)
    if (-not $Turns -or @($Turns).Count -eq 0) { return '(nothing yet - you speak first)' }
    $sb = [System.Text.StringBuilder]::new()
    foreach ($t in $Turns) {
        [void]$sb.Append("`n`n### ").Append($t.agent).Append(" (round ").Append($t.round).Append(")`n").Append($t.reply)
    }
    $convo = $sb.ToString()
    if ($convo.Length -gt $MaxChars) {
        $convo = "...(earlier trimmed)..." + $convo.Substring($convo.Length - $MaxChars)
    }
    return $convo
}

function Build-Prompt {
    # The per-turn instruction. Only OUR controlled variables are interpolated;
    # $Convo carries agent text as a VALUE (PowerShell interpolation is non-recursive,
    # so any $(...) inside agent text is NOT executed).
    param(
        [string]$Name, [string]$Other, [string]$Task, [string]$WorkDir,
        $Turns, [int]$MaxChars = 12000
    )
    $convo = Build-Convo -Turns $Turns -MaxChars $MaxChars
    return @"
You are $Name, one of two AI coding agents working as a team (the other is $Other).
You share ONE goal and ONE working directory: $WorkDir

HOUSE RULES (non-negotiable, and stated here so you never need to go and look them up):
- NEVER use em dashes, en dashes, or a hyphen as punctuation. Use commas, full stops, colons or brackets.
- Write in plain language. No internal shorthand without saying what it means.
- Draft only. Never send, deploy, publish, sign or spend. Prepare it to one click and stop.
- No client personal data (names, emails, phone numbers) in anything written to the shared vault.

GOAL:
$Task

This GOAL is your task to DO NOW, using the files in the working directory. Do NOT ask what the task is,
do NOT merely summarise memory or offer a menu of options - produce the actual work the GOAL asks for.

CONVERSATION SO FAR (most recent last):
$convo

Your turn. Engage $Other directly and substantively - this is a real collaboration, not a status update:
- Do NOT restate your role or open with "understood" / "I'll collaborate" - go straight to substance.
- If $Other has already spoken, quote a short specific phrase of theirs and respond to it: agree WITH A
  REASON, or push back WITH A REASON. Add something they did not.
- Lead with your single most important concrete point in the first line.
End EVERY turn with a line listing what you actually used, like: "TOOLS-USED: Read, Bash (ls), Grep". If you
used nothing, write "TOOLS-USED: none". This is recorded as the run's tool ledger.
If your turn is a REVIEW of $Other's work, also end with a verdict line: "VERDICT: PASS", "VERDICT: PASS-with-locks",
or "VERDICT: FAIL". That line is recorded as the run's review verdict.
Be concrete (aim under ~250 words). Do real work in the directory when it helps. Do NOT use [DONE] on your
opening turn before $Other has replied. Only once $Other has responded AND you both genuinely agree the
GOAL is complete should you end a message with [DONE].
"@
}

# --------------------------------------------------------------------------
# Agent invocation (each returns a structured result object)
# --------------------------------------------------------------------------
function Invoke-ClaudeTurn {
    # stream-json lets us capture Claude's ACTUAL tool invocations (verified ledger), not a self-report.
    param([Parameter(Mandatory=$true)][string]$ClaudeExe, [Parameter(Mandatory=$true)][string]$Prompt)
    $raw  = & $ClaudeExe --print --dangerously-skip-permissions --output-format stream-json --verbose -p $Prompt 2>$null
    $code = $LASTEXITCODE
    $tools = New-Object System.Collections.Generic.List[string]
    $finalText = ''
    $fallback  = [System.Text.StringBuilder]::new()
    foreach ($ln in @($raw)) {
        if ([string]::IsNullOrWhiteSpace($ln)) { continue }
        $obj = $null
        try { $obj = $ln | ConvertFrom-Json } catch { continue }
        if (-not $obj) { continue }
        if ($obj.type -eq 'assistant' -and $obj.message -and $obj.message.content) {
            foreach ($block in @($obj.message.content)) {
                if ($block.type -eq 'tool_use' -and $block.name) {
                    $nm = [string]$block.name
                    if (-not $tools.Contains($nm)) { $tools.Add($nm) }
                } elseif ($block.type -eq 'text' -and $block.text) {
                    [void]$fallback.Append([string]$block.text).Append("`n")
                }
            }
        } elseif ($obj.type -eq 'result' -and $obj.result) {
            $finalText = [string]$obj.result
        }
    }
    if ([string]::IsNullOrWhiteSpace($finalText)) { $finalText = $fallback.ToString() }
    $finalText = $finalText.Trim()
    return [pscustomobject]@{
        text = $finalText; exitCode = $code; timedOut = $false
        tools = @($tools); toolsVerified = $true
        ok = (($code -eq 0) -and ($finalText.Length -gt 0))
    }
}

function Invoke-CodexTurn {
    # Runs Codex under a timeout (Start-Job), reads its -o file as UTF-8, and reports
    # honestly whether it produced output. NEVER fabricates a reply.
    param(
        [Parameter(Mandatory=$true)][string]$CodexExe,
        [Parameter(Mandatory=$true)][string]$Prompt,
        [Parameter(Mandatory=$true)][string]$WorkDir,
        [Parameter(Mandatory=$true)][string]$OutFile,
        [string]$Model = 'gpt-5.6-sol',
        [string]$Effort = 'medium',   # medium so Codex engages properly (the preflight probe stays 'low')
        [int]$TimeoutSec = 240,
        [switch]$NoRetry
    )
    # CRITICAL: cmd.exe (codex.cmd) truncates a command-line argument at the first newline, so a
    # multi-line prompt reached Codex as only its first line - the real cause of shallow replies.
    # Write the full prompt to a UTF-8 sidecar file and pass Codex a short one-line pointer instead.
    $promptFile = [System.IO.Path]::ChangeExtension($OutFile, 'prompt.txt')
    [System.IO.File]::WriteAllText($promptFile, $Prompt, [System.Text.UTF8Encoding]::new($false))
    $argPrompt = "Read the UTF-8 text file at the exact path below and follow its ENTIRE contents as your instructions, responding directly to them. Do not summarise or describe the file - act on it. Output only your response. PATH: $promptFile"

    # one attempt at a given effort and time budget
    $attempt = {
        param($eff, $tmo)
        Remove-Item -LiteralPath $OutFile -ErrorAction SilentlyContinue
        # --ignore-user-config is load-bearing: it skips ~25 plugins + MCP servers (one with a
        # 120s startup) that would otherwise boot on EVERY turn. We re-supply just the model.
        $job = Start-Job -ScriptBlock {
            param($exe, $ap, $wd, $of, $model, $effort)
            & $exe exec --ignore-user-config -c "model=$model" -c "model_reasoning_effort=$effort" `
                --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -C $wd -o $of $ap 2>$null | Out-Null
            return $LASTEXITCODE
        } -ArgumentList $CodexExe, $argPrompt, $WorkDir, $OutFile, $Model, $eff
        $finished = Wait-Job $job -Timeout $tmo
        $timedOut = $false
        $exit     = $null
        if (-not $finished) { $timedOut = $true; Stop-Job $job -ErrorAction SilentlyContinue }
        else { $exit = Receive-Job $job; if ($exit -is [array]) { $exit = $exit[-1] } }
        Remove-Job $job -Force -ErrorAction SilentlyContinue
        $text = ''
        if (Test-Path -LiteralPath $OutFile) { $text = (Read-Utf8 $OutFile).Trim() }
        return [pscustomobject]@{
            text = $text; exitCode = $exit; timedOut = $timedOut; effort = $eff
            ok = ((-not $timedOut) -and ($exit -eq 0) -and ($text.Length -gt 0))
        }
    }

    $r = & $attempt $Effort $TimeoutSec
    # A timeout at normal effort is usually the reasoning budget, not a dead channel. Retry once
    # leaner so the turn degrades to a shorter answer instead of vanishing entirely.
    if ($r.timedOut -and (-not $NoRetry) -and ($Effort -ne 'low')) {
        Write-Host ("  Codex timed out at effort=" + $Effort + ", retrying once at low effort...") -ForegroundColor Yellow
        $r = & $attempt 'low' ([Math]::Max(120, [int]($TimeoutSec / 2)))
        if ($r.ok) { $r | Add-Member -NotePropertyName retried -NotePropertyValue $true -Force }
    }
    return $r
}

function Test-NonEngagement {
    # True when a reply is the agent asking what to do instead of doing it. The honesty check used to
    # measure presence (did text come back) rather than participation (did it engage with the task).
    param([string]$Reply)
    if ([string]::IsNullOrWhiteSpace($Reply)) { return $true }
    $t = $Reply.Trim()
    if ($t.Length -gt 1500) { return $false }      # long answers are substantive by definition
    $patterns = @(
        "what would you like (me )?to",
        "i don'?t see a (specific )?task",
        "what'?s the (task|ask|priority|goal)",
        "just tell me the task",
        "how can i help",
        "let me know what you'?d like",
        "what do you want me to",
        "ready (and waiting|to work).{0,40}\?"
    )
    foreach ($p in $patterns) { if ($t -imatch $p) { return $true } }
    return $false
}

function Test-CodexChannel {
    # Preflight probe: is Codex actually answering? Returns a structured verdict so the
    # run can be honestly marked single-agent (or aborted) instead of silently faking it.
    param(
        [Parameter(Mandatory=$true)][string]$CodexExe,
        [Parameter(Mandatory=$true)][string]$WorkDir,
        [Parameter(Mandatory=$true)][string]$Scratch,
        [string]$Model = 'gpt-5.6-sol',
        [int]$TimeoutSec = 90
    )
    $probeOut = Join-Path $Scratch ('codex-probe-' + [guid]::NewGuid().ToString('N').Substring(0,8) + '.txt')
    $r = Invoke-CodexTurn -CodexExe $CodexExe -Prompt 'Reply with the single word READY and nothing else.' `
            -WorkDir $WorkDir -OutFile $probeOut -Model $Model -Effort 'low' -TimeoutSec $TimeoutSec
    $reason =
        if ($r.timedOut)     { 'timeout' }
        elseif ($r.exitCode -ne 0) { 'exit ' + $r.exitCode }
        elseif ($r.text.Length -eq 0) { 'no-output' }
        elseif ($r.text -notmatch 'READY') { 'unexpected: ' + ($r.text.Substring(0,[Math]::Min(60,$r.text.Length))) }
        else { 'ok' }
    return [pscustomobject]@{
        ok = ($reason -eq 'ok'); reason = $reason; text = $r.text
        exitCode = $r.exitCode; timedOut = $r.timedOut
    }
}

# --------------------------------------------------------------------------
# The orchestration loop (invokers are injectable for testing)
# --------------------------------------------------------------------------
function Invoke-Orchestration {
    param(
        [Parameter(Mandatory=$true)][string]$Task,
        [Parameter(Mandatory=$true)][string]$WorkDir,
        [int]$Rounds = 3,
        [Parameter(Mandatory=$true)][scriptblock]$ClaudeInvoker, # { param($prompt) -> result obj }
        [Parameter(Mandatory=$true)][scriptblock]$CodexInvoker,  # { param($prompt) -> result obj }
        $CodexPreflight = $null
    )
    $turns       = New-Object System.Collections.ArrayList
    $done        = $false
    $codexSpoke  = $false
    $claudeSpoke = $false
    $degraded    = $false
    $codexStatus = 'ok'
    $doneReason  = 'rounds exhausted'
    $roundsRun   = 0
    $startedAt   = (Get-Date).ToString('o')

    if ($CodexPreflight -and -not $CodexPreflight.ok) {
        $degraded = $true
        $codexStatus = 'probe-failed: ' + $CodexPreflight.reason
    }

    for ($r = 1; $r -le $Rounds -and -not $done; $r++) {
        $roundsRun = $r

        # --- Claude ---
        $cPrompt = Build-Prompt -Name 'Claude Code' -Other 'Codex' -Task $Task -WorkDir $WorkDir -Turns $turns
        $t0 = (Get-Date).ToString('o')
        $c  = & $ClaudeInvoker $cPrompt
        $t1 = (Get-Date).ToString('o')
        $cEngaged = ($c.ok) -and (-not (Test-NonEngagement $c.text))
        $cStatus = if (-not $c.ok) { 'error' } elseif (-not $cEngaged) { 'no-engagement' } else { 'ok' }
        $cTools  = @($c.tools | Where-Object { $_ })
        # only a turn that actually engaged counts as taking part
        if ($cEngaged) { $claudeSpoke = $true } else { $degraded = $true }
        [void]$turns.Add([pscustomobject]@{
            agent = 'claude'; round = $r; startedAt = $t0; endedAt = $t1
            promptSent = $cPrompt; reply = $c.text
            status = $cStatus; exitCode = $c.exitCode
            tools = $cTools; toolsVerified = $true      # Claude tools are captured from real invocations
        })
        # Claude may only end the exchange AFTER Codex has genuinely replied at least once.
        if ($codexSpoke -and ($c.text -match '\[DONE\]')) {
            $done = $true; $doneReason = '[DONE] by Claude (after Codex replied)'; break
        }

        # --- Codex ---
        $xPrompt = Build-Prompt -Name 'Codex' -Other 'Claude Code' -Task $Task -WorkDir $WorkDir -Turns $turns
        $t2 = (Get-Date).ToString('o')
        $x  = & $CodexInvoker $xPrompt
        $t3 = (Get-Date).ToString('o')
        $xEngaged = ($x.ok) -and (-not (Test-NonEngagement $x.text))
        $xStatus = if (-not $x.ok) { if ($x.timedOut) { 'timeout' } else { 'no-output' } }
                   elseif (-not $xEngaged) { 'no-engagement' } else { 'ok' }
        if (-not $xEngaged) { $degraded = $true; $codexStatus = $xStatus }
        $xReply = if ($x.ok) { $x.text } else { "(Codex NO OUTPUT - status=$xStatus, exit=$($x.exitCode)) - reply not fabricated" }
        $xTools = @(Get-ToolsFromText $xReply)
        [void]$turns.Add([pscustomobject]@{
            agent = 'codex'; round = $r; startedAt = $t2; endedAt = $t3
            promptSent = $xPrompt; reply = $xReply
            status = $xStatus; exitCode = $x.exitCode
            tools = $xTools; toolsVerified = $false     # Codex tools are self-declared (not yet traced)
        })
        if ($xEngaged) { $codexSpoke = $true }
        if ($xEngaged -and ($x.text -match '\[DONE\]')) { $done = $true; $doneReason = '[DONE] by Codex' }
    }

    $bothSpoke = $claudeSpoke -and $codexSpoke
    $mode =
        if ($bothSpoke -and -not $degraded) { 'two-agent' }
        elseif ($bothSpoke)                 { 'two-agent-degraded' }
        else                                { 'single-agent' }

    return [pscustomobject]@{
        task         = $Task
        workDir      = $WorkDir
        roundsPlanned= $Rounds
        roundsRun    = $roundsRun
        turns        = @($turns)
        twoAgent     = [bool]$bothSpoke
        degraded     = [bool]$degraded
        mode         = $mode
        # a run that merely ran out of rounds did NOT finish: say so rather than implying success
        outcome      = if ($done) { 'complete' } else { 'incomplete' }
        codexStatus  = $codexStatus
        doneReason   = $doneReason
        startedAt    = $startedAt
        endedAt      = (Get-Date).ToString('o')
        orchestratorVersion = $script:OrchestratorVersion
    }
}

# --------------------------------------------------------------------------
# Back-compat chronological index (encoding-safe; one line per reply, no triplication)
# --------------------------------------------------------------------------
function Add-SessionsIndex {
    param([Parameter(Mandatory=$true)][string]$Vault, [Parameter(Mandatory=$true)]$Result)
    $logFile = Join-Path $Vault 'log\sessions.md'
    $dir = Split-Path $logFile
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if (-not (Test-Path -LiteralPath $logFile)) { Write-Utf8NoBom $logFile "# Session Log`n" }

    $date = (Get-Date).ToString('yyyy-MM-dd HH:mm')
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.Append("`n## ").Append($date).Append(" | ").Append($Result.workDir).Append("`n")
    [void]$sb.Append("**Goal:** ").Append($Result.task).Append("`n")
    [void]$sb.Append("**Mode:** ").Append($Result.mode)
    [void]$sb.Append(" | rounds: ").Append($Result.roundsRun)
    [void]$sb.Append(" | codex: ").Append($Result.codexStatus)
    [void]$sb.Append(" | done: ").Append($Result.doneReason).Append("`n")
    [void]$sb.Append("**Conversation:**`n")
    foreach ($t in $Result.turns) {
        [void]$sb.Append("`n### ").Append($t.agent).Append(" (round ").Append($t.round).Append(") ").Append($t.endedAt).Append("`n")
        [void]$sb.Append($t.reply).Append("`n")
    }
    [void]$sb.Append("`n---`n")
    Add-Utf8NoBom $logFile $sb.ToString()
    return $logFile
}

# --------------------------------------------------------------------------
# Git commit/push, hardened a little for OneDrive
# --------------------------------------------------------------------------
function Invoke-VaultCommit {
    param(
        [Parameter(Mandatory=$true)][string]$Vault,
        [Parameter(Mandatory=$true)][string[]]$Paths,
        [Parameter(Mandatory=$true)][string]$Message
    )
    # One global mutex so a manual run and the scheduled report can't git-race on the vault.
    $mtx = New-Object System.Threading.Mutex($false, 'Global\MyFriendsVaultCommit')
    $held = $false
    try {
        try { $held = $mtx.WaitOne([TimeSpan]::FromSeconds(120)) } catch { $held = $false }
        if (-not $held) {
            Write-Host "[WARN] vault lock not acquired after 120s. Another run or routine may be committing. Proceeding, but a git conflict is possible." -ForegroundColor Yellow
        }
        Push-Location $Vault
        try {
            & git.exe pull --rebase --autostash -q 2>$null | Out-Null
            foreach ($p in $Paths) { & git.exe add -- $p 2>$null | Out-Null }
            & git.exe commit -q -m $Message 2>$null | Out-Null
            & git.exe push -q 2>$null | Out-Null
            $pushExit = $LASTEXITCODE
            if ($pushExit -ne 0) {           # rejected? rebase on remote and retry once
                & git.exe pull --rebase --autostash -q 2>$null | Out-Null
                & git.exe push -q 2>$null | Out-Null
                $pushExit = $LASTEXITCODE
            }
            if ($pushExit -ne 0) {
                Write-Host "[WARN] vault push failed (exit $pushExit) - commit is local only. Check auth / OneDrive lock / network." -ForegroundColor Yellow
            }
            return [pscustomobject]@{ ok = ($pushExit -eq 0); pushExit = $pushExit }
        } finally { Pop-Location }
    } finally {
        if ($held) { try { $mtx.ReleaseMutex() } catch { } }
        $mtx.Dispose()
    }
}

# --------------------------------------------------------------------------
# Run Records (Mission Control) - the committed, human-readable proof of a run
# --------------------------------------------------------------------------
function Test-PiiPath {
    # True when a work dir sits under a known PII location -> its full record must
    # stay in the business folder, never the shared (GitHub+OneDrive) vault.
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    $p = ($Path.ToLowerInvariant()) -replace '/', '\'
    return (($p -match '\\clients(\\|$)') -or ($p -match '\\demand-first\\lists') -or ($p -match 'prospect'))
}

function Test-PiiContent {
    # Conservative content scan for obvious personal data (emails, phone numbers, long account/card
    # numbers). Catches PII pasted into a task string or reply that a path check would miss. Returns
    # the list of hit types (empty = clean). Deliberately narrow to avoid false alarms.
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return @() }
    $hits = New-Object System.Collections.Generic.List[string]
    if ([regex]::IsMatch($Text, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')) { [void]$hits.Add('email') }
    if ([regex]::IsMatch($Text, '(?:\+?61|\b0)[\s\-]?\d(?:[\s\-]?\d){7,9}\b'))       { [void]$hits.Add('phone') }
    if ([regex]::IsMatch($Text, '\b\d(?:[\s\-]?\d){10,18}\b'))                        { [void]$hits.Add('long-number') }
    return @($hits | Select-Object -Unique)
}

function Get-ToolsFromText {
    # Parse a self-declared 'TOOLS-USED: ...' line out of one reply. Whole line = one entry
    # (splitting on commas mangled lists like "Read (a, b), Bash (ls, find)").
    param([string]$Text)
    $used = New-Object System.Collections.Generic.List[string]
    if ([string]::IsNullOrWhiteSpace($Text)) { return @() }
    foreach ($m in [regex]::Matches($Text, '(?im)^\s*tools?[-_ ]?used\s*:\s*(.+)$')) {
        $tt = $m.Groups[1].Value.Trim()
        if ($tt -and (-not $used.Contains($tt))) { $used.Add($tt) }
    }
    return @($used)
}

function Get-ToolsFromTurns {
    param($Turns)
    $used = New-Object System.Collections.Generic.List[string]
    foreach ($t in $Turns) {
        foreach ($x in (Get-ToolsFromText $t.reply)) { if (-not $used.Contains($x)) { $used.Add($x) } }
    }
    return @($used)
}

function Get-VerdictFromTurns {
    # The REVIEW lock. An agent reviewing the other's work ends with a line:
    #   VERDICT: PASS   |   VERDICT: PASS-with-locks   |   VERDICT: FAIL
    # Without this the lock was documentation only: review_verdict was always empty.
    param($Turns)
    $verdict = ''
    foreach ($t in $Turns) {
        foreach ($m in [regex]::Matches([string]$t.reply, '(?im)^\s*verdict\s*:\s*(PASS[-\s]with[-\s]locks|PASS|FAIL)\b')) {
            $verdict = ($m.Groups[1].Value -replace '\s', '-').ToUpper()
        }
    }
    return $verdict
}

function ConvertTo-TranscriptMarkdown {
    param($Result)
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.Append("# Transcript`n`n")
    [void]$sb.Append("**Goal:** ").Append($Result.task).Append("`n`n")
    [void]$sb.Append("**Mode:** ").Append($Result.mode)
    [void]$sb.Append(" | rounds ").Append($Result.roundsRun)
    [void]$sb.Append(" | codex ").Append($Result.codexStatus)
    [void]$sb.Append(" | done: ").Append($Result.doneReason).Append("`n`n")
    [void]$sb.Append("Each agent replies in free text; the orchestrator wraps each reply in a standard hand-off template. ")
    [void]$sb.Append("The exact prompt each turn received is included (folded) for full auditability.`n`n---`n")
    foreach ($t in $Result.turns) {
        [void]$sb.Append("`n## ").Append($t.agent).Append(" - round ").Append($t.round)
        [void]$sb.Append("  (").Append($t.endedAt).Append(", status: ").Append($t.status).Append(")`n`n")
        [void]$sb.Append($t.reply).Append("`n`n")
        [void]$sb.Append("<details><summary>exact prompt sent to ").Append($t.agent).Append("</summary>`n`n")
        [void]$sb.Append("~~~text`n").Append($t.promptSent).Append("`n~~~`n</details>`n")
    }
    return $sb.ToString()
}

function New-RunRecord {
    # Writes runs/<YYYY-MM-DD--HHmm--slug>/ with the 6 station files + manifest.json.
    # PII runs are redirected to <work_dir>/.runs and only a stub lands in the vault.
    param(
        [Parameter(Mandatory=$true)][string]$Vault,
        [Parameter(Mandatory=$true)]$Result,
        [string]$Station = 'BUILD',
        [string]$Venture = '',
        [string]$Brief = '',
        [string]$Plan = '',
        [string]$Output = '',
        [string]$Review = '',
        [string]$ReviewVerdict = '',
        [string[]]$ToolsDeclared = @(),
        [string[]]$LedgerTouched = @()
    )
    $stamp = (Get-Date).ToString('yyyy-MM-dd--HHmmss')   # seconds: avoid same-minute run-id collisions
    $slug  = New-Slug $Result.task
    $runId = "$stamp--$slug"
    # PII gate: path signal OR content signal (scan task + all replies). Redirect on either.
    $piiPath = Test-PiiPath $Result.workDir
    $scanText = [string]$Result.task
    foreach ($tt in $Result.turns) { $scanText = $scanText + "`n" + [string]$tt.reply }
    $piiContent = Test-PiiContent $scanText
    $pii = $piiPath -or (@($piiContent).Count -gt 0)
    $piiReason = if ($piiPath -and @($piiContent).Count) { 'path+content(' + ($piiContent -join ',') + ')' }
                 elseif ($piiPath)                       { 'path' }
                 elseif (@($piiContent).Count)           { 'content(' + ($piiContent -join ',') + ')' }
                 else                                    { 'none' }

    if ($pii) { $recordRoot = Join-Path $Result.workDir '.runs' }
    else      { $recordRoot = Join-Path $Vault 'runs' }
    $runDir = Join-Path $recordRoot $runId
    New-Item -ItemType Directory -Force -Path $runDir | Out-Null

    $agents = @()
    foreach ($grp in ($Result.turns | Group-Object agent)) {
        $agents += [pscustomobject]@{
            name     = $grp.Name
            turns    = $grp.Count
            statuses = @($grp.Group | ForEach-Object { $_.status } | Select-Object -Unique)
        }
    }
    # Tool ledger: verified = real invocations captured from Claude; declared = self-reported (Codex).
    $verifiedTools = New-Object System.Collections.Generic.List[string]
    $declaredTools = New-Object System.Collections.Generic.List[string]
    foreach ($t in $Result.turns) {
        foreach ($tool in @($t.tools)) {
            if (-not $tool) { continue }
            if ($t.toolsVerified) { if (-not $verifiedTools.Contains($tool)) { $verifiedTools.Add($tool) } }
            else                  { if (-not $declaredTools.Contains($tool)) { $declaredTools.Add($tool) } }
        }
    }

    # REVIEW lock: pick up a VERDICT line if either agent issued one.
    if (-not $ReviewVerdict) { $ReviewVerdict = Get-VerdictFromTurns $Result.turns }

    $toolsMd = [System.Text.StringBuilder]::new()
    [void]$toolsMd.Append("# Tool ledger`n`n")
    $vStr = if (@($verifiedTools).Count) { @($verifiedTools) -join ', ' } else { '(none captured)' }
    $dStr = if (@($declaredTools).Count) { @($declaredTools) -join ', ' } else { '(none declared)' }
    [void]$toolsMd.Append("**Verified - actual invocations (Claude):** ").Append($vStr).Append("`n`n")
    [void]$toolsMd.Append("**Declared - self-reported (Codex TOOLS-USED lines):** ").Append($dStr).Append("`n`n")
    if ($ToolsDeclared -and @($ToolsDeclared).Count) {
        [void]$toolsMd.Append("**Brief tool manifest (planned):** ").Append((@($ToolsDeclared) -join ', ')).Append("`n`n")
    }
    [void]$toolsMd.Append("_Claude's tools are captured from real tool_use events (stream-json) = verified. Codex's are self-declared and not yet invocation-traced._`n")

    # Lean-by-default: always a single-glance SUMMARY + transcript + tools + manifest;
    # the Line station files are written ONLY when real content is supplied (no stub "apologies").
    $sum = [System.Text.StringBuilder]::new()
    [void]$sum.Append("# ").Append($runId).Append("`n`n")
    $taskShown = if ($pii) { '(redacted - PII run)' } else { $Result.task }
    [void]$sum.Append("**Task:** ").Append($taskShown).Append("`n`n")
    [void]$sum.Append("- **Mode:** ").Append($Result.mode).Append("  (two-agent=").Append([bool]$Result.twoAgent).Append(", degraded=").Append([bool]$Result.degraded).Append(")`n")
    [void]$sum.Append("- **Rounds:** ").Append($Result.roundsRun).Append("  -  **Done:** ").Append($Result.doneReason).Append("`n")
    [void]$sum.Append("- **Codex:** ").Append($Result.codexStatus).Append("`n")
    if ($ReviewVerdict) { [void]$sum.Append("- **Review verdict:** ").Append($ReviewVerdict).Append("`n") }
    $vSum = if (@($verifiedTools).Count) { @($verifiedTools) -join ', ' } else { '(none captured)' }
    [void]$sum.Append("- **Tools (verified, Claude):** ").Append($vSum).Append("`n")
    [void]$sum.Append("- **PII:** ").Append($piiReason).Append("`n`n")
    [void]$sum.Append("See transcript.md for the full exchange, tools.md for the ledger.`n")

    Write-Utf8NoBom (Join-Path $runDir '00-SUMMARY.md')  $sum.ToString()
    Write-Utf8NoBom (Join-Path $runDir 'transcript.md')  (ConvertTo-TranscriptMarkdown $Result)
    Write-Utf8NoBom (Join-Path $runDir 'tools.md')       $toolsMd.ToString()
    if ($Brief)  { Write-Utf8NoBom (Join-Path $runDir 'brief.md')  $Brief }
    if ($Plan)   { Write-Utf8NoBom (Join-Path $runDir 'plan.md')   $Plan }
    if ($Output) { Write-Utf8NoBom (Join-Path $runDir 'output.md') $Output }
    if ($Review) { Write-Utf8NoBom (Join-Path $runDir 'review.md') $Review }

    $manifest = [ordered]@{
        schema         = 'runrecord/v1'
        run_id         = $runId
        slug           = $slug
        task           = $Result.task
        station        = $Station
        venture        = $Venture
        work_dir       = $Result.workDir
        started_at     = $Result.startedAt
        ended_at       = $Result.endedAt
        mode           = $Result.mode
        outcome        = $Result.outcome
        two_agent      = [bool]$Result.twoAgent
        degraded       = [bool]$Result.degraded
        rounds_planned = $Result.roundsPlanned
        rounds_run     = $Result.roundsRun
        done_reason    = $Result.doneReason
        agents         = $agents
        codex_status   = $Result.codexStatus
        tools_manifest = @($ToolsDeclared)   # planned, from the Brief
        tools_verified = @($verifiedTools)   # Claude, real invocations
        tools_declared = @($declaredTools)   # Codex, self-reported
        outputs        = @()
        review_verdict = $ReviewVerdict
        ledger_touched = @($LedgerTouched)
        pii_present    = [bool]$pii
        pii_reason     = $piiReason
        encoding       = 'utf-8'
        orchestrator_version = $Result.orchestratorVersion
    }
    Write-Utf8NoBom (Join-Path $runDir 'manifest.json') ($manifest | ConvertTo-Json -Depth 8)

    # Vault always gets a runs/<runId>/ entry (stub if PII) so the digest can see it.
    $vaultRunDir = Join-Path (Join-Path $Vault 'runs') $runId
    if ($pii) {
        New-Item -ItemType Directory -Force -Path $vaultRunDir | Out-Null
        $stub = [ordered]@{
            schema='runrecord/v1-stub'; run_id=$runId; task='(redacted - PII run)';
            station=$Station; venture=$Venture; mode=$Result.mode;
            two_agent=[bool]$Result.twoAgent; degraded=[bool]$Result.degraded;
            pii_present=$true; record_location='business folder (.runs) - not synced';
            ended_at=$Result.endedAt; orchestrator_version=$Result.orchestratorVersion
        }
        Write-Utf8NoBom (Join-Path $vaultRunDir 'manifest.json') ($stub | ConvertTo-Json -Depth 6)
        Write-Utf8NoBom (Join-Path $vaultRunDir '00-SUMMARY.md') "# Redacted run`n`nThis run contained PII, so its full record is kept in the business folder and NOT synced to the shared vault. Only this stub is committed.`n"
    }

    return [pscustomobject]@{
        runId = $runId; runDir = $runDir; pii = [bool]$pii
        vaultRelPath = "runs/$runId"; manifest = $manifest
    }
}

function Add-RunIndexLine {
    # Compact one-line-per-run chronological index in log/sessions.md.
    param([Parameter(Mandatory=$true)][string]$Vault, [Parameter(Mandatory=$true)]$Result, [Parameter(Mandatory=$true)][string]$RunId)
    $logFile = Join-Path $Vault 'log\sessions.md'
    $dir = Split-Path $logFile
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if (-not (Test-Path -LiteralPath $logFile)) { Write-Utf8NoBom $logFile "# Session Index`n`nOne line per orchestrated run. Full detail in runs/.`n" }
    $date = (Get-Date).ToString('yyyy-MM-dd HH:mm')
    $sb = [System.Text.StringBuilder]::new()
    $taskShort = ($Result.task -replace '\s+', ' ')
    if ($taskShort.Length -gt 100) { $taskShort = $taskShort.Substring(0, 100).Trim() + '...' }
    [void]$sb.Append("- ").Append($date).Append(" | ").Append($Result.mode)
    [void]$sb.Append(" | rounds ").Append($Result.roundsRun)
    [void]$sb.Append(" | ").Append($taskShort)
    [void]$sb.Append(" -> runs/").Append($RunId).Append("/`n")
    Add-Utf8NoBom $logFile $sb.ToString()
    return $logFile
}

Export-ModuleMember -Function `
    Set-Utf8Console, Write-Utf8NoBom, Add-Utf8NoBom, Read-Utf8, New-Slug, `
    Build-Convo, Build-Prompt, Invoke-ClaudeTurn, Invoke-CodexTurn, Test-CodexChannel, `
    Invoke-Orchestration, Add-SessionsIndex, Invoke-VaultCommit, `
    Test-PiiPath, Test-PiiContent, Test-NonEngagement, Get-ToolsFromText, Get-ToolsFromTurns, `
    Get-VerdictFromTurns, ConvertTo-TranscriptMarkdown, New-RunRecord, Add-RunIndexLine
