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

Issue Link Compliance: 45/45 PRs (100% ✅)
DoD Compliance (linked AND merged): 38/45 (84% ⏳)
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

The priority algorithm is defined in `skills/pr-manager/SKILL.md` → Priority Algorithm (single source of truth).

### Priority Factors

| Factor | Weight | Calculation |
|--------|--------|-------------|
| DoD violation | 1000 | Binary: linked or not |
| Age | × 10 | Days since creation |
| Category | +100/80/60/40 | infra/critical/high/normal |
| Size | −0.01/line | Smaller first |
| Blocked | −50 | Conflicts, failures |

### Priority Queue Example

```
Priority Queue (highest first):

Rank  Score  PR      Reason
────  ─────  ──────  ──────────────────────────
1     1035   #277    Missing issue (BLOCK) — 1000 + 35 age
2     150    #278    5 days old, infra task — 50 + 100
3     110    #279    3 days old, critical task — 30 + 80
4     90     #280    2 days old, critical, 1000 lines — 20 + 80 − 10
5     50     #281    1 day old, normal task — 10 + 40
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
  - number: 278
    task: infra-1
    branch: feature/infra-1-service
    worktree: .worktrees/feature-infra-1-service
    issue: 42
    status: approved_ready
    priority: 150
    comments: 0
    dod_status: met  # ✅

  - number: 279
    task: critical-1
    branch: feature/critical-1-auth
    worktree: .worktrees/feature-critical-1-auth
    issue: 43
    status: feedback_pending
    priority: 110
    comments: 2
    dod_status: met  # ✅

DoD Metrics:
  total: 17
  issues_linked: 17
  prs_merged: 1
  issue_link_compliance: 100%
  dod_compliance: 6%
```

Dashboard summary for the registry above:
```
Issue Link Compliance: 17/17 PRs (100% ✅)
DoD Compliance (linked AND merged): 1/17 (6% ⏳)
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
- Issue Link Compliance: 45/45 PRs (100% ✅)
- DoD Compliance (linked AND merged): 38/45 (84% ⏳)
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
| Feedback Response | < 15 min | < 30 min |
