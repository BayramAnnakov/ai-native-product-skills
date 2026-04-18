# Fitness function design

Autoresearch dies here. Not in the loop mechanics - in the fitness function. This is the single highest-leverage stage of the whole skill. Budget real time for it.

## The six requirements

A fitness function is ready when ALL of these are true:

### 1. Callable as a command

`./fitness.sh`, `python eval.py`, or equivalent outputs a number. Not "I look at it and decide." Not "the team agrees." Not "I run these five things and weigh them in my head."

If the user is building a subjective rubric, wrap it in an LLM-judge with:
- A fixed prompt (committed to git)
- A fixed seed
- A fixed corpus of inputs
- A deterministic output parser

A wrapped LLM judge is acceptable. A vibe is not.

### 2. Runs on a fixed corpus with fixed seeds

The input set doesn't change between iterations. Random sampling, live data, and new eval sets break comparisons. The same inputs go in every run so that output differences reflect the change under test and nothing else.

If the production system runs on live data, that's fine - the fitness function runs on a frozen snapshot separately.

### 3. Baseline recorded

Run the fitness function on the current state of the system BEFORE the first iteration. Write the number and the date to `baseline.json`. Every experiment is measured against this.

```json
{
  "metric": 0.131,
  "date": "2026-04-09",
  "corpus": "labeled_leads_v3.jsonl",
  "corpus_size": 851,
  "seed": 42,
  "command": "python eval.py --seed 42 --corpus labeled_leads_v3.jsonl"
}
```

### 4. Significance threshold defined

Any delta smaller than the threshold is noise. Set it by:
- Run the fitness function 5 times without changing anything
- Compute the standard deviation of those runs
- Significance threshold = 2 × std (roughly - tighter for expensive evals, looser for noisy ones)

Record this in `baseline.json`. Every "keep" decision checks the delta against this threshold.

### 5. Sanity check done

Score known-good examples and known-bad examples by hand. Does the metric agree with your ground truth? 

If the metric ranks a known-bad above a known-good, the metric is wrong. Do not start the loop.

Example: if you're optimizing an ICP scorer, run it on 3 of your actual paying customers and 3 known no-fit prospects. Paying customers should score high, no-fits should score low. If they don't, you're about to optimize a broken metric.

### 6. Guard metrics defined

At least one "must not regress" metric beyond the primary. Examples:
- Primary: latency → Guard: error rate, p99, memory
- Primary: conversion → Guard: brand safety score, unsubscribe rate
- Primary: model accuracy → Guard: worst-case bucket performance, inference cost
- Primary: extraction speed → Guard: accuracy

A loop without guards is how you get faster code that crashes, cheaper leads that don't buy, or "engaging" content that embarrasses you.

### 7. Compliance audit (LLM-prompt loops only)

When the mutable surface is a prompt steering an LLM, verify the model actually follows the prompt before optimizing it. The prompt written is not the prompt followed.

- Sample 5-10 traces from the baseline run
- For each concrete rule in the prompt (acceptance thresholds, banned phrases, role-specific behavior, required outputs), check whether the model honored it
- If compliance is below ~70%, the prompt text is decorative. Editing words the model is already ignoring moves the score on noise, not on prompt content
- Fix before iterating, not during:
  - Shorten and simplify - small models (flash-lite, nano, haiku-class) cannot do if/else at temperature ≥ 0.7 in a single forward pass
  - Replace abstract rules with worked examples or persona framing (the model mimics more reliably than it reasons)
  - Move hard rules into the scaffolding (schema constraints, tool signatures, post-hoc filters) so the model cannot violate them even when it ignores the prompt

When compliance is unverified, the loop optimizes the wrong object. See anti-pattern #14.

---

## Stochastic evaluator variance handling

When the fitness function itself is stochastic (LLM temperature, simulated opponent, randomized environment), the noise floor dominates everything else.

