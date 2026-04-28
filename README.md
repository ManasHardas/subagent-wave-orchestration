# subagent-wave-orchestration

A discipline framework for building software with Claude Code (or similar AI orchestration tools) using **dispatched specialist agents** organized in **wave-cadence** phases.

Extracted from a real production project that ran 19+ sessions across 8 phases, shipping ~50 PRs through the pattern with calibrated reviewer composition rules, budget watchdogs, and operating-mode discipline.

---

## What this is

A copy-into-your-project template containing:

- **`agents/`** — generic role docs for 11 specialist agents (orchestrator, PM, PM-Designer, Code Review, Security, SRE, Backend, Frontend, Infra, QA, Docs)
- **`dispatch-templates/`** — 4 permanent dispatch-brief clauses extracted from real-project retrospectives:
  - Clause #3: test-file-in-initial-commit
  - Clause #6: reviewer-trio composition (default-keep / default-prune rules)
  - HARD CONSTRAINT: verification environment (no `docker cp` / `docker exec` mutation)
  - Close-keyword convention (one `Closes #N` per line for bundled PRs)
- **`templates/`** — empty starter files for `wave-state.md`, `capacity-log.md`, `velocity.json`, `phase-spec.md`, `implementation-plan.md`
- **`scripts/`** — read-only checklist printers for session-start + session-close
- **`CLAUDE.md.snippet`** — paste this into your project's `CLAUDE.md` to encode operating-mode rules

## What this is NOT

- A code generator. The agents don't write themselves; you orchestrate them via `Agent` tool calls in your Claude Code session.
- A framework that runs autonomously. Human (you) approves session budget, picks operating mode, escalates on blockers.
- Tied to any specific tech stack. Patterns work for FastAPI/Next.js, Django/React, or any backend+frontend split. Replace `<api-routes-dir>`, `<frontend-app-dir>` etc. with your project's paths.

## The wave cadence

Every phase runs through 5 waves:

```
Wave 0    — Contract Freeze        (Orchestrator alone)
Wave 0.5  — Issue Planning         (Backend + Frontend + Infra agents in parallel)
Wave 1    — Build (loop)           (Specialist agents per filed issue)
Wave 2    — QA                     (QA agent)
Wave 3    — Phase close            (Docs agent + tag + roadmap update)
```

Wave 0 + Wave 0.5 produce the **filed-issue ready-set** that drives Wave 1 build dispatch. Skipping Wave 0.5 (orchestrator synthesizing dispatch briefs from memory instead of from filed issues) was the discipline-failure mode that motivated codifying these rules.

## Specialist agents (11 roles)

| Role | Writes | Reviews | File |
|---|---|---|---|
| **Orchestrator** | Contracts, glue, merges | Everything, final call | `agents/orchestrator.md` |
| **PM (Stage 2)** | Velocity log, capacity log, wave-state | n/a | `agents/pm.md` |
| **PM / Designer** | Nothing | User-visible PRs + phase-spec sanity check | `agents/pm-designer.md` |
| **Code Review** | Nothing | Every Wave 1 build PR | `agents/code-review.md` |
| **Security** | Narrow security fixes | Auth-pathway + new-attack-surface PRs | `agents/security.md` |
| **SRE** | Instrumentation, retry decorators | Worker + external-API PRs | `agents/sre.md` |
| **Backend** | API routes, services, workers, models | n/a | `agents/backend.md` |
| **Frontend** | App routes, components, lib | n/a | `agents/frontend.md` |
| **Infra** | Compose, Dockerfiles, CI, scripts | n/a | `agents/infra.md` |
| **QA** | Test files | n/a | `agents/qa.md` |
| **Docs** | README, CHANGELOG, runbooks | n/a | `agents/docs.md` |

## Operating modes — ACTIVE vs DEGRADED

Real-project retrospective revealed that `PM-skip mode` (orchestrator self-plans without dispatched PM) is valid for narrow-fix sibling-shape sessions but DANGEROUS for sessions introducing new contract surfaces. The rule:

**ACTIVE mode is REQUIRED if ANY of:**
- New phase boundary
- New contract surface introduction (new endpoints, tables, external API integration)
- >1-issue scope synthesis required (work not yet decomposed into filed GH issues)
- Unresolved fix-cycle from prior session
- First-of-class novel surface (no prior data point for the class)

