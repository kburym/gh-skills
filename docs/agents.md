# Agent support

These skills are plain `SKILL.md` folders. Any agent that looks for a folder
containing a `SKILL.md` can load them — the collection does not depend on a
Claude-only layout.

## Where each agent looks

| Agent | Directory |
|-------|-----------|
| Claude Code | `.claude/skills/` (global: `~/.claude/skills/`) |
| Codex, generic agents | `.agents/skills/` (global: `~/.agents/skills/`) |
| Cursor | `.cursor/skills/` |
| opencode | `.opencode/skills/` (global: `~/.config/opencode/skills/`) |
| Claude Code plugin | installed via the marketplace — no directory to manage |

`install.sh` knows all of these:

```bash
# project scope (default) — links into ./.claude/skills and ./.agents/skills
curl -fsSL https://raw.githubusercontent.com/odykyi/gh-skills/main/install.sh | sh -s -- --agent claude --project

# user scope — links into ~/.claude/skills
curl -fsSL https://raw.githubusercontent.com/odykyi/gh-skills/main/install.sh | sh -s -- --agent claude --global

# opencode, project scope
curl -fsSL https://raw.githubusercontent.com/odykyi/gh-skills/main/install.sh | sh -s -- --agent opencode --project
```

The installer only ever creates **symlinks**. It never copies markdown, never
uses `sudo`, and it removes its own stale links on re-run.

## Claude Code plugin

This repository is a plugin marketplace:

```
/plugin marketplace add odykyi/gh-skills
/plugin install gh-skills@gh-skills
```

Or browse it in Claude Code with `Browse and install plugins`.

## The skills CLI

```bash
npx skills add odykyi/gh-skills            # install into the detected agent
npx skills add odykyi/gh-skills --list     # show what is available
npx skills use odykyi/gh-skills/pr-merger  # generate a prompt without installing
```

## Other agents

Everything the skills do is expressed as `gh` and `git` commands, so any agent
with a shell and those two binaries can execute them. The skills reference the
agents by name in the form `@pr-merger`, `@pr-reviewer`, and so on — that is
the convention the collection uses internally, and it maps onto whatever
sub-agent mechanism your agent provides.

## Requirements

| Requirement | Why |
|-------------|-----|
| `gh` CLI, authenticated | every GitHub operation |
| `git` 2.17+ | `git worktree remove`, `lock`, `unlock` |
| Node.js 18+ | only for `scripts/validate-skills.mjs` (contributors) |
| Graphviz | only to rebuild the diagram (contributors) |

Check them with:

```bash
gh auth status
git --version
```