- Fix seeds for the **corpus** (which examples run). Accept randomness in the **evaluator** (temperature, opponent stochasticity). Never average across both sources without separating them.
- Significance threshold = 2 × standard error of the mean, not 2 × std of individual samples. With per-sample std of 0.2 and n=10, SE is ~0.063 - no plausible small improvement beats it. At n=50, SE is ~0.028. Growing the corpus is almost always higher-leverage than a cleverer search.
- For borderline wins (delta between 1× and 2× SE), re-run with a different seed tuple before keeping. Cheap insurance against noise-induced drift.
- Prefer a larger fixed corpus over more seeds of a small corpus. The variance reduction is the same in aggregate, but a single fixed corpus keeps per-iteration debugging tractable.
- Report the **tail** (min, p10) alongside the mean when the metric has a cliff (no-deal penalty, refund trigger, safety violation). A 0.60 mean with min 0.46 is a different strategy from a 0.60 mean with min -0.50.

**Rule of thumb:** most LLM-prompt autoresearch failures are fitness-function failures wearing a prompt-engineering mask. If your per-sample std is 0.2 and your corpus is 10, no amount of prompt cleverness can beat the noise floor.

---

## Common failures

### Proxy metric trap

The metric is easy to compute but doesn't correlate with the real goal.

- "Engagement" → not revenue
- "Reply rate" → not qualified meetings
- "Test pass rate" → not correctness (tests can be wrong)
- "LLM judge score" → not human preference (unless validated)
- "Accepted connection" → not buying intent

**Fix:** Before the loop, correlate the proxy with the real goal on historical data. If the correlation is weak (r² below ~0.3), find a better proxy or reject the whole approach.

### Arbitrary weights dressed as measurement

Composite score with weights set by intuition. "Accepted connection = 0.3 positive, reply = 0.7, meeting = 1.0." Nobody can say why those exact numbers.

**"This is astrology with a JSON schema."** (Taleb)

**Fix:** Either validate the weights against downstream outcomes (do 0.3-weighted leads convert at 0.3× the rate of 1.0-weighted leads in reality?), or simplify to a binary metric (did it convert, yes or no).

### Confounded labels

The training labels are polluted by upstream factors. Example: lead quality labels are actually labels of `lead_quality × message_quality × timing × sender`. Optimizing on these teaches the loop to game the confounds.

**Fix:** Control confounds explicitly (hold message/sender/timing constant), use an unconfounded label source, or switch to an unconfounded proxy.

### Non-stationary metric

What worked last month doesn't work this month. Prospects adapt, competitors adapt, models drift, SEO algorithms change.

**Fix:** Either (a) recompute the baseline frequently and accept the loop runs in batches, (b) switch to barbell mode, or (c) refuse - non-stationary domains are a bad autoresearch fit for pure optimization.

### Sample size below power threshold

Fitness varies so much run-to-run that you can't distinguish a real improvement from noise.

**Fix:** Grow the corpus. Pool across archetypes. Use synthetic data. Run more seeds and average. If none of that works, the problem isn't ready for the loop.

### "Looks good" verification

Subjective check dressed up as mechanical. "The LLM judge said it's better" without a rubric, seed, and fixed corpus is not mechanical. "The team voted" is not mechanical.

**Fix:** Either formalize (rubric + seed + fixed corpus + committed prompt) or admit it's subjective and use human-in-loop mode.

### Single metric tyranny

Collapsing a multi-objective problem into one number, when the real goal is "maximize X subject to Y, Z, brand safety, legal, customer experience."

**Fix:** Define guard metrics. The primary is the scalar; the guards catch regressions elsewhere.

---

## Worked examples

### Good fitness: code bundle size

- Command: `npm run build && stat -f%z dist/bundle.js`
- Corpus: the repo at HEAD
- Baseline: 420KB
- Significance: ±1KB (2× measurement noise from 5 runs)
- Sanity check: deleting a known dead file reduces size as expected
- Guard: all tests pass, no type errors

### Good fitness: ICP scorer on labeled leads

