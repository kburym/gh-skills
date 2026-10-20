---
name: pr-opener
description: |
  Creates Pull Requests with proper formatting, descriptions, and mandatory issue 
  linking. Use when the user wants to open a PR, create a pull request, push and PR, 
  or submit completed work. **REQUIRED PRE-CONDITION**: Every PR MUST have a linked 
  GitHub issue - this is enforced, never open a PR without an issue. Coordinates with 
  pr-labeler for automatic label application.
---

# PR Opener

Creates PRs with proper formatting, descriptions, and mandatory issue linking.

## Overview

**Purpose**: Open PRs that tell a complete story - what changed, why it changed, and how to verify.

**Core Principle**: Issue-first workflow. You cannot create a PR without first having a linked issue.

## When to Use

Use this skill when:
- User wants to open a PR
- Creating a pull request from a branch
- Pushing and creating PR
- Submitting completed work
- Converting work to a PR with proper formatting

## Definition of Done (DoD)

| Check | Required | Verification |
|-------|----------|--------------|
| Issue exists | ✅ Yes | Search for existing or create new |
| PR references issue | ✅ Yes | `Closes #N` in title and body |
| Issue references PR | ✅ Yes | Comment on issue with PR link |
| Labels applied | ✅ Yes | Dispatch pr-labeler |
| Branch pushed | ✅ Yes | `git push -u origin <branch>` |

## Workflow

### Step 1: Check for Linked Issue (MANDATORY)

**Search strategies**:
```bash
# Extract task ID from branch name
git branch --show-current
grep -oE "[A-Z]+-[0-9]+" <<< "$(git branch --show-current)"

# Search GitHub issues
gh issue list --search "$(git branch --show-current)" --state all
gh issue list --search "<TASK-ID>" --state all
```

**Decision**:
- ✅ Issue exists → Proceed to Step 2
- ❌ No issue → Create issue first (Step 1B)

### Step 2: Create Issue (If Missing)

```bash
branch=$(git branch --show-current)
task_id=$(echo "$branch" | grep -oE "[A-Z]+-[0-9]+" || echo "")

if [ -n "$task_id" ]; then
  title="$task_id: ${branch//-/ }"
else
  title=$(git log --oneline origin/main..HEAD --reverse | head -1 | cut -d' ' -f2-)
fi

gh issue create --title "$title" --body "..." --label "enhancement"
```

### Step 3: Create PR with Issue Link

**PR Title Format**:
```
<type>: <Description> (Closes #<issue-number>)
```

**Examples**:
- `feat: Add Stripe payment (Closes #42)`
- `fix: Resolve 404 on settings page (Closes #73)`
- `refactor: Extract service logic (Closes #55)`

**Create PR**:
```bash
gh pr create --title "<type>: <Description> (Closes #${issue_number})" --body "
## Summary
Brief description of what changed

## Implementation
- Key change 1
- Key change 2

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Definition of Done
- ✅ Issue exists and is linked
- ✅ PR references issue with 'Closes #${issue_number}'

## Related
**Closes #${issue_number}**
- Issue: #${issue_number}
- Branch: ${branch}
"
```

### Step 4: Link PR to Issue

```bash
# Add PR link to issue
gh issue comment "$issue_number" --body "PR created: ${pr_url}"
```

### Step 5: Apply Labels

```bash
pr_number=$(gh pr view "$branch" --json number --jq '.number')
pr-labeler auto-label "$pr_number"
```

## Commands

### 1. Open PR

```
@pr-opener Open PR for <branch-name>
```

**Workflow**:
1. Verify/create issue
2. Push branch
3. Create PR with `Closes #N`
4. Link PR to issue
5. Apply labels via pr-labeler

### 2. Open PR with Issue

```
@pr-opener Open PR for <branch-name> with issue #<number>
```

### 3. Verify DoD

```
@pr-opener Verify DoD for PR #<number>
```

## Error Handling

### PR Already Exists

```
⚠️ PR already exists: https://github.com/.../pull/123

Checking for issue link...
❌ Missing issue link in existing PR

Action: Creating issue and updating PR...
✅ Updated PR #123 with issue link #45
```

### No Issue Found

```
❌ CANNOT PROCEED

No issue exists for this work.

Required Actions:
1. Manually create issue on GitHub
2. Re-run pr-opener with issue number
3. Or provide issue number: @pr-opener open PR #<number>
```

## Integration

**Called by**:
- Super orchestrator (after work completion)
- pr-manager (batch operations)
- User (manual PR creation)

**Calls to**:
- issue-reporter (if issue needs tracking)
- pr-labeler (to apply labels)

**Pre-requisites**:
- Code committed
- Tests passing
- Issue exists (or will be created)

## References

- [DoD Standards](references/dod-standards.md) - Definition of Done details
- [Issue Creation](references/issue-creation.md) - Creating issues for PRs
- [Label Integration](references/label-integration.md) - pr-labeler coordination
