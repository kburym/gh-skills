# gh-skills

GitHub automation skills for Claude Code — pull request lifecycle, labelling, projects, and issue-to-PR flow.

Every skill is a self-contained folder with a `SKILL.md` (plus optional `references/` loaded on demand) and follows the standard Anthropic skill format.

## Skills

| Skill | What it does |
|-------|--------------|
| [pr-workflow-orchestrator](./skills/pr-workflow-orchestrator/SKILL.md) | End-to-end PR workflow: worktree → open → feedback → merge. Never leaves a PR unattended. |
| [pr-manager](./skills/pr-manager/SKILL.md) | Orchestrates 3+ PRs in parallel with strict Definition of Done enforcement. |
| [pr-worktree](./skills/pr-worktree/SKILL.md) | Creates and manages isolated git worktrees for PR work — never touches the main checkout. |
| [pr-opener](./skills/pr-opener/SKILL.md) | Opens PRs with correct formatting, description, and mandatory linked issue. |
| [pr-reviewer](./skills/pr-reviewer/SKILL.md) | Comprehensive code review posted as structured review comments. |
| [pr-feedback-handler](./skills/pr-feedback-handler/SKILL.md) | Handles incoming PR comments — fixes the issue or replies with the reason. |
| [pr-commenter](./skills/pr-commenter/SKILL.md) | Posts PR comments: general, line-level, and thread replies. |
| [pr-labeler](./skills/pr-labeler/SKILL.md) | Auto-labels PRs by branch name, changed files, size, and type. |
| [pr-merger](./skills/pr-merger/SKILL.md) | Merges approved PRs safely — conflicts, CI checks, post-merge cleanup. |
| [gh-pr-review-buttons](./skills/gh-pr-review-buttons/SKILL.md) | Adds "Review this PR in" Grok / Claude / Codex badges to PR descriptions. |
| [gh-project-orchestrator](./skills/gh-project-orchestrator/SKILL.md) | Creates and manages GitHub Projects (v2), linking epics, issues, and PRs. |
| [gh-prioritizer](./skills/gh-prioritizer/SKILL.md) | Auto-sets priorities across project items, audits the board, syncs issue/PR priority. |

## Install

```bash
git clone --depth 1 https://github.com/odykyi/gh-skills.git /tmp/gh-skills
cp -R /tmp/gh-skills/skills/* ~/.claude/skills/
```

For Claude Code plugin installs, point the marketplace at this repo — each folder under `skills/` is a valid skill package.

## Prerequisites

- `gh` CLI authenticated (`gh auth status`)
- Repository write access for anything that creates, labels, comments on, or merges PRs

## Usage

Skills trigger on intent, e.g.:

- "open a PR for this branch" → `pr-opener`
- "review this PR" → `pr-reviewer`
- "merge the approved PRs" → `pr-merger`
- "manage 5 PRs in parallel" → `pr-manager`
- "set priorities on the project board" → `gh-prioritizer`
- "create a project for this integration" → `gh-project-orchestrator`

## Notes

- These skills are repository-agnostic. Where a label set, path mapping, or domain taxonomy is involved, the skill ships a documented default that you can align with your own repo conventions.
- Some skills reference companion issue-side skills (`issue-labeler`, `issue-reporter`, `issue-to-pr`). Those are not part of this collection.
- `gh-pr-review-buttons` is derived from [`tdk-landscape/tdk-skills`](https://github.com/tdk-landscape/tdk-skills/tree/main/skills/tdk-pr-review-buttons) (MIT).

## Credits

- `gh-pr-review-buttons` — original by [@tdk-landscape](https://github.com/tdk-landscape) / [tdk-cli-core](https://github.com/tdk-landscape/tdk-cli-core), MIT licensed.
