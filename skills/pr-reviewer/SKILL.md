---
name: pr-reviewer
description: Performs comprehensive code review on Pull Requests in the target repository. Analyzes code quality, security, performance, and best practices. Posts structured review comments via GitHub CLI. Use when reviewing PRs for quality assurance, before merging, or as part of the pr-manager workflow. Triggers on requests like "review PR", "code review", "PR quality check", or when pr-manager requests reviews.
---
# PR Reviewer

Performs automated and manual code reviews on Pull Requests with structured feedback.

## Workflow

### Step 1: Fetch PR Details

```bash
# Get PR metadata
gh pr view <pr-number> --json number,title,headRefName,baseRefName,author,body,files

# Get changed files with patch
gh pr view <pr-number> --json files --jq '.files[] | {path: .path, additions: .additions, deletions: .deletions}'
```

### Step 2: Analyze Code Changes

For each file changed:

```bash
# Get the diff
gh pr diff <pr-number> --path <file-path>

# Or view full PR diff
gh pr diff <pr-number>
```

**Analysis dimensions:**

1. **Code Quality**
  - Type safety and proper TypeScript usage
  - Error handling coverage
  - Test coverage for new code
  - Code duplication
  - Complexity and maintainability
2. **Security**
  - No secrets or credentials in code
  - Proper input validation
  - SQL injection prevention
  - XSS prevention
  - Authentication/authorization checks
3. **Performance**
  - Database query efficiency
  - N+1 query detection
  - Unnecessary re-renders (React)
  - Memory leaks
  - Bundle size impact
4. **Best Practices**
  - Follows project conventions
  - Proper documentation
  - Consistent naming
  - Clean architecture patterns

### Step 3: Generate Review Comments

**Comment format:**

```markdown
**[Severity: HIGH/MEDIUM/LOW] [Category: Security/Quality/Performance/Best Practice]**

**Issue:** Brief description of the problem

**Location:** `file.ts:line-number`

**Current code:**
```typescript
// problematic code snippet
```

**Suggested fix:**

```typescript
// improved code snippet
```

**Reasoning:** Why this matters and the impact

```

### Step 4: Post Review

```bash
# Post structured review
gh pr review <pr-number> --comment --body "$(cat <<'EOF'
## Code Review Summary

**Overall assessment:** [APPROVE / REQUEST CHANGES / COMMENT]

**Key findings:**
- <N> security issues
- <N> quality improvements
- <N> performance optimizations
- <N> best practice suggestions

### Detailed Comments

<individual comments from Step 3>

### Action Items

**Must fix (blocking):**
- [ ] Issue 1
- [ ] Issue 2

**Should fix (non-blocking):**
- [ ] Suggestion 1
- [ ] Suggestion 2

**Consider (optional):**
- Idea 1
- Idea 2
EOF
)"
```

### Step 5: Report to PR Manager

Return structured result:

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
    Best Practice: <N>
  Blocking Issues: <N>
  Non-Blocking: <N>
  Action: <proceed / fix_required / needs_discussion>
```

## Review Checklist

### Security (Always check)

- [ ] No hardcoded secrets, API keys, passwords
- [ ] Input validation on all user inputs
- [ ] SQL queries use parameterized statements
- [ ] No eval() or dangerous dynamic code
- [ ] Proper authorization checks

### Type Safety

- [ ] All functions have proper types
- [ ] No `any` types without justification
- [ ] Return types defined
- [ ] Edge cases handled

### Testing

- [ ] New code has unit tests
- [ ] Tests cover edge cases
- [ ] No test coverage regression
- [ ] Integration tests where appropriate

### Performance

- [ ] Database queries efficient
- [ ] No N+1 queries
- [ ] Proper React memoization
- [ ] No unnecessary API calls

### Documentation

- [ ] Complex functions documented
- [ ] API changes documented
- [ ] README updated if needed
- [ ] Breaking changes noted

## Severity Levels

**HIGH (Blocking)**

- Security vulnerabilities
- Breaking changes without migration
- Critical bugs
- Missing required tests

**MEDIUM (Should fix)**

- Type safety issues
- Performance problems
- Code duplication
- Error handling gaps

**LOW (Nice to have)**

- Naming improvements
- Style consistency
- Documentation additions
- Refactoring suggestions

## Integration

**Called by:**

- pr-manager (as part of review queue)
- User for individual PR review
- Automated review on PR open

**Calls to:**

- pr-commenter (to post individual line comments)
- GitHub CLI for review submission

**Reports to:**

- pr-manager for queue management
- User for immediate feedback

## Example Commands

```
# Review single PR
@super Review PR #277

# Review with focus
@super Review PR #278 for security issues

# Batch review
@super Review all open PRs
```

## Automated Review Patterns

### Pattern 1: Security Scan

```bash
# Check for secrets
grep -i "password\|secret\|key\|token" <diff> | grep -v "test\|mock"

# Check for SQL injection risk
grep -E "\$\{.*\}" <diff> | grep -i "query\|sql"
```

### Pattern 2: Type Safety Check

```bash
# Run TypeScript check
cd <worktree> && npx tsc --noEmit

# Report type errors as review comments
```

### Pattern 3: Test Coverage

```bash
# Run tests with coverage
cd <worktree> && npm test -- --coverage

# Flag files with <80% coverage
```