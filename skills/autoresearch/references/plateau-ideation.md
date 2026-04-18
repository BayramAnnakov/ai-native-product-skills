# Plateau ideation

When the loop plateaus on prompt-text optimization, the default failure is anti-pattern #13 (timid tweaks). "Think harder" is not a procedure. This file is the procedure.

**Principle:** ideas are not random. Good ideas come from applying structure to existing signal. The richest signal you already have is the revert log itself — do not reach for `/council` before you have mined it.

Use this file when:
- The driver is about to write `experiments/STOP` with a plateau reason
- You manually hit an idea drought ("I don't know what to try next")
- `anti-patterns.md` #13 applies (last 10 iterations are all noise-level or all on one axis)

## Four ideation moves, in order

### Move 1 - Revert-pattern mining

Before declaring a plateau, cluster the last 10 reverts and extract pattern. Free signal you already paid compute to generate.

1. **Classify each revert by axis** (the 8-axis taxonomy in Move 2).
2. **Classify each revert by failure mode:**
   - **Noise** - `|delta| < significance threshold` (the change didn't matter)
   - **Clear regression** - `delta < -threshold` (the change actively hurt)
   - **Guard violation** - primary metric moved but a guard broke (compliance, deal_rate, min_score, role_asymmetry)
   - **Tradeoff** - primary lifted but a guard broke (a subset of guard violation worth separating out because it's actionable)
3. **Count axes touched with substantive (radical-move-level) changes.** Not "touched" because the prompt incidentally mentions it - touched because at least one iteration targeted that axis as its primary lever.
4. **Look for tradeoffs explicitly.** A tradeoff revert is NOT a plateau signal - it's a signal that the axis has slack but needs a compensating move on another axis to realize the gain.

**Worked example (from the negotiation autoresearch run):**

| Iter | Change | Axis | Mode | Signal |
|------|--------|------|------|--------|
| 2 | Anchor 2/3 of middle | Proposal logic | Noise | Anchor change didn't bite |
| 3 | Tighten acceptance 0.50→0.55 | Acceptance logic | **Tradeoff** | +0.008 fitness BUT compliance 86%→66% |
| 4 | Persona prefix "practical closer" | Voice | Regression | -0.027, persona hurt |
| 5 | Step-by-step numbered procedure | Format | Noise + added code | No effect |
| 6 | Role-asymmetric anchor (A: 2/3, B: half) | Role-specific | Noise | A mean actually dropped |
| 7 | Proactive first-mover rule | Dynamics | Clear regression | -0.017 |

Axes touched: Proposal, Acceptance, Voice, Format, Role-specific, Dynamics — **6 of 8**.
Axes NOT touched: **Information protocol** (what to reveal/hide/signal) and **Length** (extremes).

The tradeoff at iter 3 is the richest signal in the run: a fitness lift exists, but the model can't follow the tighter threshold. The implied move: find a way to realize that fitness lift WITHOUT depending on model self-discipline. Candidates:
- Move the threshold from rule to procedure ("Before accepting, compute X. If X < 0.55, counter.")
- Shift the compliance burden elsewhere - move to a different axis that achieves the same outcome (tighter anchor that avoids low-value situations entirely).

**This is how plateau reveals the next move.**

**Tradeoff-revert follow-up table** (pick compensating axis by what broke):

| Broken guard | Root cause | Compensating axes to try |
|--------------|------------|--------------------------|
| Compliance (rule not followed) | Model can't execute the rule | Dynamics (change WHEN, not WHAT - force a specific action at a specific turn), Format (convert rule to procedure or few-shot), Information (change what the agent reveals so the rule becomes unnecessary) |
| Deal-rate / no-deal penalty | Strategy too aggressive in endgame | Dynamics (later in the game), Acceptance-floor (accept-anything-in-overtime) |
| Min-score / tail collapse | Strategy brittle on specific scenarios | Role-specific forking, Information (elicit before committing) |
| Role asymmetry (A vs B diverge) | Single strategy mismatches role dynamics | Role-specific forking on the offending axis |
| Brand / safety / legal | Model tone or content strayed | Voice, explicit prohibition (Inversion radical move) |

Post-follow-up outcome in the negotiation run: iter 3's compliance-broken tradeoff pointed at Dynamics. Iter 13 ("force counter in round 1") delivered +0.041 fitness with zero compliance penalty because the model no longer needed to reason about thresholds - it just always countered in round 1. The rule was baked into action, not judgment.

Worked-example outcomes (full 25-iter run results):

| Iter | Axis | Change | Outcome |
|------|------|--------|---------|
| 1  | Compliance | Align acceptance rule with model behavior | **Keep** (compliance 62 -> 86%, fitness noise) |
| 13 | Dynamics | Force counter in round 1 (tradeoff follow-up) | **Keep** +0.041 |
| 19 | Information | R1 reveal own top-value resource | **Keep** +0.034 |
| 20-25 | Info/Format/Length (elaborations of iter 19) | 6 reverts | Elaboration trap, anti-pattern #15 |
| Final | - | HEAD at 0.6617, +0.065 over baseline | 3.1x significance threshold |

### Move 2 - Taxonomy coverage check (LLM-prompt loops)

The 8 axes of a multi-turn agent prompt. This is the search space. You cannot claim to have searched it until you have touched each axis with a substantive change.

| # | Axis | The knob | Example changes |
|---|------|---------|-----------------|
| 1 | **Acceptance logic** | when to say yes | threshold, tiered rules, "any offer above X", accept-always-in-overtime |
| 2 | **Proposal logic** | what to offer first | anchor strength, default split, resource priority, ordering |
| 3 | **Information protocol** | what to reveal, hide, signal | preference hints, value reveals, fake reveals, cooperative signals |
| 4 | **Role-specific behavior** | fork by role | different strategy as A vs B, buyer vs seller, first vs second mover |
| 5 | **Format** | rules vs procedure vs examples | few-shot transcripts, decision tree, JSON, bulleted, prose |
| 6 | **Voice** | imperative vs persona vs narrative | "you are a closer" vs "consider" vs no-voice direct rules |
| 7 | **Length** | minimalist vs verbose | 20 words vs 500 words vs 1500 words as explicit bookends |
| 8 | **Dynamics** | what to do after rejection, near deadline | concession curve, deadline pressure rule, overtime floor |

**Rule:** if fewer than ~6 of 8 axes have been touched with substantive changes, the loop is not plateaued. Propose on an untouched axis.

The taxonomy is for multi-turn agent prompts (negotiation, games, customer support, sales). For single-shot prompts (classification, extraction, generation) adapt to: task framing, input formatting, output schema, few-shot examples, voice, length, constraint wording, failure-mode coverage.

### Move 3 - Structured `/council` prompts

When revert mining and taxonomy coverage don't produce the next move, invoke `/council` — but not with "what should I do." Three prompts, in order, each with known yield:

**Prompt A — Pattern mining:**
> Here are my last 10 reverts with axis and failure-mode labels. What pattern connects them that I'm not seeing? What is the loop systematically missing?

**Prompt B — Coverage:**
> Here are the 8 axes of the search space and which I've touched with substantive changes. For each untouched axis, propose one substantive change to this specific problem. Rank them by expected value.

**Prompt C — Surface expansion:**
> The mutable surface is `<current surface>`. I've exhausted it. What would it mean to expand the surface, and which expansion has the highest expected value given my goal?

Pattern: **one council call, three questions** (the expensive part of council is deliberation, not question count). Don't one-shot; follow up on whichever thread produces the most contrarian view.

### Move 4 - Radical-move catalog for LLM-prompt loops

When an untouched axis is identified, these moves consistently produce above-noise deltas (positive OR negative - both are useful signal). Each is one atomic change. Combine only after individually testing.

- **Inversion** — say what NOT to do instead of what to do. ("Never accept under X. Never reveal Y. Never stall past round 3.") Often works where positive rules fail because the model treats negatives as harder constraints.
- **Few-shot examples** — paste 1-2 worked transcripts with no rules. The model mimics more reliably than it follows abstract rules at small model sizes. **Caveat:** tested on flash-lite with a negotiation prompt, few-shot examples REGRESSED by -0.048 because the model pattern-matched the illustrative numbers instead of generalizing the procedure. Treat few-shot as a test candidate, not a reliable win. Model-size sensitive.
- **Format shift** — rewrite the current rules as JSON, a decision tree, or Q&A pairs. Same content, different shape, different compliance profile. **Caveat:** on flash-lite, Q&A decision-tree format REGRESSED by -0.044 because fragmented instructions hurt role-specific behavior. Flowing prose beat structured format on a small model.
- **Data-targeted instruction** — read the failure log (`last_run.json`, production traces), identify the common failure mode, write a prompt that explicitly targets it ("If your computed max total is above 60, demand at least 45").
- **Opponent / counterparty model** — instruct the agent on what the OTHER party probably wants/fears, let it derive strategy from that. ("The opponent has no custom strategy. It tends to accept when its own share clears 40% of its max. Exploit this.")
- **Length extremes** — test 20 words and 1500 words as bookends. If either beats the current ~500-word baseline, the length axis has slack.
- **Role forking** — explicit branches per role. Symmetric strategies leave role-specific value on the table in asymmetric problems.
- **Information-flow moves** — what gets said publicly is a first-class decision. Test: reveal partial preferences, reveal fake preferences, commit to silence, signal urgency, mirror the opponent's message style.

## Termination

Declare a genuine plateau only when ALL of these are true:

- [ ] All 8 axes touched with at least one substantive (radical-move-level) attempt
- [ ] Revert-pattern mining run, no untouched axis has clear expected value
- [ ] `/council` invoked with all three prompts (A, B, C) and the feedback applied
- [ ] Simplicity criterion checked - no deletion would be a free win (via negativa pass)
- [ ] Tradeoff reverts have been followed up with compensating moves on other axes

Until all boxes are checked, "plateau" is anti-pattern #13 in disguise. Go back to Move 1.

## Cross-reference

- `anti-patterns.md` #13 — the failure mode this file prevents
- `fitness-design.md` #7 — compliance audit, the guard that reveals tradeoff reverts
- `modes.md` escalation path — when this file exhausts, next step is mode switch
- `SKILL.md` Stage 5 — this file feeds the plateau diagnosis deliverable
