---
name: pr-manager
description: |
  Orchestrates multiple PRs in parallel with strict Definition of Done enforcement. 
  Use when managing 3+ PRs simultaneously, batch PR operations, prioritizing PRs, 
  handling PRs at scale, or coordinating complete PR lifecycle from open to merge. 
  Coordinates pr-opener, pr-reviewer, pr-feedback-handler, and pr-merger subagents.
---

# PR Manager

Orchestrates multiple PRs in parallel with strict DoD enforcement.

## Overview

**Purpose**: Manage the complete PR lifecycle when dealing with multiple PRs simultaneously.

**Core Principle**: PR merged = Definition of Done. Creating a PR is NOT completion.

## When to Use

Use this skill when:
- Managing 3 or more PRs simultaneously
- Orchestrating batch PR operations
- Prioritizing PRs with dependencies
- Handling PRs at scale across teams
- Coordinating complete PR lifecycle (open → merge)
- Managing OKR-driven parallel development

## Definition of Done (DoD)

| Stage | Status | Requirements |
|-------|--------|--------------|
| Issue Exists | ✅ Required | GitHub issue created and linked |
| PR Opened | ⏳ Intermediate | PR created with `Closes #<issue>` |
| PR Approved | ⏳ Intermediate | Review completed, approved |
| **PR MERGED** | ✅ **DONE** | Code in main branch |

**Enforcement Rules**:
- ❌ No issue = Task BLOCKED
- ❌ PR opened without issue = INCOMPLETE
- ❌ PR approved but not merged = INCOMPLETE
- ✅ Issue linked + PR merged = COMPLETE

## Commands

### 1. Manage Batch PRs

```
@pr-manager Manage PRs for tasks:
- TASK-1: Branch feature/payment
- TASK-2: Branch feature/auth
- TASK-3: Branch fix/bug-404
```

**Workflow**:
1. Phase 1: Verify issues exist (create if missing)
2. Phase 2: Create PRs with issue links
3. Phase 3: Monitor and handle feedback
4. Phase 4: Merge when approved

### 2. Monitor All Open PRs

```
@pr-manager Monitor all open PRs
```

**Output**:
```
PR Manager Dashboard
═══════════════════════════════════════════

DoD Compliance: 17/17 PRs (100% ✅)

Active PRs: 17
┌─────────┬───────────────────────────┬──────────────┬─────────┬──────────┐
│ PR      │ Task                      │ Status       │ Issue   │ DoD      │
├─────────┼───────────────────────────┼──────────────┼─────────┼──────────┤
│ #264    │ INF-1: Tilt Docker        │ ✅ Merged    │ #40     │ ✅ MET   │
│ #277    │ O2-10: Stripe Payment     │ 🔄 Feedback  │ #41     │ ✅ MET   │
│ #278    │ O2-11: Payment UI         │ ⏳ Approved   │ #42     │ ✅ MET   │
└─────────┴───────────────────────────┴──────────────┴─────────┴──────────┘
```

### 3. Prioritize PRs

```
@pr-manager Prioritize PRs by: <criteria>
```

**Criteria**: `age`, `urgency`, `dependencies`, `dod-status`, `size`

**Priority Algorithm**:
```javascript
function calculatePriority(pr) {
  let score = 0;
  if (!pr.hasIssueLink) score += 1000;  // DoD violation = highest
  score += daysOpen(pr) * 10;
  if (pr.category === 'INF') score += 100;
  if (pr.category === 'O1') score += 80;
  score -= (pr.linesChanged / 100);
  return score;
}
```

### 4. Review and Merge Approved PRs

```
@pr-manager Review and merge approved PRs
```

### 5. PR Dashboard

```
@pr-manager PR dashboard
```

## Subagents Coordinated

| Subagent | Responsibility |
|----------|----------------|
| pr-opener | Creates PRs with mandatory issue linking |
| pr-reviewer | Reviews PRs for quality, security, performance |
| pr-commenter | Posts structured comments and replies |
| pr-feedback-handler | Processes incoming comments per PR |
| pr-merger | Merges approved PRs |
| issue-reporter | Creates issues if missing |

## DoD Enforcement at Scale

### Missing Issue Cascade (5+ branches)

1. **STOP** all PR creation
2. Batch create issues for all branches
3. Report: "Created N issues for DoD compliance"
4. Resume PR creation with issue links

### DoD Violation Wave

When base policy changes:
1. Scan all open PRs
2. Identify PRs without issue links
3. Batch fix: Create issues + Update PRs
4. Report: "Fixed N PRs for DoD compliance"

## Best Practices

1. **Always verify issues first** - Before any batch operation
2. **Link bidirectionally** - PR references issue, issue references PR
3. **Monitor continuously** - Check for new comments every 3 minutes
4. **Merge when ready** - Approved + CI passing = merge
5. **Report metrics** - Track DoD compliance rate

## Integration

**Called by**:
- Super agent (batch operations)
- User for multi-PR management
- Scheduled jobs for monitoring

**Calls to**:
- pr-opener, pr-reviewer, pr-commenter
- pr-feedback-handler, pr-merger
- issue-reporter

**Reports to**:
- User via dashboard
- Super agent for coordination

## References

- [Acceptance Criteria](references/acceptance-criteria.md) - DoD standards and quality gates
- [Best Practices](references/best-practices.md) - PR orchestration patterns
- [Workflow Examples](references/workflow-examples.md) - Real-world batch operations
- [DoD Enforcement](references/dod-enforcement.md) - Definition of Done details
