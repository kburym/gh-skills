---
name: pr-workflow-orchestrator
description: Orchestrates the complete PR workflow from worktree creation through PR feedback resolution and merge. Coordinates pr-worktree, pr-opener, pr-feedback-handler, and pr-merger subagents. NEVER leaves PRs unattended - always monitors, handles feedback, and drives to merge. Use for end-to-end task management.
---

# PR Workflow Orchestrator

Coordinates the complete development-to-merge lifecycle using four specialized subagents.

## Overview

The PR Workflow Orchestrator manages the entire lifecycle of a Pull Request from task inception through merge completion. It ensures no PR is left unattended by continuously monitoring, handling feedback, and driving to completion.

**Definition of Done**: PR is **MERGED** or explicitly **CLOSED** with documented reason.

## When to Use

- Starting work on a new task ("Start task X")
- Creating and managing PRs ("Open PR", "Complete delivery")
- Handling PR review feedback ("Handle feedback for PR #N")
- Coordinating multiple parallel PRs
- Ensuring PRs reach completion (merged, not just opened)

## Subagents

| Subagent | Responsibility |
|----------|---------------|
| **pr-worktree** | Creates isolated worktrees for new tasks |
| **pr-opener** | Opens PRs when work is complete |
| **pr-feedback-handler** | **MANDATORY** - Processes all PR comments/reviews |
| **pr-merger** | **MANDATORY** - Merges approved PRs |

## Key Workflows

### Complete Delivery (Single Task)

```
User: @super Deliver fix for issue #432

Orchestrator:
1. Dispatch pr-worktree
   → Worktree: .worktrees/fix-issue-432-dialog-props

2. [Developer works in worktree...]

3. Dispatch pr-opener
   → PR #576 opened

4. IMMEDIATELY dispatch pr-feedback-handler
   → Monitor for reviews (2-min check cycle)

5. Handle any feedback → Fix or reply

6. Dispatch pr-merger
   → PR #576 merged ✅

7. Cleanup worktree

8. Report: "✅ DELIVERY COMPLETE"
```

### Parallel Delivery (Multiple Tasks)

```
User: @super Deliver:
- Issue #432: Dialog fix
- Issue #444: DB check
- Issue #445: Schema alignment

Orchestrator:
1. Create 3 worktrees in parallel
2. Open 3 PRs in parallel
3. DISPATCH 3 pr-feedback-handlers (MANDATORY)
4. Monitor all continuously
5. MERGE all 3 before complete
```

## Critical Rules

### 🚨 NEVER Leave PRs Unattended

- ✅ Always monitor PRs after opening
- ✅ Always handle review feedback immediately
- ✅ Always drive PRs to completion
- ✅ Never leave a PR in "open and waiting" state

### Mandatory Feedback Handling

When a PR opens:
1. Wait 2 minutes for initial reviews
2. **ALWAYS** dispatch pr-feedback-handler
3. Process all comments immediately
4. Continue monitoring every 2 minutes

**Auto-Handling Time Limits:**

| Review Type | Action | Time Limit |
|-------------|--------|------------|
| Requested changes | Fix immediately | 10 min |
| Questions | Answer with evidence | 5 min |
| CI failure | Investigate and fix | 15 min |
| Merge conflict | Rebase and fix | 15 min |

### Merge Criteria

**Merge when:**
- ✅ All feedback addressed
- ✅ CI passing
- ✅ No merge conflicts
- ✅ Minimum 1 approval
- ✅ Linked issue referenced

**Escalate when:**
- ❌ Breaking changes without plan
- ❌ Security concerns
- ❌ Architecture disagreement

## User Notifications

| Stage | Notification |
|-------|--------------|
| Worktree created | "Ready to work at <path>" |
| PR opened | "PR #<N> opened, monitoring..." |
| Review received | "⚡ <N> reviews need attention" |
| Feedback handled | "✅ Fixed <X>, replied to <Y>" |
| Ready to merge | "🚀 PR #<N> ready - merging..." |
| Merged | "✅ DELIVERY COMPLETE" |

## Commands Summary

| Command | Purpose | Mandatory Follow-up |
|---------|---------|---------------------|
| `Start task` | Create worktree | None |
| `Open PR` | Push & create PR | pr-feedback-handler |
| `Handle feedback` | Process reviews | Continue monitoring |
| `Complete delivery` | Merge & cleanup | pr-merger + cleanup |

## Escalation Path

| Issue | Escalate To |
|-------|-------------|
| Technical disagreement | code-reviewer |
| Complex refactor | super orchestrator |
| Security concerns | security-engineer |
| Architecture concerns | plan-eng-review |
| No reviewer response (24h) | super orchestrator |

## Success Metrics

- **0 unattended open PRs**
- **100% of PRs merged** (not just opened)
- **< 5 min response time** to new reviews
- **< 30 min idle time** for any PR

## References

- [Acceptance Criteria](references/acceptance-criteria.md) - Functional requirements and orchestration patterns
- [Best Practices](references/best-practices.md) - Coordination patterns and monitoring guidelines
- [Workflow Patterns](references/workflow-patterns.md) - Scenario-specific orchestration examples

---

**Remember: This orchestrator's job is NOT done until the PR is merged and the worktree is cleaned up. Never leave a PR behind.**
