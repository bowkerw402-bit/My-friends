# session-orientation.ps1
# Injected into Claude's context at the start of every chat via the SessionStart hook in
# ~/.claude/settings.json. Read only: it prints a compact orientation from the shared vault so
# Claude always has Will's current state in front of it without being told. Fails quietly if the
# vault is not present (for example on another machine).

$ErrorActionPreference = 'SilentlyContinue'
$vault = 'C:\Users\bowke\OneDrive\Documents\GitHub\My-friends'
if (-not (Test-Path $vault)) { exit 0 }

Write-Output '=== Vault orientation (auto injected, read before working) ==='
Write-Output 'Standards: no dashes as punctuation, plain language, draft only. Full rules in My-friends/_reference/standards/.'
Write-Output 'Toolbox (apply as defaults for any build, design, or writing): ~/.claude/toolbox/README.md'

$active = Get-ChildItem -Directory (Join-Path $vault '10-active') -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
if ($active) {
  Write-Output ('Active work (My-friends/10-active): ' + ($active -join ', ') + '. Read the relevant entry before touching it.')
}

$daily = Join-Path $vault 'mission-control\DAILY.md'
if (Test-Path $daily) {
  Write-Output ''
  Write-Output '--- mission-control/DAILY.md (current state) ---'
  Get-Content $daily -TotalCount 45 | ForEach-Object { Write-Output $_ }
}
Write-Output ''
Write-Output 'Deeper state: mission-control/BOARD.md (92 ventures), _reference/ (the-line, capabilities, standards, learning).'
Write-Output 'Be gentle: do not restructure or archive on assumption. Draft only, Will fires.'
Write-Output '=== end orientation ==='
exit 0
