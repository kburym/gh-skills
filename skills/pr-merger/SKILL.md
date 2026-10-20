---
name: pr-merger
description: |
  Merges approved Pull Requests safely with verification and cleanup. Handles merge 
  conflicts, CI checks, and post-merge cleanup including worktree removal. Use when 
  PR is approved and ready to land, for batch merging, or when completing the PR 
  lifecycle. Triggers on requests like "merge PR", "land PR", "merge approved PRs", 
  or "complete task". **PR merged = Definition of Done achieved**.
---

# PR Merger

Safely merges approved PRs with full verification and cleanup.

## Overview

**Purpose**: Achieve Definition of Done by merging approved PRs to main.

**Critical Rule**: PR merged = DONE. Creating a PR or getting approval is NOT completion.

## When to Use

Use this skill when:
- PR is approved and ready to merge
- User requests "merge PR", "land PR", "complete task"
- Batch merging multiple approved PRs
- Completing the PR lifecycle
- Cleaning up after merge (worktrees, branches)

## Definition of Done

| Stage | Status | DoD Met? |
|-------|--------|----------|
| Issue linked | ✅ Required | No |
| PR opened | ⏳ Intermediate | No |
| PR approved | ⏳ Intermediate | No |
| **PR merged** | ✅ **DONE** | **YES** |

**Success Criteria**:
1. ✅ PR shows as **MERGED** on GitHub
2. ✅ Merge commit exists on main branch
3. ✅ Code is in production path

## Prerequisites

Before merging, verify ALL of:
- [ ] PR has approval review
- [ ] CI checks passing (or explicitly bypassed)
- [ ] No merge conflicts with base branch
- [ ] Branch is up to date with main
- [ ] Worktree exists and is clean

## Commands

### 1. Merge Single PR

```
@pr-merger Merge PR #<number>
```

**Workflow**:
1. Verify PR status (approved, CI passing)
2. Check for conflicts
3. Update branch if behind main
4. Merge with squash (default)
5. Verify merge
6. Clean up worktree and branch

### 2. Batch Merge

```
@pr-merger Merge all approved PRs
```

### 3. Merge with Verification

```
@pr-merger Merge PR #<number> and clean up
```

## Merge Strategies

| Strategy | Command | Best For |
|----------|---------|----------|
| **Squash** | `gh pr merge <n> --squash --delete-branch=true` | Feature branches with many commits |
| **Merge** | `gh pr merge <n> --merge --delete-branch=true` | Long-lived branches |
| **Rebase** | `gh pr merge <n> --rebase --delete-branch=true` | Clean linear history |

## Cleanup Process

### Worktree Removal

```bash
# Get branch name
branch_name=$(gh pr view <pr-number> --json headRefName -q .headRefName)

# Find worktree path
worktree_path=$(git worktree list --porcelain | \
  grep -B1 "branch refs/heads/$branch_name" | head -1 | sed 's/worktree //')

# Remove worktree
if [ -n "$worktree_path" ]; then
  git worktree remove "$worktree_path" 2>/dev/null || \
    git worktree remove --force "$worktree_path"
fi
```

### Branch Cleanup

```bash
# Switch to main
git checkout main 2>/dev/null || git checkout master 2>/dev/null

# Delete local branch
git branch -D "$branch_name" 2>/dev/null || true

# Prune remote references
git fetch --prune origin 2>/dev/null || true
```

## Conflict Resolution

### Auto-Resolve (Simple Cases)

For conflicts in `package.json`, `CHANGELOG`, `VERSION`:
```bash
git checkout --ours <files>
git add <files>
git commit -m "Merge main into <branch> - auto-resolved"
git push origin <branch>
```

### Manual Resolution

```
⚠️ Merge Conflict Detected

PR #<n> has conflicts with main:
- Conflicting files: <list>
- Worktree: <path>

Options:
1. Resolve manually in worktree, then retry merge
2. Ask pr-manager to rebase and retry
3. Request author to resolve
```

## Error Handling

### CI Failure

```
❌ PR #<n> CI status: FAILURE

Failed checks:
- test/unit (failed)
- lint (passed)

Action required: Fix tests before merging
```

### Merge Failed

```
❌ Merge failed for PR #<n>

Possible causes:
- Branch protection rules
- Required reviews not met
- Status checks failing
- Merge conflicts

Details: <error message>
```

## Integration

**Called by**:
- pr-manager (batch merging approved PRs)
- pr-workflow-orchestrator (completing workflow)
- User for single PR merge

**Calls to**:
- GitHub CLI for merge operations
- Git for worktree cleanup
- Test runner for verification

**Reports to**:
- pr-manager for queue updates
- User for completion status

## References

- [Merge Strategies](references/merge-strategies.md) - Detailed strategy selection
- [Conflict Resolution](references/conflict-resolution.md) - Handling merge conflicts
- [Cleanup Procedures](references/cleanup-procedures.md) - Post-merge cleanup
