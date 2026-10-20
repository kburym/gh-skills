# PR Commenter - Best Practices

Guidelines for effective PR commenting, etiquette, and threading strategies.

---

## When to Use Line-Level vs General Comments

### Use Line-Level Comments When:

✅ **Appropriate Scenarios:**
| Scenario | Example |
|---|---|
| Specific code issue | "Line 45: This function lacks error handling" |
| Syntax or style violation | "Line 23: Missing semicolon" |
| Logic error on specific line | "Line 78: Off-by-one error in loop condition" |
| Suggesting specific code change | "Line 32: Consider using `const` instead of `let`" |
| Security issue at location | "Line 55: Unsanitized user input" |
| Performance concern | "Line 90: O(n²) complexity could be O(n)" |

❌ **Don't Use Line-Level Comments For:**
| Anti-Pattern | Better Approach |
|---|---|
| Architecture discussions | Use general PR comment |
| High-level design feedback | Use general PR comment |
| Questions about PR scope | Use general PR comment |
| Summarizing multiple issues | Use general PR comment |
| General encouragement | Use general PR comment |

### Use General PR Comments When:

✅ **Appropriate Scenarios:**
| Scenario | Example |
|---|---|
| Overall PR feedback | "Great work on the error handling improvements" |
| Architecture concerns | "The new service pattern doesn't align with our DDD approach" |
| Missing requirements | "This PR should include migration scripts" |
| Summary of review | "3 issues found, 2 need addressing before merge" |
| Cross-cutting concerns | "The logging approach needs standardization" |
| Process issues | "Please add tests for the new functionality" |

❌ **Don't Use General Comments For:**
| Anti-Pattern | Better Approach |
|---|---|
| Specific line issues | Use line-level comment |
| Code suggestions without context | Add line reference |
| Typos in code | Use line-level comment |
| Single-line questions | Use line-level comment |

---

## Comment Etiquette and Tone Guidelines

### Tone Principles

✅ **Constructive Tone:**
```markdown
**[Severity: MEDIUM] [Category: Quality]** Consider adding input validation

The current implementation assumes valid input, which could lead to runtime errors.

**Suggested:**
```typescript
if (!isValidEmail(email)) {
  throw new ValidationError('Invalid email format');
}
```

This will help catch issues early and provide better error messages.
```

❌ **Harsh Tone:**
```markdown
This is wrong. You didn't validate the input. Fix it.
```

### Framing Guidelines

✅ **Do Frame As:**
- "Consider..." - For suggestions
- "What do you think about..." - For alternatives
- "Could we..." - For improvements
- "For future reference..." - For educational points
- "I noticed..." - For observations

❌ **Don't Frame As:**
- "You must..." - Dictatorial
- "This is wrong..." - Without explanation
- "Why didn't you..." - Accusatory
- "Everyone knows..." - Condescending
- "Just fix it..." - Dismissive

### Encouragement Balance

✅ **Good Balance:**
```markdown
Great use of the strategy pattern here! 

One small suggestion: the error message could be more specific about which validation failed. This will help with debugging.

Overall solid implementation! 🎉
```

❌ **All Critical:**
```markdown
- Missing validation
- Wrong error type
- No tests
- Poor naming
```

❌ **All Praise (no value):**
```markdown
LGTM! 👍
```

---

## Threading Best Practices

### Starting a Thread

✅ **Clear Opening:**
```markdown
**[Severity: HIGH] [Category: Security]** SQL injection vulnerability

**Location:** `src/db/queries.ts:45`

The user input is directly interpolated into the SQL query.

**Current:**
```typescript
const query = `SELECT * FROM users WHERE name = '${userInput}'`;
```

**Suggested:**
```typescript
const query = 'SELECT * FROM users WHERE name = $1';
const result = await db.query(query, [userInput]);
```

**Impact:** This could allow attackers to execute arbitrary SQL commands.

**Next Steps:** Please update to use parameterized queries.
```

