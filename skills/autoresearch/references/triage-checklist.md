# Triage checklist - is this problem autoresearch-shaped?

Score each dimension green / yellow / red. All green → pure optimizer. Any yellow → adapt the mode. Any red → adapt or refuse.

This is the highest-leverage stage in the whole skill. Most autoresearch failures are candidates that should have failed triage but were allowed through.

## 1. Feedback latency

How long from "make a change" to "know if it worked"?

- **Green** - minutes or hours. The loop can run many iterations per session. Examples: code benchmarks, token counts, bundle size, test pass rate, static analysis scores, ML model eval on held-out set.
- **Yellow** - hours to a day. Feasible but slow. Examples: content readability, LLM-judge scoring on large corpora, scraping pipelines with rate limits.
- **Red** - days, weeks, or months. The loop's horizon mismatches the signal. Examples: sales response rates, product retention, compounding revenue, SEO rankings, customer NPS.

If red: human-in-loop or barbell mode. Pure optimization on red-latency signals converges on noise because the fitness function can't produce enough signal in the iteration window.

## 2. Metric mechanicality

Is the metric extractable by a command, or does a human need to judge it?

- **Green** - deterministic command outputs a number. Examples: `pytest --cov`, benchmark wall-clock, `wc`, held-out accuracy, token count, latency p99.
- **Yellow** - LLM judge with a rubric, fixed seed, and fixed corpus. Reproducible if seeded, but expensive and drifts with model updates. Acceptable if the rubric has been validated against human judgment.
- **Red** - subjective human quality. "Does this feel right?" Not a fitness function. Not yet.

If red: Stage 3 is where the real work lives. Either build a mechanical proxy or refuse the loop.

## 3. Tail shape

Is the payoff thin-tailed (small wins compound) or fat-tailed (one big hit dominates all other outcomes)?

- **Green** - thin-tailed, stationary. Small improvements compound linearly. Examples: code performance, extraction accuracy, compression ratio, database query time.
- **Yellow** - mixed. Most gains are thin-tailed but tail events matter. Examples: landing page conversion, ad creative, retention funnels.
- **Red** - fat-tailed, reflexive. One whale deal, one viral post, one unpredictable event dominates all others. Examples: B2B enterprise sales, content virality, VC fundraising, creative breakthroughs.

If red: barbell mode is mandatory. Pure optimization on fat-tailed domains "trains a better turkey" (Taleb) - converges to a brittle local optimum that breaks when the environment shifts or adapts.

**Self-play note:** when the "opponent" or evaluator is the same LLM as the agent being optimized, behavior is mildly reflexive - the opponent's distribution shifts with prompt formatting (different system-prompt lengths, verbosity, persona cues can shift response patterns independent of strategy content). Score tail shape as yellow even when the primary metric looks thin-tailed. The usual mitigations: hold the opponent's prompt strictly fixed across iterations, use a larger corpus so reflexive drift averages out, or switch to barbell with a locked minimalist core that experiments at the margin.

## 4. Sample size vs noise

For one fitness evaluation, how many independent samples contribute? Is that enough to distinguish a real delta from noise?

- **Green** - thousands of samples per eval. Differences are detectable at small effect sizes.
- **Yellow** - 50 to 500 samples. Power analysis needed. Likely need bigger deltas to declare a win with confidence.
- **Red** - fewer than 50 samples, or the sample is a single event (a deal, a launch, a campaign). The metric is a coin flip with narrative attached.

Sample size failure is the #1 killer in real autoresearch runs. Fix it before looping. Strategies:
- Pool across customer archetypes or domains
- Use a fixed large corpus for the eval even if production runs on a small one
- Use synthetic data or model-based eval to multiply samples
- Run each fitness evaluation with multiple seeds and report the distribution

If you can't get above red, the problem isn't ready for the loop. Do not start it.

## 5. Surface locality

How local is a typical productive change?

- **Green** - atomic diffs. One file, one function, one parameter. Keep-or-revert works cleanly.
- **Yellow** - coordinated multi-file changes. Still revertable with git, but harder to reason about which change caused which delta.
- **Red** - architectural / system redesign. Not iteratable. Each change is a bet, not an experiment.

If red: this isn't a loop, it's a design decision. Use the council skill or a plan, not autoresearch.

---

## Scoring examples

| Candidate | Latency | Mechanical | Tail | Samples | Surface | Verdict |
|-----------|---------|-----------|------|---------|---------|---------|
| Code bundle size | G | G | G | G | G | Pure optimizer |
| SQL query wall-clock | G | G | G | G | G | Pure optimizer |
| LLM scorer prompt on fixed corpus | G | Y | G | Y | G | Pure with care |
| Extraction accuracy on labeled set | G | G | G | Y | G | Pure |
| Landing page copy A/B | Y | G | Y | Y | G | Barbell |
| Cold outbound subject line | R | Y | R | R | G | Refuse or barbell |
| Cold outbound targeting (ICP) | Y | G | Y | Y | G | Pure with care |
| Customer workflow redesign | R | R | R | R | R | Refuse - use council |
| Sudoku solver speed | G | G | G | G | G | Pure optimizer |
| Family history research strategy | Y | Y | G | G | Y | Human-in-loop |
| Product retention experiment | R | Y | Y | Y | Y | Barbell or human-in-loop |
| Security hardening (CVE count) | G | G | G | G | G | Pure optimizer |
| Content readability score | G | G | Y | G | G | Pure |
| LLM prompt (small model, stochastic eval) | G | G | Y | Y | G | Pure with care - force n ≥ 50, run compliance audit |
| LLM prompt (frontier model, thinking mode) | G | G | G | Y | G | Pure |
| Agent-vs-agent self-play score | G | G | Y | Y | G | Pure with care - lock opponent prompt, enlarge corpus |

## The refusal template

When a candidate fails triage:

> This candidate isn't autoresearch-shaped because [dimension X is red: specific reason]. If I run the loop here, it will converge to a local optimum of the wrong thing - efficiently. Here's what to do instead:
>
> 1. [Specific alternative that addresses the blocker]
> 2. [A smaller, better-shaped sub-problem that IS autoresearch-shaped]
> 3. [Another mode that might work - barbell, via negativa, human-in-loop]
>
> Want me to look at one of these instead?

Refusing is the correct output. Do not start the loop to be helpful.

## Cross-dimension patterns

- **All red:** not a candidate. Use council or 5 Whys.
- **Latency + tail red, others green:** classic sales / content / marketing. Use barbell.
- **Metric red, others green:** build a mechanical proxy in Stage 3, or use LLM-judge with validated rubric.
- **Samples red, others green:** grow the corpus (pool, synthetic, historical) before looping.
- **Surface red, others green:** use via negativa on subcomponents instead of redesigning the whole.
- **One yellow, rest green:** proceed with the caution noted in the relevant mode.
