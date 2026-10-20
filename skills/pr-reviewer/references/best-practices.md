# Best Practices for PR Reviewer

## Review Mindset

### The "Quality Gate" Philosophy
- ✅ You are the last line of defense before code enters main
- ✅ Every issue you catch saves users from bugs
- ✅ Reviews teach the team, not just block code
- ❌ Don't rubber-stamp approvals
- ❌ Don't nitpick without purpose

## Review Preparation

### Before Starting
- ✅ Read PR description to understand context
- ✅ Check linked issues for requirements
- ✅ Note files changed and review size
- ✅ Set aside adequate time (don't rush large PRs)

### Environment Setup
```bash
# Fetch PR to local worktree for deep analysis
cd <worktree>
git fetch origin pull/<number>/head:pr-<number>
git checkout pr-<number>

# Run local checks
npm test
npx tsc --noEmit
```

## Review Execution

### Order of Review
1. **Security First** - Always check for vulnerabilities
2. **Correctness** - Does it do what it claims?
3. **Testing** - Are there tests? Do they cover edge cases?
4. **Performance** - Any obvious issues?
5. **Style/Quality** - Clean code principles
6. **Documentation** - README, comments, API docs

### Comment Guidelines

#### Severity Assignment
| Severity | When to Use | Example |
|----------|-------------|---------|
| **HIGH** | Security, crashes, data loss | SQL injection, null pointer, missing auth |
| **MEDIUM** | Bugs, performance, maintainability | N+1 query, unclear naming, missing tests |
| **LOW** | Style, suggestions, refactoring | Better variable name, extra docs |

#### Constructive Feedback Formula
```
✅ Pattern: Observation + Impact + Suggestion

"The current query loads all users then filters in memory. 
This causes OOM with 100k+ users. 
Consider using WHERE clause in SQL instead."
```

### Code Examples in Comments

#### Good Example
```markdown
**Suggested fix:**
```typescript
// Add null check before accessing
const user = await getUser(id);
if (!user) {
  throw new NotFoundError(`User ${id} not found`);
}
```
```

#### Bad Example
```markdown
❌ Fix this
(No context, no code, no help)
```

## Review Categories

### Security Review Checklist
- [ ] No secrets in code (use Infisical)
- [ ] Input validation present
- [ ] Output encoding/escaping
- [ ] Authorization checks
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection (if applicable)

### TypeScript Review Checklist
- [ ] Functions have return types
- [ ] No `any` without comment explaining why
- [ ] Interfaces preferred over types for objects
- [ ] Generics used appropriately
- [ ] Null/undefined handled

### Testing Review Checklist
- [ ] Tests cover new functionality
- [ ] Edge cases tested (empty, max, null)
- [ ] Error paths tested
- [ ] No test coverage regression
- [ ] Test names describe behavior

### Performance Review Checklist
- [ ] No N+1 database queries
- [ ] Efficient data structures
- [ ] Memoization for expensive calcs (React)
- [ ] No unnecessary re-renders
- [ ] Lazy loading for large data

## Review Delivery

### When to APPROVE
✅ All HIGH issues resolved
✅ All MEDIUM issues addressed or justified
✅ Tests passing
✅ No blocking concerns

### When to REQUEST CHANGES
❌ Any HIGH severity issue
❌ Missing critical tests
❌ Broken functionality
❌ Unaddressed MEDIUM issues from previous review

### When to COMMENT
🤔 Need clarification on approach
🤔 Design concerns to discuss
🤔 Suggestions for future improvement

## Automation Integration

### Pre-Review Automation
```bash
# Run before manual review
npm run lint      # Code style
npm run typecheck # TypeScript
npm run test      # Unit tests
npm run build     # Compilation
```

### Post-Review Actions
- ✅ Update PR status in tracking
- ✅ Notify pr-manager of results
- ✅ Schedule follow-up if needed
- ❌ Don't leave "in progress" reviews dangling

## Review Anti-Patterns

### What to Avoid

#### The "LGTM" Review
```
❌ "Looks good to me" with no actual review
→ Misses obvious issues
→ Wastes the review opportunity
```

#### The "Perfect Code" Review
```
❌ Blocking merge over style preferences
→ "I would have named this differently"
→ If it works and is clear, let it through
```

#### The "Drive-By" Review
```
❌ Quick skim, approve, move on
→ Security issues slip through
→ Logic errors missed
```

## Special Cases

### Large PRs (>500 lines)
- ✅ Request splitting into smaller PRs
- ✅ If must review: schedule dedicated time
- ✅ Focus on architecture first, then details
- ✅ Consider pair-reviewing

### Hotfixes
- ✅ Expedited review but not skipped
- ✅ Security checks still required
- ✅ Post-merge review within 24 hours
- ✅ Document what was bypassed and why

### Dependency Updates
- ✅ Check changelog for breaking changes
- ✅ Verify compatibility matrix
- ✅ Run full test suite
- ✅ Check for security advisories

## Metrics & Improvement

### Track Your Reviews
- Review turnaround time (goal: <4 hours)
- Issues found per review
- Approval rate vs changes requested
- Repeat issues (teaching opportunities)

### Self-Review
Before submitting your review:
- [ ] Are severity levels accurate?
- [ ] Is feedback actionable?
- [ ] Would I want to receive this review?
- [ ] Have I explained the "why"?

## Integration with Team Workflow

### Review Queues
- pr-manager assigns reviews
- Complete within SLA (typically 4-24 hours)
- Escalate if domain expertise needed

### Teaching Moments
- Link to docs or patterns when suggesting changes
- Explain "why" not just "what"
- Reference previous similar issues
- Share knowledge in team channels

### When to Escalate
- Security uncertainty → security-engineer
- Performance questions → qa-engineer with benchmark
- Architecture concerns → tech lead
- Domain knowledge gap → domain expert
