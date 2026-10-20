# PR Manager Acceptance Criteria

**Skill**: `pr-manager`

**Purpose**: Produce PR orchestration that ensures all PRs meet Definition of Done (issue linked + merged).

**Focus**: DoD enforcement, batch operations, prioritization, multi-skill coordination.

---

## 1. Definition of Done Enforcement

### 1.1 ✅ CORRECT: Every PR Has Linked Issue Before Creation

**Example**:
```
User: @pr-manager Manage PRs for 20 OKR tasks

pr-manager:
Phase 1: Issue Verification
- Checking 20 branches for linked issues...
- Found: 15 issues exist
- Missing: 5 issues (TASK-15, TASK-16, TASK-17, TASK-18, TASK-19)
- Creating 5 missing issues...
- ✅ All 20 branches now have linked issues

Phase 2: PR Creation
- Creating 20 PRs with issue links...
- PR #200 → Issue #50 ✅
- PR #201 → Issue #51 ✅
- ...

DoD Compliance: 100% (20/20 issues linked)
```

### 1.2 ✅ CORRECT: DoD Verification in Dashboard

```
PR Manager Dashboard
═══════════════════════════════════════════
DoD Compliance: 17/17 PRs (100% ✅)

DoD Summary:
✅ Issue Linked + PR Merged: 1
⏳ Issue Linked + PR Open: 16
🚫 Missing Issue Link: 0

DoD Enforcement: ✅ ACTIVE
```

### 1.3 ❌ INCORRECT: PRs Created Without Issues

```
pr-manager: Created 20 PRs
Status: Done
```

**Problem**: No issue verification, DoD not enforced.

---

## 2. Batch Operations

### 2.1 ✅ CORRECT: Coordinated Batch Creation

**Input**:
```
@pr-manager Manage PRs for:
- TASK-1: feature/payment
- TASK-2: feature/auth
- TASK-3: fix/bug-404
```

**Output**:
```
Phase 1: Issue Verification (3 issues found ✅)
Phase 2: Creating PRs
  ✅ PR #201: feature/payment → Issue #101
  ✅ PR #202: feature/auth → Issue #102
  ✅ PR #203: fix/bug-404 → Issue #103
Phase 3: Labeling (via pr-labeler)
Phase 4: Monitoring active
```

### 2.2 ✅ CORRECT: Handling Missing Issues at Scale

**Scenario**: 5 of 20 branches lack issues

**Response**:
```
🚫 DoD BLOCKED: 5 branches missing issues
Creating issues for TASK-15, TASK-16, TASK-17, TASK-18, TASK-19...
✅ Created: #45, #46, #47, #48, #49
Resuming PR creation...
```

### 2.3 ❌ INCORRECT: Individual PR Creation

```
@pr-manager Manage PRs for 20 tasks

pr-manager:
Created PR #201 for branch-1
Created PR #202 for branch-2
...
Created PR #220 for branch-20
Done.
```

**Problem**: No batch coordination, no DoD enforcement, no priority handling.

---

## 3. PR Prioritization

### 3.1 ✅ CORRECT: Priority with DoD Weight

```javascript
function calculatePriority(pr) {
  let score = 0;
  
  // DoD violation = highest priority
  if (!pr.hasIssueLink) score += 1000;
  
  // Age factor
  score += daysOpen(pr) * 10;
  
  // Category priority
  if (pr.category === 'INF') score += 100;
  if (pr.category === 'O1') score += 80;
  if (pr.category === 'O2') score += 60;
  
  // Size factor
  score -= (pr.linesChanged / 100);
  
  return score;
}
```

### 3.2 ✅ CORRECT: Prioritization by Criteria

```
@pr-manager Prioritize PRs by: dod-status

Priority Queue (highest first):
1. PR #277: MISSING ISSUE (score: 1035) 🔴
2. PR #278: 5 days old, O1 (score: 130) 🟡
3. PR #279: 2 days old, O2 (score: 80) 🟢
```

### 3.3 ❌ INCORRECT: No Priority Strategy

```
@pr-manager Prioritize PRs

Processing in order created...
```

**Problem**: No criteria, no DoD weighting, no urgency consideration.

---

## 4. Multi-Skill Coordination

### 4.1 ✅ CORRECT: Clear Subagent Orchestration

```
PR Lifecycle Coordination:

Phase 1: Creation
├── pr-opener (create with issue link)
└── pr-labeler (auto-apply labels)

Phase 2: Review
├── pr-reviewer (code quality)
└── pr-commenter (structured comments)

Phase 3: Resolution
├── pr-feedback-handler (address comments)
└── pr-merger (merge when approved)

Dependencies:
- pr-opener → pr-labeler (sequential)
- pr-reviewer || pr-commenter (parallel)
- All review → pr-feedback-handler (gate)
```

