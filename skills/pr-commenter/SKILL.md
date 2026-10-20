---
name: pr-commenter
description: Posts comments on Pull Requests including line-level comments, general PR comments, and replies to existing threads. Handles comment threading, resolving conversations, and coordinated commenting across multiple PRs. Use when posting review feedback, replying to comments, or managing PR discussions. Triggers on requests like "post comment", "reply to comment", "add line comment", or when pr-reviewer or pr-feedback-handler needs to communicate on PRs.
---

# PR Commenter

Posts structured comments on Pull Requests with support for line-level feedback and threading.

## Workflow

### Step 1: Prepare Comment Content

**Format based on comment type:**

**Line-level comment (on specific code):**
```markdown
**[Category: Quality]** Consider adding error handling

The current implementation doesn't handle the case where `user` is undefined.

**Suggestion:**
```typescript
const user = await getUser(id);
if (!user) {
  throw new NotFoundError(`User ${id} not found`);
}
```
```

**General PR comment:**
```markdown
## Feedback on Test Coverage

The new functionality looks good, but I'd like to see more test coverage:

- [ ] Test case for empty input
- [ ] Test case for maximum boundary
- [ ] Error scenario tests

Once these are added, this will be ready to merge!
```

**Reply to existing comment:**
```markdown
@reviewer Good catch! I've updated the implementation to handle the edge case:

- Added null check on line 45
- Added test case for this scenario
- Updated error message

Please re-review when you have a chance.
```

### Step 2: Post Comment

**Post line-level comment:**
```bash
gh pr review <pr-number> --comment --body "$(cat <<'EOF'
<comment content>
EOF
)"
```

**Post general PR comment:**
```bash
gh pr comment <pr-number> --body "$(cat <<'EOF'
<comment content>
EOF
)"
```

**Post reply to specific comment:**
```bash
# Get comment ID from previous fetch
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment-id}/replies \
  -f body="<reply content>"
```

### Step 3: Handle Thread Resolution

**Resolve conversation (if applicable):**
```bash
# Mark as resolved via GitHub API
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment-id} \
  -X PATCH -f state=RESOLVED
```

### Step 4: Report Status

Return result:
```yaml
Comment Posted:
  PR: <number>
  Type: <line-level / general / reply>
  Thread: <thread-id or none>
  Status: <posted / resolved / needs-follow-up>
```

## Comment Types

### Type 1: Review Finding (from pr-reviewer)
Posts a code review finding with severity and category.

**Template:**
```markdown
**[Severity: HIGH] [Category: Security]** Potential SQL injection

**Location:** `src/db/user.ts:42`

**Issue:** User input is directly interpolated into SQL query

**Current:**
```typescript
const query = `SELECT * FROM users WHERE name = '${userInput}'`;
```

**Suggested:**
```typescript
const query = 'SELECT * FROM users WHERE name = $1';
const result = await db.query(query, [userInput]);
```

**Impact:** This could allow SQL injection attacks if userInput contains malicious SQL.
```

### Type 2: Fix Confirmation (from pr-feedback-handler)
Confirms that a requested fix has been implemented.

**Template:**
```markdown
✅ **Fixed:** Type safety issue addressed

**Changes made:**
- Replaced `any` with proper `User` interface on line 45
- Added runtime validation before type assertion
- Updated related tests

Commit: `<commit-sha>`
```

### Type 3: Discussion Reply
Responds to a question or suggestion with reasoning.

**Template:**
```markdown
@reviewer Thanks for the suggestion!

**Reasoning for current approach:**
I considered using the newer pattern, but opted for the current implementation because:
1. It maintains backward compatibility
2. It avoids breaking changes to the public API
3. The performance difference is negligible for our use case

We can migrate to the new pattern in a future PR when we're ready for breaking changes.
```

### Type 4: Batch Summary (from pr-manager)
Summarizes actions taken across multiple comments.

**Template:**
```markdown
## Feedback Processing Complete

**Summary:**
- ✅ Fixed: 3 issues (commits pushed)
- 💬 Replied: 2 questions (reasoning provided)
- ⏳ Pending: 1 discussion awaiting response

**Details:**
1. Fixed type safety in `userService.ts` (commit: abc123)
2. Fixed error handling in `auth.ts` (commit: def456)
3. Fixed test coverage in `utils.test.ts` (commit: ghi789)
4. Replied to architecture question - see thread
5. Replied to scope question - see thread

Ready for re-review!
```

## Integration

**Called by:**
- pr-reviewer (to post review findings)
- pr-feedback-handler (to post fix confirmations and replies)
- pr-manager (to post batch summaries)
- User for manual comments

**Calls to:**
- GitHub CLI/API for comment posting

**Coordinates with:**
- pr-reviewer for review content
- pr-feedback-handler for fix confirmations
- pr-manager for batch operations

## Multi-PR Commenting

When pr-manager needs to post on multiple PRs:

```bash
# Post on PR #277
echo "Comment for #277" | gh pr comment 277 --body-file -

# Post on PR #278 in parallel
echo "Comment for #278" | gh pr comment 278 --body-file -

# etc.
```

## Error Handling

**If comment fails to post:**
- Check authentication: `gh auth status`
- Check permissions on repository
- Retry with exponential backoff

**If replying to resolved thread:**
- Reopen thread first: `gh api repos/{o}/{r}/pulls/{n}/comments/{id} -X PATCH -f state=PENDING`
- Then post reply

## Best Practices

1. **Be specific:** Always reference line numbers and file paths
2. **Be constructive:** Provide suggested fixes, not just problems
3. **Be respectful:** Frame as suggestions, not demands
4. **Be actionable:** Clear next steps for the author
5. **Use severity:** HIGH (blocking), MEDIUM (should fix), LOW (optional)