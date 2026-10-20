---
name: pr-labeler
description: |
  Automates PR label assignment and management throughout the PR lifecycle. 
  Use when auto-labeling new PRs based on branch names and file changes, calculating 
  PR size labels, managing status labels, running label hygiene checks, or 
  performing bulk label operations across multiple PRs. Works with pr-manager and 
  pr-opener for orchestration at scale.
---

# PR Labeler

Automates PR label assignment and management throughout the PR lifecycle.

## Overview

**Purpose**: Maintain consistent, accurate labeling across all PRs with zero manual intervention.

## When to Use

Use this skill when:
- Auto-labeling new PRs based on branch names and files
- Calculating and updating PR size labels (XS/S/M/L/XL)
- Managing status label lifecycle (wip → ready-for-review → approved → merged)
- Running label hygiene checks across all PRs
- Performing bulk label operations on multiple PRs

## Label Categories

### Type Labels (from branch name)

| Branch Pattern | Label |
|----------------|-------|
| `feature/*` | `feature` |
| `fix/*`, `bugfix/*` | `bug` |
| `hotfix/*` | `hotfix` + `P0-critical` |
| `refactor/*` | `refactor` |
| `docs/*` | `documentation` |
| `security/*` | `security` + `security-review` |
| `performance/*` | `performance` |
| `deps/*` | `dependencies` |

### Size Labels (auto-calculated from diff)

| Lines Changed | Label |
|---------------|-------|
| < 50 lines | `size/XS` |
| 50-100 lines | `size/S` |
| 100-300 lines | `size/M` |
| 300-500 lines | `size/L` |
| > 500 lines | `size/XL` |

### Team Labels (from file paths)

| File Pattern | Label |
|--------------|-------|
| `frontend/**`, `*.tsx` | `team/frontend` |
| `backend/**`, `api/**`, `server/**` | `team/backend` |
| `infra/**`, `docker/**`, `*.yml` | `team/devops` |
| `tests/**`, `**/*.test.*`, `**/*.spec.*` | `team/qa` |
| `security/**`, `**/auth/**` | `team/security` |

### Domain Labels (from branch/files)

| Pattern | Label |
|---------|-------|
| `*api*` | `domain/api` |
| `*auth*` | `domain/auth` |
| `*payment*` | `domain/payment` |
| `*ui*` | `domain/ui` |
| `*docs*` | `domain/docs` |

## Commands

### 1. Auto-Label PR

```
@pr-labeler auto-label <PR_NUMBER>
```

**Actions**:
1. Detect branch name
2. Analyze file changes
3. Calculate size from diff
4. Apply all matching labels

### 2. Update Status

```
@pr-labeler update-status <PR_NUMBER> <NEW_STATE>
```

**States**: `wip`, `ready-for-review`, `changes-requested`, `approved`, `ci-failing`, `awaiting-qa`, `qa-passed`, `blocked`

### 3. Hygiene Check

```
@pr-labeler hygiene-check
```

**Output**:
```
Label Hygiene Report
═══════════════════════════════════════

PRs Missing Required Labels:
┌─────────┬──────────────────┬─────────────────────────┐
│ PR      │ Title            │ Missing                 │
├─────────┼──────────────────┼─────────────────────────┤
│ #201    │ Add payment      │ size/, team/            │
│ #202    │ Fix auth bug     │ priority, component/    │
└─────────┴──────────────────┴─────────────────────────┘

Recommendations:
- 2 PRs need size labels
- 1 PR needs priority label
- 0 PRs have conflicting labels
```

### 4. Bulk Operations

```
@pr-labeler bulk-add <LABEL> --filter "P1-high"
@pr-labeler bulk-remove <LABEL>
```

## GitHub CLI Commands

```bash
# Add labels
gh pr edit <PR_NUMBER> --add-label "bug,P1-high,team/backend"

# Remove labels
gh pr edit <PR_NUMBER> --remove-label "status/wip"

# List PRs by label
gh pr list --label "P1-high" --label "status/ready-for-review"

# Get PR labels
gh pr view <PR_NUMBER> --json labels
```

## Best Practices

1. **Every PR MUST have**: type + priority + size + team/domain labels
2. **Hotfixes automatically get** `P0-critical` priority
3. **Status labels must be updated immediately** when state changes
4. **XL PRs (>500 lines)** require 2+ reviewers

## Label Standards

Label conventions (adjust to your repository label set):

| Category | Labels |
|----------|--------|
| **Type** | bug, feature, enhancement, documentation, refactor, performance, security, dependencies, testing, devops, config, ui, breaking |
| **Priority** | P0-critical, P1-high, P2-medium, P3-low |
| **Status** | status/wip, status/ready-for-review, status/changes-requested, status/approved, status/blocked, status/ci-failing, status/awaiting-qa, status/qa-passed |
| **Size** | size/XS, size/S, size/M, size/L, size/XL |
| **Team** | team/frontend, team/backend, team/devops, team/qa, team/security, team/platform, team/database, team/product |
| **Domain** | domain/api, domain/auth, domain/payment, domain/ui, domain/docs, domain/data, domain/infra |

## Integration

**Called by**:
- pr-opener (after PR creation)
- pr-manager (batch operations)
- User (manual labeling)

**Calls to**:
- GitHub CLI for label operations

**Reports to**:
- pr-manager for batch status
- User for hygiene reports

## References

- [Label Detection Rules](references/label-detection-rules.md) - Complete detection patterns
- [Size Calculation](references/size-calculation.md) - Diff analysis for sizing
- [Hygiene Standards](references/hygiene-standards.md) - Label quality criteria
- [Bulk Operations](references/bulk-operations.md) - Mass labeling workflows
