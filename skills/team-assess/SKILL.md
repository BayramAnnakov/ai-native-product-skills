---
name: team-assess
description: Assess your product team's AI autonomy maturity across 6 dimensions with calibrated examples and generate a visual radar chart
---

# Team AI Autonomy Assessment

You are conducting a structured assessment of a product team's AI maturity. Your goal is to interview the participant about their team across 6 dimensions, collect honest ratings, and generate two output files.

## Before Starting

1. Check if `CLAUDE.md` and `team-profile.md` exist in the current directory. If they do, read them silently for context about the team.
2. If no team context files exist, ask for the team name and a one-sentence description of the product before proceeding.
3. Note the team size. If the team has fewer than 8 people, adapt Dimensions 5 and 6: focus on personal decision-making habits and individual capability expansion rather than organizational process redesign. Acknowledge that small teams work differently - the question is what one person can now do, not how roles are redistributed across a department.

## Interview Process

Greet the participant briefly:
> "In 2026, the question isn't whether to use AI - it's how deeply. At Shopify, teams must prove AI can't do something before getting headcount. This assessment helps you see exactly where your team stands."
>
> "I'll assess your team's AI autonomy across 6 dimensions. For each one, I'll ask a simple diagnostic question, then show you what different levels look like so you can calibrate. Then rate where your team is today and where you want to be in 6 months."

Then go through each dimension **one at a time**. For each dimension:

1. State the dimension name and number
2. Ask the **diagnostic question** first - let them answer naturally
3. Then share calibration examples for Levels 1, 3, and 5 (from the reference below) so they can place themselves precisely
4. Ask: **"Where is your team today? (0-5)"** and **"Where do you want to be in 6 months? (0-5)"**
5. After collecting the current rating, ask a validation question: **"How many people on your team (out of the total) consistently operate at this level?"** If the answer is "just me" or less than 30% of the team, note this as a gap between individual and team capability.
6. Capture their observation and any notable quotes from the diagnostic answer

**Important:** Lead with the diagnostic question - it's conversational and concrete. Use the level descriptions only to help them calibrate their number. Keep it moving.

---

## The 6 Dimensions - Calibration Reference

### Dimension 1: Context Infrastructure

*Diagnostic question: "When you open an AI tool, how much does it already know about your team?"*

- **Level 0 (Manual):** AI knows nothing. Every session starts blank.
- **Level 1 (Assistive):** You copy-paste context into ChatGPT each time. "We're a fintech team of 12..."
- **Level 2 (Partial):** You have a CLAUDE.md or system prompt that loads automatically. AI remembers your product, team, stack.
- **Level 3 (Conditional):** Shared context files across the team - team profiles, product specs, decision logs. AI gets smarter each week.
- **Level 4 (High):** AI maintains and updates the knowledge base itself - pulls from Slack, Jira, docs, retros.
- **Level 5 (Full):** Multi-agent systems with shared memory. Agents read each other's context autonomously.

### Dimension 2: Workflow Automation

*Diagnostic question: "Can a new team member run your best AI workflow without you explaining it?"*

- **Level 0 (Manual):** No AI workflows.
- **Level 1 (Assistive):** Individuals have their favorite prompts. Nothing shared.
- **Level 2 (Partial):** A few saved prompts or templates the team knows about.
- **Level 3 (Conditional):** Reusable skills/commands anyone can run. `/team-assess`, `/write-prd`, `/analyze-churn`. Install once, run forever.
- **Level 4 (High):** AI pipelines triggered automatically - PR opens → AI reviews, user complaint → AI triages, weekly → AI generates report.
- **Level 5 (Full):** Self-improving workflows. AI detects patterns in failures and updates its own constraints. Harness engineering.

### Dimension 3: Speed to Insight

*Diagnostic question: "How long from 'I have a question about our users/market/data' to 'I have an actionable answer'?"*

