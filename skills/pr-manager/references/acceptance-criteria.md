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
Issue Link Compliance: 17/17 PRs (100% ✅)
DoD Compliance (linked AND merged): 1/17 (6% ⏳)

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

The priority algorithm is defined in `skills/pr-manager/SKILL.md` → Priority Algorithm (single source of truth).

Default category weights used by that algorithm: `infra` +100, `critical` +80, `high` +60, `normal` +40.

### 3.2 ✅ CORRECT: Prioritization by Criteria

```
@pr-manager Prioritize PRs by: dod-status

Priority Queue (highest first):

Rank  Score  PR      Reason
────  ─────  ──────  ──────────────────────────
1     1035   #277    Missing issue (BLOCK) — 1000 + 35 age
2     150    #278    5 days old, infra task — 50 + 100
3     110    #279    3 days old, critical task — 30 + 80
4     90     #280    2 days old, critical, 1000 lines — 20 + 80 − 10
5     50     #281    1 day old, normal task — 10 + 40
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
══════════════════════════════════════════

Issue Link Compliance: 17/17 PRs (100% ✅)
DoD Compliance (linked AND merged): 1/17 (6% ⏳)

Active PRs: 17
┌─────────┬───────────────────────────┬──────────────┬─────────┬──────────┐
│ PR      │ Task                      │ Status       │ Issue   │ DoD      │
├─────────┼───────────────────────────┼──────────────┼─────────┼──────────┤
│ #264    │ infra-1: Tilt Docker      │ ✅ Merged    │ #40     │ ✅ MET   │
│ #277    │ high-10: Stripe Payment   │ 🔄 Feedback  │ #41     │ ⏳ PENDING │
│ #278    │ high-11: Payment UI       │ ⏳ Approved   │ #42     │ ⏳ PENDING │
│ #279    │ normal-19: Calendar Sync  │ 🆕 Open      │ #43     │ ⏳ PENDING │
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
