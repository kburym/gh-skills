# Acceptance Criteria: PR Feedback Handler

## Functional Requirements

### FR-001: Comment Fetching
- ✅ **MUST** fetch all PR comments using `gh pr view` with JSON output
- ✅ **MUST** parse both review comments and general PR comments
- ✅ **MUST** extract author, body, timestamp, and thread context for each comment
- ❌ **MUST NOT** skip or ignore any unresolved comments
- ✅ **SHOULD** handle pagination for PRs with >100 comments

### FR-002: Comment Classification (Type A vs Type B)
- ✅ **MUST** classify each comment as either Type A (Fix) or Type B (Reply)
- ✅ **MUST** use keyword heuristics for initial classification
- ✅ **MUST** support manual override for edge cases
- ❌ **MUST NOT** default to "Reply" for security-related comments

#### Type A (Fix) Classification Rules
- ✅ **MUST** classify as Type A when comment contains:
  - Bug report keywords: "bug", "error", "fails", "broken", "crash"
  - Requirement keywords: "should be", "needs to", "must", "missing"
  - Security keywords: "security", "vulnerability", "exploit", "CVE"
  - Testing keywords: "test", "coverage", "spec", "fails tests"
  - Style keywords: "formatting", "lint", "style violation"
  - Logic keywords: "logic error", "incorrect", "wrong result"
- ❌ **MUST NOT** classify as Type A when:
  - Comment is explicitly marked as "nit" or "optional" (unless the reviewer explicitly asked for a specific mechanical fix)
  - Comment asks questions without stating a problem
  - Comment is a suggestion for future improvement

#### Type B (Reply) Classification Rules
- ✅ **MUST** classify as Type B when comment contains:
  - Question keywords: "why", "how", "what if", "consider"
  - Suggestion keywords: "suggestion", "thought", "idea", "nit"
  - Scope keywords: "out of scope", "future", "separate PR", "not for this"
  - Discussion keywords: "discussed", "decided", "agreed"
- ❌ **MUST NOT** classify as Type B when:
  - Comment identifies a concrete bug or security issue
  - Comment states tests are failing
  - Comment requires immediate action

### FR-003: Fix Implementation (Type A)
- ✅ **MUST** verify the worktree is already on the correct branch (never `git checkout` inside a worktree)
- ✅ **MUST** locate and read the file(s) mentioned in the comment
- ✅ **MUST** implement the fix according to comment instructions
- ✅ **MUST** run tests to verify the fix
- ✅ **MUST** commit with proper message format referencing the PR and commenter
- ✅ **MUST** push the fix to the same branch
- ❌ **MUST NOT** push if tests fail
- ❌ **MUST NOT** modify files not mentioned in the comment without explicit approval
- ❌ **MUST NOT** stage unrelated changes (`git add .`) — stage only the files changed by the fix

#### Fix Commit Message Requirements
- ✅ **MUST** start with "Fix: " prefix
- ✅ **MUST** include brief description of change
- ✅ **MUST** reference the commenter username
- ✅ **MUST** include specific change details in commit body
- ✅ **MUST** include "Addressing feedback from @<commenter>" in the commit body
- ✅ **MUST** include "Refs: PR #<number>" in footer
- ❌ **MUST NOT** use generic commit messages like "Fixes" or "Update"

### FR-004: Reply Formatting (Type B)
- ✅ **MUST** post reply using `gh pr comment` command
- ✅ **MUST** mention the original commenter with `@username`
- ✅ **MUST** provide clear reasoning for the decision
- ✅ **MUST** include relevant context or trade-off details
- ✅ **MUST** remain professional and constructive in tone
- ❌ **MUST NOT** use dismissive or defensive language
- ❌ **MUST NOT** reply with single-word responses like "No" or "Done"

#### Reply Structure Requirements
```
@<commenter> <acknowledgment>

<reasoning paragraph>

<context or trade-off details>

<next steps or call to action>
```
- ✅ **MUST** include at least 2-3 sentences of explanation
- ✅ **MUST** reference specific code or design decisions when relevant
- ❌ **MUST NOT** simply state "will not fix" without explanation

### FR-005: Thread Resolution
- ✅ **SHOULD** resolve the thread via the GraphQL API (`resolveReviewThread` mutation) when the fix is pushed or a reply is posted
- ❌ **MUST NOT** mark a thread resolved without taking action
- ✅ **FALLBACK** if the API is unavailable: state in the reply that the thread can be resolved manually

