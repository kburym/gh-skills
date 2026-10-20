# GitHub Prioritizer Best Practices

Best practices for automated priority management in GitHub Projects.

---

## 1. Priority Level Guidelines

### When to Use Each Priority

| Priority | Use For | Don't Use For |
|----------|---------|---------------|
| **P0-Critical** | Production down, security vulnerabilities, hotfixes, data loss | Feature work, minor bugs, docs |
| **P1-High** | User-facing bugs, major features, OKR work, blocking dependencies | Tech debt, small refactors |
| **P2-Medium** | Feature enhancements, non-blocking bugs, performance improvements | Urgent fixes, user blockers |
| **P3-Low** | Documentation, testing, tech debt, small refactors (<100 lines) | Production issues, security |

### Priority Escalation

**Auto-escalate to P0 when**:
- Production monitoring alerts fire
- Security scan finds vulnerabilities
- Customer reports data loss
- Payment system fails

**Never escalate**:
- Documentation fixes
- Test additions
- Code style changes

---

## 2. Detection Rule Optimization

### Rule Ordering

```javascript
// Check in priority order (highest first)
const checkOrder = [
  "P0-Critical",  // Check first - never miss critical
  "P1-High",      // Then high priority
  "P2-Medium",    // Then medium
  "P3-Low"        // Last - default
];

// Example: Security label should trigger P0 even if also "documentation"
if (labels.includes("security")) return "P0-Critical";
if (labels.includes("documentation")) return "P3-Low";
```

### Label-Based Detection

**High-confidence labels** (immediately assign):
```javascript
const immediateLabels = {
  "hotfix": "P0-Critical",
  "critical": "P0-Critical",
  "security": "P0-Critical",
  "production-down": "P0-Critical",
  "DO-NOT-MERGE": null,  // Skip
  "WIP": "P3-Low"
};
```

**Contextual labels** (consider with other factors):
```javascript
const contextualLabels = {
  "bug": 1,           // +1 priority level
  "user-facing": 1,   // +1 priority level
  "large-pr": 1,      // +1 priority level (>500 lines)
  "refactor": -1,     // -1 priority level
  "documentation": -2   // -2 priority levels
};
```

### File Path Detection

**Critical paths** (always P0 if modified):
```
**/auth/**
**/authentication/**
**/payment/**
**/security/**
**/encryption/**
**/credential/**
**/token/**
```

**User-facing paths** (P1 consideration):
```
**/api/**
**/auth/**
**/payment/**
**/frontend/**
**/*.tsx
**/*.jsx
```

---

## 3. Size-Based Priority

### Size Thresholds

| Size | Lines | Priority Impact |
|------|-------|-----------------|
| XS | < 50 | P3 consideration |
| S | 50-100 | Neutral |
| M | 100-300 | Neutral |
| L | 300-500 | P1 consideration |
| XL | > 500 | P1 required |

### Size Calculation

```bash
# Correct calculation
SIZE=$(gh pr view <number> --json additions,deletions --jq '.additions + .deletions')

# Not just additions
# Not just changed files count
```

---

## 4. Override Rules

### Standard Overrides

| Condition | Override | Rationale |
|-----------|----------|-----------|
| `DO-NOT-MERGE` label | Skip priority | Not ready for queue |
| `WIP` label | Force P3 | Work in progress |
| Draft PR | Force P3 | Not ready for review |
| `blocked` label | Bump +1 | Needs attention |
| Author is senior | No change | Don't bias |

### Manual Override

```bash
# When auto-detection is wrong
gh-prioritizer set-manual 323 P1-High

# Document why
gh issue comment 323 --body "Manual priority: P1-High (auto-detected P2, but affects reporting)"
```

---

## 5. Batch Operations

### Daily Priority Sync

```bash
#!/bin/bash
# daily-priority-sync.sh

echo "Running daily priority sync..."

# 1. Label new PRs first
pr-labeler hygiene-check

# 2. Update all priorities
gh-prioritizer update-project 1

# 3. Check for SLA violations
gh-prioritizer audit --project 1 --sla-check

# 4. Generate report
gh-prioritizer report --project 1

echo "Priority sync complete"
```

### Batch Safety

**Always**:
- Run with `--dry-run` first on large projects
- Report counts (not just "success")
- Handle rate limits gracefully

```bash
# Good
gh-prioritizer update-project 1
# Output: "Updated 23 items: P0:1, P1:8, P2:10, P3:4"

# Bad
gh-prioritizer update-project 1
# Output: "Updated project" ❌
```

---

## 6. SLA Management

### SLA Targets

| Priority | Target SLA | Alert Threshold |
|----------|------------|-----------------|
| P0-Critical | 4 hours | 3 hours |
| P1-High | 1-2 days | 1 day |
| P2-Medium | 1 week | 5 days |
| P3-Low | As convenient | Never |

### SLA Monitoring

```bash
# Check for at-risk items
gh-prioritizer audit --project 1 --sla-check

# Expected output:
# ⚠️ 2 items approaching SLA:
#   - PR #323 (P0): 3.5 hours old
#   - PR #316 (P1): 1.5 days old
```

---

## 7. Common Mistakes

### Mistake 1: Over-Prioritizing

**Scenario**: Every PR is P1 or P0

**Problem**: No differentiation, SLA meaningless

**Fix**: 
- Default to P2 for features
- Require justification for P0/P1
- Regular audit: "Why is this P1?"

### Mistake 2: Under-Prioritizing Security

**Scenario**: Security fix marked as P2

**Problem**: Security vulnerabilities not addressed quickly

**Fix**: 
- Always P0 for security label
- Override any other rules

### Mistake 3: Ignoring Size

**Scenario**: 1000-line PR marked as P3

**Problem**: Large PRs need urgent review

**Fix**: 
- XL PRs (>500 lines) automatically P1
- Require 2+ reviewers for XL

### Mistake 4: No Override Handling

**Scenario**: WIP PR marked as P0

**Problem**: Not ready for review in critical queue

**Fix**: 
- WIP label forces P3
- Draft PRs get P3

---

## 8. Integration Best Practices

### With pr-labeler

```
1. PR created
2. pr-labeler auto-labels
3. gh-prioritizer sets priority based on labels
4. pr-manager uses priority for queue order
```

**Timing**: Run prioritization after labeling

### With pr-manager

```bash
# PR manager uses priority for orchestration
@pr-manager Prioritize PRs by: priority

# High priority PRs get reviewed first
```

### With issue-labeler

```bash
# Sync issue and PR priorities
gh-prioritizer set 323 --project 1  # Set PR priority
gh-prioritizer set 42 --project 1   # Set linked issue priority
```

---

## 9. Performance Optimization

### Caching

```bash
# Cache project field IDs
PROJECT_FIELDS=$(gh api graphql -f query='...' | jq '.')
# Reuse for multiple operations
```

### Batch Size

```bash
# Process in batches of 50
gh project item-list 1 --limit 50 | \
  jq -c '.items[]' | \
  while read item; do
    # Process each item
  done
```

### Rate Limit Handling

```bash
# Check rate limit
gh api rate_limit --jq '.resources.graphql'

# Add delay if needed
sleep 1
```
