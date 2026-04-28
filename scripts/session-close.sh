#!/usr/bin/env bash
# usage: ./scripts/session-close.sh
# Print the session-close checklist for PM to execute.
# This script is read-only — it does NOT mutate any state.
set -euo pipefail
cd "$(dirname "$0")/.."

cat <<'EOF'
==============================================================
SESSION-CLOSE PROTOCOL — PM responsibility
==============================================================

PM agent runs at session-close to update three persistent files:

1. plans/velocity.json
   Append one entry per merged PR + per agent-dispatch.
   Schema (per agents/pm.md §Per-merge):

   {
     "session": N,
     "wave": "<wave>",
     "kind": "pr_merge" | "agent_dispatch",
     "pr": <num>,                  # for pr_merge
     "issue": <num>,               # for pr_merge
     "agent_role": "<role>",
     "tokens_implementer": <int>,
     "tokens_reviewers": <int>,    # sum of CR/SRE/Security/PM-D
     "review_iterations": <int>,
     "files_touched": <int>,
     "wall_clock_min": <int>,
     "notes": "<calibration observations>"
   }

   Validate JSON before commit:
   $ python3 -c "import json; json.load(open('plans/velocity.json'))"

2. plans/capacity-log.md
   Append session entry following the template in
   templates/capacity-log.md.

   Required sections:
   - Stage 2 PM mode (ACTIVE / DEGRADED)
   - Wave executed
   - Build PRs merged
   - Activities completed
   - Issues filed
   - Discipline holds (T-A / T-G / T-D / re-consults / HARD CONSTRAINT)
   - Calibration findings
   - Cumulative dispatched (% of ceiling)
   - Forecast for next session

3. plans/wave-state.md
   Update the "## Current state" block to reflect post-session reality:
   - Phase + Wave (next required state)
   - Last session SHA
   - Carry-over slots
   - Open blockers (none if clean close)
   - Next required activities (read agents/orchestrator.md §Wave sequence)

   Move just-closed session into "## Recent session history"
   (drop oldest if rolling window > 5).

4. Commit all 3 files in ONE chore PR:
   $ git checkout -B chore/s<N>-close origin/main
   $ git add plans/velocity.json plans/capacity-log.md plans/wave-state.md
   $ git commit -m "chore: S<N> <phase/wave> close"
   $ git push -u origin chore/s<N>-close
   $ gh pr create --title "chore: S<N> close" --body "..."
   $ # Wait for CI green; self-merge.

==============================================================
EOF
