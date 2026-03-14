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
