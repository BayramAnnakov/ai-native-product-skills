#!/usr/bin/env bash
#
# Autoresearch loop driver.
#
# Runs `claude -p` (non-interactive mode) in a bounded loop until ANY of:
#   - max iterations reached (hard cap)
#   - dollar budget exhausted (claude -p --max-budget-usd)
#   - plateau detected (N iterations without significance-threshold improvement)
#   - guard violation (loop writes experiments/STOP)
#
# No hooks. No daemons. No framework. ~80 lines of bash is the whole driver.
# This file is the driver, not the product. Keep it simple.
#
# Usage:
#   ./loop-driver.sh [--max-iter N] [--max-budget-usd X] [--plateau-window N] [--goal goal.md]
#
# Reads:  goal.md, experiments/journal.md, experiments/baseline.json, iteration-prompt.md
# Writes: experiments/journal.md (appends), experiments/STOP (on termination)
# Commits: one git commit per iteration (kept) plus one revert commit (if reverted)

set -euo pipefail

# --- defaults ---
MAX_ITER=50
MAX_BUDGET_USD=10
GOAL_FILE="goal.md"
PROMPT_FILE="iteration-prompt.md"
PLATEAU_WINDOW=10

# --- flags ---
while [ $# -gt 0 ]; do
    case "$1" in
        --max-iter) MAX_ITER="$2"; shift 2 ;;
        --max-budget-usd) MAX_BUDGET_USD="$2"; shift 2 ;;
        --plateau-window) PLATEAU_WINDOW="$2"; shift 2 ;;
        --goal) GOAL_FILE="$2"; shift 2 ;;
        --prompt) PROMPT_FILE="$2"; shift 2 ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "Unknown flag: $1" >&2; exit 1 ;;
    esac
done

# --- preconditions ---
[ -f "$GOAL_FILE" ] || { echo "ERROR: $GOAL_FILE not found. Complete Stages 1-4 first." >&2; exit 1; }
[ -f "$PROMPT_FILE" ] || { echo "ERROR: $PROMPT_FILE not found. Copy templates/iteration-prompt.md here." >&2; exit 1; }
[ -f "experiments/baseline.json" ] || { echo "ERROR: experiments/baseline.json not found. Record baseline in Stage 3." >&2; exit 1; }
[ -d ".git" ] || { echo "ERROR: not a git repo. Autoresearch uses git as experiment memory." >&2; exit 1; }
command -v claude >/dev/null || { echo "ERROR: claude CLI not found in PATH." >&2; exit 1; }

mkdir -p experiments
rm -f experiments/STOP  # clear any stale stop signal

ITER=0
PLATEAU_COUNT=0
BEST_METRIC=""

echo "=== autoresearch loop starting: max_iter=$MAX_ITER budget=\$${MAX_BUDGET_USD} plateau_window=$PLATEAU_WINDOW ==="

while [ "$ITER" -lt "$MAX_ITER" ]; do
    ITER=$((ITER + 1))
    echo ""
    echo "=== Iteration $ITER / $MAX_ITER ==="

    # Substitute iteration variables into the prompt template
    PROMPT=$(sed "s/{{ITER}}/$ITER/g; s/{{MAX_ITER}}/$MAX_ITER/g" "$PROMPT_FILE")

    # Run one iteration: Claude reads state, proposes ONE atomic change,
    # commits, runs fitness, keeps or reverts, appends to journal.
    claude -p \
        --permission-mode acceptEdits \
        --max-budget-usd "$MAX_BUDGET_USD" \
        --output-format text \
        "$PROMPT" || {
            echo "experiments/STOP: claude -p exited non-zero (budget exhausted or error)" > experiments/STOP
            break
        }

    # STOP signal check (guard violation, plateau declared by Claude, manual stop)
    if [ -f "experiments/STOP" ]; then
        echo "STOP signal: $(cat experiments/STOP)"
        break
    fi

    # Driver-side plateau detection (belt and suspenders)
    LAST_METRIC=$(tail -1 experiments/journal.md 2>/dev/null | grep -oE 'metric=[0-9.]+' | cut -d= -f2 || true)
    if [ -n "${LAST_METRIC:-}" ]; then
        if [ -z "$BEST_METRIC" ] || awk -v a="$LAST_METRIC" -v b="$BEST_METRIC" 'BEGIN{exit !(a>b)}'; then
            BEST_METRIC="$LAST_METRIC"
            PLATEAU_COUNT=0
        else
            PLATEAU_COUNT=$((PLATEAU_COUNT + 1))
            if [ "$PLATEAU_COUNT" -ge "$PLATEAU_WINDOW" ]; then
                echo "plateau: $PLATEAU_WINDOW iterations without improvement - change the search space (see anti-pattern #13)" > experiments/STOP
                echo "STOP: $(cat experiments/STOP)"
                break
            fi
        fi
    fi
done

echo ""
echo "=== Loop terminated after $ITER iterations ==="
echo "Best metric: ${BEST_METRIC:-unknown}"
echo ""
echo "Next: run Stage 6 post-mortem."
echo "  - Review experiments/journal.md"
echo "  - Read experiments/STOP if present"
echo "  - Produce the plateau diagnosis (see SKILL.md Stage 6)"
