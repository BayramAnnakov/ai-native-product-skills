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

## Simplicity principles (Karpathy, verbatim)

Baked into every stage. Non-negotiable. Quoted directly from Karpathy's `program.md`:

1. **One atomic change per iteration.** Not five. Not "a batch of related tweaks." One. Revert is trivial; diagnosis is tractable.
2. **Small mutable surface.** Karpathy's original had exactly ONE file mutable (`train.py`) and one file read-only (`prepare.py`). If your surface is "the whole codebase" or "the whole prompt," the loop cannot converge. Scope down before looping.
3. **Simple fitness function.** One command. One number. Fixed corpus. Karpathy's was `grep "^val_bpb:" run.log`. If your fitness needs a 200-line harness, your fitness is wrong.
4. **Simple loop driver.** ~80 lines of bash, or one prompt that "LOOPs FOREVER" in a single session. Not a framework. Not microservices. Karpathy's entire system is `train.py` + `prepare.py` + `results.tsv` + `program.md` - four files.
5. **The simplicity criterion** (Karpathy's exact rule for keep-or-revert decisions):
   > *"All else being equal, simpler is better. A small improvement that adds ugly complexity is not worth it. Conversely, removing something and getting equal or better results is a great outcome - that's a simplification win. When evaluating whether to keep a change, weigh the complexity cost against the improvement magnitude. A 0.001 val_bpb improvement that adds 20 lines of hacky code? Probably not worth it. A 0.001 val_bpb improvement from deleting code? Definitely keep. An improvement of ~0 but much simpler code? Keep."*

   Decision table:

   | Fitness delta | Complexity delta | Decision |
   |---------------|-----------------|----------|
   | Small improvement | Added ugly code | **Revert** |
   | Small improvement | Deleted code | **Keep** (simplification win) |
   | ~0 | Much simpler | **Keep** (deletion alone is valuable) |
   | Big improvement | Added code | Keep (paid for by the gain) |
   | Big improvement | Deleted code | Definitely keep |

   This is NOT a rule about change magnitude ("be bold"). It is a rule about the trade-off between complexity cost and fitness benefit. Simplifications always win, even at zero fitness improvement.

6. **When stuck, escalate ambition - not iteration count.** Karpathy: *"If you run out of ideas, think harder - read papers referenced in the code, re-read the in-scope files for new angles, try combining previous near-misses, try more radical architectural changes."* If timid tweaks plateau, the answer is BOLDER changes, not more timid ones. See `references/anti-patterns.md` #13.

7. **Hard iteration cap + autonomous execution.** The loop driver enforces a max iteration count (default 50) and a dollar budget. Within those limits, the loop runs AUTONOMOUSLY - **never pausing to ask permission**. Karpathy, verbatim:
   > *"Once the experiment loop has begun, do NOT pause to ask the human if you should continue. Do NOT ask 'should I keep going?' or 'is this a good stopping point?'. The human might be asleep. You are autonomous. The loop runs until the human interrupts you, period."*

   The cap is a termination condition, not an "ask the human" event. The loop stops when: cap hit, budget exhausted, plateau detected (10 iterations without significance-threshold improvement), guard violation, or manual interrupt. Nothing else.

These are why Karpathy's `autoresearch.py` is ~630 lines, not 6300. Complexity is the enemy of convergence.

## Five stages, in order

1. **Intake** - what, how measured, what can change, what can't regress, budget
2. **Triage** - is this problem autoresearch-shaped? (see `references/triage-checklist.md`)
3. **Fitness design** - build or validate the fitness function (see `references/fitness-design.md`)
4. **Mode selection** - pure / barbell / via negativa / inverted / human-in-loop (see `references/modes.md`)
5. **Loop + post-mortem** - scaffold, run, diagnose plateau if reached (see `references/anti-patterns.md` when diagnosing)

Skip stages only when the user explicitly says "I've done that, start the loop."

**Reference files map:**
- `references/triage-checklist.md` - Stage 2 (is this problem autoresearch-shaped)
- `references/fitness-design.md` - Stage 3 (the 7 requirements a fitness function must meet)
- `references/modes.md` - Stage 4 (pick one: pure / barbell / via negativa / inverted / human-in-loop)
- `references/anti-patterns.md` - Stages 3 + 5 + 6 (14 named failure modes)
- `references/plateau-ideation.md` - Stage 5/6 (what to propose when the loop plateaus)

Load each reference file on demand during the stage that needs it. Do not preload.

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
- `loop-driver.sh` and `iteration-prompt.md` from `templates/` (for autonomous runs)

### Drive the loop (autonomously)

Claude Code's interactive mode pauses between turns. To run the loop continuously without a human pressing enter each iteration, drive it from OUTSIDE the Claude Code session via a script. Each iteration is one fresh `claude -p` (non-interactive print mode) invocation that reads state from `goal.md` + `experiments/`, proposes one atomic change, runs fitness, commits or reverts, appends to `journal.md`, and exits.

**Three options, in order of simplicity:**

1. **Bash + `claude -p`** (recommended, simplest). Use `templates/loop-driver.sh` and `templates/iteration-prompt.md`. Run:
   ```bash
   ./loop-driver.sh --max-iter 50 --max-budget-usd 10
   ```
   Uses Claude Code's `-p` / `--print` mode, `--permission-mode acceptEdits` for tool autonomy, `--max-budget-usd` for a built-in dollar cap. State lives in git + files, not session memory. Each iteration is a fresh session reading the journal.

2. **Python + Anthropic SDK** - what Karpathy's original `autoresearch.py` does. Use when you need programmatic state tracking, richer plateau detection, or parallel experiments. More code, more control.

3. **Interactive / manual** - user approves each iteration in a single Claude Code session. OK for N ≤ 5. Tedious above that.

**Hard caps are mandatory.** Every driver MUST enforce:
- **Max iterations** - default 50, hard cap. Raise only with a written reason in `goal.md`.
- **Dollar budget** - via `claude -p --max-budget-usd`.
- **Wall-clock budget** - via `timeout` or driver-level check.
- **Plateau detection** - default 10 iterations without significance-threshold improvement → stop.
- **Guard violation** - immediate stop, no retries.

Any trigger writes `experiments/STOP` with a one-line reason and exits. Stage 6 post-mortem reads this file and produces the plateau diagnosis.

**What does NOT work:** Claude Code hooks (`Stop`, `PostToolUse`, `UserPromptSubmit`, `SubagentStop`). Hooks REACT to Claude's actions - they cannot inject new prompts that drive iteration. The loop driver MUST live outside the Claude Code session.

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

**Before declaring plateau, run the ideation workflow in `references/plateau-ideation.md`.** This is mandatory, not optional. Specifically:

1. Mine the last 10 reverts for pattern (axis + failure mode for each). Tradeoff reverts (primary lifted, guard broke) are especially rich - they reveal axes with slack that need compensating moves elsewhere.
2. Run the taxonomy coverage check. If fewer than ~6 of 8 axes have been touched with substantive changes, the loop is NOT plateaued - it has exhausted one corner of the search space. Propose on an untouched axis and continue.
3. Only when coverage is satisfied AND revert mining surfaces no untouched direction: invoke `/council` with the three structured prompts from `plateau-ideation.md` Move 3.
4. Only when all three are exhausted: declare plateau and pick a cause above.

"I ran out of ideas" is anti-pattern #13 (timid tweaks). The plateau-ideation workflow is how the skill converts that into a concrete next move instead of a stop.

**The plateau diagnosis IS the deliverable when the loop doesn't improve.** Foreground it, don't bury it.

### Escalation: invoke `/council` on a plateaued loop

When the loop plateaus and you own the mutable surface, the mode, and the fitness function, the failure is usually **invisible from inside the loop** - wrong sample size, unverified compliance, a metric that doesn't discriminate, confounded labels, or a mutable surface that no longer holds leverage. These are exactly the findings a multi-perspective review delivers cheaply in one pass.

Before switching modes or mutable surfaces, spend a single `/council` call. Canonical prompt:

> Goal, fitness, baseline, significance threshold, mode, last 10 journal lines - the loop has plateaued. What is the loop missing that an outsider would notice?

A council that agrees with your reading tells you the loop is genuinely stuck on the right problem. A council that disagrees usually names the specific failure mode from `references/anti-patterns.md` - which is exactly the plateau diagnosis you were about to struggle to produce alone.

This is different from anti-pattern #10 ("use council for architecture, not tactics"). Council here is a second-opinion tool on the loop itself, not an architecture substitute. On a real autoresearch run, a plateau-council review produced the two highest-leverage fixes (enlarge sample size, verify compliance) that the loop couldn't see from inside.

---

## Style rules for this skill

- Declarative: tell the user WHAT to check, not exact commands. The agent picks the command.
- Refuse gracefully and suggest alternatives when a candidate fails triage
- Keep the loop boring - creativity lives in triage and mode selection, not loop mechanics
- Git is the experiment log; `journal.md` is the narrative
- Use plain `-` hyphens, not em dashes