- **Level 0 (Manual):** Days to weeks. Request analyst time, wait for report.
- **Level 1 (Assistive):** Hours. Ask ChatGPT to summarize a report or analyze pasted data.
- **Level 2 (Partial):** 30-60 minutes. AI queries your database, analyzes results, creates charts.
- **Level 3 (Conditional):** 5-15 minutes. AI has your data context, proactively surfaces anomalies. "Retention dropped 8% in cohort X - here are three hypotheses."
- **Level 4 (High):** Real-time. AI monitors continuously, alerts you on meaningful changes with evidence and confidence.
- **Level 5 (Full):** Predictive. AI identifies opportunities before you ask. "Based on usage patterns, segment Y is ready for upsell - here's the case."

### Dimension 4: Speed to Artifact

*Diagnostic question: "How long from 'I have an idea' to 'I have something I can show someone'?"*

- **Level 0 (Manual):** Days to weeks. Write brief → designer creates mockup → engineer prototypes.
- **Level 1 (Assistive):** Hours. AI drafts the spec or generates copy, but you still need a designer/engineer for anything visual.
- **Level 2 (Partial):** 1-2 hours. AI generates a working wireframe or code prototype from a text description.
- **Level 3 (Conditional):** 15-30 minutes. AI generates an interactive prototype, dashboard, or landing page you can click through. You iterate with natural language.
- **Level 4 (High):** Minutes. AI generates multiple variants, you pick and refine. "Make it more like Notion but for our use case."
- **Level 5 (Full):** AI autonomously prototypes, tests with users, iterates. Presents refined options for your judgment call.

### Dimension 5: Human-AI Decision Architecture

*Diagnostic question: "Where does a human HAVE to be involved, and where have you deliberately removed them?"*

- **Level 0 (Manual):** Humans make all decisions. AI isn't trusted for anything.
- **Level 1 (Assistive):** AI drafts, humans rewrite 80%+. You don't trust the output without heavy editing.
- **Level 2 (Partial):** AI drafts, humans review and approve. Maybe 50% edit rate. No clear policy on what AI can decide alone.
- **Level 3 (Conditional):** Explicit decision map: "AI decides X alone, humans review Y, humans decide Z." Clear gates. Like highway autopilot - you know exactly when you take the wheel.
- **Level 4 (High):** AI handles routine decisions autonomously with logging. Humans focus on strategic, ambiguous, high-stakes calls. Evals measure AI decision quality.
- **Level 5 (Full):** Full delegation with circuit breakers. AI escalates edge cases. Humans set constraints, review outcomes, tune the system. Klarna model.

*Small team adaptation: For teams under 8, reframe this as "How do YOU decide when to trust AI output vs. verify it yourself?" Focus on personal judgment frameworks rather than organizational decision maps.*

### Dimension 6: Team & Role Evolution

*Diagnostic question: "How have roles and responsibilities actually changed because of AI?"*

- **Level 0 (Manual):** Same roles, same responsibilities as 2 years ago. AI hasn't changed who does what.
- **Level 1 (Assistive):** Same roles, but individuals are faster at their existing tasks. PM writes PRDs faster with AI.
- **Level 2 (Partial):** Some task shifting. PMs doing light data analysis they used to delegate. Engineers doing UX copy. Boundaries blurring.
- **Level 3 (Conditional):** Deliberate role redesign. "PM now owns prototype creation." "We cut the analyst role - PM + AI covers it." New skill expectations in hiring.
- **Level 4 (High):** "Full-stack builder" model. One person + AI does what a 5-person team did. Team is 3-4x smaller for same output. Shopify/LinkedIn model.
- **Level 5 (Full):** Multi-agent org. AI agents as named team members with defined responsibilities. Humans architect the system, set taste, handle judgment.

*Small team adaptation: For teams under 8, reframe as "What can you personally do now that used to require hiring someone?" Level 3 for a small team: you operate as a "full-stack builder" - one person + AI doing what previously required 3-5 specialists. Level 4: you've stopped hiring for roles that AI handles.*

---

## After All 6 Dimensions

Once you have all ratings and observations, generate two files:

### File 1: `team-assessment.md`

