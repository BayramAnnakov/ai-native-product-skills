# Anti-patterns

Failure modes that kill autoresearch runs. Call them out when you see them - either during triage, during fitness design, or when diagnosing a plateau in Stage 6.

## 1. Astrology chart with a JSON schema

The metric is arbitrary. Weights set by intuition, a proxy correlated with nothing real, composite scores that can't be validated.

**Smell:** Numbers exist, trends exist, but nobody can say "if this goes from 0.13 to 0.25 we have won."

**Fix:** Validate the metric against an outcome the user genuinely cares about (revenue, retention, measured speedup, human preference on a held-out set) before iterating. If the correlation is weak, redesign the metric.

**Attribution:** Taleb - "this is astrology with a JSON schema." From the plateau diagnosis of an ICP scorer whose F1 plateaued at 0.15 because the labels themselves were noisy and arbitrarily weighted.

## 2. Training a better turkey

The stationarity assumption is violated. The environment adapts, competitors adapt, models drift. What worked converges to what no longer works.

**Smell:** Wins from month 1 stop winning in month 3. Yesterday's "best variant" is today's average. The loop has to restart its baseline frequently.

**Fix:** Barbell mode. Protect a proven baseline, experiment at the margins, accept you will never fully optimize a non-stationary system.

**Attribution:** Taleb. The turkey is fed for 1000 days and builds a beautifully fit model of its environment - until Thanksgiving.

## 3. Green lumber fallacy

The metric optimizes decomposable features, but the real driver is tacit and non-decomposable.

**Smell:** The fitness function can be computed from text/data alone, but the actual goal depends on relationships, timing, trust, social graph, reputation, or other unmeasured features.

**Fix:** Interview people who achieved the goal recently. Ask what actually drove the outcome. If the real drivers aren't in the fitness function and can't be added, stop optimizing the fitness function and use a different approach.

**Attribution:** Taleb. The commodity trader who made fortunes on green lumber without knowing what "green" meant - the optimizable features weren't the operative ones.

## 4. A/B testing the wrong door

The downstream funnel is being optimized but the upstream funnel is broken. Message variants when the targeting is wrong. Conversion copy when the traffic is wrong. ICP scoring weights when the data source is wrong.

**Smell:** Every iteration is a small win, but the absolute numbers remain terrible. 0/7 conversions no matter which variant runs.

**Fix:** 5 Whys on the bottleneck before looping. Autoresearch only helps when you're optimizing the actual constraint, not a downstream symptom.

**Attribution:** Verna - "you're A/B testing the color of a door that leads to a room people don't want to stay in."

## 5. "Looks good" verification

Verification is subjective but dressed up as mechanical. An LLM judge with no rubric. A human who changes their mind between runs. A vibe-based acceptance.

**Smell:** The user can't produce the verification command when asked. The fitness function is a mental process, not an artifact.

**Fix:** Either formalize (rubric + seed + fixed corpus + committed prompt) or switch to human-in-loop mode. Don't pretend a vibe is a metric.

## 6. Local optimum lock-in

Pure optimizer converges quickly and then stalls. The loop has found a peak, but it's not the right peak.

**Smell:** Plateau - 10 iterations with no improvement. Proposed changes all fail to beat the current best. The metric at convergence is noticeably worse than what a human thinks is possible.

