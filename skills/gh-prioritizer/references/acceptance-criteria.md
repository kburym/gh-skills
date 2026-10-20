# GitHub Prioritizer Acceptance Criteria

**Skill**: `gh-prioritizer`

**Purpose**: Produce automated priority assignment for GitHub Projects V2 items that accurately reflects urgency and impact.

**Focus**: Priority detection rules, override logic, SLA compliance, batch operations.

---

## 1. Priority Detection Accuracy

### 1.1 ✅ CORRECT: P0-Critical Detected for Production Blockers

**Example**:
```bash
gh-prioritizer set 323 --project 1

Input:
- PR #323: Title "hotfix: Resolve payment gateway failure"
- Labels: hotfix, critical
- Branch: hotfix/payment-fix
- Files: src/payment/gateway.ts

Output:
PR #323 set to P0-Critical (hotfix branch, affects payment system)
```

**Detection**:
- Branch pattern `hotfix/*` → P0 ✓
- Label "hotfix" → P0 ✓
- File path includes "payment" → P0 ✓

### 1.2 ✅ CORRECT: P1-High for User-Facing Bugs

**Example**:
```bash
gh-prioritizer set 316 --project 1

Input:
- PR #316: Title "fix: Resolve 404 error on settings page"
- Labels: bug, user-facing
- Files: frontend/settings/[id].tsx
- Size: 150 lines

Output:
PR #316 set to P1-High (user-facing bug, affects core functionality)
```

**Detection**:
- Label "bug" + "user-facing" → P1 ✓
- File path includes "settings" → P1 ✓

### 1.3 ✅ CORRECT: P3-Low for Documentation

**Example**:
```bash
gh-prioritizer set 320 --project 1

Input:
- PR #320: Title "docs: Update API documentation"
- Labels: documentation
- Files: docs/api.md, README.md
- Size: 45 lines

Output:
PR #320 set to P3-Low (documentation only, <50 lines)
```

**Detection**:
- Label "documentation" → P3 ✓
- File extensions `.md` → P3 ✓
- Size < 50 lines → P3 ✓

### 1.4 ❌ INCORRECT: Wrong Priority Assignment

**Scenario**:
```bash
# Hotfix PR without P0
Input: Branch "hotfix/critical-fix", Label "hotfix"
Output: P2-Medium ❌

Expected: P0-Critical ✅
```

**Problem**: Hotfix detection not working.

---

## 2. Priority Override Rules

### 2.1 ✅ CORRECT: Higher Priority Wins

**Example**:
```bash
# PR matches both P0 and P1 rules
- Branch: hotfix/security  # P0 rule
- Label: bug                # P1 rule
- Result: P0-Critical ✅ (higher priority wins)
```

### 2.2 ✅ CORRECT: Override for Special Labels

**Example**:
```bash
# DO-NOT-MERGE label skips priority
Input: Labels ["bug", "DO-NOT-MERGE"]
Result: No priority assigned ✅

# WIP label forces P3
Input: Labels ["feature", "WIP"]
Result: P3-Low ✅
```

### 2.3 ❌ INCORRECT: Priority Not Overridden

**Scenario**:
```bash
Input: Labels ["hotfix", "WIP"]
Current: P0-Critical ❌
Expected: P3-Low ✅ (WIP should override)
```

---

## 3. Batch Operations

### 3.1 ✅ CORRECT: Batch Update All Items

**Example**:
```bash
gh-prioritizer update-project 1

Processing 11 items...
✅ PR #323: P0-Critical (hotfix)
✅ PR #316: P1-High (user-facing bug)
✅ PR #315: P1-High (large PR)
✅ PR #314: P2-Medium (feature)
✅ Issue #42: P2-Medium (enhancement)
✅ PR #320: P3-Low (docs)
...

Summary:
  P0-Critical: 1 item
  P1-High: 5 items
  P2-Medium: 4 items
  P3-Low: 1 item
```

### 3.2 ✅ CORRECT: Audit with Inconsistency Detection

