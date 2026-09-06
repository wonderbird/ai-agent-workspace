# Skill-manager research

Frozen research behind
[ADR 002: Centralizing Skills Across Coding Agents](../../architecture-decisions/002-skill-manager-tool-selection.md).
These documents are point-in-time evidence, pinned to the HEADs/dates recorded in
each file. They are **not maintained** — the living decision is the ADR.

## Reading order

| # | Document | What it is | Status |
|---|---|---|---|
| 1 | [initial-tool-survey.md](initial-tool-survey.md) | First broad survey of candidate tools | **Superseded** by #3 and #4 |
| 2 | [evaluation-method.md](evaluation-method.md) | Reusable prompt/rubric for the source evaluation | Frozen |
| 3 | [source-code-evaluation.md](source-code-evaluation.md) | Source-verified evaluation of the original five tools | Frozen (pinned HEADs) |
| 4 | [landscape-scan.md](landscape-scan.md) | Source-verified scan of six further tools | Frozen (2026-09-05, pinned HEADs) |
| 5 | [vercel-labs-scorecard.md](vercel-labs-scorecard.md) | Deep scorecard for `vercel-labs/skills` | Frozen (2026-09-05, HEAD `435076e`) |
| 6 | [packaging-standards.md](packaging-standards.md) | Enterprise packaging & distribution standards review | Frozen |
| 7 | [hands-on-spike.md](hands-on-spike.md) | Hands-on trial that settled the decision | Frozen (2026-09-06) |

## Outcome

The spike (#7) reversed the pre-spike lead: `vercel-labs/skills` searches skills
well but its project restore re-links only into `.agents/` and cannot reconstruct
`.claude/` or global skills. The decision adopts **`omrikais/skill-manager` (`sm`)**
as the day-one skill manager and uses **`vercel-labs/skills` (`npx skills find`)**
only for discovery. See [ADR 002](../../architecture-decisions/002-skill-manager-tool-selection.md)
for the full decision, drivers, and confirmation steps.
