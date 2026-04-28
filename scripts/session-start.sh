#!/usr/bin/env bash
# usage: ./scripts/session-start.sh
# Print the session-start checklist + current wave-state for orchestrator to read.
# This script is read-only — it does NOT mutate any state.
set -euo pipefail
cd "$(dirname "$0")/.."

WAVE_STATE="${WAVE_STATE:-plans/wave-state.md}"

cat <<'EOF'
==============================================================
SESSION-START RITUAL — orchestrator MUST execute these checks
==============================================================

1. Fetch + reset worktree to origin/main:
   $ git fetch origin main && git reset --hard origin/main
   (Verify clean status; ignore expected untracked artifacts)

2. Read the authoritative wave-state file:
EOF

if [[ -f "$WAVE_STATE" ]]; then
  echo "   $ cat $WAVE_STATE"
  echo ""
  echo "------- $WAVE_STATE -------"
  cat "$WAVE_STATE"
  echo "------- end -------"
else
  echo "   ERROR: $WAVE_STATE not found."
  echo "   Create from templates/wave-state.md if this is a fresh project."
  echo ""
fi

cat <<'EOF'

3. Cross-reference required activities for current phase+wave from
   agents/orchestrator.md §Wave sequence:

   - Wave 0: orchestrator-only contract freeze + PM-D phase-sanity-check
             + tracking issue creation
   - Wave 0.5: 3 parallel build-agent dispatches (BE + FE + Infra)
               for issue decomposition
   - Wave 1: build loop dispatching per filed issue
   - Wave 2: QA agent
   - Wave 3: Phase close

4. Confirm session budget with user:
   - full window / ~half / tight / specific token estimate

5. Decide operating mode:

   ACTIVE (Stage-2 PM dispatched + filed-issue-derived briefs) is
   REQUIRED if ANY of:
   - New phase boundary (Wave 0)
   - New contract surface introduction
   - >1-issue scope synthesis required
   - Unresolved fix-cycle from prior session
   - First-of-class novel surface

   DEGRADED (PM-skip; orchestrator self-plans) is allowed ONLY when
   ALL of:
   - All planned slots are narrow-fix or sibling-shape
   - All issues filed before session start
   - No new contract artifacts
   - Last session closed cleanly

6. Confirm with user before proceeding if mode is contested.

==============================================================
EOF
