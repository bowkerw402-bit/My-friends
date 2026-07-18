param(
    [string]$Vault        = 'C:\Users\bowke\OneDrive\Documents\GitHub\My-friends',
    [string]$LedgerPath   = 'C:\Users\bowke\OneDrive\Desktop\CLAUDE\Business\_ideas\LEDGER.md',
    [string]$BusinessRoot = 'C:\Users\bowke\OneDrive\Desktop\CLAUDE\Business',
    [int]$SinceHours      = 24,
    [switch]$Commit,
    [switch]$Open         # open DAILY.md when done (used by the morning task so it lands on screen)
)

# Regenerates Mission Control: mission-control/BOARD.md (funnel state from the ledger)
# and mission-control/DAILY.md (morning digest from run manifests + ledger + open gates).
# Intended to be run on demand OR by a scheduled task each morning (-Commit to push).

Import-Module (Join-Path $PSScriptRoot 'OrchestratorLib.psm1')    -Force -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot 'MissionControlLib.psm1')  -Force -DisableNameChecking
Set-Utf8Console

$r = Update-MissionControl -Vault $Vault -LedgerPath $LedgerPath -BusinessRoot $BusinessRoot -SinceHours $SinceHours
Write-Host ("Mission Control updated: " + $r.ventures + " ventures, " + $r.runs + " runs (last ${SinceHours}h), " + $r.gates + " open gates") -ForegroundColor Cyan
Write-Host ("  " + $r.board)
Write-Host ("  " + $r.daily)

if ($Commit) {
    # keep the _tools backup mirror in step with the running copy, so they cannot drift silently
    $mirror = Join-Path $Vault '_tools'
    if (Test-Path -LiteralPath $mirror) {
        Copy-Item (Join-Path $PSScriptRoot '*.ps1')  $mirror -Force -ErrorAction SilentlyContinue
        Copy-Item (Join-Path $PSScriptRoot '*.psm1') $mirror -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 2
    Invoke-VaultCommit -Vault $Vault -Paths @('mission-control/BOARD.md','mission-control/DAILY.md','_tools') `
        -Message ("mission-control: " + (Get-Date).ToString('yyyy-MM-dd HH:mm'))
    Write-Host "  committed + pushed" -ForegroundColor DarkGray
}
# keep the Desktop transcript reader current
try { & (Join-Path $PSScriptRoot 'Build-TranscriptIndex.ps1') | Out-Null } catch { }

if ($Open) { try { Invoke-Item -LiteralPath (Join-Path $Vault 'mission-control\DAILY.md') } catch { } }
