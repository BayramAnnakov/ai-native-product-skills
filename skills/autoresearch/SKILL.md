---
name: autoresearch
description: Apply Karpathy's autoresearch loop (goal + mechanical fitness + mutable surface + keep-or-revert iteration) to ANY measurable workflow - code, content, sales, research, design, operations, not just ML or software. Use when the user asks to set up an overnight improvement loop, a keep-or-revert experiment workflow, iterative optimization, or asks "can I autoresearch this?". Includes a pre-loop triage that refuses fat-tailed, reflexive, or slow-feedback problems without adapting the mode.
---

# Autoresearch (generalized)

Karpathy's loop in one breath: pick a goal, define a mechanical fitness function, constrain a mutable surface, iterate keep-or-revert until budget or plateau. This skill ports it to any domain.

**The hard-won lesson: most candidate workflows are not autoresearch-shaped.** Running the loop on a fat-tailed, reflexive, or slow-feedback problem converges to a local optimum of the wrong thing - very efficiently. This skill's main job is to catch that before the loop starts. Saying "this isn't autoresearch-shaped, here's why, here's what to do instead" is the correct output when a candidate fails triage.

## When this skill applies

Invoke when the user:
- wants to scaffold or run an iterative improvement loop on any workflow
- mentions Karpathy, autoresearch, keep-or-revert, overnight optimization, Tobi's Liquid, pi-autoresearch, "the Karpathy loop"
- asks "can I apply autoresearch to X"
- has a measurable goal and wants autonomous iteration
- says "overnight agent," "experiment loop," "fitness function," "val_bpb"

Do NOT invoke for:
- one-shot optimization (no iteration needed - just do the thing)
- pure subjective quality with no path to a mechanical metric and no willingness to build one
- safety-critical / irreversible actions where keep-or-revert cannot be automated
- architecture or strategy questions (use the council skill instead - "use autoresearch for plumbing, never for architecture")

## Five stages, in order

1. **Intake** - what, how measured, what can change, what can't regress, budget
2. **Triage** - is this problem autoresearch-shaped? (see `references/triage-checklist.md`)
3. **Fitness design** - build or validate the fitness function (see `references/fitness-design.md`)
4. **Mode selection** - pure / barbell / via negativa / inverted / human-in-loop (see `references/modes.md`)
5. **Loop + post-mortem** - scaffold, run, diagnose plateau if reached (see `references/anti-patterns.md` when diagnosing)

Skip stages only when the user explicitly says "I've done that, start the loop."

---

## Stage 1: Intake

Ask all five in one structured message, not one at a time:

1. **Goal** - what should be better after this runs? State as "before → after."
2. **Candidate metric** - how would you know it's better? A number is ideal; a deterministic rubric is the fallback.
3. **Mutable surface** - what files, prompts, config, copy, or parameters can the agent change? Be specific.
4. **Guard** - what must not regress? Safety tests, brand rules, legal constraints, downstream dependencies.
5. **Budget** - iterations, wall-clock, or dollars.

If the user cannot answer 2 or 3, continue anyway. Triage will surface it and Stage 3 will force a resolution.

---

## Stage 2: Triage

Load `references/triage-checklist.md`. Walk the candidate through five dimensions and score each green / yellow / red:

- Feedback latency
- Metric mechanicality
- Tail shape (thin vs fat-tailed)
- Sample size vs noise
- Surface locality (atomic diff vs system redesign)

**Decision rules:**
- All green → pure optimizer mode, proceed to Stage 3
- Any yellow → mode adaptation required, proceed to Stage 3 with concerns noted
- Any red → either adapt the mode or **refuse the loop and offer alternatives** (council, human-in-loop, fix the upstream bottleneck first, smaller better-shaped sub-problem)

Refusal is a feature. Do not start the loop to be agreeable.

---

## Stage 3: Fitness design

Load `references/fitness-design.md`. The fitness function is where autoresearch dies when it dies - not in the loop mechanics.

Required before the loop can start:
1. Fitness is a command (or deterministic chain) that outputs a number
2. It runs on a fixed corpus with fixed seeds (stationary across iterations)
3. Baseline has been recorded to `baseline.json`
4. Significance threshold defined (what delta is real vs noise)
5. Sanity check done: score known-good and known-bad by hand, confirm the metric agrees
6. Guard metrics defined: what must not regress

If 1-4 are not met, the skill's answer is: "fix the fitness function first, then come back." This is the single highest-leverage intervention. Do not skip it to be helpful.

---

## Stage 4: Mode selection

Load `references/modes.md`. Pick exactly one:

| Mode | When |
|------|------|
| **Pure optimizer** | Small mutable surface, fast feedback, clean metric, thin-tailed |
| **Barbell** | Fat-tailed, reflexive domain - 85% immutable proven baseline + 15% wild experiments |
| **Via negativa** | Fragile system - ask "what to kill" not "what to add" |
| **Inverted** | Imbalanced classes - optimize rejection of bad, not selection of good |
| **Human-in-loop** | Slow feedback or irreversible actions - agent proposes, human decides |

Record the mode in `goal.md`. It controls what the loop is allowed to propose.

---

## Stage 5: Loop + post-mortem

### Scaffold (once)

Create in the user's working directory (or a subdirectory they pick):
- `goal.md` - filled from `templates/goal.md`: goal / metric / surface / guard / mode / budget
- The fitness command (script, notebook, evaluator - user's choice, not the skill's)
- `experiments/` directory for per-iteration logs
- `baseline.json` with the starting metric value and sanity check results

### Run the loop

1. Read state: git log, `experiments/`, last N lessons learned
2. Propose ONE focused change, respecting the mode
3. Commit the proposal with an `experiment:` prefix BEFORE running (so git can revert)
4. Run the fitness command
5. Compare to baseline (or best-so-far) with the significance threshold
6. Keep (advance baseline) or revert (`git revert`)
7. Append a one-line lesson to `experiments/journal.md`
8. Check termination: budget exhausted, plateau detected (10 iterations without improvement), guard violated → Stage 6

Non-negotiable principles:
- One change per iteration
- Mechanical verification only (no "looks good")
- Automatic rollback on regression or guard failure
- Git is memory

### Post-mortem (when the loop stops)

Produce:
- Final metric vs baseline, with significance
- Top 3 changes that stuck, top 3 changes that were reverted
- **Plateau diagnosis** if plateaued - consult `references/anti-patterns.md` and name one:
  - Wrong search space → change the mutable surface
  - Wrong metric → fitness does not correlate with the real goal
  - Broken measurement → sample size, stationarity, or confounded labels
  - Genuine local optimum → switch mode to barbell
  - Out of budget → more iterations would help

**The plateau diagnosis IS the deliverable when the loop doesn't improve.** Foreground it, don't bury it.

---

## Style rules for this skill

- Declarative: tell the user WHAT to check, not exact commands. The agent picks the command.
- Refuse gracefully and suggest alternatives when a candidate fails triage
- Keep the loop boring - creativity lives in triage and mode selection, not loop mechanics
- Git is the experiment log; `journal.md` is the narrative
- Use plain `-` hyphens, not em dashes
