---
name: template-skill
description: Replace this with what the skill does and when to use it. Use when the user asks for X.
---

# Template skill

One sentence on what this skill does, and one on when the agent should reach
for it.

## When to use

- The trigger conditions, as a list.
- When **not** to use it, and which skill to use instead.

## Workflow

### Step 1: <name>

```bash
# the exact command, with a real flag that exists
```

### Step 2: <name>

```bash
```

## Safety rules

- What must be true before a destructive action.
- What the skill must never do (force push, `--admin`, `branch -D`, …).
- When to stop and ask a human.

## Failure handling

| Situation | What to do |
|-----------|-----------|
| Command fails | … |
| Command not found | … |
| Permission denied | … |

## References

- [Acceptance Criteria](references/acceptance-criteria.md) — required behaviour and validation
- [Best Practices](references/best-practices.md) — judgement calls and tone