### 4.2 ✅ CORRECT: Error Handling Across Skills

```
Phase 2: Review
├── pr-reviewer: PR #277 has security vulnerability
├── Action: Dispatch security-engineer
└── Status: ⏸️ BLOCKED until resolved

Options:
1. Fix vulnerability → continue
2. Override (risk acknowledged) → continue
3. Cancel workflow → clean up
```

### 4.3 ❌ INCORRECT: Unclear Coordination

```
@pr-manager Manage 20 PRs

Dispatching agents...
[Done]
```

**Problem**: No visibility into which agents, when, dependencies, status.

---

## 5. Monitoring and Feedback

### 5.1 ✅ CORRECT: Continuous Monitoring

```
[Continuous monitoring...]

pr-manager:
"PR #277 has 2 new comments - dispatching handler"
"PR #278 approved, issue #42 linked, merging now"
"PR #279 opened, checking DoD compliance... ✅"
```

### 5.2 ✅ CORRECT: Dashboard with Metrics

```
PR Manager Dashboard
═══════════════════════════════════════════

DoD Compliance: 17/17 PRs (100% ✅)

Active PRs: 17
┌─────────┬───────────────────────────┬──────────────┬─────────┬──────────┐
│ PR      │ Task                      │ Status       │ Issue   │ DoD      │
├─────────┼───────────────────────────┼──────────────┼─────────┼──────────┤
│ #264    │ INF-1: Tilt Docker        │ ✅ Merged    │ #40     │ ✅ MET   │
│ #277    │ O2-10: Stripe Payment     │ 🔄 Feedback  │ #41     │ ✅ MET   │
│ #278    │ O2-11: Payment UI         │ ⏳ Approved   │ #42     │ ✅ MET   │
│ #279    │ INT-19: Google Calendar   │ 🆕 Open      │ #43     │ ✅ MET   │
└─────────┴───────────────────────────┴──────────────┴─────────┴──────────┘

Actions Needed:
- 2 PRs have new comments (dispatching handlers)
- 1 PR approved and ready to merge
- 0 PRs need issue creation
```

### 5.3 ❌ INCORRECT: No Monitoring

```
pr-manager: Created 20 PRs. Monitoring complete.
```

**Problem**: No continuous monitoring, feedback not handled.

---

## 6. Integration Coordination

### 6.1 ✅ CORRECT: Integration Progress Tracking

```
Integration: Stripe Payment
══════════════════════════════════════════

Project: #7
PRs in Integration: 5
┌─────────┬──────────────────────────────┬──────────┬────────┐
│ PR      │ Title                        │ Status   │ Issue  │
├─────────┼──────────────────────────────┼──────────┼────────┤
│ #234    │ feat: Add Stripe auth        │ ✅ Merged│ #601   │
│ #235    │ feat: Payment UI             │ 🔄 Open  │ #602   │
│ #236    │ feat: Webhook handlers       │ ⏳ Draft │ #603   │
│ #237    │ feat: Error handling         │ ✅ Merged│ #604   │
│ #238    │ docs: Integration guide      │ 🔄 Open  │ #605   │
└─────────┴──────────────────────────────┴──────────┴────────┘

Progress: 40% (2/5 PRs merged)
DoD Compliance: 100% (5/5 issues linked)
```

### 6.2 ❌ INCORRECT: No Integration Visibility

```
@pr-manager Manage Stripe Payment integration

Managing integration...
Done.
```

---

## 7. Anti-Patterns Summary

| Anti-Pattern | Impact | Fix |
|--------------|--------|-----|
| No DoD enforcement | PRs without issues | Add issue verification phase |
| No batch coordination | Inefficient processing | Implement phased batch workflow |
| No prioritization | Wrong PRs merged first | Add weighted priority algorithm |
| No monitoring | Feedback not handled | Continuous 3-minute monitoring |
| No subagent visibility | Unclear orchestration | Explicit coordination phases |
| No integration tracking | Progress unclear | Integration progress dashboard |

---

## 8. Checklist for PR Manager

- [ ] DoD enforced: Issue linked before PR creation
- [ ] DoD verified: All PRs have "Closes #N" reference
- [ ] Batch operations coordinated in phases
- [ ] Missing issues auto-created at scale
- [ ] Prioritization algorithm includes DoD weight
- [ ] Subagents orchestrated with clear dependencies
- [ ] Continuous monitoring active (3-min cycle)
- [ ] Dashboard shows DoD metrics
- [ ] Integration progress tracked
- [ ] Feedback handled automatically