**Example**:
```bash
gh-prioritizer audit --project 1

✓ All items have priority assigned
⚠ PR #316 has status/blocked but is P1-High
  Recommendation: Consider P0-Critical?
✓ 11/11 items consistent
```

### 3.3 ❌ INCORRECT: Batch Update Failures Not Reported

**Scenario**:
```bash
gh-prioritizer update-project 1

Output: "Updated project"

Problem: 3 items failed, no error reported ❌
```

---

## 4. GitHub Projects V2 Integration

### 4.1 ✅ CORRECT: GraphQL Mutation Successful

**Example**:
```bash
# Set priority via GraphQL
gh api graphql -f query='...' \
  -f projectId="PVT_xxx" \
  -f itemId="PVTI_xxx" \
  -f fieldId="PVTF_xxx" \
  -f optionId="PVTSSO_xxx"

Response:
{
  "data": {
    "updateProjectV2ItemFieldValue": {
      "projectV2Item": {
        "id": "PVTI_xxx"
      }
    }
  }
}
```

### 4.2 ✅ CORRECT: Error Handling for Auth Issues

**Example**:
```bash
# Token missing 'project' scope
Error: INSUFFICIENT_SCOPES

Action:
1. Report: "GitHub CLI needs project scopes"
2. Provide command: "gh auth login --scopes 'repo,read:project,write:project'"
3. Exit gracefully
```

### 4.3 ❌ INCORRECT: Silent Failures

**Scenario**:
```bash
gh-prioritizer set 323 --project 1

Output: "Priority set" ✅

Reality: No GraphQL call made ❌
```

---

## 5. Size-Based Detection

### 5.1 ✅ CORRECT: Large PR Detection

| Lines | Expected | Actual | Status |
|-------|----------|--------|--------|
| 50 | XS or S | - | - |
| 150 | M | M | ✅ |
| 350 | L | L | ✅ |
| 550 | XL + P1 | XL + P1 | ✅ |

### 5.2 ❌ INCORRECT: Size Calculation Wrong

**Scenario**:
```bash
PR: +300 lines, -50 lines
Expected: 350 lines (L) → P1 consideration
Actual: 300 lines (M) → P2 ❌

Fix: Should use additions + deletions
```

---

## 6. SLA Tracking

### 6.1 ✅ CORRECT: SLA Status Report

**Example**:
```bash
gh-prioritizer report --project 1 --sla-check

╔══════════════════════════════════════════╗
║     Priority Distribution & SLA Status     ║
╠══════════════════════════════════════════╣
║  🔴 P0-Critical:  1 item  (⚠️ SLA at risk) ║
║  🟠 P1-High:      5 items (✅ Within SLA) ║
║  🟡 P2-Medium:    4 items (✅ Within SLA) ║
║  🟢 P3-Low:       1 item  (✅ Within SLA) ║
╠══════════════════════════════════════════╣
║  SLA at risk: 1 P0 item > 4 hours old     ║
╚══════════════════════════════════════════╝
```

---

## 7. Anti-Patterns Summary

| Anti-Pattern | Impact | Fix |
|--------------|--------|-----|
| Wrong priority assignment | Urgent work delayed | Check detection rules |
| No override handling | WIP marked as P0 | Implement override logic |
| Silent failures | Think it's working | Add error reporting |
| Missing SLA tracking | Miss deadlines | Add SLA monitoring |
| Batch errors hidden | Incomplete updates | Report all failures |

---

## 8. Checklist for GitHub Prioritizer

- [ ] P0 detected for hotfix branches
- [ ] P0 detected for security labels
- [ ] P1 detected for user-facing bugs
- [ ] P1 detected for large PRs (>500 lines)
- [ ] P3 detected for documentation
- [ ] Higher priority wins in conflicts
- [ ] DO-NOT-MERGE skips assignment
- [ ] WIP forces P3
- [ ] Batch update reports all items
- [ ] Audit detects inconsistencies
- [ ] GraphQL errors handled gracefully
- [ ] SLA status tracked and reported
- [ ] Size calculated correctly (additions + deletions)
