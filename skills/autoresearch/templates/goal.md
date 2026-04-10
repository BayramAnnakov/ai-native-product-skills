# Goal: [one-line statement]

**Owner:** [name]
**Started:** [YYYY-MM-DD]
**Mode:** [pure / barbell / via negativa / inverted / human-in-loop]
**Triage verdict:** [all-green / yellow in X / red in X, adapted with mode Y]

---

## Goal

[What should be better after this runs? State as "before → after" with numbers where possible.]

Before: [current state]
After: [desired state]
Why it matters: [the real outcome this supports - not the metric, the outcome]

---

## Mutable surface

What files, prompts, config, copy, or parameters can the agent change? Be specific - paths or patterns, not categories.

**Read-only (must not touch):**
- [path or rule]
- [path or rule]

**Mutable (agent may modify):**
- [path or rule]
- [path or rule]

**If barbell mode:** the mutable surface above is the 10-15% experimental zone. The proven baseline is in:
- [path or rule]

---

## Fitness function

**Command:** `[the shell command or script that outputs a number]`

**Corpus:** [what the fitness is computed on - must be fixed and seeded]
- Path: [path to corpus]
- Size: [N examples]
- Seed: [integer]

**Baseline:** [the number before any iteration, date recorded]

**Significance threshold:** [delta below this is noise - measured from 5 repeat runs of the fitness function on the baseline]

**Sanity check:**
- Known-good examples scored: [list, with scores]
- Known-bad examples scored: [list, with scores]
- Metric agrees with ground truth: [yes / no - if no, DO NOT START THE LOOP]

---

## Guard metrics

What must not regress. At least one guard is required.

- **[Guard 1 name]:** must stay [above / below] [threshold]. Measured by: `[command]`
- **[Guard 2 name]:** must stay [above / below] [threshold]. Measured by: `[command]`

If any guard fails, automatic revert regardless of the primary metric.

---

## Budget

- Iterations: [N]
- Wall-clock: [T hours]
- Dollars: [$X]

The loop terminates when any budget is exhausted, a plateau is detected (10 iterations with no improvement above the significance threshold), or a guard is violated without a recoverable revert.

---

## Stop conditions beyond budget

- [any domain-specific rule - e.g., "stop if proposal quality degrades," "stop if reviewer approval rate drops below 50%"]

---

## Notes

Prior attempts, known bad directions, things that have already been tried, things the agent should NOT propose:

- [note]
- [note]

---

## Triage record

Walked through `references/triage-checklist.md` on [date]:

| Dimension | Score | Reason |
|-----------|-------|--------|
| Feedback latency | G/Y/R | |
| Metric mechanicality | G/Y/R | |
| Tail shape | G/Y/R | |
| Sample size | G/Y/R | |
| Surface locality | G/Y/R | |

**Verdict:** [pure / barbell / via negativa / inverted / human-in-loop / refused]

---

## Fitness design record

Walked through `references/fitness-design.md` on [date]. The six requirements:

- [ ] Callable as a command
- [ ] Fixed corpus with fixed seeds
- [ ] Baseline recorded in `baseline.json`
- [ ] Significance threshold defined
- [ ] Sanity check done (known-good and known-bad agree with metric)
- [ ] Guard metrics defined

All six must be checked before the loop starts.
