# Best Practices

## Naming Conventions

### Branch Naming
```
<type>/issue-<number>-<short-description>

Types:
- fix/       Bug fixes
- feature/   New features  
- refactor/  Code refactoring
- docs/      Documentation changes
- hotfix/    Emergency production fixes

Examples:
- fix/issue-432-button-rendering
- feature/issue-444-db-health-check
- hotfix/security-patch-auth
```

### Worktree Directory Naming
```
.worktrees/<type>-issue-<number>-<short-description>

Examples:
- .worktrees/fix-issue-432-button-rendering
- .worktrees/feature-issue-444-db-health-check
- .worktrees/hotfix-security-patch-auth
```

### Special Cases
```
# Reviewing someone else's PR
.worktrees/pr-<number>-<contributor>-<description>

# Hotfixes (keep separate from regular work)
.worktrees/hotfix-<timestamp>-<description>

# Experiments (disposable)
.worktrees/exp-<description>-<timestamp>
```

## Parallel Work Management

### Maximum Parallel Worktrees
- Recommended: 3-5 simultaneous worktrees
- Maximum practical: 8-10 (beyond this becomes hard to track)
- Clean up merged PRs promptly to stay under limits

### Organization Strategies

**By Terminal/Window:**
```bash
# Terminal 1 - Main feature work
cd .worktrees/feature-issue-444-db-check

# Terminal 2 - Bug fix
cd .worktrees/fix-issue-432-rendering

# Terminal 3 - Hotfix (urgent)
cd .worktrees/hotfix-security-patch
```

**By IDE Workspace:**
- Open each worktree as separate folder in IDE
- Switch between windows for different PRs
- Keeps search/find operations isolated per PR

**By Task Context:**
```bash
# Morning: feature work
cd .worktrees/feature-issue-444-db-check

# Afternoon: review PR
.cd .worktrees/pr-500-contributor-fix

# Evening: hotfix
cd .worktrees/hotfix-security-patch
```

### Context Switching Workflow
```bash
# 1. Stash or commit current work
git stash push -m "WIP: context switch"

# 2. Switch worktree
cd ../other-worktree

# 3. Resume work there
# ...

# 4. Return and restore
cd ../previous-worktree
git stash pop
```

## Cleanup Strategies

### Immediate Cleanup (After Merge)
```bash
# Within 5 minutes of PR merge
git worktree remove "${WORKTREE_PATH}"
git branch -d "${BRANCH_NAME}"
```

### Daily Cleanup (End of Day)
```bash
# Check for merged PRs and cleanup
for wt in $(git worktree list | grep ".worktrees" | awk '{print $1}'); do
  # Check if branch is merged to main
  branch=$(git worktree list | grep "$wt" | awk '{print $3}')
  if git branch -r --merged main | grep "$branch"; then
    echo "Cleanup: $wt (branch merged)"
    git worktree remove "$wt"
    git branch -d "$branch"
  fi
done
```

### Weekly Cleanup (Maintenance)
```bash
# Prune all stale worktrees
git worktree prune

# Check for orphaned directories
ls -la .worktrees/
# Remove any directories not in `git worktree list`

# Fetch and prune remote branches
git fetch --prune
```

### Safety Rules for Cleanup
1. **Always verify PR merged** before removing worktree
2. **Commit or stash uncommitted changes** before removal
3. **Check no processes are using directory** (IDE, terminal, server)
4. **Keep hotfix worktrees longer** (may need quick reference)
5. **Document why if keeping merged worktrees** (add note to manifest)

## Worktree Manifest Tracking

Create `.worktrees/manifest.json` for tracking:

```json
{
  "version": "1.0",
  "lastUpdated": "2026-04-01T10:00:00Z",
  "worktrees": [
    {
      "path": ".worktrees/fix-issue-432-button-rendering",
      "branch": "fix/issue-432-button-rendering",
      "issue": 432,
      "prNumber": 567,
      "status": "in-review",
      "created": "2026-03-31T10:00:00Z",
      "description": "Fix Button props in UI"
    },
    {
      "path": ".worktrees/feature-issue-444-db-check",
      "branch": "feature/issue-444-db-health-check",
      "issue": 444,
      "status": "in-progress",
      "created": "2026-04-01T08:00:00Z",
      "description": "Add database health check endpoint"
    }
  ]
}
```

## Integration Patterns

### With pr-opener
```bash
# 1. Create worktree (pr-worktree)
# 2. Make changes in worktree
# 3. Hand off to pr-opener:
#    - Push branch
#    - Create PR
#    - Add labels
#    - Link issue
```

### With pr-feedback-handler
```bash
# When PR receives comments:
# 1. Enter worktree
cd "${WORKTREE_PATH}"

# 2. Apply fixes
# ...

# 3. Commit and push
git add . && git commit -m "address review feedback"
git push origin "${BRANCH_NAME}"

# 4. Reply to comments via pr-feedback-handler
```

### With qa
```bash
# Before creating PR:
cd "${WORKTREE_PATH}"
qa --path="${WORKTREE_PATH}"

# Only if tests pass:
# → proceed to pr-opener
# If tests fail:
# → fix in worktree → re-run qa → repeat
```

## Disk Space Management

### Monitor Worktree Sizes
```bash
# Check worktree disk usage
du -sh .worktrees/*/

# Set up alerts if > 1GB per worktree
# Typical worktree size: 50-200MB (without node_modules)
# With node_modules: 300-800MB
```

### Exclude Patterns
Add to `.worktrees/.gitignore` (if tracking worktrees):
```
*/node_modules/
*/dist/
*/build/
*/.cache/
*/coverage/
```

### Cleanup Thresholds
- Auto-cleanup: PRs merged > 7 days
- Manual review: PRs merged 3-7 days
- Keep active: In-progress, in-review, hotfixes
