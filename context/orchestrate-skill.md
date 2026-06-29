---
name: orchestrate
description: >
  Splits a task between Claude Code and Codex and runs both agents in parallel.
  Use this skill whenever Will says "orchestrate", "run both agents on this",
  "get Claude and Codex to work on this together", "multi-agent", or any variant
  of wanting two AI agents collaborating on a single task. Works across ANY project
  — not tied to a specific repo. Will activates this manually; never auto-trigger it.
---

# Orchestrate — Two-Agent Workflow

Will is running Claude Code + Codex as a two-agent system. When this skill is
invoked, you coordinate both agents on a single task.

## What to do

### 1. Clarify the task (if needed)
If the task is vague, ask one short clarifying question before splitting. If it's
clear enough, proceed straight to the split.

### 2. Plan the split
Divide the task into two parallel workstreams — one for Claude Code, one for Codex.
Good splits are:
- Independent (neither blocks the other)
- Complementary (together they cover the whole task)
- Roughly equal in scope

Examples of good splits:
- "Build a contact form" → Claude: HTML/logic | Codex: CSS/styling
- "Write tests for auth" → Claude: unit tests | Codex: integration tests
- "Refactor the dashboard" → Claude: data layer | Codex: UI components

### 3. Run the orchestrator script
Call the global PowerShell orchestrator with the full task description:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "C:\Users\bowke\.claude\tools\orchestrate.ps1" `
  -Task "<full task description>" `
  -WorkDir "<current working directory>"
```

This script:
- Runs Claude and Codex in parallel background jobs
- Collects both results
- Auto-logs the session to the shared vault (My-friends/log/sessions.md) and pushes to GitHub

### 4. Synthesise and report
Once both agents finish, summarise:
- What Claude handled and what it produced
- What Codex handled and what it produced
- Any follow-up steps or conflicts to resolve

### 5. Note anything worth sharing
If either agent produced context that the other should know about for future tasks,
write a short note to `C:\Users\bowke\OneDrive\Documents\GitHub\My-friends\claude\`
and push it so Codex can read it next session.

## Key rules
- Never auto-trigger this skill — Will activates it manually with `/orchestrate`
- Do not delegate back to the agent that called you (no recursive loops)
- Production deployments and domain changes require Will's explicit approval
- If the orchestrator script isn't available, split the task manually and run
  `tools/ask-codex.ps1` for the Codex portion

## Shared vault
The shared knowledge base between Claude and Codex lives at:
- Local: `C:\Users\bowke\OneDrive\Documents\GitHub\My-friends\`
- GitHub: https://github.com/bowkerw402-bit/My-friends

Check `My-friends/context/` at the start of a significant orchestrated task for
any shared state left by a previous session.
