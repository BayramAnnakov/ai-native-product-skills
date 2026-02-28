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

## Installation

### Option 1: Plugin marketplace (recommended)

In Claude Code:
```
/plugin marketplace add BayramAnnakov/ai-native-product-skills
/plugin install team-assessment@ai-native-product-skills
```

### Option 2: Manual install (one command)

```bash
cd ~/team-ai-workspace
mkdir -p .claude/commands
curl -o .claude/commands/team-assess.md https://raw.githubusercontent.com/BayramAnnakov/ai-native-product-skills/main/skills/team-assess/SKILL.md
```

## Usage

Open Claude Code in your workspace and type:

```
/team-assess
```

Follow the interview. When done, you'll have:
- `team-assessment.md` - your full assessment with recommendations
- `radar-chart.svg` - visual radar chart (open in browser)

## Tips

- Run `/team-assess` after creating your `CLAUDE.md` and `team-profile.md` - the skill reads them for context
- Re-run monthly to track progress
- Share with your co-founder or head of engineering to compare assessments

## Course

Part of the [AI-Native Product Team](https://empatika.com) course (Season 1, 2026).

## License

MIT - see [LICENSE](LICENSE)
