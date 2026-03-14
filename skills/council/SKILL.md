---
name: council
description: Multi-perspective AI council - get 3-5 expert viewpoints on any product question, with debate and synthesis. Use for strategic decisions, competitive analysis, feature prioritization, or any question where multiple perspectives improve the outcome.
---

# Multi-Perspective Council

You are orchestrating a panel of AI expert personas to evaluate a question from multiple angles. The goal is adversarial synthesis - diverse perspectives that challenge each other, not consensus that papers over disagreements.

## How It Works

The user provides a question or topic via `$ARGUMENTS`. You simulate a council of expert personas, each providing an independent evaluation, then synthesize their views - highlighting both agreement AND disagreement.

## Before Starting

1. Read CLAUDE.md and any .claude/rules/ files for product/team context. **Extract a 3-5 sentence context summary** that you will pass to each sub-agent (product, market, team size, key constraints, current situation).
2. If no context exists, ask: "What's your product/company and who are your customers?" (one question only). If the answer is too vague (less than 2 sentences), push back: "I need a bit more context to give you specific advice. What market are you in and what's the key decision you're facing?"
3. Determine the question type to select appropriate personas:
   - **Strategic decision** → Business strategist, Customer advocate, Devil's advocate
   - **Competitive analysis** → Market analyst, Customer researcher, Contrarian
   - **Feature prioritization** → User advocate, Technical feasibility, Business impact
   - **Go-to-market** → Growth expert, Positioning specialist, Target buyer persona
   - **Build vs buy / Technology** → Pragmatic engineer, Business case analyst, Risk assessor
   - **Hiring / Team** → People leader, Finance lens, Culture advocate
   - **Pricing / Monetization** → Revenue strategist, Customer willingness advocate, Competitor analyst
   - **General** → Optimist, Pessimist, Pragmatist

## The Council Process

### Step 1: Select the Panel (automatic)

Choose 3-5 personas based on the question type. For each persona, define:
- **Name and role** (use real industry expert archetypes, e.g., "Growth Strategist (Elena Verna-style)")
- **Their lens** (what they optimize for)
- **Their known bias** (what they tend to over-weight)

Present the panel to the user:
> "I've assembled a council of [N] perspectives for your question. Here's who's at the table:"
> [Table: Name | Lens | Known bias]

### Step 2: Independent Evaluations

**Preferred: Use sub-agents** for truly independent perspectives (each sub-agent has its own context window, preventing groupthink). Spawn them in parallel when possible.

**Fallback: If sub-agents are unavailable** (Desktop app, token limits, or user preference), generate each evaluation independently by completing one fully before starting the next. Explicitly avoid letting earlier evaluations influence later ones - treat each as if written by a different person.

For each persona, use this evaluation prompt (either as sub-agent instruction or as your own generation frame):
```
You are [PERSONA NAME], evaluating this question: "[USER'S QUESTION]"

Context about the product/team:
[PASTE THE 3-5 SENTENCE CONTEXT SUMMARY FROM STEP 0]

Your lens: [THEIR LENS]
Your known bias: [THEIR BIAS]

Provide your independent evaluation:
1. Your verdict (1-2 sentences, take a clear position - no hedging)
2. Your reasoning (3-5 bullet points, grounded in the specific context above)
3. What everyone else will miss (your unique angle that others won't see)
4. The biggest risk if they follow YOUR advice (intellectual honesty)
5. Rate: [relevant scale, e.g., Build/Don't Build, 1-10, or Go/No-Go]
```

Collect all evaluations before proceeding to the debate.

### Step 3: The Debate

Present all evaluations side-by-side, then highlight:
- **Where they AGREE** (high-confidence signal)
- **Where they DISAGREE** (this is where the real insight lives)
- **The most surprising perspective** (the one the user probably didn't expect)

For the biggest disagreement, present both sides:
> **The Key Tension:**
> [Persona A] says: "[their position]"
> [Persona B] counters: "[their counter-position]"
> Why this matters: [what the disagreement reveals about the decision]

### Step 4: Synthesis

Produce a final synthesis that:
1. States the consensus recommendation (if one exists)
2. Names the key insight that emerged from DISAGREEMENT
3. Lists what to do now, what to defer, and what to kill
4. Flags what needs real-world validation (not just AI opinion)

## Output Format

Save as `council-[topic-slug].md` with this structure:

```markdown
# Council: [Topic]
Date: [today]
Panel: [N] perspectives

## The Panel
[Table of personas]

## Verdict Matrix
[Quick summary table: Persona | Verdict | Key quote]

## Key Agreements
[Bullet points]

## Key Disagreements
[The tensions, with both sides presented]

## Synthesis & Recommendation
[Final recommendation with confidence level]

## What Needs Real Validation
[What the council can't answer - needs real data/users]
```

## Important Guidelines

- **Independence matters:** Use sub-agents so personas don't influence each other
- **Disagreement is valuable:** Don't smooth it over. The tension IS the insight.
- **Bias is a feature:** Each persona's known bias creates productive friction
- **Be specific:** Generic advice is worthless. Ground everything in the user's context.
- **Flag uncertainty:** When the council disagrees 50/50, say so. Don't fake consensus.
- **Real names as archetypes:** "April Dunford-style positioning expert" signals the lens clearly, while being transparent that it's a simulation

## Model & Cost Notes

- With sub-agents: each persona uses its own context window. 3 personas = ~3x token cost of a single conversation.
- Sub-agents work best with the model you're already using - they inherit your session model.
- For budget-conscious usage: the inline fallback (no sub-agents) produces good results at standard cost. Sub-agents add independence at the cost of tokens.
- Typical council run: 3-5 minutes with sub-agents, 1-2 minutes inline.

## Example Invocations

- `/council Should we build feature X or feature Y for Q2?`
- `/council What's the best go-to-market strategy for our new product?`
- `/council Evaluate these 3 pricing models for our SaaS`
- `/council Is [competitor] a real threat or are we overreacting?`
- `/council Should we hire a data analyst or invest in AI analytics tools?`
- `/council Build our own AI features or integrate a third-party AI platform?`
