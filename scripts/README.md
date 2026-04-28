# Scripts

Read-only helpers that print checklists for orchestrator + PM. They do NOT mutate state — actual file updates remain manual (orchestrator writes commits; PM appends entries).

| Script | Owner | Purpose |
|---|---|---|
| `session-start.sh` | Orchestrator | Print session-start checklist + cat current `plans/wave-state.md` |
| `session-close.sh` | PM | Print session-close protocol (what files to update, in what shape) |

## Why read-only

Mutating `plans/wave-state.md` from a script risks drifting from what the LLM agent actually believes. The discipline relies on PM reasoning through the update at session-close (Bayesian prior updates, calibration findings, etc.) — automating the file-write would skip that reasoning.

These scripts exist as printed reminders, not automation.

## Usage in a fresh project

After cloning this template into your project:

```bash
chmod +x scripts/*.sh

# Session-start — orchestrator runs this:
./scripts/session-start.sh

# Session-close — PM agent runs this (printed checklist; PM then dispatches to update files):
./scripts/session-close.sh
```
