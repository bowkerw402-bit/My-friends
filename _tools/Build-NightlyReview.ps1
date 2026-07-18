param(
    [string]$Vault = 'C:\Users\bowke\OneDrive\Documents\GitHub\My-friends',
    [int]$DaysBack = 0,          # 0 = today
    [switch]$NoCommit,
    [switch]$Open
)

# Nightly sweep. Reads the day's Claude Code session threads, has Claude write the day's
# assessment, has Codex pressure test it (substrate diversity), and files the result in the repo
# so problems, solutions and decisions are findable later.

Import-Module (Join-Path $PSScriptRoot 'OrchestratorLib.psm1') -Force -DisableNameChecking
Set-Utf8Console

$day     = (Get-Date).Date.AddDays(-1 * $DaysBack)
$dayEnd  = $day.AddDays(1)
$stamp   = $day.ToString('yyyy-MM-dd')
$scratch = Join-Path $env:TEMP 'nightly'
New-Item -ItemType Directory -Force -Path $scratch | Out-Null

# ---- 1. collect the day's session threads (skip subagent transcripts: noise) --------------
$projRoot = Join-Path $HOME '.claude\projects'
$files = @(Get-ChildItem -LiteralPath $projRoot -Recurse -Filter *.jsonl -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $day -and $_.LastWriteTime -lt $dayEnd -and $_.FullName -notmatch '\\subagents\\' } |
    Sort-Object LastWriteTime -Descending)

Write-Host ("Threads touched on " + $stamp + ": " + $files.Count) -ForegroundColor Cyan
if ($files.Count -eq 0) { Write-Host "Nothing to review."; return }

# ---- 2. extract just the conversation (user asks + assistant replies), bounded ------------
function Get-ThreadDigest {
    param([string]$Path, [int]$KeepLast = 60, [int]$MaxChars = 700)
    $q = New-Object System.Collections.Generic.Queue[string]
    $reader = $null
    $fs = $null
    try {
        # Session logs run to tens of MB. Only the recent tail matters for a day review, so seek.
        $fs = [System.IO.File]::OpenRead($Path)
        $tail = 6MB
        if ($fs.Length -gt $tail) { [void]$fs.Seek($fs.Length - $tail, [System.IO.SeekOrigin]::Begin) }
        $reader = [System.IO.StreamReader]::new($fs, [System.Text.UTF8Encoding]::new($false))
        if ($fs.Position -gt 0) { [void]$reader.ReadLine() }   # discard the partial first line
        while ($null -ne ($line = $reader.ReadLine())) {
            if ($line.Length -lt 20) { continue }
            if ($line -notmatch '"role"\s*:\s*"(user|assistant)"') { continue }   # cheap filter first
            $o = $null; try { $o = $line | ConvertFrom-Json } catch { continue }
            $role = $o.message.role
            if (-not $role) { continue }
            $text = ''
            foreach ($b in @($o.message.content)) {
                if ($b -is [string]) { $text += $b }
                elseif ($b.type -eq 'text' -and $b.text) { $text += [string]$b.text }
            }
            $text = ($text -replace '\s+', ' ').Trim()
            if ($text.Length -lt 15) { continue }
            if ($text.Length -gt $MaxChars) { $text = $text.Substring(0, $MaxChars) + '...' }
            $q.Enqueue(($role.ToUpper() + ': ' + $text))
            while ($q.Count -gt $KeepLast) { [void]$q.Dequeue() }
        }
    } catch { } finally { if ($reader) { $reader.Dispose() } elseif ($fs) { $fs.Dispose() } }
    return @($q)
}

$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append("THREADS FOR ").Append($stamp).Append("`n`n")
$n = 0
foreach ($f in $files) {
    if ($sb.Length -gt 90000) { break }
    $lines = Get-ThreadDigest -Path $f.FullName
    if (@($lines).Count -eq 0) { continue }
    $n++
    [void]$sb.Append("=== thread ").Append($n).Append(" (").Append($f.BaseName.Substring(0,8)).Append(", last touched ").Append($f.LastWriteTime.ToString('HH:mm')).Append(") ===`n")
    foreach ($l in $lines) { [void]$sb.Append($l).Append("`n") }
    [void]$sb.Append("`n")
}
$digestPath = Join-Path $scratch ("digest-" + $stamp + ".txt")
Write-Utf8NoBom $digestPath $sb.ToString()
Write-Host ("Digest: " + [int]($sb.Length/1KB) + " KB from " + $n + " threads")

