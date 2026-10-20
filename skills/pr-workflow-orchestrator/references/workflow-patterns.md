# Workflow Patterns

## Pattern 1: Single Task Delivery

**Scenario**: User wants to deliver one task from start to finish

**Workflow**:
```
User Request: "Deliver fix for issue #432"

1. DISPATCH pr-worktree
   Input: task=fix/issue-432
   Output: worktree_path=.worktrees/fix-issue-432

2. [WAIT] Developer implements fix in worktree

3. DISPATCH pr-opener
   Input: worktree=.worktrees/fix-issue-432
   Output: pr_number=576

4. IMMEDIATELY DISPATCH pr-feedback-handler
   Input: pr=576, worktree=.worktrees/fix-issue-432
   Output: monitoring_active=true

5. [WAIT] Monitor for reviews/comments
   Loop every 3 minutes:
   - Check for new reviews
   - Check for new comments
   - Check CI status
   - Check mergeable status

6. WHEN feedback received:
   DISPATCH pr-feedback-handler
   Actions:
   - Read all comments
   - Fix or reply to each
   - Push updates
   - Request re-review

7. WHEN approved and CI passing:
   DISPATCH pr-merger
   Input: pr=576
   Output: merged=true

8. CLEANUP worktree
   Command: `git worktree remove .worktrees/fix-issue-432`
   (Run only after PR state is MERGED. If the tree is dirty, report and stop — do not use --force.)

9. REPORT completion
   "✅ DELIVERY COMPLETE - PR #576 merged"
```

## Pattern 2: Handle Existing PR Feedback

**Scenario**: User wants to address feedback on an open PR

**Workflow**:
```
User Request: "Handle feedback for PR #576"

1. VERIFY worktree exists for PR #576
   If not: "Error: Worktree not found. Cannot fix without local branch."

2. FETCH PR details
   - Get all reviews
   - Get all comments
   - Get current state

3. DISPATCH pr-feedback-handler
   Input:
     - pr=576
     - worktree=.worktrees/...
     - reviews=[...]
     - comments=[...]

4. FOR EACH review/comment:
   IF actionable:
     - Fix in worktree
     - Commit with descriptive message
   IF needs discussion:
     - Reply with technical justification

5. PUSH all changes

6. REQUEST re-reviews from all reviewers

7. RESUME monitoring loop
   "Monitoring PR #576 for further feedback..."
```

## Pattern 3: Complete Partial Delivery

**Scenario**: PR exists but hasn't been merged yet

**Workflow**:
```
User Request: "Complete delivery for PR #576"

1. CHECK PR status
   - State: open/closed/merged?
   - CI: passing/failing?
   - Reviews: approved/changes requested?
   - Mergeable: true/false?

2. IF merged:
   - Report: "Already merged"
   - Cleanup worktree if exists
   - Done

3. IF closed:
   - Report: "PR was closed"
   - Document reason
   - Cleanup worktree
   - Done

4. IF open:
   - Check for pending feedback
   - IF feedback exists:
     → DISPATCH pr-feedback-handler
   - ELSE IF ready to merge:
     → DISPATCH pr-merger
   - ELSE IF blocked:
     → Report blockers
     → Suggest next steps
```

## Pattern 4: Parallel Multi-Task Delivery

**Scenario**: User wants to deliver multiple tasks simultaneously

**Workflow**:
```
User Request: "Deliver issues #432, #444, #445"

1. PARALLEL DISPATCH pr-worktree (x3)
   - Task fix/issue-432 → worktree-1
   - Task fix/issue-444 → worktree-2
   - Task fix/issue-445 → worktree-3

2. [WAIT] All developers work in parallel

3. PARALLEL DISPATCH pr-opener (x3)
   - worktree-1 → PR #576
   - worktree-2 → PR #577
   - worktree-3 → PR #578

4. PARALLEL DISPATCH pr-feedback-handler (x3)
   - Handler-1 monitors PR #576
   - Handler-2 monitors PR #577
   - Handler-3 monitors PR #578

5. INDEPENDENT monitoring loops (all 3 PRs)
   Each handler monitors its assigned PR

6. WHEN each PR ready:
   DISPATCH pr-merger for that PR

7. PARALLEL CLEANUP (x3)
   Remove all 3 worktrees

8. FINAL REPORT
   "✅ ALL DELIVERIES COMPLETE
    - PR #576: Merged ✅
    - PR #577: Merged ✅
    - PR #578: Merged ✅"
```

## Pattern 5: Resume Stalled Delivery

**Scenario**: PR has been open with no activity

**Workflow**:
```
User Request: "Check on my open PRs"

1. QUERY open PRs by current user
   gh pr list --author "@me" --state open

2. FOR EACH open PR:
   - Calculate idle time
   - Check last activity
   - Identify blocker

3. CATEGORIZE:
   - Waiting for review > 24h → Ping reviewer
   - CI failing → Dispatch fix
   - Merge conflicts → Dispatch fix
   - Approved but not merged → Verify CI passing, no conflicts, issue linked → dispatch pr-merger

4. TAKE ACTION on each

5. REPORT status
   "Found 3 open PRs:
   - #576: Pinging reviewer (idle 26h)
   - #577: Fixing CI failure...
   - #578: Ready to merge → merging now"
```

## Decision Matrix

| Scenario | First Action | Follow-up | Completion |
|----------|--------------|-----------|------------|
| New task | pr-worktree | pr-opener → feedback-handler | pr-merger |
| Task done, no PR | pr-opener | feedback-handler | pr-merger |
| PR open, no feedback | feedback-handler | Continue monitoring | pr-merger |
| PR open, has feedback | feedback-handler | Fix/reply | pr-merger |
| Multiple tasks | Parallel pr-worktree | Parallel pr-opener | Parallel pr-merger |
| Stalled PR | Identify blocker | Fix or escalate | pr-merger |
