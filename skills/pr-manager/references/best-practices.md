# PR Manager Best Practices

Best practices for orchestrating multiple PRs with strict DoD enforcement.

---

## 1. Definition of Done (DoD)

### The Two Requirements

| Requirement | Verification | Enforcement |
|-------------|--------------|-------------|
| Issue linked | `Closes #N` in PR body | BLOCK if missing |
| PR merged | State = MERGED on GitHub | ONLY completion criteria |

### DoD Violation Handling

**Scenario**: PR opened without issue
```
🚫 PR CREATION BLOCKED - DoD NOT MET

Issue: Not found
PR: Not created (blocked)

Actions Taken:
1. Searched for issues matching branch/task
2. No matching issue found
3. Created issue #45: "Work from branch 'quick-fix'"

Next Steps:
- Issue #45 is ready
- Can now create PR with proper link
- Rerun: @pr-manager Manage PRs
```

### DoD Metrics

Track weekly:
```
PR Manager: DoD Compliance Report
════════════════════════════════════

Week of: 2026-03-30

Metrics:
- PRs Created: 45
- Issues Linked: 45 (100%)
- DoD Violations: 0
- Auto-Fixed PRs: 3
- Merged PRs: 38

Compliance Rate: 100% ✅
```

---

## 2. Batch Operation Phases

### Phase Structure

```
Batch PR Operation:

Phase 1: Pre-flight (verification)
├── Verify all branches exist
├── Check for linked issues
├── Create missing issues
└── Report: "X of Y ready"

Phase 2: Creation (execution)
├── Push all branches
├── Create all PRs
├── Link all PRs to issues
└── Report: "X PRs created"

Phase 3: Labeling (automation)
├── Dispatch pr-labeler for each PR
├── Verify labels applied
└── Report: "X PRs labeled"

Phase 4: Monitoring (continuous)
├── Check for comments (3-min cycle)
├── Handle feedback
├── Merge when ready
└── Report: "X merged, Y pending"
```

### Batch Size Guidelines

| Batch Size | Approach | Rationale |
|------------|----------|-----------|
| 1-3 | Single phase | Low coordination overhead |
| 4-10 | Full phases | Balance throughput and control |
| 11-20 | Chunked (10 at a time) | Manageable error handling |
| 21+ | Queued with priority | Sequential with priority |

---

## 3. Prioritization Strategy

### Priority Factors

| Factor | Weight | Calculation |
|--------|--------|-------------|
| DoD violation | 1000 | Binary: linked or not |
| Age | × 10 | Days since creation |
| Category | +100/80/60/40 | INF/O1/O2/O3 |
| Size | −0.01/line | Smaller first |
| Blocked | −50 | Conflicts, failures |

### Priority Queue Example

```
Priority Queue (highest first):

Rank  Score  PR      Reason
────  ─────  ──────  ─────────────────────
1     1035   #277    Missing issue (BLOCK)
2     130    #278    5 days old, INF task
3     85     #279    3 days old, O1 task
4     75     #280    2 days old, O1, 1000 lines
5     40     #281    1 day old, O3 task
```

---

## 4. Subagent Coordination

### Orchestration Patterns

**Sequential** (one after another):
```
pr-opener → pr-labeler
[Create PR] → [Apply labels]
```

**Parallel** (simultaneous):
```
pr-reviewer || pr-commenter
[Review code] + [Post comments]
```

**Gated** (conditional):
```
(pr-reviewer && pr-commenter) → pr-feedback-handler
[Both done] → [Handle feedback]
```

### Error Propagation

**Strategy**: Stop and report, or continue with degraded functionality

```
Phase 2: Review
├── pr-reviewer: Error (network)
│   └── Action: Retry 3x, then skip
├── pr-commenter: Success
└── Status: ⚠️ Partial (proceed with warning)

Phase 3: Resolution
└── pr-feedback-handler: BLOCKED (review incomplete)
    └── Action: Wait for manual review
```

---

## 5. State Management

### PR Registry Structure

```yaml
PRs:
  - number: 277
    task: O2-10
    branch: okr/o2-10-stripe
    worktree: ~/.worktrees/okr-o2-10-stripe
    issue: 41
    status: feedback_pending
    priority: 85
    comments: 2
    dod_status: met  # ✅
    
  - number: 278
    task: O2-11
    branch: okr/o2-11-payment-ui
    worktree: ~/.worktrees/okr-o2-11-payment-ui
    issue: 42
    status: approved_ready
    priority: 70
    comments: 0
    dod_status: met  # ✅

DoD Metrics:
  total: 17
  issues_linked: 17
  prs_merged: 1
  compliance_rate: 100%
```

---

## 6. Common Mistakes

### Mistake 1: Creating PRs Without Issue Verification

**Problem**:
```
pr-manager: Created 20 PRs
Status: Done
```

**Impact**: DoD not met, tracking broken.

**Fix**: Always include Phase 1 (Issue Verification).

### Mistake 2: No Priority for DoD Violations

**Problem**: PRs without issues get same priority as valid PRs.

**Impact**: Urgent fixes delayed by missing infrastructure.

**Fix**: Add DoD weight (1000 points) to priority algorithm.

### Mistake 3: No Continuous Monitoring

**Problem**: Create PRs, then stop.

**Impact**: Comments not addressed, PRs stall.

**Fix**: 3-minute monitoring cycle with feedback handlers.

### Mistake 4: Unclear Subagent Responsibilities

**Problem**: Multiple agents trying to do the same thing.

**Impact**: Conflicts, duplicate work.

**Fix**: Clear orchestration phases with explicit handoffs.

---

## 7. Success Metrics

### Weekly Dashboard

```
PR Manager: Weekly Summary
═══════════════════════════════════

Throughput:
- PRs Created: 45
- PRs Merged: 38 (84%)
- Average Time to Merge: 2.3 days

Quality:
- DoD Compliance: 100%
- Issues Auto-Created: 12
- Review Feedback Handled: 156

Efficiency:
- Batch Operations: 5 (avg 9 PRs each)
- Priority Queue Accuracy: 95%
- Integration Success Rate: 92%
```

### Target Metrics

| Metric | Target | Minimum |
|--------|--------|---------|
| DoD Compliance | 100% | 95% |
| Time to Merge | < 3 days | < 5 days |
| Batch Success | > 90% | > 80% |
| Feedback Response | < 4 hours | < 8 hours |
