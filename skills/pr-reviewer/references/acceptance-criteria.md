# Acceptance Criteria for PR Reviewer

## Skill Requirements

### Functional Requirements

#### PR Data Fetching
- ✅ Must fetch PR metadata using `gh pr view --json`
- ✅ Must retrieve changed files list with additions/deletions counts
- ✅ Must fetch diff content for each changed file
- ❌ Must NOT attempt to review without PR number or branch

#### Code Analysis
- ✅ Must analyze code across 4 dimensions: Quality, Security, Performance, Best Practices
- ✅ Must identify issues with severity levels (HIGH/MEDIUM/LOW)
- ✅ Must provide specific line numbers for each issue
- ✅ Must suggest concrete fixes with code examples
- ❌ Must NOT give vague feedback without specific locations

#### Review Posting
- ✅ Must format review with severity and category labels
- ✅ Must include "Current code" and "Suggested fix" sections
- ✅ Must post via GitHub CLI with structured markdown
- ✅ Must categorize issues as blocking vs non-blocking
- ❌ Must NOT post empty or incomplete reviews

### Quality Standards

#### Security Checks (Always Required)
- ✅ Check for hardcoded secrets, API keys, passwords
- ✅ Verify input validation on user inputs
- ✅ Ensure SQL queries use parameterized statements
- ✅ Flag eval() or dangerous dynamic code
- ✅ Confirm authorization checks present

#### Type Safety Verification
- ✅ All functions have explicit types
- ✅ No `any` types without documented justification
- ✅ Return types clearly defined
- ✅ Edge cases handled in type definitions

#### Testing Requirements
- ✅ New code includes unit tests
- ✅ Edge cases covered in tests
- ✅ No test coverage regression (maintain 80%+)
- ✅ Integration tests for API changes

#### Performance Review
- ✅ Database queries are efficient (no N+1)
- ✅ React components properly memoized
- ✅ No unnecessary API calls or re-renders
- ✅ Bundle size impact assessed

## Review Output Format

### Required Sections

```markdown
## Code Review Summary

**Overall assessment:** [APPROVED / CHANGES_REQUESTED / COMMENTED]

**Key findings:**
- <N> security issues
- <N> quality improvements
- <N> performance optimizations
- <N> best practice suggestions

### Detailed Comments

**[Severity: HIGH] [Category: Security]**
**Issue:** Description
**Location:** `file.ts:line`
**Current code:**
```typescript
// problematic code
```
**Suggested fix:**
```typescript
// improved code
```

### Action Items

**Must fix (blocking):**
- [ ] Issue 1

**Should fix (non-blocking):**
- [ ] Suggestion 1

**Consider (optional):**
- Idea 1
```

### YAML Report Format

```yaml
Review Complete:
  PR: <number>
  Status: <APPROVED / CHANGES_REQUESTED / COMMENTED>
  Severity Count:
    HIGH: <N>
    MEDIUM: <N>
    LOW: <N>
  Categories:
    Security: <N>
    Quality: <N>
    Performance: <N>
    Testing: <N>
    Documentation: <N>
    Architecture: <N>
    Maintainability: <N>
    Compatibility: <N>
  Blocking Issues: <N>
  Non-Blocking: <N>
  Action: <proceed / fix_required / needs_discussion>
```

**Category taxonomy (shared with pr-commenter)**: `Security, Quality, Performance, Testing, Documentation, Architecture, Maintainability, Compatibility`

## Error Handling

### Common Failures

#### PR Not Found
```
❌ Error: "Could not resolve to a PullRequest"
✅ Fix: Verify PR number and repository access
```

#### No Changes Detected
```
❌ Error: Empty diff returned
✅ Fix: Check if PR is already merged or has no file changes
```

#### Permission Denied
```
❌ Error: "Resource not accessible by integration"
✅ Fix: Ensure GitHub CLI has proper authentication
```

## Test Scenarios

### Scenario 1: Security Issue Detection
**Given:** PR with hardcoded API key
**When:** Review runs
**Then:** Must flag as HIGH severity with specific location

### Scenario 2: Performance Problem
**Given:** PR introduces N+1 query pattern
**When:** Review analyzes database code
**Then:** Must identify query issue and suggest optimization

### Scenario 3: Clean PR
**Given:** PR passes all checks
**When:** Review completes
**Then:** Should return APPROVE with optional suggestions only
