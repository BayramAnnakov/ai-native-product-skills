# AI-Native Product Team Skills

Reusable [Claude Code](https://claude.ai/claude-code) skills for the AI-Native Product Team course. Installable as a Claude Code plugin marketplace.

## Available Skills

### `/team-assess` - Team AI Autonomy Assessment

Interviews you about your product team's AI maturity across 6 dimensions, generates a structured assessment report and a visual radar chart.

**What it does:**
- Walks through 6 dimensions (Research, Specs, Prototyping, Analytics, Quality, Team Workflows)
- Provides calibration examples at each level using the self-driving car metaphor
- Asks for current score (0-5) and 6-month target for each dimension
- Generates `team-assessment.md` with ratings, observations, and priority recommendations
- Generates `radar-chart.svg` comparing current vs target scores

### `/council` - Multi-Perspective AI Council

Get 3-5 expert viewpoints on any product question, with adversarial debate and synthesis. Use for strategic decisions, competitive analysis, feature prioritization, or any question where multiple perspectives improve the outcome.

**What it does:**
- Assembles a panel of 3-5 expert personas tailored to your question type
- Each persona evaluates independently via sub-agents (no groupthink)
- Highlights agreements, disagreements, and the key tension in the debate
- Produces a synthesis with clear recommendations and confidence levels
- Saves output as `council-[topic-slug].md`

**Example invocations:**
- `/council Should we build feature X or feature Y for Q2?`
- `/council What's the best go-to-market strategy for our new product?`
- `/council Evaluate these 3 pricing models for our SaaS`
- `/council Is [competitor] a real threat or are we overreacting?`

### `/prototype` - Autonomous Prototype Builder

Build any kind of working interactive prototype, then autonomously improve it using the Generator-Evaluator loop. Based on Anthropic's harness architecture (March 2026).

**What it does:**
- Calibrates evaluation criteria based on prototype type (dashboard, flow, page, tool - suggests domain-specific criteria, you confirm)
- Plans a prototype spec from available context (CLAUDE.md, competitive analysis, brand guidelines - works with minimal context too)
- Spawns a **Generator sub-agent** to build a multi-file interactive prototype
- Spawns an **Evaluator sub-agent** to independently critique it with browser automation
- Loops: Generator improves based on Evaluator feedback, Evaluator re-scores
- Runs 3-5 rounds autonomously until quality threshold is met
- Produces: working prototype, improvement-log.md, product-passport.md

**Three-agent architecture** (Orchestrator + Generator + Evaluator) ensures the Evaluator is genuinely independent - separate context window, no access to the Generator's reasoning.

**Example invocations:**
- `/prototype Landing page for our B2B sales tool`
- `/prototype Admin dashboard showing real-time pipeline metrics`
- `/prototype Onboarding flow for first-time users`
- `/prototype Settings page with team management and billing`
- `/prototype Data visualization of monthly revenue trends`

## Installation

### Option 1: Plugin marketplace (recommended)

In Claude Code:
```
/plugin marketplace add BayramAnnakov/ai-native-product-skills
/plugin install team-assessment@ai-native-product-skills
```

### Option 2: Manual install (one command per skill)

```bash
cd ~/team-ai-workspace
mkdir -p .claude/commands

# Team Assessment
curl -o .claude/commands/team-assess.md https://raw.githubusercontent.com/BayramAnnakov/ai-native-product-skills/main/skills/team-assess/SKILL.md

# Council
curl -o .claude/commands/council.md https://raw.githubusercontent.com/BayramAnnakov/ai-native-product-skills/main/skills/council/SKILL.md

# Prototype
curl -o .claude/commands/prototype.md https://raw.githubusercontent.com/BayramAnnakov/ai-native-product-skills/main/skills/prototype/SKILL.md
```

## Usage

Open Claude Code in your workspace and type:

```
/team-assess
```
Follow the interview. You'll get `team-assessment.md` + `radar-chart.svg`.

```
/council Should we build feature X or feature Y?
```
The council assembles expert personas, runs independent evaluations, and produces `council-[topic].md`.

## Tips

- Run `/team-assess` after creating your `CLAUDE.md` and `team-profile.md` - the skill reads them for context
- Run `/council` with your `CLAUDE.md` set up - the council uses your product context to give specific (not generic) advice
- Re-run `/team-assess` monthly to track progress
- Share skills with your team via git - they install once, run forever

## Course

Part of the [AI-Native Product Team](https://empatika.com) course (Season 1, 2026).

## License

MIT - see [LICENSE](LICENSE)
