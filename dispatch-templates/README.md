# Dispatch-template clauses

Permanent clauses that orchestrator MUST include verbatim in every build-agent dispatch brief. Each clause was extracted from a real-project retrospective where omission produced a recurring failure mode.

| File | Clause | Failure mode it prevents |
|---|---|---|
| `clause-3-test-file-in-initial-commit.md` | Backend impl PRs MUST include test file in INITIAL commit covering ≥70% of new lines | Post-merge fix-cycle to add tests after diff-cover gate fails (~70-100k token tax per affected PR) |
| `clause-6-reviewer-trio-composition.md` | Default-keep / default-prune rules for which reviewers fire on which PR class | Over-reviewing (wasted tokens) on narrow fixes; under-reviewing (escaped Blockers) on novel surfaces |
| `hard-constraint-verification-environment.md` | Verify on host or `docker compose run --rm`; never `docker cp`/`docker exec` to mutate running containers | Image-built artifact mutations that don't survive image rebuild; verification-via-running-container that misses real bugs |
| `close-keyword-convention.md` | `Closes #N` on its own line; one per line for bundled PRs | GitHub auto-close keyword fails to match `Closes #40 + #41` syntax — leaves issues stale-open |

## How to compose into a dispatch brief

Inside the orchestrator's dispatch prompt template (`agents/orchestrator.md` §Wave 1 Agent dispatch template), insert each clause's body verbatim. Don't paraphrase. The clauses are calibrated to what the build agent will read and act on; paraphrase risks losing the specificity that makes the clause useful.

Example dispatch-brief skeleton:

```
You are the **<role> agent**. Read your role at `agents/<role>.md` first.

[Project-specific context: working directory, branch state, current phase + wave]

# Task

Implement issue **#<N>** — `<issue title>`. Read full spec via `gh issue view <N>`.

[Phase-specific context: sibling PRs, conventions, frozen contracts]

# DISPATCH-TEMPLATE CLAUSES (mandatory)

[Clause #3 body — paste from clause-3-test-file-in-initial-commit.md]

[Clause #6 body — orchestrator picks default-keep/default-prune row appropriate to this PR's class]

[HARD CONSTRAINT body — paste from hard-constraint-verification-environment.md]

[Close-keyword body — paste from close-keyword-convention.md]

# Out-of-scope guardrails (DO NOT cross)

[Project-specific scope-fence reminders]

# Verification gates (must pass before `gh pr ready`)

[Project-specific test commands + diff-cover thresholds]

# Return contract

[What you want the agent to report back]
```
