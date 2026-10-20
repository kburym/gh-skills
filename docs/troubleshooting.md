# Troubleshooting

## The agent does not see the skills

**Claude Code**

- Project scope → the skills must be in `./.claude/skills/<name>/SKILL.md`.
- Global scope → `~/.claude/skills/<name>/SKILL.md`.
- Start a new session after installing. Skills are discovered at startup.
- If you installed the plugin, run `/plugin` and check it is enabled.

**Other agents**

- The agent looks for a folder with a `SKILL.md` inside it. A symlink works;
  a copied *file* named `SKILL.md` at the wrong level does not.
- Run `ls -l .claude/skills/` and confirm the symlink target exists.

## The symlinks point at a deleted checkout

`install.sh` symlinks into a cache at `~/.local/share/gh-skills`. If that
directory was removed, every link is dangling:

```bash
rm -rf ~/.local/share/gh-skills
curl -fsSL https://raw.githubusercontent.com/odykyi/gh-skills/main/install.sh | sh -s -- --agent claude --global
```

`install.sh` also cleans up its own stale links on every run.

## `could not add label: 'bug' not found`

`gh pr edit --add-label` fails when the label does not exist in the repository.
Create it once:

```bash
gh label create "bug" --color "d73a4a" --description "Something is broken"
gh label list --limit 100 --json name --jq '.[].name'
```

`pr-labeler` checks the label set before applying anything.

## `fatal: 'main' is already used by worktree` or `already checked out at`

A branch can only be checked out in one worktree. Either use the existing
worktree, or pick a different branch name:

```bash
git worktree list
```

## `fatal: Refusing to fetch into current branch refs/heads/main`

`git fetch origin main:main` fails in a non-bare repository when `main` is
checked out — which is exactly what `pr-worktree` keeps true. Fetch the
remote-tracking ref instead:

```bash
git fetch origin main
git branch "my-branch" origin/main
```

## The PR body was not updated / buttons did not appear

The `ai-review-buttons` workflow only runs on the default branch:

- Merging the workflow does not re-trigger it for PRs that are already open.
  Run **Actions → AI review buttons → Run workflow** once to backfill.
- Merged PRs are never rewritten — open a new PR to see the buttons.
- The workflow uses `pull_request_target`, so forks get buttons too. If it
  does not run at all, check that `actions/checkout` is pinned and that the
  workflow file is on the default branch.

## `gh pr view --json reviews` returns nothing for inline comments

`gh pr view` exposes issue comments and review submissions, not the inline
diff-anchored comments. Use the API:

```bash
gh api "repos/{owner}/{repo}/pulls/<n>/comments" --paginate \
  --jq '.[] | {author: .user.login, path: .path, line: .line, body: .body}'
```

## Thread resolution fails

There is no REST endpoint for it. `resolveReviewThread` is a GraphQL
mutation, and it is one-way — a resolved thread cannot be reopened. Post a new
reply with `in_reply_to` instead.

## The validator fails on a skill I just wrote

```bash
node scripts/validate-skills.mjs
```

It prints the file and the reason. The usual causes:

- `name` does not equal the folder name
- a `references/*.md` link does not exist
- a banned command (see `docs/creating-skills.md`)
- the skill is not listed in `README.md`, `llms.txt` or the marketplace manifest

## The diagram is out of date

```bash
./assets/build-diagram.sh
git commit assets/pr-lifecycle.svg
```

CI fails if `assets/pr-lifecycle.svg` differs from what `pr-lifecycle.dot`
renders, so the checked-in SVG is always the source of truth.