❌ **Vague Opening:**
```markdown
Security issue here
```

### Responding in Threads

✅ **Contextual Response:**
```markdown
@reviewer Good catch! I've updated the implementation:

- [x] Changed to parameterized queries
- [x] Added input sanitization
- [x] Added test case for SQL injection attempt

Commit: `a1b2c3d`

Ready for re-review!
```

❌ **Unhelpful Response:**
```markdown
fixed
```

### Resolving Threads

✅ **When to Resolve:**
- Issue has been addressed with code changes
- Discussion reached conclusion
- Author and reviewer agree on path forward
- Fix has been verified

✅ **Resolution Confirmation:**
```markdown
✅ **Resolved:** Type safety issue addressed

- Replaced `any` with `User` interface
- Added validation function
- Tests updated

Commit: `abc1234`
```

❌ **When NOT to Resolve:**
- Without confirming the fix
- When reviewer hasn't responded
- When there's ongoing disagreement
- To dismiss without addressing

### Reopening Threads

✅ **Appropriate Reopening:**
- Fix doesn't fully address the concern
- New information invalidates the resolution
- Related issue discovered
- Reviewer requests additional changes

✅ **Reopening Message:**
```markdown
Reopening this thread - the current fix handles the null case but doesn't address the undefined scenario. Could you update to handle both?
```

---

## Examples: Good vs Bad Comments

### Example 1: Code Quality Finding

✅ **Good:**
```markdown
**[Severity: MEDIUM] [Category: Quality]** Consider early return pattern

**Location:** `src/utils/helpers.ts:23`

The nested conditionals make this harder to follow than necessary.

**Current:**
```typescript
function processUser(user: User | null) {
  if (user) {
    if (user.isActive) {
      if (user.email) {
        return sendEmail(user.email);
      }
    }
  }
  return null;
}
```

**Suggested:**
```typescript
function processUser(user: User | null) {
  if (!user) return null;
  if (!user.isActive) return null;
  if (!user.email) return null;
  
  return sendEmail(user.email);
}
```

**Rationale:** Early returns reduce nesting and improve readability. The cognitive load is lower when each condition is handled immediately.
```

❌ **Bad:**
```markdown
This function is too nested. Fix the nesting.
```

### Example 2: Security Issue

✅ **Good:**
```markdown
**[Severity: HIGH] [Category: Security]** Missing authentication check

**Location:** `src/api/admin.ts:15`

The admin endpoint doesn't verify the user's role.

**Current:**
```typescript
app.get('/admin/users', async (req, res) => {
  const users = await getAllUsers();
  res.json(users);
});
```

**Suggested:**
```typescript
app.get('/admin/users', 
  requireAuth,
  requireRole('admin'),
  async (req, res) => {
    const users = await getAllUsers();
    res.json(users);
  }
);
```

**Impact:** Any authenticated (or unauthenticated) user could access sensitive user data. This is a P0 security issue.

**Required Fix:** Add authentication and authorization middleware.
```

❌ **Bad:**
```markdown
Security problem. Anyone can access this. You need auth.
```

### Example 3: Reply to Question

✅ **Good:**
```markdown
@reviewer Thanks for the question about the database choice!

**Reasoning for PostgreSQL over MongoDB:**

1. **ACID compliance:** We need transactional integrity for financial data
2. **Existing expertise:** Team has 5+ years PostgreSQL experience
3. **Query complexity:** Reporting queries require JOINs that would be inefficient in MongoDB
4. **Migration path:** Existing data is in PostgreSQL

**Trade-offs considered:**
- MongoDB would offer more flexible schema evolution
- PostgreSQL requires more upfront schema design
- The strict schema is actually beneficial for our use case

Happy to discuss further if you see concerns I missed!
```

❌ **Bad:**
```markdown
@reviewer We always use PostgreSQL. It's better.
```

