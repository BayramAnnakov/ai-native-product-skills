# Autoresearch iteration prompt

You are running iteration {{ITER}} of {{MAX_ITER}} in an autoresearch loop. You have ONE job: propose one atomic change, run fitness, keep or revert, log the result, exit.

Do NOT start a second iteration yourself - the driver script handles that.

## Step 1: Read state before anything else

1. Read `goal.md` - your full brief (mode, mutable surface, fitness command, guards, budget, triage verdict, prior attempts).
2. Read `experiments/journal.md` - every prior iteration's result. Pay special attention to the last 10 lines.
3. Read `experiments/baseline.json` - the starting metric and significance threshold.
4. Run `git log --oneline -20` to see the experiment history in git.

## Step 2: Plateau check (before proposing anything)

Parse the last 10 lines of `experiments/journal.md`. If all deltas are smaller than the significance threshold from `baseline.json`, you are plateaued.

**If plateaued: STOP. Do NOT propose another timid tweak.** Write `experiments/STOP` with:
```
plateau: change the search space, not the iteration count. See anti-pattern #13.
```
Then exit. Iteration theater is the single most common failure in autoresearch runs.

## Step 3: Propose ONE atomic change

Non-negotiable rules:
- **Exactly one change.** Not five. Not "a batch of related tweaks."
- **Respect the mode** declared in `goal.md`:
  - Pure: any change inside the mutable surface
  - Barbell: changes inside the 15% experimental zone ONLY (the proven baseline is locked)
  - Via negativa: propose a REMOVAL of something, not an addition
  - Inverted: edit the rejection filter, not the quality scorer
  - Human-in-loop: propose and WAIT (this loop driver is for autonomous modes; switch to manual for human-in-loop)
- **Respect the mutable surface.** Do NOT touch read-only paths from `goal.md`.
- **No architectural redesigns.** Autoresearch is plumbing, not architecture. If you find yourself wanting to redesign the system, write that to `experiments/STOP` with "architectural - use /council instead."
- **If recent iterations plateaued, escalate ambition** (Karpathy's exact rule): *"think harder - read papers referenced in the code, re-read the in-scope files for new angles, try combining previous near-misses, try more radical architectural changes."* Do NOT propose another 2-character tweak to escape a plateau. Try a genuinely different idea.

## Step 4: Commit BEFORE running fitness

```bash
git add <changed-files>
git commit -m "experiment: <one-line description>"
```

The commit happens first so `git revert` always works cleanly. Never run fitness on uncommitted state.

## Step 5: Run the fitness command

Run the exact command from `goal.md` (the one you recorded in Stage 3). Parse its output to extract the primary metric. Also run each guard check listed in `goal.md`.

## Step 6: Keep or revert (Karpathy's simplicity criterion)

Mechanical decision based on fitness + a complexity weighting:

- **Guard failure** → always **revert**, even if the primary metric improved dramatically. Guards are non-negotiable.
- **Guard improvement at zero fitness cost** (e.g. compliance 62% → 86% with fitness in noise) → **Keep**. Making the prompt functional is a simplification-adjacent win even when the primary metric doesn't move.
- **Single-run keep confirmation:** if your decision to keep is based on a single-run |delta| > the single-run-accept threshold (e.g. 0.025), run the fitness ONE more time at the new HEAD before advancing the baseline. If the second run's delta vs the previous HEAD is under significance, the first run was a lucky draw - revert and investigate. This adds one run per keep; it's cheap insurance against stochastic-evaluator false positives.
- Otherwise, apply Karpathy's verbatim rule from `program.md`:

  | Fitness delta | Complexity delta | Decision |
  |---------------|-----------------|----------|
  | Big improvement | Any | Keep (after confirmation run if single-run) |
  | Small improvement (above significance threshold) | Deleted code | **Keep** (simplification win) |
  | Small improvement (above significance threshold) | Added clean code | Keep |
  | Small improvement | Added ugly / hacky code | **Revert** (not worth it) |
  | ~0 (below significance) | Much simpler | **Keep** (deletion alone is valuable) |
  | ~0 (below significance) | Guard improved (compliance, safety) | **Keep** (functional win) |
  | ~0 (below significance) | Added code | **Revert** |
  | Regression | Any | **Revert** |

- **Never** keep on "looks good." The fitness function is the judge on fitness; the simplicity criterion is the judge on complexity.
- If you keep, update `experiments/baseline.json` with the new metric.
- If you revert:
  ```bash
  git revert HEAD --no-edit
  ```

## Step 7: Log exactly one line

Append to `experiments/journal.md`:
```
iteration={{ITER}} metric=<number> delta=<number_signed> kept=<yes|no> change=<one-line summary>
```

Example:
```
iteration=17 metric=0.1847 delta=+0.0091 kept=yes change=replaced keyword-list with structured feature extraction
iteration=18 metric=0.1839 delta=-0.0008 kept=no change=added "be concise" to system prompt
```

## Step 8: Check termination signals

Write `experiments/STOP` with a one-line reason and exit if:
- A guard metric violated and no revert can recover it
- You've determined the search space is exhausted (plateau check in Step 2)
- The mutable surface has no more productive experiments (iteration theater detected)
- You've hit any architectural or strategic question that autoresearch can't answer

Otherwise exit cleanly - the driver will start iteration {{ITER}}+1.

## Step 9: Exit

Exit. Do NOT start the next iteration. Do NOT summarize the whole loop. That's Stage 6's job, run after the driver terminates.
