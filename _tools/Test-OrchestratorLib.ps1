# Test-OrchestratorLib.ps1 - unit tests for the orchestrator library.
# Proves the P0 fixes with NO real agents in the loop (mock invokers).
# Run:  powershell -NoProfile -ExecutionPolicy Bypass -File Test-OrchestratorLib.ps1

Import-Module (Join-Path $PSScriptRoot 'OrchestratorLib.psm1') -Force -DisableNameChecking
Set-Utf8Console

$fails = New-Object System.Collections.ArrayList
function Assert($name, [bool]$cond) {
    if ($cond) { Write-Host ("  PASS  " + $name) -ForegroundColor Green }
    else       { Write-Host ("  FAIL  " + $name) -ForegroundColor Red; [void]$fails.Add($name) }
}

# Non-ASCII built from code points (never as a source literal, so the .ps1 encoding
# can't taint the test). $-amounts and $(...) kept literal via single quotes.
$EM   = [char]0x2014   # em dash
$ARR  = [char]0x2192   # right arrow
$FFFD = [char]0xFFFD   # replacement char (the corruption signature)
$tricky = 'amount $3,250 ' + $EM + ' calc $(2+2) and ${x} ' + $ARR + ' done'

$tmp = Join-Path $env:TEMP ('orch-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

Write-Host "`n[1] Encoding round-trip (Write/Read-Utf8, no BOM, no corruption)" -ForegroundColor Cyan
$f = Join-Path $tmp 'enc.txt'
Write-Utf8NoBom $f $tricky
$back  = Read-Utf8 $f
$bytes = [System.IO.File]::ReadAllBytes($f)
$hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
Assert 'round-trips identically'            ($back -eq $tricky)
Assert 'no BOM written'                     (-not $hasBom)
Assert 'no U+FFFD corruption'               ($back.IndexOf($FFFD) -lt 0)
Assert 'em dash preserved'                  ($back.IndexOf($EM) -ge 0)
Assert 'dollar amount preserved ($3,250)'   ($back.Contains('$3,250'))
Assert 'subexpression left literal ($(2+2))' ($back.Contains('$(2+2)'))

Write-Host "`n[2] New-Slug" -ForegroundColor Cyan
$slug = New-Slug 'Build the $3,250 Report -- Batch #3!!'
Assert 'slug is kebab ascii'   ($slug -match '^[a-z0-9-]+$')
Assert 'slug has no leading/trailing dash' ($slug -notmatch '(^-|-$)')
Assert 'empty task -> run'      ((New-Slug '') -eq 'run')

Write-Host "`n[3] Orchestration - healthy Codex => two-agent, content intact" -ForegroundColor Cyan
$script:cCalls = 0
$mockClaudeOk = {
    param($p)
    $script:cCalls++
    $body = 'plan: budget $3,250 ' + [char]0x2014 + ' calc $(2+2).'
    if ($script:cCalls -ge 2) { $body = $body + ' Agreed. [DONE]' }
    [pscustomobject]@{ text = $body; exitCode = 0; timedOut = $false; ok = $true }
}
$mockCodexOk = {
    param($p)
    [pscustomobject]@{ text = ('ack ' + [char]0x2014 + ' splitting the work.'); exitCode = 0; timedOut = $false; ok = $true }
}
$r1 = Invoke-Orchestration -Task 'ZZGOALZZ ship it' -WorkDir $tmp -Rounds 3 -ClaudeInvoker $mockClaudeOk -CodexInvoker $mockCodexOk
Assert 'mode is two-agent'          ($r1.mode -eq 'two-agent')
Assert 'twoAgent flag true'         ($r1.twoAgent -eq $true)
Assert 'not degraded'               ($r1.degraded -eq $false)
Assert 'finished via [DONE]'        ($r1.doneReason -like '*DONE*')
Assert 'has claude + codex turns'   ((@($r1.turns | Where-Object { $_.agent -eq 'codex' }).Count -ge 1) -and (@($r1.turns | Where-Object { $_.agent -eq 'claude' }).Count -ge 1))
$anyClaude = @($r1.turns | Where-Object { $_.agent -eq 'claude' })[0]
Assert 'claude reply keeps $3,250'  ($anyClaude.reply.Contains('$3,250'))
Assert 'claude reply keeps $(2+2)'  ($anyClaude.reply.Contains('$(2+2)'))

Write-Host "`n[4] Orchestration - Codex silent => single-agent, NOT faked" -ForegroundColor Cyan
$script:cCalls = 0
$mockCodexFail = {
    param($p)
    [pscustomobject]@{ text = ''; exitCode = 1; timedOut = $false; ok = $false }
}
$r2 = Invoke-Orchestration -Task 'YYGOALYY' -WorkDir $tmp -Rounds 2 -ClaudeInvoker $mockClaudeOk -CodexInvoker $mockCodexFail
$codexTurns = @($r2.turns | Where-Object { $_.agent -eq 'codex' })
Assert 'mode is single-agent'       ($r2.mode -eq 'single-agent')
Assert 'degraded flag true'         ($r2.degraded -eq $true)
Assert 'twoAgent flag false'        ($r2.twoAgent -eq $false)
Assert 'codex turn marked NO OUTPUT'($codexTurns.Count -ge 1 -and $codexTurns[0].reply -like '*NO OUTPUT*')
Assert 'codex reply NOT fabricated' ($codexTurns[0].reply -notlike '*ack*')
Assert 'claude cannot self-DONE without codex' ($r2.doneReason -notlike '*DONE*')  # never reached DONE

Write-Host "`n[5] Add-SessionsIndex - encoding intact, task once (no triplication)" -ForegroundColor Cyan
$logFile = Add-SessionsIndex -Vault $tmp -Result $r1
$log = Read-Utf8 $logFile
$logBytes = [System.IO.File]::ReadAllBytes($logFile)
# BOM only ever allowed at position 0 (single file header), never mid-file appends:
$midBom = $false
for ($i = 3; $i -lt $logBytes.Length - 2; $i++) {
    if ($logBytes[$i] -eq 0xEF -and $logBytes[$i+1] -eq 0xBB -and $logBytes[$i+2] -eq 0xBF) { $midBom = $true; break }
}
$goalCount = ([regex]::Matches($log, 'ZZGOALZZ')).Count
Assert 'log keeps em dash'          ($log.IndexOf($EM) -ge 0)
Assert 'log keeps $3,250'           ($log.Contains('$3,250'))
Assert 'log has no U+FFFD'          ($log.IndexOf($FFFD) -lt 0)
Assert 'no BOM mid-file'            (-not $midBom)
Assert 'goal appears exactly once'  ($goalCount -eq 1)

Write-Host "`n[6] New-RunRecord - non-PII => full record in vault/runs, manifest valid" -ForegroundColor Cyan
$vaultA = Join-Path $tmp 'vaultA'
New-Item -ItemType Directory -Force -Path $vaultA | Out-Null
$rrA = New-RunRecord -Vault $vaultA -Result $r1 -Station 'BUILD' -Venture 'test-venture'
$files = @('00-SUMMARY.md','transcript.md','tools.md','manifest.json')
$allFiles = $true
foreach ($fn in $files) { if (-not (Test-Path -LiteralPath (Join-Path $rrA.runDir $fn))) { $allFiles = $false } }
Assert 'not flagged PII'            ($rrA.pii -eq $false)
Assert 'runDir under vault/runs'    ($rrA.runDir -like (Join-Path $vaultA 'runs*'))
Assert 'lean record files present'  $allFiles
Assert 'no stub brief when none supplied' (-not (Test-Path -LiteralPath (Join-Path $rrA.runDir 'brief.md')))
$mfRaw = Read-Utf8 (Join-Path $rrA.runDir 'manifest.json')
$mf = $null; try { $mf = $mfRaw | ConvertFrom-Json } catch { }
Assert 'manifest.json parses'       ($null -ne $mf)
Assert 'manifest schema v1'         ($mf.schema -eq 'runrecord/v1')
Assert 'manifest mode two-agent'    ($mf.mode -eq 'two-agent')
Assert 'manifest two_agent true'    ($mf.two_agent -eq $true)
$tr = Read-Utf8 (Join-Path $rrA.runDir 'transcript.md')
Assert 'transcript keeps $3,250'    ($tr.Contains('$3,250'))
Assert 'transcript keeps em dash'   ($tr.IndexOf($EM) -ge 0)
Assert 'transcript no U+FFFD'       ($tr.IndexOf($FFFD) -lt 0)

Write-Host "`n[7] New-RunRecord - PII path => full record in business folder, only stub in vault" -ForegroundColor Cyan
$vaultB = Join-Path $tmp 'vaultB'
$piiWork = Join-Path $tmp 'clients'
New-Item -ItemType Directory -Force -Path $vaultB  | Out-Null
New-Item -ItemType Directory -Force -Path $piiWork | Out-Null
$piiResult = [pscustomobject]@{
    task='pii run'; workDir=$piiWork; roundsPlanned=1; roundsRun=1; turns=$r1.turns
    twoAgent=$true; degraded=$false; mode='two-agent'; codexStatus='ok'; doneReason='test'
    startedAt=$r1.startedAt; endedAt=$r1.endedAt; orchestratorVersion='2.0.0'
}
$rrB = New-RunRecord -Vault $vaultB -Result $piiResult -Station 'BUILD'
Assert 'flagged PII'                     ($rrB.pii -eq $true)
Assert 'full record in business .runs'   ($rrB.runDir -like (Join-Path $piiWork '.runs*'))
Assert 'full transcript NOT in vault'    (-not (Test-Path -LiteralPath (Join-Path (Join-Path $vaultB 'runs') (Split-Path $rrB.runDir -Leaf) | Join-Path -ChildPath 'transcript.md')))
$stubMf = $null
try { $stubMf = (Read-Utf8 (Join-Path (Join-Path $vaultB 'runs') ((Split-Path $rrB.runDir -Leaf)) | Join-Path -ChildPath 'manifest.json')) | ConvertFrom-Json } catch { }
Assert 'vault has stub manifest'         ($null -ne $stubMf -and $stubMf.schema -eq 'runrecord/v1-stub')
Assert 'stub marks pii_present'          ($stubMf.pii_present -eq $true)

Write-Host "`n[8] Test-PiiContent - content PII detector" -ForegroundColor Cyan
Assert 'detects email'         (@(Test-PiiContent 'please contact john.doe@example.com') -contains 'email')
Assert 'detects phone'         (@(Test-PiiContent 'call me on 0412 345 678').Count -ge 1)
Assert 'clean text is clean'   (@(Test-PiiContent 'ship the $3,250 report by Friday').Count -eq 0)
# a non-PII path but PII in the task string must still flag + redirect
$piiC = [pscustomobject]@{ task='email bob@acme.com the draft'; workDir=$tmp; roundsPlanned=1; roundsRun=1; turns=$r1.turns; twoAgent=$true; degraded=$false; mode='two-agent'; codexStatus='ok'; doneReason='t'; startedAt=$r1.startedAt; endedAt=$r1.endedAt; orchestratorVersion='2.0.0' }
$rrC = New-RunRecord -Vault (Join-Path $tmp 'vaultC') -Result $piiC -Station 'BUILD'
Assert 'content-PII run flagged pii'     ($rrC.pii -eq $true)

Write-Host "`n[9] Non-engagement: presence is not participation" -ForegroundColor Cyan
Assert 'flags "what would you like me to do"'  (Test-NonEngagement "I'm set up and ready. What would you like me to do?")
Assert 'flags "I do not see a specific task"'  (Test-NonEngagement "I don't see a specific task in your message yet.")
Assert 'substantive reply counts as engaged'   (-not (Test-NonEngagement ('Here is the concrete plan and the reasoning behind it. ' * 20)))
$mockClaudeIdle = { param($p) [pscustomobject]@{ text='I am set up and ready in the working directory. What would you like me to work on?'; exitCode=0; timedOut=$false; ok=$true } }
$r3 = Invoke-Orchestration -Task 'XXGOALXX' -WorkDir $tmp -Rounds 2 -ClaudeInvoker $mockClaudeIdle -CodexInvoker $mockCodexOk
Assert 'idle Claude is NOT labelled two-agent' ($r3.mode -ne 'two-agent')
Assert 'idle Claude marks the run degraded'    ($r3.degraded -eq $true)

Write-Host "`n[10] REVIEW lock: verdict is parsed, not decorative" -ForegroundColor Cyan
$vt1 = @([pscustomobject]@{ reply = ("Checked against the brief." + [Environment]::NewLine + "VERDICT: PASS-with-locks") })
$vt2 = @([pscustomobject]@{ reply = 'Solid work, no verdict line here.' })
Assert 'parses PASS-with-locks'  ((Get-VerdictFromTurns $vt1) -eq 'PASS-WITH-LOCKS')
Assert 'no verdict gives empty'  ((Get-VerdictFromTurns $vt2) -eq '')
$rrV = New-RunRecord -Vault (Join-Path $tmp 'vaultV') -Result ([pscustomobject]@{
    task='verdict run'; workDir=$tmp; roundsPlanned=1; roundsRun=1; twoAgent=$true; degraded=$false
    mode='two-agent'; codexStatus='ok'; doneReason='t'; startedAt=(Get-Date).ToString('o'); endedAt=(Get-Date).ToString('o')
    orchestratorVersion='2.0.0'; turns=$vt1 })
$mfV = (Read-Utf8 (Join-Path $rrV.runDir 'manifest.json')) | ConvertFrom-Json
Assert 'verdict lands in the manifest' ($mfV.review_verdict -eq 'PASS-WITH-LOCKS')

Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
if ($fails.Count -eq 0) {
    Write-Host "ALL TESTS PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host ("FAILED: " + ($fails -join ', ')) -ForegroundColor Red
    exit 1
}
