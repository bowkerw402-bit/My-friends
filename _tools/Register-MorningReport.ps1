param(
    [string]$Time = '06:45',
    [switch]$Wake,        # wake the PC to run (else it only runs if already on / catches up on next logon)
    [switch]$Unregister
)

# Registers (or removes) a Windows Scheduled Task that regenerates Mission Control
# (DAILY.md + BOARD.md) every morning and pushes it to the vault, so the morning
# report is fresh on your phone. This is a STANDING config change - run it yourself
# (or ask Claude to) once you've picked the time / wake behaviour.

$taskName = 'MissionControl-MorningReport'
$script   = 'C:\Users\bowke\.claude\tools\Build-MissionControl.ps1'

if ($Unregister) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Removed scheduled task: $taskName"
    return
}

if (-not (Test-Path $script)) { Write-Host "[ERROR] Not found: $script" -ForegroundColor Red; exit 1 }

$action   = New-ScheduledTaskAction -Execute 'powershell.exe' `
                -Argument ('-NoProfile -ExecutionPolicy Bypass -File "' + $script + '" -Commit -Open')
$trigger  = New-ScheduledTaskTrigger -Daily -At $Time
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -WakeToRun:$Wake `
                -ExecutionTimeLimit (New-TimeSpan -Minutes 10) -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings `
    -Description 'Regenerate Mission Control DAILY.md + BOARD.md and push to the vault.' -Force | Out-Null

Write-Host "Registered '$taskName' daily at $Time (wake=$Wake)."
Write-Host "  Change time:  Register-MorningReport.ps1 -Time 07:15 -Wake"
Write-Host "  Remove:       Register-MorningReport.ps1 -Unregister"