**DEGRADED is allowed ONLY when ALL:**
- All planned slots are narrow-fix or sibling-shape
- All issues filed before session start
- No new contract artifacts
- Last session closed cleanly

This rule is encoded in:
1. `agents/orchestrator.md` §Session-start ritual
2. `CLAUDE.md.snippet` (auto-loaded into every conversation context)

## Adoption guide

### 1. Clone into your project

```bash
cd <your-project>
git submodule add https://github.com/<your-username>/subagent-wave-orchestration .orchestrator
# OR plain copy:
git clone https://github.com/<your-username>/subagent-wave-orchestration .orchestrator
```

### 2. Customize agent files for your stack

Open each `agents/*.md` and replace placeholders:

- `<api-routes-dir>` → your project's API route directory (e.g., `backend/api/`)
- `<services-dir>` → e.g., `backend/services/`
- `<workers-dir>` → e.g., `backend/workers/`
- `<frontend-app-dir>` → e.g., `frontend/app/`
- `<api-codegen-output>` → e.g., `frontend/lib/api/generated.ts`
- `<migrations-versions-dir>` → e.g., `backend/alembic/versions/`
- `<full-stack-up-command>` → e.g., `docker compose up --build`

Search for `<placeholder>` style strings and adapt them.

### 3. Initialize wave state + velocity log

```bash
cp .orchestrator/templates/wave-state.md plans/wave-state.md
cp .orchestrator/templates/capacity-log.md plans/capacity-log.md
cp .orchestrator/templates/velocity.json plans/velocity.json
```

Edit `plans/wave-state.md` to reflect your project's starting state (phase 1, wave 0, no carry-over).

### 4. Paste the operating-mode rules into your CLAUDE.md

```bash
cat .orchestrator/CLAUDE.md.snippet >> .claude/CLAUDE.md
# OR (project-level):
cat .orchestrator/CLAUDE.md.snippet >> CLAUDE.md
```

### 5. Mark scripts executable

```bash
chmod +x .orchestrator/scripts/*.sh
```

### 6. First orchestrator session

In a fresh Claude Code conversation in your project's directory:

> Read `.orchestrator/agents/orchestrator.md`. We're starting Phase 1 of <project>. I'll be the user; you're the Orchestrator. Run the Session-start ritual.

Claude reads the role + checks wave-state + asks you for budget + decides ACTIVE/DEGRADED + proposes next activities. Wave 0 contract-freeze writing happens; Wave 0.5 dispatches Backend/Frontend/Infra in parallel to decompose into issues; Wave 1 dispatches per filed issue.

### 7. Refine priors as you go

`agents/pm.md` ships with bootstrap priors (sibling-cache-warm 50-65k, first-of-class 75-90k, etc.). After ~10-15 PRs in your project, PM should regenerate the table from `velocity.json` actuals. The bootstrap priors are starting points, not gospel.

## How to NOT use this

- **Don't try to use it on a single-implementer-no-Claude project.** The patterns assume specialist-agent dispatch is the build mechanism. Without that, the wave cadence over-scopes.
- **Don't run agents in parallel without independent scope.** "Parallel within a wave" only works for files-don't-overlap dispatches. Two backend agents touching the same router file = merge conflicts.
- **Don't skip Wave 0.5.** Orchestrator-synthesized dispatch briefs (no filed-issue intermediate) consistently produce 50-100k token fix-cycle taxes. Filed issues = scope checkpoint = no synthesis bugs.
- **Don't run PM-skip mode for first-of-class slots.** See ACTIVE vs DEGRADED rules above.

## License

MIT. See LICENSE.

## Provenance

Pattern extracted 2026-04-28 from a real project that ran 19 sessions across 8 phases, shipping ~50 PRs through the pattern with calibrated reviewer composition rules. Names and project-specific examples genericized for cross-project reuse.

The S18 dispatch-brief-accuracy collapse retrospective (where PM-skip was wrongly applied to a session introducing new pages, producing 4 PM-D Blockers + 68k fix-cycle tax) is the clearest single source for why the operating-mode discipline matters. That retrospective is encoded in `agents/orchestrator.md` §Session-start ritual.