**Fix:**
1. Change the mutable surface (different files, different parameters, different abstraction level)
2. Switch to barbell to force exploration of distant variants
3. Reconsider whether the fitness function itself is capped at this value (anti-pattern #1)

**Attribution:** Karpathy's own framing - "you built a solid engine and pointed it at the wrong search space."

## 7. Confounded labels

The training labels are polluted by upstream factors. Lead quality labels reflect `lead_quality × message_quality × timing × sender`. Optimizing teaches the loop to game the confounds.

**Smell:** The loop finds "improvements" that look great on the fitness function but don't transfer to production. Held-out performance and production performance diverge.

**Fix:** Control confounds explicitly (hold messages / senders / timing constant when labeling), use an unconfounded label source, or switch metric entirely.

## 8. Via positiva fallacy

Believing every improvement requires adding something. Over-engineered systems that need subtraction get more complex instead.

**Smell:** The mutable surface only allows adding. The loop proposes "add rule X," "add check Y," "add example Z." Total complexity monotonically increases.

**Fix:** Via negativa mode. Propose removals. Most mature systems are too complex, not too simple.

## 9. Single metric tyranny

Collapsing a multi-objective problem into one number. "Just maximize X" when the real goal is "maximize X subject to Y, Z, brand safety, legal, customer experience."

**Smell:** Guard metrics are missing. One dimension is getting better while other dimensions are quietly getting worse. Users start complaining about things the primary metric doesn't capture.

**Fix:** Define guard metrics in Stage 3. A loop without guards is how you ship regressions.

## 10. Using the loop for architecture

The loop is a plumbing tool. It cannot discover "we should rebuild this with a different database," "we should serve a different customer," or "we should pivot from outbound to PLG." It can only optimize within an existing architecture.

**Smell:** The user expects autoresearch to answer a strategy question.

**Fix:** Use the council skill or a plan. Autoresearch for tactics, council for strategy. "Use it for the plumbing, never for the architecture" (Taleb).

## 11. Sample size theater

Declaring wins on fewer samples than the metric's noise floor would allow.

**Smell:** Fitness function runs on a few dozen examples. Run-to-run variance is larger than most claimed improvements.

**Fix:** Enlarge the corpus (pool archetypes, synthetic data, historical data). Run multiple seeds per fitness evaluation. If the sample can't be enlarged enough to distinguish a real win from noise, the problem isn't ready for the loop.

## 12. Premature loop

Starting the loop before Stage 3 is complete. The fitness function is half-built, the baseline is "I don't remember," the guards are missing, the sanity check hasn't been run.

**Smell:** The user is impatient and wants the loop to start "and we'll figure out the rest as we go."

**Fix:** Refuse. Kindly. Every minute spent on fitness design before the loop saves hours of chasing noise during the loop. This is the single highest-leverage discipline in autoresearch.

## 13. Timid tweaks on a plateau

Not "more iterations" - that part is fine. The problem is running 500 more 1-character prompt tweaks hoping one of them breaks the plateau. Tiny-scope experiments on a flat surface overfit to noise and burn budget producing nothing.

**Smell:** Last 10-20 iterations all produced deltas smaller than the significance threshold. Each new experiment is a 1-2 word tweak to the same spot. The journal reads like background noise.

**Fix:** Karpathy's exact prescription when stuck, quoted verbatim from `program.md`:
> *"If you run out of ideas, think harder - read papers referenced in the code, re-read the in-scope files for new angles, try combining previous near-misses, try more radical architectural changes."*

Escalate the AMBITION of changes, not the iteration count. The loop keeps running; what changes is the boldness of each experiment. If radical changes also plateau, then change the mutable surface entirely. The loop runs until the human interrupts or the hard cap fires - but every iteration should be trying a genuinely different idea, not a cosmetic edit.

**Worth emphasizing because people get it backwards:** the simplicity criterion (keep deletions even at zero fitness gain) is NOT "make small, timid changes." It is "when weighing complexity against fitness, simplifications are always keepers." Bold, radical experiments are still welcome - they just need to justify their complexity cost with a matching fitness gain.

**Attribution:** Karpathy's `program.md` NEVER STOP rule + simplicity criterion, plus the plateau council's "prompt text search is exhausted" observation (all panelists flagged this within ~15 iterations of the ICP scorer run).

---

## How to use this file

Load this file when:
1. Stage 2 triage surfaces a concern and you need to name which anti-pattern applies
2. Stage 3 fitness design is revealing a specific pathology
3. Stage 6 post-mortem needs to diagnose a plateau - match the symptoms to a pattern, produce the diagnosis as the deliverable

**Do not hide these from the user.** Naming the anti-pattern IS the deliverable when the loop isn't working. The plateau diagnosis has more value than the loop results in those cases.
