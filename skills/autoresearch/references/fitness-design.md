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

---

## The exit question

Before starting the loop, the user must be able to answer:

> "If this metric goes from X to 1.5X, have we actually achieved the goal?"

If the answer is no, or "it depends," the fitness function isn't ready. Go back and fix it.

This is the question Karpathy meant by "what is your val_bpb?" The loop only works when this question has a crisp answer.
