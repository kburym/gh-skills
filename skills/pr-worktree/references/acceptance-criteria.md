# Acceptance Criteria

## Functional Requirements

### Worktree Creation
- [ ] Check for existing worktree before creating (`git worktree list | grep <branch>`)
- [ ] Check for existing branch before creating (`git branch -a | grep <branch>`)
- [ ] Generate consistent branch names: `<type>/issue-<number>-<description>`
- [ ] Generate consistent worktree paths: `.worktrees/<type>-issue-<number>-<description>`
- [ ] Never use `git checkout` in main working directory
- [ ] Create branch at `origin/main` without switching to it
- [ ] Create worktree that points to the new branch
- [ ] Verify creation with `git worktree list` and `git branch -vv`

### Worktree Operations
- [ ] Support creating worktrees for new branches
- [ ] Support adding worktrees to existing branches
- [ ] Support parallel worktrees (multiple simultaneous)
- [ ] Enable switching between worktrees via `cd` commands
- [ ] Support rebase operations within worktrees (`git rebase main`)
- [ ] Support sync with remote branches (`git pull origin <branch>`)

### Cleanup Operations
- [ ] Verify PR is merged before cleanup
- [ ] Remove worktree directory safely (`git worktree remove <path>`)
- [ ] Delete local branch after worktree removal (`git branch -d <branch>`)
- [ ] Prune remote tracking branches (`git fetch --prune`)
- [ ] Verify cleanup completed successfully

## Safety Checks

### Pre-Creation Checks
- [ ] Verify no uncommitted changes in main directory that could interfere
- [ ] Check disk space availability
- [ ] Verify git repository is clean (no ongoing operations)
- [ ] Validate branch name format compliance

### During Operations
- [ ] All git operations use full paths, not relative where possible
- [ ] Verify worktree directory was actually created
- [ ] Verify branch was created at correct base (`origin/main`)
- [ ] Confirm no checkout occurred in main working directory

### Pre-Cleanup Checks
- [ ] Verify worktree has no uncommitted changes
- [ ] Verify branch has been pushed to remote (or confirm intentional local-only)
- [ ] Confirm PR is merged or explicitly marked for deletion
- [ ] Check that no other processes are using the worktree directory

## Validation Commands

```bash
# Verify worktree exists
git worktree list | grep "${BRANCH_NAME}"

# Verify branch exists and tracks correctly
git branch -vv | grep "${BRANCH_NAME}"

# Verify worktree directory structure
ls -la "${WORKTREE_PATH}"

# Verify clean main directory
git -C "$(git rev-parse --show-toplevel)" status --short

# Verify no checkout pollution
git -C "$(git rev-parse --show-toplevel)" branch --show-current
# Should output: main (or whatever default branch)
```

## Error Conditions

Must handle and report clearly:
- Worktree already exists → Offer to use existing or remove
- Branch already exists → Offer to use existing or recreate
- Directory already exists but not registered → Clean up and recreate
- Permission denied → Report with fix instructions
- Uncommitted changes in worktree → Require stash/commit before removal
- Network issues during fetch → Retry or report
