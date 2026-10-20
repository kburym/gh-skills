---
name: pr-worktree
description: Creates and manages isolated git worktrees for PR workflows. Uses worktrees exclusively—never checkout—to avoid disrupting the main working directory. Handles branch creation, worktree setup, and PR lifecycle management. Enables parallel PR development with clean isolation and safe cleanup.
---

# PR Worktree

**Core Principle**: Use `git worktree` exclusively. Never `git checkout`.

Worktrees provide isolated directories for each PR while keeping your main working directory untouched. This enables parallel development on multiple PRs without stash/reset conflicts.

## When to Use

- Starting work on a new PR
- Fixing issues in an existing PR branch  
- Working on multiple PRs simultaneously
- Reviewing someone else's PR locally
- Hotfixing production issues
- Any git work that requires isolation from main

## Quick Start

### Create New PR Worktree

```bash
# Parse issue/task: type, issue number, description
BRANCH_TYPE="fix"  # fix|feature|refactor|docs|hotfix
ISSUE_NUM="432"
DESC="button-rendering"
BRANCH_NAME="${BRANCH_TYPE}/issue-${ISSUE_NUM}-${DESC}"
WORKTREE_PATH=".worktrees/$(echo ${BRANCH_NAME} | tr '/' '-')"

# Smart creation (NO checkout in main dir)
git fetch origin main:main
git branch "${BRANCH_NAME}" origin/main
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"

# Start working
cd "${WORKTREE_PATH}"
npm install  # if needed
```

### Work on Existing PR

```bash
# Fetch PR branch without checkout
git fetch origin "${BRANCH_NAME}:${BRANCH_NAME}"
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"
cd "${WORKTREE_PATH}"

# Make changes, commit, push
git add .
git commit -m "fix: resolve rendering issue

- Fixed DialogContent props
- Verified with tests

Closes #432"
git push origin "${BRANCH_NAME}"
```

### Parallel PR Management

```bash
# Create multiple worktrees
git worktree add .worktrees/fix-issue-432-rendering fix/issue-432-rendering
git worktree add .worktrees/feature-issue-444-db-check feature/issue-444-db-check
git worktree add .worktrees/hotfix-security-patch hotfix/security-patch

# Switch between worktrees (main stays clean!)
cd .worktrees/fix-issue-432-rendering     # work on fix
cd ../feature-issue-444-db-check          # work on feature
cd ../hotfix-security-patch                 # work on hotfix
```

### Cleanup After Merge

```bash
# Verify PR merged via API or UI, then cleanup
git worktree remove "${WORKTREE_PATH}"
git branch -d "${BRANCH_NAME}"
git fetch --prune

# Verify
git worktree list
git branch -a | grep "${BRANCH_NAME}"
```

## Smart Detection

Before creating, always check:

```bash
# Worktree exists?
git worktree list | grep "<branch-name>"

# Branch exists?
git branch -a | grep "<branch-name>"

# Directory exists?
ls -la .worktrees/ | grep "<branch-name>"
```

**If worktree exists** → Use it directly  
**If branch exists, no worktree** → Add worktree to existing branch  
**If neither exists** → Create both fresh

## Key Commands Reference

| Task | Command |
|------|---------|
| Create worktree | `git worktree add <path> <branch>` |
| List worktrees | `git worktree list` |
| Remove worktree | `git worktree remove <path>` |
| Prune stale | `git worktree prune` |
| Lock worktree | `git worktree lock <path>` |
| Unlock worktree | `git worktree unlock <path>` |

## Safety Rules

1. **Never `git checkout` in main repo** — Use worktrees instead
2. **Always verify branch state** — Check `git worktree list` before operations
3. **Commit or stash before removing** — Prevent data loss
4. **Use absolute paths in scripts** — Avoid path confusion
5. **Clean up merged PRs** — Remove worktrees after merge to save disk space

## Integration Patterns

**With pr-opener**: After creating worktree and making changes, pr-opener handles pushing, PR creation, and labeling.

**With pr-feedback-handler**: When PR receives comments, switch to worktree, apply fixes, commit, and push updates.

**With qa**: Run QA tests in worktree before creating PR. Only proceed if tests pass.

## Naming Convention

```
.worktrees/fix-issue-XXX-short-desc        # Bug fixes
.worktrees/feature-issue-YYY-feature-name  # New features
.worktrees/hotfix-urgent-desc             # Emergency fixes
.worktrees/pr-NNN-branch-name              # Reviewing others' PRs
```

## Summary

The pr-worktree skill enables:
- ✅ Parallel PR development without conflicts
- ✅ Clean main working directory at all times
- ✅ Fast context switching between PRs
- ✅ Safe experimentation and isolation
- ✅ Easy cleanup after merge

**All achieved without ever using `git checkout`.**

## References

- [Acceptance Criteria](references/acceptance-criteria.md) — Functional requirements, worktree operations, safety checks
- [Best Practices](references/best-practices.md) — Naming conventions, parallel work management, cleanup strategies
- [Troubleshooting](references/troubleshooting.md) — Common issues and solutions