### Example 4: Batch Summary

✅ **Good:**
```markdown
## Review Feedback - Batch Response

**Summary:**
- ✅ Fixed: 4 issues
- 💬 Replied: 2 questions
- ⏳ Pending: 1 discussion

**Details:**

**Fixed:**
1. **[Security]** Added auth checks to admin routes (commit: `abc123`)
2. **[Quality]** Refactored nested conditionals in helpers.ts (commit: `def456`)
3. **[Performance]** Added database index on user.email (commit: `ghi789`)
4. **[Testing]** Added integration tests for auth flow (commit: `jkl012`)

**Replied:**
1. Architecture question about service layer - see [thread](#)
2. Database choice rationale - see [thread](#)

**Pending:**
1. Discussion about breaking API changes - awaiting maintainer decision

**Next Steps:**
- Monitor pending discussion for resolution
- Address any additional feedback from re-review

Ready for re-review when you have a chance! 🚀
```

❌ **Bad:**
```markdown
Fixed everything. Ready to merge?
```

### Example 5: Fix Confirmation

✅ **Good:**
```markdown
✅ **Fixed:** Type safety issue in user validation

**Changes made:**
- Replaced `any` with `User` interface in `src/types/user.ts`
- Added runtime validation with Zod schema
- Updated `validateUser()` to return typed result
- Added 3 new test cases for type validation edge cases

**Commits:**
- `a1b2c3d` - Add User interface and validation
- `e4f5g6h` - Update tests

**Verification:**
- [x] All tests passing
- [x] TypeScript compilation successful
- [x] Runtime validation tested

The fix maintains backward compatibility while adding type safety. Users of the old API won't need changes.
```

❌ **Bad:**
```markdown
Done
```

---

## Severity Guidelines

### HIGH (Blocking)

✅ **Use For:**
- Security vulnerabilities
- Data loss risks
- Breaking API changes without versioning
- Legal/compliance issues
- Production-critical bugs

**Tone:** Urgent but professional

### MEDIUM (Should Fix)

✅ **Use For:**
- Code maintainability issues
- Performance concerns (non-critical)
- Missing test coverage
- Documentation gaps
- Design pattern violations

**Tone:** Constructive suggestion

### LOW (Optional)

✅ **Use For:**
- Style preferences
- Minor optimizations
- Alternative approaches
- Educational notes
- Future improvements

**Tone:** Optional suggestion

---

## Category Labels Reference

| Category | Use For | Example |
|---|---|---|
| **Security** | Vulnerabilities, auth, encryption | "Missing CSRF token" |
| **Quality** | Code structure, readability, patterns | "Deep nesting" |
| **Performance** | Speed, memory, efficiency | "N+1 query pattern" |
| **Testing** | Coverage, test quality | "No error case tests" |
| **Documentation** | Comments, docs, README | "Missing JSDoc" |
| **Architecture** | Design patterns, structure | "Violates SRP" |
| **Maintainability** | Future maintenance concerns | "Magic numbers" |
| **Compatibility** | Breaking changes, versioning | "API v1 breakage" |

---

## Multi-PR Commenting Guidelines

### When to Batch Comments

✅ **Batch When:**
- Same issue affects multiple PRs
- Dependency chain requires coordinated updates
- PR manager orchestrating multiple reviews

❌ **Don't Batch When:**
- Issues are unrelated
- PRs have different authors requiring different context
- Comments need PR-specific tailoring

### PR-Specific Customization

✅ **Good:**
```markdown
## Update Required: Dependency Version

**PR #123:** Updated auth-service
- [x] Version bumped to 2.1.0
- [ ] Tests passing

**PR #124:** Updated user-service  
- [x] Version bumped to 2.1.0
- [x] Integration tests updated
- [x] Breaking changes documented

Each PR requires verification before merge.
```

❌ **Bad:**
```markdown
Same comment for all PRs.
```
