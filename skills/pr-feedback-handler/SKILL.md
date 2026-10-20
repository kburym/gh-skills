---
name: pr-feedback-handler
description: Handles Pull Request comments by either fixing issues or replying with reasons. Use when PR receives comments that need addressing. Analyzes each comment and decides whether to (A) implement the fix or (B) reply explaining why not. Triggers after PR comments arrive (typically 3+ minutes after PR opened).
---
# PR Feedback Handler

Processes PR comments and takes appropriate action: fix or reply.

## Workflow

### Step 1: Fetch Comments

```bash
# Get all PR comments with context
gh pr view <branch> --json comments,reviews --jq '{
  comments: [.comments[] | {author: .author.login, body: .body, createdAt: .createdAt}],
  reviews: [.reviews[] | {author: .author.login, body: .body, state: .state}]
}'
```

### Step 2: Analyze Each Comment

For every comment, determine:

**Type A: Fix Required**

- Bug reports
- Code style violations
- Missing tests
- Security issues
- Performance problems
- Logic errors

**Type B: Reply With Reason**

- Design decisions already discussed
- Out of scope for this PR
- Intentional trade-offs
- Already addressed elsewhere
- False positives

### Step 3: Execute Actions

#### For Type A (Fix):

```bash
cd <worktree-path>

# Checkout branch
git checkout <branch-name>

# Implement fix based on comment
# <edit files per comment instructions>

# Test the fix
npm test

# Commit with reference to comment
git add .
git commit -m "Fix: <brief description>

Addressing feedback from <commenter>
- <specific change made>

Refs: PR <number>"

# Push update
git push origin <branch-name>
```

#### For Type B (Reply):

```bash
# Post reply comment
gh pr comment <pr-number> --body "@$(cat <<'EOF'
<commenter> <reasoning>

<explanation of why this approach was chosen>

<context or trade-off details>
EOF
)"
```

### Step 4: Resolve Thread (if applicable)

```bash
# Mark comment as resolved via GitHub API or UI
# Note: gh CLI may not support direct resolve, document for manual resolution
```

### Step 5: Check for More Comments

```bash
# After processing, check if new comments arrived
gh pr view <branch> --json comments --jq '.comments | length'
```

### Step 6: Report to Super Agent

Return structured result:

```
PR Feedback Processed:
- PR: <URL>
- Comments received: <N>
- Actions taken:
  - Fixed: <N> issues (commits pushed)
  - Replied: <N> comments (reasons provided)
- Status: <resolved/pending/awaiting-reviewer>

Next steps:
- Monitor for additional comments
- Await reviewer re-review
- Super agent will continue monitoring
```

## Decision Matrix

| Comment Type | Action | Example |
| --- | --- | --- |
| "This breaks tests" | Fix | Run tests, identify failure, fix code |
| "Missing validation" | Fix | Add validation logic + tests |
| "Use early return" | Fix | Refactor code structure |
| "Why not use X pattern?" | Reply | Explain pattern choice, trade-offs |
| "Add Y feature here" | Reply | "Out of scope - tracked in TASK-Z" |
| "Security issue: Z" | Fix | Immediate fix + security review |
| "Formatting" | Fix | Apply linter/auto-format |
| "I don't understand..." | Reply | Clarify with code comments + reply |

## Comment Analysis Heuristics

**Keywords indicating FIX needed:**

- "bug", "error", "fails", "broken", "crash"
- "should be", "needs to", "must", "missing"
- "security", "vulnerability", "exploit"
- "test", "coverage", "spec"

**Keywords indicating REPLY:**

- "why", "consider", "what if", "suggestion"
- "nit", "optional", "thought"
- "out of scope", "future", "separate PR"

## Error Handling

**If fix conflicts with main:**

- Pull latest main: `git pull origin main`
- Resolve conflicts
- Re-run tests
- Push fixed commit

**If comment is unclear:**

- Reply asking for clarification
- Document unclear comment for super agent
- Do NOT guess - get clarity first

**If fix requires major refactor:**

- Reply with estimate and trade-offs
- Ask if commenter prefers:
    1. Fix in this PR (larger scope)
    2. Separate PR (tracked as new task)

## Integration

**Called by:**

- Super orchestrator when comments detected
- pr-opener workflow (after 3 min wait)
- Scheduled monitoring job

**Calls to:**

- Worktree for edits (same location as original)
- GitHub CLI for comments

**Reports to:**

- Super agent for workflow status