- Command: `python eval.py --corpus labeled_leads.jsonl --seed 42 --metric f1`
- Corpus: 851 hand-labeled leads, frozen
- Baseline: F1 = 0.131
- Significance: 0.02 from variance across 5 seeds
- Sanity check: known paying customers score ≥ 8/10; known no-fit score ≤ 4/10
- Guard: no category of lead collapses to zero (distribution check)

### Good fitness: sudoku solver speed

- Command: `cargo bench --bench solve -- --quick`
- Corpus: 10,000 puzzles at varying difficulty
- Baseline: 820ms total
- Significance: ±5ms from run variance
- Sanity check: solver still produces correct solutions for all puzzles
- Guard: correctness on an easy and a hard test set

### Bad fitness: "content engagement"

- "Engagement" isn't a command. No fixed corpus. No baseline. No significance threshold. Is a "good" tweet actually ranked higher than a "bad" tweet by the metric? If you can't answer these, it's not a fitness function. Build one or refuse.

### Bad fitness: "does this feel professional"

- Pure subjective. Must be wrapped in a rubric-driven LLM judge with fixed seed, or switched to human-in-loop mode. Until then, the loop cannot run.

### Good fitness: LLM-prompt optimization (negotiation case study)

Canonical Karpathy-style use case - a single-file prompt steers an LLM agent against a scored benchmark.

- **Mutable surface:** `strategy.txt` (one file, ≤2000 chars), read into the agent's system prompt every game
- **Command:** `bash evaluate.sh` - runs 50 negotiation games (25 as player A, 25 as B) against a baseline opponent at seed 42, prints `mean_score`, `std_error`, `deal_rate`, `mean_as_A`, `mean_as_B`, `min_score`
- **Corpus:** fixed game scenarios (pools + valuations) drawn from seed 42, n=50. Frozen across iterations.
- **Baseline:** mean 0.60, deal_rate 1.00, SE 0.015 (from 5 repeat runs of the full n=50 eval - NOT 5 runs of n=10, which gave SE 0.032 and made keep/revert a coin flip)
- **Significance threshold:** ±0.03 (2× SE). Borderline wins (0.015-0.030) require a second seed before keeping.
- **Sanity check:** score the shipped example prompts (`cooperative.txt`, `aggressive.txt`). They must rank differently. If they don't, the metric doesn't discriminate strategy content from noise and the loop cannot start.
- **Compliance audit (req #7):** open 5 game transcripts. For each: does the agent follow the acceptance threshold written in the prompt? Does it leak per-unit point values in public messages despite a "never reveal" rule? If compliance is below 70%, rewrite the prompt shorter / more concrete before iterating - prompt-text search on a model that ignores the prompt is pure noise chasing.
- **Guards:**
  - `deal_rate` must stay at 1.00 (each no-deal costs -0.5, dominating small mean gains)
  - `min_score` must stay above -0.3
  - Role-symmetry: `abs(mean_as_A - mean_as_B)` stays below 0.10. A strategy that scores 0.70 as A and 0.35 as B only works from one seat and is brittle in deployment.

**Lesson from the original run:** four experiments were run at n=10 before the `/council` review caught that SE was 0.032 - bigger than any claimed improvement. The highest-leverage change was not a smarter prompt; it was moving the evaluator from n=10 to n=50. If this fitness-design checklist had been followed in Stage 3, those four experiments would have been the fitness-design work, not the research.

---

## The exit question

Before starting the loop, the user must be able to answer:

> "If this metric goes from X to 1.5X, have we actually achieved the goal?"

If the answer is no, or "it depends," the fitness function isn't ready. Go back and fix it.

This is the question Karpathy meant by "what is your val_bpb?" The loop only works when this question has a crisp answer.

**For LLM-prompt loops, add a second exit question:**

> "If I hand the model the 'winning' prompt and read 5 transcripts, is the model visibly doing what the prompt says - or is the prompt decorative?"

If decorative, you are optimizing a caption, not a behavior. Rewrite the prompt or move the rules into the scaffolding before iterating.
