# Troubleshooting

## Common Issues and Solutions

### Issue: Worktree Already Exists

**Symptoms:**
```
fatal: '.worktrees/fix-issue-432-rendering' is dirty, use --force to delete it
```
and
```
fatal: '.worktrees/exists' already exists
# OR
fatal: 'feature/x' is already checked out at '/path/to/.worktrees/exists'
```

**Solutions:**

```bash
# Option 1: Use existing worktree
cd "${WORKTREE_PATH}"
# Continue working there

# Option 2: Remove and recreate (if stale)
# Check for work that would be lost first:
git -C "${WORKTREE_PATH}" status --short
git -C "${WORKTREE_PATH}" log --oneline -3
# Only after confirming the above is empty/safe:
git worktree remove "${WORKTREE_PATH}" --force
git worktree prune
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"

# Option 3: Prune stale entries and retry
git worktree prune
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"
```

**Prevention:**
- Always check `git worktree list` before creating
- Use smart detection logic (see SKILL.md)

---

### Issue: Branch Already Exists

**Symptoms:**
```
fatal: A branch named 'fix/issue-432-rendering' already exists.
```

**Solutions:**

```bash
# Option 1: Use existing branch
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"

# Option 2: Reset branch to main and recreate (SAFE VERSION)
# 0. Confirm nothing is lost
git log --oneline "origin/${BRANCH_NAME}..${BRANCH_NAME}"   # must be empty
git -C "${WORKTREE_PATH}" status --short                   # must be empty

# 1. Remove the worktree that holds the branch FIRST
git worktree remove "${WORKTREE_PATH}"   # add --force only if the above is empty

# 2. Now safe to delete
git branch -D "${BRANCH_NAME}"
git branch "${BRANCH_NAME}" origin/main
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"

# Option 3: Check if branch is attached to another worktree
git worktree list | grep "${BRANCH_NAME}"
# If found: work in that worktree instead
```

---

### Issue: Permission Denied

**Symptoms:**
```
mkdir: cannot create directory '.worktrees/...': Permission denied
fatal: could not create leading directories of '.worktrees/...'
```

**Solutions:**

```bash
# Check ownership first
ls -ld "${WORKTREE_PATH}" "$(dirname "${WORKTREE_PATH}")"
# Fix only the specific directory, without sudo:
mkdir -p "${WORKTREE_PATH}"
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"
```

---

### Issue: Uncommitted Changes Warning

**Symptoms:**
```
fatal: 'fix/issue-432-rendering' contains modified or untracked files, use --force to switch branches
```

**Solutions:**

```bash
# In the worktree (not main directory):
cd "${WORKTREE_PATH}"

# Option 1: Stash changes
git stash push -m "WIP before worktree operations"
git worktree remove "${WORKTREE_PATH}"

# Option 2: Commit changes
git add .
git commit -m "WIP: save state"
git worktree remove "${WORKTREE_PATH}"

# Option 3: Force remove (use with caution!)
git worktree remove "${WORKTREE_PATH}" --force
# Note: This discards uncommitted changes!
```

---

### Issue: Directory Exists But Not Registered

**Symptoms:**
```
fatal: '.worktrees/...' is already registered
# OR
# Directory exists but `git worktree list` doesn't show it
```

**Solutions:**

```bash
# If the path is a registered worktree, remove it through git first:
git worktree remove "${WORKTREE_PATH}" --force
git worktree prune
# Only if the path was never registered:
# rm -rf "${WORKTREE_PATH}"
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"
```

---

### Issue: Cannot Remove Main Worktree

**Symptoms:**
```
fatal: cannot remove main working directory
```

**Cause:** Attempting to remove the main repository worktree.

**Solution:**
```bash
# Never remove the main worktree!
# Check which one you're trying to remove:
git worktree list

# Only remove sub-worktrees (paths in .worktrees/)
```

---

### Issue: Network/Fetch Failures

**Symptoms:**
```
fatal: unable to access 'https://github.com/...': Could not resolve host
error: RPC failed; HTTP 500 curl 22 The requested URL returned error: 500
```

**Solutions:**

```bash
# Retry the fetch
git fetch origin main

# If persistent, check connectivity
# Check GitHub API connectivity
gh api rate_limit --jq '.rate.remaining'

# Alternative: Create branch from local main (if up to date)
git branch "${BRANCH_NAME}" origin/main  # or main only if you have verified it is up to date
git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"

# Then sync later when network available
cd "${WORKTREE_PATH}"
git fetch origin
git rebase origin/main
```

---

### Issue: Worktree Shows Wrong Branch

**Symptoms:**
- `cd` into worktree but `git branch` shows different branch
- Changes appear in wrong location

**Solutions:**

```bash
# Verify actual worktree location
git worktree list
pwd

# Ensure you're in the worktree directory
# Not just running commands from main directory with -C flag

# If confused, re-enter clearly:
cd "$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')"  # Go to the main worktree
cd .worktrees/YOUR-WORKTREE-NAME     # Enter specific worktree
pwd && git branch --show-current     # Verify
```

---

### Issue: Slow Worktree Operations

**Symptoms:**
- `git worktree add` takes minutes
- `cd` into worktree is slow
- File operations sluggish

**Causes & Solutions:**

```bash
# Cause 1: Large node_modules copied
# Solution: Don't copy node_modules, reinstall in worktree
rm -rf "${WORKTREE_PATH}/node_modules"
npm install  # Fresh install, faster than copy

# Cause 2: Antivirus scanning
# Solution: Add .worktrees/ to AV exclusion list

# Cause 3: Network drive / slow disk
# Solution: Keep worktrees on local SSD

# Cause 4: Too many worktrees
# Solution: Cleanup old worktrees
for wt in $(git worktree list | grep ".worktrees" | awk '{print $1}'); do
  echo "Size: $(du -sh "$wt" | cut -f1) $wt"
done
```

---

### Issue: Rebase Conflicts in Worktree

**Symptoms:**
```
Auto-merging file.ts
CONFLICT (content): Merge conflict in file.ts
error: could not apply abc1234... commit message
```

**Solutions:**

```bash
cd "${WORKTREE_PATH}"

# View conflict status
git status

# Resolve conflicts in affected files
# Edit files to fix conflicts

# Mark resolved
git add <resolved-files>

# Continue rebase
git rebase --continue

# Or abort if too complex
git rebase --abort
# Try merge instead: git merge origin/main
```

---

## Diagnostic Commands

```bash
# Full worktree status
git worktree list --porcelain

# Verbose branch info
git branch -vv

# Check for lock files
# Check for locked worktrees
find "$(git rev-parse --git-common-dir)/worktrees" -name locked 2>/dev/null
# Or:
git worktree list --porcelain | grep -A1 '^locked$'

# Verify repository integrity
git fsck

# Check disk space
df -h .worktrees/
du -sh .worktrees/*/

# Trace git operations (debug)
GIT_TRACE=1 git worktree add ...
```

## Getting Help

If issues persist:

1. Check git version: `git --version` (**need 2.17+** — this skill uses `git worktree remove`, `lock`, and `unlock`, added in Git 2.17)
2. Verify git configuration: `git config --list | grep worktree`
3. Review git worktree docs: `git help worktree`
4. Check for known issues: Search git mailing list or Stack Overflow
