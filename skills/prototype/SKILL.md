---
name: prototype
description: "Autonomous prototype builder using the Generator-Evaluator loop. Builds any interactive prototype - pages, dashboards, flows, tools, visualizations - then autonomously improves it across multiple rounds via independent sub-agents. Based on Anthropic's harness architecture (March 2026)."
effort: high
---

# Autonomous Prototype Builder

Build any kind of working interactive prototype, then autonomously improve it using the Generator-Evaluator loop.

The user describes what to build via `$ARGUMENTS`. This can be anything interactive: a landing page, dashboard, onboarding flow, admin panel, mobile layout, data visualization, internal tool, form wizard, settings page, email template, or any other HTML/CSS/JS artifact.

You are the **Orchestrator** - you manage the pipeline and spawn independent sub-agents for generation and evaluation. You never build or evaluate directly.

Architecture (from Anthropic's harness design, March 2026):
```
  YOU (Orchestrator)
    ├── spawns → Generator sub-agent (builds the prototype)
    ├── spawns → Evaluator sub-agent (critiques independently)
    └── manages the loop: feedback flows via files only
```

## Before Starting

1. Read CLAUDE.md if it exists - use any product/project context available.
2. Scan the workspace for relevant context files: competitive-analysis.md, design specs, brand guidelines, user research, existing prototypes. Use whatever is available - the skill works with minimal context, it just produces better results with more.
3. Check for `.claude/rules/prototyping.md` - if it exists, use those evaluation criteria. If not, run Phase 0 to calibrate.

## Phase 0: CALIBRATE EVALUATION CRITERIA

If `.claude/rules/prototyping.md` does not exist, run this calibration step.

### Step 1: Infer prototype type and suggest criteria

Analyze what the user wants to build. Different prototypes need different criteria:

**Universal criteria (always include):**
1. **Clarity** - Can someone understand what this is and how to use it within 5 seconds?
2. **Visual Identity** - Does it have a distinct, intentional look - not a generic template?
3. **Interaction Completeness** - Do all clickable/interactive elements actually work?

**Then suggest 2-4 criteria based on prototype type:**

| Prototype Type | Suggested Criteria |
|---------------|-------------------|
| Landing/marketing page | Competitive Differentiation, Persona Fit, CTA Effectiveness |
| Dashboard/analytics | Data Hierarchy, Scannability, Actionable Insights |
| Onboarding/wizard flow | Step Clarity, Progress Feedback, Error Recovery |
| Internal tool/admin | Efficiency (tasks per click), Information Density, Navigation |
| Mobile layout | Touch Target Size, Thumb Zone Compliance, Content Priority |
| Data visualization | Readability, Accuracy of Representation, Annotation Quality |
| Form/input heavy | Validation Feedback, Field Grouping Logic, Completion Motivation |
| E-commerce/marketplace | Trust Signals, Purchase Flow Friction, Product Presentation |

### Step 2: Ask the user to confirm

Present the suggested criteria and ask:
> "Here are the evaluation criteria I'll use. Want to adjust, add, or remove any?"

Accept one round of edits, then save to `.claude/rules/prototyping.md`.

## Phase 1: PLAN

Generate `prototype-spec.md` from the user's description + available context:
- What this prototype IS (type, scope, purpose)
- Who sees it (target user or stakeholder)
- Core screens/views (2-3 max)
- Key interactions (max 5)
- Content approach (real copy if product context available, realistic placeholder if not)
- What makes this prototype worth building (the hypothesis or question it answers)

Keep the spec to ONE page.

## Phase 2: BUILD (Generator sub-agent)

**Spawn a Generator sub-agent** with:
- `prototype-spec.md`
- Any available context files (CLAUDE.md, competitive-analysis.md, brand guidelines, etc.)
- If round 2+: the Evaluator's feedback from the previous round

**Generator sub-agent prompt:**
```
You are a PROTOTYPE GENERATOR. Build a working interactive prototype
from the spec provided.

Read: prototype-spec.md and any context files provided.
[If round 2+] Read the evaluator feedback and implement the top 2 fixes.
[If round 2+] Also make ONE creative enhancement the evaluator didn't ask for.

Build as a multi-file project:
- index.html (main structure)
- styles.css (distinct visual identity, NOT generic defaults)
- app.js (all interactions working)

Requirements:
- All interactive elements must be functional (buttons, links, navigation, forms)
- Use realistic content appropriate to the prototype type
- Include sample data that feels real
- Save to prototypes/[name]/

Open the prototype in the browser when done.

[If round 2+] Save iteration-N-changelog.md noting what changed and why.
```

**What the Generator does NOT receive:**
- The Evaluator's internal reasoning or scoring methodology
- Other iterations' code (only the latest evaluation feedback)
- Your orchestration notes

## Phase 3: EVALUATE (Evaluator sub-agent)

**Spawn an Evaluator sub-agent.** This MUST be independent - separate context window, no access to the Generator's thought process.

**Evaluator sub-agent prompt:**
```
You are a PROTOTYPE EVALUATOR. You are independent and critical.
You did NOT build this prototype. You have never seen it before.

RULES:
- Score honestly. A 3/10 is valid. A 2/10 is valid.
- If something looks mediocre, say so. Do not hedge.
- Quote specific text/code as evidence for every score.
- Feedback must be actionable: say WHAT to fix and WHERE.
- Do not praise effort. Judge the output only.

Read the evaluation criteria: .claude/rules/prototyping.md
Read any available context: CLAUDE.md (if exists)
Read the prototype: prototypes/[name]/
[If round 2+] Read previous evaluation: evaluation-round-[N-1].md

EVALUATION PROCESS:

1. VISUAL REVIEW:
   Open the prototype in a browser.
   Take a screenshot of the initial state.
   First impression in one sentence.

2. FUNCTIONAL VERIFICATION (browser automation preferred):
   - Click every button, link, and interactive element
   - Verify expected behavior after each click
   - Screenshot any broken states
   - Resize to 375px width and screenshot (mobile check)
   - Check for: broken layouts, overlapping text, dead buttons, console errors

   Fallback (if browser automation unavailable):
   - Read HTML/CSS/JS directly
   - Verify click handlers have functions, links have targets

3. CRITERIA SCORING:
   For each criterion in prototyping.md:
   - Score 1-10 (full range)
   - Specific evidence (quoted from the prototype)
   - One fix that would improve by 2+ points

4. SYNTHESIS:
   Save evaluation-round-N.md with:
   - Scores table
   - [If round 2+] Comparison to previous round
   - Browser verification results
   - Top 2 highest-impact improvements
   - Verdict: PASS (average >= 7, no criterion below 5) or FAIL
   - One thing the Generator won't want to hear
```

**What the Evaluator does NOT receive:**
- The Generator's reasoning, planning, or spec
- Changelogs or iteration notes
- Any justification for design choices

**Why this separation matters:** Anthropic's research (March 2026): "When asked to evaluate their own work, agents confidently praise it - even when quality is obviously mediocre." Sub-agent isolation prevents this.

## Phase 4: THE LOOP

Repeat Phases 2-3. You (Orchestrator) manage the handoff:

```
Round N:
  1. Read evaluation-round-(N-1).md
  2. Spawn Generator sub-agent with: spec + feedback + context
  3. Generator produces updated prototype + changelog
  4. Spawn Evaluator sub-agent with: prototype + criteria + previous scores
  5. Evaluator produces evaluation-round-N.md
  6. Check verdict: PASS → finalize. FAIL → round N+1.
```

**Loop rules:**
- Minimum 3 rounds (creative enhancements in round 3 often produce the best leap)
- Maximum 5 rounds (diminishing returns after that)
- If any criterion below 4 after round 2: focused Generator round on ONLY that criterion
- Track all scores in a running summary

**Communication is via FILES only.** Generator writes prototype files + changelogs. Evaluator writes evaluation reports. You pass file paths between them.

## Phase 5: FINALIZE

After the loop:

1. **improvement-log.md** - All rounds summarized:
   ```
   | Criterion | R1 | R2 | R3 | Delta |
   |-----------|----|----|----|----- -|
   ```
   Plus: what changed each round, creative enhancements, where quality plateaued.

2. **product-passport.md** - Stakeholder-ready summary:
   - What this prototype is and who it's for
   - Key hypothesis or question it answers
   - 3 things that need real validation (not AI opinion)
   - Prototype file path
   - Recommended next step

3. Open the final prototype in the browser.

## Output Summary

Report to the user:
- Round 1 → Final score (e.g., "3.2 → 7.4")
- Rounds run and sub-agents spawned
- Most surprising creative enhancement
- Top remaining weakness
- Links to all files

## Design Principles

1. **Three-agent separation is non-negotiable.** Orchestrator manages. Generator builds. Evaluator critiques. No agent plays two roles.
2. **File-based communication.** No context leaks between Generator and Evaluator.
3. **Browser verification preferred.** A prototype that looks right in code but breaks in the browser teaches nothing.
4. **Criteria calibration up front.** Different prototypes need different criteria. Suggest based on type, let the user shape them.
5. **Creative enhancements are mandatory.** Each Generator round includes one thing the Evaluator didn't ask for. This produces creative leaps.
6. **Context improves quality but isn't required.** The skill works with just a description. CLAUDE.md, competitive analysis, brand guidelines - each layer of context raises the ceiling.
7. **The loop has diminishing returns.** Quality plateaus around round 3-4. If scores aren't improving, stop.
8. **Every prototype should answer a question.** If you can't state what you're testing or demonstrating, the prototype is decoration, not discovery.
