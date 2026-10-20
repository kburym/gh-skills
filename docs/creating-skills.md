# Creating a skill

A skill is a folder with a `SKILL.md`. That is the whole contract — but a
skill that reads well and a skill that an agent can *execute* are different
things. This page is about the second one.

## 1. Start from the template

```bash
cp template/skill-template.md skills/my-skill/SKILL.md
```

## 2. The frontmatter is the trigger

The agent sees only the `name` and `description` before it decides whether to
load the skill. Write the description for that decision:

```yaml
---
name: my-skill
description: Does one specific thing. Use when the user asks for X, or when Y happens.
---
```

Good descriptions say **what it does** and **when to use it**. Bad ones
describe the implementation ("Uses GraphQL and React") or repeat the title
("A skill for GitHub"). Keep it under 1024 characters, one paragraph.

`name` must equal the folder name, lowercase and hyphenated.

## 3. Write commands that actually run

This is where most skills go wrong. Every `gh` and `git` invocation must be
one you have executed against the real CLI. Things that have actually broken
in this collection:

| Broken | Working |
|--------|---------|
| `gh pr reviews <n>` | `gh pr view <n> --json reviews` |
| `gh pr comments <n>` | `gh pr view <n> --json comments` |
| `gh pr diff <n> --path <file>` | `gh pr diff <n> --patch` |
| `POST /pulls/<n>/comments/<id>/replies` | `POST /pulls/<n>/comments` with `in_reply_to` |
| `PATCH /pulls/comments/<id> -f state=RESOLVED` | GraphQL `resolveReviewThread` mutation |
| `git fetch origin main:main` | `git fetch origin main` |
| `git checkout --ours` on a manifest | resolve manually, never auto-resolve `package.json` / lockfiles |

Two checks worth doing every time:

```bash
gh pr view <n> --json <fields>       # does the field exist?
gh <cmd> --help                      # does the flag exist?
```

Note that `gh api` only expands `{owner}`, `{repo}` and `{branch}`. Every other
placeholder — `{number}`, `{comment-id}`, `{file-path}` — is sent literally and
will 404. Substitute them yourself.

## 4. Guard the destructive parts

A skill is instructions for an agent that will actually run them. Anything
irreversible needs a check that proves nothing is lost:

```bash
# wrong
git branch -D "$branch_name" 2>/dev/null || true

# right
git branch -d "$branch_name" || {
  echo "Local branch not fully merged — keeping it."
  git log origin/main.."$branch_name"
}
```

The same applies to force pushes, `--admin` merges, worktree removal, branch
deletion and thread resolution. If the guard can fail, the skill must stop and
report rather than continue.

## 5. Keep it self-contained

A skill may not link to a file that is not in its own folder, and may not
depend on a skill outside this collection unless the dependency is marked
external. `scripts/validate-skills.mjs` enforces both.

## 6. Keep it repository-agnostic

No organisation names, no product nouns, no domain vocabulary that only makes
sense in one repo. Label sets, path mappings and category taxonomies are
documented defaults that the user can override.

## 7. Register the skill

A new skill is invisible until it is listed in three places:

1. `README.md` — the skills table
2. `llms.txt` — the machine-readable index
3. `.claude-plugin/marketplace.json` — the plugin manifest

Then:

```bash
node scripts/validate-skills.mjs
```

## 8. Reference material

Keep `SKILL.md` under ~500 lines. Move long tables, decision trees and
examples into `references/` and link them:

```markdown
- [Best Practices](references/best-practices.md) — judgement calls and tone
```

The agent loads `SKILL.md` always and `references/` only when it needs them.

## Checklist

- [ ] `name` equals the folder name
- [ ] description says what **and when**, under 1024 chars
- [ ] every command was executed against the real CLI
- [ ] destructive steps are guarded
- [ ] no dead `references/` links
- [ ] no private or organisation-specific vocabulary
- [ ] listed in `README.md`, `llms.txt` and the marketplace manifest
- [ ] `node scripts/validate-skills.mjs` passes
