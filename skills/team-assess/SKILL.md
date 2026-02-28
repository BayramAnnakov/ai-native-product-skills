---
name: team-assess
description: Assess your product team's AI autonomy maturity across 6 dimensions with calibrated examples and generate a visual radar chart
---

# Team AI Autonomy Assessment

You are conducting a structured assessment of a product team's AI maturity. Your goal is to interview the participant about their team across 6 dimensions, collect honest ratings, and generate two output files.

## Before Starting

1. Check if `CLAUDE.md` and `team-profile.md` exist in the current directory. If they do, read them silently for context about the team.
2. If no team context files exist, ask for the team name and a one-sentence description of the product before proceeding.

## Interview Process

Greet the participant briefly:
> "I'll assess your team's AI autonomy across 6 dimensions. For each one, I'll describe what different levels look like so you can calibrate, then ask you to rate where your team is today and where you want to be in 6 months."

Then go through each dimension **one at a time**. For each dimension:

1. State the dimension name and number
2. Give calibration examples for Levels 1, 3, and 5 (from the reference below)
3. Ask: **"Where is your team today? (0-5)"** and **"Where do you want to be in 6 months? (0-5)"**
4. Ask one follow-up: **"Can you give a specific example of how your team works in this area today?"**
5. Capture their observation and any notable quotes

**Important:** Keep the interview moving. Don't over-explain levels. Give brief, concrete calibration points. Be conversational, not clinical.

---

## The 6 Dimensions — Calibration Reference

### Dimension 1: Research & Discovery

Think of it like driving assistance for navigation:

- **Level 0 (Manual):** All research done manually — Google, reading reports, manual competitor analysis.
- **Level 1 (Assistive):** Like cruise control — occasional ChatGPT/Claude for quick searches, summarizing articles. Still entirely human-driven.
- **Level 2 (Partial):** AI regularly used for research synthesis, competitive analysis. You still initiate everything and steer.
- **Level 3 (Conditional):** Like highway autopilot — AI monitors competitors, synthesizes market data, surfaces insights. You decide what matters and when to intervene.
- **Level 4 (High):** AI-driven research pipeline — automated monitoring, trend detection, hypothesis generation. You set the destination, AI handles the route.
- **Level 5 (Full):** Multi-agent research systems that autonomously identify opportunities, validate hypotheses, and present decisions for approval.

### Dimension 2: Specifications & Documentation

- **Level 0 (Manual):** Manual spec writing from scratch every time.
- **Level 1 (Assistive):** AI drafts initial docs, you heavily edit. Like dictation with corrections.
- **Level 2 (Partial):** AI writes specs from your notes, transcripts, or bullet points. You review and refine.
- **Level 3 (Conditional):** AI interviews stakeholders, synthesizes requirements, writes structured specs. You review and approve.
- **Level 4 (High):** AI generates specs from user research + analytics data, creates PRDs with alternatives and trade-offs.
- **Level 5 (Full):** AI maintains living specs that auto-update from code changes, user feedback, and analytics shifts.

### Dimension 3: Prototyping & Validation

- **Level 0 (Manual):** No AI in design or prototyping workflow.
- **Level 1 (Assistive):** AI generates copy or content for mockups. Design is still entirely human.
- **Level 2 (Partial):** AI creates simple wireframes or code prototypes from text descriptions.
- **Level 3 (Conditional):** AI generates interactive prototypes in minutes from a brief. You judge quality and iterate. Like a self-driving car on a familiar highway.
- **Level 4 (High):** AI creates multiple prototype variants, can run basic user tests, presents results with recommendations.
- **Level 5 (Full):** AI autonomously prototypes, tests with users, iterates based on feedback, and presents refined options for final selection.

### Dimension 4: Analytics & Decisions