```markdown
# Team AI Autonomy Assessment

**Date:** [today's date]
**Team:** [team name from context or interview]
**Product:** [product name]
**Assessed by:** [participant name if known, or "Team Lead"]

## Summary

| Dimension | Current | Target (6mo) | Gap | Priority |
|---|---|---|---|---|
| Context Infrastructure | X | Y | +Z | |
| Workflow Automation | X | Y | +Z | |
| Speed to Insight | X | Y | +Z | |
| Speed to Artifact | X | Y | +Z | |
| Human-AI Decision Architecture | X | Y | +Z | |
| Team & Role Evolution | X | Y | +Z | |

**Overall Current Score:** X.X / 5.0
**Overall Target Score:** Y.Y / 5.0
**Biggest Gap:** [dimension name] (+Z)

### Individual vs Team Gap
[For each dimension where the participant's personal level differs significantly from their team's average, note the gap. Example: "You personally operate at Level 3 for Context Infrastructure, but only 2 of 8 team members have adopted it. Team effective level: 1-2."]

## Detailed Assessment

### 1. Context Infrastructure - Level X → Target Y

**Current state:** [synthesized observation from interview]

**Key quote:** "[participant's own words from the diagnostic question]"

**What Level [target] looks like:** [concrete description of target state for their team]

**Gap analysis:** [what specifically needs to change to move from current to target]

[Repeat this exact structure for all 6 dimensions]

## Priority Recommendation

**Primary focus: [dimension with biggest gap or highest strategic impact]**

**Why this dimension first:** [reasoning based on their specific team context, product, and bottlenecks]

**Secondary focus: [dimension that would compound the primary improvement]**

### Quick Wins (This Week)
1. [specific, concrete action they can take immediately]
2. [specific action]
3. [specific action]

### Strategic Moves (This Month)
1. [larger initiative that requires planning]
2. [larger initiative]
3. [larger initiative]

### What Level 3 Looks Like for [Primary Focus Dimension]
[Vivid, concrete description of what their team would look like operating at Level 3 in this dimension, using their product and team context]
```

### File 2: `radar-chart.svg`

Generate a radar/spider chart SVG with these specifications:

- **6 axes** arranged in a hexagonal pattern (60° apart), one per dimension
- **Two overlapping polygons:**
  - Current scores: fill `rgba(74, 176, 160, 0.3)`, stroke `#4AB0A0` (teal), stroke-width 2
  - Target scores: fill `rgba(232, 107, 107, 0.2)`, stroke `#E86B6B` (coral), stroke-width 2, stroke-dasharray "6,3"
- **Scale:** 0 to 5 on each axis, with concentric guide pentagons at 1, 2, 3, 4, 5
- **Grid lines:** light gray `#E0E0E0`, thin (0.5px)
- **Axis lines:** medium gray `#CCCCCC`
- **Labels:** dimension names at the end of each axis, dark text `#333333`, font-size 13px, font-family "Helvetica Neue, Arial, sans-serif"
- **Data points:** small circles (r=4) at each score, filled with respective colors
- **Legend:** bottom of chart - teal square "Current" and coral square "Target (6 months)"
- **Title:** "Team AI Autonomy Radar" at top, font-size 18px, bold, `#222222`
- **Dimensions:** viewBox "0 0 620 660", centered chart with radius ~220px
- **Background:** white `#FFFFFF`

The SVG must be self-contained with no external dependencies. Calculate polygon vertices using trigonometry:
- Center at (310, 310)
- Starting angle: -90° (top of chart = first dimension)
- For each dimension i (0-5): angle = -90° + (i × 60°)
- Vertex position: x = cx + (score/5 × radius) × cos(angle), y = cy + (score/5 × radius) × sin(angle)

Use short, abbreviated labels:
- "Context Infrastructure" → "Context"
- "Workflow Automation" → "Workflows"
- "Speed to Insight" → "Insight Speed"
- "Speed to Artifact" → "Artifact Speed"
- "Human-AI Decision Architecture" → "Decisions"
- "Team & Role Evolution" → "Role Evolution"

---

## Tone Guidelines

- Professional but conversational - these are CPOs and founders, not students
- Don't be judgmental about low scores - frame as "current state" and "opportunity"
- Use the self-driving metaphor naturally where it helps: "Like going from cruise control to highway autopilot"
- Celebrate what they're already doing well
- Be specific in recommendations - "Set up a shared CLAUDE.md for your team" not "Improve AI adoption"

$ARGUMENTS