# ---- 3. Claude writes the day's assessment -----------------------------------------------
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
$claudeExe = if ($claudeCmd) { $claudeCmd.Source } else { "$env:APPDATA\npm\claude.ps1" }

$reviewPrompt = @"
Read the file at $digestPath . It is a condensed record of every work thread from $stamp (user asks and assistant replies, tool noise stripped).

Write the day's assessment as Markdown, using exactly these sections:

## What we worked on
## Problems hit
## Solutions found
## Decisions made
## Still unresolved
## Worth keeping
## Noise (safe to ignore)

Rules: be specific and short, use bullets, name files and commands where they matter. Under 'Worth keeping' put only things genuinely worth referring back to later. Under 'Noise' put dead ends and false starts, so future readers skip them. If a section has nothing, write 'none'. Do not use em dashes, en dashes, or hyphens as punctuation anywhere. Output only the Markdown, no preamble.
"@

Write-Host "Claude is assessing the day..." -ForegroundColor DarkCyan
$c = Invoke-ClaudeTurn -ClaudeExe $claudeExe -Prompt $reviewPrompt
$assessment = if ($c.ok) { $c.text } else { "_Claude assessment failed (exit " + $c.exitCode + ")._" }

# ---- 4. Codex pressure tests it -----------------------------------------------------------
$codexExe = Join-Path $env:APPDATA 'npm\codex.cmd'
$reviewFile = Join-Path $scratch ("assessment-" + $stamp + ".md")
Write-Utf8NoBom $reviewFile $assessment

$codexPrompt = @"
Two files. The raw day record: $digestPath . Claude's assessment of it: $reviewFile .

Pressure test the assessment against the raw record. Answer in Markdown, short and specific:
- What Claude got wrong or overstated (quote the line).
- What Claude missed that matters.
- The single most important unresolved problem going into tomorrow.
Do not restate the assessment. Do not use em dashes, en dashes, or hyphens as punctuation. Output only the Markdown.
"@

Write-Host "Codex is pressure testing it..." -ForegroundColor DarkCyan
$x = Invoke-CodexTurn -CodexExe $codexExe -Prompt $codexPrompt -WorkDir $scratch `
        -OutFile (Join-Path $scratch ("codex-review-" + $stamp + ".txt")) -Effort 'medium' -TimeoutSec 240
$challenge = if ($x.ok) { $x.text } else { "_Codex unavailable (" + $(if($x.timedOut){'timeout'}else{'exit ' + $x.exitCode}) + "). Assessment is single agent._" }

# ---- 5. file it in the repo ----------------------------------------------------------------
$outDir = Join-Path $Vault 'reviews'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$outFile = Join-Path $outDir ($stamp + '.md')

$doc = [System.Text.StringBuilder]::new()
[void]$doc.Append("---`nkind: nightly-review`ndate: ").Append($stamp).Append("`nthreads: ").Append($n).Append("`ntwo_agent: ").Append([bool]$x.ok).Append("`n---`n`n")
[void]$doc.Append("# Day review, ").Append($day.ToString('dddd d MMMM yyyy')).Append("`n`n")
[void]$doc.Append("_Swept ").Append($n).Append(" threads at ").Append((Get-Date).ToString('HH:mm')).Append(". Claude assessed, Codex pressure tested._`n`n")
[void]$doc.Append($assessment).Append("`n`n---`n`n## Codex challenge`n`n").Append($challenge).Append("`n")
Write-Utf8NoBom $outFile $doc.ToString()
Write-Host ("Wrote " + $outFile) -ForegroundColor Green

if (-not $NoCommit) {
    Start-Sleep -Seconds 2
    $r = Invoke-VaultCommit -Vault $Vault -Paths @('reviews') -Message ("nightly review: " + $stamp)
    Write-Host ("committed: ok=" + $r.ok) -ForegroundColor DarkGray
}
if ($Open) { try { Invoke-Item -LiteralPath $outFile } catch { } }
