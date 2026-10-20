# AGENTS.md — repos that use the gh-skills collection

Copy this file to the root of your repository as `AGENTS.md` when you install
the [`gh-skills`](https://github.com/odykyi/gh-skills) skills. It tells the
agent how your repository does pull requests, so the skills do not have to
guess.

Replace the values in angle brackets. Delete any line that does not apply.

## The loop

Every pull request in this repository follows the same path:

```text
issue → branch → worktree → PR → review → fix → merge → cleanup
```

- **Every PR is linked to an issue.** Both directions: the PR body says
  `Closes #<issue>`, and the issue links back to the PR.
- **A PR is not done until it is merged.** Opening one is not completion.
- **No PR is left unattended.** Reviews are picked up and either fixed or
  answered with a reason.
- **Work happens in a worktree**, never by switching the main checkout.

## Repository facts

- Default branch: `<main|master>`
- Test command: `<npm test | pytest | go test ./...>`
- Type check: `<npx tsc --noEmit | mypy | none>`
- Lint: `<npm run lint | ruff | golangci-lint>`
- Package manager: `<npm | pnpm | yarn | bun>`
- Worktrees live in `<.worktrees/>`

## Labels

| Category | Labels |
|----------|--------|
| Type | `<bug, feature, enhancement, documentation, refactor, performance, security>` |
| Priority | `<P0-Critical, P1-High, P2-Medium, P3-Low>` |
| Status | `<status/wip, status/ready-for-review, status/changes-requested, status/approved, status/blocked>` |
| Size | `<size/XS, size/S, size/M, size/L, size/XL>` |

## Merge rules

- Branch protection is respected. Never use `gh pr merge --admin`.
- Merge strategy: `<squash | merge | rebase>` — follow the repository default.
- Required checks: `<list them>`.
- At least one approval from someone with write access is required.

## What the agent must never do

- Force push, or delete a branch that is not merged.
- Open a PR without a linked issue.
- Merge while CI is red, or with unresolved conflicts.
- Force-remove a worktree that has uncommitted changes.
- Resolve a review thread it has not acted on.
- Change files outside the scope of the task it was given.

## Notifications

- Post a summary of each merged PR on `<the PR itself | a tracking issue | Slack>`.
- Escalate to a human when: a reviewer disagrees, a security concern appears,
  the scope of the task changes, or nothing has responded for `<24h>`.
