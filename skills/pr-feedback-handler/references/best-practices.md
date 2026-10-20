# Best Practices: PR Feedback Handler

## When to Fix vs When to Reply

### Always Fix (Type A)
- ✅ **Concrete bugs** - "This throws an error when input is null"
- ✅ **Security issues** - Any mention of security, vulnerability, or CVE
- ✅ **Failing tests** - "Tests are failing on line 47"
- ✅ **Missing requirements** - "You forgot to add the validation"
- ✅ **Logic errors** - "This condition will never be true"
- ✅ **Code style violations** - Lint errors, formatting issues (when auto-fixable)
- ✅ **Performance problems** - Clear performance regression identified

### Always Reply (Type B)
- ✅ **Questions** - "Why did you implement it this way?"
- ✅ **Suggestions for future** - "We should consider refactoring this later"
- ✅ **Out of scope requests** - "Can you add feature X here?"
- ✅ **Design discussions** - "What if we used pattern Y instead?"
- ✅ **Clarification requests** - "I don't understand this logic"
- ✅ **Trade-off questions** - "Why not use library Z?"

### Context-Dependent Decisions

| Scenario | Action | Reasoning |
|----------|--------|-----------|
| "Nit: variable name" | Fix | Low effort, improves readability |
| "Nit: architecture suggestion" | Reply | May be subjective, discuss first |
| "Consider adding test" | Fix | Improves coverage, reasonable |
| "Add more tests" (vague) | Reply | Ask for specifics |
| "Security: use HTTPS" | Fix | Security is non-negotiable |
| "Security thought: maybe hash?" | Fix | Still security-related, verify |

## Decision Tree for Feedback Classification

```
START
│
├─ Does comment contain "security", "vulnerability", "exploit", "CVE"?
│  ├─ YES → Type A (Fix) [Security Override]
│  └─ NO → Continue
│
├─ Does comment state tests are failing or missing?
│  ├─ YES → Type A (Fix)
│  └─ NO → Continue
│
├─ Does comment describe a concrete bug or error?
│  ├─ YES → Type A (Fix)
│  └─ NO → Continue
│
├─ Does comment use words: "should be", "needs to", "must"?
│  ├─ YES → Type A (Fix)
│  └─ NO → Continue
│
├─ Does comment contain "nit" AND is a simple fix?
│  ├─ YES → Type A (Fix)
│  └─ NO → Continue
│
├─ Does comment ask "why", "what if", "consider"?
│  ├─ YES → Type B (Reply)
│  └─ NO → Continue
│
├─ Does comment mention "out of scope", "future", "separate"?
│  ├─ YES → Type B (Reply)
│  └─ NO → Continue
│
├─ Is comment a question without stating a problem?
│  ├─ YES → Type B (Reply)
│  └─ NO → Type A (Fix) [Default to fix if unclear]
```

## Fix Commit Message Conventions

### Format Template
```
Fix: <brief description of change>

Addressing feedback from @<commenter>
- <specific change 1>
- <specific change 2>

Refs: PR <pr-number>
```

### Good Examples

**Example 1: Bug Fix**
```
Fix: Handle null input in user validation

Addressing feedback from @alice
- Added null check before accessing user.name
- Added test case for null input scenario

Refs: PR #42
```

**Example 2: Security Fix**
```
Fix: Use bcrypt for password hashing instead of MD5

Addressing feedback from @security-reviewer
- Replaced md5() with bcrypt.hash()
- Updated password validation logic
- Added bcrypt to dependencies

Refs: PR #42
```

**Example 3: Test Addition**
```
Fix: Add missing test for edge case in payment calculation

Addressing feedback from @bob
- Added test for zero-amount payment edge case
- Added test for negative amount validation

Refs: PR #42
```

### Bad Examples (Avoid These)

❌ **Too vague:**
```
Fix: Update code

Addressing feedback

Refs: PR #42
```

❌ **Missing context:**
```
Fix: Bug fix

Done.

Refs: PR #42
```

❌ **Multiple unrelated fixes in one commit:**
```
Fix: Various fixes

Addressing feedback from @alice, @bob, @charlie
- Fixed stuff

Refs: PR #42
```

## Reply Tone Guidelines

### Principles
- ✅ **Professional** - No slang, no emotional language
- ✅ **Constructive** - Even when disagreeing, stay solution-oriented
- ✅ **Appreciative** - Acknowledge the reviewer's time and effort
- ✅ **Clear** - Easy to understand, no jargon without explanation
- ✅ **Concise** - Direct but not terse

### Opening Templates

**For accepting feedback:**
```
@reviewer Thanks for catching this! You're absolutely right.
```

**For explaining decisions:**
```
@reviewer Good question! Let me explain the reasoning behind this approach.
```

**For scope discussions:**
```
@reviewer That's a great suggestion for a future improvement.
```

**For clarification requests:**
```
@reviewer Thanks for the feedback. I want to make sure I understand correctly.
```

### Reply Structure by Scenario

**Scenario: Explaining Design Choice**
```
@reviewer Good question about using a for loop here.

I chose a for loop over map() because we need to skip elements conditionally 
without creating intermediate arrays. The map() approach would require 
filter() first, creating two array passes instead of one.

The performance difference is small here (~2ms), but this pattern is used 
consistently across the codebase for consistency. Happy to discuss if you 
see a better approach!
```