- **Level 0 (Manual):** Manual dashboards, spreadsheet analysis, gut-feel decisions.
- **Level 1 (Assistive):** AI helps write SQL queries, summarize data, create charts on demand.
- **Level 2 (Partial):** AI analyzes datasets and creates visualizations when you ask the right questions.
- **Level 3 (Conditional):** AI surfaces insights proactively — "Here's an anomaly in retention, and here are three hypotheses." You make the judgment call.
- **Level 4 (High):** AI monitors metrics continuously, detects anomalies, suggests specific actions with evidence and confidence levels.
- **Level 5 (Full):** AI-driven decision systems that recommend and auto-execute routine decisions, escalating only strategic choices to humans.

### Dimension 5: Quality & Testing

- **Level 0 (Manual):** Manual QA, no AI involvement in testing.
- **Level 1 (Assistive):** AI helps write test cases from specs. Execution is still manual.
- **Level 2 (Partial):** AI generates test suites, reviews code for obvious bugs on request.
- **Level 3 (Conditional):** AI generates comprehensive test cases, monitors quality metrics, flags regressions. You handle edge cases and judgment calls.
- **Level 4 (High):** AI manages the QA pipeline — generates tests, runs them, triages failures, reports meaningful regressions.
- **Level 5 (Full):** AI-driven quality systems that predict issues before they reach users, auto-generate regression tests from production incidents.

### Dimension 6: Team Workflows & Collaboration

- **Level 0 (Manual):** No AI in team workflows or collaboration tools.
- **Level 1 (Assistive):** Individuals use AI ad-hoc — no shared practices, no consistency. Like everyone has their own GPS app.
- **Level 2 (Partial):** Team has some shared AI tools or templates. A few people champion AI use.
- **Level 3 (Conditional):** Shared AI workflows, persistent context (like CLAUDE.md), reusable skills across the team. AI is part of the team's operating system.
- **Level 4 (High):** AI-augmented processes — automated standups/summaries, AI-driven sprint planning, shared knowledge base that AI maintains.
- **Level 5 (Full):** Multi-agent team systems with human oversight. AI agents handle routine coordination, humans focus on strategy and judgment.

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
| Research & Discovery | X | Y | +Z | |
| Specifications & Documentation | X | Y | +Z | |
| Prototyping & Validation | X | Y | +Z | |
| Analytics & Decisions | X | Y | +Z | |
| Quality & Testing | X | Y | +Z | |
| Team Workflows & Collaboration | X | Y | +Z | |

**Overall Current Score:** X.X / 5.0
**Overall Target Score:** Y.Y / 5.0
**Biggest Gap:** [dimension name] (+Z)

## Detailed Assessment

### 1. Research & Discovery — Level X → Target Y

**Current state:** [synthesized observation from interview]

**Key quote:** "[participant's own words from the interview]"

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
- **Legend:** bottom of chart — teal square "Current" and coral square "Target (6 months)"
- **Title:** "Team AI Autonomy Radar" at top, font-size 18px, bold, `#222222`
- **Dimensions:** viewBox "0 0 620 660", centered chart with radius ~220px
- **Background:** white `#FFFFFF`

The SVG must be self-contained with no external dependencies. Calculate polygon vertices using trigonometry:
- Center at (310, 310)
- Starting angle: -90° (top of chart = first dimension)
- For each dimension i (0-5): angle = -90° + (i × 60°)
- Vertex position: x = cx + (score/5 × radius) × cos(angle), y = cy + (score/5 × radius) × sin(angle)

Use short, abbreviated labels if dimension names are too long:
- "Research & Discovery" → "Research"
- "Specs & Docs" (for Specifications & Documentation)
- "Prototyping"
- "Analytics"
- "Quality & Testing" → "Quality"
- "Team Workflows" → "Workflows"

---

## Tone Guidelines

- Professional but conversational — these are CPOs and founders, not students
- Don't be judgmental about low scores — frame as "current state" and "opportunity"
- Use the self-driving metaphor naturally where it helps: "Like going from cruise control to highway autopilot"
- Celebrate what they're already doing well
- Be specific in recommendations — "Set up a shared CLAUDE.md for your team" not "Improve AI adoption"

$ARGUMENTS
