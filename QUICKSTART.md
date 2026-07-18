# QUICKSTART

Four verbs, loaded in your PowerShell profile. That's the whole daily surface.

| Verb | What it does | When |
|------|--------------|------|
| `today` | opens this morning's report | first thing each day — see runs, open gates, what needs you |
| `run "<task>" <venture>` | a real two-agent step | to actually do a piece of work (framed, recorded, **draft-only**) |
| `board` | refresh + open DAILY/BOARD | after a run or a change to the ledger |
| `capture "<idea>"` | drop an idea into the inbox | the moment you think of something — so it never rots in chat |

## Examples
```powershell
today                                   # read the morning report
run "build the AML gap-report template" ndis-audit-desk   # two-agent step in that venture
run "sanity-check the funnel maths"     # two-agent step in the current folder
board                                   # refresh the board after work
capture "idea: weekly compliance digest as a lead magnet"
```

## What happens when you `run`
Claude + Codex hold a real back-and-forth (both genuinely present — it fails loud if Codex is down),
then a committed **Run Record** appears in `runs/` and the folder opens for you. Nothing is ever sent,
deployed, or spent — you do that. Read the full model in `_reference/the-line.md`.

_Not loaded yet? Add this line to your PowerShell profile (`notepad $PROFILE`):_
```powershell
Import-Module "$HOME\.claude\tools\Will-OS.psm1" -DisableNameChecking
```
