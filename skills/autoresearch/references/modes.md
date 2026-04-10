# Autoresearch modes

Pick exactly one mode per mutable surface. The mode controls what the loop is allowed to propose, and how "keep or revert" works.

## Pure optimizer

The classical Karpathy loop. Small mutable surface, fast feedback, thin-tailed clean metric.

**How it works:**
- Propose one atomic change per iteration
- Run the fitness command
- Keep if metric improves by more than the significance threshold, revert otherwise
- No safety rails beyond the guard metric
- Run overnight or on a compute budget

**When to use:**
- Code benchmarks, compression, extraction accuracy
- ML model training and fine-tuning
- SQL query performance
- Test coverage
- Static analysis scores
- Sudoku solvers, compiler optimizations, kernel tuning

**When NOT to use:**
- Anything fat-tailed (sales, content virality, VC)
- Anything reflexive (prospects adapt, competitors adapt)
- Anything with slow feedback (weeks/months per iteration)

**Failure mode:** converges quickly, then plateaus. When it plateaus, run the post-mortem diagnosis in `anti-patterns.md`.

---

## Barbell

From Taleb. 85-90% of the system is immutable proven baseline. 10-15% is wild experiments. The loop is only allowed to propose changes inside the experimental zone.

**How it works:**
- Lock the proven core (brand voice, working template, current ICP, proven product copy)
- Declare a small experimental zone (a new subject line variant, a new channel, a new format, a new audience)
- Fitness is applied to the experimental zone only, with a rolled-up comparison against the proven baseline
- When an experiment wins by a large margin (and sustains that win across multiple evaluations), promote it into the baseline
- Most experiments fail. The occasional experiment that hits is the fat-tail upside the pure loop can never find.

**When to use:**
- B2B outbound (proven ICP + proven templates, experiment on new segments)
- Content marketing (proven voice + proven formats, experiment on new angles)
- Design (proven system + proven patterns, experiment on new variants)
- Anything reflexive where pure optimization converges to a brittle local optimum

**Why it works:**
- Protects against "training a better turkey" (Taleb). Pure optimization on a non-stationary domain finds a peak that collapses the moment the environment shifts.
- Captures fat-tail upside. One unexpected experiment win dominates all the small gains a pure loop could produce.
- Keeps shipping. The proven core runs in production while experiments happen at the margin.

**Allocation rule:** if an experiment can cost you more than the gain it would provide in the best case, it belongs in the experimental zone (capped at 10-15% of resources), not in the core.

---

## Via negativa

Subtractive loop. Instead of "what to add to improve," ask "what to kill to improve."

**How it works:**
- List every component / rule / step in the system
- Propose removing one per iteration
- Fitness check: does the system get cheaper, faster, simpler without getting worse on the primary metric or any guard?
- Keep the removal if yes, revert if no
- Continue until no removal is accepted

**When to use:**
- Legacy codebases with unknown dependencies
- Over-engineered agent prompts (30 rules, 15 examples, 5 sections)
- 40+ customer workflows that started diverging
- Tangled CI/CD pipelines
- Bloated configuration
- Any system where adding more hasn't helped and the user suspects complexity is the problem

**Why it works:**
- Addition has unbounded downside (new bugs, new dependencies, new failure modes) and bounded upside.
- Subtraction has bounded downside (you can always add it back via git revert) and unbounded upside (fragility removed compounds).
- "Stop doing the wrong thing faster" (Taleb).

**The invariant:** via negativa NEVER reduces the primary metric or violates a guard. It only removes what the system can survive without. If nothing can be removed without regression, the loop terminates - and that terminating state is the answer: "the system is already lean."

---

## Inverted

For imbalanced problems where there are far more negatives than positives. Instead of scoring "is this good," score "is this definitely bad."

**How it works:**
- Build a rejection filter, not a quality scorer
- Fitness = precision of rejection (did we reject only true negatives, and how many of them?)
- Everything that passes the filter goes to the next stage (human review, expensive pipeline, outreach, whatever)
- The loop iterates on the rejection rules, not the selection rules

**When to use:**
- Lead qualification where 95% of leads are clearly bad (the plateau council's recommendation for Onsa's ICP scorer)
- Resume filtering
- Spam / phishing detection
- Content moderation
- Any problem where the signal in the majority class is much stronger than the signal in the minority class

**Why it works:**
- The signal in the 95% negatives is enormous; the signal in the 5% positives is tiny.
- A rejection filter uses the big signal. A quality scorer drowns in the tiny signal.
- False positives in the filter (rejecting a good one) are cheap to recover from if the filter is conservative.

**Example:** instead of "score every lead 0-10 and chase the 8+," write rules that reject obvious no-fits (wrong industry, wrong title, wrong company size, wrong geography) and let outreach quality be the real filter on everything else. The autoresearch loop iterates on the rejection rules.

---

## Human-in-loop

Agent proposes. Human decides. No automatic commit.

**How it works:**
- Same loop structure as pure, but "keep or revert" is a human approval step
- Agent runs the fitness check and presents the diff + delta + explanation
- Human clicks yes/no (or writes a short note)
- Loop advances on approval, reverts on rejection
- Human can override the fitness metric ("the number is up but this isn't actually better")

**When to use:**
- Slow feedback (days per fitness evaluation - the human breaks the bottleneck)
- Irreversible actions (sent emails, deployed to production, customer-facing changes, published content)
- High-stakes fitness where a metric regression could cascade
- Domains where tacit knowledge matters (Taleb's green lumber problem)
- Research / genealogy / investigation workflows

**Why it works:**
- Retains the loop's compounding structure without letting the agent commit to decisions it can't undo
- Keeps tacit human judgment in the feedback loop
- Makes the agent a research assistant, not an autonomous optimizer

**Trade-off:** the agent is the bottleneck for proposing, the human is the bottleneck for deciding. If the human can't keep up, reduce the proposal rate. If proposals are consistently rejected, something is wrong with the fitness function or the mutable surface - stop the loop and re-plan.

---

## How to choose

| Signal from triage | Mode |
|--------------------|------|
| All green | Pure |
| Fat-tailed, reflexive | Barbell |
| Fragile, complex, over-engineered | Via negativa |
| Imbalanced classes (95%+ negatives) | Inverted |
| Slow feedback or irreversible actions | Human-in-loop |

## Combining modes

You CAN run two modes in parallel on the same system if the surfaces don't overlap.

Example: Onsa
- **Pure optimizer** on fitness extraction accuracy (code, fast feedback, clean metric)
- **Barbell** on the downstream outreach content (fat-tailed, reflexive)
- **Via negativa** on the 40+ customer workflow configurations (fragile, over-engineered)

You CANNOT use more than one mode on the same mutable surface in the same loop - the keep-or-revert logic becomes unintelligible.

## Escalation path

If pure hits a plateau, the typical escalation is:
1. Change the mutable surface (still pure, different target)
2. Switch to barbell (force exploration of distant variants)
3. Switch to via negativa (try removing instead of adding)
4. Refuse the loop and go back to Stage 2 triage - the problem may not be autoresearch-shaped at all