**Scenario: Out of Scope Request**
```
@reviewer That's a valuable feature suggestion!

Adding user preferences would definitely improve the experience. However, 
it's outside the scope of this PR which focuses on the authentication flow.

I've created TASK-123 to track this for the next sprint. Would you like me 
to add a TODO comment referencing that task?
```

**Scenario: Disagreeing with Feedback**
```
@reviewer I appreciate you raising this concern.

After reviewing, I believe the current implementation is correct for these 
reasons:
1. The API contract requires this specific format
2. Changing it would break backward compatibility
3. The downstream consumers expect this structure

That said, I'm open to refactoring this in a separate PR if we want to 
introduce a v2 API. What do you think?
```

### Tone Checklist
Before posting a reply, verify:
- ✅ Does it start with acknowledgment?
- ✅ Is the explanation at least 2 sentences?
- ✅ Would this sound professional if read aloud in a meeting?
- ✅ Does it offer a path forward (fix, discuss, or defer)?
- ❌ Does it sound defensive or dismissive? (If yes, rewrite)
- ❌ Does it use phrases like "obviously" or "clearly"? (Remove these)

## Examples of Good Decisions

### Example 1: Fix vs Reply - Logic Error
**Comment:** "This comparison is wrong - it should be `>=` not `>`"
**Decision:** ✅ Type A (Fix)
**Reasoning:** Clear bug identified, unambiguous fix
**Action:** Change `>` to `>=`, add test case, commit with message explaining the boundary condition

### Example 2: Fix vs Reply - Design Question
**Comment:** "Why not extract this into a separate function?"
**Decision:** ✅ Type B (Reply)
**Reasoning:** Question about design choice, not a requirement
**Reply:**
```
@reviewer Good suggestion! I kept it inline because it's only used here 
and the logic is tightly coupled to this specific flow. Extracting would 
require passing 4+ parameters and reduce readability. Happy to refactor 
if we end up needing this logic elsewhere - just let me know!
```

### Example 3: Fix vs Reply - Nitpick Navigation
**Comment:** "Nit: variable name `data` is too generic"
**Decision:** ✅ Type A (Fix)
**Reasoning:** Simple fix, improves code clarity, "nit" is not a blocker but easy to address
**Action:** Rename `data` to `userProfile`, commit: "Fix: Use descriptive variable name for user profile data"

### Example 4: Fix vs Reply - Security Suggestion
**Comment:** "Just a thought - have we considered rate limiting here?"
**Decision:** ✅ Type A (Fix)
**Reasoning:** Contains security implication despite "thought" framing
**Action:** Evaluate if rate limiting is needed, implement if yes, or reply with current security measures if already protected

### Example 5: Fix vs Reply - Scope Management
**Comment:** "Can we add pagination to this list?"
**Decision:** ✅ Type B (Reply)
**Reasoning:** Feature request, not a bug or requirement of current PR
**Reply:**
```
@reviewer Great idea! Pagination would definitely help with large datasets.

This PR is focused on the filtering functionality. I've created TASK-456 
to add pagination in the next iteration. We can tackle it right after this 
merges to avoid scope creep. Does that work?
```

## Common Pitfalls to Avoid

### Pitfall 1: Over-Replying
❌ **Don't reply to obvious bugs:**
```
Comment: "This throws undefined error"
Bad Response: "@reviewer You're right, I'll look into it..."
Good Action: Just fix it and push
```

### Pitfall 2: Under-Replying
❌ **Don't silently ignore questions:**
```
Comment: "Why did you choose this approach?"
Bad Response: [No response, just resolves thread]
Good Response: Detailed explanation of trade-offs
```

### Pitfall 3: Defensive Replies
❌ **Avoid justifying without listening:**
```
Bad: "@reviewer Actually, this is the standard pattern..."
Good: "@reviewer Thanks for the feedback. The pattern choice was based on 
X constraint. Do you see concerns with this approach?"
```

### Pitfall 4: Commit Message Laziness
❌ **Don't be vague:**
```
Bad: "Fix: update code"
Good: "Fix: Add input validation for email field per review feedback"
```

### Pitfall 5: Scope Creep
❌ **Don't add unrelated features:**
```
Comment: "While you're here, can you also add Y feature?"
Bad Action: Implements Y feature in same PR
Good Action: Reply explaining this will be a separate task
```

## Integration Best Practices

### With Super Agent
- ✅ Always report completion status with specific numbers
- ✅ Flag any comments that couldn't be processed
- ✅ Escalate security issues immediately
- ✅ Request worktree recreation if workspace is corrupted

### With PR-Opener
- ✅ Wait for pr-opener to signal "3+ minutes elapsed"
- ✅ Don't process feedback on brand new PRs (<3 min old)
- ✅ Coordinate on PR numbering and branch names

### With Code-Reviewer
- ✅ Treat code-reviewer agent feedback as high priority
- ✅ If code-reviewer and human reviewer conflict, escalate to super agent
- ✅ Document any automated review findings in status report

## Metrics for Success

Track these to improve over time:
- **Fix Success Rate**: % of Type A fixes that pass CI on first push
- **Reply Satisfaction**: % of replies that result in commenter approval
- **Iteration Count**: Average number of back-and-forth rounds per PR
- **Resolution Time**: Average time from comment to resolution

Goals:
- Fix Success Rate > 95%
- Reply Satisfaction > 90%
- Iteration Count < 2
- Resolution Time < 10 minutes per comment