### FR-006: Status Reporting
- ✅ **MUST** report to the orchestrating agent with structured results
- ✅ **MUST** include count of comments received, fixed, and replied to
- ✅ **MUST** indicate current PR status (resolved/pending/awaiting-reviewer)
- ✅ **MUST** list next steps for workflow continuation
- ❌ **MUST NOT** report success if any action failed

## Error Handling Scenarios

### EHS-001: Merge Conflicts During Fix
- ✅ **DETECT** conflict when `git push` fails
- ✅ **RESOLVE** by fetching and merging the base branch: `git fetch origin && git merge origin/<default-branch>`
- ✅ **MERGE** conflicts manually or using merge tool
- ✅ **RE-RUN** tests after conflict resolution
- ✅ **RE-PUSH** with `git push origin <branch-name>` after successful merge
- ❌ **ABORT** only if conflicts are unresolvable, report to the orchestrating agent

### EHS-002: Unclear Comment
- ✅ **DETECT** ambiguity in comment instructions
- ✅ **REPLY** asking for clarification with specific questions
- ✅ **DOCUMENT** unclear comment for the orchestrating agent tracking
- ❌ **NEVER** guess or assume intent of unclear comments
- ✅ **WAIT** for clarification before proceeding

### EHS-003: Major Refactor Required
- ✅ **DETECT** when fix requires >50 lines changed or >3 files modified
- ✅ **REPLY** with estimate of scope and trade-offs
- ✅ **OFFER** two options: fix in current PR or create new task
- ✅ **AWAIT** reviewer decision before proceeding
- ❌ **NEVER** silently perform major refactors without approval

### EHS-004: Test Failures After Fix
- ✅ **DETECT** when `npm test` or `bun test` fails
- ✅ **ANALYZE** if failure is related to the fix or pre-existing
- ✅ **FIX** related failures before committing
- ❌ **NEVER** push commits with failing tests
- ✅ **REPORT** pre-existing failures to the orchestrating agent for triage

### EHS-005: Cannot Access Worktree
- ✅ **DETECT** when worktree path is invalid or deleted
- ✅ **REPORT** to the orchestrating agent immediately
- ❌ **NEVER** attempt to recreate worktree without the orchestrating agent coordination
- ✅ **WAIT** for the orchestrating agent to provide worktree location or recreate

### EHS-006: GitHub API Errors
- ✅ **DETECT** when `gh pr comment` or `gh pr view` fails
- ✅ **RETRY** with exponential backoff (3 attempts)
- ✅ **REPORT** persistent failures to the orchestrating agent
- ❌ **NEVER** silently drop comments or actions due to API errors
- ✅ **LOG** all API errors with full error message

## Classification Examples

### Example 1: Type A (Fix)
```
Comment: "This breaks the login flow. When I click submit, nothing happens."
Classification: ✅ Type A (Fix)
Reason: Bug report with concrete problem
Action: Reproduce, debug, fix, test, commit, push
```

### Example 2: Type B (Reply)
```
Comment: "Why did you choose to use a for loop instead of map() here?"
Classification: ✅ Type B (Reply)
Reason: Question about design choice, not a requirement
Action: Reply explaining performance/semantic reasoning
```

### Example 3: Edge Case - Security Override
```
Comment: "Just a thought - should we consider using bcrypt instead?"
Classification: ✅ Type A (Fix)
Reason: Contains "bcrypt" (security keyword) despite "thought" prefix
Action: Evaluate security implication, fix if valid, reply if already secure
```

### Example 4: Edge Case - Nit Override
```
Comment: "Nit: This variable name is confusing"
Classification: ✅ Type B (Reply)
Reason: Marked as a nit; non-blocking.
Action: Confirm intent and reply; only fix if the reviewer explicitly asked for a specific mechanical change
```

## Performance Requirements

- ✅ **SHOULD** complete processing of single comment within 5 minutes
- ✅ **SHOULD** complete processing of PR with <10 comments within 15 minutes
- ✅ **MUST** handle PRs with up to 50 comments without timeout
- ❌ **MUST NOT** process more than 10 comments simultaneously

## Security Requirements

- ✅ **MUST** treat all comments containing security keywords as Type A
- ✅ **MUST** escalate security-related fixes to security-engineer agent if available
- ✅ **MUST** verify security fixes do not introduce new vulnerabilities
- ❌ **MUST NOT** dismiss security concerns without thorough review
