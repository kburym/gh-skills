# Acceptance Criteria

## Functional Requirements

### PR Creation
- [ ] Worktree created with proper branch naming
- [ ] PR has linked GitHub issue (Closes #XXX)
- [ ] PR title follows convention: `<type>: <description> (Closes #<issue>)`
- [ ] PR description includes summary and change list
- [ ] All CI checks passing before merge consideration

### Feedback Handling
- [ ] All review comments addressed within 10 minutes
- [ ] Each comment either fixed or replied to with justification
- [ ] CI failures investigated and resolved within 15 minutes
- [ ] Merge conflicts rebased and fixed within 15 minutes
- [ ] Requested changes implemented and pushed
- [ ] Re-review requested after changes

### Merge Completion
- [ ] All review feedback resolved
- [ ] CI status: passing
- [ ] No merge conflicts
- [ ] Minimum 1 approval from a reviewer with write access
- [ ] Linked issue properly referenced
- [ ] No blocking labels present (e.g. `status/blocked`, per pr-labeler's label standards)
- [ ] Worktree cleaned up after merge

## Orchestration Patterns

### Sequential Execution
```
pr-worktree → [dev work] → pr-opener → pr-feedback-handler → pr-merger → cleanup
```

### Parallel Execution
```
pr-worktree (x3) → pr-opener (x3) → pr-feedback-handler (x3) → pr-merger (x3) → cleanup (x3)
```

### Continuous Monitoring Loop
Re-check the PR every 3 minutes. At each tick run:
- `gh pr view <number> --json state,mergeStateStatus,statusCheckRollup,reviewDecision`
- `gh pr view <number> --json reviews,comments`
- `gh api "repos/{owner}/{repo}/pulls/<number>/comments" --paginate --jq '.[] | {author: .user.login, path: .path, line: .line, body: .body}'`

If new reviews or comments appeared, dispatch pr-feedback-handler. Exit the loop when state is MERGED or CLOSED.

## Error Handling

### If pr-opener fails
- Fix issue in worktree
- Retry pr-opener
- Cannot proceed without PR

### If pr-feedback-handler fails
- MUST NOT abandon PR
- Escalate to the orchestrating agent
- Document failure reason
- Assign alternative handler

### If pr-merger fails
- Check merge conflicts → dispatch fix
- Check CI failures → dispatch fix
- Check permissions → escalate
- MUST resolve - merge is Definition of Done

## State Tracking Requirements

Every PR must track:
- PR number
- Branch name
- Worktree path
- Current status (opened, feedback_pending, ready_to_merge, merged)
- Opened timestamp
- Last action timestamp
- Pending review count
- CI status
- Next check timestamp
- Assigned handler

## Completion Criteria

The orchestrator's job is complete when:
1. ✅ PR is created
2. ✅ All feedback handled
3. ✅ PR is merged
4. ✅ Worktree cleaned up
5. ✅ Final report delivered to user
