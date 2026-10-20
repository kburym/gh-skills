# Best Practices

## Coordination Patterns

### Worktree Management
- Use isolated worktrees for every task (no git checkout pollution)
- Name worktrees consistently: `.worktrees/<branch-name>`
- Remove worktrees immediately after merge
- Never work directly in main workspace

### PR Lifecycle Management
- Always create PR with linked issue
- Immediately dispatch feedback handler after opening
- Monitor every 2 minutes until merged
- Never let PR sit idle > 30 minutes without action

### Feedback Response Priority
1. **Critical** (0-5 min): Security issues, breaking changes
2. **High** (5-10 min): Requested changes, CI failures
3. **Medium** (10-15 min): Questions, nitpicks, merge conflicts
4. **Low** (document): Out of scope requests, minor suggestions

## Monitoring Guidelines

### PR Health Check (Every 2 Minutes)
```bash
# Check status
gh pr view <number> --json state,mergeStateStatus,checks

# Check for new reviews
gh pr reviews <number> --json state,author,body

# Check for new comments
gh pr comments <number> --json author,body,createdAt
```

### Stale PR Detection (Every 30 Minutes)
```bash
# Find PRs idle > 30 min
gh pr list --author "@me" --state open --json number,updatedAt \
  | jq '.[] | select((now - (.updatedAt | fromdateiso8601)) > 1800)'
```

**Actions for stale PRs:**
1. Waiting for review → Ping reviewer politely
2. Waiting for CI → Investigate CI status
3. Ready to merge → Proceed to merge
4. Unknown state → Investigate and update

## Communication Best Practices

### User Notifications
Be explicit and actionable:
- ❌ "PR opened"
- ✅ "PR #576 opened, monitoring for reviews..."

- ❌ "Reviews received"
- ✅ "⚡ 2 reviews need immediate attention - dispatching handler..."

- ❌ "Done"
- ✅ "✅ DELIVERY COMPLETE - PR #576 merged to main, worktree cleaned up"

### Feedback Handler Communication
When fixing issues:
1. Acknowledge the comment
2. State what you're doing
3. Do the work
4. Push and confirm
5. Request re-review

Example:
```
"Fixing: Remove unused import on line 45
[commit/push]
✅ Fixed - pushed commit abc123
Requesting re-review from @reviewer"
```

## Examples

### Example 1: Simple Fix with No Feedback
```
User: Start task fix/issue-432
→ Worktree created at .worktrees/fix-issue-432

[Developer works]

User: Open PR
→ PR #576 opened
→ Monitoring for reviews...

[2 min pass - no reviews]
[5 min pass - no reviews]
[CI passes]

→ PR #576 ready to merge
→ Merging...
→ ✅ PR #576 merged
→ 🧹 Worktree removed
→ ✅ DELIVERY COMPLETE
```

### Example 2: Fix with Feedback
```
User: Start task fix/issue-432
→ Worktree created

[Developer works]

User: Open PR
→ PR #576 opened
→ Monitoring...

[Review received after 3 min]
→ ⚡ 1 review received
→ pr-feedback-handler dispatched
→ Processing: "Remove unused import"
→ Fixed, pushed, re-review requested

[5 min pass - approved]
→ PR approved, CI passing
→ Merging...
→ ✅ PR #576 merged
→ ✅ DELIVERY COMPLETE
```

### Example 3: Parallel Delivery
```
User: Deliver issues #432, #444, #445

→ Creating 3 worktrees in parallel
  [worktree-1] [worktree-2] [worktree-3]

[All developers work]

→ Opening 3 PRs in parallel
  PR #576, #577, #578 opened

→ Dispatching 3 feedback handlers
  All monitoring...

[Feedback handled for all]

→ Merging 3 PRs
  All merged ✅

→ Cleaning 3 worktrees
  All cleaned 🧹

→ ✅ ALL DELIVERIES COMPLETE
   - PR #576: Dialog fix merged
   - PR #577: DB check merged
   - PR #578: Schema alignment merged
```

## Anti-Patterns to Avoid

❌ Opening PR without dispatching feedback handler
❌ Leaving PR open without monitoring
❌ Not tracking PR state
❌ Considering "PR opened" as complete
❌ Abandoning PR if feedback handler fails
❌ Not cleaning up worktrees after merge
❌ Manual git checkout instead of worktrees
